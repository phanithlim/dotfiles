package main

// Form state and keys.

import (
	"os"
	"path/filepath"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

type model struct {
	width, height int
	kind          int    // index in kinds
	focus         string // "sidebar", a field id, or "buttons"
	insert        bool   // Vim insert mode in a text field
	pendingG      bool   // saw the first g of gg
	button        int    // 0 Cancel/Back, 1 Next/Create
	err           string // shown in red at the bottom

	inputs map[string]*textinput.Model // typed fields
	edited map[string]bool             // typed in by you, so it stops following
	choice map[string]int              // picked option per choice field
	git    bool

	// dependencies page
	depsPage bool
	deps     []dep
	groups   []string        // group names in order
	open     map[string]bool // groups shown open
	picked   map[string]bool
	boots    []string // Spring Boot versions
	boot     int      // picked version
	search   textinput.Model
	cursor   int    // row in the tree
	depFocus string // "version", "list" or "buttons"
	pendingZ bool   // saw the z of za/zR/zM

	create bool // Create was pressed
}

func newModel() model {
	m := model{
		width: 100, height: 30,
		focus:  "name",
		button: 1,
		inputs: map[string]*textinput.Model{},
		edited: map[string]bool{},
		choice: map[string]int{},
		picked: map[string]bool{},
		open:   map[string]bool{},
	}
	for id, f := range fields {
		if f.options == nil {
			t := textinput.New()
			t.Prompt = ""
			t.Width = inputWidth - 1
			t.SetValue(f.start)
			m.inputs[id] = &t
			continue
		}
		for i, o := range f.options {
			if o == f.start {
				m.choice[id] = i
			}
		}
	}
	delete(m.inputs, "git")
	m.search = textinput.New()
	m.search.Prompt = ""
	m.search.Placeholder = "search"
	return m
}

func (m model) Init() tea.Cmd { return tea.Batch(textinput.Blink, loadSpringMeta) }

func (m model) currentKind() Kind { return kinds[m.kind] }

func (m model) value(id string) string {
	if t, ok := m.inputs[id]; ok {
		return t.Value()
	}
	opts := fields[id].options
	if len(opts) == 0 {
		return ""
	}
	return opts[m.choice[id]%len(opts)]
}

func (m model) dest() string {
	return filepath.Join(expand(m.value("location")), m.value("name"))
}

func (m model) project() Project {
	values := map[string]string{}
	for id := range fields {
		values[id] = m.value(id)
	}
	p := Project{Name: m.value("name"), Dest: m.dest(), Git: m.git, Values: values}
	for _, d := range m.pickedDeps() {
		p.Deps = append(p.Deps, d.id)
	}
	if m.boot < len(m.boots) {
		p.Boot = m.boots[m.boot]
	}
	return p
}

// Rows for the current kind.
func (m model) rows() []string {
	rows := []string{"name", "location", "git"}
	rows = append(rows, m.currentKind().Fields(m.project())...)
	return append(rows, "open")
}

func (m model) validate() string {
	p := m.project()
	if !nameRe.MatchString(p.Name) {
		return "Name: use only letters, numbers, - and _"
	}
	if check := m.currentKind().Validate; check != nil {
		if msg := check(p); msg != "" {
			return msg
		}
	}
	if _, err := os.Stat(p.Dest); err == nil {
		return short(p.Dest) + " already exists"
	}
	return ""
}

func (m model) stops() []string {
	return append(append([]string{"sidebar"}, m.rows()...), "buttons")
}

func (m *model) focusOn(id string) {
	m.focus, m.insert = id, false
	for _, t := range m.inputs {
		t.Blur()
	}
}

func (m *model) move(step int) {
	stops := m.stops()
	at := 0
	for i, s := range stops {
		if s == m.focus {
			at = i
		}
	}
	m.focusOn(stops[(at+step+len(stops))%len(stops)])
}

func (m *model) switchKind(step int) {
	m.kind = (m.kind + step + len(kinds)) % len(kinds)
	m.err = ""
	for _, s := range m.stops() {
		if s == m.focus {
			return
		}
	}
	m.focusOn("name")
}

func (m *model) startInsert(clear bool) {
	t, ok := m.inputs[m.focus]
	if !ok {
		return
	}
	if clear {
		t.SetValue("")
	}
	m.insert = true
	t.Focus()
	t.CursorEnd()
}

// Fill fields that copy others.
func (m *model) follow() {
	for id, t := range m.inputs {
		if v, ok := followValue(id, m.value); ok && !m.edited[id] {
			t.SetValue(v)
		}
	}
}

// Next or Create.
func (m model) submit() (tea.Model, tea.Cmd) {
	if m.err = m.validate(); m.err != "" {
		return m, nil
	}
	if !m.depsPage && m.currentKind().HasDeps {
		m.depsPage, m.button, m.depFocus = true, 1, "list"
		m.focusOn(m.focus)
		return m, nil
	}
	m.create = true
	return m, tea.Quit
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case springMeta:
		m.loadMeta(msg)
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c":
			return m, tea.Quit
		case "ctrl+s":
			return m.submit()
		}
		switch {
		case m.depsPage:
			return m.depsKeys(msg)
		case m.insert:
			return m.insertKeys(msg)
		default:
			return m.normalKeys(msg)
		}
	}
	return m, nil
}

// Insert mode.
func (m model) insertKeys(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "esc":
		m.focusOn(m.focus)
		return m, nil
	case "enter", "tab":
		m.move(1)
		return m, nil
	}
	t := m.inputs[m.focus]
	before := t.Value()
	var cmd tea.Cmd
	*t, cmd = t.Update(msg)
	if t.Value() != before {
		m.edited[m.focus] = true
	}
	m.follow()
	m.err = ""
	return m, cmd
}

// Normal mode.
func (m model) normalKeys(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	key := msg.String()
	m.err = ""

	if m.pendingG {
		m.pendingG = false
		if key == "g" {
			m.focusOn(m.stops()[1])
			return m, nil
		}
	}

	switch key {
	case "q":
		return m, tea.Quit
	case "g":
		m.pendingG = true
	case "G":
		m.focusOn("buttons")
	case "J":
		m.switchKind(1)
	case "K":
		m.switchKind(-1)
	case "tab":
		m.move(1)
	case "shift+tab":
		m.move(-1)
	default:
		return m.rowKeys(key)
	}
	return m, nil
}

// Keys for the current row.
func (m model) rowKeys(key string) (tea.Model, tea.Cmd) {
	if m.focus == "sidebar" {
		switch key {
		case "j", "down":
			m.switchKind(1)
		case "k", "up":
			m.switchKind(-1)
		case "l", "right", "enter":
			m.move(1)
		}
		return m, nil
	}

	switch key {
	case "j", "down":
		m.move(1)
		return m, nil
	case "k", "up":
		m.move(-1)
		return m, nil
	}

	switch options := fields[m.focus].options; {
	case m.focus == "buttons":
		switch key {
		case "h", "left", "l", "right":
			m.button = 1 - m.button
		case "enter", " ":
			if m.button == 0 {
				return m, tea.Quit
			}
			return m.submit()
		}

	case m.focus == "git":
		if key == " " || key == "x" || key == "enter" {
			m.git = !m.git
		}

	case options != nil:
		n := len(options)
		switch key {
		case "h", "left":
			m.choice[m.focus] = (m.choice[m.focus] + n - 1) % n
		case "l", "right", " ":
			m.choice[m.focus] = (m.choice[m.focus] + 1) % n
		case "enter":
			m.move(1)
		}

	default: // a typed field
		switch key {
		case "i", "a", "I", "A", "enter":
			m.startInsert(false)
		case "C", "S":
			m.startInsert(true)
		case "h":
			m.focusOn("sidebar")
		}
	}
	return m, nil
}

package main

// Spring dependencies page.

import (
	"fmt"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// A tree line: a group or a dependency.
type depRow struct {
	group string
	dep   *dep
}

func (m *model) loadMeta(meta springMeta) {
	m.deps, m.boots = meta.deps, meta.boots
	m.groups = nil
	for _, d := range m.deps {
		if len(m.groups) == 0 || m.groups[len(m.groups)-1] != d.group {
			m.groups = append(m.groups, d.group)
		}
	}
	for i, v := range m.boots {
		if v == meta.boot {
			m.boot = i
		}
	}
	if len(m.groups) > 0 {
		m.open[m.groups[0]] = true
	}
}

func (m model) pickedDeps() []dep {
	var out []dep
	for _, d := range m.deps {
		if m.picked[d.id] {
			out = append(out, d)
		}
	}
	return out
}

// Tree lines to show.
func (m model) depRows() []depRow {
	query := strings.ToLower(m.search.Value())
	var rows []depRow
	for _, group := range m.groups {
		var items []depRow
		for i := range m.deps {
			d := &m.deps[i]
			text := strings.ToLower(d.name + " " + d.group + " " + d.id)
			if d.group == group && strings.Contains(text, query) {
				items = append(items, depRow{group, d})
			}
		}
		if len(items) == 0 {
			continue
		}
		rows = append(rows, depRow{group: group})
		if query != "" || m.open[group] {
			rows = append(rows, items...)
		}
	}
	return rows
}

func (m model) depsKeys(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	key := msg.String()

	if m.search.Focused() {
		switch key {
		case "esc", "enter":
			m.search.Blur()
		case "down", "ctrl+n", "ctrl+j":
			m.search.Blur()
			m.depFocus = "list"
		default:
			var cmd tea.Cmd
			m.search, cmd = m.search.Update(msg)
			m.cursor = 0
			return m, cmd
		}
		return m, nil
	}

	if m.pendingG {
		m.pendingG = false
		if key == "g" {
			m.depFocus, m.cursor = "list", 0
			return m, nil
		}
	}
	if m.pendingZ {
		m.pendingZ = false
		m.foldKeys(key)
		return m, nil
	}

	focusOrder := []string{"version", "list", "buttons"}
	switch key {
	case "esc", "q":
		m.depsPage = false
	case "/", "i":
		m.search.Focus()
		m.depFocus = "list"
	case "tab":
		m.depFocus = next(focusOrder, m.depFocus, 1)
	case "shift+tab":
		m.depFocus = next(focusOrder, m.depFocus, -1)
	case "g":
		m.pendingG = true
	case "G":
		m.depFocus = "buttons"
	case "z":
		m.pendingZ = true
	default:
		switch m.depFocus {
		case "version":
			m.versionKeys(key)
		case "buttons":
			return m.depButtonKeys(key)
		default:
			m.treeKeys(key)
		}
	}
	return m, nil
}

// Next item, wraps around.
func next(list []string, current string, step int) string {
	for i, s := range list {
		if s == current {
			return list[(i+step+len(list))%len(list)]
		}
	}
	return list[0]
}

// zR, zM, za, zo, zc
func (m *model) foldKeys(key string) {
	rows := m.depRows()
	switch key {
	case "R", "M":
		for _, g := range m.groups {
			m.open[g] = key == "R"
		}
		m.cursor = 0
	case "a", "o", "c":
		if m.cursor < len(rows) {
			g := rows[m.cursor].group
			m.open[g] = map[string]bool{"a": !m.open[g], "o": true, "c": false}[key]
			m.cursor = m.groupRow(g)
		}
	}
}

// Line of a group.
func (m model) groupRow(group string) int {
	for i, r := range m.depRows() {
		if r.dep == nil && r.group == group {
			return i
		}
	}
	return 0
}

func (m *model) versionKeys(key string) {
	n := len(m.boots)
	switch key {
	case "h", "left":
		if n > 0 {
			m.boot = (m.boot + n - 1) % n
		}
	case "l", "right", " ":
		if n > 0 {
			m.boot = (m.boot + 1) % n
		}
	case "j", "down", "enter":
		m.depFocus = "list"
	}
}

func (m model) depButtonKeys(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "h", "left", "l", "right":
		m.button = 1 - m.button
	case "k", "up":
		m.depFocus = "list"
	case "enter", " ":
		if m.button == 0 {
			m.depsPage, m.button = false, 1
			return m, nil
		}
		return m.submit()
	}
	return m, nil
}

func (m *model) treeKeys(key string) {
	rows := m.depRows()
	if len(rows) == 0 {
		return
	}
	m.cursor = min(m.cursor, len(rows)-1)
	row := rows[m.cursor]

	switch key {
	case "j", "down", "ctrl+n":
		if m.cursor < len(rows)-1 {
			m.cursor++
		} else {
			m.depFocus = "buttons"
		}
	case "k", "up", "ctrl+p":
		if m.cursor > 0 {
			m.cursor--
		} else {
			m.depFocus = "version"
		}
	case "ctrl+d":
		m.cursor = min(len(rows)-1, m.cursor+10)
	case "ctrl+u":
		m.cursor = max(0, m.cursor-10)
	case "l", "right":
		if row.dep == nil {
			m.open[row.group] = true
		}
	case "h", "left":
		// item: go to group. group: close it.
		if row.dep != nil {
			m.cursor = m.groupRow(row.group)
		} else {
			m.open[row.group] = false
		}
	case " ", "x", "enter":
		if row.dep == nil {
			m.open[row.group] = !m.open[row.group]
		} else {
			m.picked[row.dep.id] = !m.picked[row.dep.id]
		}
	}
}

func (m model) depsView(height int) string {
	rows := m.depRows()
	cursor := min(m.cursor, max(0, len(rows)-1))
	leftWidth := max(40, (m.width-8)/2)
	rightWidth := max(30, m.width-leftWidth-10)

	version := mutedStyle.Render("Spring Boot  ") + m.versionView()

	search := mutedStyle.Render("/ ") + m.search.View()
	if m.search.Focused() {
		search = focusStyle.Render("/ ") + m.search.View()
	}
	left := []string{version, "", search, ""}
	if m.deps == nil {
		left = append(left, mutedStyle.Render("loading from start.spring.io…"))
	}

	listHeight := max(3, height-8)
	start := max(0, cursor-listHeight+1)
	for i := start; i < len(rows) && i < start+listHeight; i++ {
		left = append(left, m.treeLine(rows[i], i == cursor && m.depFocus == "list" && !m.search.Focused()))
	}
	if m.deps != nil && len(rows) == 0 {
		left = append(left, mutedStyle.Render("no match"))
	}

	right := m.detailView(rows, cursor, rightWidth)

	body := lipgloss.JoinHorizontal(lipgloss.Top,
		lipgloss.NewStyle().Width(leftWidth).Height(height).Padding(1, 2).Render(strings.Join(left, "\n")),
		lipgloss.NewStyle().Width(rightWidth).Height(height).Padding(1, 2).Render(right),
	)

	help := "j/k move · l/h open/close · space pick · za/zR/zM fold · / search · ctrl+s create · esc back"
	if m.search.Focused() {
		help = "type to filter · esc or enter done"
	}
	return m.frame(body, help, m.buttonsView("Back", "Create", m.depFocus == "buttons"))
}

func (m model) versionView() string {
	if len(m.boots) == 0 {
		return mutedStyle.Render("default")
	}
	var parts []string
	for i, v := range m.boots {
		switch {
		case i == m.boot && m.depFocus == "version":
			parts = append(parts, onStyle.Render(" "+v+" "))
		case i == m.boot:
			parts = append(parts, focusStyle.Render(" "+v+" "))
		default:
			parts = append(parts, mutedStyle.Render(" "+v+" "))
		}
	}
	return strings.Join(parts, " ")
}

// "▾ Developer Tools  2" or "    [x] Lombok"
func (m model) treeLine(row depRow, current bool) string {
	marker := "  "
	if current {
		marker = focusStyle.Render("▌ ")
	}
	if row.dep == nil {
		arrow := "▸ "
		if m.open[row.group] || m.search.Value() != "" {
			arrow = "▾ "
		}
		count := 0
		for _, d := range m.pickedDeps() {
			if d.group == row.group {
				count++
			}
		}
		line := arrow + lipgloss.NewStyle().Bold(true).Render(row.group)
		if count > 0 {
			line += okStyle.Render(fmt.Sprintf("  %d", count))
		}
		return marker + line
	}
	box := mutedStyle.Render("[ ] ")
	if m.picked[row.dep.id] {
		box = okStyle.Render("[x] ")
	}
	return marker + "    " + box + row.dep.name
}

// Right side: details and picks.
func (m model) detailView(rows []depRow, cursor, width int) string {
	wrap := lipgloss.NewStyle().Width(width - 4)
	var lines []string

	if cursor < len(rows) && m.depFocus == "list" {
		row := rows[cursor]
		if row.dep != nil {
			lines = append(lines, titleStyle.Render(row.dep.name), wrap.Render(row.dep.desc))
		} else {
			count := 0
			for _, d := range m.deps {
				if d.group == row.group {
					count++
				}
			}
			lines = append(lines, titleStyle.Render(row.group), mutedStyle.Render(fmt.Sprintf("%d dependencies", count)))
		}
	}

	picked := m.pickedDeps()
	lines = append(lines, "", "", titleStyle.Render("Added dependencies")+mutedStyle.Render(fmt.Sprintf("  %d", len(picked))))
	if len(picked) == 0 {
		lines = append(lines, mutedStyle.Render("none yet"))
	}
	for _, d := range picked {
		lines = append(lines, okStyle.Render("• ")+d.name+mutedStyle.Render("  "+d.group))
	}
	return strings.Join(lines, "\n")
}

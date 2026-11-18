package main

// Drawing. Uses terminal colors, so it follows the theme.

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

const inputWidth = 40

var (
	accent = lipgloss.Color("4")
	muted  = lipgloss.Color("8")
	red    = lipgloss.Color("1")
	green  = lipgloss.Color("2")
	black  = lipgloss.Color("0")

	titleStyle = lipgloss.NewStyle().Bold(true).Foreground(accent)
	mutedStyle = lipgloss.NewStyle().Foreground(muted)
	focusStyle = lipgloss.NewStyle().Bold(true).Foreground(accent)
	errStyle   = lipgloss.NewStyle().Foreground(red)
	okStyle    = lipgloss.NewStyle().Bold(true).Foreground(green)
	onStyle    = lipgloss.NewStyle().Bold(true).Foreground(black).Background(accent)
	boxStyle   = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(accent).Padding(0, 2)
)

func (m model) View() string {
	height := max(5, m.height-2)
	if m.depsPage {
		return m.depsView(height)
	}

	// basics, kind settings, open in
	k := m.currentKind()
	rows := m.rows()
	block := func(ids []string) string {
		var lines []string
		for _, id := range ids {
			lines = append(lines, m.rowView(id))
		}
		return strings.Join(lines, "\n")
	}
	form := strings.Join([]string{
		titleStyle.Render("New project") + mutedStyle.Render("  "+k.Desc),
		block(rows[:3]),
		block(rows[3 : len(rows)-1]),
		block(rows[len(rows)-1:]),
	}, "\n\n")
	form = lipgloss.NewStyle().Height(height).Padding(1, 4).Render(form)
	body := lipgloss.JoinHorizontal(lipgloss.Top, m.sidebarView(height), form)

	next := "Create"
	if k.HasDeps {
		next = "Next"
	}
	help := "j/k move · h/l choose · i edit · J/K kind · gg/G top/bottom · ctrl+s " + strings.ToLower(next) + " · q quit"
	if m.insert {
		help = "type · esc normal mode · enter next field"
	}
	return m.frame(body, help, m.buttonsView("Cancel", next, m.focus == "buttons"))
}

// One form row.
func (m model) rowView(id string) string {
	label := fmt.Sprintf("%-16s", fields[id].label)
	out := "  " + mutedStyle.Render(label)
	if m.focus == id {
		out = focusStyle.Render("▌ " + label)
	}

	switch {
	case id == "git":
		box := "[ ]"
		if m.git {
			box = okStyle.Render("[x]")
		}
		out += box + " Create Git repository"
	case fields[id].options != nil:
		out += m.choiceView(id)
	case id == "location":
		// folder, then the project name
		out += m.inputView(id) + mutedStyle.Render("/"+m.value("name"))
	default:
		out += m.inputView(id)
	}
	return out
}

// Choices in a row.
func (m model) choiceView(id string) string {
	var parts []string
	for i, o := range fields[id].options {
		text := " " + o + " "
		switch {
		case i == m.choice[id] && m.focus == id:
			parts = append(parts, onStyle.Render(text))
		case i == m.choice[id]:
			parts = append(parts, focusStyle.Render(text))
		default:
			parts = append(parts, mutedStyle.Render(text))
		}
	}
	return strings.Join(parts, " ")
}

// Typed field. The space lines it up with choices.
func (m model) inputView(id string) string {
	switch {
	case m.focus == id && m.insert:
		return " " + m.inputs[id].View()
	case m.focus == id:
		return " " + focusStyle.Render(m.value(id))
	}
	return " " + m.value(id)
}

func (m model) sidebarView(height int) string {
	var lines []string
	group := ""
	for i, k := range kinds {
		if k.Group != group {
			if group != "" {
				lines = append(lines, "")
			}
			group = k.Group
			lines = append(lines, mutedStyle.Render(group))
		}
		text := "  " + k.Name
		switch {
		case i == m.kind && m.focus == "sidebar":
			text = onStyle.Render(fmt.Sprintf("▌ %-14s", k.Name))
		case i == m.kind:
			text = focusStyle.Render("▌ " + k.Name)
		}
		lines = append(lines, text)
	}
	return lipgloss.NewStyle().Width(20).Height(height).Padding(1, 1).
		Render(strings.Join(lines, "\n"))
}

func (m model) buttonsView(left, right string, focused bool) string {
	cancel := mutedStyle.Render("[ " + left + " ]")
	primary := focusStyle.Render("[ " + right + " ]")
	if focused && m.button == 0 {
		cancel = onStyle.Render("[ " + left + " ]")
	}
	if focused && m.button == 1 {
		primary = onStyle.Render("[ " + right + " ]")
	}
	return cancel + "  " + primary
}

// NORMAL or INSERT.
func (m model) modeView() string {
	if m.insert || m.search.Focused() {
		return lipgloss.NewStyle().Bold(true).Foreground(black).Background(green).Render(" INSERT ")
	}
	return onStyle.Render(" NORMAL ")
}

// Body and footer.
func (m model) frame(body, help, buttons string) string {
	width := m.width - 2
	left := m.modeView() + " " + mutedStyle.Render(help)
	if m.err != "" {
		left = m.modeView() + " " + errStyle.Render("✗ "+m.err)
	}
	gap := max(1, width-lipgloss.Width(left)-lipgloss.Width(buttons))
	footer := left + strings.Repeat(" ", gap) + buttons

	return lipgloss.NewStyle().Padding(0, 1).Render(body + "\n" + footer)
}

// mkproj makes a new project. Build: go build -o ~/.local/bin/mkproj
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	loadFields()

	final, err := tea.NewProgram(newModel(), tea.WithAltScreen()).Run()
	if err != nil {
		fail(err.Error())
	}
	m := final.(model)
	if !m.create {
		return
	}

	p := m.project()
	mkdir(parentOf(p.Dest))
	fmt.Println()
	result := m.currentKind().Make(p)
	if p.Git && !result.GitDone {
		run(p.Dest, "Creating git repo", "git", "init", "-q")
	}

	where := short(p.Dest)
	fmt.Println(boxStyle.Render(strings.Join([]string{
		okStyle.Render("✓ Created " + where), "",
		"Run it   cd " + where + " && " + result.Run,
	}, "\n")))

	openIn(p.Get("open"), p.Dest)
}

// Open the project in herdr or tmux.
func openIn(where, dir string) {
	script := map[string]string{"herdr": "herdr-sessionizer", "tmux": "tmux-sessionizer"}[where]
	if script == "" {
		return
	}
	cmd := exec.Command(script, dir)
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	cmd.Run()
}

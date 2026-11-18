package main

// Run commands and handle paths.

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

var (
	home, _   = os.UserHomeDir()
	nameRe    = regexp.MustCompile(`^[A-Za-z0-9_-]+$`)
	npmNameRe = regexp.MustCompile(`^[a-z0-9][a-z0-9._-]*$`)
	packageRe = regexp.MustCompile(`^[A-Za-z_]\w*(\.[A-Za-z_]\w*)*$`)
)

// Print a step.
func say(text string) {
	fmt.Println(mutedStyle.Render("  " + text + "…"))
}

// Stop with an error.
func fail(text string) {
	fmt.Println(errStyle.Render("  ✗ " + text))
	os.Exit(1)
}

// Run quietly. Show output only on error.
func run(dir, title, name string, args ...string) {
	say(title)
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	if out, err := cmd.CombinedOutput(); err != nil {
		fmt.Print(string(out))
		fail(title + " failed: " + err.Error())
	}
}

// Run in the terminal, so you see it and can answer.
func runLive(dir, title, name string, args ...string) {
	say(title)
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	if err := cmd.Run(); err != nil {
		fail(title + " failed: " + err.Error())
	}
}

func mkdir(path string) {
	if err := os.MkdirAll(path, 0o755); err != nil {
		fail(err.Error())
	}
}

func writeFile(dir, name, text string) {
	if err := os.WriteFile(filepath.Join(dir, name), []byte(text), 0o644); err != nil {
		fail(err.Error())
	}
}

func parentOf(path string) string { return filepath.Dir(path) }

// /home/me/x -> ~/x
func short(path string) string {
	if strings.HasPrefix(path, home) {
		return "~" + strings.TrimPrefix(path, home)
	}
	return path
}

// ~/x -> /home/me/x
func expand(path string) string {
	if strings.HasPrefix(path, "~") {
		return home + strings.TrimPrefix(path, "~")
	}
	return path
}

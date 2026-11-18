package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

// A form field. With options you pick one, without you type it.
type field struct {
	label   string
	options []string
	start   string // starting text, or the option picked at first
}

// All fields by id.
var fields map[string]field

func loadFields() {
	cwd, _ := os.Getwd()
	javas, currentJava := javaVersions()
	pythons := pythonVersions()

	open := "herdr"
	if os.Getenv("TMUX") != "" {
		open = "tmux"
	} else if os.Getenv("HERDR_PANE_ID") == "" {
		open = "don't open"
	}

	fields = map[string]field{
		// every kind
		"name":     {label: "Name", start: "demo"},
		"location": {label: "Location", start: short(cwd)},
		"git":      {label: "Git"}, // a tick box, drawn on its own
		"open":     {label: "Open in", options: []string{"herdr", "tmux", "don't open"}, start: open},

		// JVM
		"build":     {label: "Build system", options: []string{"Gradle", "Maven"}},
		"dsl":       {label: "Gradle DSL", options: []string{"Kotlin", "Groovy"}},
		"java":      {label: "Java", options: javas, start: currentJava},
		"group":     {label: "Group", start: "com.example"},
		"artifact":  {label: "Artifact", start: "demo"},
		"package":   {label: "Package name", start: "com.example.demo"},
		"lang":      {label: "Language", options: []string{"Java", "Kotlin", "Groovy"}},
		"type":      {label: "Type", options: []string{"Gradle - Groovy", "Gradle - Kotlin", "Maven"}},
		"packaging": {label: "Packaging", options: []string{"Jar", "War"}},
		"config":    {label: "Configuration", options: []string{"Properties", "YAML"}},

		// web
		"ts":       {label: "Language", options: []string{"TypeScript", "JavaScript"}},
		"tailwind": {label: "Tailwind", options: []string{"Yes", "No"}},
		"srcdir":   {label: "src/ folder", options: []string{"No", "Yes"}},
		"pm":       {label: "Package manager", options: []string{"pnpm", "npm", "bun"}},

		// Go
		"module":   {label: "Module path", start: "demo"},
		"template": {label: "Template", options: []string{"CLI", "HTTP server"}},

		// Python
		"layout": {label: "Layout", options: []string{"Flat", "src"}},
		"python": {label: "Python", options: pythons, start: pythons[len(pythons)-1]},
	}
}

// Fields that copy others until you edit them.
func followValue(id string, get func(string) string) (string, bool) {
	switch id {
	case "artifact", "module":
		return get("name"), true
	case "package":
		return get("group") + "." + packagePart(get("artifact")), true
	}
	return "", false
}

// "my-App" -> "myapp", usable in a Java package name
func packagePart(s string) string {
	return strings.ToLower(regexp.MustCompile(`[^A-Za-z0-9]`).ReplaceAllString(s, ""))
}

// Installed Java versions and the current one.
func javaVersions() ([]string, string) {
	folder := filepath.Join(home, ".sdkman/candidates/java")
	seen := map[int]bool{}
	entries, _ := os.ReadDir(folder)
	for _, e := range entries {
		if n, err := strconv.Atoi(strings.SplitN(e.Name(), ".", 2)[0]); err == nil {
			seen[n] = true
		}
	}
	list := sortedNumbers(seen, "")
	if len(list) == 0 {
		list = []string{"17", "21", "25"}
	}
	current := "21"
	if target, err := os.Readlink(filepath.Join(folder, "current")); err == nil {
		current = strings.SplitN(filepath.Base(target), ".", 2)[0]
	}
	return list, current
}

// Installed Python versions.
func pythonVersions() []string {
	out, _ := exec.Command("uv", "python", "list", "--only-installed").Output()
	seen := map[int]bool{}
	for _, match := range regexp.MustCompile(`cpython-3\.(\d+)\.`).FindAllStringSubmatch(string(out), -1) {
		n, _ := strconv.Atoi(match[1])
		seen[n] = true
	}
	list := sortedNumbers(seen, "3.")
	if len(list) == 0 {
		list = []string{"3.13"}
	}
	return list
}

func sortedNumbers(seen map[int]bool, prefix string) []string {
	var nums []int
	for n := range seen {
		nums = append(nums, n)
	}
	sort.Ints(nums)
	var list []string
	for _, n := range nums {
		list = append(list, prefix+strconv.Itoa(n))
	}
	return list
}

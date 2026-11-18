package main

// Python app with uv. Flat: main.py on top. src: code in src/.
var pythonKind = Kind{
	Name:  "Python",
	Group: "Other",
	Desc:  "Python app managed by uv",
	Fields: func(p Project) []string {
		return []string{"layout", "python"}
	},
	Make: func(p Project) Result {
		vcs := "none"
		if p.Git {
			vcs = "git"
		}
		layout, hint := "--app", "uv run main.py"
		if p.Get("layout") == "src" {
			layout, hint = "--package", "uv run "+p.Name
		}
		run("", "Running uv init", "uv", "init", layout,
			"--python", p.Get("python"), "--name", p.Name, "--vcs", vcs, p.Dest)
		return Result{Run: hint, GitDone: true}
	},
}

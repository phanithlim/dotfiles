package main

// Next.js and Nuxt. Their tools run in the terminal.

var nextKind = Kind{
	Name:  "Next.js",
	Group: "Web",
	Desc:  "React full-stack app, with create-next-app",
	Fields: func(p Project) []string {
		return []string{"ts", "tailwind", "srcdir", "pm"}
	},
	Validate: checkNpmName,
	Make: func(p Project) Result {
		pm := p.Get("pm")
		args := []string{"create-next-app@latest", p.Name,
			"--eslint", "--app", "--import-alias", "@/*", "--use-" + pm, "--yes",
			map[string]string{"TypeScript": "--ts", "JavaScript": "--js"}[p.Get("ts")],
			map[string]string{"Yes": "--tailwind", "No": "--no-tailwind"}[p.Get("tailwind")],
			map[string]string{"Yes": "--src-dir", "No": "--no-src-dir"}[p.Get("srcdir")],
		}
		if !p.Git {
			args = append(args, "--disable-git")
		}
		runPackage(pm, parentOf(p.Dest), "Running create-next-app", args...)
		return Result{Run: devCommand(pm), GitDone: true}
	},
}

var nuxtKind = Kind{
	Name:  "Nuxt",
	Group: "Web",
	Desc:  "Vue full-stack app, with nuxi init",
	Fields: func(p Project) []string {
		return []string{"pm"}
	},
	Validate: checkNpmName,
	Make: func(p Project) Result {
		pm := p.Get("pm")
		git := "--no-gitInit"
		if p.Git {
			git = "--gitInit"
		}
		runPackage(pm, parentOf(p.Dest), "Running nuxi init",
			"nuxi@latest", "init", p.Name, "--packageManager", pm, git)
		return Result{Run: devCommand(pm), GitDone: true}
	},
}

// npm names must be lowercase.
func checkNpmName(p Project) string {
	if !npmNameRe.MatchString(p.Name) {
		return "Name: use lowercase letters, numbers, - and _ (npm rule)"
	}
	return ""
}

// Run an npm package with pnpm, npm or bun.
func runPackage(pm, dir, title string, args ...string) {
	runner := map[string][]string{"pnpm": {"pnpm", "dlx"}, "npm": {"npx", "-y"}, "bun": {"bunx"}}[pm]
	all := append(runner[1:], args...)
	runLive(dir, title, runner[0], all...)
}

func devCommand(pm string) string {
	if pm == "npm" {
		return "npm run dev"
	}
	return pm + " dev"
}

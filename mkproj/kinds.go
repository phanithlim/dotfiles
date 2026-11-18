package main

// One project type. To add one, copy kind_go.go and add it to kinds below.
type Kind struct {
	Name  string // shown in the sidebar
	Group string // sidebar heading it sits under
	Desc  string // one line shown above the form

	// Rows after Name, Location and Git.
	Fields func(p Project) []string

	// Extra checks. Return "" if fine.
	Validate func(p Project) string

	// Show the dependencies page.
	HasDeps bool

	// Make the project.
	Make func(p Project) Result
}

// The form values.
type Project struct {
	Name   string
	Dest   string            // full path of the new project folder
	Git    bool              // "Create Git repository" ticked
	Values map[string]string // every field: typed text or picked option
	Deps   []string          // Spring dependency ids
	Boot   string            // Spring Boot version, "" for start.spring.io's default
}

func (p Project) Get(id string) string { return p.Values[id] }

// Shown when done.
type Result struct {
	Run     string // command to run the new project
	GitDone bool   // the tool already made the git repo
}

// Sidebar order.
var kinds = []Kind{
	plainJVM("Java", "Plain Java app, built with Gradle or Maven"),
	plainJVM("Kotlin", "Plain Kotlin app, built with Gradle"),
	plainJVM("Groovy", "Plain Groovy app, built with Gradle"),
	springKind,
	nextKind,
	nuxtKind,
	goKind,
	pythonKind,
}

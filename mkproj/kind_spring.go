package main

import (
	"encoding/json"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	tea "github.com/charmbracelet/bubbletea"
)

// Spring Boot, from start.spring.io.
var springKind = Kind{
	Name:  "Spring Boot",
	Group: "JVM",
	Desc:  "Web apps and APIs, from start.spring.io",
	Fields: func(p Project) []string {
		return []string{"lang", "type", "group", "artifact", "package", "java", "packaging", "config"}
	},
	Validate: func(p Project) string {
		if !packageRe.MatchString(p.Get("package")) {
			return "Package name: use a name like com.example.demo"
		}
		return checkGroupArtifact(p)
	},
	HasDeps: true,
	Make:    makeSpring,
}

func makeSpring(p Project) Result {
	types := map[string]string{
		"Gradle - Groovy": "gradle-project",
		"Gradle - Kotlin": "gradle-project-kotlin",
		"Maven":           "maven-project",
	}
	query := url.Values{
		"type":                    {types[p.Get("type")]},
		"language":                {strings.ToLower(p.Get("lang"))},
		"javaVersion":             {p.Get("java")},
		"groupId":                 {p.Get("group")},
		"artifactId":              {p.Get("artifact")},
		"name":                    {p.Name},
		"packageName":             {p.Get("package")},
		"packaging":               {strings.ToLower(p.Get("packaging"))},
		"configurationFileFormat": {strings.ToLower(p.Get("config"))},
		"dependencies":            {strings.Join(p.Deps, ",")},
	}
	if p.Boot != "" {
		query.Set("bootVersion", p.Boot)
	}

	say("Downloading from start.spring.io")
	res, err := http.Get("https://start.spring.io/starter.zip?" + query.Encode())
	if err != nil || res.StatusCode != 200 {
		fail("start.spring.io did not accept these settings " +
			"(a dependency may not work with Spring Boot " + p.Boot + ", or Java " + p.Get("java") + ")")
	}
	zip, _ := os.CreateTemp("", "mkproj-*.zip")
	io.Copy(zip, res.Body)
	res.Body.Close()
	zip.Close()
	defer os.Remove(zip.Name())
	run("", "Unzipping", "unzip", "-q", zip.Name(), "-d", p.Dest)
	writeSdkmanrc(p)

	if p.Get("type") == "Maven" {
		return Result{Run: "./mvnw spring-boot:run"}
	}
	return Result{Run: "./gradlew bootRun"}
}

// One Spring dependency.
type dep struct{ id, name, group, desc string }

// What start.spring.io offers.
type springMeta struct {
	deps  []dep    // in start.spring.io's order, grouped
	boots []string // Spring Boot versions, newest first
	boot  string   // the version start.spring.io picks by default
}

// Load from start.spring.io, or a short list when offline.
func loadSpringMeta() tea.Msg {
	offline := springMeta{deps: []dep{
		{"devtools", "Spring Boot DevTools", "Developer Tools", "Fast restarts and live reload."},
		{"lombok", "Lombok", "Developer Tools", "Annotations that cut boilerplate code."},
		{"web", "Spring Web", "Web", "Build web apps and REST APIs with Spring MVC."},
		{"validation", "Validation", "I/O", "Bean Validation with Hibernate Validator."},
		{"security", "Spring Security", "Security", "Authentication and access control."},
		{"data-jpa", "Spring Data JPA", "SQL", "Store data in SQL databases with JPA."},
		{"postgresql", "PostgreSQL Driver", "SQL", "JDBC driver for PostgreSQL."},
		{"flyway", "Flyway Migration", "SQL", "Database schema migrations."},
		{"actuator", "Spring Boot Actuator", "Ops", "Health checks and metrics."},
	}}

	client := http.Client{Timeout: 8 * time.Second}
	req, _ := http.NewRequest("GET", "https://start.spring.io", nil)
	req.Header.Set("Accept", "application/vnd.initializr.v2.2+json")
	res, err := client.Do(req)
	if err != nil {
		return offline
	}
	defer res.Body.Close()

	var data struct {
		BootVersion struct {
			Default string
			Values  []struct{ ID string }
		}
		Dependencies struct {
			Values []struct {
				Name   string
				Values []struct{ ID, Name, Description string }
			}
		}
	}
	if json.NewDecoder(res.Body).Decode(&data) != nil {
		return offline
	}

	var meta springMeta
	for _, group := range data.Dependencies.Values {
		for _, d := range group.Values {
			meta.deps = append(meta.deps, dep{d.ID, d.Name, group.Name, d.Description})
		}
	}
	for _, v := range data.BootVersion.Values {
		meta.boots = append(meta.boots, v.ID)
	}
	meta.boot = data.BootVersion.Default
	if len(meta.deps) == 0 {
		return offline
	}
	return meta
}

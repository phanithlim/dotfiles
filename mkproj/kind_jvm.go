package main

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// Plain Java, Kotlin or Groovy app.
func plainJVM(name, desc string) Kind {
	return Kind{
		Name:  name,
		Group: "JVM",
		Desc:  desc,
		Fields: func(p Project) []string {
			rows := []string{"java", "group", "artifact"}
			if name == "Java" {
				rows = append([]string{"build"}, rows...)
			}
			if p.Get("build") != "Maven" || name != "Java" {
				rows = append(rows, "dsl")
			}
			return rows
		},
		Validate: checkGroupArtifact,
		Make: func(p Project) Result {
			var result Result
			if name == "Java" && p.Get("build") == "Maven" {
				result = makeMaven(p)
			} else {
				result = makeGradle(p, strings.ToLower(name))
			}
			writeSdkmanrc(p)
			return result
		},
	}
}

// .sdkmanrc with the installed JDK, like java=21.0.9-amzn
func writeSdkmanrc(p Project) {
	installed, _ := filepath.Glob(filepath.Join(home, ".sdkman/candidates/java", p.Get("java")+".*"))
	if len(installed) == 0 {
		return
	}
	writeFile(p.Dest, ".sdkmanrc", "java="+filepath.Base(installed[len(installed)-1])+"\n")
}

func checkGroupArtifact(p Project) string {
	if !nameRe.MatchString(p.Get("artifact")) {
		return "Artifact: use only letters, numbers, - and _"
	}
	if !packageRe.MatchString(p.Get("group")) {
		return "Group: use a name like com.example"
	}
	return ""
}

func makeGradle(p Project, language string) Result {
	mkdir(p.Dest)
	run("", "Running gradle init", "gradle", "init", "--into", p.Dest,
		"--type", language+"-application",
		"--dsl", strings.ToLower(p.Get("dsl")),
		"--java-version", p.Get("java"),
		"--project-name", p.Get("artifact"),
		"--package", p.Get("group")+"."+packagePart(p.Get("artifact")),
		"--no-split-project", "--use-defaults")
	return Result{Run: "./gradlew run"}
}

func makeMaven(p Project) Result {
	artifact := p.Get("artifact")

	// Maven names the folder after the artifact, so move it.
	tmp, _ := os.MkdirTemp("", "mkproj")
	defer os.RemoveAll(tmp)
	run(tmp, "Running mvn archetype:generate", "mvn", "-B", "-q", "archetype:generate",
		"-DgroupId="+p.Get("group"),
		"-DartifactId="+artifact,
		"-Dpackage="+p.Get("group")+"."+packagePart(artifact),
		"-DarchetypeArtifactId=maven-archetype-quickstart",
		"-DarchetypeVersion=1.5",
		"-DinteractiveMode=false")
	if err := os.Rename(filepath.Join(tmp, artifact), p.Dest); err != nil {
		run("", "Moving the project", "mv", filepath.Join(tmp, artifact), p.Dest)
	}

	// Use the picked Java version.
	pom := filepath.Join(p.Dest, "pom.xml")
	text, _ := os.ReadFile(pom)
	release := regexp.MustCompile(`<maven.compiler.release>\d+<`)
	text = release.ReplaceAll(text, []byte("<maven.compiler.release>"+p.Get("java")+"<"))
	os.WriteFile(pom, text, 0o644)

	return Result{Run: "mvn package"}
}

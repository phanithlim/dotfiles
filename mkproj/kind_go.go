package main

import "strings"

// Go module with a CLI or HTTP server. Copy this file to add a kind.
var goKind = Kind{
	Name:  "Go",
	Group: "Other",
	Desc:  "Go module with a CLI or an HTTP server",
	Fields: func(p Project) []string {
		return []string{"module", "template"}
	},
	Validate: func(p Project) string {
		if p.Get("module") == "" || strings.ContainsAny(p.Get("module"), " \t") {
			return "Module path: no spaces, like github.com/me/demo"
		}
		return ""
	},
	Make: func(p Project) Result {
		mkdir(p.Dest)
		run(p.Dest, "Running go mod init", "go", "mod", "init", p.Get("module"))
		code := goCLI
		if p.Get("template") == "HTTP server" {
			code = goHTTP
		}
		writeFile(p.Dest, "main.go", code)
		return Result{Run: "go run ."}
	},
}

const goCLI = `package main

import "fmt"

func main() {
	fmt.Println("Hello")
}
`

const goHTTP = `package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Hello")
	})
	log.Println("listening on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
`

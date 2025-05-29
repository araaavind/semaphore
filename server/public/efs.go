package public

import (
	"embed"
)

//go:embed "html"
var Html embed.FS

//go:embed "static"
var Static embed.FS

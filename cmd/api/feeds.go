package main

import (
	"fmt"
	"net/http"
)

func (app *application) addFeedHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Add new feed")
}

func (app *application) getFeedHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	fmt.Fprintf(w, "Feed ID: %d\n", id)
}

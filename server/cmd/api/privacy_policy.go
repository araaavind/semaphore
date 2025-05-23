package main

import (
	"net/http"

	"github.com/aravindmathradan/semaphore/public"
)

func (app *application) privacyPolicy(w http.ResponseWriter, r *http.Request) {
	content, err := public.Html.ReadFile("html/pages/privacy-policy.html")
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}
	w.Header().Set("Content-Type", "text/html")
	w.Write(content)
}

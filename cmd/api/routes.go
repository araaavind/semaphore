package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
)

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodPost, "/v1/feeds", app.addFeedHandler)
	router.HandlerFunc(http.MethodGet, "/v1/feeds/:id", app.getFeedHandler)

	return router
}

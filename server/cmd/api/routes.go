package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
)

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodGet, "/v1/feeds", app.listFeedsHandler)
	router.HandlerFunc(http.MethodGet, "/v1/feeds/:id", app.getFeedHandler)
	router.HandlerFunc(http.MethodPost, "/v1/feedfollows", app.followFeedHandler)

	return app.recoverPanic(router)
}

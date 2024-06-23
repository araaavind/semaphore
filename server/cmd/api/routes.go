package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
)

/*
POST	/feeds						add and follow a feed
GET		/feeds						list all feeds
GET		/feeds/:feed_id				get a feed
PUT		/feeds/:feed_id/followers 	follow a feed
*/

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheck)
	router.HandlerFunc(http.MethodPost, "/v1/feeds", app.addAndFollowFeed)
	router.HandlerFunc(http.MethodGet, "/v1/feeds", app.listFeeds)
	router.HandlerFunc(http.MethodGet, "/v1/feeds/:feed_id", app.getFeed)
	router.HandlerFunc(http.MethodPut, "/v1/feeds/:feed_id/followers", app.followFeed)

	return app.recoverPanic(router)
}

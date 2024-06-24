package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
	"github.com/justinas/alice"
)

/*

Method		Route						Description						Permission			Response
-------------------------------------------------------------------------------------------------------------------

POST		/users						signup							-					user with 201
PUT			/users/activate				activate user					-					empty response with 200

POST		/feeds						add and follow a feed			feeds:write			empty response with 201
GET			/feeds						list all feeds					-					feed list with 200
GET			/feeds/:feed_id				get a feed						-					feed with 200
PUT			/feeds/:feed_id/followers 	follow a feed					feeds:follow		empty response with 200
DELETE		/feeds/:feed_id/followers	unfollow a feed					feeds:follow		empty response with 200

*/

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheck)

	router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/activate", app.activateUser)

	router.HandlerFunc(http.MethodPost, "/v1/tokens/authentication", app.createAuthenticationToken)

	router.HandlerFunc(http.MethodGet, "/v1/feeds", app.listFeeds)
	router.HandlerFunc(http.MethodGet, "/v1/feeds/:feed_id", app.getFeed)

	authenticated := alice.New(app.requireAuthentication)

	router.Handler(http.MethodPut, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.requirePermission("feeds:follow", app.followFeed)))
	router.Handler(http.MethodDelete, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.requirePermission("feeds:follow", app.unfollowFeed)))

	activated := authenticated.Append(app.requireActivation)

	router.Handler(http.MethodPost, "/v1/feeds", activated.ThenFunc(app.requirePermission("feeds:write", app.addAndFollowFeed)))

	standard := alice.New(app.recoverPanic, app.authenticate)
	return standard.Then(router)
}

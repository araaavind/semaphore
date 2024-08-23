package main

import (
	"expvar"
	"net/http"

	"github.com/julienschmidt/httprouter"
	"github.com/justinas/alice"
)

/*

Method		Route						Description								Permission						Response
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

POST		/users						signup									-								user with 201
PUT			/users/activate				activate user							-								empty response with 200
GET			/users/:username			get a user								-							user with 200
HEAD		/users/:username			check if user exists(username taken)	-								empty response with 200 if user exists or 404 for error

GET			/me							get logged in user						auth							user with 200
GET			/me/feeds					get feeds followed by logged in user	auth							feeds list, metadata with 200
GET			/me/feeds/contains			check if user follows feeds				auth							boolean list with 200
GET			/me/walls					list walls of logged in user			auth							walls list with 200

POST		/feeds						add and follow a feed					activation, feeds:write			empty response with 201
GET			/feeds						list all feeds							-								feeds list, metadata with 200
GET			/feeds/:feed_id				get a feed								-								feed with 200
GET			/feeds/:feed_id/followers 	list followers for feed					auth							users list, metadata with 200
PUT			/feeds/:feed_id/followers 	follow a feed							auth, feeds:follow				empty response with 200
DELETE		/feeds/:feed_id/followers	unfollow a feed							auth, feeds:follow				empty response with 200
GET			/feeds/:feed_id/items		get feeds for a wall

POST		/walls						create wall
GET			/walls/:wall_id				get a specific wall
PUT			/walls/:wall_id				update a wall's details
POST		/walls/:wall_id/feeds		add feeds to a wall
GET			/walls/:wall_id/feeds		get feeds for a wall
GET			/walls/:wall_id/items		get items for a wall

GET			/items						list all items (from primary wall)
GET			/items/:item_id				get a specific item

*/

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	router.Handler(http.MethodGet, "/debug/vars", expvar.Handler())
	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheck)

	router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/activate", app.activateUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/password", app.updateUserPassword)
	router.HandlerFunc(http.MethodHead, "/v1/users/:username", app.checkUsername)

	router.HandlerFunc(http.MethodPost, "/v1/tokens/authentication", app.createAuthenticationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/activation", app.createActivationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/password-reset", app.createPasswordResetToken)

	router.HandlerFunc(http.MethodGet, "/v1/feeds", app.listFeeds)
	router.HandlerFunc(http.MethodGet, "/v1/feeds/:feed_id", app.getFeed)

	authenticated := alice.New(app.requireAuthentication)

	router.Handler(http.MethodDelete, "/v1/tokens/authentication", authenticated.ThenFunc(app.deleteAuthenticationToken))

	router.Handler(http.MethodGet, "/v1/me", authenticated.ThenFunc(app.getCurrentUser))
	router.Handler(http.MethodGet, "/v1/me/feeds", authenticated.ThenFunc(app.listFeedsForUser))
	router.Handler(http.MethodGet, "/v1/me/feeds/contains", authenticated.ThenFunc(app.checkIfUserFollowsFeeds))
	router.Handler(http.MethodGet, "/v1/me/walls", authenticated.ThenFunc(app.listWalls))

	router.Handler(http.MethodGet, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.listFollowersForFeed))
	router.Handler(http.MethodPut, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.requirePermission("feeds:follow", app.followFeed)))
	router.Handler(http.MethodDelete, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.requirePermission("feeds:follow", app.unfollowFeed)))
	router.Handler(http.MethodGet, "/v1/feeds/:feed_id/items", authenticated.ThenFunc(app.listItemsForFeed))

	router.Handler(http.MethodGet, "/v1/walls/:wall_id/items", authenticated.ThenFunc(app.listItemsForWall))

	activated := authenticated.Append(app.requireActivation)

	router.Handler(http.MethodPost, "/v1/walls", activated.ThenFunc(app.createWall))

	router.Handler(http.MethodPost, "/v1/feeds", activated.ThenFunc(app.requirePermission("feeds:write", app.addAndFollowFeed)))

	standard := alice.New(app.metrics, app.recoverPanic, app.rateLimit, app.authenticate)
	return standard.Then(router)
}

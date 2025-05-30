package main

import (
	"expvar"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/public"
	"github.com/julienschmidt/httprouter"
	"github.com/justinas/alice"
)

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)

	staticFileServer := http.FileServer(http.FS(public.Static))

	router.Handler(http.MethodGet, "/static/*filepath", staticFileServer)

	router.Handler(http.MethodGet, "/debug/vars", expvar.Handler())
	router.HandlerFunc(http.MethodGet, "/user-agreement", app.userAgreement)
	router.HandlerFunc(http.MethodGet, "/privacy-policy", app.privacyPolicy)
	router.HandlerFunc(http.MethodGet, "/account-deletion", app.accountDeletion)
	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheck)

	router.HandlerFunc(http.MethodPost, "/v1/users", app.registerUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/activate", app.activateUser)
	router.HandlerFunc(http.MethodPut, "/v1/users/password", app.updateUserPassword)
	router.HandlerFunc(http.MethodHead, "/v1/users/:username", app.checkUsername)

	router.HandlerFunc(http.MethodPost, "/v1/tokens/authentication", app.createAuthenticationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/google", app.createGoogleAuthenticationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/refresh", app.refreshAuthenticationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/activation", app.createActivationToken)
	router.HandlerFunc(http.MethodPost, "/v1/tokens/password-reset", app.createPasswordResetToken)

	router.HandlerFunc(http.MethodGet, "/v1/feeds", app.listFeeds)
	router.HandlerFunc(http.MethodGet, "/v1/feeds/:feed_id", app.getFeed)

	router.HandlerFunc(http.MethodGet, "/v1/topics", app.listTopicsWithCache)

	router.HandlerFunc(http.MethodGet, "/v1/youtube/channel", app.getYouTubeChannelID)

	authenticated := alice.New(app.requireAuthentication)

	router.Handler(http.MethodPut, "/v1/users/username", authenticated.ThenFunc(app.updateUsername))

	router.Handler(http.MethodDelete, "/v1/tokens/authentication", authenticated.ThenFunc(app.deleteAuthenticationToken))

	router.Handler(http.MethodGet, "/v1/me", authenticated.ThenFunc(app.getCurrentUser))
	router.Handler(http.MethodGet, "/v1/me/feeds", authenticated.ThenFunc(app.listFeedsForUser))
	router.Handler(http.MethodGet, "/v1/me/feeds/contains", authenticated.ThenFunc(app.checkIfUserFollowsFeeds))
	router.Handler(http.MethodGet, "/v1/me/items/saved/contains", authenticated.ThenFunc(app.checkIfUserSavedItems))
	router.Handler(http.MethodGet, "/v1/me/items/liked/contains", authenticated.ThenFunc(app.checkIfUserLikedItems))
	router.Handler(http.MethodGet, "/v1/me/walls", authenticated.ThenFunc(app.listWalls))
	router.Handler(http.MethodGet, "/v1/me/items/saved", authenticated.ThenFunc(app.listSavedItemsHandler))
	router.Handler(http.MethodGet, "/v1/me/items/liked", authenticated.ThenFunc(app.listLikedItemsHandler))

	router.Handler(http.MethodGet, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.listFollowersForFeed))
	router.Handler(http.MethodPut, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.requirePermission(data.PermissionFeedsFollow, app.followFeed)))
	router.Handler(http.MethodDelete, "/v1/feeds/:feed_id/followers", authenticated.ThenFunc(app.requirePermission(data.PermissionFeedsFollow, app.unfollowFeed)))
	router.Handler(http.MethodGet, "/v1/feeds/:feed_id/items", authenticated.ThenFunc(app.listItemsForFeed))

	router.Handler(http.MethodPut, "/v1/walls/:wall_id/feeds/:feed_id", authenticated.ThenFunc(app.addFeedToWall))
	router.Handler(http.MethodDelete, "/v1/walls/:wall_id/feeds/:feed_id", authenticated.ThenFunc(app.removeFeedFromWall))
	router.Handler(http.MethodGet, "/v1/walls/:wall_id/feeds", authenticated.ThenFunc(app.listFeedsForWall))
	router.Handler(http.MethodGet, "/v1/walls/:wall_id/items", authenticated.ThenFunc(app.listItemsForWall))

	router.Handler(http.MethodPut, "/v1/items/:id/save", authenticated.ThenFunc(app.saveItemHandler))
	router.Handler(http.MethodPut, "/v1/items/:id/unsave", authenticated.ThenFunc(app.unsaveItemHandler))
	router.Handler(http.MethodPut, "/v1/items/:id/like", authenticated.ThenFunc(app.likeItemHandler))
	router.Handler(http.MethodPut, "/v1/items/:id/unlike", authenticated.ThenFunc(app.unlikeItemHandler))
	router.Handler(http.MethodGet, "/v1/items/:id/like_count", authenticated.ThenFunc(app.getLikeCountHandler))

	activated := authenticated.Append(app.requireActivation)

	router.Handler(http.MethodPost, "/v1/walls", activated.ThenFunc(app.createWall))
	router.Handler(http.MethodPut, "/v1/walls/:wall_id", activated.ThenFunc(app.updateWall))
	router.Handler(http.MethodDelete, "/v1/walls/:wall_id", activated.ThenFunc(app.deleteWall))
	router.Handler(http.MethodPut, "/v1/walls/:wall_id/pin", activated.ThenFunc(app.pinWall))
	router.Handler(http.MethodPut, "/v1/walls/:wall_id/unpin", activated.ThenFunc(app.unpinWall))

	router.Handler(http.MethodPost, "/v1/feeds", activated.ThenFunc(app.requirePermission(data.PermissionFeedsWrite, app.addAndFollowFeed)))

	standard := alice.New(app.metrics, app.recoverPanic, app.enableCORS, app.rateLimit, app.authenticate)
	return standard.Then(router)
}

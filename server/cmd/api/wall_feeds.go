package main

import (
	"errors"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
)

func (app *application) addFeedToWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	walls, err := app.models.Walls.FindAllForUser(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	containsWall := false
	for _, w := range walls {
		if w.ID == wallID {
			containsWall = true
		}
	}

	if !containsWall {
		app.notPermittedResponse(w, r)
		return
	}

	feedID, err := app.readIDParam(r, "feed_id")
	if err != nil || feedID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	feed, err := app.models.Feeds.FindByID(feedID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
			return
		default:
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	wallFeed := data.WallFeed{
		WallID: wallID,
		FeedID: feed.ID,
	}
	err = app.models.WallFeeds.Insert(&wallFeed)
	if err != nil && !errors.Is(err, data.ErrDuplicateWallFeed) {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (app *application) removeFeedFromWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	feedID, err := app.readIDParam(r, "feed_id")
	if err != nil || feedID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	walls, err := app.models.Walls.FindAllForUser(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	containsWall := false
	for _, w := range walls {
		if w.ID == wallID {
			containsWall = true
		}
	}

	if !containsWall {
		app.notPermittedResponse(w, r)
		return
	}

	wallFeed := data.WallFeed{
		FeedID: feedID,
		WallID: wallID,
	}
	err = app.models.WallFeeds.Delete(&wallFeed)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
			return
		default:
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	w.WriteHeader(http.StatusOK)
}

func (app *application) listFeedsForWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	wall, err := app.models.Walls.FindByID(wallID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
			return
		default:
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	user := app.contextGetSession(r).User
	if wall.UserID != user.ID {
		app.notPermittedResponse(w, r)
		return
	}

	feeds, err := app.models.WallFeeds.FindFeedsForWall(wallID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"feeds": feeds}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

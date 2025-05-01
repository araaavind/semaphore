package main

import (
	"errors"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
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

	var input struct {
		Title string
		data.Filters
	}

	v := validator.New()

	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.Sort = app.readString(qs, "sort", "pub_date")
	input.SortSafeList = []string{"id", "title", "pub_date", "pub_updated", "-id", "-title", "-pub_date", "-pub_updated"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
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

	feeds, metadata, err := app.models.WallFeeds.FindFeedsForWall(wallID, input.Title, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"feeds": feeds, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

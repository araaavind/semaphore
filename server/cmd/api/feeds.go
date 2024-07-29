package main

import (
	"errors"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) getFeed(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r, "feed_id")
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	feed, err := app.models.Feeds.FindByID(id)
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

	err = app.writeJSON(w, http.StatusOK, envelope{"feed": feed}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) listFeeds(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title    string
		FeedLink string
		data.Filters
	}

	v := validator.New()

	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.FeedLink = app.readString(qs, "feed_link", "")
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.Sort = app.readString(qs, "sort", "pub_date")
	input.SortSafeList = []string{"id", "title", "pub_date", "pub_updated", "-id", "-title", "-pub_date", "-pub_updated"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	feeds, metadata, err := app.models.Feeds.FindAll(input.Title, input.FeedLink, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	feedIDs := []int64{}
	for _, f := range feeds {
		feedIDs = append(feedIDs, f.ID)
	}

	followCountMap, err := app.models.FeedFollows.CountFollowersForFeeds(feedIDs)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	type feedResponse struct {
		FollowersCount int `json:"followers_count"`
		*data.Feed
	}

	result := []*feedResponse{}
	for _, feed := range feeds {
		result = append(result, &feedResponse{
			FollowersCount: followCountMap[feed.ID],
			Feed:           feed,
		})
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"feeds": result, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

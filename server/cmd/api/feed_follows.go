package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) listFollowersForFeed(w http.ResponseWriter, r *http.Request) {
	var input struct {
		data.Filters
	}

	feedID, err := app.readIDParam(r, "feed_id")
	if err != nil || feedID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	v := validator.New()

	qs := r.URL.Query()
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.Sort = app.readString(qs, "sort", "full_name")
	input.SortSafeList = []string{"id", "full_name", "username", "-id", "-full_name", "-username"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	users, metadata, err := app.models.FeedFollows.GetFollowersForFeed(feedID, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"users": users, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) listFeedsForUser(w http.ResponseWriter, r *http.Request) {
	var input struct {
		data.Filters
	}

	v := validator.New()
	qs := r.URL.Query()
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.Sort = app.readString(qs, "sort", "title")
	input.SortSafeList = []string{"id", "title", "pub_date", "pub_updated", "-id", "-title", "-pub_date", "-pub_updated"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	user := app.contextGetSession(r).User

	feeds, metadata, err := app.models.FeedFollows.GetFeedsForUser(user.ID, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"feeds": feeds, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) checkIfUserFollowsFeeds(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()

	feedIDs := app.readInt64List(qs, "ids", []int64{}, v)
	if len(feedIDs) > 100 {
		v.AddError("ids", "IDs should be a maximum of 100")
	}

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	user := app.contextGetSession(r).User

	result, err := app.models.FeedFollows.CheckIfUserFollowsFeeds(user.ID, []int64(feedIDs))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	followsList := make([]bool, len(feedIDs))
	for i, feedID := range feedIDs {
		if isFollowed, exists := result[feedID]; exists {
			followsList[i] = isFollowed
		} else {
			followsList[i] = false
		}
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"follows": followsList}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) addAndFollowFeed(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetSession(r).User

	var input struct {
		FeedLink string `json:"feed_link"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	if data.ValidateFeedLink(v, input.FeedLink); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*30)
	defer cancel()

	parsedFeed, err := app.parser.ParseURLWithContext(input.FeedLink, ctx)
	if err != nil {
		v.AddError("feed_link", "This URL does not point to a valid feed")
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	linksToSearch := []string{input.FeedLink}
	if parsedFeed.FeedLink != "" {
		linksToSearch = append(linksToSearch, parsedFeed.FeedLink)
	}
	// Check if the link provided by the user OR the 'self' link of parsedFeed exists in the DB.
	feedToFolow, err := app.models.Feeds.FindByFeedLinks(linksToSearch)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			// If the link provided by user or the 'self' link of parsed Feed is not present in DB,
			// check if the 'self' link of the parsed feed is same as the link provided by the user.
			feedToFolow = &data.Feed{
				AddedBy: user.ID,
			}
			if parsedFeed.FeedLink == input.FeedLink {
				//If they are same, insert the parsed feed into DB.
				CopyFeedFields(feedToFolow, parsedFeed, input.FeedLink)
			} else {
				ctx, cancel := context.WithTimeout(context.Background(), time.Second*30)
				defer cancel()
				// if they are different, parse the 'self' link of parsed Feed and check if it is valid and latest.
				parsedSelfFeed, err := app.parser.ParseURLWithContext(parsedFeed.FeedLink, ctx)
				if err != nil {
					// if the 'self' link of parsed feed is invalid, insert the parsed feed of input link to DB
					CopyFeedFields(feedToFolow, parsedFeed, input.FeedLink)
				} else {
					if parsedSelfFeed.UpdatedParsed != nil &&
						parsedFeed.UpdatedParsed != nil &&
						parsedSelfFeed.UpdatedParsed.Before(*parsedFeed.UpdatedParsed) {
						// if the 'self' link of parsed feed is valid but not latest, insert the parsed feed of input link to DB
						CopyFeedFields(feedToFolow, parsedFeed, input.FeedLink)
					} else {
						// if the 'self' link of parsed feed is valid and latest, insert the parsed feed of 'self' link to DB
						CopyFeedFields(feedToFolow, parsedSelfFeed, parsedSelfFeed.FeedLink)
					}
				}
			}
			err = app.models.Feeds.Insert(feedToFolow)
			if err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}
		} else {
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	feedFollow := &data.FeedFollow{
		FeedID: feedToFolow.ID,
		UserID: user.ID,
	}
	err = app.models.FeedFollows.Insert(feedFollow)
	if err != nil {
		if errors.Is(err, data.ErrDuplicateFeedFollow) {
			v.AddError("feed_link", "You are already following this feed")
			app.failedValidationResponse(w, r, v.Errors)
			return
		} else {
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	wall, err := app.models.Walls.FindPrimaryWallForUser(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	wallFeed := &data.WallFeed{
		FeedID: feedFollow.FeedID,
		WallID: wall.ID,
	}
	err = app.models.WallFeeds.Insert(wallFeed)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	app.background(func() {
		app.RefreshFeed(feedToFolow)
	})

	w.Header().Set("Location", fmt.Sprintf("/v1/feeds/%d", feedFollow.FeedID))
	w.WriteHeader(http.StatusCreated)
}

func (app *application) followFeed(w http.ResponseWriter, r *http.Request) {
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

	user := app.contextGetSession(r).User

	feedFollow := data.FeedFollow{
		FeedID: feed.ID,
		UserID: user.ID,
	}
	err = app.models.FeedFollows.Insert(&feedFollow)
	if err != nil && !errors.Is(err, data.ErrDuplicateFeedFollow) {
		app.serverErrorResponse(w, r, err)
		return
	}

	wall, err := app.models.Walls.FindPrimaryWallForUser(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	wallFeed := &data.WallFeed{
		FeedID: feedFollow.FeedID,
		WallID: wall.ID,
	}
	err = app.models.WallFeeds.Insert(wallFeed)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (app *application) unfollowFeed(w http.ResponseWriter, r *http.Request) {
	feedID, err := app.readIDParam(r, "feed_id")
	if err != nil || feedID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	feedFolow := data.FeedFollow{
		FeedID: feedID,
		UserID: user.ID,
	}
	err = app.models.FeedFollows.Delete(feedFolow)
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

	walls, err := app.models.Walls.FindAllForUser(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	var wallIDs []int64
	for _, wall := range walls {
		wallIDs = append(wallIDs, wall.ID)
	}

	err = app.models.WallFeeds.DeleteFeedForWalls(feedID, wallIDs)
	if err != nil && !errors.Is(err, data.ErrRecordNotFound) {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusOK)
}

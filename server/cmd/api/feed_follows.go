package main

import (
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
	"github.com/mmcdole/gofeed"
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

	user := app.contextGetUser(r)

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

func (app *application) addAndFollowFeed(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

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

	parsedFeed, err := app.parser.ParseURL(input.FeedLink)
	if err != nil {
		v.AddError("feed_link", err.Error())
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
				copyFeedFields(feedToFolow, parsedFeed, input.FeedLink)
			} else {
				// if they are different, parse the 'self' link of parsed Feed and check if it is valid and latest.
				parsedSelfFeed, err := app.parser.ParseURL(parsedFeed.FeedLink)
				if err != nil {
					// if the 'self' link of parsed feed is invalid, insert the parsed feed of input link to DB
					copyFeedFields(feedToFolow, parsedFeed, input.FeedLink)
				} else {
					if parsedSelfFeed.UpdatedParsed != nil &&
						parsedFeed.UpdatedParsed != nil &&
						parsedSelfFeed.UpdatedParsed.Before(*parsedFeed.UpdatedParsed) {
						// if the 'self' link of parsed feed is valid but not latest, insert the parsed feed of input link to DB
						copyFeedFields(feedToFolow, parsedFeed, input.FeedLink)
					} else {
						// if the 'self' link of parsed feed is valid and latest, insert the parsed feed of 'self' link to DB
						copyFeedFields(feedToFolow, parsedSelfFeed, parsedSelfFeed.FeedLink)
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
			v.AddError("feed_url", "user already follows the feed")
			app.failedValidationResponse(w, r, v.Errors)
			return
		} else {
			app.serverErrorResponse(w, r, err)
			return
		}
	}

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

	user := app.contextGetUser(r)

	feedFollow := data.FeedFollow{
		FeedID: feed.ID,
		UserID: user.ID,
	}
	err = app.models.FeedFollows.Upsert(feedFollow)
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

	user := app.contextGetUser(r)

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

	w.WriteHeader(http.StatusOK)
}

func copyFeedFields(feed *data.Feed, parsedFeed *gofeed.Feed, feedLink string) {
	feed.Title = parsedFeed.Title
	feed.Description = parsedFeed.Description
	feed.Link = parsedFeed.Link
	feed.FeedLink = feedLink

	if parsedFeed.PublishedParsed != nil {
		feed.PubDate = *parsedFeed.PublishedParsed
	} else {
		feed.PubDate = time.Now()
	}
	if parsedFeed.UpdatedParsed != nil {
		feed.PubUpdated = *parsedFeed.UpdatedParsed
	} else {
		feed.PubUpdated = time.Now()
	}
	if parsedFeed.FeedType != "" {
		feed.FeedType = strings.ToLower(parsedFeed.FeedType)
	} else {
		feed.FeedType = "rss"
	}
	if parsedFeed.FeedVersion != "" {
		feed.FeedVersion = parsedFeed.FeedVersion
	} else {
		feed.FeedVersion = "2.0"
	}
	if parsedFeed.Language != "" {
		feed.Language = strings.ToLower(parsedFeed.Language)
	} else {
		feed.Language = "en-us"
	}
}

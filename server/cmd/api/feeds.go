package main

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) addFeedHandler(w http.ResponseWriter, r *http.Request) {
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

	if len(parsedFeed.FeedLink) > 0 && parsedFeed.FeedLink != input.FeedLink {
		_, err := app.parser.ParseURL(parsedFeed.FeedLink)
		if err != nil {
			input.FeedLink = parsedFeed.FeedLink
		}
	}

	feed, err := app.models.Feeds.FindByFeedLink(input.FeedLink)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			feed = &data.Feed{
				Title:       parsedFeed.Title,
				Description: parsedFeed.Description,
				Link:        parsedFeed.Link,
				FeedLink:    input.FeedLink,
				FeedType:    parsedFeed.FeedType,
				FeedVersion: parsedFeed.FeedVersion,
				Language:    parsedFeed.Language,
			}

			if parsedFeed.PublishedParsed != nil {
				feed.PubDate = *parsedFeed.PublishedParsed
			}

			if parsedFeed.UpdatedParsed != nil {
				feed.PubUpdated = *parsedFeed.UpdatedParsed
			}

			err = app.models.Feeds.Insert(feed)
			if err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}
		} else {
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	headers := make(http.Header)
	headers.Set("Location", fmt.Sprintf("/v1/feeds/%d", feed.ID))

	err = app.writeJSON(w, http.StatusCreated, envelope{"feed": feed}, headers)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) getFeedHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
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

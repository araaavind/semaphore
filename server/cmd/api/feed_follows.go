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

func (app *application) followFeedHandler(w http.ResponseWriter, r *http.Request) {
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
	feedToSubscribeTo, err := app.models.Feeds.FindByFeedLinks(linksToSearch)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			// If the link provided by user or the 'self' link of parsed Feed is not present in DB,
			// check if the 'self' link of the parsed feed is same as the link provided by the user.
			feedToSubscribeTo = &data.Feed{}
			if parsedFeed.FeedLink == input.FeedLink {
				//If they are same, insert the parsed feed into DB.
				copyFeedFields(feedToSubscribeTo, parsedFeed, input.FeedLink)
			} else {
				// if they are different, parse the 'self' link of parsed Feed and check if it is valid and latest.
				parsedSelfFeed, err := app.parser.ParseURL(parsedFeed.FeedLink)
				if err != nil {
					// if the 'self' link of parsed feed is invalid, insert the parsed feed of input link to DB
					copyFeedFields(feedToSubscribeTo, parsedFeed, input.FeedLink)
				} else {
					if parsedSelfFeed.UpdatedParsed != nil &&
						parsedFeed.UpdatedParsed != nil &&
						parsedSelfFeed.UpdatedParsed.Before(*parsedFeed.UpdatedParsed) {
						// if the 'self' link of parsed feed is valid but not latest, insert the parsed feed of input link to DB
						copyFeedFields(feedToSubscribeTo, parsedFeed, input.FeedLink)
					} else {
						// if the 'self' link of parsed feed is valid and latest, insert the parsed feed of 'self' link to DB
						copyFeedFields(feedToSubscribeTo, parsedSelfFeed, parsedSelfFeed.FeedLink)
					}
				}
			}
			err = app.models.Feeds.Insert(feedToSubscribeTo)
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
		FeedID: feedToSubscribeTo.ID,
		UserID: 1,
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

	headers := make(http.Header)
	headers.Set("Location", fmt.Sprintf("/v1/feeds/%d", feedFollow.FeedID))

	err = app.writeJSON(w, http.StatusCreated, envelope{"feed_id": feedFollow.FeedID, "user_id": feedFollow.UserID}, headers)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
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

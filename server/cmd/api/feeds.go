package main

import (
	"errors"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/mmcdole/gofeed"
)

var feedUpdateMutex sync.Mutex

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
		TopicID  int64
		FeedType string
		data.Filters
	}

	v := validator.New()

	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.FeedLink = app.readString(qs, "feed_link", "")
	input.TopicID = int64(app.readInt(qs, "topic_id", -1, v))
	input.FeedType = app.readString(qs, "feed_type", "")
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.Sort = app.readString(qs, "sort", "pub_date")
	input.SortSafeList = []string{"id", "title", "pub_date", "pub_updated", "-id", "-title", "-pub_date", "-pub_updated"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	user := app.contextGetSession(r).User
	addedBy := pgtype.Int8{}
	if !user.IsAnonymous() {
		addedBy.Int64 = user.ID
		addedBy.Valid = true
	}

	if input.FeedType != "" {
		data.ValidateFeedType(v, input.FeedType)
		if !v.Valid() {
			app.failedValidationResponse(w, r, v.Errors)
			return
		}
	}

	feeds, metadata, err := app.models.Feeds.FindAll(input.Title, input.FeedLink, input.TopicID, input.FeedType, addedBy, input.Filters)
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

func copyFeedFields(feed *data.Feed, parsedFeed *gofeed.Feed, feedLink string) {
	feed.Title = parsedFeed.Title
	feed.Description = parsedFeed.Description
	feed.Link = parsedFeed.Link
	feed.FeedLink = feedLink

	if parsedFeed.Image != nil && parsedFeed.Image.URL != "" {
		feed.ImageURL = pgtype.Text{
			String: parsedFeed.Image.URL,
			Valid:  true,
		}
	}

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
		feed.FeedFormat = strings.ToLower(parsedFeed.FeedType)
	} else {
		feed.FeedFormat = "rss"
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
	feed.LastFetchAt.Time = time.Now()
	feed.LastFetchAt.Valid = true
}

func (app *application) listItemsForFeed(w http.ResponseWriter, r *http.Request) {
	feedID, err := app.readIDParam(r, "feed_id")
	if err != nil || feedID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	var input struct {
		Title string
		data.CursorFilters
	}

	v := validator.New()
	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.After = app.readString(qs, "after", "")
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.SortMode = data.SortMode(app.readString(qs, "sort_mode", string(data.SortModeNew)))
	input.SortSafeList = []data.SortMode{data.SortModeNew}

	data.ValidateCursorFilters(v, input.CursorFilters)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	feed, err := app.models.Feeds.FindByID(feedID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	user := app.contextGetSession(r).User

	items, metadata, err := app.models.Items.FindAllForFeedsByNew([]int64{feed.ID}, user.ID, input.Title, input.CursorFilters)
	if err != nil {
		if errors.Is(err, data.ErrInvalidCursor) {
			v.AddError("after", "invalid cursor")
			app.failedValidationResponse(w, r, v.Errors)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"items": items, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) UpdateFollowersCount() {
	for {
		select {
		case <-app.ctx.Done():
			return
		default:
			timer := time.NewTimer(24 * time.Hour)
			select {
			case <-app.ctx.Done():
				timer.Stop()
				return
			case <-timer.C:
				feedUpdateMutex.Lock()
				err := app.models.Feeds.UpdateFollowersCount()
				feedUpdateMutex.Unlock()
				if err != nil {
					app.logInternalError("app.models.Feeds.UpdateFollowersCount failed", err)
				}
			}
		}
	}
}

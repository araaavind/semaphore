package main

import (
	"context"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
)

func (app *application) RefreshFeed(feed *data.Feed) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
	defer cancel()

	parsedFeed, err := app.parser.ParseURLWithContext(feed.FeedLink, ctx)
	if err != nil {
		app.logInternalError("ParseURLWithContext failed", err)
		feed.LastFailure.String = err.Error()
		feed.LastFailure.Valid = true
		feed.LastFailureAt.Time = time.Now()
		feed.LastFetchAt.Valid = true
		app.models.Feeds.Update(feed)
		return
	}

	items := CopyItemsFields(parsedFeed, feed.ID)
	err = app.models.Items.UpsertMany(items)
	if err != nil {
		app.logInternalError("app.models.Items.UpsertMany failed", err)
		return
	}

	CopyFeedFields(feed, parsedFeed, feed.FeedLink)
	err = app.models.Feeds.Update(feed)
	if err != nil {
		app.logInternalError("app.models.Feeds.Update() failed", err)
	}
}

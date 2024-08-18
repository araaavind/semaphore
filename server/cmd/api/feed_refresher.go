package main

import (
	"context"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
)

func (app *application) KeepFeedsFresh(maxConcurrentRefreshes int, refreshStaleFeedsSince, refreshPeriod time.Duration) {
	for {
		startTime := time.Now()
		staleFeeds, err := app.models.Feeds.GetUncheckedFeedsSince(startTime.Add(-1 * refreshStaleFeedsSince))
		if err != nil {
			app.logInternalError("app.models.Feeds.GetUncheckedFeedsSince failed", err)
			return
		}

		staleFeedsChan := make(chan *data.Feed)
		finishChan := make(chan bool)

		refreshWorker := func() {
			for feed := range staleFeedsChan {
				app.RefreshFeed(feed)
			}
			finishChan <- true
		}

		for i := 0; i < maxConcurrentRefreshes; i++ {
			app.background(refreshWorker)
		}

		for _, feed := range staleFeeds {
			staleFeedsChan <- feed
		}
		close(staleFeedsChan)

		for i := 0; i < maxConcurrentRefreshes; i++ {
			<-finishChan
		}

		// sleeps until startTime + 1 min. Returns immediately if startTime + 1 min is in the past
		time.Sleep(time.Until(startTime.Add(refreshPeriod)))
	}
}

func (app *application) RefreshFeed(feed *data.Feed) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
	defer cancel()

	parsedFeed, err := app.parser.ParseURLWithContext(feed.FeedLink, ctx)
	if err != nil {
		app.logInternalError("ParseURLWithContext failed", err)
		feed.LastFailure.String = err.Error()
		feed.LastFailure.Valid = true
		feed.LastFailureAt.Time = time.Now()
		feed.LastFailureAt.Valid = true
		err = app.models.Feeds.Update(feed)
		if err != nil {
			app.logInternalError("app.models.Feeds.Update failed while updating failed feed status", err)
		}
		return
	}

	items := CopyItemsFields(parsedFeed, feed.ID)
	err = app.models.Items.UpsertMany(items)
	if err != nil {
		app.logInternalError("app.models.Items.UpsertMany failed", err)
		feed.LastFailure.String = err.Error()
		feed.LastFailure.Valid = true
		feed.LastFailureAt.Time = time.Now()
		feed.LastFailureAt.Valid = true
		err = app.models.Feeds.Update(feed)
		if err != nil {
			app.logInternalError("app.models.Feeds.Update failed while updating failed feed status", err)
		}
		return
	}

	CopyFeedFields(feed, parsedFeed, feed.FeedLink)
	err = app.models.Feeds.Update(feed)
	if err != nil {
		app.logInternalError("app.models.Feeds.Update() failed", err)
	}
}

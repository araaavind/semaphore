package main

import (
	"context"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
)

func (app *application) KeepFeedsFresh() {
	for {
		select {
		case <-app.ctx.Done():
			return
		default:
			timer := time.NewTimer(app.config.refresher.refreshPeriod)

			select {
			case <-app.ctx.Done():
				timer.Stop()
				return
			case <-timer.C:
				// Lock or wait for the lock to be available if it's locked by feed followers count updater
				feedUpdateMutex.Lock()

				staleFeeds, err := app.models.Feeds.GetUncheckedFeedsSince(time.Now().Add(-1 * app.config.refresher.refreshStaleFeedsSince))
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

				for range app.config.refresher.maxConcurrentRefreshes {
					app.background(refreshWorker)
				}

				for _, feed := range staleFeeds {
					staleFeedsChan <- feed
				}
				close(staleFeedsChan)

				for range app.config.refresher.maxConcurrentRefreshes {
					<-finishChan
				}

				feedUpdateMutex.Unlock()
			}
		}
	}
}

func (app *application) RefreshFeed(feed *data.Feed) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*15)
	defer cancel()

	parsedFeed, err := app.parser.ParseURLWithContext(feed.FeedLink, ctx)
	if err != nil {
		app.logInternalError("ParseURLWithContext failed for feed: "+feed.FeedLink, err)
		feed.LastFailure.String = err.Error()
		feed.LastFailure.Valid = true
		feed.LastFailureAt.Time = time.Now()
		feed.LastFailureAt.Valid = true
		err = app.models.Feeds.UpdateFailureStatus(feed)
		if err != nil {
			app.logInternalError("app.models.Feeds.Update failed while updating failed feed status", err)
		}
		return
	}

	items := copyItemsFields(parsedFeed, feed.ID)
	err = app.models.Items.UpsertMany(items)
	if err != nil {
		app.logInternalError("app.models.Items.UpsertMany failed", err)
		feed.LastFailure.String = err.Error()
		feed.LastFailure.Valid = true
		feed.LastFailureAt.Time = time.Now()
		feed.LastFailureAt.Valid = true
		err = app.models.Feeds.UpdateFailureStatus(feed)
		if err != nil {
			app.logInternalError("app.models.Feeds.UpdateFailureStatus failed while updating failed feed status", err)
		}
		return
	}

	copyFeedFields(feed, parsedFeed, feed.FeedLink)
	err = app.models.Feeds.Update(feed)
	if err != nil {
		app.logInternalError("app.models.Feeds.Update() failed", err)
	}
}

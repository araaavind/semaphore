package main

import (
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/mmcdole/gofeed"
)

func copyItemsFields(parsedFeed *gofeed.Feed, feedID int64) (items []*data.Item) {
	for _, parsedItem := range parsedFeed.Items {
		item := &data.Item{}
		item.Title = parsedItem.Title
		item.Description = parsedItem.Description
		if parsedItem.Content != "" {
			item.Content = pgtype.Text{
				String: parsedItem.Content,
				Valid:  true,
			}
		}
		if parsedItem.Link != "" {
			item.Link = parsedItem.Link
		} else {
			if parsedItem.GUID != "" && parsedFeed.FeedType == "rss" {
				item.Link = parsedItem.GUID
			} else if len(parsedItem.Links) != 0 {
				item.Link = parsedItem.Links[0]
			} else {
				// skip adding the item
				continue
			}
		}
		if parsedItem.PublishedParsed != nil {
			item.PubDate = pgtype.Timestamptz{
				Time:  *parsedItem.PublishedParsed,
				Valid: true,
			}
		}
		if parsedItem.UpdatedParsed != nil {
			item.PubUpdated = pgtype.Timestamptz{
				Time:  *parsedItem.UpdatedParsed,
				Valid: true,
			}
		}
		if parsedItem.Authors != nil {
			var authors pgtype.FlatArray[*data.Person]
			for _, a := range parsedItem.Authors {
				authors = append(authors, &data.Person{
					Name:  a.Name,
					Email: a.Email,
				})
			}
			item.Authors = authors
		}
		if parsedItem.GUID != "" {
			item.GUID = parsedItem.GUID
		} else {
			if parsedItem.Link != "" {
				item.GUID = parsedItem.Link
			} else {
				// skip adding the item
				continue
			}
		}
		if parsedItem.Image != nil && parsedItem.Image.URL != "" {
			item.ImageURL = pgtype.Text{
				String: parsedItem.Image.URL,
				Valid:  item.ImageURL.Valid,
			}
		}
		if parsedItem.Categories != nil {
			item.Categories = pgtype.FlatArray[string](parsedItem.Categories)
		}
		if parsedItem.Enclosures != nil {
			var enclosures pgtype.FlatArray[*data.Enclosure]
			for _, e := range parsedItem.Enclosures {
				enclosures = append(enclosures, &data.Enclosure{
					URL:    e.URL,
					Length: e.Length,
					Type:   e.Type,
				})
			}
			item.Enclosures = enclosures
		}
		item.FeedID = feedID
		items = append(items, item)
	}
	return items
}

func (app *application) CleanupOldUnsavedItems() {
	for {
		select {
		case <-app.ctx.Done():
			app.logger.Info("items cleanup shutting down gracefully")
			return
		default:
			startTime := time.Now()
			err := app.models.Items.CleanupItems(startTime.Add(-1 * app.config.cleanup.itemsCleanupBeforeDuration))
			if err != nil {
				app.logInternalError("app.models.Items.CleanupItems failed", err)
			}
			timer := time.NewTimer(time.Until(startTime.Add(app.config.cleanup.itemsCleanupPeriod)))
			select {
			case <-app.ctx.Done():
				timer.Stop()
				return
			case <-timer.C:
				// Continue with the next iteration
			}
		}
	}
}

package main

import (
	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/mmcdole/gofeed"
)

func CopyItemsFields(parsedFeed *gofeed.Feed, feedID int64) (items []*data.Item) {
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
		if len(parsedItem.Categories) != 0 {
			item.Categories = pgtype.Array[string]{}
			item.Categories.Elements = append(item.Categories.Elements, parsedItem.Categories...)
			item.Categories.Valid = true
		}
		item.FeedID = feedID
		items = append(items, item)
	}
	return items
}

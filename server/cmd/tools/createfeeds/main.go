package main

import (
	"bytes"
	"context"
	_ "embed"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/mmcdole/gofeed"
	"github.com/mmcdole/gofeed/atom"
	"github.com/mmcdole/gofeed/json"
	"github.com/mmcdole/gofeed/rss"
	"github.com/xuri/excelize/v2"
)

//go:embed feeds.xlsx
var feedsExcel []byte

type feedRow struct {
	displayTitle string
	topicCode    string
	feedLink     string
	websiteLink  string
	sourceType   string
	ownerType    string
}

var models data.Models

func main() {
	var (
		dsn         = flag.String("dsn", os.Getenv("SEMAPHORE_DB_DSN"), "PostgreSQL connection string")
		concurrency = flag.Int("concurrency", 10, "Number of concurrent feed fetches")
		userAgent   = flag.String("user-agent", "SMPHR Feed Fetcher/1.0", "User agent for feed fetching")
	)

	flag.Parse()

	db, err := openDB(*dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	models = data.NewModels(db)

	f, err := excelize.OpenReader(bytes.NewReader(feedsExcel))
	if err != nil {
		log.Fatal(err)
	}

	rows, err := f.GetRows("Feeds")
	if err != nil {
		log.Fatal(err)
	}

	feedRows := make([]feedRow, 0, len(rows)-1)
	headers := rows[0]
	for _, row := range rows[1:] {
		feedRow := feedRow{}
		for i, cell := range row {
			switch headers[i] {
			case "display_title":
				feedRow.displayTitle = cell
			case "topic_code":
				feedRow.topicCode = cell
			case "feed_url":
				feedRow.feedLink = cell
			case "website_url":
				feedRow.websiteLink = cell
			case "source_type":
				feedRow.sourceType = cell
			case "owner_type":
				feedRow.ownerType = cell
			}
		}
		feedRows = append(feedRows, feedRow)
	}

	fmt.Println("Completed parsing excel")
	fmt.Println("Processing started...")

	// Map to store topics by code for quick lookup
	topics, err := getTopicsMap(context.Background())
	if err != nil {
		log.Fatal("Failed to get topics:", err)
	}

	// Channel for processing feeds with a controlled number of workers
	feedChan := make(chan feedRow)
	var wg sync.WaitGroup

	// Track statistics
	var (
		successCount int
		failureCount int
		mutex        sync.Mutex
	)

	for i := range *concurrency {
		fmt.Printf("Starting worker #%d\n", i+1)
		wg.Add(1)
		go func() {
			defer func() {
				fmt.Printf("Worker #%d done\n", i+1)
				wg.Done()
			}()

			parser := gofeed.NewParser()
			parser.UserAgent = *userAgent

			for fr := range feedChan {
				err := processFeed(parser, fr, topics)

				mutex.Lock()
				if err != nil {
					fmt.Printf("Error processing %s: %v\n", fr.feedLink, err)
					failureCount++
				} else {
					fmt.Printf("Successfully added feed: %s\n", fr.feedLink)
					successCount++
				}
				mutex.Unlock()
			}
		}()
	}

	// Send feeds to workers
	for _, fr := range feedRows {
		feedChan <- fr
	}
	close(feedChan)

	// Wait for all workers to finish
	wg.Wait()

	fmt.Printf("Processing complete. Success: %d, Failures: %d\n", successCount, failureCount)
	fmt.Println("Done")
}

func getTopicsMap(ctx context.Context) (map[string]data.Topic, error) {
	topics, err := models.Topics.GetTopics(ctx)
	if err != nil {
		return nil, err
	}

	topicsByCode := make(map[string]data.Topic)
	for _, t := range topics {
		topicsByCode[t.Code] = t
	}

	return topicsByCode, nil
}

func processFeed(parser *gofeed.Parser, fr feedRow, topics map[string]data.Topic) error {
	var topicID pgtype.Int8
	if topic, ok := topics[fr.topicCode]; ok {
		topicID = pgtype.Int8{Int64: topic.ID, Valid: true}
	}

	existingFeed, err := models.Feeds.FindByFeedLinks([]string{fr.feedLink})
	if err == nil {
		// Feed already exists. Update it.
		existingFeed.DisplayTitle = pgtype.Text{String: fr.displayTitle, Valid: fr.displayTitle != ""}
		existingFeed.FeedType = fr.sourceType
		existingFeed.OwnerType = fr.ownerType
		existingFeed.TopicID = topicID
		existingFeed.Link = fr.websiteLink

		err = models.Feeds.Update(existingFeed)
		if err != nil {
			return fmt.Errorf("failed to update feed: %w", err)
		}

		return nil
	} else if !errors.Is(err, data.ErrRecordNotFound) {
		return fmt.Errorf("failed to look for existing feed: %w", err)
	}

	// Feed doesn't exist. Parse and create it.

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	parsedFeed, err := parser.ParseURLWithContext(fr.feedLink, ctx)
	if err != nil {
		if errors.Is(err, gofeed.ErrFeedTypeNotDetected) {
			fmt.Printf("Feed type not detected for %s\n", fr.feedLink)
			parsedFeed, err = parseWithSpecificParser(ctx, fr.feedLink)
		}
		return fmt.Errorf("failed to parse feed: %w", err)
	}

	// Check if there's a self link in the parsed feed.
	if parsedFeed.FeedLink != fr.feedLink {
		parsedSelfFeed, err := parser.ParseURLWithContext(parsedFeed.FeedLink, ctx)
		if err != nil {
			// If self link is invalid, ignore and continue with parsedFeed
		} else {
			if parsedSelfFeed.UpdatedParsed != nil &&
				parsedFeed.UpdatedParsed != nil &&
				parsedSelfFeed.UpdatedParsed.Before(*parsedFeed.UpdatedParsed) {
				// if the 'self' link of parsed feed is valid but not latest,
				// continue with parsedFeed
			} else {
				// if the 'self' link of parsed feed is valid and latest,
				// continue with parsedSelfFeed
				parsedFeed = parsedSelfFeed
			}
		}
	}

	// Create the feed object
	feed := &data.Feed{
		DisplayTitle: pgtype.Text{String: fr.displayTitle, Valid: fr.displayTitle != ""},
		Title:        parsedFeed.Title,
		Description:  parsedFeed.Description,
		Link:         fr.websiteLink,
		FeedLink:     fr.feedLink,
		FeedType:     fr.sourceType,
		OwnerType:    fr.ownerType,
		TopicID:      topicID,
		LastFetchAt:  pgtype.Timestamptz{Time: time.Now(), Valid: true},
	}

	if parsedFeed.Image != nil && parsedFeed.Image.URL != "" {
		feed.ImageURL = pgtype.Text{String: parsedFeed.Image.URL, Valid: true}
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

	err = models.Feeds.Insert(feed)
	if err != nil {
		// Even though we check for existing feed, it's still possible that the feed was created using a self link.
		if errors.Is(err, data.ErrDuplicateLink) {
			// Feed already exists. Update it.
			err = models.Feeds.Update(feed)
			if err != nil {
				return fmt.Errorf("failed to update feed: %w", err)
			}
		} else {
			return fmt.Errorf("failed to insert feed: %w", err)
		}
	}

	return nil
}

func parseWithSpecificParser(ctx context.Context, feedLink string) (*gofeed.Feed, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", feedLink, nil)
	if err != nil {
		return nil, err
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	fmt.Println("Attempting to parse with RSS parser...")
	rssParser := rss.Parser{}
	rssFeed, err := rssParser.Parse(bytes.NewReader(body))
	if err == nil {
		rssTranslator := gofeed.DefaultRSSTranslator{}
		return rssTranslator.Translate(rssFeed)
	}
	fmt.Println("Failed to parse with RSS parser: ", err)

	fmt.Println("Attempting to parse with Atom parser...")
	atomParser := atom.Parser{}
	atomFeed, err := atomParser.Parse(bytes.NewReader(body))
	if err == nil {
		atomTranslator := gofeed.DefaultAtomTranslator{}
		return atomTranslator.Translate(atomFeed)
	}
	fmt.Println("Failed to parse with Atom parser: ", err)

	fmt.Println("Attempting to parse with JSON parser...")
	jsonParser := json.Parser{}
	jsonFeed, err := jsonParser.Parse(bytes.NewReader(body))
	if err == nil {
		jsonTranslator := gofeed.DefaultJSONTranslator{}
		return jsonTranslator.Translate(jsonFeed)
	}
	fmt.Println("Failed to parse with JSON parser: ", err)

	return nil, fmt.Errorf("failed to parse feed using specific parsers: %w", err)
}

func openDB(dsn string) (*pgxpool.Pool, error) {
	poolConfig, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	db, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, err
	}

	err = db.Ping(ctx)
	if err != nil {
		db.Close()
		return nil, err
	}

	return db, nil
}

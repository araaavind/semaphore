package main

import (
	"context"
	_ "embed"
	"encoding/json"
	"flag"
	"log"
	"os"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/jackc/pgx/v5/pgxpool"
)

// To update the topics, you can make the necessary changes in the topics.json file
// MAKE SURE TO NEVER MODIFY THE CODE OF THE TOPIC as it can create duplicates

//go:embed topics.json
var topicsJSON []byte

func main() {
	var (
		dsn = flag.String("dsn", os.Getenv("SEMAPHORE_DB_DSN"), "PostgreSQL connection string")
	)

	flag.Parse()

	db, err := openDB(*dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	models := data.NewModels(db)

	var topics []data.Topic
	err = json.Unmarshal(topicsJSON, &topics)
	if err != nil {
		log.Fatal(err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Upsert all topics
	err = models.Topics.Upsert(ctx, topics)
	if err != nil {
		log.Fatal(err)
	}

	topicCodeToID := make(map[string]int64)
	for _, topic := range topics {
		topicCodeToID[topic.Code] = topic.ID
	}

	// Create subtopic mappings
	var subtopicsToUpsert []data.Subtopic
	for _, topic := range topics {
		for _, subTopicCode := range topic.SubTopics {
			childID, ok := topicCodeToID[subTopicCode]
			if !ok {
				log.Fatalf("Error: Subtopic code '%s' (referenced as a subtopic of '%s' - ID: %d) does not exist as a main topic code. Please check topics.json.", subTopicCode, topic.Code, topic.ID)
			}
			subtopicsToUpsert = append(subtopicsToUpsert, data.Subtopic{
				ParentID: topic.ID,
				ChildID:  childID,
			})
		}
	}

	err = models.Topics.ReCreateSubtopics(ctx, subtopicsToUpsert)
	if err != nil {
		log.Fatal(err)
	}
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

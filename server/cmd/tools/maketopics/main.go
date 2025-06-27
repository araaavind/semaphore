package main

import (
	"context"
	_ "embed"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aravindmathradan/semaphore/internal/cache"
	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

// To update the topics, make the necessary changes in the topics.json file
// MAKE SURE TO NEVER MODIFY THE CODE OF THE TOPIC as it can create duplicates

//go:embed topics.json
var topicsJSON []byte

func main() {
	var (
		dsn           = flag.String("dsn", os.Getenv("SEMAPHORE_DB_DSN"), "PostgreSQL connection string")
		redisDsn      = flag.String("redis-dsn", os.Getenv("REDIS_DSN"), "Redis connection string")
		redisDb       = flag.Int("redis-db", 0, "Redis database number")
		redisPoolSize = flag.Int("redis-pool-size", 10, "Redis connection pool size")
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

	// Delete topics not in JSON
	err = deleteOrphanedTopics(ctx, &models, topics)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Upserting topics...")
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
		for _, subTopicCode := range topic.SubTopicCodes {
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
	fmt.Println("Creating subtopic mappings...")
	err = models.Topics.ReCreateSubtopics(ctx, subtopicsToUpsert)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Invalidating cache...")
	rdb, err := initRedis(*redisDsn, *redisDb, *redisPoolSize)
	if err != nil {
		log.Fatal(err)
	}
	defer rdb.Close()
	fmt.Println("redis connection pool established")

	cache := cache.NewRedisCache(rdb)

	err = cache.Delete(ctx, "topics:*")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Cache invalidated")

	fmt.Println("Done")
}

func deleteOrphanedTopics(ctx context.Context, models *data.Models, topics []data.Topic) error {
	fmt.Println("Deleting orphaned topics...")
	topicCodes := []string{}
	for _, topic := range topics {
		topicCodes = append(topicCodes, topic.Code)
	}

	err := models.Topics.DeleteAllExcludingCodes(ctx, topicCodes)
	if err != nil {
		return err
	}

	return nil
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

func initRedis(dsn string, db, poolSize int) (*redis.Client, error) {
	options, err := redis.ParseURL(dsn)
	if err != nil {
		return nil, err
	}
	options.DB = db
	options.PoolSize = poolSize

	rdb := redis.NewClient(options)

	// Test Redis connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := rdb.Ping(ctx).Err(); err != nil {
		return nil, err
	}

	return rdb, nil
}

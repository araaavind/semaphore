package main

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/aravindmathradan/semaphore/internal/cache"
	"github.com/aravindmathradan/semaphore/internal/data"
)

func (app *application) listTopicsWithCache(w http.ResponseWriter, r *http.Request) {
	// Try to get topics from cache first
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	cacheKey := cache.GenerateTopicsKey()

	cachedData, err := app.cache.Get(ctx, cacheKey)
	if err == nil && len(cachedData) > 0 {
		// Cache hit - return the cached data
		var topics []data.Topic
		err = json.Unmarshal(cachedData, &topics)
		if err == nil {
			err = app.writeJSON(w, http.StatusOK, envelope{"topics": topics}, nil)
			if err != nil {
				app.serverErrorResponse(w, r, err)
			}
			return
		}
	}
	if err != nil {
		app.logger.Error("failed to get topics from cache", "error", err)
	}

	// Cache miss or error - fetch from database
	topics, err := app.models.Topics.GetTopics(ctx)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Cache the result with 6-hour expiration
	topicsJSON, err := json.Marshal(topics)
	if err == nil {
		err = app.cache.Set(ctx, cacheKey, topicsJSON, 6*time.Hour)
		if err != nil {
			// Log the error but continue - caching failure shouldn't affect the response
			app.logger.Error("failed to cache topics", "error", err)
		}
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"topics": topics}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

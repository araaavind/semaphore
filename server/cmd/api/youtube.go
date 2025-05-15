package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"

	"github.com/aravindmathradan/semaphore/internal/validator"
)

// youTubeChannelResponse represents the response from YouTube channels API
type youTubeChannelResponse struct {
	Items []struct {
		ID string `json:"id"`
	} `json:"items"`
	PageInfo struct {
		TotalResults int `json:"totalResults"`
	} `json:"pageInfo"`
}

// getYouTubeChannelID resolves a YouTube handle to a channel ID
func (app *application) getYouTubeChannelID(w http.ResponseWriter, r *http.Request) {
	// Check if the YouTube API key is configured
	if app.config.google.youtubeAPIKey == "" {
		app.serverErrorResponse(w, r, errors.New("YouTube API key not configured"))
		return
	}

	// Extract the handle from the query parameter
	handle := r.URL.Query().Get("handle")
	if handle == "" {
		app.badRequestResponse(w, r, errors.New("handle query parameter is required"))
		return
	}

	// Validate handle format
	v := validator.New()
	validateYouTubeHandle(v, handle)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	// Create context with timeout
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	// Ensure input is a handle (starts with @)
	if !strings.HasPrefix(handle, "@") {
		app.badRequestResponse(w, r, errors.New("handle must start with @"))
		return
	}

	// Resolve handle to channel ID
	channelID, err := resolveHandleToChannelID(ctx, handle, app.config.google.youtubeAPIKey)

	if err != nil {
		if errors.Is(err, errors.New("channel not found")) {
			app.notFoundResponse(w, r)
		} else {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// Return the channel ID
	err = app.writeJSON(w, http.StatusOK, envelope{"channel_id": channelID}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// resolveHandleToChannelID resolves a YouTube handle to a channel ID
// using the channels API with forHandle parameter
func resolveHandleToChannelID(ctx context.Context, handle, apiKey string) (string, error) {
	// Clean the handle - remove @ prefix
	cleanHandle := handle[1:]

	// Build YouTube API request URL with forHandle parameter
	apiURL := fmt.Sprintf(
		"https://www.googleapis.com/youtube/v3/channels?part=id&forHandle=%s&key=%s",
		url.QueryEscape(cleanHandle),
		apiKey,
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, apiURL, nil)
	if err != nil {
		return "", err
	}

	// Execute request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	// Check for non-200 status codes
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("YouTube API returned non-200 status: %d", resp.StatusCode)
	}

	// Parse the response
	var channelResp youTubeChannelResponse
	if err := json.NewDecoder(resp.Body).Decode(&channelResp); err != nil {
		return "", err
	}

	// Check if any channels were found
	if channelResp.PageInfo.TotalResults == 0 || len(channelResp.Items) == 0 {
		return "", errors.New("channel not found")
	}

	return channelResp.Items[0].ID, nil
}

// validateYouTubeHandle validates a YouTube handle string
func validateYouTubeHandle(v *validator.Validator, handle string) {
	v.Check(handle != "", "handle", "must be provided")
	v.Check(strings.HasPrefix(handle, "@"), "handle", "must start with @")

	// Clean the handle by removing @ prefix
	cleanHandle := handle[1:]

	v.Check(len(cleanHandle) >= 3, "handle", "must be at least 3 characters long")
	v.Check(len(cleanHandle) <= 30, "handle", "must not be more than 30 characters long")

	// YouTube handles typically allow letters, numbers, underscores, hyphens and periods
	validPattern := regexp.MustCompile(`^[a-zA-Z0-9_\-\.]+$`)
	v.Check(validator.Matches(cleanHandle, validPattern), "handle", "must contain only letters, numbers, underscores, hyphens and periods")
}

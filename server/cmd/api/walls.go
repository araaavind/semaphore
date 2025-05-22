package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/aravindmathradan/semaphore/internal/cache"
	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) createWall(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetSession(r).User

	var input struct {
		WallName string `json:"name"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	wall := &data.Wall{
		Name:      input.WallName,
		UserID:    user.ID,
		IsPrimary: false,
	}

	data.ValidateWall(v, wall)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = app.models.Walls.Insert(wall)
	if err != nil {
		if errors.Is(err, data.ErrDuplicateWall) {
			v.AddError("name", "You already have a wall with the same name")
			app.failedValidationResponse(w, r, v.Errors)
			return
		} else {
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	w.Header().Set("Location", fmt.Sprintf("/v1/walls/%d", wall.ID))
	w.WriteHeader(http.StatusCreated)
}

func (app *application) listWalls(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetSession(r).User

	walls, err := app.models.Walls.FindAllForUser(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"walls": walls}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) listItemsForWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	var filters data.CursorFilters

	v := validator.New()
	qs := r.URL.Query()

	filters.After = app.readString(qs, "after", "")
	filters.SessionID = app.readString(qs, "session_id", "")
	filters.PageSize = app.readInt(qs, "page_size", 16, v)
	filters.SortMode = data.SortMode(app.readString(qs, "sort_mode", string(data.SortModeNew)))
	filters.SortSafeList = []data.SortMode{data.SortModeNew, data.SortModeHot}

	data.ValidateCursorFilters(v, filters)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	wall, err := app.models.Walls.FindByID(wallID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	user := app.contextGetSession(r).User
	if wall.UserID != user.ID {
		app.notPermittedResponse(w, r)
		return
	}

	var items []*data.Item
	var metadata data.CursorMetadata
	if filters.SortMode == data.SortModeNew {
		// For new sort, fetch items directly from the database
		items, metadata, err = app.models.Items.FindAllForWallByNew(wallID, user.ID, filters)
		if err != nil {
			if errors.Is(err, data.ErrInvalidCursor) {
				v.AddError("after", "invalid cursor")
				app.failedValidationResponse(w, r, v.Errors)
				return
			}
			app.serverErrorResponse(w, r, err)
			return
		}
	} else if filters.SortMode == data.SortModeHot {
		// For hot sort, item scores are calculated once and cached throughout the paination session

		ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
		defer cancel()

		// SessionID is encoded as base64 string when sent to the client
		// Client sends back the same base64 string.
		// Decode it to get the actual session ID
		b, err := base64.URLEncoding.DecodeString(filters.SessionID)
		if err != nil {
			v.AddError("session_id", "invalid session id")
			app.failedValidationResponse(w, r, v.Errors)
			return
		}
		sessionID := string(b)

		var itemScores []*data.ItemScore
		if sessionID == "" {
			// Create a new session ID for the current pagination session
			// SessionID belongs to a wall and sort mode
			// UserID is not included because a wall can have only one owner
			sessionID = cache.GenerateItemScoresKey(wallID, string(filters.SortMode))

			// Encode the session ID to send to the client. This will be part of metadata
			filters.SessionID = base64.URLEncoding.EncodeToString([]byte(sessionID))

			// Calculate item scores for the current pagination session for a snapshot size of 300 (no. of items)
			itemScores, err = app.models.Items.CalculateHotItemScoresForWall(wallID, user.ID, 300)
			if err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}

			// Cache the pagination session with item scores for 10 minutes
			val, err := json.Marshal(itemScores)
			if err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}
			err = app.cache.Set(ctx, sessionID, val, 10*time.Minute)
		} else {
			// If client sends SessionID, get item scores from cache for the corresponding session
			val, err := app.cache.Get(ctx, sessionID)
			if err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}

			if val == nil {
				// If session is not found in cache, create a new session
				sessionID = cache.GenerateItemScoresKey(wallID, string(filters.SortMode))

				// Encode the session ID to send to the client. This will be part of metadata
				filters.SessionID = base64.URLEncoding.EncodeToString([]byte(sessionID))

				// Calculate item scores for the current pagination session for 100 top items
				itemScores, err = app.models.Items.CalculateHotItemScoresForWall(wallID, user.ID, 100)
				if err != nil {
					app.serverErrorResponse(w, r, err)
					return
				}

				// Cache the pagination session with item scores for 10 minutes
				val, err := json.Marshal(itemScores)
				if err != nil {
					app.serverErrorResponse(w, r, err)
					return
				}
				err = app.cache.Set(ctx, sessionID, val, 10*time.Minute)

				// Else, decode the item scores from cache
			} else if err := json.Unmarshal(val, &itemScores); err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}
		}

		// Find items by score. Pagination is handled inside the FindByScore function using the cursor
		items, metadata, err = app.models.Items.FindByScore(itemScores, user.ID, filters)
		if err != nil {
			if errors.Is(err, data.ErrInvalidCursor) {
				v.AddError("after", "invalid cursor")
				app.failedValidationResponse(w, r, v.Errors)
				return
			}
			app.serverErrorResponse(w, r, err)
			return
		}
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"items": items, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) updateWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	var input struct {
		Name string `json:"name"`
	}

	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	wall, err := app.models.Walls.FindByID(wallID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if wall.IsPrimary {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "Cannot update primary wall")
		return
	}

	user := app.contextGetSession(r).User
	if wall.UserID != user.ID {
		app.notPermittedResponse(w, r)
		return
	}

	wall.Name = input.Name

	v := validator.New()

	data.ValidateWall(v, wall)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	err = app.models.Walls.Update(wall)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"wall": wall}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) deleteWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	wall, err := app.models.Walls.FindByID(wallID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	if wall.IsPrimary {
		app.errorResponse(w, r, http.StatusUnprocessableEntity, "Cannot delete primary wall")
		return
	}

	user := app.contextGetSession(r).User
	if wall.UserID != user.ID {
		app.notPermittedResponse(w, r)
		return
	}

	err = app.models.Walls.Delete(wallID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		case errors.Is(err, data.ErrDeletingPrimaryWall):
			app.errorResponse(w, r, http.StatusUnprocessableEntity, "Cannot delete primary wall")
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (app *application) pinWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	wall, err := app.models.Walls.FindByID(wallID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	user := app.contextGetSession(r).User
	if wall.UserID != user.ID {
		app.notPermittedResponse(w, r)
		return
	}

	err = app.models.Walls.Pin(wallID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (app *application) unpinWall(w http.ResponseWriter, r *http.Request) {
	wallID, err := app.readIDParam(r, "wall_id")
	if err != nil || wallID < 1 {
		app.notFoundResponse(w, r)
		return
	}

	wall, err := app.models.Walls.FindByID(wallID)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			app.notFoundResponse(w, r)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
	}

	user := app.contextGetSession(r).User
	if wall.UserID != user.ID {
		app.notPermittedResponse(w, r)
		return
	}

	err = app.models.Walls.Unpin(wallID)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

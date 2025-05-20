package main

import (
	"errors"
	"fmt"
	"net/http"

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

	var input struct {
		Title string
		data.CursorFilters
	}

	v := validator.New()
	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.After = app.readString(qs, "after", "")
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.SortMode = data.SortMode(app.readString(qs, "sort_mode", string(data.SortModeNew)))

	data.ValidateCursorFilters(v, input.CursorFilters)
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

	items, metadata, err := app.models.Items.FindAllForWall(wallID, user.ID, input.Title, input.CursorFilters)
	if err != nil {
		if errors.Is(err, data.ErrInvalidCursor) {
			v.AddError("after", "invalid cursor")
			app.failedValidationResponse(w, r, v.Errors)
			return
		}
		if errors.Is(err, data.ErrUnsupportedSortMode) {
			v.AddError("sort_mode", "unsupported sort mode")
			app.failedValidationResponse(w, r, v.Errors)
			return
		}
		app.serverErrorResponse(w, r, err)
		return
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

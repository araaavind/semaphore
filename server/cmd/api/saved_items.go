package main

import (
	"errors"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) saveItemHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r, "id")
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	item, err := app.models.Items.GetById(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	err = app.models.SavedItems.Insert(user.ID, item.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (app *application) unsaveItemHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r, "id")
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	err = app.models.SavedItems.Delete(user.ID, id)
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

func (app *application) listSavedItemsHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetSession(r).User

	var input struct {
		Title string
		data.Filters
	}

	v := validator.New()
	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.Filters.Page = app.readInt(qs, "page", 1, v)
	input.Filters.PageSize = app.readInt(qs, "page_size", 20, v)
	input.Filters.Sort = app.readString(qs, "sort", "-saved_at")
	input.Filters.SortSafeList = []string{"saved_at", "created_at", "updated_at", "pub_date", "title", "-saved_at", "-created_at", "-updated_at", "-pub_date", "-title"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	savedItems, metadata, err := app.models.SavedItems.GetAllForUser(user.ID, input.Title, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"saved_items": savedItems, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) checkIfUserSavedItems(w http.ResponseWriter, r *http.Request) {
	v := validator.New()
	qs := r.URL.Query()

	itemIDs := app.readInt64List(qs, "ids", []int64{}, v)
	if len(itemIDs) > 100 {
		v.AddError("ids", "IDs should be a maximum of 100")
	}

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	user := app.contextGetSession(r).User

	result, err := app.models.SavedItems.CheckIfUserSavedItems(user.ID, []int64(itemIDs))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	savedList := make([]bool, len(itemIDs))
	for i, itemID := range itemIDs {
		if isSaved, exists := result[itemID]; exists {
			savedList[i] = isSaved
		} else {
			savedList[i] = false
		}
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"saved": savedList}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

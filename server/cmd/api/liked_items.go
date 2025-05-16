package main

import (
	"errors"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) likeItemHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r, "id")
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	err = app.models.LikedItems.Insert(user.ID, id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrFKeyItemNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (app *application) unlikeItemHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r, "id")
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	user := app.contextGetSession(r).User

	err = app.models.LikedItems.Delete(user.ID, id)
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

func (app *application) listLikedItemsHandler(w http.ResponseWriter, r *http.Request) {
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
	input.Filters.Sort = app.readString(qs, "sort", "-liked_at")
	input.Filters.SortSafeList = []string{"liked_at", "created_at", "updated_at", "pub_date", "title", "-liked_at", "-created_at", "-updated_at", "-pub_date", "-title"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	likedItems, metadata, err := app.models.LikedItems.GetAllForUser(user.ID, input.Title, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"liked_items": likedItems, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) checkIfUserLikedItems(w http.ResponseWriter, r *http.Request) {
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

	result, err := app.models.LikedItems.CheckIfUserLikedItems(user.ID, []int64(itemIDs))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	likedList := make([]bool, len(itemIDs))
	for i, itemID := range itemIDs {
		if isLiked, exists := result[itemID]; exists {
			likedList[i] = isLiked
		} else {
			likedList[i] = false
		}
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"liked": likedList}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) getLikeCountHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r, "id")
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	count, err := app.models.LikedItems.GetLikeCount(id)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"like_count": count}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

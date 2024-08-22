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

	if v.Check(validator.NotBlank(input.WallName), "name", "Wall name cannot be empty"); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	wall := &data.Wall{
		Name:      input.WallName,
		UserID:    user.ID,
		IsPrimary: false,
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
		data.Filters
	}

	v := validator.New()
	qs := r.URL.Query()

	input.Title = app.readString(qs, "title", "")
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 16, v)
	input.Sort = app.readString(qs, "sort", "-pub_date")
	input.SortSafeList = []string{"id", "title", "pub_date", "-id", "-title", "-pub_date"}

	if data.ValidateFilters(v, input.Filters); !v.Valid() {
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

	feeds, err := app.models.WallFeeds.FindFeedsForWall(wallID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	feedsMap := make(map[int64]*data.Feed)
	feedIDs := []int64{}
	for _, feed := range feeds {
		feedIDs = append(feedIDs, feed.ID)
		feedsMap[feed.ID] = feed
	}

	items, metadata, err := app.models.Items.FindAllForFeeds(feedIDs, input.Title, input.Filters)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	type itemWithFeedType struct {
		*data.Item
		Feed *data.Feed `json:"feed"`
	}

	itemsResponse := []*itemWithFeedType{}
	for _, item := range items {
		itemsResponse = append(itemsResponse, &itemWithFeedType{
			Item: item,
			Feed: feedsMap[item.FeedID],
		})
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"items": itemsResponse, "metadata": metadata}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

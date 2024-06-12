package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) addFeedHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Link string `json:"link"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	if data.ValidateLink(v, input.Link); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	fmt.Fprintf(w, "%v\n", input)
}

func (app *application) getFeedHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil || id < 1 {
		app.notFoundResponse(w, r)
		return
	}

	feed := data.Feed{
		ID:        id,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
		Title:     "Test feed",
		Version:   1,
	}

	err = app.writeJSON(w, http.StatusOK, envelope{"feed": feed}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

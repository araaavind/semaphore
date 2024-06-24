package main

import (
	"errors"
	"net/http"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

func (app *application) createAuthenticationToken(w http.ResponseWriter, r *http.Request) {
	var input struct {
		UsernameOrEmail string `json:"username_or_email"`
		Password        string `json:"password"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	var isInputEmail bool
	v := validator.New()
	if validator.Matches(input.UsernameOrEmail, validator.EmailRX) {
		data.ValidateEmail(v, input.UsernameOrEmail)
		isInputEmail = true
	} else if validator.Matches(input.UsernameOrEmail, validator.UsernameBasicRX) {
		data.ValidateUsername(v, input.UsernameOrEmail)
		isInputEmail = false
	} else {
		v.AddError("username_or_email", "invalid username or email")
	}
	data.ValidatePasswordPlaintext(v, input.Password)

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	var user *data.User
	if isInputEmail {
		user, err = app.models.Users.GetByEmail(input.UsernameOrEmail)
	} else {
		user, err = app.models.Users.GetByUsername(input.UsernameOrEmail)
	}
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.invalidCredentialsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	match, err := user.Password.Matches(input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	if !match {
		app.invalidCredentialsResponse(w, r)
		return
	}

	token, err := app.models.Tokens.New(user.ID, 24*time.Hour, data.ScopeAuthentication)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	err = app.writeJSON(w, http.StatusCreated, envelope{"authentication_token": token}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

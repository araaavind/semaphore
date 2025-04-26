package main

import (
	"crypto/sha256"
	"errors"
	"net/http"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/validator"
)

const (
	deleteGlobalSessionScope = "global"
	deleteLocalSessionScope  = "local"
	deleteOthersSessionScope = "others"

	authTokenTTL          = 1 * time.Hour
	refreshTokenTTL       = 30 * 24 * time.Hour
	activationTokenTTL    = 3 * 24 * time.Hour
	passwordResetTokenTTL = 45 * time.Minute
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
		v.AddError("username_or_email", "Invalid username or email")
	}
	v.Check(validator.NotBlank(input.Password), "password", "Password must be provided")

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

	refreshToken, err := app.models.Tokens.New(user.ID, refreshTokenTTL, data.ScopeRefresh)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	authToken, err := app.models.Tokens.New(user.ID, authTokenTTL, data.ScopeAuthentication)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	user.LastLoginAt.Time = time.Now()
	user.LastLoginAt.Valid = true
	err = app.models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrEditConflict):
			app.editConflictResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	err = app.writeJSON(w, http.StatusCreated, envelope{
		"authentication_token": authToken,
		"refresh_token":        refreshToken,
		"user":                 user,
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) deleteAuthenticationToken(w http.ResponseWriter, r *http.Request) {
	session := app.contextGetSession(r)
	qs := r.URL.Query()

	// Get the refresh token from the request header so that the refresh token of the session
	// can be deleted if the logout scope is local (or avoid deleting if logout scope is others)
	refreshToken := r.Header.Get("X-Refresh-Token")

	deleteSessionScope := app.readString(qs, "scope", deleteLocalSessionScope)
	var err error
	switch deleteSessionScope {
	case deleteLocalSessionScope:
		if refreshToken != "" && len(refreshToken) == 26 {
			refreshTokenHash := sha256.Sum256([]byte(refreshToken))
			err = app.models.Tokens.DeleteByHash(refreshTokenHash[:])
		}
		if err == nil {
			err = app.models.Tokens.DeleteByHash(session.Token.Hash)
		}
	case deleteGlobalSessionScope:
		err = app.models.Tokens.DeleteAllForUser(data.ScopeRefresh, session.User.ID)
		if err == nil {
			err = app.models.Tokens.DeleteAllForUser(data.ScopeAuthentication, session.User.ID)
		}
	case deleteOthersSessionScope:
		if refreshToken != "" && len(refreshToken) == 26 {
			refreshTokenHash := sha256.Sum256([]byte(refreshToken))
			err = app.models.Tokens.DeleteAllForUserExcept(data.ScopeAuthentication, session.User.ID, refreshTokenHash[:])
		}
		if err == nil {
			err = app.models.Tokens.DeleteAllForUserExcept(data.ScopeAuthentication, session.User.ID, session.Token.Hash)
		}
	default:
		app.failedValidationResponse(w, r, map[string]string{"scope": "invalid scope"})
		return
	}
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (app *application) createActivationToken(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Email string `json:"email"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	if data.ValidateEmail(v, input.Email); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	user, err := app.models.Users.GetByEmail(input.Email)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			v.AddError("email", "No matching email address found")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if user.Activated {
		v.AddError("email", "Your account has already been activated")
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	token, err := app.models.Tokens.New(user.ID, activationTokenTTL, data.ScopeActivation)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	app.background(func() {
		data := map[string]any{
			"activationToken": token.Plaintext,
			"username":        user.Username,
		}

		// Since email addresses MAY be case sensitive, notice that we are sending this
		// email using the address stored in our database for the user --- not to the
		// input.Email address provided by the client in this request.
		err = app.mailer.Send(user.Email, "activation_token.tmpl", data)
		if err != nil {
			app.logger.Error(err.Error())
		}
	})

	env := envelope{"message": "An email will be sent to you containing the activation token"}

	err = app.writeJSON(w, http.StatusAccepted, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) createPasswordResetToken(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Email string `json:"email"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()

	if data.ValidateEmail(v, input.Email); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	user, err := app.models.Users.GetByEmail(input.Email)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			v.AddError("email", "No matching account found")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if !user.Activated {
		v.AddError("email", "Your account must be activated to reset password")
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	token, err := app.models.Tokens.New(user.ID, passwordResetTokenTTL, data.ScopePasswordReset)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	app.background(func() {
		data := map[string]any{
			"passwordResetToken": token.Plaintext,
		}

		err = app.mailer.Send(user.Email, "password_reset_token.tmpl", data)
		if err != nil {
			app.logger.Error(err.Error())
		}
	})

	env := envelope{"message": "An email will be sent to you containing the password reset token"}

	err = app.writeJSON(w, http.StatusAccepted, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *application) refreshAuthenticationToken(w http.ResponseWriter, r *http.Request) {
	var input struct {
		RefreshToken string `json:"refresh_token"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	if data.ValidateTokenPlaintext(v, input.RefreshToken); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	// Get the user associated with the refresh token
	user, err := app.models.Users.GetForToken(data.ScopeRefresh, input.RefreshToken)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.invalidCredentialsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// Implement refresh token rotation by deleting the current refresh token
	// and assigning a new one.
	refreshTokenHash := sha256.Sum256([]byte(input.RefreshToken))
	err = app.models.Tokens.DeleteByHash(refreshTokenHash[:])
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	refreshToken, err := app.models.Tokens.New(user.ID, refreshTokenTTL, data.ScopeRefresh)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Create a new authentication token
	authToken, err := app.models.Tokens.New(user.ID, authTokenTTL, data.ScopeAuthentication)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Update the last login time
	user.LastLoginAt.Time = time.Now()
	user.LastLoginAt.Valid = true
	err = app.models.Users.Update(user)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrEditConflict):
			app.editConflictResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	err = app.writeJSON(w, http.StatusCreated, envelope{
		"authentication_token": authToken,
		"refresh_token":        refreshToken,
		"user":                 user,
	}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

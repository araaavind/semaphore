package main

import (
	"context"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
)

type contextKey string

const userContextKey = contextKey("user")

func (app *application) contextSetUser(r *http.Request, user *data.User) *http.Request {
	ctx := context.WithValue(r.Context(), userContextKey, user)
	return r.WithContext(ctx)
}

func (app *application) contextGetUser(r *http.Request) *data.User {
	user, ok := r.Context().Value(userContextKey).(*data.User)
	if !ok {
		// The only time that we'll use this helper is when we logically expect there to be User struct
		// value in the context, and if it doesn't exist it will firmly be an 'unexpected' error.
		// It's OK to panic in this case
		panic("missing user value in request context")
	}

	return user
}

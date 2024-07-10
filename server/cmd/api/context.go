package main

import (
	"context"
	"net/http"

	"github.com/aravindmathradan/semaphore/internal/data"
)

type contextKey string

const sessionContextKey = contextKey("sesssion")

func (app *application) contextSetSession(r *http.Request, session *data.Session) *http.Request {
	ctx := context.WithValue(r.Context(), sessionContextKey, session)
	return r.WithContext(ctx)
}

func (app *application) contextGetSession(r *http.Request) *data.Session {
	session, ok := r.Context().Value(sessionContextKey).(*data.Session)
	if !ok {
		// The only time that we'll use this helper is when we logically expect there to be User struct
		// value in the context, and if it doesn't exist it will firmly be an 'unexpected' error.
		// It's OK to panic in this case
		panic("missing session value in request context")
	}

	return session
}

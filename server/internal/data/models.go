package data

import (
	"database/sql"
	"errors"
)

var (
	ErrRecordNotFound = errors.New("record not found")
	ErrEditConflict   = errors.New("edit conflict")
)

type Models struct {
	Users       UserModel
	Tokens      TokenModel
	Feeds       FeedModel
	FeedFollows FeedFollowModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		UserModel{DB: db},
		TokenModel{DB: db},
		FeedModel{DB: db},
		FeedFollowModel{DB: db},
	}
}

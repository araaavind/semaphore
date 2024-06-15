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
	Feeds       FeedModel
	FeedFollows FeedFollowModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		FeedModel{DB: db},
		FeedFollowModel{DB: db},
	}
}

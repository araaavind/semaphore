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
	Sessions    SessionModel
	Permissions PermissionModel
	Feeds       FeedModel
	FeedFollows FeedFollowModel
	Items       ItemModel
	Walls       WallModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		UserModel{DB: db},
		TokenModel{DB: db},
		SessionModel{DB: db},
		PermissionModel{DB: db},
		FeedModel{DB: db},
		FeedFollowModel{DB: db},
		ItemModel{DB: db},
		WallModel{DB: db},
	}
}

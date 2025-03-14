package data

import (
	"errors"

	"github.com/jackc/pgx/v5/pgxpool"
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
	WallFeeds   WallFeedModel
}

func NewModels(db *pgxpool.Pool) Models {
	return Models{
		UserModel{DB: db},
		TokenModel{DB: db},
		SessionModel{DB: db},
		PermissionModel{DB: db},
		FeedModel{DB: db},
		FeedFollowModel{DB: db},
		ItemModel{DB: db},
		WallModel{DB: db},
		WallFeedModel{DB: db},
	}
}

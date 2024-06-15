package data

import (
	"context"
	"database/sql"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
)

var (
	ErrDuplicateFeedFollow = errors.New("user already follows the feed")
)

type FeedFollow struct {
	UserID    int64     `json:"user_id"`
	FeedID    int64     `json:"feed_id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type FeedFollowModel struct {
	DB *sql.DB
}

func (m FeedFollowModel) Insert(feedFollow *FeedFollow) error {
	insertFeedFollowQuery := `
		INSERT INTO feed_follows (user_id, feed_id)
		VALUES ($1, $2)
		RETURNING created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, insertFeedFollowQuery, feedFollow.UserID, feedFollow.FeedID).Scan(
		&feedFollow.CreatedAt,
		&feedFollow.UpdatedAt,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "feed_follows_pkey") {
				return ErrDuplicateFeedFollow
			}
		}
		return err
	}

	return nil
}

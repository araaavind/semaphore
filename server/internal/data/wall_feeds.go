package data

import (
	"context"
	"database/sql"
	"time"
)

type WallFeed struct {
	WallID    int64      `json:"wall_id"`
	FeedID    int64      `json:"feed_id"`
	CreatedAt *time.Time `json:"created_at,omitempty"`
	UpdatedAt *time.Time `json:"updated_at,omitempty"`
}

type WallFeedModel struct {
	DB *sql.DB
}

func (m WallFeedModel) Insert(wallFeed *WallFeed) error {
	query := `
		INSERT INTO wall_feeds (wall_id, feed_id)
		VALUES ($1, $2)
		RETURNING created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, wallFeed.WallID, wallFeed.FeedID).Scan(
		&wallFeed.CreatedAt,
		&wallFeed.UpdatedAt,
	)
	if err != nil {
		return err
	}
	return nil
}

func (m WallFeedModel) DeleteFeedForWalls(feedID int64, wallIDs []int64) error {
	query := `
		DELETE FROM wall_feeds
		WHERE feed_id = $1
		AND wall_id = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, feedID, wallIDs)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return ErrRecordNotFound
	}

	return nil
}

func (m WallFeedModel) Delete(wallFeed *WallFeed) error {
	query := `
		DELETE FROM wall_feeds
		WHERE wall_id = $1 AND feed_id = $2`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.ExecContext(ctx, query, wallFeed.WallID, wallFeed.FeedID)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return ErrRecordNotFound
	}

	return nil
}

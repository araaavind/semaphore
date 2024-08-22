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
	ErrDuplicateWallFeed = errors.New("feed is already added to the wall")
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
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "wall_feeds_pkey") {
				return ErrDuplicateWallFeed
			}
		}
		return err
	}
	return nil
}

func (m WallFeedModel) FindFeedsForWall(wallID int64) ([]*Feed, error) {
	query := `
		SELECT feeds.id, feeds.title, feeds.description, feeds.link, feeds.feed_link,
			feeds.pub_date, feeds.pub_updated, feeds.feed_type, feeds.feed_version, feeds.language
		FROM feeds
		INNER JOIN wall_feeds ON wall_feeds.feed_id = feeds.id
		WHERE wall_feeds.wall_id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, wallID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	feeds := []*Feed{}
	for rows.Next() {
		var feed Feed
		err := rows.Scan(
			&feed.ID,
			&feed.Title,
			&feed.Description,
			&feed.Link,
			&feed.FeedLink,
			&feed.PubDate,
			&feed.PubUpdated,
			&feed.FeedType,
			&feed.FeedVersion,
			&feed.Language,
		)
		if err != nil {
			return nil, err
		}
		feeds = append(feeds, &feed)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return feeds, nil
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

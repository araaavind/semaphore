package data

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
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
	DB *pgxpool.Pool
}

func (m WallFeedModel) Insert(wallFeed *WallFeed) error {
	query := `
		INSERT INTO wall_feeds (wall_id, feed_id)
		VALUES ($1, $2)
		RETURNING created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, wallFeed.WallID, wallFeed.FeedID).Scan(
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

func (m WallFeedModel) FindFeedsForWall(wallID int64, title string, filters Filters) ([]*Feed, Metadata, error) {
	columnMapping := sortColumnMapping{
		"id":          "feeds.id",
		"title":       "feeds.title",
		"pub_date":    "feeds.pub_date",
		"pub_updated": "feeds.pub_updated",
	}
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), feeds.id, feeds.title, feeds.description, feeds.link, feeds.feed_link,
			feeds.pub_date, feeds.pub_updated, feeds.feed_type, feeds.feed_version, feeds.language
		FROM feeds
		INNER JOIN wall_feeds ON wall_feeds.feed_id = feeds.id
		WHERE wall_feeds.wall_id = $1 
		AND (
			to_tsvector('simple', feeds.title) @@ plainto_tsquery('simple', $2)
			OR $2 = ''
		)
		ORDER BY %s %s, feeds.id ASC
		LIMIT $3 OFFSET $4`, filters.sortColumn(columnMapping), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{wallID, title, filters.limit(), filters.offset()}

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	totalRecords := 0
	feeds, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Feed, error) {
		var feed Feed
		err := row.Scan(
			&totalRecords,
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
		return &feed, err
	})
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	return feeds, calculateMetadata(totalRecords, filters.Page, filters.PageSize), nil
}

func (m WallFeedModel) DeleteFeedForWalls(feedID int64, wallIDs []int64) error {
	query := `
		DELETE FROM wall_feeds
		WHERE feed_id = $1
		AND wall_id = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.Exec(ctx, query, feedID, wallIDs)
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
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

	result, err := m.DB.Exec(ctx, query, wallFeed.WallID, wallFeed.FeedID)
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrRecordNotFound
	}

	return nil
}

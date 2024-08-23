package data

import (
	"context"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/aravindmathradan/semaphore/internal/validator"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrDuplicateLink = errors.New("link already exists in the database")
)

type Feed struct {
	ID            int64              `json:"id"`
	Title         string             `json:"title"`
	Description   string             `json:"description"`
	Link          string             `json:"link"`
	FeedLink      string             `json:"feed_link"`
	PubDate       time.Time          `json:"pub_date,omitempty"`
	PubUpdated    time.Time          `json:"pub_updated,omitempty"`
	FeedType      string             `json:"feed_type,omitempty"`
	FeedVersion   string             `json:"feed_version,omitempty"`
	Language      string             `json:"language,omitempty"`
	Version       int32              `json:"version,omitempty"`
	AddedBy       int64              `json:"added_by,omitempty"`
	LastFetchAt   pgtype.Timestamptz `json:"last_fetch_at,omitempty"`
	LastFailure   pgtype.Text        `json:"last_failure,omitempty"`
	LastFailureAt pgtype.Timestamptz `json:"last_failure_at,omitempty"`
	FailureCount  int32              `json:"failure_count,omitempty"`
	CreatedAt     *time.Time         `json:"created_at,omitempty"`
	UpdatedAt     *time.Time         `json:"updated_at,omitempty"`
}

func ValidateFeedLink(v *validator.Validator, feedLink string) {
	v.Check(validator.NotBlank(feedLink), "feed_link", "Feed link must not be empty")
}

type FeedModel struct {
	DB *pgxpool.Pool
}

func (m FeedModel) Insert(feed *Feed) error {
	query := `
		INSERT INTO feeds (title, description, link, feed_link, pub_date, pub_updated,
			feed_type, feed_version, language, added_by, last_fetch_at, last_failure_at,
			last_failure)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, created_at, updated_at, version`

	args := []any{
		feed.Title,
		feed.Description,
		feed.Link,
		feed.FeedLink,
		feed.PubDate,
		feed.PubUpdated,
		feed.FeedType,
		feed.FeedVersion,
		feed.Language,
		feed.AddedBy,
		feed.LastFetchAt,
		feed.LastFailureAt,
		feed.LastFailure,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, args...).Scan(
		&feed.ID,
		&feed.CreatedAt,
		&feed.UpdatedAt,
		&feed.Version,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "feeds_feed_link_key") {
				return ErrDuplicateLink
			}
		}
		return err
	}
	return nil
}

func (m FeedModel) FindAll(title string, feedLink string, filters Filters) ([]*Feed, Metadata, error) {
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), id, title, description, link, feed_link, pub_date,
		pub_updated, feed_type, feed_version, language, added_by, created_at, updated_at,
		version, last_fetch_at, last_failure_at, last_failure
		FROM feeds
		WHERE (
			to_tsvector('simple', title) @@ plainto_tsquery('simple', $1)
			OR $1 = ''
		)
		AND (feed_link = $2 OR $2 = '')
		ORDER BY %s %s, id ASC
		LIMIT $3 OFFSET $4`, filters.sortColumn(), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{title, feedLink, filters.limit(), filters.offset()}

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
			&feed.AddedBy,
			&feed.CreatedAt,
			&feed.UpdatedAt,
			&feed.Version,
			&feed.LastFetchAt,
			&feed.LastFailureAt,
			&feed.LastFailure,
		)
		return &feed, err
	})
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return feeds, metadata, nil
}

func (m FeedModel) FindByFeedLinks(feedLinks []string) (*Feed, error) {
	query := `
		SELECT id, title, description, link, feed_link, pub_date, pub_updated, feed_type,
		feed_version, language, added_by, created_at, updated_at, version, last_fetch_at,
		last_failure_at, last_failure
		FROM feeds WHERE feed_link = ANY ($1)`

	var feed Feed

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, feedLinks).Scan(
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
		&feed.AddedBy,
		&feed.CreatedAt,
		&feed.UpdatedAt,
		&feed.Version,
		&feed.LastFetchAt,
		&feed.LastFailureAt,
		&feed.LastFailure,
	)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &feed, nil
}

func (m FeedModel) FindByID(id int64) (*Feed, error) {
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	query := `
		SELECT id, title, description, link, feed_link, pub_date, pub_updated, feed_type,
		feed_version, language, added_by, created_at, updated_at, version, last_fetch_at,
		last_failure_at, last_failure
		FROM feeds WHERE id = $1`

	var feed Feed

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, id).Scan(
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
		&feed.AddedBy,
		&feed.CreatedAt,
		&feed.UpdatedAt,
		&feed.Version,
		&feed.LastFetchAt,
		&feed.LastFailureAt,
		&feed.LastFailure,
	)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &feed, nil
}

func (m FeedModel) Update(feed *Feed) error {
	query := `
		UPDATE feeds
		SET title = $1, description = $2, link = $3, feed_link = $4, pub_date = $5, pub_updated = $6,
		feed_type = $7, feed_version = $8, language = $9, updated_at = NOW(), last_fetch_at = $10,
		last_failure_at = $11, last_failure = $12, version = version + 1
		WHERE id = $13 AND version = $14
		RETURNING updated_at, version`

	args := []any{
		feed.Title,
		feed.Description,
		feed.Link,
		feed.FeedLink,
		feed.PubDate,
		feed.PubUpdated,
		feed.FeedType,
		feed.FeedVersion,
		feed.Language,
		feed.LastFetchAt,
		feed.LastFailureAt,
		feed.LastFailure,
		feed.ID,
		feed.Version,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, args...).Scan(&feed.UpdatedAt, &feed.Version)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return ErrEditConflict
		default:
			return err
		}
	}
	return nil
}

func (m FeedModel) DeleteByID(id int64) error {
	if id < 1 {
		return ErrRecordNotFound
	}

	query := `
		DELETE FROM feeds
		WHERE id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.Exec(ctx, query, id)
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrRecordNotFound
	}

	return nil
}

func (m FeedModel) GetUncheckedFeedsSince(since time.Time) ([]*Feed, error) {
	query := `
		SELECT id, feed_link, version
		FROM feeds
		WHERE GREATEST(last_fetch_at, last_failure_at, '-Infinity'::timestamptz) < $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, since)
	if err != nil {
		return nil, err
	}

	feeds, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Feed, error) {
		var feed Feed
		err := row.Scan(
			&feed.ID,
			&feed.FeedLink,
			&feed.Version,
		)
		return &feed, err
	})
	if err != nil {
		return nil, err
	}

	return feeds, nil
}

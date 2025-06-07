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
	DisplayTitle  pgtype.Text        `json:"display_title,omitempty"`
	Title         string             `json:"title"`
	Description   string             `json:"description"`
	Link          string             `json:"link"`
	FeedLink      string             `json:"feed_link"`
	ImageURL      pgtype.Text        `json:"image_url,omitempty"`
	PubDate       time.Time          `json:"pub_date,omitempty"`
	PubUpdated    time.Time          `json:"pub_updated,omitempty"`
	FeedType      string             `json:"feed_type,omitempty"`
	OwnerType     string             `json:"owner_type,omitempty"`
	FeedFormat    string             `json:"feed_format,omitempty"`
	FeedVersion   string             `json:"feed_version,omitempty"`
	TopicID       pgtype.Int8        `json:"topic_id,omitempty"`
	Language      string             `json:"language,omitempty"`
	Version       int32              `json:"version,omitempty"`
	AddedBy       pgtype.Int8        `json:"added_by,omitempty"`
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
		INSERT INTO feeds (display_title, title, description, link, feed_link, image_url, pub_date, pub_updated,
			feed_type, owner_type, feed_format, feed_version, topic_id, language, added_by,
			last_fetch_at, last_failure_at, last_failure)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
		RETURNING id, created_at, updated_at, version`

	if feed.FeedType == "" {
		feed.FeedType = "website"
	}

	if feed.OwnerType == "" {
		feed.OwnerType = "organization"
	}

	args := []any{
		feed.DisplayTitle,
		feed.Title,
		feed.Description,
		feed.Link,
		feed.FeedLink,
		feed.ImageURL,
		feed.PubDate,
		feed.PubUpdated,
		feed.FeedType,
		feed.OwnerType,
		feed.FeedFormat,
		feed.FeedVersion,
		feed.TopicID,
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

func (m FeedModel) FindAll(title string, feedLink string, topicID int64, filters Filters) ([]*Feed, Metadata, error) {
	sortColMap := sortColumnMapping{
		"id":          "feeds.id",
		"title":       "feeds.title",
		"pub_date":    "feeds.pub_date",
		"pub_updated": "feeds.pub_updated",
	}

	query := fmt.Sprintf(`
		SELECT count(*) OVER(), feeds.id, feeds.display_title, feeds.title, feeds.description, feeds.link, feeds.feed_link, feeds.image_url, feeds.pub_date,
		feeds.pub_updated, feeds.feed_type, feeds.owner_type, feeds.feed_format, feeds.feed_version, feeds.topic_id, feeds.language, feeds.added_by, feeds.created_at, feeds.updated_at,
		feeds.version, feeds.last_fetch_at, feeds.last_failure_at, feeds.last_failure
		FROM feeds
		WHERE (
			to_tsvector('simple', feeds.title) @@ plainto_tsquery('simple', $1)
			OR $1 = ''
		)
		AND (feeds.feed_link = $2 OR $2 = '')
		AND (
			feeds.topic_id = $3
			OR EXISTS (
				SELECT 1 FROM subtopics 
				WHERE subtopics.child_id = feeds.topic_id 
				AND subtopics.parent_id = $3
			)
			OR $3 = -1
		)
		ORDER BY %s %s, feeds.id ASC
		LIMIT $4 OFFSET $5`, filters.sortColumn(sortColMap), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{title, feedLink, topicID, filters.limit(), filters.offset()}

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
			&feed.DisplayTitle,
			&feed.Title,
			&feed.Description,
			&feed.Link,
			&feed.FeedLink,
			&feed.ImageURL,
			&feed.PubDate,
			&feed.PubUpdated,
			&feed.FeedType,
			&feed.OwnerType,
			&feed.FeedFormat,
			&feed.FeedVersion,
			&feed.TopicID,
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
		SELECT id, display_title, title, description, link, feed_link, image_url, pub_date, pub_updated, feed_type, owner_type, feed_format,
		feed_version, topic_id, language, added_by, created_at, updated_at, version, last_fetch_at,
		last_failure_at, last_failure
		FROM feeds WHERE feed_link = ANY ($1)`

	var feed Feed

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, feedLinks).Scan(
		&feed.ID,
		&feed.DisplayTitle,
		&feed.Title,
		&feed.Description,
		&feed.Link,
		&feed.FeedLink,
		&feed.ImageURL,
		&feed.PubDate,
		&feed.PubUpdated,
		&feed.FeedType,
		&feed.OwnerType,
		&feed.FeedFormat,
		&feed.FeedVersion,
		&feed.TopicID,
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
		SELECT id, display_title, title, description, link, feed_link, image_url, pub_date, pub_updated, feed_type, owner_type, feed_format,
		feed_version, topic_id, language, added_by, created_at, updated_at, version, last_fetch_at,
		last_failure_at, last_failure
		FROM feeds WHERE id = $1`

	var feed Feed

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, id).Scan(
		&feed.ID,
		&feed.DisplayTitle,
		&feed.Title,
		&feed.Description,
		&feed.Link,
		&feed.FeedLink,
		&feed.ImageURL,
		&feed.PubDate,
		&feed.PubUpdated,
		&feed.FeedType,
		&feed.OwnerType,
		&feed.FeedFormat,
		&feed.FeedVersion,
		&feed.TopicID,
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
		SET display_title = $1, 
			title = $2, 
			description = $3, 
			link = $4, 
			feed_link = $5, 
			image_url = COALESCE($6, image_url), 
			pub_date = COALESCE($7, pub_date), 
			pub_updated = COALESCE($8, pub_updated),
			feed_type = $9,
			owner_type = $10,
			feed_format = $11, 
			feed_version = $12, 
			topic_id = COALESCE($13, topic_id), 
			language = $14, 
			updated_at = NOW(), 
			last_fetch_at = COALESCE($15, last_fetch_at),
			last_failure_at = COALESCE($16, last_failure_at), 
			last_failure = COALESCE($17, last_failure), 
			version = version + 1
		WHERE id = $18 AND version = $19
		RETURNING updated_at, version`

	args := []any{
		feed.DisplayTitle,
		feed.Title,
		feed.Description,
		feed.Link,
		feed.FeedLink,
		feed.ImageURL,
		feed.PubDate,
		feed.PubUpdated,
		feed.FeedType,
		feed.OwnerType,
		feed.FeedFormat,
		feed.FeedVersion,
		feed.TopicID,
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
		SELECT id, feed_link, display_title, feed_type, owner_type, topic_id, version
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
			&feed.DisplayTitle,
			&feed.FeedType,
			&feed.OwnerType,
			&feed.TopicID,
			&feed.Version,
		)
		return &feed, err
	})
	if err != nil {
		return nil, err
	}

	return feeds, nil
}

func (m FeedModel) UpdateFailureStatus(feed *Feed) error {
	query := `
		UPDATE feeds
		SET last_failure_at = $1, last_failure = $2, version = version + 1
		WHERE id = $3 AND version = $4
		RETURNING updated_at, version`

	args := []any{
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

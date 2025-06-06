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
	ErrDuplicateFeedFollow = errors.New("user already follows the feed")
)

type FeedFollow struct {
	UserID    int64     `json:"user_id"`
	FeedID    int64     `json:"feed_id"`
	Priority  int       `json:"priority,omitempty"`
	CreatedAt time.Time `json:"created_at,omitempty"`
	UpdatedAt time.Time `json:"updated_at,omitempty"`
}

type FeedFollowModel struct {
	DB *pgxpool.Pool
}

func (m FeedFollowModel) GetFollowersForFeed(feedID int64, filters Filters) ([]*User, Metadata, error) {
	columnMapping := sortColumnMapping{
		"id":        "users.id",
		"full_name": "users.full_name",
		"username":  "users.username",
	}
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), users.id, users.full_name, users.username, users.profile_image_url
		FROM users
		INNER JOIN feed_follows ON feed_follows.user_id = users.id
		INNER JOIN feeds ON feeds.id = feed_follows.feed_id
		WHERE feeds.id = $1
		ORDER BY %s %s, id ASC
		LIMIT $2 OFFSET $3`, filters.sortColumn(columnMapping), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{feedID, filters.limit(), filters.offset()}

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	totalRecords := 0
	users, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*User, error) {
		var user User
		err := row.Scan(
			&totalRecords,
			&user.ID,
			&user.FullName,
			&user.Username,
			&user.ProfileImageURL,
		)
		return &user, err
	})
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return users, metadata, nil
}

func (m FeedFollowModel) GetFeedsForUser(userID int64, filters Filters) ([]*Feed, Metadata, error) {
	columnMapping := sortColumnMapping{
		"id":          "feeds.id",
		"title":       "feeds.title",
		"pub_date":    "feeds.pub_date",
		"pub_updated": "feeds.pub_updated",
	}
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), feeds.id, feeds.display_title, feeds.title, feeds.description, feeds.link, feeds.feed_link,
			feeds.image_url, feeds.pub_date, feeds.pub_updated, feeds.feed_type, feeds.owner_type, feeds.feed_format, feeds.feed_version, feeds.language
		FROM feeds
		INNER JOIN feed_follows ON feed_follows.feed_id = feeds.id
		INNER JOIN users ON users.id = feed_follows.user_id
		WHERE users.id = $1
		ORDER BY %s %s, id ASC
		LIMIT $2 OFFSET $3`, filters.sortColumn(columnMapping), filters.sortDirection())

	args := []any{userID, filters.limit(), filters.offset()}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

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
			&feed.Language,
		)
		return &feed, err
	})
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return feeds, metadata, nil
}

func (m FeedFollowModel) CountFollowersForFeeds(feedIDs []int64) (map[int64]int, error) {
	query := `
		SELECT feed_id, COALESCE(count(feed_id), 0) AS followers
		FROM feed_follows
		WHERE feed_id = ANY($1)
		GROUP BY feed_id`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, feedIDs)
	if err != nil {
		return nil, err
	}

	var feedID int64
	var followerCount int
	result := make(map[int64]int)
	_, err = pgx.ForEachRow(rows, []any{&feedID, &followerCount}, func() error {
		result[feedID] = followerCount
		return nil
	})
	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m FeedFollowModel) CheckIfUserFollowsFeeds(userID int64, feedIDs []int64) (map[int64]bool, error) {
	query := `
		SELECT feeds.id,
		EXISTS (
			SELECT 1
			FROM feed_follows
			WHERE feed_follows.user_id = $1 AND feed_follows.feed_id = feeds.id
		) AS is_followed
		FROM feeds
		WHERE feeds.id = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, userID, feedIDs)
	if err != nil {
		return nil, err
	}

	var feedID int64
	var isFollowed bool
	result := make(map[int64]bool)
	_, err = pgx.ForEachRow(rows, []any{&feedID, &isFollowed}, func() error {
		result[feedID] = isFollowed
		return nil
	})
	if err != nil {
		return nil, err
	}

	return result, nil
}

func (m FeedFollowModel) Insert(feedFollow *FeedFollow) error {
	query := `
		INSERT INTO feed_follows (user_id, feed_id)
		VALUES ($1, $2)
		RETURNING created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, feedFollow.UserID, feedFollow.FeedID).Scan(
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

func (m FeedFollowModel) Delete(feedFollow FeedFollow) error {
	query := `
		DELETE FROM feed_follows
		WHERE user_id = $1 AND feed_id = $2`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.Exec(ctx, query, feedFollow.UserID, feedFollow.FeedID)
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrRecordNotFound
	}

	return nil
}

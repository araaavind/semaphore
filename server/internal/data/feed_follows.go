package data

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
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

func (m FeedFollowModel) GetFollowersForFeed(feedID int64, filters Filters) ([]*User, Metadata, error) {
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), users.id, users.full_name, users.username
		FROM users
		INNER JOIN feed_follows ON feed_follows.user_id = users.id
		INNER JOIN feeds ON feeds.id = feed_follows.feed_id
		WHERE feeds.id = $1
		ORDER BY %s %s, id ASC
		LIMIT $2 OFFSET $3`, filters.sortColumn(), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{feedID, filters.limit(), filters.offset()}

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}
	defer rows.Close()

	totalRecords := 0
	users := []*User{}

	for rows.Next() {
		var user User
		err = rows.Scan(
			&totalRecords,
			&user.ID,
			&user.FullName,
			&user.Username,
		)
		if err != nil {
			return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
		}
		users = append(users, &user)
	}

	if err = rows.Err(); err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return users, metadata, nil
}

func (m FeedFollowModel) GetFeedsForUser(userID int64, filters Filters) ([]*Feed, Metadata, error) {
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), feeds.id, feeds.title, feeds.description, feeds.link, feeds.feed_link, feeds.pub_date, feeds.pub_updated, feeds.feed_type, feeds.feed_version, feeds.language
		FROM feeds
		INNER JOIN feed_follows ON feed_follows.feed_id = feeds.id
		INNER JOIN users ON users.id = feed_follows.user_id
		WHERE users.id = $1
		ORDER BY %s %s, id ASC
		LIMIT $2 OFFSET $3`, filters.sortColumn(), filters.sortDirection())

	args := []any{userID, filters.limit(), filters.offset()}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}
	defer rows.Close()

	totalRecords := 0
	feeds := []*Feed{}
	for rows.Next() {
		var feed Feed
		err := rows.Scan(
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
		if err != nil {
			return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
		}
		feeds = append(feeds, &feed)
	}

	if err = rows.Err(); err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return feeds, metadata, nil
}

func (m FeedFollowModel) CheckFeedsFollowedByUser(userID int64, feedIDs []int64) (map[int64]bool, error) {
	query := `
		SELECT feeds.id AS feed_id,
		EXISTS (
			SELECT 1
			FROM feed_follows
			WHERE feed_follows.user_id = $1 AND feed_follows.feed_id = feeds.id
		) AS is_followed
		FROM feeds
		WHERE feeds.id = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, userID, feedIDs)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := make(map[int64]bool)
	for rows.Next() {
		var feedID int64
		var isFollowed bool
		err := rows.Scan(
			&feedID,
			&isFollowed,
		)
		if err != nil {
			return nil, err
		}
		result[feedID] = isFollowed
	}

	if err = rows.Err(); err != nil {
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

	err := m.DB.QueryRowContext(ctx, query, feedFollow.UserID, feedFollow.FeedID).Scan(
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

func (m FeedFollowModel) Upsert(feedFollow FeedFollow) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	existsQuery := `
		SELECT EXISTS (
			SELECT 1 FROM feed_follows
			WHERE user_id = $1
			AND feed_id = $2
		)`

	var exists bool
	err := m.DB.QueryRowContext(ctx, existsQuery, feedFollow.UserID, feedFollow.FeedID).Scan(&exists)
	if err != nil {
		return err
	}

	if exists {
		return nil
	}

	insertQuery := `
		INSERT INTO feed_follows (user_id, feed_id)
		VALUES ($1, $2)`

	_, err = m.DB.ExecContext(ctx, insertQuery, feedFollow.UserID, feedFollow.FeedID)
	if err != nil {
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

	result, err := m.DB.ExecContext(ctx, query, feedFollow.UserID, feedFollow.FeedID)
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

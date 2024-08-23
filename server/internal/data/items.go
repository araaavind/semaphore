package data

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrDuplicateItem = errors.New("item already exists in the database for the same feed")
)

type Item struct {
	ID          int64                 `json:"id"`
	Title       string                `json:"title,omitempty"`
	Description string                `json:"description,omitempty"`
	Content     pgtype.Text           `json:"content,omitempty"`
	Link        string                `json:"link,omitempty"`
	PubDate     pgtype.Timestamptz    `json:"pub_date,omitempty"`
	PubUpdated  pgtype.Timestamptz    `json:"pub_updated,omitempty"`
	Authors     pgtype.Array[*Person] `json:"authors,omitempty"`
	GUID        string                `json:"guid,omitempty"`
	ImageURL    pgtype.Text           `json:"image_url,omitempty"`
	Categories  pgtype.Array[string]  `json:"categories,omitempty"`
	FeedID      int64                 `json:"feed_id,omitempty"`
	Version     int32                 `json:"version,omitempty"`
	CreatedAt   time.Time             `json:"created_at,omitempty"`
	UpdatedAt   time.Time             `json:"updated_at,omitempty"`
}

// Person is an individual specified in a feed
// (e.g. an author)
type Person struct {
	Name  string `json:"name,omitempty"`
	Email string `json:"email,omitempty"`
}

type ItemModel struct {
	DB *pgxpool.Pool
}

func buildUpsertItemsQuery(items []*Item) (query string, args []any) {
	var buf bytes.Buffer

	buf.WriteString(`
		WITH all_items(feed_id, title, description, content, link, pub_date, pub_updated, guid,
			authors, image_url, categories) AS (
			VALUES
	`)

	for i, item := range items {
		if i > 0 {
			buf.WriteString(", ")
		}

		buf.WriteString("($")
		args = append(args, item.FeedID)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::bigint")

		buf.WriteString(", $")
		args = append(args, item.Title)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		args = append(args, item.Description)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		if item.Content.Valid {
			args = append(args, item.Content.String)
		} else {
			args = append(args, nil)
		}
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		args = append(args, item.Link)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		if item.PubDate.Valid {
			args = append(args, item.PubDate.Time)
		} else {
			args = append(args, nil)
		}
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::timestamptz")

		buf.WriteString(", $")
		if item.PubUpdated.Valid {
			args = append(args, item.PubUpdated.Time)
		} else {
			args = append(args, nil)
		}
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::timestamptz")

		buf.WriteString(", $")
		args = append(args, item.GUID)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		if item.Authors.Valid {
			authorsJSON, err := json.Marshal(item.Authors)
			if err != nil {
				panic(err)
			}
			args = append(args, authorsJSON)
		} else {
			args = append(args, nil)
		}
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::jsonb")

		buf.WriteString(", $")
		if item.ImageURL.Valid {
			args = append(args, item.ImageURL.String)
		} else {
			args = append(args, nil)
		}
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		if item.Categories.Valid {
			args = append(args, item.Categories)
		} else {
			args = append(args, nil)
		}
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::text[]")
		buf.WriteString(")")
	}

	buf.WriteString(`
		),
		updated_items AS (
			UPDATE items AS i
			SET
				title = a.title,
				description = a.description,
				content = a.content,
				link = a.link,
				pub_date = a.pub_date,
				pub_updated = a.pub_updated,
				guid = a.guid,
				authors = a.authors,
				image_url = a.image_url,
				categories = a.categories
			FROM all_items as a
			WHERE i.feed_id = a.feed_id
			AND (i.link = a.link OR i.guid = a.guid)
			RETURNING i.feed_id, i.guid, i.link
		)
		INSERT INTO items (feed_id, title, description, content, link, pub_date, pub_updated,
			guid, authors, image_url, categories)
		SELECT *
		FROM all_items ai
		WHERE NOT EXISTS (
			SELECT 1
			FROM updated_items ui
			WHERE ui.feed_id = ai.feed_id
			AND (ui.link = ai.link OR ui.guid = ai.guid)
		)
	`)

	return buf.String(), args
}

func (m ItemModel) UpsertMany(items []*Item) error {
	query, args := buildUpsertItemsQuery(items)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, args...)
	if err != nil {
		return err
	}

	return nil
}

func (m ItemModel) Insert(item *Item) error {
	query := `
		INSERT INTO items (title, description, content, link, pub_date, pub_updated,
			guid, authors, image_url, categories, feed_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at, updated_at, version`

	authorsJSON, err := json.Marshal(item.Authors)
	if err != nil {
		return err
	}

	args := []any{
		item.Title,
		item.Description,
		item.Content,
		item.Link,
		item.PubDate,
		item.PubUpdated,
		item.GUID,
		authorsJSON,
		item.ImageURL,
		item.Categories,
		item.FeedID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err = m.DB.QueryRow(ctx, query, args...).Scan(
		&item.ID,
		&item.CreatedAt,
		&item.UpdatedAt,
		&item.Version,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && (strings.Contains(pgErr.ConstraintName, "items_feed_id_link_key") || strings.Contains(pgErr.ConstraintName, "items_feed_id_guid_key")) {
				return ErrDuplicateItem
			}
		}
		return err
	}
	return nil
}

func (m ItemModel) FindAllForFeeds(feedIDs []int64, title string, filters Filters) ([]*Item, Metadata, error) {
	query := fmt.Sprintf(`
		SELECT count(*) OVER(), id, title, description, content, link, pub_date,
			pub_updated, authors, guid, image_url, categories, feed_id, version,
			created_at, updated_at
		FROM items
		WHERE feed_id = ANY($1)
		AND (
			to_tsvector('simple', title) @@ plainto_tsquery('simple', $2)
			OR $2 = ''
		)
		ORDER BY %s %s, id ASC
		LIMIT $3 OFFSET $4`, filters.sortColumn(), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{feedIDs, title, filters.limit(), filters.offset()}

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	totalRecords := 0
	items, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Item, error) {
		var item Item
		authorsJSON := []byte{}
		err := rows.Scan(
			&totalRecords,
			&item.ID,
			&item.Title,
			&item.Description,
			&item.Content,
			&item.Link,
			&item.PubDate,
			&item.PubUpdated,
			&authorsJSON,
			&item.GUID,
			&item.ImageURL,
			&item.Categories,
			&item.FeedID,
			&item.Version,
			&item.CreatedAt,
			&item.UpdatedAt,
		)
		if authorsJSON != nil {
			err = json.Unmarshal(authorsJSON, &item.Authors)
		}
		return &item, err
	})
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)

	return items, metadata, nil
}

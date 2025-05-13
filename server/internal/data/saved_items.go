package data

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type SavedItem struct {
	UserID    int64     `json:"user_id"`
	ItemID    int64     `json:"item_id"`
	CreatedAt time.Time `json:"created_at"`
	Item      *Item     `json:"item,omitempty"`
}

type SavedItemModel struct {
	DB *pgxpool.Pool
}

func (m SavedItemModel) Insert(userID, itemID int64) error {
	query := `
		INSERT INTO saved_items (user_id, item_id)
		VALUES ($1, $2)
		ON CONFLICT DO NOTHING`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, userID, itemID)
	if err != nil {
		return err
	}

	return nil
}

func (m SavedItemModel) Delete(userID, itemID int64) error {
	query := `
		DELETE FROM saved_items
		WHERE user_id = $1 AND item_id = $2`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.Exec(ctx, query, userID, itemID)
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrRecordNotFound
	}

	return nil
}

func (m SavedItemModel) GetAllForUser(userID int64, title string, filters Filters) ([]*SavedItem, Metadata, error) {
	sortMapping := sortColumnMapping{
		"saved_at":   "si.created_at",
		"created_at": "i.created_at",
		"updated_at": "i.updated_at",
		"pub_date":   "i.pub_date",
		"title":      "i.title",
	}

	query := fmt.Sprintf(`
		SELECT count(*) OVER(), si.user_id, si.item_id, si.created_at,
			i.id, i.title, i.description, i.content, i.link, i.pub_date,
			i.pub_updated, i.authors, i.guid, i.image_url, i.categories, i.enclosures, i.feed_id,
			i.version, i.created_at, i.updated_at, f.title
		FROM saved_items si
		INNER JOIN items i ON si.item_id = i.id
		INNER JOIN feeds f ON i.feed_id = f.id
		WHERE si.user_id = $1
		AND (
			to_tsvector('simple', i.title) @@ plainto_tsquery('simple', $2)
			OR $2 = ''
		)
		ORDER BY COALESCE(%s, i.updated_at) %s, i.id desc
		LIMIT $3 OFFSET $4`, filters.sortColumn(sortMapping), filters.sortDirection())

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	args := []any{userID, title, filters.limit(), filters.offset()}

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}
	defer rows.Close()

	totalRecords := 0

	savedItems, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*SavedItem, error) {
		var savedItem SavedItem
		var item Item
		var feed Feed
		err := row.Scan(
			&totalRecords,
			&savedItem.UserID,
			&savedItem.ItemID,
			&savedItem.CreatedAt,
			&item.ID,
			&item.Title,
			&item.Description,
			&item.Content,
			&item.Link,
			&item.PubDate,
			&item.PubUpdated,
			&item.Authors,
			&item.GUID,
			&item.ImageURL,
			&item.Categories,
			&item.Enclosures,
			&item.FeedID,
			&item.Version,
			&item.CreatedAt,
			&item.UpdatedAt,
			&feed.Title,
		)
		if err != nil {
			return nil, err
		}

		item.Feed = &feed
		savedItem.Item = &item
		return &savedItem, nil
	})

	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)
	return savedItems, metadata, nil
}

func (m SavedItemModel) CheckIfUserSavedItems(userID int64, itemIDs []int64) (map[int64]bool, error) {
	query := `
		SELECT items.id,
		EXISTS (
			SELECT 1
			FROM saved_items
			WHERE saved_items.user_id = $1 AND saved_items.item_id = items.id
		) AS is_saved
		FROM items
		WHERE items.id = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, userID, itemIDs)
	if err != nil {
		return nil, err
	}

	var itemID int64
	var isSaved bool
	result := make(map[int64]bool)
	_, err = pgx.ForEachRow(rows, []any{&itemID, &isSaved}, func() error {
		result[itemID] = isSaved
		return nil
	})
	if err != nil {
		return nil, err
	}

	return result, nil
}

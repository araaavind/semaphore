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

type LikedItem struct {
	UserID    int64     `json:"user_id"`
	ItemID    int64     `json:"item_id"`
	CreatedAt time.Time `json:"created_at"`
	Item      *Item     `json:"item,omitempty"`
}

type LikedItemModel struct {
	DB *pgxpool.Pool
}

var (
	ErrFKeyItemNotFound = errors.New("item not found")
)

func (m LikedItemModel) Insert(userID, itemID int64) error {
	query := `
		INSERT INTO liked_items (user_id, item_id)
		VALUES ($1, $2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, userID, itemID)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23503) && strings.Contains(pgErr.ConstraintName, "liked_items_item_id_fkey") {
				return ErrFKeyItemNotFound
			}
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "liked_items_pkey") {
				// Do nothing, it's already liked
				return nil
			}
		}
		return err
	}

	return nil
}

func (m LikedItemModel) Delete(userID, itemID int64) error {
	query := `
		DELETE FROM liked_items
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

func (m LikedItemModel) GetAllForUser(userID int64, title string, filters Filters) ([]*LikedItem, Metadata, error) {
	sortMapping := sortColumnMapping{
		"liked_at":   "li.created_at",
		"created_at": "i.created_at",
		"updated_at": "i.updated_at",
		"pub_date":   "i.pub_date",
		"title":      "i.title",
	}

	query := fmt.Sprintf(`
		SELECT count(*) OVER(), li.user_id, li.item_id, li.created_at,
			i.id, i.title, i.description, i.content, i.link, i.pub_date,
			i.pub_updated, i.authors, i.guid, i.image_url, i.categories, i.enclosures, i.feed_id,
			i.version, i.created_at, i.updated_at, f.title
		FROM liked_items li
		INNER JOIN items i ON li.item_id = i.id
		INNER JOIN feeds f ON i.feed_id = f.id
		WHERE li.user_id = $1
		AND (
			to_tsvector('simple', i.title) @@ plainto_tsquery('simple', $2)
			OR $2 = ''
		)
		ORDER BY COALESCE(%s, i.updated_at) %s, i.id DESC
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

	likedItems, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*LikedItem, error) {
		var likedItem LikedItem
		var item Item
		var feed Feed
		err := row.Scan(
			&totalRecords,
			&likedItem.UserID,
			&likedItem.ItemID,
			&likedItem.CreatedAt,
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
		likedItem.Item = &item
		return &likedItem, nil
	})

	if err != nil {
		return nil, getEmptyMetadata(filters.Page, filters.PageSize), err
	}

	metadata := calculateMetadata(totalRecords, filters.Page, filters.PageSize)
	return likedItems, metadata, nil
}

func (m LikedItemModel) GetLikeCount(itemID int64) (int, error) {
	query := `
		SELECT COUNT(*) 
		FROM liked_items
		WHERE item_id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var count int
	err := m.DB.QueryRow(ctx, query, itemID).Scan(&count)
	if err != nil {
		return 0, err
	}

	return count, nil
}

func (m LikedItemModel) CheckIfUserLikedItems(userID int64, itemIDs []int64) (map[int64]bool, error) {
	query := `
		SELECT items.id,
		EXISTS (
			SELECT 1
			FROM liked_items
			WHERE liked_items.user_id = $1 AND liked_items.item_id = items.id
		) AS is_liked
		FROM items
		WHERE items.id = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, userID, itemIDs)
	if err != nil {
		return nil, err
	}

	var itemID int64
	var isLiked bool
	result := make(map[int64]bool)
	_, err = pgx.ForEachRow(rows, []any{&itemID, &isLiked}, func() error {
		result[itemID] = isLiked
		return nil
	})
	if err != nil {
		return nil, err
	}

	return result, nil
}

// GetUsersWhoLiked retrieves the user IDs of all users who liked a specific item
// This can be useful for notifications or analytics
func (m LikedItemModel) GetUsersWhoLiked(itemID int64) ([]int64, error) {
	query := `
		SELECT user_id
		FROM liked_items
		WHERE item_id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, itemID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	userIDs := []int64{}
	for rows.Next() {
		var userID int64
		err := rows.Scan(&userID)
		if err != nil {
			return nil, err
		}
		userIDs = append(userIDs, userID)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return userIDs, nil
}

// UpdateItemWithLikeInfo extends an item with like information for a specific user
func (m LikedItemModel) UpdateItemWithLikeInfo(item *Item, userID int64) error {
	query := `
		SELECT EXISTS (
			SELECT 1 
			FROM liked_items 
			WHERE user_id = $1 AND item_id = $2
		) AS is_liked`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var isLiked bool
	err := m.DB.QueryRow(ctx, query, userID, item.ID).Scan(&isLiked)
	if err != nil {
		return err
	}

	item.IsLiked = isLiked
	return nil
}

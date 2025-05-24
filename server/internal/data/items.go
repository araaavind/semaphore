package data

import (
	"bytes"
	"context"
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
	ID          int64                        `json:"id"`
	Title       string                       `json:"title,omitempty"`
	Description string                       `json:"description,omitempty"`
	Content     pgtype.Text                  `json:"content,omitempty"`
	Link        string                       `json:"link,omitempty"`
	PubDate     pgtype.Timestamptz           `json:"pub_date,omitempty"`
	PubUpdated  pgtype.Timestamptz           `json:"pub_updated,omitempty"`
	Authors     pgtype.FlatArray[*Person]    `json:"authors,omitempty"`
	GUID        string                       `json:"guid,omitempty"`
	ImageURL    pgtype.Text                  `json:"image_url,omitempty"`
	Categories  pgtype.FlatArray[string]     `json:"categories,omitempty"`
	Enclosures  pgtype.FlatArray[*Enclosure] `json:"enclosures,omitempty"`
	FeedID      int64                        `json:"feed_id,omitempty"`
	Version     int32                        `json:"version,omitempty"`
	CreatedAt   time.Time                    `json:"created_at,omitempty"`
	UpdatedAt   time.Time                    `json:"updated_at,omitempty"`

	IsSaved bool    `json:"is_saved,omitempty"`
	IsLiked bool    `json:"is_liked,omitempty"`
	Score   float64 `json:"score,omitempty"`
	Feed    *Feed   `json:"feed,omitempty"`
}

// Person is an individual specified in a feed
// (e.g. an author)
type Person struct {
	Name  string `json:"name,omitempty"`
	Email string `json:"email,omitempty"`
}

type Enclosure struct {
	URL    string `json:"url,omitempty"`
	Length string `json:"length,omitempty"`
	Type   string `json:"type,omitempty"`
}

type ItemScore struct {
	ItemID int64
	Score  float64
}

// Cursor for sorting items by "new"
type sortByNewCursor struct {
	PubDate pgtype.Timestamptz
	ID      int64
}

type sortByScoreCursor struct {
	ID    int64
	Score float64
}

type ItemModel struct {
	DB *pgxpool.Pool
}

func buildUpsertItemsQuery(items []*Item) (query string, args []any) {
	var buf bytes.Buffer

	buf.WriteString(`
		WITH all_items(feed_id, title, description, content, link, pub_date, pub_updated, guid,
			authors, image_url, categories, enclosures) AS (
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
		args = append(args, item.Content)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		args = append(args, item.Link)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		args = append(args, item.PubDate)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::timestamptz")

		buf.WriteString(", $")
		args = append(args, item.PubUpdated)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::timestamptz")

		buf.WriteString(", $")
		args = append(args, item.GUID)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		args = append(args, item.Authors)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::jsonb")

		buf.WriteString(", $")
		args = append(args, item.ImageURL)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))

		buf.WriteString(", $")
		args = append(args, item.Categories)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::text[]")

		buf.WriteString(", $")
		args = append(args, item.Enclosures)
		buf.WriteString(strconv.FormatInt(int64(len(args)), 10))
		buf.WriteString("::jsonb")

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
				categories = a.categories,
				enclosures = a.enclosures,
				version = i.version + 1
			FROM all_items as a
			WHERE i.feed_id = a.feed_id
			AND (i.link = a.link OR i.guid = a.guid)
			RETURNING i.feed_id, i.guid, i.link
		)
		INSERT INTO items (feed_id, title, description, content, link, pub_date, pub_updated,
			guid, authors, image_url, categories, enclosures)
		SELECT *
		FROM all_items ai
		WHERE NOT EXISTS (
			SELECT 1
			FROM updated_items ui
			WHERE ui.feed_id = ai.feed_id
			AND (ui.link = ai.link OR ui.guid = ai.guid)
		)
		ON CONFLICT DO NOTHING
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
			guid, authors, image_url, categories, enclosures, feed_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
		RETURNING id, created_at, updated_at, version`

	args := []any{
		item.Title,
		item.Description,
		item.Content,
		item.Link,
		item.PubDate,
		item.PubUpdated,
		item.GUID,
		item.Authors,
		item.ImageURL,
		item.Categories,
		item.Enclosures,
		item.FeedID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, args...).Scan(
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

func (m ItemModel) FindAllForFeedsByNew(feedIDs []int64, userID int64, title string, cursorFilters CursorFilters) ([]*Item, CursorMetadata, error) {
	query := `
		SELECT items.id, items.title, items.description, items.content, items.link, items.pub_date,
			items.pub_updated, items.authors, items.guid, items.image_url, items.categories, items.enclosures, items.feed_id,
			items.version, items.created_at, items.updated_at, (si.item_id IS NOT NULL) as is_saved,
			(li.item_id IS NOT NULL) as is_liked
		FROM items
		LEFT JOIN saved_items si ON si.item_id = items.id AND si.user_id = $3
		LEFT JOIN liked_items li ON li.item_id = items.id AND li.user_id = $3
		WHERE items.feed_id = ANY($1)
		AND (
			to_tsvector('simple', items.title) @@ plainto_tsquery('simple', $2)
			OR $2 = ''
		)`

	args := []any{feedIDs, title, userID}

	if cursorFilters.After != "" {
		var cursor sortByNewCursor
		err := decodeCursor(cursorFilters.After, &cursor)
		if err != nil {
			return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
		}
		query += `
			AND (COALESCE(items.pub_date, items.updated_at), items.id) < ($4, $5)
		`
		args = append(args, cursor.PubDate, cursor.ID)
	}
	query += fmt.Sprintf(`
		ORDER BY COALESCE(items.pub_date, items.updated_at) DESC, items.id DESC
		LIMIT $%d
	`, len(args)+1)
	args = append(args, cursorFilters.PageSize)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
	}

	var lastID int64
	var lastPubDate pgtype.Timestamptz
	items, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Item, error) {
		var item Item
		err := rows.Scan(
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
			&item.IsSaved,
			&item.IsLiked,
		)
		lastID = item.ID
		lastPubDate = item.PubDate
		return &item, err
	})
	if err != nil {
		return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
	}

	nextCursor := sortByNewCursor{
		PubDate: lastPubDate,
		ID:      lastID,
	}
	metadata := calculateCursorMetadata(
		nextCursor,
		cursorFilters.PageSize,
		len(items) == cursorFilters.PageSize,
		cursorFilters.SessionID,
	)

	return items, metadata, nil
}

func (m ItemModel) FindAllForWallByNew(wallID, userID int64, cursorFilters CursorFilters) ([]*Item, CursorMetadata, error) {
	query := `
		SELECT items.id, items.title, items.description, items.content, items.link, items.pub_date,
			items.pub_updated, items.authors, items.guid, items.image_url, items.categories, items.enclosures, items.feed_id,
			items.version, items.created_at, items.updated_at, feeds.id, feeds.title, feeds.description, feeds.link, feeds.feed_link,
			feeds.pub_date as feed_pub_date, feeds.pub_updated as feed_pub_updated, feeds.feed_type, feeds.language,
			feeds.image_url as feed_image_url, (si.item_id IS NOT NULL) as is_saved, (li.item_id IS NOT NULL) as is_liked
		FROM items
		INNER JOIN feeds ON feeds.id = items.feed_id
		INNER JOIN wall_feeds ON wall_feeds.feed_id = feeds.id
		LEFT JOIN saved_items si ON si.item_id = items.id AND si.user_id = $2
		LEFT JOIN liked_items li ON li.item_id = items.id AND li.user_id = $2
		WHERE wall_feeds.wall_id = $1
	`
	args := []any{wallID, userID}

	if cursorFilters.After != "" {
		var cursor sortByNewCursor
		err := decodeCursor(cursorFilters.After, &cursor)
		if err != nil {
			return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
		}
		query += `
			AND (COALESCE(items.pub_date, items.updated_at), items.id) < ($3, $4)
		`
		args = append(args, cursor.PubDate, cursor.ID)
	}
	query += fmt.Sprintf(`
		ORDER BY COALESCE(items.pub_date, items.updated_at) DESC, items.id DESC
		LIMIT $%d
	`, len(args)+1)
	args = append(args, cursorFilters.PageSize)

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
	}

	var lastID int64
	var lastPubDate pgtype.Timestamptz
	items, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Item, error) {
		var item Item
		var feed Feed
		err := rows.Scan(
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
			&feed.ID,
			&feed.Title,
			&feed.Description,
			&feed.Link,
			&feed.FeedLink,
			&feed.PubDate,
			&feed.PubUpdated,
			&feed.FeedType,
			&feed.Language,
			&feed.ImageURL,
			&item.IsSaved,
			&item.IsLiked,
		)
		item.Feed = &feed
		lastID = item.ID
		lastPubDate = item.PubDate
		return &item, err
	})
	if err != nil {
		return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
	}

	nextCursor := sortByNewCursor{
		PubDate: lastPubDate,
		ID:      lastID,
	}
	metadata := calculateCursorMetadata(
		nextCursor,
		cursorFilters.PageSize,
		len(items) == cursorFilters.PageSize,
		cursorFilters.SessionID,
	)

	return items, metadata, nil
}

func (m ItemModel) FindByScore(itemScores []*ItemScore, userID int64, cursorFilters CursorFilters) ([]*Item, CursorMetadata, error) {
	// itemScores is already sorted by score in descending order
	// We use the cursor to find the start and end indices of the items to fetch

	if len(itemScores) == 0 {
		return []*Item{}, getEmptyCursorMetadata(cursorFilters.PageSize), nil
	}

	start := 0
	var cursor sortByScoreCursor
	if cursorFilters.After != "" {
		// If cursor is provided, decode it to get the previous item's score and ID
		err := decodeCursor(cursorFilters.After, &cursor)
		if err != nil {
			return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
		}

		// Find the start index of the items to fetch next
		for _, itemScore := range itemScores {
			start++
			if itemScore.Score > cursor.Score ||
				(itemScore.Score == cursor.Score && itemScore.ItemID > cursor.ID) {
				continue
			} else {
				break
			}
		}
	}

	// end is the end index of the items to fetch next
	// If end index is greater than the number of items, set it to the last item
	end := min(start+cursorFilters.PageSize, len(itemScores))

	slice := itemScores[start:end]

	// Get the IDs of the items to fetch next
	ids := make([]int64, len(slice))
	for i, itemScore := range slice {
		ids[i] = itemScore.ItemID
	}

	// GetByItemIDs function does not guarantee the order of the items
	unorderedItems, err := m.GetByItemIDs(ids, userID)
	if err != nil {
		return nil, getEmptyCursorMetadata(cursorFilters.PageSize), err
	}

	itemMap := make(map[int64]*Item)
	for _, item := range unorderedItems {
		itemMap[item.ID] = item
	}

	// Create a new items variable for ordering the items according to itemScores
	// Also add the score to the items
	items := make([]*Item, len(slice))
	for i, itemScore := range slice {
		items[i] = itemMap[itemScore.ItemID]
		items[i].Score = itemScore.Score
	}

	// Provide the next cursor to the client
	nextCursor := sortByScoreCursor{
		ID:    slice[len(slice)-1].ItemID,
		Score: slice[len(slice)-1].Score,
	}

	return items, calculateCursorMetadata(
		nextCursor,
		cursorFilters.PageSize,
		len(items) == cursorFilters.PageSize,
		cursorFilters.SessionID,
	), nil
}

func (m ItemModel) CalculateHotItemScoresForWall(wallID, userID int64, snapshotSize int) ([]*ItemScore, error) {
	scoreCalculation := buildHotItemsScoreCalculationQuery("lc.like_count", "sc.save_count", "items.pub_date")
	query := fmt.Sprintf(`
		WITH ranked_items AS (
			SELECT items.id as item_id, %s as score
			FROM items
			INNER JOIN feeds ON feeds.id = items.feed_id
			INNER JOIN wall_feeds ON wall_feeds.feed_id = feeds.id
			LEFT JOIN (
				SELECT item_id, COUNT(*) as save_count FROM saved_items GROUP BY item_id
			) sc ON sc.item_id = items.id
			LEFT JOIN (
				SELECT item_id, COUNT(*) as like_count FROM liked_items GROUP BY item_id
			) lc ON lc.item_id = items.id
			WHERE wall_feeds.wall_id = $1
		)
		SELECT *
		FROM ranked_items
		ORDER BY score DESC, item_id DESC
		LIMIT $2
	`, scoreCalculation)
	args := []any{wallID, snapshotSize}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}

	itemScores, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*ItemScore, error) {
		var itemScore ItemScore
		err := row.Scan(&itemScore.ItemID, &itemScore.Score)
		return &itemScore, err
	})
	if err != nil {
		return nil, err
	}

	return itemScores, nil
}

func (m ItemModel) GetByItemIDs(ids []int64, userID int64) ([]*Item, error) {
	query := `
		SELECT items.id, items.title, items.description, items.content, items.link, items.pub_date,
			items.pub_updated, items.authors, items.guid, items.image_url, items.categories, items.enclosures, items.feed_id,
			items.version, items.created_at, items.updated_at, feeds.id, feeds.title, feeds.description, feeds.link, feeds.feed_link,
			feeds.pub_date as feed_pub_date, feeds.pub_updated as feed_pub_updated, feeds.feed_type, feeds.language,
			feeds.image_url as feed_image_url, (si.item_id IS NOT NULL) as is_saved, (li.item_id IS NOT NULL) as is_liked
		FROM items
		INNER JOIN feeds ON feeds.id = items.feed_id
		LEFT JOIN saved_items si ON si.item_id = items.id AND si.user_id = $2
		LEFT JOIN liked_items li ON li.item_id = items.id AND li.user_id = $2
		WHERE items.id = ANY($1)
	`
	args := []any{ids, userID}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}

	items, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Item, error) {
		var item Item
		var feed Feed
		err := row.Scan(
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
			&feed.ID,
			&feed.Title,
			&feed.Description,
			&feed.Link,
			&feed.FeedLink,
			&feed.PubDate,
			&feed.PubUpdated,
			&feed.FeedType,
			&feed.Language,
			&feed.ImageURL,
			&item.IsSaved,
			&item.IsLiked,
		)
		item.Feed = &feed
		return &item, err
	})

	return items, err
}

func (m ItemModel) GetById(id int64) (*Item, error) {
	query := `
		SELECT id, title, description, content, link, pub_date, pub_updated,
			authors, guid, image_url, categories, enclosures, feed_id,
			version, created_at, updated_at
		FROM items
		WHERE id = $1`

	var item Item

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, id).Scan(
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
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}

	return &item, nil
}

func (m ItemModel) CleanupItems(before time.Time) error {
	query := `
		DELETE FROM items
		WHERE updated_at < $1
		AND id NOT IN (
			SELECT item_id FROM saved_items
			WHERE item_id = items.id
		)
	`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, before)
	return err
}

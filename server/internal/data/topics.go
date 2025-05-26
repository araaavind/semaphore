package data

import (
	"context"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Topic struct {
	ID        int64              `json:"id"`
	Code      string             `json:"code"`
	Name      string             `json:"name"`
	Featured  bool               `json:"featured,omitempty"`
	Active    bool               `json:"active,omitempty"`
	ImageURL  pgtype.Text        `json:"image_url,omitempty"`
	Color     pgtype.Text        `json:"color,omitempty"`
	Keywords  []string           `json:"keywords,omitempty"`
	CreatedAt pgtype.Timestamptz `json:"-"`
	UpdatedAt pgtype.Timestamptz `json:"-"`
	Version   int32              `json:"-"`

	// Not stored in DB
	SubTopics     []*Topic `json:"sub_topics,omitempty"`
	SubTopicCodes []string `json:"sub_topic_codes,omitempty"`
}

type Subtopic struct {
	ParentID int64 `json:"parent_id"`
	ChildID  int64 `json:"child_id"`
}

type TopicModel struct {
	DB *pgxpool.Pool
}

func (m *TopicModel) Upsert(ctx context.Context, topics []Topic) error {
	query := `
		INSERT INTO topics (code, name, featured, active, image_url, color, keywords)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (code) DO UPDATE
		SET name = EXCLUDED.name,
			featured = EXCLUDED.featured,
			active = EXCLUDED.active,
			image_url = EXCLUDED.image_url,
			color = EXCLUDED.color,
			keywords = EXCLUDED.keywords,
			version = topics.version + 1,
			updated_at = NOW()
		RETURNING id`

	tx, err := m.DB.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	for i := range topics {
		err = tx.QueryRow(
			ctx,
			query,
			topics[i].Code,
			topics[i].Name,
			topics[i].Featured,
			topics[i].Active,
			topics[i].ImageURL,
			topics[i].Color,
			topics[i].Keywords,
		).Scan(&topics[i].ID)

		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

func (m *TopicModel) ReCreateSubtopics(ctx context.Context, subtopics []Subtopic) error {
	query := `
		INSERT INTO subtopics (parent_id, child_id)
		VALUES ($1, $2)
		ON CONFLICT (parent_id, child_id) DO NOTHING
	`

	tx, err := m.DB.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	_, err = tx.Exec(ctx, `DELETE FROM subtopics`)
	if err != nil {
		return err
	}

	for _, subtopic := range subtopics {
		_, err = tx.Exec(ctx, query, subtopic.ParentID, subtopic.ChildID)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

func (m *TopicModel) GetTopics(ctx context.Context) ([]Topic, error) {
	query := `
		SELECT p.id, p.code, p.name, p.featured, p.image_url, p.color, p.keywords,
			c.id, c.code, c.name
		FROM topics p
		LEFT JOIN subtopics st ON p.id = st.parent_id
		LEFT JOIN topics c ON st.child_id = c.id AND c.active = true
		WHERE p.active = true
		ORDER BY p.featured DESC, p.name ASC
	`

	rows, err := m.DB.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	topics := []Topic{}

	for rows.Next() {
		var parent Topic
		var childID *int64
		var childCode *string
		var childName *string
		err := rows.Scan(
			&parent.ID,
			&parent.Code,
			&parent.Name,
			&parent.Featured,
			&parent.ImageURL,
			&parent.Color,
			&parent.Keywords,
			&childID,
			&childCode,
			&childName,
		)
		if err != nil {
			return nil, err
		}

		if len(topics) != 0 && topics[len(topics)-1].ID == parent.ID && childID != nil {
			topics[len(topics)-1].SubTopics = append(topics[len(topics)-1].SubTopics, &Topic{
				ID:   *childID,
				Code: *childCode,
				Name: *childName,
			})
		} else {
			topics = append(topics, parent)
			if childID != nil {
				topics[len(topics)-1].SubTopics = append(topics[len(topics)-1].SubTopics, &Topic{
					ID:   *childID,
					Code: *childCode,
					Name: *childName,
				})
			}
		}
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}

	return topics, nil
}

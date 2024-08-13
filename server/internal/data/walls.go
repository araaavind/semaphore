package data

import (
	"context"
	"database/sql"
	"time"
)

type Wall struct {
	ID        int64      `json:"id"`
	Name      string     `json:"name"`
	IsPrimary bool       `json:"is_primary"`
	UserID    int64      `json:"user_id"`
	CreatedAt *time.Time `json:"created_at,omitempty"`
	UpdatedAt *time.Time `json:"updated_at,omitempty"`
}

type WallModel struct {
	DB *sql.DB
}

func (m WallModel) Insert(wall *Wall) error {
	query := `
		INSERT INTO walls (name, is_primary, user_id)
		VALUES ($1, $2, $3)
		RETURNING id, created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, query, wall.Name, wall.IsPrimary, wall.UserID).Scan(
		&wall.ID,
		&wall.CreatedAt,
		&wall.UpdatedAt,
	)
	if err != nil {
		return err
	}
	return nil
}

func (m WallModel) InsertPrimaryWall(userID int64) error {
	wall := &Wall{
		Name:      "All feeds",
		IsPrimary: true,
		UserID:    userID,
	}

	return m.Insert(wall)
}

func (m WallModel) FindAllForUser(userID int64) ([]*Wall, error) {
	query := `
		SELECT id, name, is_primary, user_id, created_at, updated_at
		FROM walls
		WHERE user_id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	walls := []*Wall{}
	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		wall := &Wall{}
		err := rows.Scan(
			&wall.ID,
			&wall.Name,
			&wall.IsPrimary,
			&wall.UserID,
			&wall.CreatedAt,
			&wall.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		walls = append(walls, wall)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}
	return walls, nil
}

func (m WallModel) FindPrimaryWallForUser(userID int64) (*Wall, error) {
	query := `
		SELECT id, name, is_primary, user_id, created_at, updated_at
		FROM walls
		WHERE user_id = $1 AND is_primary = true
		LIMIT 1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	wall := &Wall{}
	err := m.DB.QueryRowContext(ctx, query, userID).Scan(
		&wall.ID,
		&wall.Name,
		&wall.IsPrimary,
		&wall.UserID,
		&wall.CreatedAt,
		&wall.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return wall, nil
}

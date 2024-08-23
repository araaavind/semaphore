package data

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrDuplicateWall = errors.New("user already owns a wall with same name")
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
	DB *pgxpool.Pool
}

func (m WallModel) Insert(wall *Wall) error {
	query := `
		INSERT INTO walls (name, is_primary, user_id)
		VALUES ($1, $2, $3)
		RETURNING id, created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, wall.Name, wall.IsPrimary, wall.UserID).Scan(
		&wall.ID,
		&wall.CreatedAt,
		&wall.UpdatedAt,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "walls_name_key") {
				return ErrDuplicateWall
			}
		}
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

func (m WallModel) FindByID(wallID int64) (*Wall, error) {
	query := `
		SELECT id, name, is_primary, user_id, created_at, updated_at
		FROM walls
		WHERE id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	wall := &Wall{}
	err := m.DB.QueryRow(ctx, query, wallID).Scan(
		&wall.ID,
		&wall.Name,
		&wall.IsPrimary,
		&wall.UserID,
		&wall.CreatedAt,
		&wall.UpdatedAt,
	)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return wall, nil
}

func (m WallModel) FindAllForUser(userID int64) ([]*Wall, error) {
	query := `
		SELECT id, name, is_primary, user_id, created_at, updated_at
		FROM walls
		WHERE user_id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}

	walls, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*Wall, error) {
		var wall Wall
		err := rows.Scan(
			&wall.ID,
			&wall.Name,
			&wall.IsPrimary,
			&wall.UserID,
			&wall.CreatedAt,
			&wall.UpdatedAt,
		)
		return &wall, err
	})
	if err != nil {
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
	err := m.DB.QueryRow(ctx, query, userID).Scan(
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

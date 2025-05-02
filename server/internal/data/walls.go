package data

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/aravindmathradan/semaphore/internal/validator"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrDuplicateWall       = errors.New("user already owns a wall with same name")
	ErrDeletingPrimaryWall = errors.New("cannot delete primary wall")
	ErrDuplicatePinnedWall = errors.New("user already has another pinned wall")
)

type Wall struct {
	ID        int64      `json:"id"`
	Name      string     `json:"name"`
	IsPrimary bool       `json:"is_primary"`
	IsPinned  bool       `json:"is_pinned"`
	UserID    int64      `json:"user_id"`
	CreatedAt *time.Time `json:"created_at,omitempty"`
	UpdatedAt *time.Time `json:"updated_at,omitempty"`
}

type WallModel struct {
	DB *pgxpool.Pool
}

type WallWithFeedDTO struct {
	Wall
	Feeds []Feed `json:"feeds,omitempty"`
}

func ValidateWall(v *validator.Validator, wall *Wall) {
	v.Check(validator.NotBlank(wall.Name), "name", "Name must be provided")
	v.Check(validator.MaxChars(wall.Name, 36), "name", "Name must not be more than 36 characters long")
}

func (m WallModel) Insert(wall *Wall) error {
	query := `
		INSERT INTO walls (name, is_primary, is_pinned, user_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, updated_at`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, wall.Name, wall.IsPrimary, wall.IsPinned, wall.UserID).Scan(
		&wall.ID,
		&wall.CreatedAt,
		&wall.UpdatedAt,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "walls_non_primary_name_unique_idx") {
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
		SELECT id, name, is_primary, is_pinned, user_id, created_at, updated_at
		FROM walls
		WHERE id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	wall := &Wall{}
	err := m.DB.QueryRow(ctx, query, wallID).Scan(
		&wall.ID,
		&wall.Name,
		&wall.IsPrimary,
		&wall.IsPinned,
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

func (m WallModel) FindAllForUser(userID int64) ([]*WallWithFeedDTO, error) {
	query := `
		SELECT w.id, w.name, w.is_primary, w.is_pinned, w.user_id, w.created_at, w.updated_at,
		COALESCE(
			JSONB_AGG(JSONB_BUILD_OBJECT(
				'id', f.id,
				'title', f.title,
				'description', f.description,
				'link', f.link,
				'feed_link', f.feed_link,
				'pub_date', f.pub_date,
				'pub_updated', f.pub_updated,
				'feed_type', f.feed_type,
				'feed_version', f.feed_version,
				'language', f.language
			))
			FILTER (WHERE f.id IS NOT NULL), '[]'
		) as w_feeds	
		FROM walls w
		LEFT JOIN wall_feeds wf ON w.id = wf.wall_id
		LEFT JOIN feeds f ON wf.feed_id = f.id
		WHERE w.user_id = $1
		GROUP BY w.id
		ORDER BY w.is_pinned DESC, w.is_primary DESC, w.name ASC`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}

	walls, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (*WallWithFeedDTO, error) {
		var wall WallWithFeedDTO
		err := rows.Scan(
			&wall.ID,
			&wall.Name,
			&wall.IsPrimary,
			&wall.IsPinned,
			&wall.UserID,
			&wall.CreatedAt,
			&wall.UpdatedAt,
			&wall.Feeds,
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
		SELECT id, name, is_primary, is_pinned, user_id, created_at, updated_at
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
		&wall.IsPinned,
		&wall.UserID,
		&wall.CreatedAt,
		&wall.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return wall, nil
}

func (m WallModel) Update(wall *Wall) error {
	query := `
        UPDATE walls 
        SET name = $1, updated_at = $2
        WHERE id = $3 AND is_primary = false`

	args := []any{
		wall.Name,
		time.Now(),
		wall.ID,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, args...)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "walls_non_primary_name_unique_idx") {
				return ErrDuplicateWall
			}
		}
		return err
	}

	return nil
}

func (m WallModel) Delete(wallID int64) error {
	query := `
		DELETE FROM walls
		WHERE id = $1 AND is_primary = false
	`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, wallID)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			var isPrimary bool
			searchQuery := `
				SELECT is_primary
				FROM walls
				WHERE id = $1`
			err = m.DB.QueryRow(ctx, searchQuery, wallID).Scan(
				&isPrimary,
			)
			if err != nil {
				return err
			}
			if isPrimary {
				return ErrDeletingPrimaryWall
			}
			return ErrRecordNotFound
		default:
			return err
		}
	}
	return nil
}

func (m WallModel) Pin(wallID int64) error {
	// First unpin any currently pinned walls for this user
	query := `
		WITH current_wall AS (
			SELECT user_id
			FROM walls
			WHERE id = $1
		),
		update_pinned AS (
			UPDATE walls
			SET is_pinned = false, updated_at = NOW()
			WHERE user_id = (SELECT user_id FROM current_wall)
			AND is_pinned = true
		)
		UPDATE walls
		SET is_pinned = true, updated_at = NOW()
		WHERE id = $1
	`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, wallID)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return ErrRecordNotFound
		default:
			return err
		}
	}

	return nil
}

func (m WallModel) Unpin(wallID int64) error {
	query := `
		UPDATE walls
		SET is_pinned = false, updated_at = NOW()
		WHERE id = $1
	`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, wallID)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return ErrRecordNotFound
		default:
			return err
		}
	}

	return nil
}

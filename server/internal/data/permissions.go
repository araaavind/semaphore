package data

import (
	"context"
	"errors"
	"strconv"
	"strings"
	"time"

	"slices"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

const (
	PermissionAllAdmin    = "all:admin" // permission to administerate all resources
	PermissionFeedsRead   = "feeds:read"
	PermissionFeedsWrite  = "feeds:write"
	PermissionFeedsFollow = "feeds:follow"
)

type Permissions []string

func (p Permissions) Includes(code string) bool {
	return slices.Contains(p, code)
}

type PermissionModel struct {
	DB *pgxpool.Pool
}

func (m PermissionModel) AddForUser(userID int64, codes ...string) error {
	query := `
		INSERT INTO user_permissions
		select $1, permissions.id FROM permissions WHERE permissions.code = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, userID, codes)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "user_permissions_pkey") {
				return ErrUniqueConstraint
			}
		}
		return err
	}
	return nil
}

func (m PermissionModel) RemoveForUser(userID int64, permissions ...string) error {
	query := `
		DELETE FROM user_permissions
		WHERE user_id = $1 AND permission_id = ANY(
			SELECT id FROM permissions WHERE code = ANY($2)
		)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	result, err := m.DB.Exec(ctx, query, userID, permissions)
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrRecordNotFound
	}

	return nil
}

func (m PermissionModel) CreateIfNotExists(codes ...string) error {
	query := `
		INSERT INTO permissions (code)
		SELECT new_code FROM UNNEST($1::text[]) AS t(new_code)
		ON CONFLICT DO NOTHING`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.Exec(ctx, query, codes)
	if err != nil {
		return err
	}

	return nil
}

func (m PermissionModel) GetAllForUser(userID int64) (Permissions, error) {
	query := `
		SELECT permissions.code
		FROM permissions
		INNER JOIN user_permissions ON user_permissions.permission_id = permissions.id
		INNER JOIN users ON users.id = user_permissions.user_id
		WHERE users.id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}

	permissions, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (string, error) {
		var permission string
		err := row.Scan(&permission)
		return permission, err
	})
	if err != nil {
		return nil, err
	}

	return permissions, nil
}

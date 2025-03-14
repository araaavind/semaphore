package data

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Permissions []string

func (p Permissions) Includes(code string) bool {
	for i := range p {
		if code == p[i] {
			return true
		}
	}
	return false
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
	return err
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

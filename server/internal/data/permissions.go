package data

import (
	"context"
	"database/sql"
	"time"
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
	DB *sql.DB
}

func (m PermissionModel) AddForUser(userID int64, codes ...string) error {
	addPermissionForUserQuery := `
		INSERT INTO user_permissions
		select $1, permissions.id FROM permissions WHERE permissions.code = ANY($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.ExecContext(ctx, addPermissionForUserQuery, userID, codes)
	return err
}

func (m PermissionModel) GetAllForUser(userID int64) (Permissions, error) {
	getAllPermissionsForUserQuery := `
		SELECT permissions.code
		FROM permissions
		INNER JOIN user_permissions ON user_permissions.permission_id = permissions.id
		INNER JOIN users ON users.id = user_permissions.user_id
		WHERE users.id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, getAllPermissionsForUserQuery, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var permissions Permissions

	for rows.Next() {
		var permission string

		err := rows.Scan(&permission)
		if err != nil {
			return nil, err
		}

		permissions = append(permissions, permission)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return permissions, nil
}

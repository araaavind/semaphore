package data

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"errors"
	"time"
)

type Session struct {
	User  *User
	Token *Token
}

type SessionModel struct {
	DB *sql.DB
}

func (m SessionModel) GetForToken(tokenPlaintext string) (*Session, error) {
	tokenHash := sha256.Sum256([]byte(tokenPlaintext))

	query := `
		SELECT users.id, users.created_at, users.updated_at, users.full_name, users.username,
		users.email, users.password_hash, users.activated, users.last_login_at, users.version, tokens.hash, tokens.scope,
		tokens.expiry, tokens.created_at
		FROM users
		INNER JOIN tokens ON users.id = tokens.user_id
		WHERE tokens.hash = $1
		AND tokens.scope = $2
		AND tokens.expiry > $3`

	var session Session

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var user User
	var token Token
	err := m.DB.QueryRowContext(ctx, query, tokenHash[:], ScopeAuthentication, time.Now()).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.FullName,
		&user.Username,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.LastLoginAt,
		&user.Version,
		&token.Hash,
		&token.Scope,
		&token.Expiry,
		&token.CreatedAt,
	)
	session.User = &user
	session.Token = &token
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &session, nil
}

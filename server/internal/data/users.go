package data

import (
	"context"
	"crypto/sha256"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/aravindmathradan/semaphore/internal/validator"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrDuplicateEmail    = errors.New("duplicate email")
	ErrDuplicateUsername = errors.New("duplicate username")
)

type User struct {
	ID          int64              `json:"id"`
	CreatedAt   *time.Time         `json:"created_at,omitempty"`
	UpdatedAt   *time.Time         `json:"updated_at,omitempty"`
	FullName    string             `json:"full_name"`
	Username    string             `json:"username"`
	Email       string             `json:"email,omitempty"`
	Password    password           `json:"-"`
	Activated   bool               `json:"activated,omitempty"`
	Version     int                `json:"-"`
	LastLoginAt pgtype.Timestamptz `json:"last_login_at,omitempty"`
}

type password struct {
	// using pointer instead of string for plaintext to distinguish between
	// password not provided and password being empty string "".
	plaintext *string
	hash      []byte
}

func (p *password) Set(plaintextPassword string) error {
	hash, err := bcrypt.GenerateFromPassword([]byte(plaintextPassword), 12)
	if err != nil {
		return err
	}

	p.plaintext = &plaintextPassword
	p.hash = hash

	return nil
}

func (p *password) SetOAuthPasswordPlaceholder() {
	// Use a minimal valid bcrypt hash that won't match any password
	p.hash = []byte("$2a$10$************************")
	p.plaintext = nil
}

func (p *password) Matches(plaintextPassword string) (bool, error) {
	err := bcrypt.CompareHashAndPassword(p.hash, []byte(plaintextPassword))
	if err != nil {
		switch {
		case errors.Is(err, bcrypt.ErrMismatchedHashAndPassword):
			return false, nil
		default:
			return false, err
		}
	}
	return true, err
}

func ValidateUsername(v *validator.Validator, username string) {
	v.Check(validator.NotBlank(username), "username", "Username must be provided")
	v.Check(validator.MinChars(username, 8), "username", "Username must be atleast 8 characters long")
	v.Check(validator.MaxChars(username, 16), "username", "Username must not be more than 16 characters long")
	v.Check(
		validator.Matches(username, validator.UsernameBasicRX),
		"username",
		`Username must contain only alphanumeric characters, dots and dashes`,
	)

	forbiddenPrefixes := []string{".", "_"}
	v.Check(
		validator.SafePrefix(username, forbiddenPrefixes...),
		"username",
		`Username must not start with "." or "_"`,
	)

	forbiddenSuffixes := []string{".", "_"}
	v.Check(
		validator.SafeSuffix(username, forbiddenSuffixes...),
		"username",
		`Username must not end with "." or "_"`,
	)

	forbiddenSubstrings := []string{"..", "__", "._", "_."}
	v.Check(
		validator.SafeSubstrings(username, forbiddenSubstrings...),
		"username",
		`Username must not contain consecutive "." or "_" or a combination of those`,
	)
}

func ValidateEmail(v *validator.Validator, email string) {
	v.Check(validator.NotBlank(email), "email", "Email must be provided")
	v.Check(validator.Matches(email, validator.EmailRX), "email", "Email must be a valid email address")
}

func ValidatePasswordPlaintext(v *validator.Validator, password string) {
	v.Check(validator.NotBlank(password), "password", "Password must be provided")
	v.Check(validator.MinChars(password, 8), "password", "Password must be at least 8 characters long")
	v.Check(validator.MaxChars(password, 72), "password", "Password must not be more than 72 characters long")
	v.Check(validator.Matches(password, validator.HasLowerRX), "password", "Password must have atleast 1 lower-case character")
	v.Check(validator.Matches(password, validator.HasUpperRX), "password", "Password must have atleast 1 upper-case character")
	v.Check(validator.Matches(password, validator.HasSpecialRX), "password", "Password must have atleast 1 special character (! @ # $ & *)")
	v.Check(validator.Matches(password, validator.HasDigitRX), "password", "Password must have atleast 1 numeric character")
}

func ValidateUser(v *validator.Validator, user *User) {
	v.Check(validator.NotBlank(user.FullName), "full_name", "Full name must be provided")
	v.Check(validator.MaxChars(user.FullName, 100), "full_name", "Full name must not be more than 100 characters long")

	ValidateUsername(v, user.Username)
	ValidateEmail(v, user.Email)

	if user.Password.plaintext != nil {
		ValidatePasswordPlaintext(v, *user.Password.plaintext)
	}

	// If the password hash is ever nil, this will be due to a logic error in our
	// codebase (probably because we forgot to set a password for the user). It's a
	// useful sanity check to include here, but it's not a problem with the data
	// provided by the client. So rather than adding an error to the validation map we
	// raise a panic instead.
	if user.Password.hash == nil {
		panic("missing password hash for user")
	}
}

var AnonymousUser = &User{}

func (u *User) IsAnonymous() bool {
	return u == AnonymousUser
}

type UserModel struct {
	DB *pgxpool.Pool
}

func (m UserModel) Insert(user *User) error {
	query := `
		INSERT INTO users (full_name, username, email, password_hash, activated) 
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, last_login_at, created_at, updated_at, version`

	args := []any{user.FullName, user.Username, user.Email, user.Password.hash, user.Activated}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, args...).Scan(&user.ID, &user.LastLoginAt, &user.CreatedAt, &user.UpdatedAt, &user.Version)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "users_email_key") {
				return ErrDuplicateEmail
			} else if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "users_username_key") {
				return ErrDuplicateUsername
			}
		}
		return err
	}
	return nil
}

func (m UserModel) GetByID(id int64) (*User, error) {
	query := `
		SELECT id, created_at, updated_at, full_name, username, email, activated, last_login_at, version
		FROM users
		WHERE id = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, id).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.FullName,
		&user.Username,
		&user.Email,
		&user.Activated,
		&user.LastLoginAt,
		&user.Version,
	)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) GetByEmail(email string) (*User, error) {
	query := `
        SELECT id, created_at, updated_at, full_name, username, email, password_hash, activated, last_login_at, version
        FROM users
        WHERE email = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, email).Scan(
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
	)

	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) GetByUsername(username string) (*User, error) {
	query := `
        SELECT id, created_at, updated_at, full_name, username, email, password_hash, activated, last_login_at, version
        FROM users
        WHERE username = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, username).Scan(
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
	)

	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) GetForToken(scope, tokenPlaintext string) (*User, error) {
	tokenHash := sha256.Sum256([]byte(tokenPlaintext))

	query := `
		SELECT users.id, users.created_at, users.updated_at, users.full_name, users.username,
		users.email, users.password_hash, users.activated, users.last_login_at, users.version
		FROM users
		INNER JOIN tokens ON users.id = tokens.user_id
		WHERE tokens.hash = $1
		AND tokens.scope = $2
		AND tokens.expiry > $3`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, tokenHash[:], scope, time.Now()).Scan(
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
	)
	if err != nil {
		switch {
		case errors.Is(err, pgx.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) CountByUsername(username string) (int, error) {
	query := `
        SELECT count(1)
        FROM users
        WHERE username = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	count := 0
	err := m.DB.QueryRow(ctx, query, username).Scan(&count)

	if err != nil {
		return -1, err
	}

	return count, nil
}

func (m UserModel) Update(user *User) error {
	query := `
        UPDATE users 
        SET full_name = $1, username = $2, email = $3, password_hash = $4, activated = $5, updated_at = $6,
		last_login_at = $7, version = version + 1
        WHERE id = $8 AND version = $9
        RETURNING version`

	args := []any{
		user.FullName,
		user.Username,
		user.Email,
		user.Password.hash,
		user.Activated,
		time.Now(),
		user.LastLoginAt,
		user.ID,
		user.Version,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRow(ctx, query, args...).Scan(&user.Version)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "users_email_key") {
				return ErrDuplicateEmail
			} else if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "users_username_key") {
				return ErrDuplicateUsername
			}
		} else if errors.Is(err, pgx.ErrNoRows) {
			return ErrEditConflict
		}
		return err
	}

	return nil
}

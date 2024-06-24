package data

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"errors"
	"strconv"
	"strings"
	"time"

	"github.com/aravindmathradan/semaphore/internal/validator"
	"github.com/jackc/pgx/v5/pgconn"
	"golang.org/x/crypto/bcrypt"
)

var (
	ErrDuplicateEmail    = errors.New("duplicate email")
	ErrDuplicateUsername = errors.New("duplicate username")
)

type User struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	FullName  string    `json:"full_name"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Password  password  `json:"-"`
	Activated bool      `json:"activated"`
	Version   int       `json:"-"`
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
	v.Check(validator.NotBlank(username), "username", "must be provided")
	v.Check(validator.MinChars(username, 8), "username", "must be atleast 8 characters long")
	v.Check(validator.MaxChars(username, 16), "username", "must not be more than 16 characters long")
	v.Check(validator.Matches(username, validator.UsernameBasicRX), "username", `username must contain only alphanumeric characters, "." and "_"`)

	forbiddenPrefixes := []string{".", "_"}
	v.Check(
		validator.SafePrefix(username, forbiddenPrefixes...),
		"username",
		`must not start with "." or "_"`,
	)

	forbiddenSuffixes := []string{".", "_"}
	v.Check(
		validator.SafeSuffix(username, forbiddenSuffixes...),
		"username",
		`must not end with "." or "_"`,
	)

	forbiddenSubstrings := []string{"..", "__", "._", "_."}
	v.Check(
		validator.SafeSubstrings(username, forbiddenSubstrings...),
		"username",
		`must not contain consecutive "." or "_" or a combination of those`,
	)
}

func ValidateEmail(v *validator.Validator, email string) {
	v.Check(validator.NotBlank(email), "email", "must be provided")
	v.Check(validator.Matches(email, validator.EmailRX), "email", "must be a valid email address")
}

func ValidatePasswordPlaintext(v *validator.Validator, password string) {
	v.Check(validator.NotBlank(password), "password", "must be provided")
	v.Check(validator.MinChars(password, 8), "password", "must be at least 8 bytes long")
	v.Check(validator.MaxChars(password, 72), "password", "must not be more than 72 bytes long")
}

func ValidateUser(v *validator.Validator, user *User) {
	v.Check(validator.NotBlank(user.FullName), "full_name", "must be provided")
	v.Check(validator.MaxChars(user.FullName, 100), "full_name", "must not be more than 100 characters long")

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

type UserModel struct {
	DB *sql.DB
}

func (m UserModel) Insert(user *User) error {
	insertUserQuery := `
		INSERT INTO users (full_name, username, email, password_hash, activated) 
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at, updated_at, version`

	args := []any{user.FullName, user.Username, user.Email, user.Password.hash, user.Activated}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, insertUserQuery, args...).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt, &user.Version)
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
	getUserByIDQuery := `
		SELECT id, created_at, updated_at, full_name, username, email, activated, version
		FROM users
		WHERE id = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, getUserByIDQuery, id).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.FullName,
		&user.Username,
		&user.Email,
		&user.Activated,
		&user.Version,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) GetByEmail(email string) (*User, error) {
	getUserByEmailQuery := `
        SELECT id, created_at, updated_at, full_name, username, email, password_hash, activated, version
        FROM users
        WHERE email = $1`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, getUserByEmailQuery, email).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.FullName,
		&user.Username,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
	)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) GetForToken(scope, tokenPlaintext string) (*User, error) {
	tokenHash := sha256.Sum256([]byte(tokenPlaintext))

	getUserForTokenQuery := `
		SELECT users.id, users.created_at, users.updated_at, users.full_name, users.username, users.email, users.password_hash, users.activated, users.version
		FROM users
		INNER JOIN tokens ON users.id = tokens.user_id
		WHERE tokens.hash = $1
		AND tokens.scope = $2
		AND tokens.expiry > $3`

	var user User

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, getUserForTokenQuery, tokenHash[:], scope, time.Now()).Scan(
		&user.ID,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.FullName,
		&user.Username,
		&user.Email,
		&user.Password.hash,
		&user.Activated,
		&user.Version,
	)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}

	return &user, nil
}

func (m UserModel) Update(user *User) error {
	updateUserQuery := `
        UPDATE users 
        SET full_name = $1, username = $2, email = $3, password_hash = $4, activated = $5, updated_at = $6, version = version + 1
        WHERE id = $7 AND version = $8
        RETURNING version`

	args := []any{
		user.FullName,
		user.Username,
		user.Email,
		user.Password.hash,
		user.Activated,
		time.Now(),
		user.ID,
		user.Version,
	}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	err := m.DB.QueryRowContext(ctx, updateUserQuery, args...).Scan(&user.Version)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "users_email_key") {
				return ErrDuplicateEmail
			} else if pgErr.Code == strconv.Itoa(23505) && strings.Contains(pgErr.ConstraintName, "users_username_key") {
				return ErrDuplicateUsername
			}
		} else if errors.Is(err, sql.ErrNoRows) {
			return ErrEditConflict
		}
		return err
	}

	return nil
}

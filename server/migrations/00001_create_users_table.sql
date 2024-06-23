-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS users (
	id bigserial PRIMARY KEY,
    full_name text NOT NULL,
	username text NOT NULL,
	email citext UNIQUE NOT NULL,
	password_hash bytea NOT NULL,
    activated bool NOT NULL,
	version integer NOT NULL DEFAULT 1,
	created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
	updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
)
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS users;
-- +goose StatementEnd

-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS users (
	id bigserial PRIMARY KEY,
    full_name text NOT NULL,
	username citext UNIQUE NOT NULL,
	email citext UNIQUE NOT NULL,
	password_hash bytea NOT NULL,
    activated bool NOT NULL,
	version integer NOT NULL DEFAULT 1,
	created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
	updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS users_id_idx ON user(id);
CREATE INDEX IF NOT EXISTS users_full_name_idx ON user(full_name);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS users_full_name_idx;
DROP INDEX IF EXISTS users_id_idx;
DROP TABLE IF EXISTS users;
-- +goose StatementEnd

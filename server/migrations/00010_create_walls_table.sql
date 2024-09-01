-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS walls (
    id bigserial PRIMARY KEY,
    name text NOT NULL,
    is_primary bool NOT NULL DEFAULT false,
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);

-- Add a partial unique index to enforce a single primary wall per user
CREATE UNIQUE INDEX IF NOT EXISTS walls_user_primary_unique_idx
ON walls (user_id)
WHERE is_primary = true;

CREATE INDEX IF NOT EXISTS walls_user_non_primary_idx
ON walls (user_id)
WHERE is_primary = false;

-- Add a partial unique index to enforce unique names for non-primary walls per user
CREATE UNIQUE INDEX IF NOT EXISTS walls_non_primary_name_unique_idx
ON walls (user_id, name)
WHERE is_primary = false;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS walls_non_primary_name_unique_idx;
DROP INDEX IF EXISTS walls_user_non_primary_idx;
DROP INDEX IF EXISTS walls_user_primary_unique_idx;
DROP TABLE IF EXISTS walls;
-- +goose StatementEnd

-- +goose Up
-- +goose StatementBegin
ALTER TABLE feeds ADD COLUMN followers_count integer NOT NULL DEFAULT 0;
ALTER TABLE feeds ADD COLUMN is_private bool NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS feeds_followers_count_idx ON feeds(followers_count DESC);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS feeds_followers_count_idx;

ALTER TABLE feeds DROP COLUMN is_private;
ALTER TABLE feeds DROP COLUMN followers_count;
-- +goose StatementEnd 
-- +goose Up
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS feeds_title_idx ON feeds USING GIN (to_tsvector('simple', title));
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS feeds_title_idx;
-- +goose StatementEnd

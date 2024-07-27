-- +goose Up
-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS feeds_title_idx ON feeds USING GIN (to_tsvector('simple', title));
CREATE INDEX IF NOT EXISTS feeds_id_idx ON feeds(id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS feeds_id_idx;
DROP INDEX IF EXISTS feeds_title_idx;
-- +goose StatementEnd

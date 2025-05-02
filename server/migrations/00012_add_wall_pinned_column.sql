-- +goose Up
-- +goose StatementBegin
ALTER TABLE walls
ADD COLUMN is_pinned bool NOT NULL DEFAULT false;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE walls
DROP COLUMN is_pinned;
-- +goose StatementEnd

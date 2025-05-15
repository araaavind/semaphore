-- +goose Up
-- +goose StatementBegin
ALTER TABLE feeds ADD COLUMN image_url text DEFAULT NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE feeds DROP COLUMN image_url;
-- +goose StatementEnd 
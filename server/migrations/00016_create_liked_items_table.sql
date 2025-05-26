-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS liked_items (
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    item_id bigint NOT NULL REFERENCES items ON DELETE CASCADE,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, item_id)
);

CREATE INDEX IF NOT EXISTS liked_items_user_id_idx ON liked_items (user_id);
CREATE INDEX IF NOT EXISTS liked_items_item_id_idx ON liked_items (item_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS liked_items_item_id_idx;
DROP INDEX IF EXISTS liked_items_user_id_idx;
DROP TABLE IF EXISTS liked_items;
-- +goose StatementEnd 
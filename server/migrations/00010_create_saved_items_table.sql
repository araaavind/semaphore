-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS saved_items (
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    item_id bigint NOT NULL REFERENCES items ON DELETE CASCADE,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, item_id)
);

CREATE INDEX saved_items_user_id_idx ON saved_items (user_id);
CREATE INDEX saved_items_item_id_idx ON saved_items (item_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS saved_items_item_id_idx;
DROP INDEX IF EXISTS saved_items_user_id_idx;
DROP TABLE IF EXISTS saved_items;
-- +goose StatementEnd 
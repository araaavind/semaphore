-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS wall_feeds (
    wall_id bigint NOT NULL REFERENCES walls ON DELETE CASCADE,
    feed_id bigint NOT NULL REFERENCES feeds ON DELETE CASCADE,
    PRIMARY KEY(wall_id, feed_id),
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS wall_feeds_wall_id_idx ON wall_feeds(wall_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS wall_feeds_wall_id_idx;
DROP TABLE IF EXISTS wall_feeds;
-- +goose StatementEnd

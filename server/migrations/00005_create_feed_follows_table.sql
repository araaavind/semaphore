-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS feed_follows (
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    feed_id bigint NOT NULL REFERENCES feeds ON DELETE CASCADE,
    PRIMARY KEY(user_id, feed_id),
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
	updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS feed_follows_user_id_idx ON feed_follows(user_id);
CREATE INDEX IF NOT EXISTS feed_follows_feed_id_idx ON feed_follows(feed_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS feed_follows_feed_id_idx;
DROP INDEX IF EXISTS feed_follows_user_id_idx;
DROP TABLE IF EXISTS feed_follows;
-- +goose StatementEnd

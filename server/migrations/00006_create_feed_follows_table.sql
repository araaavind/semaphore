-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS feed_follows (
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    feed_id bigint NOT NULL REFERENCES feeds ON DELETE CASCADE,
    PRIMARY KEY(user_id, feed_id),
    priority integer NOT NULL DEFAULT 5,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);

ALTER TABLE feed_follows
    ADD CONSTRAINT feed_follows_priority_check CHECK (priority >= 1 AND priority <= 10);

CREATE INDEX IF NOT EXISTS feed_follows_user_id_idx ON feed_follows(user_id);
CREATE INDEX IF NOT EXISTS feed_follows_feed_id_idx ON feed_follows(feed_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS feed_follows_feed_id_idx;
DROP INDEX IF EXISTS feed_follows_user_id_idx;

ALTER TABLE feed_follows DROP CONSTRAINT IF EXISTS feed_follows_priority_check;

DROP TABLE IF EXISTS feed_follows;
-- +goose StatementEnd

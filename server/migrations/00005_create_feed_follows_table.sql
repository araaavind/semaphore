-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS feed_follows (
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    feed_id bigint NOT NULL REFERENCES feeds ON DELETE CASCADE,
    PRIMARY KEY(user_id, feed_id),
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
	updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
)
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS feed_follows;
-- +goose StatementEnd

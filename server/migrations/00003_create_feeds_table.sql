-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS feeds (
    id bigserial PRIMARY KEY,  
    title text NOT NULL,
    description text NOT NULL,
    link text NOT NULL,
    feed_link text NOT NULL UNIQUE,
    pub_date timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    pub_updated timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    feed_type text NOT NULL DEFAULT 'rss',
    feed_version text NOT NULL DEFAULT '2.0',
    language text NOT NULL DEFAULT 'en-us',
    version integer NOT NULL DEFAULT 1,
    added_by bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    last_fetch_at timestamp(0) with time zone,
    last_failure text,
    last_failure_at timestamp(0) with time zone,
    failure_count integer NOT NULL DEFAULT 0,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS feeds;
-- +goose StatementEnd

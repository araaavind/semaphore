-- +goose Up
-- +goose StatementBegin

CREATE TYPE feed_type_enum AS ENUM ('website', 'medium', 'reddit', 'youtube', 'substack', 'podcast');
CREATE TYPE owner_type_enum AS ENUM ('personal', 'organization');
CREATE TYPE feed_format_enum AS ENUM ('rss', 'atom', 'json', 'iota');

CREATE TABLE IF NOT EXISTS feeds (
    id bigserial PRIMARY KEY,
    display_title text,
    title text NOT NULL,
    description text NOT NULL,
    link text NOT NULL,
    feed_link text NOT NULL UNIQUE,
    pub_date timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    pub_updated timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    feed_type feed_type_enum NOT NULL DEFAULT 'website',
    owner_type owner_type_enum NOT NULL DEFAULT 'organization',
    feed_format feed_format_enum NOT NULL DEFAULT 'rss',
    feed_version text NOT NULL DEFAULT '2.0',
    image_url text,
    topic_id bigint REFERENCES topics(id),
    language text NOT NULL DEFAULT 'en-us',
    version integer NOT NULL DEFAULT 1,
    added_by bigint REFERENCES users ON DELETE CASCADE,
    last_fetch_at timestamp(0) with time zone,
    last_failure text,
    last_failure_at timestamp(0) with time zone,
    failure_count integer NOT NULL DEFAULT 0,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS feeds_title_idx ON feeds USING GIN (to_tsvector('simple', title));
CREATE INDEX IF NOT EXISTS feeds_id_idx ON feeds(id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS feeds_id_idx;
DROP INDEX IF EXISTS feeds_title_idx;

DROP TABLE IF EXISTS feeds;

DROP TYPE feed_type_enum;
DROP TYPE owner_type_enum;
DROP TYPE feed_format_enum;
-- +goose StatementEnd

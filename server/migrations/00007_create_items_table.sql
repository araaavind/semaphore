-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS items (
    id bigserial PRIMARY KEY,  
    title text NOT NULL,
    description text NOT NULL,
    content text,
    link text NOT NULL,
    pub_date timestamp(0) with time zone,
    pub_updated timestamp(0) with time zone,
    guid text NOT NULL,
    authors jsonb,
    image_url text,
    categories text[],
    enclosures jsonb,
    version integer NOT NULL DEFAULT 1,
    feed_id bigint NOT NULL REFERENCES feeds ON DELETE CASCADE,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    UNIQUE(feed_id, link),
    UNIQUE(feed_id, guid)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS items;
-- +goose StatementEnd

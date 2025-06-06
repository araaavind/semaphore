-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS topics (
    id bigserial PRIMARY KEY,
    code text NOT NULL UNIQUE,
    name text NOT NULL,
    featured boolean NOT NULL DEFAULT false,
    active boolean NOT NULL DEFAULT true,
    image_url text,
    color text,
    keywords text[],
    version integer NOT NULL DEFAULT 1,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    updated_at timestamp(0) with time zone NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subtopics (
    parent_id bigint REFERENCES topics(id) ON DELETE CASCADE,
    child_id bigint REFERENCES topics(id) ON DELETE CASCADE,
    PRIMARY KEY (parent_id, child_id)
);

CREATE INDEX IF NOT EXISTS subtopics_parent_id_idx ON subtopics(parent_id);
CREATE INDEX IF NOT EXISTS subtopics_child_id_idx ON subtopics(child_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS subtopics_parent_id_idx;
DROP INDEX IF EXISTS subtopics_child_id_idx;

DROP TABLE IF EXISTS subtopics;

DROP TABLE IF EXISTS topics;
-- +goose StatementEnd

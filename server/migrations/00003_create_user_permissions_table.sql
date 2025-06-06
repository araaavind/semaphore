-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS permissions (
    id bigserial PRIMARY KEY,
    code text NOT NULL
);

CREATE TABLE IF NOT EXISTS user_permissions (
    user_id bigint NOT NULL REFERENCES users ON DELETE CASCADE,
    permission_id bigint NOT NULL REFERENCES permissions ON DELETE CASCADE,
    PRIMARY KEY (user_id, permission_id)
);

INSERT INTO permissions (code)
VALUES 
    ('feeds:read'),
    ('feeds:write'),
    ('feeds:follow');
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM permissions
WHERE code IN (
    'feeds:read',
    'feeds:write',
    'feeds:follow'
);

DROP TABLE IF EXISTS user_permissions;
DROP TABLE IF EXISTS permissions;
-- +goose StatementEnd

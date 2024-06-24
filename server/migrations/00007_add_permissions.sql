-- +goose Up
-- +goose StatementBegin
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
-- +goose StatementEnd

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    password_salt TEXT NOT NULL,
    role TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT
);

INSERT INTO users (
    username,
    display_name,
    password_hash,
    password_salt,
    role,
    is_active,
    created_at
)
SELECT
    'admin',
    'Administrator',
    'b8071d0b5bb7b26e8b83d9fe00e6c5b3a1bdb533f9933344c2d1b5a8dce3c3ab',
    '9f7c4a2e6b1d48f3a0c5e8d2b7f94136',
    'Admin',
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE username = 'admin'
);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.2.0', 'Create users and demo administrator', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.2.0'
);

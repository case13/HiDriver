CREATE TABLE IF NOT EXISTS schema_version (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    version TEXT NOT NULL,
    description TEXT NOT NULL,
    applied_at TEXT NOT NULL
);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.1.0', 'Initial database structure', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.1.0'
);

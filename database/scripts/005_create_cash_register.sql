CREATE TABLE IF NOT EXISTS cash_registers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    status TEXT NOT NULL,
    opening_amount REAL NOT NULL DEFAULT 0,
    closing_amount REAL,
    expected_amount REAL,
    difference_amount REAL,
    opened_at TEXT NOT NULL,
    closed_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_cash_registers_status
    ON cash_registers(status);
CREATE INDEX IF NOT EXISTS idx_cash_registers_user_id
    ON cash_registers(user_id);
CREATE INDEX IF NOT EXISTS idx_cash_registers_opened_at
    ON cash_registers(opened_at);

CREATE TABLE IF NOT EXISTS cash_movements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cash_register_id INTEGER NOT NULL,
    movement_type TEXT NOT NULL,
    description TEXT NOT NULL,
    amount REAL NOT NULL,
    payment_method TEXT,
    reference_type TEXT,
    reference_id INTEGER,
    created_at TEXT NOT NULL,
    FOREIGN KEY (cash_register_id) REFERENCES cash_registers(id)
);

CREATE INDEX IF NOT EXISTS idx_cash_movements_cash_register_id
    ON cash_movements(cash_register_id);
CREATE INDEX IF NOT EXISTS idx_cash_movements_movement_type
    ON cash_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_cash_movements_created_at
    ON cash_movements(created_at);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.5.0', 'Create cash registers and movements', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.5.0'
);

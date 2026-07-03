CREATE TABLE IF NOT EXISTS stock_movements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    movement_date TEXT NOT NULL,
    movement_type TEXT NOT NULL
        CHECK (movement_type IN ('In', 'Out', 'Adjustment', 'Reversal')),
    source_type TEXT NOT NULL
        CHECK (source_type IN (
            'Sale',
            'SaleCancellation',
            'ManualAdjustment',
            'InitialBalance'
        )),
    source_id INTEGER,
    quantity NUMERIC NOT NULL,
    previous_stock NUMERIC NOT NULL,
    new_stock NUMERIC NOT NULL CHECK (new_stock >= 0),
    unit_cost NUMERIC,
    notes TEXT,
    user_id INTEGER,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_product_date
    ON stock_movements(product_id, movement_date DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_stock_movements_movement_date
    ON stock_movements(movement_date DESC);
CREATE INDEX IF NOT EXISTS idx_stock_movements_movement_type
    ON stock_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_stock_movements_source
    ON stock_movements(source_type, source_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_is_active
    ON stock_movements(is_active);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.8.0', 'Create stock movement history', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.8.0'
);

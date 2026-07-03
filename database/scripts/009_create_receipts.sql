CREATE TABLE IF NOT EXISTS receipts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    receipt_number TEXT NOT NULL,
    source_type TEXT NOT NULL
        CHECK (source_type IN ('Sale', 'AccountReceivablePayment')),
    source_id INTEGER NOT NULL,
    customer_id INTEGER,
    customer_name TEXT,
    customer_document TEXT,
    issue_date TEXT NOT NULL,
    subtotal_amount NUMERIC NOT NULL,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    total_amount NUMERIC NOT NULL,
    payment_summary TEXT,
    notes TEXT,
    status TEXT NOT NULL
        CHECK (status IN ('Issued', 'Canceled')),
    created_by_user_id INTEGER,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (created_by_user_id) REFERENCES users(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipts_number
    ON receipts(receipt_number);
CREATE UNIQUE INDEX IF NOT EXISTS idx_receipts_issued_source
    ON receipts(source_type, source_id)
    WHERE is_active = 1 AND status = 'Issued';
CREATE INDEX IF NOT EXISTS idx_receipts_source
    ON receipts(source_type, source_id);
CREATE INDEX IF NOT EXISTS idx_receipts_customer_id
    ON receipts(customer_id);
CREATE INDEX IF NOT EXISTS idx_receipts_issue_date
    ON receipts(issue_date DESC);
CREATE INDEX IF NOT EXISTS idx_receipts_status_active
    ON receipts(status, is_active);

CREATE TABLE IF NOT EXISTS receipt_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    receipt_id INTEGER NOT NULL,
    product_id INTEGER,
    description TEXT NOT NULL,
    quantity NUMERIC NOT NULL,
    unit_price NUMERIC NOT NULL,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    total_amount NUMERIC NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (receipt_id) REFERENCES receipts(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX IF NOT EXISTS idx_receipt_items_receipt_id
    ON receipt_items(receipt_id);
CREATE INDEX IF NOT EXISTS idx_receipt_items_product_id
    ON receipt_items(product_id);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.9.0', 'Create receipts and receipt items', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.9.0'
);

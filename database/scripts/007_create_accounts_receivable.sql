CREATE TABLE IF NOT EXISTS accounts_receivable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    issue_date TEXT NOT NULL,
    due_date TEXT,
    total_amount NUMERIC NOT NULL,
    received_amount NUMERIC NOT NULL DEFAULT 0,
    balance_amount NUMERIC NOT NULL,
    status TEXT NOT NULL,
    notes TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_accounts_receivable_sale_id
    ON accounts_receivable(sale_id);
CREATE INDEX IF NOT EXISTS idx_accounts_receivable_customer_id
    ON accounts_receivable(customer_id);
CREATE INDEX IF NOT EXISTS idx_accounts_receivable_status
    ON accounts_receivable(status);
CREATE INDEX IF NOT EXISTS idx_accounts_receivable_is_active
    ON accounts_receivable(is_active);

CREATE TABLE IF NOT EXISTS account_receivable_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_receivable_id INTEGER NOT NULL,
    cash_register_id INTEGER NOT NULL,
    cash_movement_id INTEGER,
    payment_date TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    interest_amount NUMERIC NOT NULL DEFAULT 0,
    total_received NUMERIC NOT NULL,
    notes TEXT,
    created_at TEXT NOT NULL,
    FOREIGN KEY (account_receivable_id) REFERENCES accounts_receivable(id),
    FOREIGN KEY (cash_register_id) REFERENCES cash_registers(id),
    FOREIGN KEY (cash_movement_id) REFERENCES cash_movements(id)
);

CREATE INDEX IF NOT EXISTS idx_ar_payments_account_id
    ON account_receivable_payments(account_receivable_id);
CREATE INDEX IF NOT EXISTS idx_ar_payments_cash_register_id
    ON account_receivable_payments(cash_register_id);
CREATE INDEX IF NOT EXISTS idx_ar_payments_payment_date
    ON account_receivable_payments(payment_date);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.7.0', 'Create accounts receivable and payment history', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.7.0'
);

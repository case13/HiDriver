CREATE TABLE IF NOT EXISTS sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    cash_register_id INTEGER NOT NULL,
    sale_date TEXT NOT NULL,
    subtotal_amount REAL NOT NULL DEFAULT 0,
    discount_amount REAL NOT NULL DEFAULT 0,
    total_amount REAL NOT NULL DEFAULT 0,
    status TEXT NOT NULL,
    notes TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    canceled_at TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (cash_register_id) REFERENCES cash_registers(id)
);

CREATE INDEX IF NOT EXISTS idx_sales_customer_id
    ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_cash_register_id
    ON sales(cash_register_id);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date
    ON sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_status
    ON sales(status);

CREATE TABLE IF NOT EXISTS sale_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_description TEXT NOT NULL,
    quantity REAL NOT NULL,
    unit_price REAL NOT NULL,
    discount_amount REAL NOT NULL DEFAULT 0,
    total_amount REAL NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id
    ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id
    ON sale_items(product_id);

CREATE TABLE IF NOT EXISTS sale_payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_id INTEGER NOT NULL,
    payment_method TEXT NOT NULL,
    amount REAL NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id)
);

CREATE INDEX IF NOT EXISTS idx_sale_payments_sale_id
    ON sale_payments(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_payments_payment_method
    ON sale_payments(payment_method);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.6.0', 'Create sales, items and payments', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.6.0'
);

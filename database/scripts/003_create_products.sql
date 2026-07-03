CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    internal_code TEXT NOT NULL UNIQUE,
    barcode TEXT,
    original_code TEXT,
    description TEXT NOT NULL,
    brand_name TEXT,
    category_name TEXT,
    vehicle_application TEXT,
    current_stock REAL NOT NULL DEFAULT 0,
    minimum_stock REAL NOT NULL DEFAULT 0,
    cost_price REAL NOT NULL DEFAULT 0,
    sale_price REAL NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_products_description
    ON products(description);
CREATE INDEX IF NOT EXISTS idx_products_internal_code
    ON products(internal_code);
CREATE INDEX IF NOT EXISTS idx_products_barcode
    ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_is_active
    ON products(is_active);

INSERT INTO products (
    internal_code,
    barcode,
    original_code,
    description,
    brand_name,
    category_name,
    vehicle_application,
    current_stock,
    minimum_stock,
    cost_price,
    sale_price,
    is_active,
    created_at
)
SELECT
    'PAST-FREIO-001',
    '7891000000011',
    'ABC-1234',
    'Front Brake Pad',
    'Bosch',
    'Brake System',
    'Gol / Voyage / Saveiro 1.6 2013-2018',
    12,
    3,
    85.00,
    149.90,
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM products WHERE internal_code = 'PAST-FREIO-001'
);

INSERT INTO products (
    internal_code,
    barcode,
    original_code,
    description,
    brand_name,
    category_name,
    vehicle_application,
    current_stock,
    minimum_stock,
    cost_price,
    sale_price,
    is_active,
    created_at
)
SELECT
    'OLEO-5W30-001',
    '7891000000028',
    '5W30-SYN',
    'Synthetic Engine Oil 5W30',
    'Mobil',
    'Lubricants',
    'Multi-vehicle application',
    24,
    6,
    32.00,
    59.90,
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM products WHERE internal_code = 'OLEO-5W30-001'
);

INSERT INTO products (
    internal_code,
    barcode,
    original_code,
    description,
    brand_name,
    category_name,
    vehicle_application,
    current_stock,
    minimum_stock,
    cost_price,
    sale_price,
    is_active,
    created_at
)
SELECT
    'FILT-OLEO-001',
    '7891000000035',
    'FO-987',
    'Oil Filter',
    'Tecfil',
    'Filters',
    'Fiat Palio / Uno / Siena 1.0 2010-2017',
    18,
    5,
    18.00,
    34.90,
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM products WHERE internal_code = 'FILT-OLEO-001'
);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.3.0', 'Create products and demo catalog', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.3.0'
);

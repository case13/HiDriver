CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    document TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_customers_name
    ON customers(name);
CREATE INDEX IF NOT EXISTS idx_customers_document
    ON customers(document);
CREATE INDEX IF NOT EXISTS idx_customers_is_active
    ON customers(is_active);

INSERT INTO customers (
    name,
    document,
    phone,
    email,
    address,
    city,
    state,
    zip_code,
    is_active,
    created_at
)
SELECT
    'João Silva',
    '12345678901',
    '5591999991001',
    'joao.silva@example.com',
    'Rua das Oficinas, 100',
    'Belém',
    'PA',
    '66000000',
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM customers WHERE document = '12345678901'
);

INSERT INTO customers (
    name,
    document,
    phone,
    email,
    address,
    city,
    state,
    zip_code,
    is_active,
    created_at
)
SELECT
    'Maria Oliveira',
    '98765432100',
    '5591999991002',
    'maria.oliveira@example.com',
    'Avenida das Peças, 200',
    'Castanhal',
    'PA',
    '68740000',
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM customers WHERE document = '98765432100'
);

INSERT INTO customers (
    name,
    document,
    phone,
    email,
    address,
    city,
    state,
    zip_code,
    is_active,
    created_at
)
SELECT
    'Auto Center Demo Ltda',
    '12345678000199',
    '5591999991003',
    'contato@autocenterdemo.com',
    'Travessa dos Motores, 300',
    'Ananindeua',
    'PA',
    '67000000',
    1,
    datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM customers WHERE document = '12345678000199'
);

INSERT INTO schema_version (version, description, applied_at)
SELECT '0.4.0', 'Create customers and demo records', datetime('now')
WHERE NOT EXISTS (
    SELECT 1 FROM schema_version WHERE version = '0.4.0'
);

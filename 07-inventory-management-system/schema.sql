-- Day 7 - Inventory Management System
-- PostgreSQL schema

-- Drop child tables first because they depend on parent tables through foreign keys.
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS reorder_rules;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS suppliers;

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(120) NOT NULL UNIQUE,
    contact_person VARCHAR(100) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL UNIQUE,
    category VARCHAR(60) NOT NULL,
    supplier_id INTEGER NOT NULL,
    unit_cost NUMERIC(12, 2) NOT NULL,
    selling_price NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers (supplier_id),

    CONSTRAINT chk_products_unit_cost
        CHECK (unit_cost >= 0),

    CONSTRAINT chk_products_selling_price
        CHECK (selling_price >= 0)
);

CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    current_stock INTEGER NOT NULL DEFAULT 0,
    last_updated DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),

    CONSTRAINT fk_inventory_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses (warehouse_id),

    CONSTRAINT uq_inventory_product_warehouse
        UNIQUE (product_id, warehouse_id),

    CONSTRAINT chk_inventory_current_stock
        CHECK (current_stock >= 0)
);

CREATE TABLE stock_movements (
    movement_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    movement_date DATE NOT NULL,
    movement_type VARCHAR(20) NOT NULL,
    quantity INTEGER NOT NULL,
    reference_note VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_stock_movements_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),

    CONSTRAINT fk_stock_movements_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses (warehouse_id),

    CONSTRAINT chk_stock_movements_type
        CHECK (movement_type IN ('stock_in', 'stock_out', 'adjustment')),

    CONSTRAINT chk_stock_movements_quantity
        CHECK (quantity > 0)
);

CREATE TABLE reorder_rules (
    rule_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    reorder_point INTEGER NOT NULL,
    reorder_quantity INTEGER NOT NULL,
    safety_stock INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_reorder_rules_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),

    CONSTRAINT fk_reorder_rules_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses (warehouse_id),

    CONSTRAINT uq_reorder_rules_product_warehouse
        UNIQUE (product_id, warehouse_id),

    CONSTRAINT chk_reorder_rules_reorder_point
        CHECK (reorder_point >= 0),

    CONSTRAINT chk_reorder_rules_reorder_quantity
        CHECK (reorder_quantity > 0),

    CONSTRAINT chk_reorder_rules_safety_stock
        CHECK (safety_stock >= 0)
);

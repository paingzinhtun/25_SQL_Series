-- Day 25: End-to-End Data Pipeline
-- schema.sql: Raw and Staging Operational Tables

-- ==============================================================
-- 1. RAW LAYER (Bronze)
-- Designed to accept messy data exactly as it comes from sources.
-- ==============================================================

DROP TABLE IF EXISTS raw_order_items CASCADE;
DROP TABLE IF EXISTS raw_orders CASCADE;
DROP TABLE IF EXISTS raw_stores CASCADE;
DROP TABLE IF EXISTS raw_products CASCADE;
DROP TABLE IF EXISTS raw_customers CASCADE;

CREATE TABLE raw_customers (
    raw_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100),
    customer_name VARCHAR(255),
    phone_number VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw_products (
    raw_id SERIAL PRIMARY KEY,
    product_id VARCHAR(100),
    product_name VARCHAR(255),
    category VARCHAR(100),
    price VARCHAR(100), -- Messy source might send text
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw_stores (
    raw_id SERIAL PRIMARY KEY,
    store_id VARCHAR(100),
    store_name VARCHAR(255),
    location VARCHAR(255),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw_orders (
    raw_id SERIAL PRIMARY KEY,
    order_id VARCHAR(100),
    customer_id VARCHAR(100),
    store_id VARCHAR(100),
    order_date VARCHAR(100), -- Messy dates
    status VARCHAR(100),
    channel VARCHAR(100),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE raw_order_items (
    raw_id SERIAL PRIMARY KEY,
    order_item_id VARCHAR(100),
    order_id VARCHAR(100),
    product_id VARCHAR(100),
    quantity VARCHAR(100), -- Might contain negatives or strings
    unit_price VARCHAR(100),
    discount VARCHAR(100),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================
-- 2. STAGING LAYER (Silver)
-- Cleaned, deduplicated, correctly typed data ready for the warehouse.
-- ==============================================================

DROP TABLE IF EXISTS stg_order_items CASCADE;
DROP TABLE IF EXISTS stg_orders CASCADE;
DROP TABLE IF EXISTS stg_stores CASCADE;
DROP TABLE IF EXISTS stg_products CASCADE;
DROP TABLE IF EXISTS stg_customers CASCADE;

CREATE TABLE stg_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(50),
    city VARCHAR(100),
    region VARCHAR(100),
    is_valid BOOLEAN DEFAULT TRUE,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stg_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stg_stores (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stg_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    store_id VARCHAR(50),
    order_date DATE,
    status VARCHAR(50),
    channel VARCHAR(50),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stg_order_items (
    order_item_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT CHECK (quantity > 0),
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
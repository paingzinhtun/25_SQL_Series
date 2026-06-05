-- Day 25: End-to-End Data Pipeline
-- warehouse_schema.sql: Star Schema (Gold Layer)

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;

-- ==============================================================
-- DIMENSIONS
-- ==============================================================

CREATE TABLE dim_customer (
    customer_sk SERIAL PRIMARY KEY, -- Surrogate Key
    customer_id VARCHAR(50) NOT NULL, -- Business Key
    customer_name VARCHAR(150),
    city VARCHAR(100),
    region VARCHAR(100),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_product (
    product_sk SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(150),
    category VARCHAR(100),
    current_price DECIMAL(10,2),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_store (
    store_sk SERIAL PRIMARY KEY,
    store_id VARCHAR(50) NOT NULL,
    store_name VARCHAR(150),
    city VARCHAR(100),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Date Dimension (Often generated entirely via SQL)
CREATE TABLE dim_date (
    date_sk INT PRIMARY KEY, -- e.g., 20230101
    full_date DATE NOT NULL,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day_of_month INT,
    day_of_week VARCHAR(20),
    is_weekend BOOLEAN
);

-- ==============================================================
-- FACT TABLE
-- Grain: One row per order item.
-- ==============================================================

CREATE TABLE fact_sales (
    sales_sk SERIAL PRIMARY KEY,
    order_item_id VARCHAR(50) NOT NULL, -- Degenerate dimension / Business Key
    order_id VARCHAR(50) NOT NULL,
    
    -- Foreign Keys to Dimensions
    customer_sk INT REFERENCES dim_customer(customer_sk),
    product_sk INT REFERENCES dim_product(product_sk),
    store_sk INT REFERENCES dim_store(store_sk),
    date_sk INT REFERENCES dim_date(date_sk),
    
    -- Measures
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    gross_sales_amount DECIMAL(12,2) NOT NULL, -- qty * price
    net_sales_amount DECIMAL(12,2) NOT NULL,   -- gross - discount
    
    -- Meta
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_fact_sales_date ON fact_sales(date_sk);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_sk);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_sk);
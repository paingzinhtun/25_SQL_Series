-- Day 23: Slowly Changing Dimensions (SCD Type 1 & Type 2)
-- schema.sql

-- Drop existing tables if they exist
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product_scd2;
DROP TABLE IF EXISTS dim_employee_scd2;
DROP TABLE IF EXISTS dim_customer_scd2;
DROP TABLE IF EXISTS dim_customer_scd1;

-- ==========================================
-- DIMENSION TABLES
-- ==========================================

-- 1. SCD Type 1: Customer Dimension
-- Overwrites history. Only keeps the latest state.
CREATE TABLE dim_customer_scd1 (
    customer_key SERIAL PRIMARY KEY, -- Surrogate key
    customer_id VARCHAR(50) NOT NULL UNIQUE, -- Business key
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),
    customer_segment VARCHAR(50),
    email VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SCD Type 2: Customer Dimension
-- Preserves history. Keeps multiple versions of a customer over time.
CREATE TABLE dim_customer_scd2 (
    customer_sk SERIAL PRIMARY KEY, -- Surrogate key (necessary because customer_id will repeat)
    customer_id VARCHAR(50) NOT NULL, -- Business key
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),
    customer_segment VARCHAR(50),
    email VARCHAR(100),
    effective_start_date DATE NOT NULL, -- When this version became active
    effective_end_date DATE, -- When this version expired (NULL if currently active)
    is_current BOOLEAN NOT NULL DEFAULT TRUE, -- Flag to easily find current records
    version_number INT NOT NULL DEFAULT 1, -- Tracks how many times the record changed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. SCD Type 2: Employee Dimension
CREATE TABLE dim_employee_scd2 (
    employee_sk SERIAL PRIMARY KEY,
    employee_id VARCHAR(50) NOT NULL,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    role VARCHAR(100),
    city VARCHAR(100),
    salary_band VARCHAR(50),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    version_number INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. SCD Type 2: Product Dimension
CREATE TABLE dim_product_scd2 (
    product_sk SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    price_band VARCHAR(50),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    version_number INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- FACT TABLE
-- ==========================================

-- 5. Fact Sales
-- Uses surrogate keys (SK) to link to the exact historical dimension version at the time of sale.
CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    sales_date DATE NOT NULL,
    customer_sk INT REFERENCES dim_customer_scd2(customer_sk),
    employee_sk INT REFERENCES dim_employee_scd2(employee_sk),
    product_sk INT REFERENCES dim_product_scd2(product_sk),
    quantity INT NOT NULL,
    total_sales_amount DECIMAL(10, 2) NOT NULL,
    profit_amount DECIMAL(10, 2) NOT NULL
);

-- Indexes for performance and historical lookups
CREATE INDEX idx_dim_customer_scd2_lookup ON dim_customer_scd2(customer_id, is_current);
CREATE INDEX idx_dim_employee_scd2_lookup ON dim_employee_scd2(employee_id, is_current);
CREATE INDEX idx_dim_product_scd2_lookup ON dim_product_scd2(product_id, is_current);
CREATE INDEX idx_fact_sales_date ON fact_sales(sales_date);
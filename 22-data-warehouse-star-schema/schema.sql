-- Day 22 - Data Warehouse Design with Star Schema
-- PostgreSQL schema

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_channel;
DROP TABLE IF EXISTS dim_employee;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_number INTEGER NOT NULL CHECK (day_number BETWEEN 1 AND 31),
    day_name VARCHAR(20) NOT NULL,
    week_number INTEGER NOT NULL CHECK (week_number BETWEEN 1 AND 53),
    month_number INTEGER NOT NULL CHECK (month_number BETWEEN 1 AND 12),
    month_name VARCHAR(20) NOT NULL,
    quarter_number INTEGER NOT NULL CHECK (quarter_number BETWEEN 1 AND 4),
    year_number INTEGER NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(30) NOT NULL UNIQUE,
    customer_name VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL,
    region VARCHAR(80) NOT NULL,
    customer_type VARCHAR(40) NOT NULL
        CHECK (customer_type IN ('retail', 'wholesale', 'vip', 'corporate')),
    signup_date DATE NOT NULL
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80) NOT NULL,
    subcategory VARCHAR(80) NOT NULL,
    brand VARCHAR(80) NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id VARCHAR(30) NOT NULL UNIQUE,
    store_name VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL,
    region VARCHAR(80) NOT NULL,
    store_type VARCHAR(40) NOT NULL
        CHECK (store_type IN ('mall_store', 'online_store', 'city_store', 'wholesale_center'))
);

CREATE TABLE dim_employee (
    employee_key SERIAL PRIMARY KEY,
    employee_id VARCHAR(30) NOT NULL UNIQUE,
    employee_name VARCHAR(120) NOT NULL,
    department VARCHAR(80) NOT NULL,
    role VARCHAR(80) NOT NULL
);

CREATE TABLE dim_channel (
    channel_key SERIAL PRIMARY KEY,
    channel_name VARCHAR(50) NOT NULL UNIQUE
);

-- Fact table grain:
-- One row per product sold per order.
-- Measures live in the fact table. Descriptive attributes live in dimensions.
CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    date_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    employee_key INTEGER NOT NULL,
    channel_key INTEGER NOT NULL,
    order_id VARCHAR(40) NOT NULL,
    quantity_sold INTEGER NOT NULL CHECK (quantity_sold > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_amount NUMERIC(10, 2) NOT NULL CHECK (discount_amount >= 0),
    total_sales_amount NUMERIC(12, 2) NOT NULL CHECK (total_sales_amount >= 0),
    total_cost_amount NUMERIC(12, 2) NOT NULL CHECK (total_cost_amount >= 0),
    profit_amount NUMERIC(12, 2) NOT NULL,
    CONSTRAINT fk_fact_sales_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer (customer_key),
    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dim_product (product_key),
    CONSTRAINT fk_fact_sales_store
        FOREIGN KEY (store_key)
        REFERENCES dim_store (store_key),
    CONSTRAINT fk_fact_sales_employee
        FOREIGN KEY (employee_key)
        REFERENCES dim_employee (employee_key),
    CONSTRAINT fk_fact_sales_channel
        FOREIGN KEY (channel_key)
        REFERENCES dim_channel (channel_key),
    CONSTRAINT uq_fact_sales_order_product
        UNIQUE (order_id, product_key)
);

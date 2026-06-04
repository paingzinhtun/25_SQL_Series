-- Day 24: KPI Dashboard Engineering Using SQL
-- schema.sql

DROP TABLE IF EXISTS customer_activity;
DROP TABLE IF EXISTS sales_order_items;
DROP TABLE IF EXISTS sales_orders;
DROP TABLE IF EXISTS monthly_targets;
DROP TABLE IF EXISTS marketing_campaigns;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),
    customer_segment VARCHAR(50), -- VIP, Regular, Premium, Occasional
    signup_date DATE,
    customer_status VARCHAR(50) -- active, inactive, churned
);

-- 2. Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    unit_price DECIMAL(10, 2)
);

-- 3. Stores Table
CREATE TABLE stores (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    store_type VARCHAR(50) -- Flagship, Standard, Kiosk
);

-- 4. Sales Orders Table
CREATE TABLE sales_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    store_id VARCHAR(50) REFERENCES stores(store_id),
    order_date DATE,
    order_status VARCHAR(50), -- completed, cancelled, returned, pending
    sales_channel VARCHAR(50), -- website, mobile_app, in_store, marketplace
    total_order_amount DECIMAL(12, 2)
);

-- 5. Sales Order Items Table
CREATE TABLE sales_order_items (
    order_item_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) REFERENCES sales_orders(order_id),
    product_id VARCHAR(50) REFERENCES products(product_id),
    quantity INT,
    unit_price DECIMAL(10, 2),
    discount_amount DECIMAL(10, 2),
    total_sales_amount DECIMAL(12, 2),
    profit_amount DECIMAL(12, 2)
);

-- 6. Marketing Campaigns Table
CREATE TABLE marketing_campaigns (
    campaign_id VARCHAR(50) PRIMARY KEY,
    campaign_name VARCHAR(100),
    campaign_type VARCHAR(50), -- awareness, conversion, retention, referral
    start_date DATE,
    end_date DATE,
    campaign_cost DECIMAL(12, 2)
);

-- 7. Customer Activity Table
CREATE TABLE customer_activity (
    activity_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    activity_date DATE,
    activity_type VARCHAR(50) -- login, purchase, support_request, review, referral
);

-- 8. Monthly Targets Table
CREATE TABLE monthly_targets (
    target_id VARCHAR(50) PRIMARY KEY,
    target_month INT,
    target_year INT,
    revenue_target DECIMAL(12, 2),
    profit_target DECIMAL(12, 2),
    customer_growth_target INT
);
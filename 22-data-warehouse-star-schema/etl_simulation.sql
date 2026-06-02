-- Day 22 - Data Warehouse Design with Star Schema
-- Simple ETL simulation using PostgreSQL

-- This file is a learning simulation.
-- It demonstrates how source-style records can be cleaned, deduplicated,
-- mapped to warehouse surrogate keys, and loaded into dimensions and facts.

DROP TABLE IF EXISTS stg_orders;
DROP TABLE IF EXISTS stg_order_items;
DROP TABLE IF EXISTS stg_customers;
DROP TABLE IF EXISTS stg_products;

CREATE TEMP TABLE stg_customers (
    customer_id VARCHAR(30),
    customer_name VARCHAR(120),
    city VARCHAR(80),
    region VARCHAR(80),
    customer_type VARCHAR(40),
    signup_date DATE
);

CREATE TEMP TABLE stg_products (
    product_id VARCHAR(30),
    product_name VARCHAR(120),
    category VARCHAR(80),
    subcategory VARCHAR(80),
    brand VARCHAR(80),
    unit_price NUMERIC(10, 2)
);

CREATE TEMP TABLE stg_orders (
    order_id VARCHAR(40),
    order_date DATE,
    customer_id VARCHAR(30),
    store_id VARCHAR(30),
    employee_id VARCHAR(30),
    channel_name VARCHAR(50)
);

CREATE TEMP TABLE stg_order_items (
    order_id VARCHAR(40),
    product_id VARCHAR(30),
    quantity_sold INTEGER,
    unit_price NUMERIC(10, 2),
    discount_amount NUMERIC(10, 2),
    unit_cost NUMERIC(10, 2)
);

-- Example source customer data.
-- This includes extra spaces and duplicate source IDs to demonstrate cleaning.
INSERT INTO stg_customers
VALUES
    ('CUST-ETL-001', '  Lin New Customer  ', 'Yangon', 'Lower Myanmar', 'Retail', '2025-10-01'),
    ('CUST-ETL-001', 'Lin New Customer', 'Yangon', 'Lower Myanmar', 'retail', '2025-10-01'),
    ('CUST-ETL-002', 'Aye Wholesale Buyer', 'Mandalay', 'Upper Myanmar', 'Wholesale', '2025-10-03');

INSERT INTO stg_products
VALUES
    ('PROD-ETL-001', 'Premium Tea Gift Box', 'Grocery', 'Beverages', 'AyarFresh', 42000),
    ('PROD-ETL-002', 'Analytics Planner', 'Stationery', 'Office Tools', 'BaganPaper', 18000),
    ('PROD-ETL-002', ' Analytics Planner ', 'Stationery', 'Office Tools', 'BaganPaper', 18000);

INSERT INTO stg_orders
VALUES
    ('ETL-ORD-001', '2025-12-20', 'CUST-ETL-001', 'STORE-001', 'EMP-001', 'website'),
    ('ETL-ORD-002', '2025-12-21', 'CUST-ETL-002', 'STORE-004', 'EMP-012', 'in_store');

INSERT INTO stg_order_items
VALUES
    ('ETL-ORD-001', 'PROD-ETL-001', 2, 42000, 3000, 26000),
    ('ETL-ORD-001', 'PROD-ETL-002', 1, 18000, 0, 10500),
    ('ETL-ORD-002', 'PROD-ETL-001', 5, 42000, 12000, 26000);

-- Step 1: Clean and deduplicate customers before loading dim_customer.
WITH cleaned_customers AS (
    SELECT DISTINCT ON (UPPER(TRIM(customer_id)))
        UPPER(TRIM(customer_id)) AS customer_id,
        INITCAP(TRIM(customer_name)) AS customer_name,
        INITCAP(TRIM(city)) AS city,
        INITCAP(TRIM(region)) AS region,
        LOWER(TRIM(customer_type)) AS customer_type,
        signup_date
    FROM stg_customers
    WHERE customer_id IS NOT NULL
      AND customer_name IS NOT NULL
    ORDER BY UPPER(TRIM(customer_id)), signup_date DESC
)
INSERT INTO dim_customer (
    customer_id,
    customer_name,
    city,
    region,
    customer_type,
    signup_date
)
SELECT
    customer_id,
    customer_name,
    city,
    region,
    customer_type,
    signup_date
FROM cleaned_customers
ON CONFLICT (customer_id) DO NOTHING;

-- Step 2: Clean and deduplicate products before loading dim_product.
WITH cleaned_products AS (
    SELECT DISTINCT ON (UPPER(TRIM(product_id)))
        UPPER(TRIM(product_id)) AS product_id,
        INITCAP(TRIM(product_name)) AS product_name,
        INITCAP(TRIM(category)) AS category,
        INITCAP(TRIM(subcategory)) AS subcategory,
        TRIM(brand) AS brand,
        unit_price
    FROM stg_products
    WHERE product_id IS NOT NULL
      AND product_name IS NOT NULL
      AND unit_price >= 0
    ORDER BY UPPER(TRIM(product_id)), product_name
)
INSERT INTO dim_product (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_price
)
SELECT
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_price
FROM cleaned_products
ON CONFLICT (product_id) DO NOTHING;

-- Step 3: Surrogate key mapping.
-- The staging tables contain source IDs such as customer_id and product_id.
-- The fact table needs dimension surrogate keys such as customer_key and product_key.
WITH mapped_fact_rows AS (
    SELECT
        dd.date_key,
        dc.customer_key,
        dp.product_key,
        ds.store_key,
        de.employee_key,
        dch.channel_key,
        so.order_id,
        soi.quantity_sold,
        soi.unit_price,
        soi.discount_amount,
        (soi.quantity_sold * soi.unit_price) - soi.discount_amount AS total_sales_amount,
        soi.quantity_sold * soi.unit_cost AS total_cost_amount,
        ((soi.quantity_sold * soi.unit_price) - soi.discount_amount)
            - (soi.quantity_sold * soi.unit_cost) AS profit_amount
    FROM stg_orders AS so
    JOIN stg_order_items AS soi
        ON so.order_id = soi.order_id
    JOIN dim_date AS dd
        ON so.order_date = dd.full_date
    JOIN dim_customer AS dc
        ON UPPER(TRIM(so.customer_id)) = dc.customer_id
    JOIN dim_product AS dp
        ON UPPER(TRIM(soi.product_id)) = dp.product_id
    JOIN dim_store AS ds
        ON so.store_id = ds.store_id
    JOIN dim_employee AS de
        ON so.employee_id = de.employee_id
    JOIN dim_channel AS dch
        ON so.channel_name = dch.channel_name
)
INSERT INTO fact_sales (
    date_key,
    customer_key,
    product_key,
    store_key,
    employee_key,
    channel_key,
    order_id,
    quantity_sold,
    unit_price,
    discount_amount,
    total_sales_amount,
    total_cost_amount,
    profit_amount
)
SELECT
    date_key,
    customer_key,
    product_key,
    store_key,
    employee_key,
    channel_key,
    order_id,
    quantity_sold,
    unit_price,
    discount_amount,
    total_sales_amount,
    total_cost_amount,
    profit_amount
FROM mapped_fact_rows AS mfr
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_sales AS fs
    WHERE fs.order_id = mfr.order_id
      AND fs.product_key = mfr.product_key
);

-- Step 4: Data quality checks.
-- These SELECT statements should return zero rows for a clean load.

-- Check for staging order items without a matching product dimension.
SELECT
    soi.product_id
FROM stg_order_items AS soi
LEFT JOIN dim_product AS dp
    ON UPPER(TRIM(soi.product_id)) = dp.product_id
WHERE dp.product_key IS NULL;

-- Check for staging orders without a matching customer dimension.
SELECT
    so.customer_id
FROM stg_orders AS so
LEFT JOIN dim_customer AS dc
    ON UPPER(TRIM(so.customer_id)) = dc.customer_id
WHERE dc.customer_key IS NULL;

-- Check fact rows with negative revenue or cost values.
SELECT
    sales_key,
    order_id,
    total_sales_amount,
    total_cost_amount
FROM fact_sales
WHERE total_sales_amount < 0
   OR total_cost_amount < 0;

-- Keep sequences aligned after the ETL simulation inserts new dimension and fact rows.
SELECT setval('dim_customer_customer_key_seq', (SELECT MAX(customer_key) FROM dim_customer));
SELECT setval('dim_product_product_key_seq', (SELECT MAX(product_key) FROM dim_product));
SELECT setval('fact_sales_sales_key_seq', (SELECT MAX(sales_key) FROM fact_sales));

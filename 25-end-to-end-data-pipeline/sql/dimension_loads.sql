-- Day 25: End-to-End Data Pipeline
-- dimension_loads.sql: Load Gold Dimensions from Silver Staging tables

-- 1. Load Dim Customer
-- In a real pipeline, we'd use MERGE/UPSERT (SCD Type 1 or 2). For this batch, we simulate a truncate/reload or insert missing.
-- Since this is an end-to-end run, we'll do an Upsert approach.
INSERT INTO dim_customer (customer_id, customer_name, city, region)
SELECT 
    customer_id, 
    customer_name, 
    city, 
    region
FROM stg_customers
WHERE is_valid = TRUE
ON CONFLICT (customer_id) -- Wait, we need a unique constraint on business key for ON CONFLICT
-- Let's add the constraint dynamically for the simulation:
-- ALTER TABLE dim_customer ADD CONSTRAINT unique_customer_id UNIQUE(customer_id);
-- Actually, a safer pattern for this script without altering schema dynamically is:
WHERE NOT EXISTS (
    SELECT 1 FROM dim_customer d WHERE d.customer_id = stg_customers.customer_id
);

-- Note: To make the script robust without assuming ON CONFLICT, we just insert new. 
-- In a real ELT, we'd manage updates. Let's keep it simple: insert missing.

-- 2. Load Dim Product
INSERT INTO dim_product (product_id, product_name, category, current_price)
SELECT 
    product_id, 
    product_name, 
    category, 
    price
FROM stg_products
WHERE NOT EXISTS (
    SELECT 1 FROM dim_product d WHERE d.product_id = stg_products.product_id
);

-- 3. Load Dim Store
INSERT INTO dim_store (store_id, store_name, city)
SELECT 
    store_id, 
    store_name, 
    city
FROM stg_stores
WHERE NOT EXISTS (
    SELECT 1 FROM dim_store d WHERE d.store_id = stg_stores.store_id
);

-- 4. Generate & Load Dim Date (Using a CTE to build a date range)
INSERT INTO dim_date (date_sk, full_date, year, quarter, month, month_name, day_of_month, day_of_week, is_weekend)
WITH DateSeries AS (
    SELECT generate_series(
        '2022-01-01'::DATE, 
        '2025-12-31'::DATE, 
        '1 day'::interval
    )::DATE as date_val
)
SELECT 
    CAST(TO_CHAR(date_val, 'YYYYMMDD') AS INT) as date_sk,
    date_val as full_date,
    EXTRACT(YEAR FROM date_val) as year,
    EXTRACT(QUARTER FROM date_val) as quarter,
    EXTRACT(MONTH FROM date_val) as month,
    TO_CHAR(date_val, 'Month') as month_name,
    EXTRACT(DAY FROM date_val) as day_of_month,
    TO_CHAR(date_val, 'Day') as day_of_week,
    CASE WHEN EXTRACT(ISODOW FROM date_val) IN (6, 7) THEN TRUE ELSE FALSE END as is_weekend
FROM DateSeries
WHERE NOT EXISTS (
    SELECT 1 FROM dim_date
);
-- Day 25: End-to-End Data Pipeline
-- staging_transformations.sql: Transforms raw data into clean staging tables

-- 1. Transform Customers
TRUNCATE TABLE stg_customers;
INSERT INTO stg_customers (customer_id, customer_name, phone_number, city, region, is_valid)
WITH DeduplicatedCustomers AS (
    SELECT 
        customer_id,
        TRIM(customer_name) AS customer_name, -- Remove extra spaces
        NULLIF(phone_number, 'N/A') AS phone_number, -- Handle 'N/A' as true NULL
        -- Standardize City Names (Fix casing/abbreviations)
        CASE 
            WHEN UPPER(TRIM(city)) = 'YGN' THEN 'Yangon'
            WHEN UPPER(TRIM(city)) = 'YANGON' THEN 'Yangon'
            ELSE INITCAP(TRIM(city))
        END AS city,
        COALESCE(region, 'Unknown') AS region, -- Handle missing regions
        -- Use ROW_NUMBER to pick the most recently ingested record if duplicates exist
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY ingested_at DESC) as rn
    FROM raw_customers
)
SELECT 
    customer_id,
    customer_name,
    phone_number,
    city,
    region,
    CASE WHEN city IS NULL THEN FALSE ELSE TRUE END as is_valid
FROM DeduplicatedCustomers
WHERE rn = 1;

-- 2. Transform Products
TRUNCATE TABLE stg_products;
INSERT INTO stg_products (product_id, product_name, category, price)
SELECT 
    product_id,
    TRIM(product_name),
    INITCAP(TRIM(category)), -- Standardize category casing (e.g., 'HOME' -> 'Home')
    CAST(price AS DECIMAL(10,2)) -- Cast string price to decimal
FROM raw_products
-- Assuming product_id is unique enough in this simulation
WHERE product_id IS NOT NULL;

-- 3. Transform Stores
TRUNCATE TABLE stg_stores;
INSERT INTO stg_stores (store_id, store_name, city)
SELECT 
    store_id,
    TRIM(store_name),
    TRIM(SPLIT_PART(location, ' ', 1)) -- Extract city from location string loosely
FROM raw_stores;

-- 4. Transform Orders
TRUNCATE TABLE stg_orders;
INSERT INTO stg_orders (order_id, customer_id, store_id, order_date, status, channel)
SELECT 
    order_id,
    customer_id,
    NULLIF(store_id, ''),
    -- Handle MM/DD/YYYY vs YYYY-MM-DD
    CASE 
        WHEN order_date LIKE '%/%' THEN TO_DATE(order_date, 'MM/DD/YYYY')
        ELSE CAST(order_date AS DATE)
    END AS order_date,
    UPPER(TRIM(status)), -- Standardize status ('Pending ', 'returned', 'CANCELLED')
    INITCAP(TRIM(channel))
FROM raw_orders;

-- 5. Transform Order Items
TRUNCATE TABLE stg_order_items;
INSERT INTO stg_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount)
WITH CleanedItems AS (
    SELECT 
        order_item_id,
        order_id,
        product_id,
        -- Handle 'NULL' string literal and cast
        CAST(NULLIF(quantity, 'NULL') AS INT) as quantity,
        CAST(unit_price AS DECIMAL(10,2)) as unit_price,
        CAST(discount AS DECIMAL(10,2)) as discount
    FROM raw_order_items
)
SELECT 
    order_item_id,
    order_id,
    product_id,
    -- Handle negative quantities (e.g., from entry errors) by taking absolute value
    -- Or we could filter them out. Let's make them positive for the simulation.
    ABS(quantity),
    unit_price,
    discount
FROM CleanedItems
WHERE quantity IS NOT NULL AND quantity != 0;
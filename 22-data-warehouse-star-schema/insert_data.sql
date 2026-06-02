-- Day 22 - Data Warehouse Design with Star Schema
-- PostgreSQL sample warehouse data

INSERT INTO dim_date (
    date_key,
    full_date,
    day_number,
    day_name,
    week_number,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend
)
SELECT
    TO_CHAR(calendar_date, 'YYYYMMDD')::integer AS date_key,
    calendar_date::date AS full_date,
    EXTRACT(DAY FROM calendar_date)::integer AS day_number,
    TRIM(TO_CHAR(calendar_date, 'Day')) AS day_name,
    EXTRACT(WEEK FROM calendar_date)::integer AS week_number,
    EXTRACT(MONTH FROM calendar_date)::integer AS month_number,
    TRIM(TO_CHAR(calendar_date, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM calendar_date)::integer AS quarter_number,
    EXTRACT(YEAR FROM calendar_date)::integer AS year_number,
    EXTRACT(ISODOW FROM calendar_date)::integer IN (6, 7) AS is_weekend
FROM generate_series(
    DATE '2024-01-01',
    DATE '2025-12-31',
    INTERVAL '1 day'
) AS dates(calendar_date);

INSERT INTO dim_customer (
    customer_id,
    customer_name,
    city,
    region,
    customer_type,
    signup_date
)
SELECT
    'CUST-' || LPAD(customer_number::text, 4, '0') AS customer_id,
    CASE (customer_number % 10)
        WHEN 1 THEN 'Aung'
        WHEN 2 THEN 'Su'
        WHEN 3 THEN 'Min'
        WHEN 4 THEN 'Hnin'
        WHEN 5 THEN 'Kyaw'
        WHEN 6 THEN 'Thandar'
        WHEN 7 THEN 'Nilar'
        WHEN 8 THEN 'Ko'
        WHEN 9 THEN 'May'
        ELSE 'Zaw'
    END || ' Customer ' || customer_number AS customer_name,
    CASE ((customer_number - 1) % 9)
        WHEN 0 THEN 'Yangon'
        WHEN 1 THEN 'Mandalay'
        WHEN 2 THEN 'Naypyidaw'
        WHEN 3 THEN 'Bago'
        WHEN 4 THEN 'Taunggyi'
        WHEN 5 THEN 'Mawlamyine'
        WHEN 6 THEN 'Pathein'
        WHEN 7 THEN 'Monywa'
        ELSE 'Pyay'
    END AS city,
    CASE ((customer_number - 1) % 5)
        WHEN 0 THEN 'Lower Myanmar'
        WHEN 1 THEN 'Upper Myanmar'
        WHEN 2 THEN 'Central Myanmar'
        WHEN 3 THEN 'Shan Region'
        ELSE 'Delta Region'
    END AS region,
    CASE
        WHEN customer_number IN (3, 7, 11, 18, 25, 32) THEN 'vip'
        WHEN customer_number IN (5, 10, 15, 20, 30, 35, 40) THEN 'wholesale'
        WHEN customer_number IN (8, 16, 24, 36) THEN 'corporate'
        ELSE 'retail'
    END AS customer_type,
    DATE '2023-01-01' + (customer_number * 13) AS signup_date
FROM generate_series(1, 40) AS customers(customer_number);

INSERT INTO dim_product (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_price
)
VALUES
    ('PROD-001', 'Smartphone A10', 'Electronics', 'Mobile Phones', 'MingalarTech', 420000),
    ('PROD-002', 'Wireless Earbuds', 'Electronics', 'Audio', 'MingalarTech', 95000),
    ('PROD-003', 'Rice Cooker 1.8L', 'Home', 'Kitchen', 'GoldenHome', 75000),
    ('PROD-004', 'Cotton Shirt', 'Fashion', 'Men Apparel', 'ShweStyle', 28000),
    ('PROD-005', 'Office Notebook Pack', 'Stationery', 'Paper Goods', 'BaganPaper', 8500),
    ('PROD-006', 'Green Tea Box', 'Grocery', 'Beverages', 'AyarFresh', 12000),
    ('PROD-007', 'Face Cleanser', 'Beauty', 'Skincare', 'LotusCare', 18000),
    ('PROD-008', 'Yoga Mat', 'Fitness', 'Training Gear', 'FitYoma', 36000),
    ('PROD-009', 'Bluetooth Speaker', 'Electronics', 'Audio', 'MingalarTech', 135000),
    ('PROD-010', 'Women Jacket', 'Fashion', 'Women Apparel', 'ShweStyle', 52000),
    ('PROD-011', 'Cooking Oil 2L', 'Grocery', 'Pantry', 'AyarFresh', 17000),
    ('PROD-012', 'Bed Sheet Set', 'Home', 'Bedroom', 'GoldenHome', 46000),
    ('PROD-013', 'Lip Balm Pack', 'Beauty', 'Personal Care', 'LotusCare', 9500),
    ('PROD-014', 'Marker Set', 'Stationery', 'Writing Tools', 'BaganPaper', 11000),
    ('PROD-015', 'Dumbbell Pair', 'Fitness', 'Strength', 'FitYoma', 65000),
    ('PROD-016', 'Laptop Sleeve', 'Electronics', 'Accessories', 'MingalarTech', 24000),
    ('PROD-017', 'Running Shoes', 'Fashion', 'Footwear', 'ShweStyle', 88000),
    ('PROD-018', 'Coffee Beans 500g', 'Grocery', 'Beverages', 'AyarFresh', 24000),
    ('PROD-019', 'Table Lamp', 'Home', 'Lighting', 'GoldenHome', 39000),
    ('PROD-020', 'Hand Cream', 'Beauty', 'Skincare', 'LotusCare', 14500),
    ('PROD-021', 'Printer Paper Box', 'Stationery', 'Paper Goods', 'BaganPaper', 23000),
    ('PROD-022', 'Resistance Band Set', 'Fitness', 'Training Gear', 'FitYoma', 22000),
    ('PROD-023', 'Power Bank', 'Electronics', 'Accessories', 'MingalarTech', 69000),
    ('PROD-024', 'Kids T-Shirt', 'Fashion', 'Kids Apparel', 'ShweStyle', 19000),
    ('PROD-025', 'Instant Noodle Carton', 'Grocery', 'Packaged Food', 'AyarFresh', 32000),
    ('PROD-026', 'Storage Basket', 'Home', 'Organization', 'GoldenHome', 16000),
    ('PROD-027', 'Sunscreen Lotion', 'Beauty', 'Skincare', 'LotusCare', 26000),
    ('PROD-028', 'Desk Organizer', 'Stationery', 'Office Tools', 'BaganPaper', 15000),
    ('PROD-029', 'Fitness Bottle', 'Fitness', 'Accessories', 'FitYoma', 12500),
    ('PROD-030', 'USB-C Cable', 'Electronics', 'Accessories', 'MingalarTech', 8000);

INSERT INTO dim_store (
    store_id,
    store_name,
    city,
    region,
    store_type
)
VALUES
    ('STORE-001', 'Yangon Junction Mall Store', 'Yangon', 'Lower Myanmar', 'mall_store'),
    ('STORE-002', 'Mandalay City Store', 'Mandalay', 'Upper Myanmar', 'city_store'),
    ('STORE-003', 'Naypyidaw Online Hub', 'Naypyidaw', 'Central Myanmar', 'online_store'),
    ('STORE-004', 'Bago Wholesale Center', 'Bago', 'Lower Myanmar', 'wholesale_center'),
    ('STORE-005', 'Taunggyi City Store', 'Taunggyi', 'Shan Region', 'city_store'),
    ('STORE-006', 'Mawlamyine Mall Store', 'Mawlamyine', 'Lower Myanmar', 'mall_store'),
    ('STORE-007', 'Pathein Online Fulfillment', 'Pathein', 'Delta Region', 'online_store'),
    ('STORE-008', 'Monywa Wholesale Center', 'Monywa', 'Upper Myanmar', 'wholesale_center');

INSERT INTO dim_employee (
    employee_id,
    employee_name,
    department,
    role
)
SELECT
    'EMP-' || LPAD(employee_number::text, 3, '0') AS employee_id,
    CASE (employee_number % 8)
        WHEN 1 THEN 'Myo'
        WHEN 2 THEN 'Thet'
        WHEN 3 THEN 'Ei'
        WHEN 4 THEN 'Nandar'
        WHEN 5 THEN 'Htet'
        WHEN 6 THEN 'Win'
        WHEN 7 THEN 'Sai'
        ELSE 'Khin'
    END || ' Employee ' || employee_number AS employee_name,
    CASE
        WHEN employee_number <= 8 THEN 'Sales'
        WHEN employee_number <= 11 THEN 'Online Sales'
        ELSE 'Wholesale'
    END AS department,
    CASE
        WHEN employee_number IN (1, 2, 9) THEN 'Senior Sales Associate'
        WHEN employee_number IN (12, 13, 14, 15) THEN 'Account Executive'
        ELSE 'Sales Associate'
    END AS role
FROM generate_series(1, 15) AS employees(employee_number);

INSERT INTO dim_channel (channel_name)
VALUES
    ('website'),
    ('mobile_app'),
    ('in_store'),
    ('marketplace');

WITH generated_sales AS (
    SELECT
        sale_number,
        CEIL(sale_number / 2.0)::integer AS order_number,
        DATE '2024-01-01' + ((sale_number * 7) % 730) AS sale_date,
        CASE
            WHEN sale_number % 10 IN (0, 1, 2, 3) THEN ((sale_number * 2) % 8) + 1
            ELSE ((sale_number * 5) % 8) + 1
        END AS store_key,
        CASE
            WHEN sale_number % 12 IN (0, 1, 2, 3, 4) THEN ((sale_number * 3) % 10) + 1
            ELSE ((sale_number * 7) % 30) + 1
        END AS product_key,
        ((sale_number * 7) % 40) + 1 AS customer_key,
        CASE
            WHEN sale_number % 9 IN (0, 1, 2) THEN 1
            WHEN sale_number % 13 = 0 THEN 9
            ELSE ((sale_number * 4) % 15) + 1
        END AS employee_key,
        CASE
            WHEN sale_number % 4 = 0 THEN 1
            WHEN sale_number % 4 = 1 THEN 2
            WHEN sale_number % 4 = 2 THEN 3
            ELSE 4
        END AS channel_key,
        CASE
            WHEN sale_number % 15 = 0 THEN 6
            WHEN sale_number % 5 = 0 THEN 4
            ELSE (sale_number % 3) + 1
        END AS quantity_sold,
        CASE
            WHEN sale_number % 11 = 0 THEN 18000
            WHEN sale_number % 7 = 0 THEN 9000
            ELSE 0
        END::numeric(10, 2) AS discount_amount
    FROM generate_series(1, 600) AS sales(sale_number)
),
sales_with_amounts AS (
    SELECT
        gs.sale_number,
        gs.order_number,
        dd.date_key,
        gs.customer_key,
        gs.product_key,
        gs.store_key,
        gs.employee_key,
        gs.channel_key,
        gs.quantity_sold,
        dp.unit_price,
        LEAST(gs.discount_amount, (dp.unit_price * gs.quantity_sold) * 0.30) AS discount_amount,
        CASE
            WHEN dd.month_number IN (11, 12) THEN 1.15
            WHEN dd.month_number IN (4, 5) THEN 1.08
            ELSE 1.00
        END AS seasonal_multiplier,
        CASE
            WHEN gs.store_key IN (1, 3, 7) THEN 1.10
            WHEN gs.store_key IN (4, 8) THEN 1.06
            ELSE 1.00
        END AS store_multiplier
    FROM generated_sales AS gs
    JOIN dim_date AS dd
        ON gs.sale_date = dd.full_date
    JOIN dim_product AS dp
        ON gs.product_key = dp.product_key
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
    'ORD-' || LPAD(order_number::text, 5, '0') AS order_id,
    quantity_sold,
    unit_price,
    discount_amount,
    ROUND(((unit_price * quantity_sold) - discount_amount) * seasonal_multiplier * store_multiplier, 2) AS total_sales_amount,
    ROUND((unit_price * quantity_sold) * 0.64, 2) AS total_cost_amount,
    ROUND(
        (((unit_price * quantity_sold) - discount_amount) * seasonal_multiplier * store_multiplier)
        - ((unit_price * quantity_sold) * 0.64),
        2
    ) AS profit_amount
FROM sales_with_amounts;

-- Keep SERIAL sequences aligned after explicit inserts and generated data loads.
SELECT setval('dim_customer_customer_key_seq', (SELECT MAX(customer_key) FROM dim_customer));
SELECT setval('dim_product_product_key_seq', (SELECT MAX(product_key) FROM dim_product));
SELECT setval('dim_store_store_key_seq', (SELECT MAX(store_key) FROM dim_store));
SELECT setval('dim_employee_employee_key_seq', (SELECT MAX(employee_key) FROM dim_employee));
SELECT setval('dim_channel_channel_key_seq', (SELECT MAX(channel_key) FROM dim_channel));
SELECT setval('fact_sales_sales_key_seq', (SELECT MAX(sales_key) FROM fact_sales));

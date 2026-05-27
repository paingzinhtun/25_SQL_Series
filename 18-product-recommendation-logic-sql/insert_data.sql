-- Day 18 - Product Recommendation Logic with SQL
-- Fictional sample data for PostgreSQL
--
-- Actual purchase behavior uses only:
-- order_status = 'completed' AND payment_status = 'paid'
-- Views and wishlists are interest signals, not confirmed purchases.

INSERT INTO customers (
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    city,
    signup_date
)
SELECT
    customer_number,
    (ARRAY['Aung','May','Ko','Su','Nandar','Thiri','Kyaw','Ei','Zaw','Hnin','Myo','Yu','Min','Khin','Thet'])[((customer_number - 1) % 15) + 1],
    (ARRAY['Thu','Sandi','Htet','Mon','Aye','Moe','Zin','Phyo','Min','Wai','Thant','Waddy','Oo','Win','Naing'])[((customer_number - 1) % 15) + 1],
    'recommend_customer' || customer_number || '@example.com',
    '+95-9-66' || LPAD(customer_number::TEXT, 6, '0'),
    (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa','Pyay'])[((customer_number - 1) % 9) + 1],
    DATE '2025-01-01' + (customer_number * 11)
FROM generate_series(1, 35) AS gs(customer_number);

INSERT INTO products (
    product_id,
    product_name,
    category,
    brand,
    unit_price
) VALUES
    (1, 'Smartphone Basic', 'Electronics', 'NovaTech', 420000.00),
    (2, 'Wireless Earbuds', 'Electronics', 'NovaTech', 85000.00),
    (3, 'Bluetooth Speaker', 'Electronics', 'SonicWave', 145000.00),
    (4, 'Laptop Stand', 'Electronics', 'DeskPro', 55000.00),
    (5, 'Cotton Shirt', 'Fashion', 'Mandalay Wear', 28000.00),
    (6, 'Denim Jeans', 'Fashion', 'Mandalay Wear', 52000.00),
    (7, 'Sneakers', 'Fashion', 'ActiveStep', 88000.00),
    (8, 'Face Serum', 'Beauty', 'GlowCare', 36000.00),
    (9, 'Lip Care Set', 'Beauty', 'GlowCare', 18000.00),
    (10, 'Rice Bag 10kg', 'Grocery', 'Golden Grain', 42000.00),
    (11, 'Cooking Oil Pack', 'Grocery', 'Golden Grain', 26000.00),
    (12, 'Coffee Mix Box', 'Grocery', 'Morning Cup', 22000.00),
    (13, 'Desk Lamp', 'Home', 'HomeBright', 38000.00),
    (14, 'Storage Box Set', 'Home', 'HomeBright', 22000.00),
    (15, 'Home Coffee Maker', 'Home', 'Morning Cup', 160000.00),
    (16, 'Notebook Bundle', 'Stationery', 'WriteWell', 12000.00),
    (17, 'Ball Pen Box', 'Stationery', 'WriteWell', 9000.00),
    (18, 'Shampoo Family Pack', 'Personal Care', 'FreshDaily', 24000.00),
    (19, 'Toothpaste Pack', 'Personal Care', 'FreshDaily', 11000.00),
    (20, 'Travel Backpack', 'Accessories', 'UrbanTrail', 65000.00),
    (21, 'Wallet', 'Accessories', 'UrbanTrail', 30000.00),
    (22, 'Baby Lotion', 'Baby Products', 'BabyJoy', 21000.00),
    (23, 'Baby Wipes Pack', 'Baby Products', 'BabyJoy', 15000.00),
    (24, 'Yoga Mat', 'Fitness', 'ActiveStep', 48000.00),
    (25, 'Dumbbell Set', 'Fitness', 'ActiveStep', 125000.00),
    (26, 'Water Bottle', 'Fitness', 'ActiveStep', 18000.00),
    (27, 'Tablet 10 inch', 'Electronics', 'NovaTech', 380000.00),
    (28, 'Hand Cream', 'Beauty', 'GlowCare', 15000.00),
    (29, 'Baby Toy Set', 'Baby Products', 'BabyJoy', 36000.00),
    (30, 'Premium Suitcase', 'Accessories', 'UrbanTrail', 210000.00);

INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    order_status
)
SELECT
    order_number,
    CASE
        WHEN order_number BETWEEN 1 AND 70 THEN ((order_number - 1) % 20) + 1
        WHEN order_number BETWEEN 71 AND 90 THEN ((order_number - 71) % 10) + 21
        ELSE ((order_number - 91) % 5) + 31
    END AS customer_id,
    DATE '2026-01-01' + ((order_number - 1) * 2) AS order_date,
    CASE
        WHEN order_number IN (14, 42, 73, 91) THEN 'cancelled'
        WHEN order_number IN (25, 58, 88, 94) THEN 'returned'
        WHEN order_number IN (37, 69, 96, 100) THEN 'pending'
        ELSE 'completed'
    END AS order_status
FROM generate_series(1, 100) AS gs(order_number);

-- 220 order item rows.
-- Product pairs 1+2, 5+6, 10+11, 22+23, and 24+26 appear often together.
INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount
)
SELECT
    ((o.order_id - 1) * 2) + item_number AS order_item_id,
    o.order_id,
    CASE
        WHEN o.order_id BETWEEN 1 AND 25 AND item_number = 1 THEN 1
        WHEN o.order_id BETWEEN 1 AND 25 AND item_number = 2 THEN 2
        WHEN o.order_id BETWEEN 26 AND 45 AND item_number = 1 THEN 5
        WHEN o.order_id BETWEEN 26 AND 45 AND item_number = 2 THEN 6
        WHEN o.order_id BETWEEN 46 AND 65 AND item_number = 1 THEN 10
        WHEN o.order_id BETWEEN 46 AND 65 AND item_number = 2 THEN 11
        WHEN o.order_id BETWEEN 66 AND 82 AND item_number = 1 THEN 22
        WHEN o.order_id BETWEEN 66 AND 82 AND item_number = 2 THEN 23
        WHEN o.order_id BETWEEN 83 AND 100 AND item_number = 1 THEN 24
        WHEN o.order_id BETWEEN 83 AND 100 AND item_number = 2 THEN 26
        ELSE ((o.order_id + item_number) % 30) + 1
    END AS product_id,
    CASE
        WHEN o.order_id BETWEEN 1 AND 25 AND item_number = 1 THEN 1
        WHEN o.order_id BETWEEN 1 AND 25 AND item_number = 2 THEN 2
        ELSE 1
    END AS quantity,
    p.unit_price,
    CASE
        WHEN o.order_id % 18 = 0 THEN 5000.00
        ELSE 0.00
    END AS discount_amount
FROM orders AS o
CROSS JOIN generate_series(1, 2) AS gs(item_number)
JOIN products AS p
    ON p.product_id = CASE
        WHEN o.order_id BETWEEN 1 AND 25 AND item_number = 1 THEN 1
        WHEN o.order_id BETWEEN 1 AND 25 AND item_number = 2 THEN 2
        WHEN o.order_id BETWEEN 26 AND 45 AND item_number = 1 THEN 5
        WHEN o.order_id BETWEEN 26 AND 45 AND item_number = 2 THEN 6
        WHEN o.order_id BETWEEN 46 AND 65 AND item_number = 1 THEN 10
        WHEN o.order_id BETWEEN 46 AND 65 AND item_number = 2 THEN 11
        WHEN o.order_id BETWEEN 66 AND 82 AND item_number = 1 THEN 22
        WHEN o.order_id BETWEEN 66 AND 82 AND item_number = 2 THEN 23
        WHEN o.order_id BETWEEN 83 AND 100 AND item_number = 1 THEN 24
        WHEN o.order_id BETWEEN 83 AND 100 AND item_number = 2 THEN 26
        ELSE ((o.order_id + item_number) % 30) + 1
    END;

INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount
)
SELECT
    200 + extra_number AS order_item_id,
    extra_number AS order_id,
    CASE
        WHEN extra_number <= 10 THEN 3
        ELSE 15
    END AS product_id,
    1 AS quantity,
    p.unit_price,
    0.00 AS discount_amount
FROM generate_series(1, 20) AS gs(extra_number)
JOIN products AS p
    ON p.product_id = CASE
        WHEN extra_number <= 10 THEN 3
        ELSE 15
    END;

INSERT INTO payments (
    payment_id,
    order_id,
    payment_date,
    payment_method,
    payment_status,
    amount
)
SELECT
    o.order_id,
    o.order_id,
    o.order_date + 1,
    (ARRAY['cash','card','mobile_wallet','bank_transfer'])[((o.order_id - 1) % 4) + 1],
    CASE
        WHEN o.order_status = 'cancelled' THEN 'failed'
        WHEN o.order_status = 'returned' THEN 'refunded'
        WHEN o.order_status = 'pending' THEN 'unpaid'
        WHEN o.order_id IN (12, 47, 79) THEN 'unpaid'
        ELSE 'paid'
    END AS payment_status,
    CASE
        WHEN o.order_status IN ('cancelled', 'pending') THEN 0.00
        ELSE COALESCE(SUM((oi.quantity * oi.unit_price) - oi.discount_amount), 0)
    END AS amount
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.order_status
ORDER BY o.order_id;

INSERT INTO product_views (
    view_id,
    customer_id,
    product_id,
    view_date
)
SELECT
    view_number,
    CASE
        WHEN view_number BETWEEN 1 AND 30 THEN ((view_number - 1) % 5) + 31
        ELSE ((view_number - 1) % 35) + 1
    END AS customer_id,
    CASE
        WHEN view_number BETWEEN 1 AND 30 THEN ((view_number - 1) % 6) + 24
        WHEN view_number % 5 = 0 THEN 27
        WHEN view_number % 7 = 0 THEN 30
        ELSE ((view_number - 1) % 30) + 1
    END AS product_id,
    DATE '2026-03-01' + ((view_number - 1) % 60)
FROM generate_series(1, 120) AS gs(view_number);

INSERT INTO wishlists (
    wishlist_id,
    customer_id,
    product_id,
    added_date
)
SELECT
    wishlist_number,
    ((wishlist_number - 1) % 35) + 1 AS customer_id,
    ((wishlist_number * 7) % 30) + 1 AS product_id,
    DATE '2026-03-15' + ((wishlist_number - 1) % 45)
FROM generate_series(1, 60) AS gs(wishlist_number);

INSERT INTO product_recommendations (
    recommendation_id,
    customer_id,
    recommended_product_id,
    recommendation_reason,
    recommendation_score,
    recommendation_date
)
SELECT
    recommendation_number,
    customer_id,
    product_id AS recommended_product_id,
    (ARRAY[
        'popular_product',
        'category_preference',
        'frequently_bought_together',
        'wishlist_based',
        'viewed_not_purchased',
        'similar_customer_behavior'
    ])[((recommendation_number - 1) % 6) + 1] AS recommendation_reason,
    CASE ((recommendation_number - 1) % 6) + 1
        WHEN 1 THEN 1
        WHEN 2 THEN 3
        WHEN 3 THEN 5
        WHEN 4 THEN 4
        WHEN 5 THEN 2
        ELSE 3
    END AS recommendation_score,
    DATE '2026-05-01'
FROM (
    WITH purchased_products AS (
        SELECT DISTINCT
            o.customer_id,
            oi.product_id
        FROM orders AS o
        JOIN payments AS pay
            ON o.order_id = pay.order_id
        JOIN order_items AS oi
            ON o.order_id = oi.order_id
        WHERE o.order_status = 'completed'
          AND pay.payment_status = 'paid'
    ),
    raw_candidates AS (
        SELECT
            c.customer_id,
            p.product_id,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_id
                ORDER BY p.product_id
            ) AS customer_recommendation_rank
        FROM customers AS c
        CROSS JOIN products AS p
        LEFT JOIN purchased_products AS pp
            ON c.customer_id = pp.customer_id
           AND p.product_id = pp.product_id
        WHERE pp.product_id IS NULL
    ),
    candidates AS (
        SELECT
            ROW_NUMBER() OVER (
                ORDER BY customer_recommendation_rank, customer_id, product_id
            ) AS recommendation_number,
            customer_id,
            product_id
        FROM raw_candidates
        WHERE customer_recommendation_rank <= 2
    )
    SELECT
        recommendation_number,
        customer_id,
        product_id
    FROM candidates
    WHERE recommendation_number <= 40
) AS recommendation_candidates;

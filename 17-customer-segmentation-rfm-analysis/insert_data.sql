-- Day 17 - Customer Segmentation with RFM Analysis
-- Fictional sample data for PostgreSQL
--
-- RFM queries only count orders where:
-- order_status = 'completed' AND payment_status = 'paid'

INSERT INTO customer_segments (
    segment_id,
    segment_name,
    segment_description
) VALUES
    (1, 'champions', 'Recent, frequent, and high-spending customers.'),
    (2, 'loyal_customers', 'Customers who buy repeatedly and have good recent activity.'),
    (3, 'potential_loyalists', 'Recent customers with moderate frequency or potential to become loyal.'),
    (4, 'new_customers', 'Recent customers with low purchase history.'),
    (5, 'at_risk', 'Customers with past value but weak recent activity.'),
    (6, 'cannot_lose_them', 'High-value and frequent customers who have not purchased recently.'),
    (7, 'hibernating', 'Low activity customers with old purchase history.'),
    (8, 'lost_customers', 'Customers with very old purchase activity and low engagement.'),
    (9, 'one_time_buyers', 'Customers with exactly one completed paid purchase.');

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
    (ARRAY['Aung','May','Ko','Su','Nandar','Thiri','Kyaw','Ei','Zaw','Hnin','Myo','Yu','Min','Khin','Thet','Nyein'])[((customer_number - 1) % 16) + 1],
    (ARRAY['Thu','Sandi','Htet','Mon','Aye','Moe','Zin','Phyo','Min','Wai','Thant','Waddy','Oo','Win','Naing','Tun'])[((customer_number - 1) % 16) + 1],
    'rfm_customer' || customer_number || '@example.com',
    '+95-9-88' || LPAD(customer_number::TEXT, 6, '0'),
    (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa','Pyay'])[((customer_number - 1) % 9) + 1],
    DATE '2024-01-01' + (customer_number * 18)
FROM generate_series(1, 40) AS gs(customer_number);

INSERT INTO products (
    product_id,
    product_name,
    category,
    unit_price
) VALUES
    (1, 'Smartphone Basic', 'Electronics', 420000.00),
    (2, 'Wireless Earbuds', 'Electronics', 85000.00),
    (3, 'Cotton Shirt', 'Fashion', 28000.00),
    (4, 'Denim Jeans', 'Fashion', 52000.00),
    (5, 'Face Serum', 'Beauty', 36000.00),
    (6, 'Lip Care Set', 'Beauty', 18000.00),
    (7, 'Rice Bag 10kg', 'Grocery', 42000.00),
    (8, 'Cooking Oil Pack', 'Grocery', 26000.00),
    (9, 'Desk Lamp', 'Home', 38000.00),
    (10, 'Storage Box Set', 'Home', 22000.00),
    (11, 'Notebook Bundle', 'Stationery', 12000.00),
    (12, 'Ball Pen Box', 'Stationery', 9000.00),
    (13, 'Shampoo Family Pack', 'Personal Care', 24000.00),
    (14, 'Toothpaste Pack', 'Personal Care', 11000.00),
    (15, 'Travel Backpack', 'Accessories', 65000.00),
    (16, 'Wallet', 'Accessories', 30000.00),
    (17, 'Baby Lotion', 'Baby Products', 21000.00),
    (18, 'Baby Wipes Pack', 'Baby Products', 15000.00),
    (19, 'Bluetooth Speaker', 'Electronics', 145000.00),
    (20, 'Home Coffee Maker', 'Home', 160000.00);

-- 120 orders with intentionally varied behavior for RFM analysis.
INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    order_status
)
SELECT
    order_number,
    CASE
        WHEN order_number BETWEEN 1 AND 60 THEN ((order_number - 1) % 5) + 1
        WHEN order_number BETWEEN 61 AND 80 THEN ((order_number - 61) % 5) + 6
        WHEN order_number BETWEEN 81 AND 92 THEN ((order_number - 81) % 8) + 11
        WHEN order_number BETWEEN 93 AND 102 THEN ((order_number - 93) % 5) + 19
        WHEN order_number BETWEEN 103 AND 108 THEN ((order_number - 103) % 6) + 24
        WHEN order_number BETWEEN 109 AND 114 THEN ((order_number - 109) % 6) + 30
        ELSE ((order_number - 115) % 5) + 36
    END AS customer_id,
    CASE
        WHEN order_number BETWEEN 1 AND 60 THEN DATE '2026-03-01' + ((order_number - 1) % 55)
        WHEN order_number BETWEEN 61 AND 80 THEN DATE '2026-01-15' + ((order_number - 61) * 4)
        WHEN order_number BETWEEN 81 AND 92 THEN DATE '2026-04-10' + ((order_number - 81) % 18)
        WHEN order_number BETWEEN 93 AND 102 THEN DATE '2025-10-01' + ((order_number - 93) * 8)
        WHEN order_number BETWEEN 103 AND 108 THEN DATE '2025-06-01' + ((order_number - 103) * 12)
        WHEN order_number BETWEEN 109 AND 114 THEN DATE '2026-02-15' + ((order_number - 109) * 7)
        ELSE DATE '2026-04-01' + (order_number - 115)
    END AS order_date,
    CASE
        WHEN order_number IN (116, 119) THEN 'cancelled'
        WHEN order_number IN (117, 120) THEN 'returned'
        WHEN order_number = 118 THEN 'pending'
        WHEN order_number IN (20, 45, 74, 88, 100) THEN 'cancelled'
        WHEN order_number IN (32, 67, 96) THEN 'returned'
        WHEN order_number IN (55, 90) THEN 'pending'
        ELSE 'completed'
    END AS order_status
FROM generate_series(1, 120) AS gs(order_number);

-- 240 order item rows: two items per order.
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
        WHEN o.customer_id BETWEEN 1 AND 5 AND item_number = 1 THEN 1
        WHEN o.customer_id BETWEEN 1 AND 5 AND item_number = 2 THEN 19
        WHEN o.customer_id BETWEEN 6 AND 10 THEN ((o.order_id + item_number) % 6) + 1
        WHEN o.customer_id BETWEEN 11 AND 18 THEN ((o.order_id + item_number) % 10) + 7
        WHEN o.customer_id BETWEEN 19 AND 23 THEN ((o.order_id + item_number) % 8) + 13
        ELSE ((o.order_id + item_number) % 20) + 1
    END AS product_id,
    CASE
        WHEN o.customer_id BETWEEN 1 AND 5 THEN 2
        WHEN o.customer_id BETWEEN 19 AND 23 AND item_number = 1 THEN 3
        ELSE 1
    END AS quantity,
    p.unit_price,
    CASE
        WHEN o.customer_id BETWEEN 1 AND 5 THEN 10000.00
        WHEN o.order_id % 15 = 0 THEN 5000.00
        ELSE 0.00
    END AS discount_amount
FROM orders AS o
CROSS JOIN generate_series(1, 2) AS gs(item_number)
JOIN products AS p
    ON p.product_id = CASE
        WHEN o.customer_id BETWEEN 1 AND 5 AND item_number = 1 THEN 1
        WHEN o.customer_id BETWEEN 1 AND 5 AND item_number = 2 THEN 19
        WHEN o.customer_id BETWEEN 6 AND 10 THEN ((o.order_id + item_number) % 6) + 1
        WHEN o.customer_id BETWEEN 11 AND 18 THEN ((o.order_id + item_number) % 10) + 7
        WHEN o.customer_id BETWEEN 19 AND 23 THEN ((o.order_id + item_number) % 8) + 13
        ELSE ((o.order_id + item_number) % 20) + 1
    END;

-- One payment per order = 120 payment records.
-- Non-paid payments should not count toward RFM customer value.
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
    o.order_date + 1 AS payment_date,
    (ARRAY['cash','card','mobile_wallet','bank_transfer'])[((o.order_id - 1) % 4) + 1] AS payment_method,
    CASE
        WHEN o.order_id IN (115, 116, 117, 118, 119, 120) THEN
            CASE
                WHEN o.order_id IN (115, 118) THEN 'unpaid'
                WHEN o.order_id IN (116, 119) THEN 'failed'
                ELSE 'refunded'
            END
        WHEN o.order_id IN (12, 41, 70) THEN 'unpaid'
        WHEN o.order_id IN (20, 45, 74, 88, 100) THEN 'failed'
        WHEN o.order_id IN (32, 67, 96) THEN 'refunded'
        ELSE 'paid'
    END AS payment_status,
    CASE
        WHEN o.order_id IN (115, 116, 117, 118, 119, 120) THEN 0.00
        ELSE COALESCE(SUM((oi.quantity * oi.unit_price) - oi.discount_amount), 0)
    END AS amount
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_id;

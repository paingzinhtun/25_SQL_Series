-- Day 11 - E-commerce Customer Behavior Analysis
-- Sample data for PostgreSQL
--
-- The sample is designed to support repeat purchase, one-time customer,
-- inactive customer, VIP, and Customer 360 analysis.

INSERT INTO customer_segments (segment_name, segment_description) VALUES
    ('new_customer', 'Recently acquired customers with limited purchase history'),
    ('regular_customer', 'Customers who purchase repeatedly at a normal value'),
    ('vip_customer', 'High-value customers with strong spending behavior'),
    ('inactive_customer', 'Customers who have not purchased recently');

INSERT INTO customers (first_name, last_name, email, phone_number, city, gender, signup_date) VALUES
    ('Aung', 'Min', 'aung.min@example.com', '09-510001001', 'Yangon', 'male', '2025-08-15'),
    ('Hnin', 'Wai', 'hnin.wai@example.com', '09-510001002', 'Mandalay', 'female', '2025-08-20'),
    ('Kyaw', 'Zin', 'kyaw.zin@example.com', '09-510001003', 'Naypyidaw', 'male', '2025-09-05'),
    ('Su', 'Mon', 'su.mon@example.com', '09-510001004', 'Bago', 'female', '2025-09-12'),
    ('Myo', 'Thant', 'myo.thant@example.com', '09-510001005', 'Taunggyi', 'male', '2025-09-18'),
    ('Ei', 'Phyo', 'ei.phyo@example.com', '09-510001006', 'Mawlamyine', 'female', '2025-10-01'),
    ('Thet', 'Naing', 'thet.naing@example.com', '09-510001007', 'Pathein', 'male', '2025-10-06'),
    ('May', 'Thu', 'may.thu@example.com', '09-510001008', 'Yangon', 'female', '2025-10-13'),
    ('Nandar', 'Hlaing', 'nandar.hlaing@example.com', '09-510001009', 'Mandalay', 'female', '2025-10-20'),
    ('Zaw', 'Linn', 'zaw.linn@example.com', '09-510001010', 'Monywa', 'male', '2025-11-01'),
    ('Thiri', 'Aye', 'thiri.aye@example.com', '09-510001011', 'Bago', 'female', '2025-11-07'),
    ('Ko', 'Paing', 'ko.paing@example.com', '09-510001012', 'Taunggyi', 'male', '2025-11-12'),
    ('Yamin', 'Oo', 'yamin.oo@example.com', '09-510001013', 'Mawlamyine', 'female', '2025-11-20'),
    ('Phone', 'Myat', 'phone.myat@example.com', '09-510001014', 'Pathein', 'male', '2025-12-01'),
    ('Cherry', 'Win', 'cherry.win@example.com', '09-510001015', 'Yangon', 'female', '2025-12-05'),
    ('Sai', 'Htun', 'sai.htun@example.com', '09-510001016', 'Taunggyi', 'male', '2025-12-10'),
    ('Moe', 'Sandar', 'moe.sandar@example.com', '09-510001017', 'Mandalay', 'female', '2025-12-16'),
    ('Wai', 'Yan', 'wai.yan@example.com', '09-510001018', 'Naypyidaw', 'male', '2025-12-22'),
    ('Khin', 'Sabal', 'khin.sabal@example.com', '09-510001019', 'Bago', 'female', '2026-01-03'),
    ('Tun', 'Aung', 'tun.aung@example.com', '09-510001020', 'Monywa', 'male', '2026-01-08'),
    ('Nan', 'Kham', 'nan.kham@example.com', '09-510001021', 'Taunggyi', 'female', '2026-01-15'),
    ('Pyae', 'Sone', 'pyae.sone@example.com', '09-510001022', 'Yangon', 'male', '2026-01-21'),
    ('Yu', 'Par', 'yu.par@example.com', '09-510001023', 'Pathein', 'female', '2026-02-01'),
    ('Lwin', 'Moe', 'lwin.moe@example.com', '09-510001024', 'Mawlamyine', 'male', '2026-02-09'),
    ('Aye', 'Chan', 'aye.chan@example.com', '09-510001025', 'Mandalay', 'female', '2026-02-18'),
    ('Htet', 'Wai', 'htet.wai@example.com', '09-510001026', 'Yangon', 'male', '2026-03-01'),
    ('Mya', 'Nadi', 'mya.nadi@example.com', '09-510001027', 'Bago', 'female', '2026-03-12'),
    ('Nyein', 'Su', 'nyein.su@example.com', '09-510001028', 'Naypyidaw', 'female', '2026-03-22');

INSERT INTO products (product_name, category, unit_price) VALUES
    ('Wireless Earbuds', 'Electronics', 45000.00),
    ('Bluetooth Speaker', 'Electronics', 65000.00),
    ('Cotton T-Shirt', 'Fashion', 18000.00),
    ('Denim Jacket', 'Fashion', 55000.00),
    ('Face Serum', 'Beauty', 32000.00),
    ('Lip Tint', 'Beauty', 12000.00),
    ('Rice Cooker', 'Home', 85000.00),
    ('Desk Lamp', 'Home', 28000.00),
    ('Premium Rice Bag', 'Grocery', 42000.00),
    ('Green Tea Pack', 'Grocery', 9500.00),
    ('Notebook Set', 'Stationery', 8500.00),
    ('Gel Pen Pack', 'Stationery', 4500.00),
    ('Shampoo', 'Personal Care', 14500.00),
    ('Body Lotion', 'Personal Care', 18500.00),
    ('Leather Wallet', 'Accessories', 30000.00),
    ('Travel Backpack', 'Accessories', 70000.00),
    ('Smart Watch', 'Electronics', 120000.00),
    ('Running Shoes', 'Fashion', 68000.00),
    ('Coffee Mug Set', 'Home', 22000.00),
    ('Sunscreen', 'Beauty', 24000.00);

INSERT INTO orders (customer_id, order_date, order_status, segment_id) VALUES
    (1, '2025-09-05', 'completed', 3),
    (1, '2025-11-12', 'completed', 3),
    (1, '2026-01-20', 'completed', 3),
    (1, '2026-03-18', 'completed', 3),
    (1, '2026-04-10', 'completed', 3),
    (1, '2026-05-01', 'completed', 3),
    (2, '2025-09-18', 'completed', 3),
    (2, '2025-12-03', 'completed', 3),
    (2, '2026-02-14', 'completed', 3),
    (2, '2026-04-02', 'completed', 3),
    (2, '2026-04-28', 'completed', 3),
    (3, '2025-10-02', 'completed', 3),
    (3, '2025-12-20', 'completed', 3),
    (3, '2026-02-25', 'completed', 3),
    (3, '2026-04-15', 'completed', 3),
    (3, '2026-05-03', 'completed', 3),
    (4, '2025-10-08', 'completed', 2),
    (4, '2026-01-10', 'completed', 2),
    (4, '2026-03-22', 'completed', 2),
    (4, '2026-04-25', 'completed', 2),
    (5, '2025-10-11', 'completed', 2),
    (5, '2026-01-14', 'completed', 2),
    (5, '2026-03-28', 'completed', 2),
    (5, '2026-04-30', 'completed', 2),
    (6, '2025-11-05', 'completed', 2),
    (6, '2026-01-25', 'completed', 2),
    (6, '2026-03-30', 'completed', 2),
    (6, '2026-05-05', 'completed', 2),
    (7, '2025-11-10', 'completed', 2),
    (7, '2026-02-03', 'completed', 2),
    (7, '2026-04-18', 'completed', 2),
    (8, '2025-11-15', 'completed', 2),
    (8, '2026-02-08', 'completed', 2),
    (8, '2026-04-20', 'completed', 2),
    (9, '2025-11-22', 'completed', 2),
    (9, '2026-02-18', 'completed', 2),
    (9, '2026-04-24', 'completed', 2),
    (10, '2025-09-25', 'completed', 4),
    (10, '2025-12-15', 'completed', 4),
    (11, '2025-10-04', 'completed', 4),
    (11, '2026-01-05', 'completed', 4),
    (12, '2025-12-28', 'completed', 4),
    (13, '2026-04-05', 'completed', 1),
    (14, '2026-04-07', 'completed', 1),
    (15, '2026-04-12', 'completed', 1),
    (16, '2026-03-11', 'completed', 1),
    (17, '2026-03-15', 'completed', 1),
    (18, '2025-12-05', 'completed', 4),
    (19, '2026-03-19', 'completed', 1),
    (20, '2026-03-21', 'completed', 1),
    (21, '2026-03-26', 'completed', 1),
    (22, '2025-12-18', 'completed', 4),
    (23, '2026-04-01', 'completed', 1),
    (24, '2026-04-03', 'completed', 1),
    (25, '2026-04-05', 'completed', 1),
    (1, '2026-04-22', 'cancelled', 3),
    (2, '2026-04-23', 'returned', 3),
    (3, '2026-04-24', 'pending', 3),
    (4, '2026-04-26', 'cancelled', 2),
    (5, '2026-04-27', 'returned', 2),
    (6, '2026-04-29', 'pending', 2),
    (7, '2026-05-02', 'completed', 2),
    (8, '2026-05-03', 'completed', 2),
    (9, '2026-05-04', 'completed', 2),
    (15, '2026-05-06', 'returned', 1);

-- Generate two order items for each order using product prices from the products table.
-- This creates 130 order item rows from 65 orders.
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_amount)
SELECT
    o.order_id,
    p.product_id,
    CASE
        WHEN o.order_id % 5 = 0 THEN 2
        ELSE 1
    END AS quantity,
    p.unit_price,
    CASE
        WHEN o.order_id % 7 = 0 THEN 2000.00
        ELSE 0.00
    END AS discount_amount
FROM orders AS o
JOIN products AS p
    ON p.product_id = ((o.order_id - 1) % 20) + 1
UNION ALL
SELECT
    o.order_id,
    p.product_id,
    CASE
        WHEN o.order_id % 4 = 0 THEN 2
        ELSE 1
    END AS quantity,
    p.unit_price,
    CASE
        WHEN o.order_id % 9 = 0 THEN 1500.00
        ELSE 0.00
    END AS discount_amount
FROM orders AS o
JOIN products AS p
    ON p.product_id = ((o.order_id + 6) % 20) + 1;

-- Payment amounts are generated from order item totals.
-- Only completed + paid orders count as real revenue in the analysis queries.
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
SELECT
    o.order_id,
    o.order_date AS payment_date,
    CASE
        WHEN o.order_id % 4 = 0 THEN 'card'
        WHEN o.order_id % 4 = 1 THEN 'mobile_wallet'
        WHEN o.order_id % 4 = 2 THEN 'bank_transfer'
        ELSE 'cash'
    END AS payment_method,
    CASE
        WHEN o.order_status = 'completed' AND o.order_id = 62 THEN 'failed'
        WHEN o.order_status = 'completed' THEN 'paid'
        WHEN o.order_status = 'cancelled' THEN 'failed'
        WHEN o.order_status = 'returned' THEN 'refunded'
        ELSE 'unpaid'
    END AS payment_status,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS amount
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.order_status;

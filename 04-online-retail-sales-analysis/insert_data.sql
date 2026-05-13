-- Day 4 - Online Retail Sales Analysis
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Completed and paid orders count as real revenue.
-- - Cancelled, pending, unpaid, and refunded records are included but excluded from revenue.
-- - Some customers place repeat orders.
-- - Products are spread across multiple retail categories.
-- - Stores are based in Myanmar cities.

INSERT INTO customers (
    first_name,
    last_name,
    email,
    phone_number,
    city,
    customer_segment
) VALUES
    ('Aung', 'Min', 'aung.min.retail@example.com', '09-450001001', 'Yangon', 'vip'),
    ('Su', 'Mon', 'su.mon.retail@example.com', '09-450001002', 'Mandalay', 'regular'),
    ('Thandar', 'Hlaing', 'thandar.hlaing.retail@example.com', '09-450001003', 'Naypyidaw', 'regular'),
    ('Kyaw', 'Zin', 'kyaw.zin.retail@example.com', '09-450001004', 'Yangon', 'new'),
    ('May', 'Thu', 'may.thu.retail@example.com', '09-450001005', 'Bago', 'regular'),
    ('Htet', 'Aung', 'htet.aung.retail@example.com', '09-450001006', 'Taunggyi', 'vip'),
    ('Nilar', 'Win', 'nilar.win.retail@example.com', '09-450001007', 'Mawlamyine', 'regular'),
    ('Min', 'Khant', 'min.khant.retail@example.com', '09-450001008', 'Mandalay', 'regular'),
    ('Ei', 'Phyo', 'ei.phyo.retail@example.com', '09-450001009', 'Yangon', 'new'),
    ('Ye', 'Naing', 'ye.naing.retail@example.com', '09-450001010', 'Pathein', 'regular'),
    ('Wai', 'Yan', 'wai.yan.retail@example.com', '09-450001011', 'Yangon', 'new'),
    ('Khin', 'Sandi', 'khin.sandi.retail@example.com', '09-450001012', 'Naypyidaw', 'vip'),
    ('Myo', 'Thant', 'myo.thant.retail@example.com', '09-450001013', 'Mandalay', 'regular'),
    ('Hnin', 'Yu', 'hnin.yu.retail@example.com', '09-450001014', 'Yangon', 'new'),
    ('Yamin', 'Oo', 'yamin.oo.retail@example.com', '09-450001015', 'Taunggyi', 'regular');

INSERT INTO products (
    product_name,
    category,
    unit_price
) VALUES
    ('Wireless Mouse', 'Electronics', 25000.00),
    ('Bluetooth Speaker', 'Electronics', 65000.00),
    ('Rice Bag 5kg', 'Grocery', 22000.00),
    ('Cooking Oil 1L', 'Grocery', 8500.00),
    ('Cotton T-Shirt', 'Fashion', 18000.00),
    ('Classic Jeans', 'Fashion', 45000.00),
    ('Face Wash', 'Beauty', 12000.00),
    ('Herbal Shampoo', 'Personal Care', 9500.00),
    ('LED Desk Lamp', 'Home', 35000.00),
    ('Notebook Set', 'Stationery', 6000.00),
    ('Ball Pen Pack', 'Stationery', 4500.00),
    ('Electric Kettle', 'Home', 55000.00);

INSERT INTO stores (
    store_name,
    city
) VALUES
    ('Yangon Main Branch', 'Yangon'),
    ('Mandalay Branch', 'Mandalay'),
    ('Naypyidaw Branch', 'Naypyidaw'),
    ('Taunggyi Branch', 'Taunggyi');

INSERT INTO orders (
    customer_id,
    store_id,
    order_date,
    order_status
) VALUES
    (1, 1, '2026-01-05', 'completed'),
    (2, 2, '2026-01-06', 'completed'),
    (3, 1, '2026-01-08', 'completed'),
    (4, 3, '2026-01-10', 'cancelled'),
    (1, 1, '2026-01-15', 'completed'),
    (5, 4, '2026-01-20', 'pending'),
    (6, 2, '2026-02-02', 'completed'),
    (7, 3, '2026-02-05', 'completed'),
    (8, 1, '2026-02-09', 'completed'),
    (9, 4, '2026-02-11', 'completed'),
    (10, 2, '2026-02-15', 'completed'),
    (11, 3, '2026-02-20', 'cancelled'),
    (12, 4, '2026-03-01', 'completed'),
    (13, 1, '2026-03-03', 'completed'),
    (14, 2, '2026-03-06', 'completed'),
    (15, 3, '2026-03-08', 'pending'),
    (2, 2, '2026-03-12', 'completed'),
    (3, 4, '2026-03-15', 'completed'),
    (6, 1, '2026-03-18', 'cancelled'),
    (7, 3, '2026-03-20', 'completed'),
    (8, 2, '2026-03-22', 'completed'),
    (1, 1, '2026-04-01', 'completed'),
    (5, 4, '2026-04-04', 'completed'),
    (9, 3, '2026-04-07', 'pending'),
    (10, 2, '2026-04-10', 'completed'),
    (15, 1, '2026-04-12', 'completed');

INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
) VALUES
    (1, 1, 1, 25000.00),
    (1, 10, 3, 6000.00),
    (2, 3, 2, 22000.00),
    (2, 4, 3, 8500.00),
    (3, 5, 2, 18000.00),
    (3, 7, 1, 12000.00),
    (3, 11, 2, 4500.00),
    (4, 2, 1, 65000.00),
    (5, 6, 1, 45000.00),
    (5, 8, 2, 9500.00),
    (6, 12, 1, 55000.00),
    (6, 10, 5, 6000.00),
    (7, 1, 2, 25000.00),
    (7, 2, 1, 65000.00),
    (8, 3, 1, 22000.00),
    (8, 4, 2, 8500.00),
    (8, 8, 1, 9500.00),
    (9, 9, 1, 35000.00),
    (9, 10, 4, 6000.00),
    (10, 5, 1, 18000.00),
    (10, 6, 1, 45000.00),
    (10, 7, 2, 12000.00),
    (11, 12, 1, 55000.00),
    (11, 11, 3, 4500.00),
    (12, 2, 2, 65000.00),
    (13, 3, 3, 22000.00),
    (13, 4, 4, 8500.00),
    (14, 1, 1, 25000.00),
    (14, 9, 2, 35000.00),
    (15, 8, 3, 9500.00),
    (15, 7, 2, 12000.00),
    (15, 10, 2, 6000.00),
    (16, 5, 2, 18000.00),
    (16, 11, 2, 4500.00),
    (17, 6, 2, 45000.00),
    (17, 5, 1, 18000.00),
    (18, 12, 1, 55000.00),
    (18, 4, 2, 8500.00),
    (19, 2, 1, 65000.00),
    (19, 9, 1, 35000.00),
    (20, 3, 2, 22000.00),
    (20, 8, 2, 9500.00),
    (20, 11, 4, 4500.00),
    (21, 1, 1, 25000.00),
    (21, 2, 1, 65000.00),
    (22, 7, 3, 12000.00),
    (22, 8, 2, 9500.00),
    (22, 10, 5, 6000.00),
    (23, 12, 1, 55000.00),
    (23, 9, 1, 35000.00),
    (23, 11, 2, 4500.00),
    (24, 6, 1, 45000.00),
    (24, 5, 2, 18000.00),
    (25, 3, 4, 22000.00),
    (25, 4, 5, 8500.00),
    (26, 2, 1, 65000.00),
    (26, 1, 1, 25000.00),
    (26, 10, 2, 6000.00);

INSERT INTO payments (
    order_id,
    payment_date,
    payment_method,
    payment_status,
    amount
) VALUES
    (1, '2026-01-05', 'mobile_wallet', 'paid', 43000.00),
    (2, '2026-01-06', 'cash', 'paid', 69500.00),
    (3, '2026-01-08', 'card', 'paid', 57000.00),
    (4, '2026-01-10', 'card', 'refunded', 65000.00),
    (5, '2026-01-15', 'mobile_wallet', 'paid', 64000.00),
    (6, '2026-01-20', 'bank_transfer', 'unpaid', 0.00),
    (7, '2026-02-02', 'card', 'paid', 115000.00),
    (8, '2026-02-05', 'cash', 'paid', 48500.00),
    (9, '2026-02-09', 'mobile_wallet', 'paid', 59000.00),
    (10, '2026-02-11', 'card', 'paid', 87000.00),
    (11, '2026-02-15', 'mobile_wallet', 'refunded', 68500.00),
    (12, '2026-02-20', 'cash', 'unpaid', 0.00),
    (13, '2026-03-01', 'bank_transfer', 'paid', 100000.00),
    (14, '2026-03-03', 'card', 'paid', 95000.00),
    (15, '2026-03-06', 'mobile_wallet', 'paid', 64500.00),
    (16, '2026-03-08', 'cash', 'unpaid', 0.00),
    (17, '2026-03-12', 'card', 'paid', 108000.00),
    (18, '2026-03-15', 'bank_transfer', 'paid', 72000.00),
    (19, '2026-03-18', 'card', 'refunded', 100000.00),
    (20, '2026-03-20', 'mobile_wallet', 'paid', 81000.00),
    (21, '2026-03-22', 'bank_transfer', 'unpaid', 0.00),
    (22, '2026-04-01', 'mobile_wallet', 'paid', 85000.00),
    (23, '2026-04-04', 'card', 'paid', 99000.00),
    (24, '2026-04-07', 'cash', 'unpaid', 0.00),
    (25, '2026-04-10', 'bank_transfer', 'paid', 130500.00),
    (26, '2026-04-12', 'card', 'paid', 102000.00);

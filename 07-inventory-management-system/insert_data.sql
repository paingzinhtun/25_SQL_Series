-- Day 7 - Inventory Management System
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Some products are below reorder point.
-- - Some products are at or below safety stock.
-- - Some products have zero stock.
-- - Some products are overstocked.
-- - Some products are fast-moving through high stock_out quantities.
-- - Some products are slow-moving through low recent stock_out quantities.

INSERT INTO suppliers (
    supplier_name,
    contact_person,
    phone_number,
    city
) VALUES
    ('Yangon Fresh Supply', 'Daw Khin Mar', '09-470001001', 'Yangon'),
    ('Mandalay Tech Wholesale', 'U Zaw Linn', '09-470001002', 'Mandalay'),
    ('Shwe Fashion Hub', 'Daw May Thu', '09-470001003', 'Bago'),
    ('Taunggyi Beauty Depot', 'U Htet Paing', '09-470001004', 'Taunggyi'),
    ('Naypyidaw Office Mart', 'Daw Mya Sandi', '09-470001005', 'Naypyidaw'),
    ('Mawlamyine Home Goods', 'U Ye Naing', '09-470001006', 'Mawlamyine');

INSERT INTO products (
    product_name,
    category,
    supplier_id,
    unit_cost,
    selling_price
) VALUES
    ('Rice Bag 5kg', 'Grocery', 1, 18000.00, 22000.00),
    ('Cooking Oil 1L', 'Grocery', 1, 6500.00, 8500.00),
    ('Instant Coffee Pack', 'Grocery', 1, 3500.00, 5000.00),
    ('Wireless Mouse', 'Electronics', 2, 18000.00, 25000.00),
    ('Bluetooth Speaker', 'Electronics', 2, 48000.00, 65000.00),
    ('USB-C Cable', 'Electronics', 2, 5000.00, 9000.00),
    ('Cotton T-Shirt', 'Fashion', 3, 12000.00, 18000.00),
    ('Classic Jeans', 'Fashion', 3, 32000.00, 45000.00),
    ('Face Wash', 'Beauty', 4, 8000.00, 12000.00),
    ('Herbal Shampoo', 'Personal Care', 4, 7000.00, 9500.00),
    ('Notebook Set', 'Stationery', 5, 4000.00, 6000.00),
    ('Ball Pen Pack', 'Stationery', 5, 2500.00, 4500.00),
    ('LED Desk Lamp', 'Home', 6, 25000.00, 35000.00),
    ('Electric Kettle', 'Home', 6, 42000.00, 55000.00),
    ('Hand Sanitizer', 'Personal Care', 4, 3000.00, 2800.00);

INSERT INTO warehouses (
    warehouse_name,
    city
) VALUES
    ('Yangon Main Warehouse', 'Yangon'),
    ('Mandalay Branch Store', 'Mandalay'),
    ('Naypyidaw Distribution Point', 'Naypyidaw'),
    ('Taunggyi Retail Branch', 'Taunggyi');

INSERT INTO inventory (
    product_id,
    warehouse_id,
    current_stock,
    last_updated
) VALUES
    (1, 1, 18, '2026-05-01'),
    (1, 2, 5, '2026-05-01'),
    (1, 3, 80, '2026-05-01'),
    (2, 1, 8, '2026-05-01'),
    (2, 2, 35, '2026-05-01'),
    (2, 4, 0, '2026-05-01'),
    (3, 1, 120, '2026-05-01'),
    (3, 2, 95, '2026-05-01'),
    (3, 4, 140, '2026-05-01'),
    (4, 1, 12, '2026-05-01'),
    (4, 2, 6, '2026-05-01'),
    (4, 3, 55, '2026-05-01'),
    (5, 1, 3, '2026-05-01'),
    (5, 2, 28, '2026-05-01'),
    (5, 4, 0, '2026-05-01'),
    (6, 1, 160, '2026-05-01'),
    (6, 2, 140, '2026-05-01'),
    (6, 3, 130, '2026-05-01'),
    (7, 1, 45, '2026-05-01'),
    (7, 2, 8, '2026-05-01'),
    (7, 4, 70, '2026-05-01'),
    (8, 1, 20, '2026-05-01'),
    (8, 2, 4, '2026-05-01'),
    (8, 3, 60, '2026-05-01'),
    (9, 1, 10, '2026-05-01'),
    (9, 3, 7, '2026-05-01'),
    (9, 4, 65, '2026-05-01'),
    (10, 1, 25, '2026-05-01'),
    (10, 2, 12, '2026-05-01'),
    (10, 4, 5, '2026-05-01'),
    (11, 1, 200, '2026-05-01'),
    (11, 2, 170, '2026-05-01'),
    (11, 3, 160, '2026-05-01'),
    (12, 1, 220, '2026-05-01'),
    (12, 2, 0, '2026-05-01'),
    (12, 4, 210, '2026-05-01'),
    (13, 1, 14, '2026-05-01'),
    (13, 3, 32, '2026-05-01'),
    (14, 1, 2, '2026-05-01'),
    (14, 4, 18, '2026-05-01'),
    (15, 1, 300, '2026-05-01'),
    (15, 2, 260, '2026-05-01');

INSERT INTO stock_movements (
    product_id,
    warehouse_id,
    movement_date,
    movement_type,
    quantity,
    reference_note
) VALUES
    (1, 1, '2026-04-01', 'stock_in', 100, 'Supplier delivery'),
    (1, 1, '2026-04-05', 'stock_out', 40, 'Retail sales'),
    (1, 1, '2026-04-12', 'stock_out', 35, 'Retail sales'),
    (1, 2, '2026-04-10', 'stock_out', 25, 'Branch sales'),
    (2, 1, '2026-04-02', 'stock_in', 80, 'Supplier delivery'),
    (2, 1, '2026-04-08', 'stock_out', 50, 'Retail sales'),
    (2, 4, '2026-04-18', 'stock_out', 20, 'Stock sold out'),
    (3, 1, '2026-03-01', 'stock_in', 150, 'Bulk purchase'),
    (3, 2, '2026-03-05', 'stock_out', 10, 'Small sales volume'),
    (3, 4, '2026-03-12', 'adjustment', 5, 'Positive count adjustment'),
    (4, 1, '2026-04-04', 'stock_in', 70, 'Tech supplier delivery'),
    (4, 1, '2026-04-09', 'stock_out', 45, 'Online sales'),
    (4, 2, '2026-04-15', 'stock_out', 22, 'Branch sales'),
    (5, 1, '2026-04-03', 'stock_in', 40, 'Electronics delivery'),
    (5, 1, '2026-04-11', 'stock_out', 35, 'High demand sales'),
    (5, 4, '2026-04-22', 'stock_out', 12, 'Stock sold out'),
    (6, 1, '2026-03-02', 'stock_in', 200, 'Bulk delivery'),
    (6, 1, '2026-03-09', 'stock_out', 20, 'Normal sales'),
    (6, 2, '2026-03-14', 'stock_out', 15, 'Normal sales'),
    (6, 3, '2026-03-20', 'adjustment', 10, 'Negative count adjustment noted'),
    (7, 1, '2026-04-01', 'stock_in', 120, 'Fashion delivery'),
    (7, 1, '2026-04-08', 'stock_out', 50, 'Retail sales'),
    (7, 2, '2026-04-14', 'stock_out', 30, 'Branch sales'),
    (8, 1, '2026-04-02', 'stock_in', 80, 'Fashion delivery'),
    (8, 1, '2026-04-16', 'stock_out', 25, 'Retail sales'),
    (8, 2, '2026-04-20', 'stock_out', 18, 'Branch sales'),
    (9, 1, '2026-04-03', 'stock_in', 70, 'Beauty supplier delivery'),
    (9, 1, '2026-04-10', 'stock_out', 45, 'Retail sales'),
    (9, 3, '2026-04-21', 'stock_out', 20, 'Branch sales'),
    (10, 1, '2026-04-04', 'stock_in', 90, 'Personal care delivery'),
    (10, 1, '2026-04-12', 'stock_out', 40, 'Retail sales'),
    (10, 4, '2026-04-23', 'stock_out', 18, 'Branch sales'),
    (11, 1, '2026-03-03', 'stock_in', 250, 'Stationery delivery'),
    (11, 1, '2026-03-15', 'stock_out', 20, 'School order'),
    (11, 2, '2026-03-19', 'stock_out', 15, 'Branch sales'),
    (12, 1, '2026-03-04', 'stock_in', 300, 'Stationery delivery'),
    (12, 1, '2026-03-20', 'stock_out', 12, 'Small sales volume'),
    (12, 2, '2026-04-07', 'stock_out', 40, 'Stock sold out'),
    (13, 1, '2026-04-05', 'stock_in', 60, 'Home goods delivery'),
    (13, 1, '2026-04-17', 'stock_out', 28, 'Retail sales'),
    (13, 3, '2026-04-25', 'stock_out', 12, 'Branch sales'),
    (14, 1, '2026-04-06', 'stock_in', 45, 'Home goods delivery'),
    (14, 1, '2026-04-13', 'stock_out', 38, 'High demand sales'),
    (14, 4, '2026-04-27', 'stock_out', 20, 'Branch sales'),
    (15, 1, '2026-03-06', 'stock_in', 350, 'Personal care bulk delivery'),
    (15, 1, '2026-03-18', 'stock_out', 8, 'Low demand sales'),
    (15, 2, '2026-03-25', 'stock_out', 5, 'Low demand sales'),
    (1, 3, '2026-04-24', 'stock_out', 30, 'Regional sales'),
    (2, 2, '2026-04-25', 'stock_out', 20, 'Branch sales'),
    (4, 3, '2026-04-26', 'stock_out', 18, 'Regional sales'),
    (5, 2, '2026-04-28', 'stock_out', 10, 'Branch sales'),
    (7, 4, '2026-04-29', 'stock_out', 22, 'Retail sales'),
    (9, 4, '2026-04-30', 'stock_out', 15, 'Retail sales'),
    (11, 3, '2026-04-30', 'stock_out', 10, 'Office sales'),
    (12, 4, '2026-04-30', 'stock_out', 6, 'Office sales'),
    (15, 2, '2026-04-30', 'stock_out', 4, 'Low demand sales');

INSERT INTO reorder_rules (
    product_id,
    warehouse_id,
    reorder_point,
    reorder_quantity,
    safety_stock
) VALUES
    (1, 1, 25, 80, 10),
    (1, 2, 20, 70, 8),
    (2, 1, 20, 60, 10),
    (2, 4, 15, 50, 5),
    (4, 1, 15, 50, 8),
    (4, 2, 12, 45, 6),
    (5, 1, 10, 40, 5),
    (5, 4, 8, 35, 4),
    (7, 1, 30, 70, 12),
    (7, 2, 20, 60, 10),
    (8, 2, 15, 45, 8),
    (9, 1, 18, 50, 10),
    (9, 3, 12, 40, 8),
    (10, 4, 15, 50, 6),
    (11, 1, 80, 90, 30),
    (11, 2, 70, 80, 25),
    (12, 1, 90, 100, 35),
    (12, 2, 40, 70, 15),
    (13, 1, 20, 45, 10),
    (14, 1, 10, 35, 5),
    (14, 4, 15, 40, 8),
    (15, 1, 90, 100, 30),
    (15, 2, 80, 90, 25),
    (3, 1, 50, 60, 20),
    (6, 1, 60, 70, 25);

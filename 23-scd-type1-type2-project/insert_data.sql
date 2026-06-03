-- Day 23: Slowly Changing Dimensions (SCD Type 1 & Type 2)
-- insert_data.sql
-- We will simulate initial data load, and later ETL files will handle updates.

-- ==========================================
-- 1. Initial Load: SCD Type 1 Customers
-- ==========================================
INSERT INTO dim_customer_scd1 (customer_id, customer_name, city, region, customer_segment, email) VALUES
('C001', 'Aung Kyaw', 'Yangon', 'Yangon Region', 'Regular', 'aung.k@example.com'),
('C002', 'Su Su', 'Mandalay', 'Mandalay Region', 'Premium', 'susu@example.com'),
('C003', 'Kyaw Zin', 'Naypyidaw', 'Naypyidaw Union Territory', 'Regular', 'kyaw.z@example.com'),
('C004', 'Mya Thandar', 'Bago', 'Bago Region', 'VIP', 'mya.t@example.com'),
('C005', 'Zayar Lin', 'Taunggyi', 'Shan State', 'Regular', 'zayar.l@example.com'),
('C006', 'Hla Hla', 'Mawlamyine', 'Mon State', 'Premium', 'hla.h@example.com'),
('C007', 'Myo Min', 'Pathein', 'Ayeyarwady Region', 'Regular', 'myo.m@example.com'),
('C008', 'Khin Zaw', 'Sittwe', 'Rakhine State', 'Premium', 'khin.z@example.com'),
('C009', 'Nilar Win', 'Monywa', 'Sagaing Region', 'Regular', 'nilar.w@example.com'),
('C010', 'Tin Tun', 'Meiktila', 'Mandalay Region', 'VIP', 'tin.t@example.com'),
('C011', 'Aye Aye', 'Pyay', 'Bago Region', 'Regular', 'aye.a@example.com'),
('C012', 'Bo Bo', 'Hpa-An', 'Kayin State', 'Regular', 'bo.b@example.com'),
('C013', 'San San', 'Dawei', 'Tanintharyi Region', 'Premium', 'san.s@example.com'),
('C014', 'Zaw Myo', 'Magway', 'Magway Region', 'Regular', 'zaw.m@example.com'),
('C015', 'Kyi Kyi', 'Loikaw', 'Kayah State', 'VIP', 'kyi.k@example.com'),
('C016', 'Tun Tun', 'Hakha', 'Chin State', 'Regular', 'tun.t@example.com'),
('C017', 'Khaing Khaing', 'Myitkyina', 'Kachin State', 'Premium', 'khaing.k@example.com'),
('C018', 'Aung Aung', 'Bhamo', 'Kachin State', 'Regular', 'aung.a@example.com'),
('C019', 'Zin Zin', 'Lashio', 'Shan State', 'Regular', 'zin.z@example.com'),
('C020', 'Win Win', 'Kengtung', 'Shan State', 'VIP', 'win.w@example.com'),
('C021', 'Moe Moe', 'Tachileik', 'Shan State', 'Regular', 'moe.m@example.com'),
('C022', 'Aung Myint', 'Myawaddy', 'Kayin State', 'Premium', 'aung.myint@example.com'),
('C023', 'Nu Nu', 'Pyin Oo Lwin', 'Mandalay Region', 'Regular', 'nu.nu@example.com'),
('C024', 'Naing Naing', 'Kalay', 'Sagaing Region', 'Regular', 'naing.n@example.com'),
('C025', 'Phyo Phyo', 'Pakokku', 'Magway Region', 'VIP', 'phyo.p@example.com'),
('C026', 'Yin Yin', 'Mrauk U', 'Rakhine State', 'Regular', 'yin.y@example.com'),
('C027', 'Thu Thu', 'Thandwe', 'Rakhine State', 'Premium', 'thu.t@example.com'),
('C028', 'Kyaw Kyaw', 'Kyaukpyu', 'Rakhine State', 'Regular', 'kyaw.k@example.com'),
('C029', 'Wai Wai', 'Bago', 'Bago Region', 'Regular', 'wai.w@example.com'),
('C030', 'Soe Soe', 'Yangon', 'Yangon Region', 'VIP', 'soe.s@example.com');

-- ==========================================
-- 2. Initial Load: SCD Type 2 Customers (Historical records)
-- ==========================================
-- Customer C001 moved from Bago to Yangon
INSERT INTO dim_customer_scd2 (customer_id, customer_name, city, region, customer_segment, email, effective_start_date, effective_end_date, is_current, version_number) VALUES
('C001', 'Aung Kyaw', 'Bago', 'Bago Region', 'Regular', 'aung.k@example.com', '2023-01-01', '2023-06-30', FALSE, 1),
('C001', 'Aung Kyaw', 'Yangon', 'Yangon Region', 'Regular', 'aung.k@example.com', '2023-07-01', NULL, TRUE, 2),
-- Customer C002 upgraded segment
('C002', 'Su Su', 'Mandalay', 'Mandalay Region', 'Regular', 'susu@example.com', '2023-01-01', '2023-08-15', FALSE, 1),
('C002', 'Su Su', 'Mandalay', 'Mandalay Region', 'Premium', 'susu@example.com', '2023-08-16', NULL, TRUE, 2),
-- Rest of customers (current only)
('C003', 'Kyaw Zin', 'Naypyidaw', 'Naypyidaw Union Territory', 'Regular', 'kyaw.z@example.com', '2023-01-01', NULL, TRUE, 1),
('C004', 'Mya Thandar', 'Bago', 'Bago Region', 'VIP', 'mya.t@example.com', '2023-01-01', NULL, TRUE, 1),
('C005', 'Zayar Lin', 'Taunggyi', 'Shan State', 'Regular', 'zayar.l@example.com', '2023-01-01', NULL, TRUE, 1),
('C006', 'Hla Hla', 'Mawlamyine', 'Mon State', 'Premium', 'hla.h@example.com', '2023-01-01', NULL, TRUE, 1),
('C007', 'Myo Min', 'Pathein', 'Ayeyarwady Region', 'Regular', 'myo.m@example.com', '2023-01-01', NULL, TRUE, 1),
('C008', 'Khin Zaw', 'Sittwe', 'Rakhine State', 'Premium', 'khin.z@example.com', '2023-01-01', NULL, TRUE, 1),
('C009', 'Nilar Win', 'Monywa', 'Sagaing Region', 'Regular', 'nilar.w@example.com', '2023-01-01', NULL, TRUE, 1),
('C010', 'Tin Tun', 'Meiktila', 'Mandalay Region', 'VIP', 'tin.t@example.com', '2023-01-01', NULL, TRUE, 1),
('C011', 'Aye Aye', 'Pyay', 'Bago Region', 'Regular', 'aye.a@example.com', '2023-01-01', NULL, TRUE, 1),
('C012', 'Bo Bo', 'Hpa-An', 'Kayin State', 'Regular', 'bo.b@example.com', '2023-01-01', NULL, TRUE, 1),
('C013', 'San San', 'Dawei', 'Tanintharyi Region', 'Premium', 'san.s@example.com', '2023-01-01', NULL, TRUE, 1),
('C014', 'Zaw Myo', 'Magway', 'Magway Region', 'Regular', 'zaw.m@example.com', '2023-01-01', NULL, TRUE, 1),
('C015', 'Kyi Kyi', 'Loikaw', 'Kayah State', 'VIP', 'kyi.k@example.com', '2023-01-01', NULL, TRUE, 1),
('C016', 'Tun Tun', 'Hakha', 'Chin State', 'Regular', 'tun.t@example.com', '2023-01-01', NULL, TRUE, 1),
('C017', 'Khaing Khaing', 'Myitkyina', 'Kachin State', 'Premium', 'khaing.k@example.com', '2023-01-01', NULL, TRUE, 1),
('C018', 'Aung Aung', 'Bhamo', 'Kachin State', 'Regular', 'aung.a@example.com', '2023-01-01', NULL, TRUE, 1),
('C019', 'Zin Zin', 'Lashio', 'Shan State', 'Regular', 'zin.z@example.com', '2023-01-01', NULL, TRUE, 1),
('C020', 'Win Win', 'Kengtung', 'Shan State', 'VIP', 'win.w@example.com', '2023-01-01', NULL, TRUE, 1),
('C021', 'Moe Moe', 'Tachileik', 'Shan State', 'Regular', 'moe.m@example.com', '2023-01-01', NULL, TRUE, 1),
('C022', 'Aung Myint', 'Myawaddy', 'Kayin State', 'Premium', 'aung.myint@example.com', '2023-01-01', NULL, TRUE, 1),
('C023', 'Nu Nu', 'Pyin Oo Lwin', 'Mandalay Region', 'Regular', 'nu.nu@example.com', '2023-01-01', NULL, TRUE, 1),
('C024', 'Naing Naing', 'Kalay', 'Sagaing Region', 'Regular', 'naing.n@example.com', '2023-01-01', NULL, TRUE, 1),
('C025', 'Phyo Phyo', 'Pakokku', 'Magway Region', 'VIP', 'phyo.p@example.com', '2023-01-01', NULL, TRUE, 1),
('C026', 'Yin Yin', 'Mrauk U', 'Rakhine State', 'Regular', 'yin.y@example.com', '2023-01-01', NULL, TRUE, 1),
('C027', 'Thu Thu', 'Thandwe', 'Rakhine State', 'Premium', 'thu.t@example.com', '2023-01-01', NULL, TRUE, 1),
('C028', 'Kyaw Kyaw', 'Kyaukpyu', 'Rakhine State', 'Regular', 'kyaw.k@example.com', '2023-01-01', NULL, TRUE, 1),
('C029', 'Wai Wai', 'Bago', 'Bago Region', 'Regular', 'wai.w@example.com', '2023-01-01', NULL, TRUE, 1),
('C030', 'Soe Soe', 'Yangon', 'Yangon Region', 'VIP', 'soe.s@example.com', '2023-01-01', NULL, TRUE, 1);

-- ==========================================
-- 3. Initial Load: Employees (SCD Type 2)
-- ==========================================
-- Employee E001 changed department
INSERT INTO dim_employee_scd2 (employee_id, employee_name, department, role, city, salary_band, effective_start_date, effective_end_date, is_current, version_number) VALUES
('E001', 'U Thant', 'Sales', 'Sales Associate', 'Yangon', 'Band A', '2023-01-01', '2023-05-31', FALSE, 1),
('E001', 'U Thant', 'Management', 'Store Manager', 'Yangon', 'Band C', '2023-06-01', NULL, TRUE, 2),
-- Employee E002 changed salary band
('E002', 'Daw Khin', 'Sales', 'Senior Sales', 'Mandalay', 'Band B', '2023-01-01', '2023-09-30', FALSE, 1),
('E002', 'Daw Khin', 'Sales', 'Senior Sales', 'Mandalay', 'Band C', '2023-10-01', NULL, TRUE, 2),
-- Others
('E003', 'Ko Ko', 'Logistics', 'Driver', 'Yangon', 'Band A', '2023-01-01', NULL, TRUE, 1),
('E004', 'Ma Ma', 'HR', 'HR Specialist', 'Naypyidaw', 'Band B', '2023-01-01', NULL, TRUE, 1),
('E005', 'Nyi Nyi', 'IT', 'IT Support', 'Yangon', 'Band B', '2023-01-01', NULL, TRUE, 1),
('E006', 'Phyu Phyu', 'Finance', 'Accountant', 'Yangon', 'Band C', '2023-01-01', NULL, TRUE, 1),
('E007', 'Myat Myat', 'Sales', 'Sales Associate', 'Taunggyi', 'Band A', '2023-01-01', NULL, TRUE, 1),
('E008', 'Zaw Zaw', 'Sales', 'Sales Associate', 'Bago', 'Band A', '2023-01-01', NULL, TRUE, 1),
('E009', 'Lin Lin', 'Logistics', 'Manager', 'Yangon', 'Band D', '2023-01-01', NULL, TRUE, 1),
('E010', 'Su Myat', 'Marketing', 'Specialist', 'Mandalay', 'Band B', '2023-01-01', NULL, TRUE, 1),
('E011', 'Thet Thet', 'Sales', 'Sales Associate', 'Mawlamyine', 'Band A', '2023-01-01', NULL, TRUE, 1),
('E012', 'Kyaw Swar', 'IT', 'Developer', 'Yangon', 'Band C', '2023-01-01', NULL, TRUE, 1),
('E013', 'Win Htut', 'Management', 'Regional Manager', 'Naypyidaw', 'Band E', '2023-01-01', NULL, TRUE, 1),
('E014', 'Zin Mar', 'HR', 'HR Manager', 'Yangon', 'Band D', '2023-01-01', NULL, TRUE, 1),
('E015', 'Aung Pyae', 'Finance', 'Clerk', 'Mandalay', 'Band A', '2023-01-01', NULL, TRUE, 1);

-- ==========================================
-- 4. Initial Load: Products (SCD Type 2)
-- ==========================================
-- Product P001 changed price band
INSERT INTO dim_product_scd2 (product_id, product_name, category, subcategory, brand, price_band, effective_start_date, effective_end_date, is_current, version_number) VALUES
('P001', 'Laptop Pro', 'Electronics', 'Laptops', 'TechBrand', 'High', '2023-01-01', '2023-11-30', FALSE, 1),
('P001', 'Laptop Pro', 'Electronics', 'Laptops', 'TechBrand', 'Premium', '2023-12-01', NULL, TRUE, 2),
-- Product P002 changed category
('P002', 'Smart Watch X', 'Accessories', 'Wearables', 'TechBrand', 'Medium', '2023-01-01', '2023-04-15', FALSE, 1),
('P002', 'Smart Watch X', 'Electronics', 'Wearables', 'TechBrand', 'Medium', '2023-04-16', NULL, TRUE, 2),
-- Others
('P003', 'Wireless Mouse', 'Accessories', 'Input Devices', 'MouseCo', 'Low', '2023-01-01', NULL, TRUE, 1),
('P004', 'Mechanical Keyboard', 'Accessories', 'Input Devices', 'KeyCo', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P005', 'Gaming Monitor', 'Electronics', 'Displays', 'ScreenPro', 'High', '2023-01-01', NULL, TRUE, 1),
('P006', 'Office Chair', 'Furniture', 'Chairs', 'ComfortSit', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P007', 'Standing Desk', 'Furniture', 'Desks', 'ErgoFit', 'High', '2023-01-01', NULL, TRUE, 1),
('P008', 'Notebook', 'Stationery', 'Paper', 'WriteWell', 'Low', '2023-01-01', NULL, TRUE, 1),
('P009', 'Gel Pens (Pack)', 'Stationery', 'Writing', 'WriteWell', 'Low', '2023-01-01', NULL, TRUE, 1),
('P010', 'Coffee Maker', 'Appliances', 'Kitchen', 'BrewMaster', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P011', 'Microwave', 'Appliances', 'Kitchen', 'HeatFast', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P012', 'Bluetooth Speaker', 'Electronics', 'Audio', 'SoundMax', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P013', 'Noise Cancelling Headphones', 'Electronics', 'Audio', 'SoundMax', 'High', '2023-01-01', NULL, TRUE, 1),
('P014', 'Desk Lamp', 'Furniture', 'Lighting', 'BrightLite', 'Low', '2023-01-01', NULL, TRUE, 1),
('P015', 'Water Bottle', 'Accessories', 'Lifestyle', 'HydroCool', 'Low', '2023-01-01', NULL, TRUE, 1),
('P016', 'Backpack', 'Accessories', 'Bags', 'CarryAll', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P017', 'External Hard Drive', 'Electronics', 'Storage', 'DataSafe', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P018', 'USB Flash Drive', 'Electronics', 'Storage', 'DataSafe', 'Low', '2023-01-01', NULL, TRUE, 1),
('P019', 'Webcam', 'Electronics', 'Video', 'ViewPro', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P020', 'Ergonomic Mouse', 'Accessories', 'Input Devices', 'MouseCo', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P021', 'Mouse Pad', 'Accessories', 'Desk', 'PadSoft', 'Low', '2023-01-01', NULL, TRUE, 1),
('P022', 'Tablet', 'Electronics', 'Tablets', 'TechBrand', 'High', '2023-01-01', NULL, TRUE, 1),
('P023', 'Stylus Pen', 'Accessories', 'Input Devices', 'TechBrand', 'Medium', '2023-01-01', NULL, TRUE, 1),
('P024', 'Printer', 'Electronics', 'Office', 'PrintFast', 'High', '2023-01-01', NULL, TRUE, 1),
('P025', 'Printer Ink', 'Stationery', 'Office Supplies', 'PrintFast', 'Medium', '2023-01-01', NULL, TRUE, 1);

-- ==========================================
-- 5. Fact Sales Load
-- Generate sales making sure to match dates with effective dates!
-- ==========================================
DO $$
DECLARE
    i INT;
    v_sales_date DATE;
    v_customer_sk INT;
    v_employee_sk INT;
    v_product_sk INT;
    v_customer_id VARCHAR(50);
    v_employee_id VARCHAR(50);
    v_product_id VARCHAR(50);
    v_qty INT;
    v_price DECIMAL;
BEGIN
    FOR i IN 1..250 LOOP
        -- Random date between 2023-01-01 and 2023-12-31
        v_sales_date := DATE '2023-01-01' + (random() * 364)::INT;
        
        -- Pick random business IDs
        v_customer_id := 'C' || LPAD((floor(random() * 30) + 1)::text, 3, '0');
        v_employee_id := 'E' || LPAD((floor(random() * 15) + 1)::text, 3, '0');
        v_product_id := 'P' || LPAD((floor(random() * 25) + 1)::text, 3, '0');
        
        -- Lookup EXACT surrogate key for that date (This is crucial for historical accuracy!)
        SELECT customer_sk INTO v_customer_sk FROM dim_customer_scd2
        WHERE customer_id = v_customer_id
          AND v_sales_date >= effective_start_date
          AND (v_sales_date <= effective_end_date OR effective_end_date IS NULL)
        LIMIT 1;

        SELECT employee_sk INTO v_employee_sk FROM dim_employee_scd2
        WHERE employee_id = v_employee_id
          AND v_sales_date >= effective_start_date
          AND (v_sales_date <= effective_end_date OR effective_end_date IS NULL)
        LIMIT 1;

        SELECT product_sk INTO v_product_sk FROM dim_product_scd2
        WHERE product_id = v_product_id
          AND v_sales_date >= effective_start_date
          AND (v_sales_date <= effective_end_date OR effective_end_date IS NULL)
        LIMIT 1;

        -- Generate facts
        v_qty := floor(random() * 5) + 1;
        v_price := (random() * 100 + 10)::NUMERIC(10,2);
        
        -- Fallback if random date logic missed a boundary (shouldn't happen with our data)
        IF v_customer_sk IS NOT NULL AND v_employee_sk IS NOT NULL AND v_product_sk IS NOT NULL THEN
            INSERT INTO fact_sales (order_id, sales_date, customer_sk, employee_sk, product_sk, quantity, total_sales_amount, profit_amount)
            VALUES (
                'ORD-' || LPAD(i::text, 5, '0'),
                v_sales_date,
                v_customer_sk,
                v_employee_sk,
                v_product_sk,
                v_qty,
                v_qty * v_price,
                (v_qty * v_price) * 0.2 -- 20% profit margin
            );
        END IF;
    END LOOP;
END $$;
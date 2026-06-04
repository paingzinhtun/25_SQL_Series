-- Day 24: KPI Dashboard Engineering Using SQL
-- insert_data.sql

-- Insert 50 Customers
INSERT INTO customers (customer_id, customer_name, city, region, customer_segment, signup_date, customer_status)
SELECT 
    'C' || LPAD(i::text, 3, '0'),
    'Customer ' || i,
    CASE i % 7 
        WHEN 0 THEN 'Yangon' 
        WHEN 1 THEN 'Mandalay' 
        WHEN 2 THEN 'Naypyidaw' 
        WHEN 3 THEN 'Bago' 
        WHEN 4 THEN 'Taunggyi' 
        WHEN 5 THEN 'Mawlamyine' 
        ELSE 'Pathein' 
    END,
    CASE i % 7 
        WHEN 0 THEN 'Yangon Region' 
        WHEN 1 THEN 'Mandalay Region' 
        WHEN 2 THEN 'Naypyidaw Union Territory' 
        WHEN 3 THEN 'Bago Region' 
        WHEN 4 THEN 'Shan State' 
        WHEN 5 THEN 'Mon State' 
        ELSE 'Ayeyarwady Region' 
    END,
    CASE i % 4 
        WHEN 0 THEN 'VIP' 
        WHEN 1 THEN 'Premium' 
        WHEN 2 THEN 'Regular' 
        ELSE 'Occasional' 
    END,
    DATE '2022-01-01' + (random() * 700)::INT,
    CASE i % 5 
        WHEN 0 THEN 'churned' 
        WHEN 1 THEN 'inactive' 
        ELSE 'active' 
    END
FROM generate_series(1, 50) i;

-- Insert 40 Products
INSERT INTO products (product_id, product_name, category, subcategory, brand, unit_price)
SELECT 
    'P' || LPAD(i::text, 3, '0'),
    'Product ' || i,
    CASE i % 5 
        WHEN 0 THEN 'Electronics' 
        WHEN 1 THEN 'Clothing' 
        WHEN 2 THEN 'Home & Garden' 
        WHEN 3 THEN 'Sports' 
        ELSE 'Toys' 
    END,
    CASE i % 5 
        WHEN 0 THEN 'Mobile' 
        WHEN 1 THEN 'Shirts' 
        WHEN 2 THEN 'Furniture' 
        WHEN 3 THEN 'Fitness' 
        ELSE 'Board Games' 
    END,
    'Brand ' || (i % 10 + 1),
    (random() * 490 + 10)::DECIMAL(10,2)
FROM generate_series(1, 40) i;

-- Insert 10 Stores
INSERT INTO stores (store_id, store_name, city, region, store_type) VALUES
('S001', 'Yangon Flagship', 'Yangon', 'Yangon Region', 'Flagship'),
('S002', 'Mandalay Central', 'Mandalay', 'Mandalay Region', 'Flagship'),
('S003', 'Naypyidaw Hub', 'Naypyidaw', 'Naypyidaw Union Territory', 'Standard'),
('S004', 'Bago Outlet', 'Bago', 'Bago Region', 'Standard'),
('S005', 'Taunggyi Mall', 'Taunggyi', 'Shan State', 'Standard'),
('S006', 'Mawlamyine Store', 'Mawlamyine', 'Mon State', 'Standard'),
('S007', 'Pathein Central', 'Pathein', 'Ayeyarwady Region', 'Standard'),
('S008', 'Yangon Kiosk 1', 'Yangon', 'Yangon Region', 'Kiosk'),
('S009', 'Mandalay Kiosk 1', 'Mandalay', 'Mandalay Region', 'Kiosk'),
('S010', 'Naypyidaw Kiosk', 'Naypyidaw', 'Naypyidaw Union Territory', 'Kiosk');

-- Insert 12 Marketing Campaigns
INSERT INTO marketing_campaigns (campaign_id, campaign_name, campaign_type, start_date, end_date, campaign_cost) VALUES
('MC01', 'New Year Promo 2023', 'conversion', '2023-01-01', '2023-01-15', 5000.00),
('MC02', 'Spring Awareness', 'awareness', '2023-03-01', '2023-03-31', 8000.00),
('MC03', 'Thingyan Festival Sale', 'conversion', '2023-04-10', '2023-04-17', 12000.00),
('MC04', 'Customer Winback', 'retention', '2023-05-01', '2023-05-31', 3000.00),
('MC05', 'Refer a Friend June', 'referral', '2023-06-01', '2023-06-30', 2000.00),
('MC06', 'Mid-Year Clearance', 'conversion', '2023-07-01', '2023-07-15', 6000.00),
('MC07', 'Brand Awareness Q3', 'awareness', '2023-08-01', '2023-08-31', 7500.00),
('MC08', 'September Loyalty', 'retention', '2023-09-01', '2023-09-30', 4000.00),
('MC09', 'Thadingyut Special', 'conversion', '2023-10-20', '2023-10-31', 10000.00),
('MC10', 'Black Friday Deals', 'conversion', '2023-11-20', '2023-11-30', 15000.00),
('MC11', 'Holiday Awareness', 'awareness', '2023-12-01', '2023-12-20', 9000.00),
('MC12', 'Christmas End of Year', 'conversion', '2023-12-21', '2023-12-31', 11000.00);

-- Insert 12 Monthly Targets (for year 2023)
INSERT INTO monthly_targets (target_id, target_month, target_year, revenue_target, profit_target, customer_growth_target)
SELECT 
    'T' || LPAD(i::text, 2, '0'),
    i,
    2023,
    (50000 + (i * 2000))::DECIMAL(12,2),
    (15000 + (i * 600))::DECIMAL(12,2),
    20 + i
FROM generate_series(1, 12) i;

-- Generate Sales Orders and Order Items
DO $$
DECLARE
    i INT;
    j INT;
    v_order_id VARCHAR(50);
    v_customer_id VARCHAR(50);
    v_store_id VARCHAR(50);
    v_order_date DATE;
    v_item_count INT;
    v_product_id VARCHAR(50);
    v_qty INT;
    v_price DECIMAL;
    v_discount DECIMAL;
    v_total DECIMAL;
    v_profit DECIMAL;
    v_order_total DECIMAL;
BEGIN
    FOR i IN 1..400 LOOP
        v_order_id := 'ORD' || LPAD(i::text, 4, '0');
        v_customer_id := 'C' || LPAD((floor(random() * 50) + 1)::text, 3, '0');
        v_store_id := CASE WHEN random() > 0.3 THEN 'S' || LPAD((floor(random() * 10) + 1)::text, 3, '0') ELSE NULL END;
        v_order_date := DATE '2023-01-01' + (random() * 364)::INT;
        v_order_total := 0;

        INSERT INTO sales_orders (order_id, customer_id, store_id, order_date, order_status, sales_channel, total_order_amount)
        VALUES (
            v_order_id,
            v_customer_id,
            v_store_id,
            v_order_date,
            CASE (i % 10) WHEN 0 THEN 'cancelled' WHEN 1 THEN 'returned' WHEN 2 THEN 'pending' ELSE 'completed' END,
            CASE WHEN v_store_id IS NOT NULL THEN 'in_store' ELSE (CASE (i % 3) WHEN 0 THEN 'website' WHEN 1 THEN 'mobile_app' ELSE 'marketplace' END) END,
            0 -- will update later
        );

        v_item_count := floor(random() * 4) + 1; -- 1 to 4 items per order
        FOR j IN 1..v_item_count LOOP
            v_product_id := 'P' || LPAD((floor(random() * 40) + 1)::text, 3, '0');
            SELECT unit_price INTO v_price FROM products WHERE product_id = v_product_id;
            
            v_qty := floor(random() * 3) + 1;
            v_discount := ROUND((v_price * v_qty * (random() * 0.1))::numeric, 2);
            v_total := (v_price * v_qty) - v_discount;
            v_profit := ROUND((v_total * (0.15 + random() * 0.2))::numeric, 2); -- 15-35% profit margin
            
            v_order_total := v_order_total + v_total;

            INSERT INTO sales_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_amount, total_sales_amount, profit_amount)
            VALUES (
                v_order_id || '-' || j,
                v_order_id,
                v_product_id,
                v_qty,
                v_price,
                v_discount,
                v_total,
                v_profit
            );
        END LOOP;

        UPDATE sales_orders SET total_order_amount = v_order_total WHERE order_id = v_order_id;
    END LOOP;
END $$;

-- Generate 500 Customer Activities
DO $$
DECLARE
    i INT;
    v_customer_id VARCHAR(50);
    v_activity_date DATE;
BEGIN
    FOR i IN 1..500 LOOP
        v_customer_id := 'C' || LPAD((floor(random() * 50) + 1)::text, 3, '0');
        v_activity_date := DATE '2023-01-01' + (random() * 364)::INT;
        
        INSERT INTO customer_activity (customer_id, activity_date, activity_type)
        VALUES (
            v_customer_id,
            v_activity_date,
            CASE (floor(random() * 10)::INT)
                WHEN 0 THEN 'support_request'
                WHEN 1 THEN 'review'
                WHEN 2 THEN 'referral'
                WHEN 3 THEN 'purchase'
                WHEN 4 THEN 'purchase'
                ELSE 'login'
            END
        );
    END LOOP;
END $$;
-- Day 25: End-to-End Data Pipeline
-- insert_raw_data.sql: Generates messy raw data to simulate real-world ingestion.

-- Insert messy customers
INSERT INTO raw_customers (customer_id, customer_name, phone_number, city, region)
SELECT 
    'C' || LPAD(i::text, 3, '0'),
    CASE WHEN random() > 0.9 THEN '  customer ' || i || '  ' ELSE 'Customer ' || i END, -- Extra spaces
    CASE WHEN random() > 0.8 THEN 'N/A' ELSE '09-' || (floor(random() * 900000000) + 100000000)::text END, -- Bad formats
    CASE i % 7 
        WHEN 0 THEN 'YGN' -- Inconsistent naming
        WHEN 1 THEN 'yangon' -- Casing issue
        WHEN 2 THEN 'Naypyidaw' 
        WHEN 3 THEN 'Bago' 
        WHEN 4 THEN 'Taunggyi' 
        WHEN 5 THEN 'Mawlamyine' 
        ELSE NULL -- Nulls
    END,
    CASE i % 3 WHEN 0 THEN 'Yangon Region' WHEN 1 THEN 'Mandalay Region' ELSE 'Shan State' END
FROM generate_series(1, 60) i;

-- Insert duplicates into raw_customers intentionally
INSERT INTO raw_customers (customer_id, customer_name, phone_number, city, region)
VALUES 
('C001', 'Customer 1', '09-123456789', 'Yangon', 'Yangon Region'),
('C005', 'Customer 5', '09-987654321', 'Bago', 'Bago Region');

-- Insert messy products
INSERT INTO raw_products (product_id, product_name, category, price)
SELECT 
    'P' || LPAD(i::text, 3, '0'),
    'Product ' || i,
    CASE i % 5 
        WHEN 0 THEN 'electronics ' -- Trailing space
        WHEN 1 THEN 'Clothing' 
        WHEN 2 THEN 'HOME' -- Caps
        WHEN 3 THEN 'Sports' 
        ELSE 'Toys' 
    END,
    (random() * 490 + 10)::DECIMAL(10,2)::VARCHAR -- Text prices
FROM generate_series(1, 40) i;

-- Insert messy stores
INSERT INTO raw_stores (store_id, store_name, location) VALUES
('S001', 'Yangon Main', 'Yangon Center'),
('S002', 'Mandalay Hub', 'Mandalay Downtown'),
('S003', 'Naypyidaw Branch', 'Naypyidaw Capital'),
('S004', 'Bago Outlet', 'Bago Highway'),
('S005', 'Taunggyi Mall', 'Taunggyi Hill'),
('S006', 'Mawlamyine Market', 'Mawlamyine Beach'),
('S007', 'Pathein Store', 'Pathein Delta'),
('S008', 'Pyay Station', 'Pyay Route'),
('S009', 'Lashio Post', 'Lashio North'),
('S010', 'Monywa Hub', 'Monywa Central');

-- Generate messy orders
DO $$
DECLARE
    i INT;
    v_date DATE;
    v_date_str VARCHAR;
BEGIN
    FOR i IN 1..500 LOOP
        v_date := DATE '2023-01-01' + (random() * 364)::INT;
        
        -- Messy date formats randomly
        IF random() > 0.8 THEN
            v_date_str := TO_CHAR(v_date, 'MM/DD/YYYY');
        ELSE
            v_date_str := TO_CHAR(v_date, 'YYYY-MM-DD');
        END IF;

        INSERT INTO raw_orders (order_id, customer_id, store_id, order_date, status, channel)
        VALUES (
            'ORD' || LPAD(i::text, 4, '0'),
            'C' || LPAD((floor(random() * 60) + 1)::text, 3, '0'),
            CASE WHEN random() > 0.3 THEN 'S' || LPAD((floor(random() * 10) + 1)::text, 3, '0') ELSE NULL END,
            v_date_str,
            CASE (i % 10) WHEN 0 THEN 'CANCELLED' WHEN 1 THEN 'returned' WHEN 2 THEN 'Pending ' ELSE 'Completed' END, -- Inconsistent casing and spaces
            CASE WHEN random() > 0.5 THEN 'Online' ELSE 'Offline' END
        );
    END LOOP;
END $$;

-- Generate messy order items
DO $$
DECLARE
    i INT;
    j INT;
    v_qty INT;
    v_qty_str VARCHAR;
BEGIN
    FOR i IN 1..500 LOOP
        FOR j IN 1..(floor(random() * 3) + 1) LOOP
            v_qty := floor(random() * 5) + 1;
            
            -- Inject negative quantities simulating refunds/errors
            IF random() > 0.95 THEN
                v_qty_str := (-v_qty)::VARCHAR;
            ELSIF random() > 0.95 THEN
                v_qty_str := 'NULL'; -- String literal "NULL" error
            ELSE
                v_qty_str := v_qty::VARCHAR;
            END IF;

            INSERT INTO raw_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount)
            VALUES (
                'ORD' || LPAD(i::text, 4, '0') || '-' || j,
                'ORD' || LPAD(i::text, 4, '0'),
                'P' || LPAD((floor(random() * 40) + 1)::text, 3, '0'),
                v_qty_str,
                (random() * 100 + 10)::DECIMAL(10,2)::VARCHAR,
                (random() * 5)::DECIMAL(10,2)::VARCHAR
            );
        END LOOP;
    END LOOP;
END $$;
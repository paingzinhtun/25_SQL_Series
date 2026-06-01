-- Day 21 - Real-Time Order Tracking System (Simulated with SQL)
-- PostgreSQL sample data

INSERT INTO customers (customer_id, first_name, last_name, phone_number, city)
SELECT
    customer_id,
    CASE (customer_id % 10)
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
    END AS first_name,
    'Customer ' || customer_id AS last_name,
    '09-7700-' || LPAD(customer_id::text, 4, '0') AS phone_number,
    CASE ((customer_id - 1) % 9)
        WHEN 0 THEN 'Yangon'
        WHEN 1 THEN 'Mandalay'
        WHEN 2 THEN 'Naypyidaw'
        WHEN 3 THEN 'Bago'
        WHEN 4 THEN 'Taunggyi'
        WHEN 5 THEN 'Mawlamyine'
        WHEN 6 THEN 'Pathein'
        WHEN 7 THEN 'Monywa'
        ELSE 'Pyay'
    END AS city
FROM generate_series(1, 35) AS customers(customer_id);

INSERT INTO warehouses (warehouse_id, warehouse_name, city, warehouse_status)
VALUES
    (1, 'Yangon Central Fulfillment', 'Yangon', 'overloaded'),
    (2, 'Mandalay North Warehouse', 'Mandalay', 'active'),
    (3, 'Naypyidaw Operations Hub', 'Naypyidaw', 'active'),
    (4, 'Bago Regional Store', 'Bago', 'overloaded'),
    (5, 'Mawlamyine South Depot', 'Mawlamyine', 'maintenance');

INSERT INTO drivers (driver_id, first_name, last_name, phone_number, city, vehicle_type, driver_status)
SELECT
    driver_id,
    CASE (driver_id % 8)
        WHEN 1 THEN 'Myo'
        WHEN 2 THEN 'Thet'
        WHEN 3 THEN 'Ko'
        WHEN 4 THEN 'Ei'
        WHEN 5 THEN 'Sai'
        WHEN 6 THEN 'Nandar'
        WHEN 7 THEN 'Win'
        ELSE 'Htet'
    END AS first_name,
    'Driver ' || driver_id AS last_name,
    '09-8800-' || LPAD(driver_id::text, 4, '0') AS phone_number,
    CASE ((driver_id - 1) % 9)
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
    CASE ((driver_id - 1) % 4)
        WHEN 0 THEN 'motorcycle'
        WHEN 1 THEN 'car'
        WHEN 2 THEN 'van'
        ELSE 'bicycle'
    END AS vehicle_type,
    CASE
        WHEN driver_id IN (1, 2, 3, 4, 5, 6) THEN 'busy'
        WHEN driver_id IN (7, 8, 9, 10, 11, 12) THEN 'available'
        WHEN driver_id IN (13, 14, 15) THEN 'offline'
        ELSE 'suspended'
    END AS driver_status
FROM generate_series(1, 18) AS drivers(driver_id);

INSERT INTO orders (
    order_id,
    customer_id,
    warehouse_id,
    driver_id,
    order_datetime,
    expected_delivery_datetime,
    total_amount,
    payment_status
)
SELECT
    order_id,
    ((order_id - 1) % 35) + 1 AS customer_id,
    CASE
        WHEN order_id <= 36 THEN 1
        WHEN order_id <= 56 THEN 2
        WHEN order_id <= 72 THEN 3
        WHEN order_id <= 90 THEN 4
        ELSE 5
    END AS warehouse_id,
    ((order_id - 1) % 18) + 1 AS driver_id,
    TIMESTAMP '2026-05-09 06:00:00'
        - ((100 - order_id) * INTERVAL '12 minutes') AS order_datetime,
    TIMESTAMP '2026-05-09 06:00:00'
        - ((100 - order_id) * INTERVAL '12 minutes')
        + (CASE WHEN order_id % 5 = 0 THEN 6 ELSE 4 END * INTERVAL '1 hour') AS expected_delivery_datetime,
    (18000 + (order_id * 1250))::numeric(12, 2) AS total_amount,
    CASE
        WHEN order_id IN (71, 72, 73, 74, 81, 82) THEN 'refunded'
        WHEN order_id IN (75, 76, 89, 90, 99, 100) THEN 'unpaid'
        ELSE 'paid'
    END AS payment_status
FROM generate_series(1, 100) AS orders(order_id);

INSERT INTO order_items (order_id, product_name, category, quantity, unit_price)
SELECT
    ((item_number - 1) % 100) + 1 AS order_id,
    CASE (item_number % 10)
        WHEN 1 THEN 'Rice Cooker'
        WHEN 2 THEN 'Green Tea Pack'
        WHEN 3 THEN 'Cotton Shirt'
        WHEN 4 THEN 'Notebook Set'
        WHEN 5 THEN 'Face Cleanser'
        WHEN 6 THEN 'Wireless Earbuds'
        WHEN 7 THEN 'Baby Wipes'
        WHEN 8 THEN 'Kitchen Storage Box'
        WHEN 9 THEN 'Coffee Beans'
        ELSE 'Phone Charger'
    END AS product_name,
    CASE (item_number % 8)
        WHEN 1 THEN 'Electronics'
        WHEN 2 THEN 'Grocery'
        WHEN 3 THEN 'Fashion'
        WHEN 4 THEN 'Stationery'
        WHEN 5 THEN 'Beauty'
        WHEN 6 THEN 'Personal Care'
        WHEN 7 THEN 'Baby Products'
        ELSE 'Home'
    END AS category,
    (item_number % 4) + 1 AS quantity,
    (4500 + (item_number % 12) * 1500)::numeric(10, 2) AS unit_price
FROM generate_series(1, 220) AS items(item_number);

INSERT INTO delivery_routes (
    order_id,
    origin_city,
    destination_city,
    distance_km,
    estimated_duration_minutes,
    actual_duration_minutes,
    route_status
)
SELECT
    o.order_id,
    w.city AS origin_city,
    c.city AS destination_city,
    (5 + (o.order_id % 35) * 2.5)::numeric(8, 2) AS distance_km,
    90 + (o.order_id % 6) * 30 AS estimated_duration_minutes,
    CASE
        WHEN o.order_id BETWEEN 1 AND 45 THEN 210 + (o.order_id % 6) * 10
        WHEN o.order_id BETWEEN 46 AND 55 THEN 340 + (o.order_id % 4) * 30
        WHEN o.order_id BETWEEN 56 AND 70 THEN 420 + (o.order_id % 5) * 35
        WHEN o.order_id BETWEEN 81 AND 88 THEN 360 + (o.order_id % 3) * 40
        ELSE NULL
    END AS actual_duration_minutes,
    CASE
        WHEN o.order_id BETWEEN 1 AND 45 THEN 'completed'
        WHEN o.order_id BETWEEN 46 AND 70 THEN 'delayed'
        WHEN o.order_id BETWEEN 71 AND 80 THEN 'cancelled'
        WHEN o.order_id BETWEEN 81 AND 88 THEN 'completed'
        ELSE 'active'
    END AS route_status
FROM orders AS o
JOIN warehouses AS w
    ON o.warehouse_id = w.warehouse_id
JOIN customers AS c
    ON o.customer_id = c.customer_id;

INSERT INTO order_status_events (order_id, event_time, order_status, status_note, updated_by)
SELECT order_id, order_datetime, 'order_placed', 'Customer placed the order.', 'system'
FROM orders
UNION ALL
SELECT order_id, order_datetime + INTERVAL '10 minutes', 'payment_confirmed', 'Payment status recorded by system.', 'payment_service'
FROM orders
UNION ALL
SELECT order_id, order_datetime + INTERVAL '25 minutes', 'preparing', 'Warehouse started preparing the order.', 'warehouse_team'
FROM orders
WHERE order_id NOT BETWEEN 71 AND 80
UNION ALL
SELECT order_id, order_datetime + INTERVAL '55 minutes', 'packed', 'Order was packed for dispatch.', 'warehouse_team'
FROM orders
WHERE order_id BETWEEN 1 AND 70
   OR order_id BETWEEN 81 AND 88
   OR order_id BETWEEN 91 AND 94
   OR order_id BETWEEN 95 AND 100
UNION ALL
SELECT order_id, order_datetime + INTERVAL '80 minutes', 'dispatched', 'Order left the warehouse.', 'warehouse_team'
FROM orders
WHERE order_id BETWEEN 1 AND 70
   OR order_id BETWEEN 81 AND 88
   OR order_id BETWEEN 91 AND 94
   OR order_id BETWEEN 95 AND 100
UNION ALL
SELECT order_id, order_datetime + INTERVAL '130 minutes', 'in_transit', 'Driver is moving toward the delivery area.', 'driver_app'
FROM orders
WHERE order_id BETWEEN 1 AND 70
   OR order_id BETWEEN 81 AND 88
   OR order_id BETWEEN 95 AND 98
UNION ALL
SELECT order_id, order_datetime + INTERVAL '180 minutes', 'out_for_delivery', 'Driver is near the customer location.', 'driver_app'
FROM orders
WHERE order_id BETWEEN 1 AND 70
   OR order_id BETWEEN 81 AND 88
   OR order_id BETWEEN 95 AND 97
UNION ALL
SELECT
    order_id,
    CASE
        WHEN order_id BETWEEN 46 AND 55 THEN expected_delivery_datetime + INTERVAL '1 hour'
        ELSE order_datetime + (actual_duration_minutes * INTERVAL '1 minute')
    END AS event_time,
    'delivered',
    'Order was delivered to the customer.',
    'driver_app'
FROM orders
JOIN delivery_routes USING (order_id)
WHERE order_id BETWEEN 1 AND 55
UNION ALL
SELECT order_id, expected_delivery_datetime + INTERVAL '90 minutes', 'delayed', 'Order is delayed beyond expected delivery time.', 'operations_monitor'
FROM orders
WHERE order_id BETWEEN 56 AND 70
UNION ALL
SELECT order_id, order_datetime + INTERVAL '35 minutes', 'cancelled', 'Order was cancelled before dispatch.', 'support_team'
FROM orders
WHERE order_id BETWEEN 71 AND 80
UNION ALL
SELECT order_id, order_datetime + INTERVAL '360 minutes', 'returned', 'Order was returned after delivery attempt.', 'support_team'
FROM orders
WHERE order_id BETWEEN 81 AND 88;

INSERT INTO driver_locations (
    driver_id,
    location_time,
    city,
    latitude,
    longitude,
    is_active
)
SELECT
    driver_id,
    TIMESTAMP '2026-05-09 10:00:00'
        - CASE
            WHEN driver_id IN (13, 14, 15, 16, 17, 18) THEN ((location_number + 1) * INTERVAL '45 minutes')
            ELSE (location_number * INTERVAL '8 minutes')
        END AS location_time,
    CASE ((driver_id + location_number) % 9)
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
    (16.700000 + (driver_id * 0.030000) + (location_number * 0.002000))::numeric(9, 6) AS latitude,
    (96.100000 + (driver_id * 0.025000) + (location_number * 0.002000))::numeric(9, 6) AS longitude,
    CASE WHEN driver_id IN (13, 14, 15, 16, 17, 18) THEN false ELSE true END AS is_active
FROM generate_series(1, 18) AS drivers(driver_id)
CROSS JOIN generate_series(1, 12) AS locations(location_number);

INSERT INTO operational_alerts (
    order_id,
    driver_id,
    alert_type,
    alert_message,
    alert_severity,
    alert_time,
    alert_status
)
SELECT
    CASE
        WHEN alert_number BETWEEN 31 AND 36 THEN NULL
        ELSE ((alert_number * 3 - 1) % 100) + 1
    END AS order_id,
    ((alert_number - 1) % 18) + 1 AS driver_id,
    CASE
        WHEN alert_number BETWEEN 1 AND 10 THEN 'delayed_order'
        WHEN alert_number BETWEEN 11 AND 18 THEN 'sla_breach'
        WHEN alert_number BETWEEN 19 AND 25 THEN 'route_delay'
        WHEN alert_number BETWEEN 26 AND 30 THEN 'failed_delivery'
        WHEN alert_number BETWEEN 31 AND 36 THEN 'inactive_driver'
        ELSE 'warehouse_overload'
    END AS alert_type,
    'Operational review needed for alert ' || alert_number || '.' AS alert_message,
    CASE
        WHEN alert_number IN (5, 12, 19, 27, 33, 40) THEN 'critical'
        WHEN alert_number % 3 = 0 THEN 'high'
        WHEN alert_number % 2 = 0 THEN 'medium'
        ELSE 'low'
    END AS alert_severity,
    TIMESTAMP '2026-05-09 10:00:00' - (alert_number * INTERVAL '18 minutes') AS alert_time,
    CASE
        WHEN alert_number % 5 = 0 THEN 'resolved'
        WHEN alert_number % 4 = 0 THEN 'investigating'
        ELSE 'open'
    END AS alert_status
FROM generate_series(1, 40) AS alerts(alert_number);

-- Keep SERIAL sequences aligned after explicit IDs in the sample data.
SELECT setval('customers_customer_id_seq', (SELECT MAX(customer_id) FROM customers));
SELECT setval('warehouses_warehouse_id_seq', (SELECT MAX(warehouse_id) FROM warehouses));
SELECT setval('drivers_driver_id_seq', (SELECT MAX(driver_id) FROM drivers));
SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));

-- Day 19 - Logistics & Delivery Optimization
-- Fictional sample data for PostgreSQL

INSERT INTO warehouses (warehouse_id, warehouse_name, city, capacity) VALUES
    (1, 'Yangon Central Warehouse', 'Yangon', 12000),
    (2, 'Mandalay North Warehouse', 'Mandalay', 9000),
    (3, 'Naypyidaw Fulfillment Center', 'Naypyidaw', 7000),
    (4, 'Taunggyi Regional Warehouse', 'Taunggyi', 5000),
    (5, 'Pathein Coastal Warehouse', 'Pathein', 4500);

INSERT INTO couriers (
    courier_id,
    first_name,
    last_name,
    phone_number,
    city,
    vehicle_type,
    courier_status
) VALUES
    (1, 'Aung', 'Thu', '+95-9-700001', 'Yangon', 'motorcycle', 'active'),
    (2, 'May', 'Sandi', '+95-9-700002', 'Yangon', 'van', 'active'),
    (3, 'Ko', 'Htet', '+95-9-700003', 'Mandalay', 'motorcycle', 'active'),
    (4, 'Su', 'Mon', '+95-9-700004', 'Mandalay', 'car', 'active'),
    (5, 'Nandar', 'Aye', '+95-9-700005', 'Naypyidaw', 'van', 'active'),
    (6, 'Thiri', 'Moe', '+95-9-700006', 'Bago', 'truck', 'active'),
    (7, 'Kyaw', 'Zin', '+95-9-700007', 'Taunggyi', 'motorcycle', 'active'),
    (8, 'Ei', 'Phyo', '+95-9-700008', 'Mawlamyine', 'car', 'active'),
    (9, 'Zaw', 'Min', '+95-9-700009', 'Pathein', 'motorcycle', 'active'),
    (10, 'Hnin', 'Wai', '+95-9-700010', 'Monywa', 'van', 'active'),
    (11, 'Myo', 'Thant', '+95-9-700011', 'Yangon', 'bicycle', 'inactive'),
    (12, 'Yu', 'Waddy', '+95-9-700012', 'Pyay', 'car', 'suspended'),
    (13, 'Min', 'Oo', '+95-9-700013', 'Yangon', 'truck', 'active'),
    (14, 'Khin', 'Win', '+95-9-700014', 'Mandalay', 'motorcycle', 'active'),
    (15, 'Thet', 'Naing', '+95-9-700015', 'Naypyidaw', 'van', 'inactive');

INSERT INTO customers (
    customer_id,
    first_name,
    last_name,
    phone_number,
    city,
    address
)
SELECT
    customer_number,
    (ARRAY['Aung','May','Ko','Su','Nandar','Thiri','Kyaw','Ei','Zaw','Hnin','Myo','Yu','Min','Khin','Thet'])[((customer_number - 1) % 15) + 1],
    (ARRAY['Thu','Sandi','Htet','Mon','Aye','Moe','Zin','Phyo','Min','Wai','Thant','Waddy','Oo','Win','Naing'])[((customer_number - 1) % 15) + 1],
    '+95-9-71' || LPAD(customer_number::TEXT, 5, '0'),
    (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa','Pyay'])[((customer_number - 1) % 9) + 1],
    'No. ' || customer_number || ', Main Road'
FROM generate_series(1, 40) AS gs(customer_number);

INSERT INTO delivery_zones (
    zone_id,
    zone_name,
    city,
    zone_type
) VALUES
    (1, 'Yangon Downtown', 'Yangon', 'urban'),
    (2, 'Yangon Industrial Park', 'Yangon', 'industrial'),
    (3, 'Mandalay Central', 'Mandalay', 'urban'),
    (4, 'Mandalay Suburb North', 'Mandalay', 'suburban'),
    (5, 'Naypyidaw Hotel Zone', 'Naypyidaw', 'commercial'),
    (6, 'Bago Rural Belt', 'Bago', 'rural'),
    (7, 'Taunggyi Hill Zone', 'Taunggyi', 'rural'),
    (8, 'Mawlamyine Commercial Area', 'Mawlamyine', 'commercial'),
    (9, 'Pathein Riverside', 'Pathein', 'suburban'),
    (10, 'Monywa Market Zone', 'Monywa', 'commercial'),
    (11, 'Pyay Rural North', 'Pyay', 'rural'),
    (12, 'Yangon Airport Cargo', 'Yangon', 'industrial');

INSERT INTO routes (
    route_id,
    origin_warehouse_id,
    destination_zone_id,
    route_name,
    distance_km,
    expected_delivery_hours
) VALUES
    (1, 1, 1, 'Yangon Central to Downtown', 8.50, 2.00),
    (2, 1, 2, 'Yangon Central to Industrial Park', 18.00, 3.50),
    (3, 2, 3, 'Mandalay North to Central', 10.00, 2.50),
    (4, 2, 4, 'Mandalay North to Suburb North', 26.00, 4.00),
    (5, 3, 5, 'Naypyidaw FC to Hotel Zone', 12.00, 2.50),
    (6, 1, 6, 'Yangon Central to Bago Rural Belt', 85.00, 8.00),
    (7, 4, 7, 'Taunggyi Regional to Hill Zone', 38.00, 6.00),
    (8, 5, 8, 'Pathein Coastal to Mawlamyine Commercial', 210.00, 18.00),
    (9, 5, 9, 'Pathein Coastal to Riverside', 14.00, 3.00),
    (10, 2, 10, 'Mandalay North to Monywa Market', 135.00, 12.00),
    (11, 5, 11, 'Pathein Coastal to Pyay Rural North', 175.00, 16.00),
    (12, 1, 12, 'Yangon Central to Airport Cargo', 22.00, 4.00),
    (13, 3, 6, 'Naypyidaw FC to Bago Rural Belt', 160.00, 14.00),
    (14, 4, 10, 'Taunggyi Regional to Monywa Market', 310.00, 28.00),
    (15, 2, 7, 'Mandalay North to Taunggyi Hill Zone', 260.00, 24.00);

INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    package_weight_kg,
    order_value
)
SELECT
    order_number,
    ((order_number - 1) % 40) + 1,
    DATE '2026-04-01' + ((order_number - 1) % 45),
    CASE
        WHEN order_number IN (18, 44, 70) THEN 'cancelled'
        WHEN order_number IN (25, 55, 83) THEN 'returned'
        WHEN order_number IN (7, 31, 62) THEN 'placed'
        WHEN order_number IN (12, 36, 78) THEN 'packed'
        WHEN order_number IN (5, 21, 48, 66, 89) THEN 'shipped'
        ELSE 'delivered'
    END AS order_status,
    0.50 + ((order_number % 10) * 0.75) AS package_weight_kg,
    25000.00 + ((order_number % 20) * 18000.00) AS order_value
FROM generate_series(1, 90) AS gs(order_number);

INSERT INTO shipments (
    shipment_id,
    order_id,
    warehouse_id,
    courier_id,
    route_id,
    dispatch_time,
    expected_delivery_time,
    actual_delivery_time,
    shipment_status,
    delivery_attempts
)
SELECT
    o.order_id,
    o.order_id,
    r.origin_warehouse_id,
    CASE
        WHEN o.order_id BETWEEN 1 AND 20 THEN ((o.order_id - 1) % 3) + 1
        WHEN o.order_id BETWEEN 21 AND 40 THEN ((o.order_id - 21) % 4) + 4
        WHEN o.order_id BETWEEN 41 AND 60 THEN ((o.order_id - 41) % 4) + 8
        WHEN o.order_id BETWEEN 61 AND 75 THEN ((o.order_id - 61) % 3) + 12
        ELSE ((o.order_id - 76) % 5) + 1
    END AS courier_id,
    ((o.order_id - 1) % 15) + 1 AS route_id,
    CASE
        WHEN o.order_id IN (7, 12, 31, 36, 62, 78) THEN NULL
        ELSE o.order_date::TIMESTAMP + TIME '08:00'
    END AS dispatch_time,
    CASE
        WHEN o.order_id IN (7, 12, 31, 36, 62, 78) THEN NULL
        ELSE o.order_date::TIMESTAMP + TIME '08:00'
             + (r.expected_delivery_hours::DOUBLE PRECISION * INTERVAL '1 hour')
    END AS expected_delivery_time,
    CASE
        WHEN o.order_id IN (7, 12, 31, 36, 62, 78) THEN NULL
        WHEN o.order_id IN (16, 30, 45, 60, 75, 90) THEN NULL
        WHEN o.order_id IN (25, 55, 83) THEN NULL
        WHEN o.order_id IN (8, 10, 15, 23, 29, 38, 47, 52, 61, 68, 72, 81, 86) THEN
            o.order_date::TIMESTAMP + TIME '08:00'
            + ((r.expected_delivery_hours + 4 + (o.order_id % 5))::DOUBLE PRECISION * INTERVAL '1 hour')
        WHEN ((o.order_id - 1) % 15) + 1 IN (8, 10, 11, 14, 15) THEN
            o.order_date::TIMESTAMP + TIME '08:00'
            + ((r.expected_delivery_hours + 2)::DOUBLE PRECISION * INTERVAL '1 hour')
        ELSE
            o.order_date::TIMESTAMP + TIME '08:00'
            + (GREATEST(r.expected_delivery_hours - 0.5, 1)::DOUBLE PRECISION * INTERVAL '1 hour')
    END AS actual_delivery_time,
    CASE
        WHEN o.order_id IN (7, 12, 31, 36, 62, 78) THEN 'pending'
        WHEN o.order_id IN (16, 30, 45, 60, 75, 90) THEN 'failed'
        WHEN o.order_id IN (25, 55, 83) THEN 'returned'
        WHEN o.order_id IN (5, 21, 48, 66, 89) THEN 'in_transit'
        WHEN o.order_id IN (8, 10, 15, 23, 29, 38, 47, 52, 61, 68, 72, 81, 86) THEN 'delayed'
        ELSE 'delivered'
    END AS shipment_status,
    CASE
        WHEN o.order_id IN (16, 30, 45, 60, 75, 90) THEN 3
        WHEN o.order_id IN (8, 10, 15, 23, 29, 38, 47, 52, 61, 68, 72, 81, 86, 25, 55, 83) THEN 2
        WHEN o.order_id IN (7, 12, 31, 36, 62, 78) THEN 0
        ELSE 1
    END AS delivery_attempts
FROM orders AS o
JOIN routes AS r
    ON r.route_id = ((o.order_id - 1) % 15) + 1;

-- Two events per shipment = 180 event records.
INSERT INTO delivery_events (
    event_id,
    shipment_id,
    event_time,
    event_type,
    event_location,
    event_note
)
SELECT
    ((s.shipment_id - 1) * 2) + event_number AS event_id,
    s.shipment_id,
    COALESCE(s.dispatch_time, s.created_at) + (event_number * INTERVAL '1 hour') AS event_time,
    CASE
        WHEN event_number = 1 THEN
            CASE
                WHEN s.shipment_status = 'pending' THEN 'picked_up'
                ELSE 'departed_warehouse'
            END
        ELSE
            CASE
                WHEN s.shipment_status = 'delivered' THEN 'delivered'
                WHEN s.shipment_status = 'delayed' THEN 'delivery_attempted'
                WHEN s.shipment_status = 'failed' THEN 'failed'
                WHEN s.shipment_status = 'returned' THEN 'returned'
                WHEN s.shipment_status = 'in_transit' THEN 'out_for_delivery'
                ELSE 'picked_up'
            END
    END AS event_type,
    CASE
        WHEN event_number = 1 THEN w.city
        ELSE dz.city
    END AS event_location,
    CASE
        WHEN event_number = 1 THEN 'Shipment processed at origin.'
        ELSE 'Latest shipment status update.'
    END AS event_note
FROM shipments AS s
JOIN warehouses AS w
    ON s.warehouse_id = w.warehouse_id
JOIN routes AS r
    ON s.route_id = r.route_id
JOIN delivery_zones AS dz
    ON r.destination_zone_id = dz.zone_id
CROSS JOIN generate_series(1, 2) AS gs(event_number);

INSERT INTO delivery_costs (
    cost_id,
    shipment_id,
    base_cost,
    distance_cost,
    handling_cost,
    failed_attempt_cost,
    total_cost
)
SELECT
    s.shipment_id,
    s.shipment_id,
    2500.00 AS base_cost,
    r.distance_km * 180.00 AS distance_cost,
    CASE
        WHEN dz.zone_type IN ('rural', 'industrial') THEN 3500.00
        WHEN dz.zone_type = 'commercial' THEN 2500.00
        ELSE 1500.00
    END AS handling_cost,
    GREATEST(s.delivery_attempts - 1, 0) * 1800.00 AS failed_attempt_cost,
    2500.00
        + (r.distance_km * 180.00)
        + CASE
            WHEN dz.zone_type IN ('rural', 'industrial') THEN 3500.00
            WHEN dz.zone_type = 'commercial' THEN 2500.00
            ELSE 1500.00
          END
        + (GREATEST(s.delivery_attempts - 1, 0) * 1800.00) AS total_cost
FROM shipments AS s
JOIN routes AS r
    ON s.route_id = r.route_id
JOIN delivery_zones AS dz
    ON r.destination_zone_id = dz.zone_id;

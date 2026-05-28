-- Day 19 - Logistics & Delivery Optimization
-- PostgreSQL schema
--
-- This is a SQL learning project for delivery operations analysis.
-- It is not a production route optimization system.

DROP TABLE IF EXISTS delivery_costs;
DROP TABLE IF EXISTS delivery_events;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS delivery_zones;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS couriers;
DROP TABLE IF EXISTS warehouses;

CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE couriers (
    courier_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    vehicle_type VARCHAR(20) NOT NULL
        CHECK (vehicle_type IN ('bicycle', 'motorcycle', 'car', 'van', 'truck')),
    courier_status VARCHAR(20) NOT NULL
        CHECK (courier_status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    address VARCHAR(200) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery_zones (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    zone_type VARCHAR(20) NOT NULL
        CHECK (zone_type IN ('urban', 'suburban', 'rural', 'industrial', 'commercial')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_zone_city_name UNIQUE (city, zone_name)
);

CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    origin_warehouse_id INTEGER NOT NULL,
    destination_zone_id INTEGER NOT NULL,
    route_name VARCHAR(120) NOT NULL UNIQUE,
    distance_km NUMERIC(8, 2) NOT NULL CHECK (distance_km >= 0),
    expected_delivery_hours NUMERIC(8, 2) NOT NULL CHECK (expected_delivery_hours > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_routes_warehouse
        FOREIGN KEY (origin_warehouse_id)
        REFERENCES warehouses (warehouse_id),
    CONSTRAINT fk_routes_zone
        FOREIGN KEY (destination_zone_id)
        REFERENCES delivery_zones (zone_id)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL
        CHECK (order_status IN ('placed', 'packed', 'shipped', 'delivered', 'cancelled', 'returned')),
    package_weight_kg NUMERIC(8, 2) NOT NULL CHECK (package_weight_kg >= 0),
    order_value NUMERIC(12, 2) NOT NULL CHECK (order_value >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
);

CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    warehouse_id INTEGER NOT NULL,
    courier_id INTEGER NOT NULL,
    route_id INTEGER NOT NULL,
    dispatch_time TIMESTAMP,
    expected_delivery_time TIMESTAMP,
    actual_delivery_time TIMESTAMP,
    shipment_status VARCHAR(20) NOT NULL
        CHECK (shipment_status IN ('pending', 'dispatched', 'in_transit', 'delivered', 'delayed', 'failed', 'returned')),
    delivery_attempts INTEGER NOT NULL DEFAULT 1 CHECK (delivery_attempts >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_shipments_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT fk_shipments_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses (warehouse_id),
    CONSTRAINT fk_shipments_courier
        FOREIGN KEY (courier_id)
        REFERENCES couriers (courier_id),
    CONSTRAINT fk_shipments_route
        FOREIGN KEY (route_id)
        REFERENCES routes (route_id),
    CONSTRAINT chk_delivery_time_order
        CHECK (
            actual_delivery_time IS NULL
            OR dispatch_time IS NULL
            OR actual_delivery_time >= dispatch_time
        )
);

CREATE TABLE delivery_events (
    event_id SERIAL PRIMARY KEY,
    shipment_id INTEGER NOT NULL,
    event_time TIMESTAMP NOT NULL,
    event_type VARCHAR(30) NOT NULL
        CHECK (
            event_type IN (
                'picked_up',
                'departed_warehouse',
                'arrived_hub',
                'out_for_delivery',
                'delivery_attempted',
                'delivered',
                'failed',
                'returned'
            )
        ),
    event_location VARCHAR(100) NOT NULL,
    event_note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_events_shipment
        FOREIGN KEY (shipment_id)
        REFERENCES shipments (shipment_id)
);

CREATE TABLE delivery_costs (
    cost_id SERIAL PRIMARY KEY,
    shipment_id INTEGER NOT NULL UNIQUE,
    base_cost NUMERIC(12, 2) NOT NULL CHECK (base_cost >= 0),
    distance_cost NUMERIC(12, 2) NOT NULL CHECK (distance_cost >= 0),
    handling_cost NUMERIC(12, 2) NOT NULL CHECK (handling_cost >= 0),
    failed_attempt_cost NUMERIC(12, 2) NOT NULL CHECK (failed_attempt_cost >= 0),
    total_cost NUMERIC(12, 2) NOT NULL CHECK (total_cost >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_costs_shipment
        FOREIGN KEY (shipment_id)
        REFERENCES shipments (shipment_id),
    CONSTRAINT chk_total_cost_matches_components
        CHECK (total_cost = base_cost + distance_cost + handling_cost + failed_attempt_cost)
);

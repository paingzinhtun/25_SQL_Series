-- Day 21 - Real-Time Order Tracking System (Simulated with SQL)
-- PostgreSQL schema

DROP TABLE IF EXISTS operational_alerts;
DROP TABLE IF EXISTS driver_locations;
DROP TABLE IF EXISTS delivery_routes;
DROP TABLE IF EXISTS order_status_events;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_name VARCHAR(120) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    warehouse_status VARCHAR(30) NOT NULL
        CHECK (warehouse_status IN ('active', 'overloaded', 'maintenance')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL
        CHECK (vehicle_type IN ('bicycle', 'motorcycle', 'car', 'van')),
    driver_status VARCHAR(30) NOT NULL
        CHECK (driver_status IN ('available', 'busy', 'offline', 'suspended')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    driver_id INTEGER,
    order_datetime TIMESTAMP NOT NULL,
    expected_delivery_datetime TIMESTAMP NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    payment_status VARCHAR(30) NOT NULL
        CHECK (payment_status IN ('paid', 'unpaid', 'refunded')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses (warehouse_id),
    CONSTRAINT fk_orders_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers (driver_id),
    CONSTRAINT chk_expected_after_order
        CHECK (expected_delivery_datetime >= order_datetime)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);

CREATE TABLE order_status_events (
    event_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    event_time TIMESTAMP NOT NULL,
    order_status VARCHAR(40) NOT NULL
        CHECK (
            order_status IN (
                'order_placed',
                'payment_confirmed',
                'preparing',
                'packed',
                'dispatched',
                'in_transit',
                'out_for_delivery',
                'delivered',
                'delayed',
                'cancelled',
                'returned'
            )
        ),
    status_note TEXT NOT NULL,
    updated_by VARCHAR(80) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_status_events_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT uq_order_event_time_status
        UNIQUE (order_id, event_time, order_status)
);

CREATE TABLE delivery_routes (
    route_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    origin_city VARCHAR(80) NOT NULL,
    destination_city VARCHAR(80) NOT NULL,
    distance_km NUMERIC(8, 2) NOT NULL CHECK (distance_km >= 0),
    estimated_duration_minutes INTEGER NOT NULL CHECK (estimated_duration_minutes >= 0),
    actual_duration_minutes INTEGER CHECK (actual_duration_minutes IS NULL OR actual_duration_minutes >= 0),
    route_status VARCHAR(30) NOT NULL
        CHECK (route_status IN ('active', 'delayed', 'completed', 'cancelled')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_routes_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);

CREATE TABLE driver_locations (
    location_id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL,
    location_time TIMESTAMP NOT NULL,
    city VARCHAR(80) NOT NULL,
    latitude NUMERIC(9, 6) NOT NULL,
    longitude NUMERIC(9, 6) NOT NULL,
    is_active BOOLEAN NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_driver_locations_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers (driver_id)
);

CREATE TABLE operational_alerts (
    alert_id SERIAL PRIMARY KEY,
    order_id INTEGER,
    driver_id INTEGER,
    alert_type VARCHAR(40) NOT NULL
        CHECK (
            alert_type IN (
                'delayed_order',
                'sla_breach',
                'inactive_driver',
                'warehouse_overload',
                'failed_delivery',
                'route_delay'
            )
        ),
    alert_message TEXT NOT NULL,
    alert_severity VARCHAR(30) NOT NULL
        CHECK (alert_severity IN ('low', 'medium', 'high', 'critical')),
    alert_time TIMESTAMP NOT NULL,
    alert_status VARCHAR(30) NOT NULL
        CHECK (alert_status IN ('open', 'investigating', 'resolved')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_operational_alerts_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT fk_operational_alerts_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers (driver_id)
);

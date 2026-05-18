-- Day 9 - Food Delivery Orders Analysis
-- PostgreSQL schema
--
-- This is a SQL learning project for marketplace-style food delivery data.
-- It is simplified for beginners and is not a production delivery platform schema.

DROP TABLE IF EXISTS delivery_ratings;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS delivery_partners;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(30),
    city VARCHAR(80) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL UNIQUE,
    cuisine_type VARCHAR(50) NOT NULL,
    city VARCHAR(80) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE delivery_partners (
    partner_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    vehicle_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_delivery_partners_vehicle_type
        CHECK (vehicle_type IN ('bicycle', 'motorcycle', 'car'))
);

CREATE TABLE menu_items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INTEGER NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_menu_items_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants (restaurant_id),

    CONSTRAINT uq_menu_items_restaurant_item
        UNIQUE (restaurant_id, item_name),

    CONSTRAINT chk_menu_items_price
        CHECK (price >= 0)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    partner_id INTEGER,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    order_time TIMESTAMP NOT NULL,
    pickup_time TIMESTAMP,
    delivery_time TIMESTAMP,
    delivery_fee NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),

    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants (restaurant_id),

    CONSTRAINT fk_orders_delivery_partner
        FOREIGN KEY (partner_id)
        REFERENCES delivery_partners (partner_id),

    CONSTRAINT chk_orders_status
        CHECK (order_status IN ('delivered', 'cancelled', 'preparing', 'out_for_delivery')),

    CONSTRAINT chk_orders_delivery_fee
        CHECK (delivery_fee >= 0),

    CONSTRAINT chk_orders_time_order
        CHECK (
            pickup_time IS NULL
            OR pickup_time >= order_time
        ),

    CONSTRAINT chk_orders_delivery_after_order
        CHECK (
            delivery_time IS NULL
            OR delivery_time >= order_time
        ),

    CONSTRAINT chk_orders_delivery_after_pickup
        CHECK (
            delivery_time IS NULL
            OR pickup_time IS NULL
            OR delivery_time >= pickup_time
        )
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    item_price NUMERIC(10, 2) NOT NULL,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT fk_order_items_menu_item
        FOREIGN KEY (item_id)
        REFERENCES menu_items (item_id),

    CONSTRAINT chk_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_items_item_price
        CHECK (item_price >= 0)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,

    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT chk_payments_method
        CHECK (payment_method IN ('cash', 'card', 'mobile_wallet', 'bank_transfer')),

    CONSTRAINT chk_payments_status
        CHECK (payment_status IN ('paid', 'unpaid', 'refunded', 'failed')),

    CONSTRAINT chk_payments_amount
        CHECK (amount >= 0)
);

CREATE TABLE delivery_ratings (
    rating_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL,
    partner_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    food_rating INTEGER NOT NULL,
    delivery_rating INTEGER NOT NULL,
    review_text TEXT,
    rating_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_delivery_ratings_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT fk_delivery_ratings_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),

    CONSTRAINT fk_delivery_ratings_partner
        FOREIGN KEY (partner_id)
        REFERENCES delivery_partners (partner_id),

    CONSTRAINT fk_delivery_ratings_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants (restaurant_id),

    CONSTRAINT chk_delivery_ratings_food
        CHECK (food_rating BETWEEN 1 AND 5),

    CONSTRAINT chk_delivery_ratings_delivery
        CHECK (delivery_rating BETWEEN 1 AND 5)
);

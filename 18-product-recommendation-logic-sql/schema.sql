-- Day 18 - Product Recommendation Logic with SQL
-- PostgreSQL schema
--
-- This is a learning project for explainable SQL recommendation logic.
-- It is not a production recommendation engine.

DROP TABLE IF EXISTS product_recommendations;
DROP TABLE IF EXISTS wishlists;
DROP TABLE IF EXISTS product_views;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone_number VARCHAR(30),
    city VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    brand VARCHAR(80) NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL
        CHECK (unit_price >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL
        CHECK (order_status IN ('completed', 'cancelled', 'returned', 'pending')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL
        CHECK (quantity > 0),
    unit_price NUMERIC(12, 2) NOT NULL
        CHECK (unit_price >= 0),
    discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (discount_amount >= 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),
    CONSTRAINT chk_discount_not_more_than_line_amount
        CHECK (discount_amount <= quantity * unit_price)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN ('cash', 'card', 'mobile_wallet', 'bank_transfer')),
    payment_status VARCHAR(20) NOT NULL
        CHECK (payment_status IN ('paid', 'unpaid', 'refunded', 'failed')),
    amount NUMERIC(12, 2) NOT NULL
        CHECK (amount >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);

CREATE TABLE product_views (
    view_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    view_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_views_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT fk_product_views_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id)
);

CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    added_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_wishlists_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT fk_wishlists_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),
    CONSTRAINT uq_customer_product_wishlist
        UNIQUE (customer_id, product_id)
);

CREATE TABLE product_recommendations (
    recommendation_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    recommended_product_id INTEGER NOT NULL,
    recommendation_reason VARCHAR(40) NOT NULL
        CHECK (
            recommendation_reason IN (
                'popular_product',
                'category_preference',
                'frequently_bought_together',
                'wishlist_based',
                'viewed_not_purchased',
                'similar_customer_behavior'
            )
        ),
    recommendation_score INTEGER NOT NULL
        CHECK (recommendation_score BETWEEN 1 AND 5),
    recommendation_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recommendations_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT fk_recommendations_product
        FOREIGN KEY (recommended_product_id)
        REFERENCES products (product_id)
);

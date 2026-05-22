-- Day 13 - Subscription-Based Platform Analysis
-- PostgreSQL schema

DROP TABLE IF EXISTS cancellations;
DROP TABLE IF EXISTS usage_events;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS subscription_plans;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone_number VARCHAR(30),
    city VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subscription_plans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(80) NOT NULL UNIQUE,
    billing_cycle VARCHAR(20) NOT NULL,
    monthly_price NUMERIC(10, 2) NOT NULL,
    plan_tier VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_subscription_plans_billing_cycle
        CHECK (billing_cycle IN ('monthly', 'quarterly', 'yearly')),

    CONSTRAINT chk_subscription_plans_monthly_price
        CHECK (monthly_price >= 0),

    CONSTRAINT chk_subscription_plans_tier
        CHECK (plan_tier IN ('basic', 'standard', 'premium', 'family', 'business'))
);

CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    subscription_status VARCHAR(20) NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_subscriptions_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_subscriptions_plan
        FOREIGN KEY (plan_id)
        REFERENCES subscription_plans (plan_id),

    CONSTRAINT chk_subscriptions_status
        CHECK (subscription_status IN ('active', 'cancelled', 'expired', 'trial', 'paused')),

    CONSTRAINT chk_subscriptions_date_order
        CHECK (end_date IS NULL OR end_date >= start_date),

    CONSTRAINT chk_subscriptions_active_end_date
        CHECK (
            subscription_status IN ('active', 'trial', 'paused')
            OR end_date IS NOT NULL
        )
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    subscription_id INTEGER NOT NULL,
    payment_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payments_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions (subscription_id),

    CONSTRAINT chk_payments_status
        CHECK (payment_status IN ('paid', 'failed', 'refunded', 'pending')),

    CONSTRAINT chk_payments_method
        CHECK (payment_method IN ('card', 'mobile_wallet', 'bank_transfer', 'cash')),

    CONSTRAINT chk_payments_amount
        CHECK (amount >= 0)
);

CREATE TABLE usage_events (
    event_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    event_date DATE NOT NULL,
    event_type VARCHAR(30) NOT NULL,
    usage_minutes INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usage_events_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT chk_usage_events_type
        CHECK (event_type IN ('login', 'watch', 'listen', 'download', 'lesson_view', 'feature_use')),

    CONSTRAINT chk_usage_events_minutes
        CHECK (usage_minutes >= 0)
);

CREATE TABLE cancellations (
    cancellation_id SERIAL PRIMARY KEY,
    subscription_id INTEGER NOT NULL UNIQUE,
    cancellation_date DATE NOT NULL,
    cancellation_reason VARCHAR(150) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cancellations_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions (subscription_id)
);

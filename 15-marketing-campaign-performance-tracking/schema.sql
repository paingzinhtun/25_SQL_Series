-- Day 15 - Marketing Campaign Performance Tracking
-- PostgreSQL schema

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS conversions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS leads;
DROP TABLE IF EXISTS ad_performance;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS marketing_channels;

CREATE TABLE marketing_channels (
    channel_id SERIAL PRIMARY KEY,
    channel_name VARCHAR(80) NOT NULL UNIQUE,
    channel_type VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_marketing_channels_type
        CHECK (channel_type IN ('paid_social', 'paid_search', 'organic', 'email', 'referral', 'event', 'partner'))
);

CREATE TABLE campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(120) NOT NULL UNIQUE,
    channel_id INTEGER NOT NULL,
    campaign_goal VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    campaign_status VARCHAR(20) NOT NULL,
    budget NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_campaigns_channel
        FOREIGN KEY (channel_id)
        REFERENCES marketing_channels (channel_id),

    CONSTRAINT chk_campaigns_goal
        CHECK (campaign_goal IN ('awareness', 'lead_generation', 'conversion', 'retention')),

    CONSTRAINT chk_campaigns_status
        CHECK (campaign_status IN ('active', 'paused', 'completed', 'cancelled')),

    CONSTRAINT chk_campaigns_budget
        CHECK (budget >= 0),

    CONSTRAINT chk_campaigns_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE ad_performance (
    performance_id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,
    performance_date DATE NOT NULL,
    impressions INTEGER NOT NULL,
    clicks INTEGER NOT NULL,
    spend NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ad_performance_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES campaigns (campaign_id),

    CONSTRAINT chk_ad_performance_impressions
        CHECK (impressions >= 0),

    CONSTRAINT chk_ad_performance_clicks
        CHECK (clicks >= 0),

    CONSTRAINT chk_ad_performance_clicks_not_more_than_impressions
        CHECK (clicks <= impressions),

    CONSTRAINT chk_ad_performance_spend
        CHECK (spend >= 0),

    CONSTRAINT uq_ad_performance_campaign_date
        UNIQUE (campaign_id, performance_date)
);

CREATE TABLE leads (
    lead_id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    lead_date DATE NOT NULL,
    lead_status VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_leads_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES campaigns (campaign_id),

    CONSTRAINT chk_leads_status
        CHECK (lead_status IN ('new', 'contacted', 'qualified', 'converted', 'disqualified'))
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    customer_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_customers_lead
        FOREIGN KEY (lead_id)
        REFERENCES leads (lead_id)
);

CREATE TABLE conversions (
    conversion_id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,
    lead_id INTEGER NOT NULL,
    customer_id INTEGER,
    conversion_date DATE NOT NULL,
    conversion_type VARCHAR(30) NOT NULL,
    conversion_value NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_conversions_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES campaigns (campaign_id),

    CONSTRAINT fk_conversions_lead
        FOREIGN KEY (lead_id)
        REFERENCES leads (lead_id),

    CONSTRAINT fk_conversions_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),

    CONSTRAINT chk_conversions_type
        CHECK (conversion_type IN ('signup', 'purchase', 'demo_booked', 'subscription', 'consultation')),

    CONSTRAINT chk_conversions_value
        CHECK (conversion_value >= 0)
);

CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    campaign_id INTEGER NOT NULL,
    sale_date DATE NOT NULL,
    revenue_amount NUMERIC(12, 2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),

    CONSTRAINT fk_sales_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES campaigns (campaign_id),

    CONSTRAINT chk_sales_revenue
        CHECK (revenue_amount >= 0),

    CONSTRAINT chk_sales_payment_status
        CHECK (payment_status IN ('paid', 'unpaid', 'refunded', 'failed'))
);

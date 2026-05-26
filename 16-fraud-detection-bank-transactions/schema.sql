-- Day 16 - Fraud Detection with Bank Transactions
-- PostgreSQL schema
--
-- Important:
-- This is a SQL learning project for rule-based transaction monitoring.
-- A flagged transaction means "needs review", not confirmed fraud.

DROP TABLE IF EXISTS flagged_transactions;
DROP TABLE IF EXISTS fraud_rules;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone_number VARCHAR(30),
    city VARCHAR(80) NOT NULL,
    customer_type VARCHAR(20) NOT NULL
        CHECK (customer_type IN ('individual', 'business')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL
        CHECK (account_type IN ('savings', 'current', 'business')),
    account_status VARCHAR(20) NOT NULL
        CHECK (account_status IN ('active', 'frozen', 'closed')),
    opening_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
);

CREATE TABLE cards (
    card_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    card_number_masked VARCHAR(25) NOT NULL UNIQUE,
    card_type VARCHAR(20) NOT NULL
        CHECK (card_type IN ('debit', 'credit', 'prepaid')),
    card_status VARCHAR(20) NOT NULL
        CHECK (card_status IN ('active', 'blocked', 'expired')),
    issued_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cards_account
        FOREIGN KEY (account_id)
        REFERENCES accounts (account_id),
    CONSTRAINT chk_card_number_is_masked
        CHECK (card_number_masked ~ '^XXXX-XXXX-XXXX-[0-9]{4}$')
);

CREATE TABLE merchants (
    merchant_id SERIAL PRIMARY KEY,
    merchant_name VARCHAR(120) NOT NULL,
    merchant_category VARCHAR(40) NOT NULL
        CHECK (
            merchant_category IN (
                'grocery',
                'electronics',
                'travel',
                'entertainment',
                'fuel',
                'restaurant',
                'fashion',
                'online_marketplace',
                'financial_service'
            )
        ),
    city VARCHAR(80) NOT NULL,
    country VARCHAR(80) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL,
    merchant_id INTEGER NOT NULL,
    transaction_datetime TIMESTAMP NOT NULL,
    transaction_type VARCHAR(30) NOT NULL
        CHECK (
            transaction_type IN (
                'purchase',
                'withdrawal',
                'transfer',
                'online_payment',
                'bill_payment'
            )
        ),
    amount NUMERIC(14, 2) NOT NULL
        CHECK (amount > 0),
    currency VARCHAR(10) NOT NULL DEFAULT 'MMK',
    transaction_status VARCHAR(20) NOT NULL
        CHECK (transaction_status IN ('success', 'failed', 'declined', 'pending')),
    transaction_city VARCHAR(80) NOT NULL,
    transaction_country VARCHAR(80) NOT NULL,
    channel VARCHAR(20) NOT NULL
        CHECK (channel IN ('atm', 'pos', 'online', 'mobile_app', 'bank_branch')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES accounts (account_id),
    CONSTRAINT fk_transactions_card
        FOREIGN KEY (card_id)
        REFERENCES cards (card_id),
    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES merchants (merchant_id)
);

CREATE TABLE fraud_rules (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL UNIQUE,
    rule_description TEXT NOT NULL,
    risk_score INTEGER NOT NULL
        CHECK (risk_score BETWEEN 1 AND 100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE flagged_transactions (
    flag_id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL,
    rule_id INTEGER NOT NULL,
    flagged_at TIMESTAMP NOT NULL,
    review_status VARCHAR(30) NOT NULL
        CHECK (
            review_status IN (
                'pending_review',
                'cleared',
                'escalated',
                'confirmed_issue'
            )
        ),
    reviewer_note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_flagged_transactions_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions (transaction_id),
    CONSTRAINT fk_flagged_transactions_rule
        FOREIGN KEY (rule_id)
        REFERENCES fraud_rules (rule_id),
    CONSTRAINT uq_flagged_transaction_rule
        UNIQUE (transaction_id, rule_id)
);

-- Day 6 - Simple Banking System
-- PostgreSQL schema

-- Drop child tables first because they depend on parent tables through foreign keys.
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS branches;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(30) UNIQUE,
    city VARCHAR(60) NOT NULL,
    customer_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_customers_type
        CHECK (customer_type IN ('individual', 'business'))
);

CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    branch_id INTEGER NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL,
    opening_date DATE NOT NULL,
    current_balance NUMERIC(14, 2) NOT NULL DEFAULT 0,
    account_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),

    CONSTRAINT fk_accounts_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches (branch_id),

    CONSTRAINT chk_accounts_type
        CHECK (account_type IN ('savings', 'current', 'business')),

    CONSTRAINT chk_accounts_status
        CHECK (account_status IN ('active', 'frozen', 'closed')),

    CONSTRAINT chk_accounts_current_balance
        CHECK (current_balance >= 0)
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL,
    transaction_status VARCHAR(20) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES accounts (account_id),

    CONSTRAINT chk_transactions_type
        CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer_in', 'transfer_out', 'fee')),

    CONSTRAINT chk_transactions_status
        CHECK (transaction_status IN ('success', 'failed', 'pending')),

    CONSTRAINT chk_transactions_amount
        CHECK (amount > 0)
);

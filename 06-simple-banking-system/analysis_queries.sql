-- Day 6 - Simple Banking System
-- Business analysis queries for PostgreSQL

-- 1. List all customers.
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    city,
    customer_type,
    created_at
FROM customers
ORDER BY customer_id;

-- 2. List all accounts with customer and branch information.
SELECT
    a.account_id,
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_type,
    b.branch_name,
    b.city AS branch_city,
    a.account_type,
    a.current_balance,
    a.account_status
FROM accounts AS a
JOIN customers AS c
    ON a.customer_id = c.customer_id
JOIN branches AS b
    ON a.branch_id = b.branch_id
ORDER BY customer_name, a.account_number;

-- 3. Show all successful transactions.
SELECT
    t.transaction_id,
    a.account_number,
    t.transaction_date,
    t.transaction_type,
    t.amount,
    t.description
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
WHERE t.transaction_status = 'success'
ORDER BY t.transaction_date, t.transaction_id;

-- 4. Show failed and pending transactions.
-- Failed and pending transactions are visible, but they should not affect completed money movement.
SELECT
    t.transaction_id,
    a.account_number,
    t.transaction_date,
    t.transaction_type,
    t.amount,
    t.transaction_status,
    t.description
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
WHERE t.transaction_status IN ('failed', 'pending')
ORDER BY t.transaction_date, t.transaction_id;

-- 5. Calculate total deposits.
-- Only successful deposits are counted as completed deposit movement.
SELECT
    SUM(amount) AS total_successful_deposits
FROM transactions
WHERE transaction_type = 'deposit'
  AND transaction_status = 'success';

-- 6. Calculate total withdrawals.
-- Only successful withdrawals are counted as completed withdrawal movement.
SELECT
    SUM(amount) AS total_successful_withdrawals
FROM transactions
WHERE transaction_type = 'withdrawal'
  AND transaction_status = 'success';

-- 7. Calculate net money movement per account.
-- Deposits and transfer_in increase balance.
-- Withdrawals, transfer_out, and fees decrease balance.
-- Failed and pending transactions are excluded from the completed movement calculation.
WITH successful_transaction_movement AS (
    SELECT
        account_id,
        CASE
            WHEN transaction_type IN ('deposit', 'transfer_in') THEN amount
            WHEN transaction_type IN ('withdrawal', 'transfer_out', 'fee') THEN -amount
            ELSE 0
        END AS signed_amount
    FROM transactions
    WHERE transaction_status = 'success'
)
SELECT
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(stm.signed_amount), 0) AS net_money_movement
FROM accounts AS a
JOIN customers AS c
    ON a.customer_id = c.customer_id
LEFT JOIN successful_transaction_movement AS stm
    ON a.account_id = stm.account_id
GROUP BY a.account_id, a.account_number, c.first_name, c.last_name
ORDER BY net_money_movement DESC;

-- 8. Show current balance for each account.
SELECT
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    a.account_type,
    a.current_balance,
    a.account_status
FROM accounts AS a
JOIN customers AS c
    ON a.customer_id = c.customer_id
ORDER BY a.current_balance DESC;

-- 9. Find top 5 accounts by current balance.
-- ROW_NUMBER assigns a unique rank even if two accounts have the same balance.
WITH ranked_accounts AS (
    SELECT
        a.account_number,
        c.first_name || ' ' || c.last_name AS customer_name,
        a.account_type,
        a.current_balance,
        ROW_NUMBER() OVER (
            ORDER BY a.current_balance DESC
        ) AS balance_rank
    FROM accounts AS a
    JOIN customers AS c
        ON a.customer_id = c.customer_id
)
SELECT
    account_number,
    customer_name,
    account_type,
    current_balance,
    balance_rank
FROM ranked_accounts
WHERE balance_rank <= 5
ORDER BY balance_rank;

-- 10. Find total customer balance by branch.
SELECT
    b.branch_name,
    b.city,
    SUM(a.current_balance) AS total_branch_balance
FROM branches AS b
LEFT JOIN accounts AS a
    ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_branch_balance DESC;

-- 11. Count accounts by account type.
SELECT
    account_type,
    COUNT(*) AS account_count
FROM accounts
GROUP BY account_type
ORDER BY account_count DESC, account_type;

-- 12. Count accounts by account status.
SELECT
    account_status,
    COUNT(*) AS account_count
FROM accounts
GROUP BY account_status
ORDER BY account_count DESC, account_status;

-- 13. Find customers with more than one account.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(a.account_id) AS account_count
FROM customers AS c
JOIN accounts AS a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(a.account_id) > 1
ORDER BY account_count DESC, customer_name;

-- 14. Find customers with the highest number of transactions.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(t.transaction_id) AS transaction_count
FROM customers AS c
JOIN accounts AS a
    ON c.customer_id = a.customer_id
JOIN transactions AS t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY transaction_count DESC, customer_name;

-- 15. Find large transactions above a chosen threshold.
-- This can help detect transactions that may need review.
SELECT
    t.transaction_id,
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    t.transaction_date,
    t.transaction_type,
    t.amount,
    t.transaction_status
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
WHERE t.amount >= 1000000.00
ORDER BY t.amount DESC, t.transaction_date;

-- 16. Calculate daily transaction volume.
-- DATE_TRUNC groups timestamps or dates into daily reporting periods.
-- total_requested_amount includes all statuses, while successful_transaction_amount excludes failed and pending rows.
SELECT
    DATE_TRUNC('day', transaction_date)::date AS transaction_day,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_requested_amount,
    SUM(
        CASE
            WHEN transaction_status = 'success' THEN amount
            ELSE 0
        END
    ) AS successful_transaction_amount
FROM transactions
GROUP BY DATE_TRUNC('day', transaction_date)::date
ORDER BY transaction_day;

-- 17. Calculate running balance per account using a window function.
-- Failed and pending transactions do not change the running balance.
-- This example starts from 0 and applies each successful signed movement over time.
WITH signed_transactions AS (
    SELECT
        t.transaction_id,
        t.account_id,
        a.account_number,
        t.transaction_date,
        t.transaction_type,
        t.transaction_status,
        t.amount,
        CASE
            WHEN t.transaction_status <> 'success' THEN 0
            WHEN t.transaction_type IN ('deposit', 'transfer_in') THEN t.amount
            WHEN t.transaction_type IN ('withdrawal', 'transfer_out', 'fee') THEN -t.amount
            ELSE 0
        END AS signed_amount
    FROM transactions AS t
    JOIN accounts AS a
        ON t.account_id = a.account_id
)
SELECT
    account_number,
    transaction_id,
    transaction_date,
    transaction_type,
    transaction_status,
    amount,
    signed_amount,
    SUM(signed_amount) OVER (
        PARTITION BY account_id
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_balance
FROM signed_transactions
ORDER BY account_number, transaction_date, transaction_id;

-- 18. Show transaction summary by transaction type and status.
SELECT
    transaction_type,
    transaction_status,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY transaction_type, transaction_status
ORDER BY transaction_type, transaction_status;

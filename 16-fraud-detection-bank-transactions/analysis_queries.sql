-- Day 16 - Fraud Detection with Bank Transactions
-- PostgreSQL analysis queries
--
-- Important:
-- These queries identify suspicious patterns for review.
-- They do not confirm fraud.
--
-- Example learning rules used in this project:
-- High-value transaction: amount >= 1,000,000 MMK
-- Late-night transaction: hour >= 23 OR hour < 5
-- Rapid transaction: transaction within 10 minutes of the previous transaction
-- Amount spike: amount is more than 3 times the customer's normal successful average

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

-- 2. List all accounts with customer information.
SELECT
    a.account_id,
    a.account_number,
    a.account_type,
    a.account_status,
    a.opening_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city AS customer_city,
    c.customer_type
FROM accounts AS a
JOIN customers AS c
    ON a.customer_id = c.customer_id
ORDER BY a.account_id;

-- 3. List all cards with account and customer information.
SELECT
    ca.card_id,
    ca.card_number_masked,
    ca.card_type,
    ca.card_status,
    ca.issued_date,
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name
FROM cards AS ca
JOIN accounts AS a
    ON ca.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
ORDER BY ca.card_id;

-- 4. Show all transactions with customer, account, card, and merchant details.
SELECT
    t.transaction_id,
    t.transaction_datetime,
    c.first_name || ' ' || c.last_name AS customer_name,
    a.account_number,
    ca.card_number_masked,
    m.merchant_name,
    m.merchant_category,
    t.transaction_type,
    t.amount,
    t.transaction_status,
    t.transaction_city,
    t.transaction_country,
    t.channel
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
JOIN cards AS ca
    ON t.card_id = ca.card_id
JOIN merchants AS m
    ON t.merchant_id = m.merchant_id
ORDER BY t.transaction_datetime, t.transaction_id;

-- 5. Count transactions by transaction status.
SELECT
    transaction_status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_status
ORDER BY transaction_count DESC;

-- 6. Count transactions by channel.
SELECT
    channel,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY channel
ORDER BY transaction_count DESC;

-- 7. Count transactions by transaction type.
SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;

-- 8. Calculate total transaction amount by customer.
-- This includes all statuses so risk teams can see total attempted activity.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_amount
FROM customers AS c
JOIN accounts AS a
    ON c.customer_id = a.customer_id
JOIN transactions AS t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, customer_name
ORDER BY total_transaction_amount DESC;

-- 9. Find high-value transactions above a chosen threshold.
-- Learning threshold: amount >= 1,000,000 MMK.
SELECT
    t.transaction_id,
    t.transaction_datetime,
    c.first_name || ' ' || c.last_name AS customer_name,
    a.account_number,
    t.amount,
    t.transaction_status,
    t.transaction_city,
    t.transaction_country,
    t.channel
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
WHERE t.amount >= 1000000
ORDER BY t.amount DESC;

-- 10. Find failed or declined transactions.
SELECT
    t.transaction_id,
    t.transaction_datetime,
    c.first_name || ' ' || c.last_name AS customer_name,
    ca.card_number_masked,
    t.amount,
    t.transaction_status,
    t.channel
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
JOIN cards AS ca
    ON t.card_id = ca.card_id
WHERE t.transaction_status IN ('failed', 'declined')
ORDER BY t.transaction_datetime;

-- 11. Find accounts with multiple failed or declined transactions.
SELECT
    a.account_id,
    a.account_number,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(*) AS failed_or_declined_count
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
WHERE t.transaction_status IN ('failed', 'declined')
GROUP BY a.account_id, a.account_number, customer_name
HAVING COUNT(*) >= 2
ORDER BY failed_or_declined_count DESC;

-- 12. Find cards with repeated declined transactions.
SELECT
    ca.card_id,
    ca.card_number_masked,
    ca.card_status,
    COUNT(*) AS declined_count
FROM transactions AS t
JOIN cards AS ca
    ON t.card_id = ca.card_id
WHERE t.transaction_status = 'declined'
GROUP BY ca.card_id, ca.card_number_masked, ca.card_status
HAVING COUNT(*) >= 2
ORDER BY declined_count DESC;

-- 13. Find transactions outside normal hours.
-- Learning rule: late-night means 11 PM to before 5 AM.
SELECT
    transaction_id,
    transaction_datetime,
    amount,
    transaction_status,
    transaction_city,
    transaction_country,
    channel,
    EXTRACT(HOUR FROM transaction_datetime) AS transaction_hour
FROM transactions
WHERE EXTRACT(HOUR FROM transaction_datetime) >= 23
   OR EXTRACT(HOUR FROM transaction_datetime) < 5
ORDER BY transaction_datetime;

-- 14. Find rapid transactions from the same account within a short time window.
-- LAG compares each transaction with the previous transaction for the same account.
WITH ordered_transactions AS (
    SELECT
        t.transaction_id,
        t.account_id,
        a.account_number,
        t.transaction_datetime,
        t.amount,
        t.transaction_status,
        LAG(t.transaction_datetime) OVER (
            PARTITION BY t.account_id
            ORDER BY t.transaction_datetime
        ) AS previous_transaction_datetime
    FROM transactions AS t
    JOIN accounts AS a
        ON t.account_id = a.account_id
)
SELECT
    transaction_id,
    account_number,
    transaction_datetime,
    previous_transaction_datetime,
    ROUND(
        EXTRACT(EPOCH FROM (transaction_datetime - previous_transaction_datetime)) / 60,
        2
    ) AS minutes_since_previous_transaction,
    amount,
    transaction_status
FROM ordered_transactions
WHERE previous_transaction_datetime IS NOT NULL
  AND transaction_datetime - previous_transaction_datetime <= INTERVAL '10 minutes'
ORDER BY account_number, transaction_datetime;

-- 15. Find customers transacting from multiple cities on the same day.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    DATE(t.transaction_datetime) AS transaction_date,
    COUNT(DISTINCT t.transaction_city) AS city_count,
    STRING_AGG(DISTINCT t.transaction_city, ', ' ORDER BY t.transaction_city) AS cities
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name, DATE(t.transaction_datetime)
HAVING COUNT(DISTINCT t.transaction_city) > 1
ORDER BY transaction_date, city_count DESC;

-- 16. Find customers transacting from multiple countries within a short period.
-- This simplified query checks whether the previous transaction was in a different country
-- within the last 24 hours.
WITH customer_transactions AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        t.transaction_id,
        t.transaction_datetime,
        t.transaction_country,
        LAG(t.transaction_country) OVER (
            PARTITION BY c.customer_id
            ORDER BY t.transaction_datetime
        ) AS previous_country,
        LAG(t.transaction_datetime) OVER (
            PARTITION BY c.customer_id
            ORDER BY t.transaction_datetime
        ) AS previous_transaction_datetime
    FROM transactions AS t
    JOIN accounts AS a
        ON t.account_id = a.account_id
    JOIN customers AS c
        ON a.customer_id = c.customer_id
)
SELECT
    customer_id,
    customer_name,
    transaction_id,
    transaction_datetime,
    previous_transaction_datetime,
    previous_country,
    transaction_country
FROM customer_transactions
WHERE previous_country IS NOT NULL
  AND transaction_country <> previous_country
  AND transaction_datetime - previous_transaction_datetime <= INTERVAL '24 hours'
ORDER BY customer_id, transaction_datetime;

-- 17. Find transactions where transaction city differs from customer home city.
SELECT
    t.transaction_id,
    t.transaction_datetime,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city AS customer_home_city,
    t.transaction_city,
    t.transaction_country,
    t.amount,
    t.channel
FROM transactions AS t
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
WHERE t.transaction_city <> c.city
ORDER BY t.transaction_datetime;

-- 18. Find sudden spikes in transaction amount compared to customer average.
-- Learning rule: amount > 3 times the customer's normal successful transaction average.
-- The normal average excludes transactions at or above 1,000,000 MMK.
WITH successful_transactions AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        t.transaction_id,
        t.transaction_datetime,
        t.amount,
        AVG(CASE WHEN t.amount < 1000000 THEN t.amount END) OVER (
            PARTITION BY c.customer_id
        ) AS normal_successful_avg_amount
    FROM transactions AS t
    JOIN accounts AS a
        ON t.account_id = a.account_id
    JOIN customers AS c
        ON a.customer_id = c.customer_id
    WHERE t.transaction_status = 'success'
)
SELECT
    customer_id,
    customer_name,
    transaction_id,
    transaction_datetime,
    amount,
    ROUND(normal_successful_avg_amount, 2) AS normal_successful_avg_amount
FROM successful_transactions
WHERE normal_successful_avg_amount IS NOT NULL
  AND amount > normal_successful_avg_amount * 3
ORDER BY amount DESC;

-- 19. Find merchants with unusually high failed transactions.
SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    COUNT(*) FILTER (WHERE t.transaction_status IN ('failed', 'declined')) AS failed_or_declined_count,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) FILTER (WHERE t.transaction_status IN ('failed', 'declined')) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS failed_or_declined_rate_percent
FROM merchants AS m
JOIN transactions AS t
    ON m.merchant_id = t.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category
HAVING COUNT(*) FILTER (WHERE t.transaction_status IN ('failed', 'declined')) >= 2
ORDER BY failed_or_declined_rate_percent DESC;

-- 20. Find top merchant categories by flagged transaction count.
SELECT
    m.merchant_category,
    COUNT(DISTINCT ft.transaction_id) AS flagged_transaction_count
FROM flagged_transactions AS ft
JOIN transactions AS t
    ON ft.transaction_id = t.transaction_id
JOIN merchants AS m
    ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_category
ORDER BY flagged_transaction_count DESC;

-- 21. Show flagged transactions with rule names and review status.
SELECT
    ft.flag_id,
    ft.flagged_at,
    fr.rule_name,
    fr.risk_score,
    ft.review_status,
    t.transaction_id,
    t.transaction_datetime,
    c.first_name || ' ' || c.last_name AS customer_name,
    t.amount,
    t.transaction_status,
    ft.reviewer_note
FROM flagged_transactions AS ft
JOIN fraud_rules AS fr
    ON ft.rule_id = fr.rule_id
JOIN transactions AS t
    ON ft.transaction_id = t.transaction_id
JOIN accounts AS a
    ON t.account_id = a.account_id
JOIN customers AS c
    ON a.customer_id = c.customer_id
ORDER BY ft.flagged_at;

-- 22. Count flagged transactions by fraud rule.
SELECT
    fr.rule_name,
    fr.risk_score,
    COUNT(ft.flag_id) AS flag_count
FROM fraud_rules AS fr
LEFT JOIN flagged_transactions AS ft
    ON fr.rule_id = ft.rule_id
GROUP BY fr.rule_id, fr.rule_name, fr.risk_score
ORDER BY flag_count DESC, fr.risk_score DESC;

-- 23. Count flagged transactions by review status.
SELECT
    review_status,
    COUNT(*) AS flag_count
FROM flagged_transactions
GROUP BY review_status
ORDER BY flag_count DESC;

-- 24. Calculate flag rate by transaction channel.
-- Flag rate = distinct flagged transactions / total transactions in that channel.
SELECT
    t.channel,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    COUNT(DISTINCT ft.transaction_id) AS flagged_transactions,
    ROUND(
        COUNT(DISTINCT ft.transaction_id) * 100.0
        / NULLIF(COUNT(DISTINCT t.transaction_id), 0),
        2
    ) AS flag_rate_percent
FROM transactions AS t
LEFT JOIN flagged_transactions AS ft
    ON t.transaction_id = ft.transaction_id
GROUP BY t.channel
ORDER BY flag_rate_percent DESC;

-- 25. Calculate flag rate by transaction type.
SELECT
    t.transaction_type,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    COUNT(DISTINCT ft.transaction_id) AS flagged_transactions,
    ROUND(
        COUNT(DISTINCT ft.transaction_id) * 100.0
        / NULLIF(COUNT(DISTINCT t.transaction_id), 0),
        2
    ) AS flag_rate_percent
FROM transactions AS t
LEFT JOIN flagged_transactions AS ft
    ON t.transaction_id = ft.transaction_id
GROUP BY t.transaction_type
ORDER BY flag_rate_percent DESC;

-- 26. Calculate risk score per transaction based on active rules.
-- This uses the review flags table and active rule scores.
WITH transaction_rule_scores AS (
    SELECT
        t.transaction_id,
        COALESCE(SUM(fr.risk_score) FILTER (WHERE fr.is_active), 0) AS total_risk_score,
        COUNT(ft.flag_id) FILTER (WHERE fr.is_active) AS active_rule_count
    FROM transactions AS t
    LEFT JOIN flagged_transactions AS ft
        ON t.transaction_id = ft.transaction_id
    LEFT JOIN fraud_rules AS fr
        ON ft.rule_id = fr.rule_id
    GROUP BY t.transaction_id
)
SELECT
    t.transaction_id,
    t.transaction_datetime,
    t.amount,
    t.transaction_status,
    t.channel,
    trs.active_rule_count,
    trs.total_risk_score,
    CASE
        WHEN trs.total_risk_score >= 70 THEN 'high_review'
        WHEN trs.total_risk_score >= 40 THEN 'medium_review'
        WHEN trs.total_risk_score > 0 THEN 'low_review'
        ELSE 'normal'
    END AS estimated_risk_level
FROM transactions AS t
JOIN transaction_rule_scores AS trs
    ON t.transaction_id = trs.transaction_id
ORDER BY trs.total_risk_score DESC, t.transaction_datetime;

-- 27. Calculate total risk score per customer.
WITH customer_risk AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COALESCE(SUM(fr.risk_score) FILTER (WHERE fr.is_active), 0) AS total_risk_score,
        COUNT(DISTINCT ft.transaction_id) AS flagged_transaction_count
    FROM customers AS c
    LEFT JOIN accounts AS a
        ON c.customer_id = a.customer_id
    LEFT JOIN transactions AS t
        ON a.account_id = t.account_id
    LEFT JOIN flagged_transactions AS ft
        ON t.transaction_id = ft.transaction_id
    LEFT JOIN fraud_rules AS fr
        ON ft.rule_id = fr.rule_id
    GROUP BY c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    flagged_transaction_count,
    total_risk_score,
    RANK() OVER (ORDER BY total_risk_score DESC) AS risk_rank
FROM customer_risk
ORDER BY risk_rank, customer_name;

-- 28. Find customers with high total risk score.
WITH customer_risk AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.city,
        COALESCE(SUM(fr.risk_score) FILTER (WHERE fr.is_active), 0) AS total_risk_score,
        COUNT(DISTINCT ft.transaction_id) AS flagged_transaction_count
    FROM customers AS c
    LEFT JOIN accounts AS a
        ON c.customer_id = a.customer_id
    LEFT JOIN transactions AS t
        ON a.account_id = t.account_id
    LEFT JOIN flagged_transactions AS ft
        ON t.transaction_id = ft.transaction_id
    LEFT JOIN fraud_rules AS fr
        ON ft.rule_id = fr.rule_id
    GROUP BY c.customer_id, customer_name, c.city
)
SELECT
    customer_id,
    customer_name,
    city,
    flagged_transaction_count,
    total_risk_score
FROM customer_risk
WHERE total_risk_score >= 70
ORDER BY total_risk_score DESC;

-- 29. Build a rule-based suspicious transaction summary using CASE WHEN.
-- This query derives simple review reasons directly from transaction attributes.
WITH customer_normal_average AS (
    SELECT
        c.customer_id,
        AVG(t.amount) AS normal_successful_avg_amount
    FROM customers AS c
    JOIN accounts AS a
        ON c.customer_id = a.customer_id
    JOIN transactions AS t
        ON a.account_id = t.account_id
    WHERE t.transaction_status = 'success'
      AND t.amount < 1000000
    GROUP BY c.customer_id
),
transaction_context AS (
    SELECT
        t.transaction_id,
        t.transaction_datetime,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.city AS customer_home_city,
        ca.card_status,
        t.amount,
        t.transaction_status,
        t.transaction_city,
        t.transaction_country,
        t.channel,
        cna.normal_successful_avg_amount
    FROM transactions AS t
    JOIN accounts AS a
        ON t.account_id = a.account_id
    JOIN customers AS c
        ON a.customer_id = c.customer_id
    JOIN cards AS ca
        ON t.card_id = ca.card_id
    LEFT JOIN customer_normal_average AS cna
        ON c.customer_id = cna.customer_id
)
SELECT
    transaction_id,
    transaction_datetime,
    customer_name,
    amount,
    transaction_status,
    transaction_city,
    transaction_country,
    channel,
    CASE
        WHEN card_status IN ('blocked', 'expired') THEN 'card_status_needs_review'
        WHEN amount >= 1000000 THEN 'high_value_review'
        WHEN normal_successful_avg_amount IS NOT NULL
             AND amount > normal_successful_avg_amount * 3 THEN 'amount_spike_review'
        WHEN transaction_status IN ('failed', 'declined') THEN 'failed_or_declined_review'
        WHEN EXTRACT(HOUR FROM transaction_datetime) >= 23
             OR EXTRACT(HOUR FROM transaction_datetime) < 5 THEN 'late_night_review'
        WHEN transaction_city <> customer_home_city THEN 'different_city_review'
        ELSE 'normal_pattern'
    END AS risk_reason
FROM transaction_context
ORDER BY transaction_datetime;

-- 30. Create a customer risk review list.
-- This list combines transaction volume, flags, and rule scores at customer level.
WITH customer_review_metrics AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.city,
        COUNT(DISTINCT t.transaction_id) AS total_transactions,
        COUNT(DISTINCT ft.transaction_id) AS flagged_transactions,
        COALESCE(SUM(fr.risk_score) FILTER (WHERE fr.is_active), 0) AS total_risk_score,
        MAX(ft.flagged_at) AS last_flagged_at
    FROM customers AS c
    LEFT JOIN accounts AS a
        ON c.customer_id = a.customer_id
    LEFT JOIN transactions AS t
        ON a.account_id = t.account_id
    LEFT JOIN flagged_transactions AS ft
        ON t.transaction_id = ft.transaction_id
    LEFT JOIN fraud_rules AS fr
        ON ft.rule_id = fr.rule_id
    GROUP BY c.customer_id, customer_name, c.city
)
SELECT
    customer_id,
    customer_name,
    city,
    total_transactions,
    flagged_transactions,
    total_risk_score,
    last_flagged_at,
    CASE
        WHEN total_risk_score >= 100 THEN 'priority_review'
        WHEN total_risk_score >= 50 THEN 'standard_review'
        WHEN flagged_transactions > 0 THEN 'watch_list'
        ELSE 'normal'
    END AS review_priority,
    RANK() OVER (ORDER BY total_risk_score DESC, flagged_transactions DESC) AS review_rank
FROM customer_review_metrics
ORDER BY review_rank, customer_name;

-- 31. Build a basic fraud monitoring dashboard view using SQL.
-- The dashboard uses review flags when they exist and otherwise shows normal activity.
WITH flag_summary AS (
    SELECT
        ft.transaction_id,
        STRING_AGG(fr.rule_name, ', ' ORDER BY fr.rule_name) AS risk_reason,
        SUM(fr.risk_score) FILTER (WHERE fr.is_active) AS total_risk_score
    FROM flagged_transactions AS ft
    JOIN fraud_rules AS fr
        ON ft.rule_id = fr.rule_id
    GROUP BY ft.transaction_id
),
dashboard_base AS (
    SELECT
        t.transaction_id,
        t.transaction_datetime,
        c.first_name || ' ' || c.last_name AS customer_name,
        a.account_number,
        ca.card_number_masked,
        m.merchant_name,
        m.merchant_category,
        t.transaction_type,
        t.channel,
        t.amount,
        t.transaction_status,
        t.transaction_city,
        t.transaction_country,
        COALESCE(fs.risk_reason, 'No review rule matched') AS risk_reason,
        COALESCE(fs.total_risk_score, 0) AS total_risk_score
    FROM transactions AS t
    JOIN accounts AS a
        ON t.account_id = a.account_id
    JOIN customers AS c
        ON a.customer_id = c.customer_id
    JOIN cards AS ca
        ON t.card_id = ca.card_id
    JOIN merchants AS m
        ON t.merchant_id = m.merchant_id
    LEFT JOIN flag_summary AS fs
        ON t.transaction_id = fs.transaction_id
)
SELECT
    transaction_id,
    transaction_datetime,
    customer_name,
    account_number,
    card_number_masked,
    merchant_name,
    merchant_category,
    transaction_type,
    channel,
    amount,
    transaction_status,
    transaction_city,
    transaction_country,
    risk_reason,
    CASE
        WHEN total_risk_score >= 70 THEN 'high_review'
        WHEN total_risk_score >= 40 THEN 'medium_review'
        WHEN total_risk_score > 0 THEN 'low_review'
        ELSE 'normal'
    END AS estimated_risk_level
FROM dashboard_base
ORDER BY total_risk_score DESC, transaction_datetime;

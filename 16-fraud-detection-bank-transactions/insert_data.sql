-- Day 16 - Fraud Detection with Bank Transactions
-- Fictional sample data for PostgreSQL
--
-- No real banking, customer, or card data is used.
-- Card numbers are fictional masked values only.

INSERT INTO customers (
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    city,
    customer_type
)
SELECT
    customer_number,
    (ARRAY['Aung','May','Ko','Su','Nandar','Thiri','Kyaw','Ei','Zaw','Hnin','Myo','Yu','Min','Khin','Thet'])[((customer_number - 1) % 15) + 1],
    (ARRAY['Thu','Sandi','Htet','Mon','Aye','Moe','Zin','Phyo','Min','Wai','Thant','Waddy','Oo','Win','Naing'])[((customer_number - 1) % 15) + 1],
    'risk_customer' || customer_number || '@example.com',
    '+95-9-77' || LPAD(customer_number::TEXT, 6, '0'),
    (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa'])[((customer_number - 1) % 8) + 1],
    CASE
        WHEN customer_number IN (5, 10, 15, 20, 25) THEN 'business'
        ELSE 'individual'
    END
FROM generate_series(1, 25) AS gs(customer_number);

-- 30 accounts. The first 25 accounts map one-to-one to customers.
-- The last 5 accounts give some customers more than one account.
INSERT INTO accounts (
    account_id,
    customer_id,
    account_number,
    account_type,
    account_status,
    opening_date
)
SELECT
    account_number,
    account_number AS customer_id,
    'MMK-ACCT-' || LPAD(account_number::TEXT, 5, '0'),
    CASE
        WHEN account_number IN (5, 10, 15, 20, 25) THEN 'business'
        WHEN account_number % 3 = 0 THEN 'current'
        ELSE 'savings'
    END,
    CASE
        WHEN account_number IN (11, 22) THEN 'frozen'
        WHEN account_number IN (18, 25) THEN 'closed'
        ELSE 'active'
    END,
    DATE '2023-01-01' + (account_number * 17)
FROM generate_series(1, 25) AS gs(account_number);

INSERT INTO accounts (
    account_id,
    customer_id,
    account_number,
    account_type,
    account_status,
    opening_date
) VALUES
    (26, 1, 'MMK-ACCT-00026', 'current', 'active', '2024-06-01'),
    (27, 3, 'MMK-ACCT-00027', 'savings', 'active', '2024-07-15'),
    (28, 5, 'MMK-ACCT-00028', 'business', 'active', '2024-08-10'),
    (29, 10, 'MMK-ACCT-00029', 'business', 'frozen', '2024-09-05'),
    (30, 15, 'MMK-ACCT-00030', 'current', 'closed', '2024-10-20');

-- 25 cards. All card values are fictional and masked.
INSERT INTO cards (
    card_id,
    account_id,
    card_number_masked,
    card_type,
    card_status,
    issued_date
)
SELECT
    account_id,
    account_id,
    'XXXX-XXXX-XXXX-' || LPAD((4000 + account_id)::TEXT, 4, '0'),
    CASE
        WHEN account_id % 5 = 0 THEN 'credit'
        WHEN account_id % 7 = 0 THEN 'prepaid'
        ELSE 'debit'
    END,
    CASE
        WHEN account_id IN (4, 11) THEN 'blocked'
        WHEN account_id IN (18, 23) THEN 'expired'
        ELSE 'active'
    END,
    DATE '2023-03-01' + (account_id * 13)
FROM accounts
WHERE account_id <= 25
ORDER BY account_id;

INSERT INTO merchants (
    merchant_id,
    merchant_name,
    merchant_category,
    city,
    country
) VALUES
    (1, 'Yangon Fresh Mart', 'grocery', 'Yangon', 'Myanmar'),
    (2, 'Mandalay Mobile Center', 'electronics', 'Mandalay', 'Myanmar'),
    (3, 'Naypyidaw Travel Desk', 'travel', 'Naypyidaw', 'Myanmar'),
    (4, 'Bago Cinema Club', 'entertainment', 'Bago', 'Myanmar'),
    (5, 'Taunggyi Fuel Stop', 'fuel', 'Taunggyi', 'Myanmar'),
    (6, 'Mawlamyine Tea House', 'restaurant', 'Mawlamyine', 'Myanmar'),
    (7, 'Pathein Fashion Hub', 'fashion', 'Pathein', 'Myanmar'),
    (8, 'Monywa Online Mall', 'online_marketplace', 'Monywa', 'Myanmar'),
    (9, 'Yangon Pay Services', 'financial_service', 'Yangon', 'Myanmar'),
    (10, 'Mandalay Grocery Plus', 'grocery', 'Mandalay', 'Myanmar'),
    (11, 'Bangkok Electronics Store', 'electronics', 'Bangkok', 'Thailand'),
    (12, 'Singapore Travel Online', 'travel', 'Singapore', 'Singapore'),
    (13, 'Kuala Lumpur Marketplace', 'online_marketplace', 'Kuala Lumpur', 'Malaysia'),
    (14, 'Tokyo Digital Goods', 'entertainment', 'Tokyo', 'Japan'),
    (15, 'Seoul Fashion Market', 'fashion', 'Seoul', 'South Korea'),
    (16, 'Yangon Business Bank Agent', 'financial_service', 'Yangon', 'Myanmar'),
    (17, 'Bago Highway Fuel', 'fuel', 'Bago', 'Myanmar'),
    (18, 'Taunggyi Family Restaurant', 'restaurant', 'Taunggyi', 'Myanmar'),
    (19, 'Pathein Grocery Corner', 'grocery', 'Pathein', 'Myanmar'),
    (20, 'Monywa Device Shop', 'electronics', 'Monywa', 'Myanmar');

INSERT INTO fraud_rules (
    rule_id,
    rule_name,
    rule_description,
    risk_score,
    is_active
) VALUES
    (1, 'High Value Transaction', 'Transaction amount is at or above 1,000,000 MMK and should be reviewed.', 35, TRUE),
    (2, 'Repeated Failed Attempts', 'Account or card has multiple failed or declined transactions.', 25, TRUE),
    (3, 'Rapid Transactions', 'Multiple transactions from the same account occur within a short time window.', 30, TRUE),
    (4, 'Different Location Pattern', 'Customer activity appears in different cities or countries close together.', 30, TRUE),
    (5, 'Late Night Transaction', 'Transaction happens between 11 PM and 5 AM.', 15, TRUE),
    (6, 'Amount Spike', 'Transaction amount is much higher than the customer average.', 35, TRUE),
    (7, 'International Transaction', 'Transaction country differs from the customer home country.', 20, TRUE),
    (8, 'Blocked Or Expired Card Activity', 'Transaction uses a card that is blocked or expired and needs review.', 40, TRUE);

-- 100 regular transactions with mixed statuses and channels.
INSERT INTO transactions (
    transaction_id,
    account_id,
    card_id,
    merchant_id,
    transaction_datetime,
    transaction_type,
    amount,
    currency,
    transaction_status,
    transaction_city,
    transaction_country,
    channel
)
SELECT
    transaction_number,
    ((transaction_number - 1) % 25) + 1,
    ((transaction_number - 1) % 25) + 1,
    ((transaction_number - 1) % 20) + 1,
    TIMESTAMP '2026-04-01 08:00:00'
        + (((transaction_number - 1) % 20) * INTERVAL '1 day')
        + (((transaction_number * 37) % 720) * INTERVAL '1 minute'),
    (ARRAY['purchase','withdrawal','transfer','online_payment','bill_payment'])[((transaction_number - 1) % 5) + 1],
    CASE
        WHEN transaction_number % 29 = 0 THEN 880000.00
        ELSE 25000.00 + (((transaction_number - 1) % 12) * 38000.00)
    END,
    'MMK',
    CASE
        WHEN transaction_number % 23 = 0 THEN 'pending'
        WHEN transaction_number % 19 = 0 THEN 'failed'
        WHEN transaction_number % 17 = 0 THEN 'declined'
        ELSE 'success'
    END,
    CASE
        WHEN transaction_number % 37 = 0 THEN 'Singapore'
        WHEN transaction_number % 31 = 0 THEN 'Bangkok'
        ELSE (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa'])[((transaction_number - 1) % 8) + 1]
    END,
    CASE
        WHEN transaction_number % 37 = 0 THEN 'Singapore'
        WHEN transaction_number % 31 = 0 THEN 'Thailand'
        ELSE 'Myanmar'
    END,
    (ARRAY['atm','pos','online','mobile_app','bank_branch'])[((transaction_number - 1) % 5) + 1]
FROM generate_series(1, 100) AS gs(transaction_number);

-- 20 scenario transactions for specific review patterns.
INSERT INTO transactions (
    transaction_id,
    account_id,
    card_id,
    merchant_id,
    transaction_datetime,
    transaction_type,
    amount,
    currency,
    transaction_status,
    transaction_city,
    transaction_country,
    channel
) VALUES
    (101, 3, 3, 11, '2026-04-22 14:10:00', 'online_payment', 2500000.00, 'MMK', 'success', 'Bangkok', 'Thailand', 'online'),
    (102, 8, 8, 12, '2026-04-22 15:45:00', 'purchase', 1800000.00, 'MMK', 'success', 'Singapore', 'Singapore', 'online'),
    (103, 10, 10, 9, '2026-04-23 10:30:00', 'transfer', 3200000.00, 'MMK', 'success', 'Yangon', 'Myanmar', 'mobile_app'),
    (104, 15, 15, 16, '2026-04-23 11:15:00', 'bill_payment', 1250000.00, 'MMK', 'success', 'Yangon', 'Myanmar', 'bank_branch'),
    (105, 21, 21, 13, '2026-04-24 09:20:00', 'online_payment', 4100000.00, 'MMK', 'success', 'Kuala Lumpur', 'Malaysia', 'online'),
    (106, 4, 4, 2, '2026-04-24 13:00:00', 'purchase', 280000.00, 'MMK', 'declined', 'Mandalay', 'Myanmar', 'pos'),
    (107, 4, 4, 2, '2026-04-24 13:05:00', 'purchase', 285000.00, 'MMK', 'declined', 'Mandalay', 'Myanmar', 'pos'),
    (108, 4, 4, 2, '2026-04-24 13:10:00', 'purchase', 290000.00, 'MMK', 'failed', 'Mandalay', 'Myanmar', 'pos'),
    (109, 4, 4, 2, '2026-04-24 13:18:00', 'purchase', 300000.00, 'MMK', 'declined', 'Mandalay', 'Myanmar', 'pos'),
    (110, 4, 4, 2, '2026-04-24 13:25:00', 'purchase', 305000.00, 'MMK', 'failed', 'Mandalay', 'Myanmar', 'pos'),
    (111, 6, 6, 8, '2026-04-25 16:00:00', 'online_payment', 90000.00, 'MMK', 'success', 'Monywa', 'Myanmar', 'mobile_app'),
    (112, 6, 6, 8, '2026-04-25 16:03:00', 'online_payment', 95000.00, 'MMK', 'success', 'Monywa', 'Myanmar', 'mobile_app'),
    (113, 6, 6, 8, '2026-04-25 16:06:00', 'online_payment', 98000.00, 'MMK', 'success', 'Monywa', 'Myanmar', 'mobile_app'),
    (114, 6, 6, 8, '2026-04-25 16:09:00', 'online_payment', 102000.00, 'MMK', 'success', 'Monywa', 'Myanmar', 'mobile_app'),
    (115, 6, 6, 8, '2026-04-25 16:12:00', 'online_payment', 104000.00, 'MMK', 'success', 'Monywa', 'Myanmar', 'mobile_app'),
    (116, 7, 7, 1, '2026-04-26 09:00:00', 'purchase', 65000.00, 'MMK', 'success', 'Yangon', 'Myanmar', 'pos'),
    (117, 7, 7, 11, '2026-04-26 11:00:00', 'purchase', 700000.00, 'MMK', 'success', 'Bangkok', 'Thailand', 'online'),
    (118, 7, 7, 12, '2026-04-26 14:30:00', 'purchase', 720000.00, 'MMK', 'success', 'Singapore', 'Singapore', 'online'),
    (119, 9, 9, 14, '2026-04-27 23:45:00', 'online_payment', 450000.00, 'MMK', 'success', 'Tokyo', 'Japan', 'online'),
    (120, 12, 12, 9, '2026-04-28 02:15:00', 'transfer', 980000.00, 'MMK', 'pending', 'Yangon', 'Myanmar', 'mobile_app');

-- Flagged transactions are review records, not final decision labels.
INSERT INTO flagged_transactions (
    transaction_id,
    rule_id,
    flagged_at,
    review_status,
    reviewer_note
) VALUES
    (101, 1, '2026-04-22 14:12:00', 'escalated', 'High value international online transaction flagged for review.'),
    (101, 6, '2026-04-22 14:13:00', 'pending_review', 'Amount is much higher than the customer normal pattern.'),
    (102, 1, '2026-04-22 15:47:00', 'pending_review', 'Large transaction needs review.'),
    (102, 7, '2026-04-22 15:48:00', 'pending_review', 'International transaction review needed.'),
    (103, 1, '2026-04-23 10:32:00', 'escalated', 'High value transfer flagged for manual review.'),
    (104, 1, '2026-04-23 11:17:00', 'cleared', 'Reviewed and cleared after documentation check.'),
    (105, 1, '2026-04-24 09:22:00', 'confirmed_issue', 'High value cross-border payment requires follow-up documentation.'),
    (105, 7, '2026-04-24 09:23:00', 'pending_review', 'International transaction review needed.'),
    (106, 2, '2026-04-24 13:02:00', 'pending_review', 'Declined transaction on blocked card.'),
    (106, 8, '2026-04-24 13:03:00', 'escalated', 'Blocked card activity needs review.'),
    (107, 2, '2026-04-24 13:07:00', 'pending_review', 'Repeated declined attempt.'),
    (108, 2, '2026-04-24 13:12:00', 'pending_review', 'Repeated failed attempt.'),
    (109, 2, '2026-04-24 13:20:00', 'escalated', 'Multiple declined attempts in short period.'),
    (110, 2, '2026-04-24 13:27:00', 'escalated', 'Multiple failed attempts in short period.'),
    (112, 3, '2026-04-25 16:05:00', 'pending_review', 'Rapid transaction pattern started.'),
    (113, 3, '2026-04-25 16:08:00', 'pending_review', 'Rapid transaction pattern continues.'),
    (114, 3, '2026-04-25 16:11:00', 'pending_review', 'Rapid transaction pattern continues.'),
    (115, 3, '2026-04-25 16:14:00', 'escalated', 'Several transactions within minutes.'),
    (117, 4, '2026-04-26 11:03:00', 'pending_review', 'Different country shortly after local transaction.'),
    (117, 7, '2026-04-26 11:04:00', 'pending_review', 'International transaction review needed.'),
    (118, 4, '2026-04-26 14:33:00', 'escalated', 'Multiple countries on the same day.'),
    (118, 7, '2026-04-26 14:34:00', 'pending_review', 'International transaction review needed.'),
    (119, 5, '2026-04-27 23:47:00', 'pending_review', 'Late-night international online payment.'),
    (119, 7, '2026-04-27 23:48:00', 'pending_review', 'International transaction review needed.'),
    (120, 5, '2026-04-28 02:17:00', 'pending_review', 'Late-night pending transfer.'),
    (17, 2, '2026-04-17 18:35:00', 'cleared', 'Declined transaction reviewed.'),
    (19, 2, '2026-04-19 19:50:00', 'cleared', 'Failed transaction reviewed.'),
    (31, 7, '2026-04-11 14:15:00', 'pending_review', 'International transaction review needed.'),
    (37, 7, '2026-04-17 17:55:00', 'pending_review', 'International transaction review needed.'),
    (68, 2, '2026-04-08 15:20:00', 'pending_review', 'Declined transaction included in review queue.');

-- Day 13 - Subscription-Based Platform Analysis
-- Sample data for PostgreSQL
--
-- All users and business records are fictional.
-- The data is designed to support revenue, churn, renewal, usage, and Subscriber 360 analysis.

INSERT INTO users (first_name, last_name, email, phone_number, city, signup_date) VALUES
    ('Aung', 'Thu', 'aung.thu13@example.com', '09-510001001', 'Yangon', '2025-01-05'),
    ('May', 'Sandi', 'may.sandi13@example.com', '09-510001002', 'Yangon', '2025-01-12'),
    ('Ko', 'Htet', 'ko.htet13@example.com', '09-510001003', 'Mandalay', '2025-01-20'),
    ('Su', 'Mon', 'su.mon13@example.com', '09-510001004', 'Naypyidaw', '2025-02-03'),
    ('Nandar', 'Aye', 'nandar.aye13@example.com', '09-510001005', 'Bago', '2025-02-10'),
    ('Thiri', 'Moe', 'thiri.moe13@example.com', '09-510001006', 'Taunggyi', '2025-02-18'),
    ('Kyaw', 'Zin', 'kyaw.zin13@example.com', '09-510001007', 'Mawlamyine', '2025-03-01'),
    ('Ei', 'Phyo', 'ei.phyo13@example.com', '09-510001008', 'Pathein', '2025-03-08'),
    ('Zaw', 'Min', 'zaw.min13@example.com', '09-510001009', 'Monywa', '2025-03-15'),
    ('Hnin', 'Wai', 'hnin.wai13@example.com', '09-510001010', 'Mandalay', '2025-03-24'),
    ('Myo', 'Thant', 'myo.thant13@example.com', '09-510001011', 'Yangon', '2025-04-02'),
    ('Yu', 'Waddy', 'yu.waddy13@example.com', '09-510001012', 'Taunggyi', '2025-04-11'),
    ('Lin', 'Htet', 'lin.htet13@example.com', '09-510001013', 'Naypyidaw', '2025-04-20'),
    ('Wai', 'Yan', 'wai.yan13@example.com', '09-510001014', 'Bago', '2025-05-01'),
    ('Khin', 'Hlaing', 'khin.hlaing13@example.com', '09-510001015', 'Mawlamyine', '2025-05-12'),
    ('Sai', 'Tun', 'sai.tun13@example.com', '09-510001016', 'Taunggyi', '2025-05-22'),
    ('Mya', 'Hnin', 'mya.hnin13@example.com', '09-510001017', 'Yangon', '2025-06-01'),
    ('Phyo', 'Paing', 'phyo.paing13@example.com', '09-510001018', 'Mandalay', '2025-06-10'),
    ('Nyein', 'Chan', 'nyein.chan13@example.com', '09-510001019', 'Pathein', '2025-06-18'),
    ('Su', 'Hnin', 'su.hnin13@example.com', '09-510001020', 'Bago', '2025-06-26'),
    ('Yamin', 'Oo', 'yamin.oo13@example.com', '09-510001021', 'Yangon', '2025-07-04'),
    ('Thiha', 'Zaw', 'thiha.zaw13@example.com', '09-510001022', 'Monywa', '2025-07-12'),
    ('Cherry', 'Win', 'cherry.win13@example.com', '09-510001023', 'Yangon', '2025-07-20'),
    ('Kaung', 'Sett', 'kaung.sett13@example.com', '09-510001024', 'Mandalay', '2025-08-01'),
    ('Moe', 'Hay', 'moe.hay13@example.com', '09-510001025', 'Naypyidaw', '2025-08-09'),
    ('Soe', 'Myat', 'soe.myat13@example.com', '09-510001026', 'Bago', '2025-08-18'),
    ('Thet', 'Mon', 'thet.mon13@example.com', '09-510001027', 'Taunggyi', '2025-08-27'),
    ('Aye', 'Chan', 'aye.chan13@example.com', '09-510001028', 'Yangon', '2025-09-05'),
    ('Tun', 'Lwin', 'tun.lwin13@example.com', '09-510001029', 'Mawlamyine', '2025-09-14'),
    ('Nilar', 'Kyaw', 'nilar.kyaw13@example.com', '09-510001030', 'Pathein', '2025-09-25');

INSERT INTO subscription_plans (plan_name, billing_cycle, monthly_price, plan_tier) VALUES
    ('Basic Monthly', 'monthly', 5000.00, 'basic'),
    ('Standard Monthly', 'monthly', 9000.00, 'standard'),
    ('Premium Monthly', 'monthly', 15000.00, 'premium'),
    ('Family Quarterly', 'quarterly', 12000.00, 'family'),
    ('Business Yearly', 'yearly', 20000.00, 'business');

INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, subscription_status, auto_renew) VALUES
    (1, 1, '2025-01-05', '2025-03-04', 'expired', FALSE),
    (1, 2, '2025-03-05', NULL, 'active', TRUE),
    (2, 2, '2025-01-12', '2025-04-11', 'cancelled', FALSE),
    (2, 3, '2025-04-12', NULL, 'active', TRUE),
    (3, 1, '2025-01-20', NULL, 'active', TRUE),
    (4, 3, '2025-02-03', '2025-08-02', 'expired', FALSE),
    (4, 4, '2025-08-03', NULL, 'active', TRUE),
    (5, 1, '2025-02-10', '2025-04-09', 'cancelled', FALSE),
    (6, 2, '2025-02-18', NULL, 'active', TRUE),
    (7, 3, '2025-03-01', '2025-06-30', 'cancelled', FALSE),
    (8, 4, '2025-03-08', NULL, 'active', TRUE),
    (9, 2, '2025-03-15', '2025-09-14', 'expired', FALSE),
    (9, 3, '2025-09-15', NULL, 'active', TRUE),
    (10, 5, '2025-03-24', NULL, 'active', TRUE),
    (11, 1, '2025-04-02', '2025-07-01', 'cancelled', FALSE),
    (12, 2, '2025-04-11', NULL, 'paused', FALSE),
    (13, 3, '2025-04-20', NULL, 'active', TRUE),
    (14, 4, '2025-05-01', '2025-10-31', 'expired', FALSE),
    (14, 4, '2025-11-01', NULL, 'active', TRUE),
    (15, 1, '2025-05-12', '2025-08-11', 'cancelled', FALSE),
    (16, 2, '2025-05-22', NULL, 'active', TRUE),
    (17, 3, '2025-06-01', '2025-09-30', 'cancelled', FALSE),
    (17, 4, '2025-10-01', NULL, 'active', TRUE),
    (18, 5, '2025-06-10', NULL, 'active', TRUE),
    (19, 1, '2025-06-18', '2025-07-17', 'expired', FALSE),
    (20, 2, '2025-06-26', '2025-09-25', 'cancelled', FALSE),
    (21, 3, '2025-07-04', NULL, 'active', TRUE),
    (22, 4, '2025-07-12', NULL, 'paused', FALSE),
    (23, 1, '2025-07-20', '2025-10-19', 'cancelled', FALSE),
    (24, 2, '2025-08-01', NULL, 'active', TRUE),
    (25, 3, '2025-08-09', NULL, 'trial', TRUE),
    (26, 4, '2025-08-18', '2025-11-17', 'cancelled', FALSE),
    (27, 5, '2025-08-27', NULL, 'active', TRUE),
    (28, 1, '2025-09-05', NULL, 'active', TRUE),
    (29, 2, '2025-09-14', '2025-12-13', 'cancelled', FALSE),
    (30, 3, '2025-09-25', NULL, 'trial', TRUE),
    (3, 2, '2025-11-01', NULL, 'active', TRUE),
    (5, 2, '2025-11-10', NULL, 'active', TRUE),
    (7, 1, '2025-12-01', '2026-02-28', 'cancelled', FALSE),
    (11, 3, '2025-12-15', NULL, 'active', TRUE),
    (15, 2, '2026-01-01', NULL, 'active', TRUE),
    (20, 1, '2026-01-10', NULL, 'active', TRUE),
    (23, 4, '2026-01-20', NULL, 'active', TRUE),
    (26, 5, '2026-02-01', NULL, 'active', TRUE),
    (29, 1, '2026-02-14', '2026-04-15', 'cancelled', FALSE);

-- Generate two payment attempts per subscription.
-- Revenue queries count only rows where payment_status = 'paid'.
-- Amount uses the billing cycle: monthly = 1 month, quarterly = 3 months, yearly = 12 months.
INSERT INTO payments (subscription_id, payment_date, payment_status, payment_method, amount)
SELECT
    s.subscription_id,
    s.start_date + ((payment_number - 1) * 30) AS payment_date,
    CASE
        WHEN s.subscription_id = 12 THEN 'pending'
        WHEN s.subscription_status = 'trial' THEN 'pending'
        WHEN s.subscription_id IN (8, 20, 35, 39) AND payment_number = 2 THEN 'failed'
        WHEN s.subscription_status = 'cancelled' AND payment_number = 2 THEN 'refunded'
        WHEN s.subscription_status = 'paused' AND payment_number = 2 THEN 'pending'
        ELSE 'paid'
    END AS payment_status,
    CASE
        WHEN s.subscription_id % 4 = 0 THEN 'card'
        WHEN s.subscription_id % 4 = 1 THEN 'mobile_wallet'
        WHEN s.subscription_id % 4 = 2 THEN 'bank_transfer'
        ELSE 'cash'
    END AS payment_method,
    CASE
        WHEN s.subscription_status = 'trial' THEN 0
        WHEN sp.billing_cycle = 'monthly' THEN sp.monthly_price
        WHEN sp.billing_cycle = 'quarterly' THEN sp.monthly_price * 3
        WHEN sp.billing_cycle = 'yearly' THEN sp.monthly_price * 12
    END AS amount
FROM subscriptions AS s
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
CROSS JOIN generate_series(1, 2) AS payment_number;

-- Generate 150 usage events: five activity records for each user.
-- Users 28 and 29 are active/paused low-usage examples.
-- User 30 is a trial user with no paid payment and almost no usage.
INSERT INTO usage_events (user_id, event_date, event_type, usage_minutes)
SELECT
    u.user_id,
    CASE
        WHEN u.user_id IN (28, 29, 30) THEN DATE '2026-02-01' + (event_number * 5)
        ELSE DATE '2026-01-01' + ((u.user_id * 4 + event_number * 13) % 120)
    END AS event_date,
    CASE
        WHEN event_number = 1 THEN 'login'
        WHEN event_number = 2 THEN 'watch'
        WHEN event_number = 3 THEN 'lesson_view'
        WHEN event_number = 4 THEN 'download'
        ELSE 'feature_use'
    END AS event_type,
    CASE
        WHEN u.user_id IN (1, 2, 10, 18, 27) THEN 180 + (event_number * 20)
        WHEN u.user_id IN (28, 29) THEN 5
        WHEN u.user_id = 30 THEN 0
        WHEN event_number IN (2, 3) THEN 75
        ELSE 20 + (event_number * 8)
    END AS usage_minutes
FROM users AS u
CROSS JOIN generate_series(1, 5) AS event_number;

INSERT INTO cancellations (subscription_id, cancellation_date, cancellation_reason) VALUES
    (3, '2025-04-11', 'Price was too high'),
    (8, '2025-04-09', 'User switched to another platform'),
    (10, '2025-06-30', 'Content did not match user needs'),
    (15, '2025-07-01', 'Payment issue'),
    (20, '2025-08-11', 'Low product usage'),
    (22, '2025-09-30', 'User no longer needed the service'),
    (26, '2025-09-25', 'Price was too high'),
    (29, '2025-10-19', 'Low product usage'),
    (32, '2025-11-17', 'User moved to business account'),
    (35, '2025-12-13', 'Payment issue'),
    (39, '2026-02-28', 'Low product usage'),
    (45, '2026-04-15', 'Temporary account pause became cancellation');

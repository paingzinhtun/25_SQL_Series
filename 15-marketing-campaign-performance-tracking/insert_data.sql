-- Day 15 - Marketing Campaign Performance Tracking
-- Sample data for PostgreSQL
--
-- All campaigns, leads, customers, conversions, and sales are fictional.
-- The data is designed to support campaign ROI, ROAS, CAC, CPL, funnel, and dashboard analysis.

INSERT INTO marketing_channels (channel_name, channel_type) VALUES
    ('Facebook', 'paid_social'),
    ('Google Search', 'paid_search'),
    ('TikTok', 'paid_social'),
    ('Organic Blog', 'organic'),
    ('Email', 'email'),
    ('Referral', 'referral'),
    ('Business Event', 'event'),
    ('Partner Program', 'partner');

INSERT INTO campaigns (
    campaign_name,
    channel_id,
    campaign_goal,
    start_date,
    end_date,
    campaign_status,
    budget
) VALUES
    ('Facebook New Year Promo', 1, 'lead_generation', '2026-01-01', '2026-01-31', 'completed', 2500000.00),
    ('Google High Intent Search', 2, 'conversion', '2026-01-05', '2026-02-15', 'completed', 1800000.00),
    ('TikTok Brand Awareness', 3, 'awareness', '2026-01-10', '2026-02-10', 'paused', 2200000.00),
    ('Email Winback Campaign', 5, 'retention', '2026-01-15', '2026-02-15', 'completed', 300000.00),
    ('Referral Rewards Push', 6, 'conversion', '2026-02-01', NULL, 'active', 200000.00),
    ('SME Business Expo Booth', 7, 'lead_generation', '2026-02-05', '2026-02-08', 'completed', 1200000.00),
    ('Partner Co-Marketing Q1', 8, 'conversion', '2026-02-10', NULL, 'active', 500000.00),
    ('Facebook Retargeting Ads', 1, 'conversion', '2026-02-15', NULL, 'active', 1600000.00),
    ('Google Competitor Keywords', 2, 'conversion', '2026-02-20', NULL, 'paused', 2400000.00),
    ('TikTok Creator Campaign', 3, 'awareness', '2026-03-01', NULL, 'active', 1800000.00),
    ('Email Product Launch', 5, 'lead_generation', '2026-03-05', NULL, 'active', 250000.00),
    ('Cancelled Display Test', 1, 'awareness', '2026-03-10', '2026-03-15', 'cancelled', 400000.00);

-- Generate 5 daily ad performance rows per campaign = 60 rows.
-- Campaign 3 has high impressions but low clicks.
-- Campaign 9 has high spend and poor return.
-- Campaign 5 has low spend and strong ROI potential.
INSERT INTO ad_performance (campaign_id, performance_date, impressions, clicks, spend)
SELECT
    c.campaign_id,
    c.start_date + (day_number - 1) AS performance_date,
    CASE
        WHEN c.campaign_id = 3 THEN 90000 + (day_number * 3000)
        WHEN c.campaign_id = 10 THEN 70000 + (day_number * 2500)
        WHEN c.campaign_id = 12 THEN 25000 + (day_number * 1000)
        ELSE 18000 + (c.campaign_id * 1800) + (day_number * 900)
    END AS impressions,
    CASE
        WHEN c.campaign_id = 3 THEN 120 + (day_number * 10)
        WHEN c.campaign_id = 9 THEN 1900 + (day_number * 120)
        WHEN c.campaign_id = 10 THEN 2800 + (day_number * 150)
        WHEN c.campaign_id = 5 THEN 420 + (day_number * 20)
        WHEN c.campaign_id = 12 THEN 0
        ELSE 600 + (c.campaign_id * 40) + (day_number * 25)
    END AS clicks,
    CASE
        WHEN c.campaign_id = 5 THEN 18000.00 + (day_number * 1000)
        WHEN c.campaign_id = 9 THEN 460000.00 + (day_number * 35000)
        WHEN c.campaign_id = 12 THEN 25000.00 + (day_number * 2000)
        ELSE 90000.00 + (c.campaign_id * 9000) + (day_number * 3500)
    END AS spend
FROM campaigns AS c
CROSS JOIN generate_series(1, 5) AS day_number;

-- Generate 80 leads.
-- Campaign 12 intentionally receives no leads.
-- Campaign 10 has high clicks but weak conversions.
INSERT INTO leads (
    campaign_id,
    first_name,
    last_name,
    email,
    city,
    lead_date,
    lead_status
)
SELECT
    CASE
        WHEN lead_number BETWEEN 1 AND 12 THEN 1
        WHEN lead_number BETWEEN 13 AND 22 THEN 2
        WHEN lead_number BETWEEN 23 AND 32 THEN 3
        WHEN lead_number BETWEEN 33 AND 38 THEN 4
        WHEN lead_number BETWEEN 39 AND 45 THEN 5
        WHEN lead_number BETWEEN 46 AND 55 THEN 6
        WHEN lead_number BETWEEN 56 AND 63 THEN 7
        WHEN lead_number BETWEEN 64 AND 71 THEN 8
        WHEN lead_number BETWEEN 72 AND 76 THEN 9
        ELSE 10
    END AS campaign_id,
    (ARRAY['Aung','May','Ko','Su','Nandar','Thiri','Kyaw','Ei','Zaw','Hnin','Myo','Yu'])[((lead_number - 1) % 12) + 1] AS first_name,
    (ARRAY['Thu','Sandi','Htet','Mon','Aye','Moe','Zin','Phyo','Min','Wai','Thant','Waddy'])[((lead_number - 1) % 12) + 1] AS last_name,
    'mkt_lead' || lead_number || '@example.com' AS email,
    (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa'])[((lead_number - 1) % 8) + 1] AS city,
    DATE '2026-01-05' + ((lead_number - 1) % 75) AS lead_date,
    CASE
        WHEN lead_number IN (1,2,3,4,5,6,13,14,15,16,17,33,34,35,39,40,41,42,43,46,47,48,49,50,56,57,58,59,60,64,65,66,67,68,72) THEN 'converted'
        WHEN lead_number IN (7,8,18,19,20,36,51) THEN 'qualified'
        WHEN lead_number IN (23,24,25,26,27,28,29,30,31,32,73,74,75,76,77,78,79,80) THEN 'contacted'
        WHEN lead_number IN (9,10,21,22,37,38,44,45,52,53,61,62,69,70) THEN 'disqualified'
        ELSE 'new'
    END AS lead_status
FROM generate_series(1, 80) AS lead_number;

-- Create 35 customers from converted leads.
INSERT INTO customers (lead_id, first_name, last_name, email, city, customer_date)
SELECT
    l.lead_id,
    l.first_name,
    l.last_name,
    'customer_' || l.email AS email,
    l.city,
    l.lead_date + 7 AS customer_date
FROM leads AS l
WHERE l.lead_id IN (
    1,2,3,4,5,
    13,14,15,16,
    33,34,
    39,40,41,42,43,
    46,47,48,49,50,
    56,57,58,59,60,
    64,65,66,67,68,
    6,17,35,72
);

-- Generate 42 conversions.
-- Customer_id is filled for leads that became customers.
INSERT INTO conversions (
    campaign_id,
    lead_id,
    customer_id,
    conversion_date,
    conversion_type,
    conversion_value
)
SELECT
    l.campaign_id,
    l.lead_id,
    c.customer_id,
    l.lead_date + 5 AS conversion_date,
    CASE
        WHEN c.customer_id IS NOT NULL AND l.lead_id % 4 = 0 THEN 'purchase'
        WHEN c.customer_id IS NOT NULL AND l.lead_id % 4 = 1 THEN 'subscription'
        WHEN c.customer_id IS NOT NULL THEN 'consultation'
        WHEN l.lead_id % 2 = 0 THEN 'demo_booked'
        ELSE 'signup'
    END AS conversion_type,
    CASE
        WHEN c.customer_id IS NOT NULL THEN 150000.00 + (l.lead_id * 5000)
        ELSE 0
    END AS conversion_value
FROM leads AS l
LEFT JOIN customers AS c
    ON l.lead_id = c.lead_id
WHERE l.lead_status IN ('converted', 'qualified')
ORDER BY l.lead_id
LIMIT 42;

-- Generate 42 sales records.
-- Revenue queries count only payment_status = 'paid'.
INSERT INTO sales (customer_id, campaign_id, sale_date, revenue_amount, payment_status)
SELECT
    c.customer_id,
    l.campaign_id,
    c.customer_date + 3 AS sale_date,
    CASE
        WHEN l.campaign_id = 5 THEN 650000.00
        WHEN l.campaign_id = 7 THEN 900000.00
        WHEN l.campaign_id = 9 THEN 120000.00
        WHEN l.campaign_id = 10 THEN 0.00
        ELSE 220000.00 + (c.customer_id * 12000)
    END AS revenue_amount,
    CASE
        WHEN c.customer_id IN (6, 18, 31) THEN 'unpaid'
        WHEN c.customer_id IN (7, 19) THEN 'refunded'
        WHEN c.customer_id IN (8, 20) THEN 'failed'
        ELSE 'paid'
    END AS payment_status
FROM customers AS c
JOIN leads AS l
    ON c.lead_id = l.lead_id
UNION ALL
SELECT
    c.customer_id,
    l.campaign_id,
    c.customer_date + 18 AS sale_date,
    CASE
        WHEN l.campaign_id IN (5, 7) THEN 450000.00
        WHEN l.campaign_id = 9 THEN 80000.00
        ELSE 150000.00
    END AS revenue_amount,
    CASE
        WHEN c.customer_id IN (2, 9) THEN 'refunded'
        WHEN c.customer_id IN (12, 28) THEN 'failed'
        WHEN c.customer_id IN (15, 34) THEN 'unpaid'
        ELSE 'paid'
    END AS payment_status
FROM customers AS c
JOIN leads AS l
    ON c.lead_id = l.lead_id
WHERE c.customer_id <= 7;

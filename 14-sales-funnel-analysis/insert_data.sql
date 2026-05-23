-- Day 14 - Sales Funnel Analysis
-- Sample data for PostgreSQL
--
-- All leads, companies, and sales records are fictional.
-- The data is designed to support funnel, conversion, drop-off, source, rep, and pipeline analysis.

INSERT INTO lead_sources (source_name, source_type) VALUES
    ('Website SEO', 'organic'),
    ('Social Media Ads', 'paid'),
    ('Customer Referral', 'referral'),
    ('Cold Outreach', 'outbound'),
    ('Business Expo', 'event'),
    ('Partner Network', 'partner');

INSERT INTO sales_reps (first_name, last_name, email, region, hire_date) VALUES
    ('Aung', 'Min', 'aung.min.sales@example.com', 'Yangon', '2023-02-01'),
    ('May', 'Thu', 'may.thu.sales@example.com', 'Mandalay', '2023-03-15'),
    ('Kyaw', 'Zin', 'kyaw.zin.sales@example.com', 'Naypyidaw', '2023-05-10'),
    ('Thiri', 'Moe', 'thiri.moe.sales@example.com', 'Lower Myanmar', '2023-07-05'),
    ('Htet', 'Aung', 'htet.aung.sales@example.com', 'Digital Sales', '2024-01-12'),
    ('Nandar', 'Aye', 'nandar.aye.sales@example.com', 'Partner Sales', '2024-04-20');

INSERT INTO funnel_stages (stage_name, stage_order) VALUES
    ('lead_created', 1),
    ('contacted', 2),
    ('qualified', 3),
    ('opportunity_created', 4),
    ('proposal_sent', 5),
    ('negotiation', 6),
    ('closed_won', 7),
    ('closed_lost', 8);

-- Generate 60 leads.
-- Source pattern:
-- referral and partner have lower volume but higher conversion.
-- paid has higher volume but lower conversion.
INSERT INTO leads (
    first_name,
    last_name,
    email,
    company_name,
    city,
    source_id,
    assigned_rep_id,
    lead_status,
    created_date
)
SELECT
    (ARRAY['Aung','May','Ko','Su','Nandar','Thiri','Kyaw','Ei','Zaw','Hnin','Myo','Yu'])[((lead_number - 1) % 12) + 1] AS first_name,
    (ARRAY['Thu','Sandi','Htet','Mon','Aye','Moe','Zin','Phyo','Min','Wai','Thant','Waddy'])[((lead_number - 1) % 12) + 1] AS last_name,
    'lead' || lead_number || '@example.com' AS email,
    (ARRAY['Golden Tech','Mandalay Retail','Naypyidaw Services','Bago Foods','Taunggyi Travel','Mawlamyine Logistics','Pathein Trading','Monywa Learning'])[((lead_number - 1) % 8) + 1]
        || ' ' || lead_number AS company_name,
    (ARRAY['Yangon','Mandalay','Naypyidaw','Bago','Taunggyi','Mawlamyine','Pathein','Monywa'])[((lead_number - 1) % 8) + 1] AS city,
    CASE
        WHEN lead_number BETWEEN 1 AND 7 THEN 3
        WHEN lead_number BETWEEN 8 AND 19 THEN 1
        WHEN lead_number BETWEEN 20 AND 39 THEN 2
        WHEN lead_number BETWEEN 40 AND 48 THEN 4
        WHEN lead_number BETWEEN 49 AND 54 THEN 5
        ELSE 6
    END AS source_id,
    CASE
        WHEN lead_number BETWEEN 1 AND 7 THEN 1
        WHEN lead_number BETWEEN 8 AND 19 THEN 2
        WHEN lead_number BETWEEN 20 AND 39 THEN 5
        WHEN lead_number BETWEEN 40 AND 48 THEN 3
        WHEN lead_number BETWEEN 49 AND 54 THEN 4
        ELSE 1
    END AS assigned_rep_id,
    CASE
        WHEN lead_number IN (1,2,3,4,5,6,8,9,10,11,12,40,41,55,56,57) THEN 'converted'
        WHEN lead_number IN (7,13,14,15,20,21,22,23,24,42,43,44,45,46,49,50,51,52,53,54,58) THEN 'qualified'
        WHEN lead_number BETWEEN 25 AND 39 THEN 'disqualified'
        WHEN lead_number IN (47,48) THEN 'contacted'
        ELSE 'new'
    END AS lead_status,
    DATE '2026-01-01' + ((lead_number - 1) * 2) AS created_date
FROM generate_series(1, 60) AS lead_number;

-- Generate lead stage history.
-- This creates a realistic funnel path while keeping the insert readable.
WITH stage_rows AS (
    SELECT lead_id, 1 AS stage_id, 1 AS max_stage FROM leads
    UNION ALL
    SELECT lead_id, 2, 2 FROM leads WHERE lead_id <= 58
    UNION ALL
    SELECT lead_id, 3, 3 FROM leads
    WHERE lead_id <= 46 OR lead_id BETWEEN 49 AND 58
    UNION ALL
    SELECT lead_id, 4, 4 FROM leads
    WHERE lead_id IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15,20,21,22,23,24,40,41,42,43,44,45,46,49,50,51,52,53,55,56,57,58)
    UNION ALL
    SELECT lead_id, 5, 5 FROM leads
    WHERE lead_id IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15,20,21,22,23,24,40,41,42,43,44,45,46,49,50,51,52,53,55,56,57,58)
    UNION ALL
    SELECT lead_id, 6, 6 FROM leads
    WHERE lead_id IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15,20,21,22,23,24,40,41,42,43,44,45,46,49,50,51,52,53,55,56,57,58)
    UNION ALL
    SELECT lead_id, 7, 7 FROM leads
    WHERE lead_id IN (1,2,3,4,5,6,8,9,10,11,12,40,41,55,56,57)
    UNION ALL
    SELECT lead_id, 8, 8 FROM leads
    WHERE lead_id IN (13,14,15,20,21,42,43,49,50)
),
max_stage AS (
    SELECT
        lead_id,
        MAX(stage_id) AS max_stage_id
    FROM stage_rows
    GROUP BY lead_id
)
INSERT INTO lead_stage_history (lead_id, stage_id, entered_at, exited_at)
SELECT
    sr.lead_id,
    sr.stage_id,
    l.created_date + ((fs.stage_order - 1) * 3) AS entered_at,
    CASE
        WHEN sr.stage_id < ms.max_stage_id THEN l.created_date + ((fs.stage_order - 1) * 3) + 2
        ELSE NULL
    END AS exited_at
FROM stage_rows AS sr
JOIN leads AS l
    ON sr.lead_id = l.lead_id
JOIN funnel_stages AS fs
    ON sr.stage_id = fs.stage_id
JOIN max_stage AS ms
    ON sr.lead_id = ms.lead_id
ORDER BY sr.lead_id, fs.stage_order;

-- Generate 35 opportunities from leads that reached opportunity_created.
WITH opportunity_data (lead_id, opportunity_status, probability, estimated_value) AS (
    VALUES
        (1, 'won', 100, 1200000.00),
        (2, 'won', 100, 850000.00),
        (3, 'won', 100, 650000.00),
        (4, 'won', 100, 1500000.00),
        (5, 'won', 100, 720000.00),
        (6, 'won', 100, 980000.00),
        (8, 'won', 100, 530000.00),
        (9, 'won', 100, 780000.00),
        (10, 'won', 100, 450000.00),
        (11, 'won', 100, 990000.00),
        (12, 'won', 100, 1100000.00),
        (13, 'lost', 0, 700000.00),
        (14, 'lost', 0, 880000.00),
        (15, 'lost', 0, 430000.00),
        (20, 'lost', 0, 300000.00),
        (21, 'lost', 0, 350000.00),
        (22, 'open', 45, 420000.00),
        (23, 'open', 30, 260000.00),
        (24, 'open', 20, 190000.00),
        (40, 'won', 100, 640000.00),
        (41, 'won', 100, 720000.00),
        (42, 'lost', 0, 510000.00),
        (43, 'lost', 0, 480000.00),
        (44, 'open', 60, 900000.00),
        (45, 'open', 40, 610000.00),
        (46, 'open', 50, 550000.00),
        (49, 'lost', 0, 780000.00),
        (50, 'lost', 0, 250000.00),
        (51, 'open', 55, 820000.00),
        (52, 'open', 35, 470000.00),
        (53, 'open', 25, 330000.00),
        (55, 'won', 100, 2000000.00),
        (56, 'won', 100, 1350000.00),
        (57, 'won', 100, 1750000.00),
        (58, 'open', 70, 1600000.00)
)
INSERT INTO opportunities (
    lead_id,
    rep_id,
    opportunity_name,
    estimated_value,
    probability,
    opportunity_status,
    created_date,
    expected_close_date
)
SELECT
    od.lead_id,
    l.assigned_rep_id,
    l.company_name || ' Opportunity' AS opportunity_name,
    od.estimated_value,
    od.probability,
    od.opportunity_status,
    l.created_date + 10 AS created_date,
    l.created_date + 45 AS expected_close_date
FROM opportunity_data AS od
JOIN leads AS l
    ON od.lead_id = l.lead_id
ORDER BY od.lead_id;

-- Generate 25 closed deals from won and lost opportunities.
-- Lost deals keep estimated deal_value so learners can analyze lost revenue potential.
INSERT INTO deals (opportunity_id, deal_value, deal_status, closed_date, loss_reason)
SELECT
    o.opportunity_id,
    o.estimated_value AS deal_value,
    o.opportunity_status AS deal_status,
    o.expected_close_date - 5 AS closed_date,
    CASE
        WHEN o.opportunity_status = 'won' THEN NULL
        WHEN o.opportunity_id % 6 = 0 THEN 'price'
        WHEN o.opportunity_id % 6 = 1 THEN 'no_budget'
        WHEN o.opportunity_id % 6 = 2 THEN 'competitor'
        WHEN o.opportunity_id % 6 = 3 THEN 'no_response'
        WHEN o.opportunity_id % 6 = 4 THEN 'not_ready'
        ELSE 'poor_fit'
    END AS loss_reason
FROM opportunities AS o
WHERE o.opportunity_status IN ('won', 'lost')
ORDER BY o.opportunity_id;

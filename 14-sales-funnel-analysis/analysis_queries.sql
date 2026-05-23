-- Day 14 - Sales Funnel Analysis
-- Analysis queries for PostgreSQL
--
-- Key formulas used in this file:
-- Conversion rate = later stage count / earlier stage count.
-- Overall lead-to-customer conversion = won deals / total leads.
-- Win rate = won deals / total closed deals.
-- Open pipeline value = estimated_value for open opportunities.
-- Weighted pipeline value = estimated_value * probability / 100.

-- 1. List all leads with source and assigned sales rep.
SELECT
    l.lead_id,
    l.first_name || ' ' || l.last_name AS lead_name,
    l.company_name,
    l.city,
    ls.source_name,
    ls.source_type,
    sr.first_name || ' ' || sr.last_name AS assigned_rep_name,
    l.lead_status,
    l.created_date
FROM leads AS l
JOIN lead_sources AS ls
    ON l.source_id = ls.source_id
JOIN sales_reps AS sr
    ON l.assigned_rep_id = sr.rep_id
ORDER BY l.created_date, l.lead_id;

-- 2. List all funnel stages in order.
SELECT
    stage_id,
    stage_order,
    stage_name
FROM funnel_stages
ORDER BY stage_order;

-- 3. Show lead stage history with lead and stage names.
SELECT
    lsh.history_id,
    l.lead_id,
    l.first_name || ' ' || l.last_name AS lead_name,
    fs.stage_order,
    fs.stage_name,
    lsh.entered_at,
    lsh.exited_at
FROM lead_stage_history AS lsh
JOIN leads AS l
    ON lsh.lead_id = l.lead_id
JOIN funnel_stages AS fs
    ON lsh.stage_id = fs.stage_id
ORDER BY l.lead_id, fs.stage_order;

-- 4. Count leads by lead status.
SELECT
    lead_status,
    COUNT(*) AS total_leads
FROM leads
GROUP BY lead_status
ORDER BY total_leads DESC;

-- 5. Count leads by source.
SELECT
    ls.source_name,
    ls.source_type,
    COUNT(l.lead_id) AS total_leads
FROM lead_sources AS ls
LEFT JOIN leads AS l
    ON ls.source_id = l.source_id
GROUP BY ls.source_id, ls.source_name, ls.source_type
ORDER BY total_leads DESC, ls.source_name;

-- 6. Count leads by city.
SELECT
    city,
    COUNT(*) AS total_leads
FROM leads
GROUP BY city
ORDER BY total_leads DESC, city;

-- 7. Count leads assigned to each sales rep.
SELECT
    sr.rep_id,
    sr.first_name || ' ' || sr.last_name AS sales_rep_name,
    COUNT(l.lead_id) AS assigned_leads
FROM sales_reps AS sr
LEFT JOIN leads AS l
    ON sr.rep_id = l.assigned_rep_id
GROUP BY sr.rep_id, sr.first_name, sr.last_name
ORDER BY assigned_leads DESC, sales_rep_name;

-- 8. Count leads at each latest funnel stage.
-- The latest stage is the most recent stage entered by each lead.
WITH latest_stage AS (
    SELECT
        lsh.lead_id,
        lsh.stage_id,
        ROW_NUMBER() OVER (
            PARTITION BY lsh.lead_id
            ORDER BY fs.stage_order DESC
        ) AS stage_rank
    FROM lead_stage_history AS lsh
    JOIN funnel_stages AS fs
        ON lsh.stage_id = fs.stage_id
)
SELECT
    fs.stage_order,
    fs.stage_name,
    COUNT(ls.lead_id) AS leads_currently_at_stage
FROM funnel_stages AS fs
LEFT JOIN latest_stage AS ls
    ON fs.stage_id = ls.stage_id
   AND ls.stage_rank = 1
GROUP BY fs.stage_id, fs.stage_order, fs.stage_name
ORDER BY fs.stage_order;

-- 9. Calculate conversion from lead_created to qualified.
-- Conversion rate = qualified stage count / lead_created stage count.
WITH stage_counts AS (
    SELECT
        fs.stage_name,
        COUNT(DISTINCT lsh.lead_id) AS lead_count
    FROM funnel_stages AS fs
    LEFT JOIN lead_stage_history AS lsh
        ON fs.stage_id = lsh.stage_id
    WHERE fs.stage_name IN ('lead_created', 'qualified')
    GROUP BY fs.stage_name
)
SELECT
    MAX(lead_count) FILTER (WHERE stage_name = 'lead_created') AS lead_created_count,
    MAX(lead_count) FILTER (WHERE stage_name = 'qualified') AS qualified_count,
    ROUND(
        MAX(lead_count) FILTER (WHERE stage_name = 'qualified') * 100.0
        / NULLIF(MAX(lead_count) FILTER (WHERE stage_name = 'lead_created'), 0),
        2
    ) AS conversion_rate_percent
FROM stage_counts;

-- 10. Calculate conversion from qualified to opportunity_created.
WITH stage_counts AS (
    SELECT
        fs.stage_name,
        COUNT(DISTINCT lsh.lead_id) AS lead_count
    FROM funnel_stages AS fs
    LEFT JOIN lead_stage_history AS lsh
        ON fs.stage_id = lsh.stage_id
    WHERE fs.stage_name IN ('qualified', 'opportunity_created')
    GROUP BY fs.stage_name
)
SELECT
    MAX(lead_count) FILTER (WHERE stage_name = 'qualified') AS qualified_count,
    MAX(lead_count) FILTER (WHERE stage_name = 'opportunity_created') AS opportunity_count,
    ROUND(
        MAX(lead_count) FILTER (WHERE stage_name = 'opportunity_created') * 100.0
        / NULLIF(MAX(lead_count) FILTER (WHERE stage_name = 'qualified'), 0),
        2
    ) AS conversion_rate_percent
FROM stage_counts;

-- 11. Calculate conversion from opportunity_created to closed_won.
WITH stage_counts AS (
    SELECT
        fs.stage_name,
        COUNT(DISTINCT lsh.lead_id) AS lead_count
    FROM funnel_stages AS fs
    LEFT JOIN lead_stage_history AS lsh
        ON fs.stage_id = lsh.stage_id
    WHERE fs.stage_name IN ('opportunity_created', 'closed_won')
    GROUP BY fs.stage_name
)
SELECT
    MAX(lead_count) FILTER (WHERE stage_name = 'opportunity_created') AS opportunity_count,
    MAX(lead_count) FILTER (WHERE stage_name = 'closed_won') AS closed_won_count,
    ROUND(
        MAX(lead_count) FILTER (WHERE stage_name = 'closed_won') * 100.0
        / NULLIF(MAX(lead_count) FILTER (WHERE stage_name = 'opportunity_created'), 0),
        2
    ) AS conversion_rate_percent
FROM stage_counts;

-- 12. Calculate overall lead-to-customer conversion rate.
-- Overall conversion = won deals / total leads.
SELECT
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT d.deal_id) FILTER (WHERE d.deal_status = 'won') AS won_deals,
    ROUND(
        COUNT(DISTINCT d.deal_id) FILTER (WHERE d.deal_status = 'won') * 100.0
        / NULLIF(COUNT(DISTINCT l.lead_id), 0),
        2
    ) AS lead_to_customer_conversion_percent
FROM leads AS l
LEFT JOIN opportunities AS o
    ON l.lead_id = o.lead_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id;

-- 13. Find funnel drop-off count by stage.
-- Drop-off count = leads at this stage - leads at the next stage.
WITH stage_counts AS (
    SELECT
        fs.stage_order,
        fs.stage_name,
        COUNT(DISTINCT lsh.lead_id) AS lead_count
    FROM funnel_stages AS fs
    LEFT JOIN lead_stage_history AS lsh
        ON fs.stage_id = lsh.stage_id
    GROUP BY fs.stage_id, fs.stage_order, fs.stage_name
),
stage_dropoff AS (
    SELECT
        stage_order,
        stage_name,
        lead_count,
        LEAD(lead_count) OVER (ORDER BY stage_order) AS next_stage_count
    FROM stage_counts
)
SELECT
    stage_order,
    stage_name,
    lead_count,
    COALESCE(next_stage_count, 0) AS next_stage_count,
    lead_count - COALESCE(next_stage_count, 0) AS dropoff_count
FROM stage_dropoff
WHERE stage_order < 7
ORDER BY stage_order;

-- 14. Find funnel drop-off rate by stage.
-- Drop-off rate = drop-off count / leads at that stage.
WITH stage_counts AS (
    SELECT
        fs.stage_order,
        fs.stage_name,
        COUNT(DISTINCT lsh.lead_id) AS lead_count
    FROM funnel_stages AS fs
    LEFT JOIN lead_stage_history AS lsh
        ON fs.stage_id = lsh.stage_id
    GROUP BY fs.stage_id, fs.stage_order, fs.stage_name
),
stage_dropoff AS (
    SELECT
        stage_order,
        stage_name,
        lead_count,
        LEAD(lead_count) OVER (ORDER BY stage_order) AS next_stage_count
    FROM stage_counts
)
SELECT
    stage_order,
    stage_name,
    lead_count,
    lead_count - COALESCE(next_stage_count, 0) AS dropoff_count,
    ROUND(
        (lead_count - COALESCE(next_stage_count, 0)) * 100.0
        / NULLIF(lead_count, 0),
        2
    ) AS dropoff_rate_percent
FROM stage_dropoff
WHERE stage_order < 7
ORDER BY stage_order;

-- 15. Calculate average time spent in each stage.
-- Stage duration = exited_at - entered_at. Open/current stages with NULL exited_at are excluded.
SELECT
    fs.stage_order,
    fs.stage_name,
    ROUND(AVG(lsh.exited_at - lsh.entered_at), 2) AS average_days_in_stage
FROM lead_stage_history AS lsh
JOIN funnel_stages AS fs
    ON lsh.stage_id = fs.stage_id
WHERE lsh.exited_at IS NOT NULL
GROUP BY fs.stage_id, fs.stage_order, fs.stage_name
ORDER BY fs.stage_order;

-- 16. Find lead sources with highest conversion rate.
-- Source conversion = won deals from the source / total leads from the source.
SELECT
    ls.source_name,
    ls.source_type,
    COUNT(DISTINCT l.lead_id) AS total_leads,
    COUNT(DISTINCT d.deal_id) FILTER (WHERE d.deal_status = 'won') AS won_deals,
    ROUND(
        COUNT(DISTINCT d.deal_id) FILTER (WHERE d.deal_status = 'won') * 100.0
        / NULLIF(COUNT(DISTINCT l.lead_id), 0),
        2
    ) AS source_conversion_rate_percent
FROM lead_sources AS ls
LEFT JOIN leads AS l
    ON ls.source_id = l.source_id
LEFT JOIN opportunities AS o
    ON l.lead_id = o.lead_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
GROUP BY ls.source_id, ls.source_name, ls.source_type
ORDER BY source_conversion_rate_percent DESC NULLS LAST, won_deals DESC;

-- 17. Find lead sources with highest won revenue.
SELECT
    ls.source_name,
    SUM(d.deal_value) FILTER (WHERE d.deal_status = 'won') AS won_revenue
FROM lead_sources AS ls
LEFT JOIN leads AS l
    ON ls.source_id = l.source_id
LEFT JOIN opportunities AS o
    ON l.lead_id = o.lead_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
GROUP BY ls.source_id, ls.source_name
ORDER BY won_revenue DESC NULLS LAST;

-- 18. Find sales reps with highest win count.
WITH rep_wins AS (
    SELECT
        sr.rep_id,
        sr.first_name || ' ' || sr.last_name AS sales_rep_name,
        COUNT(d.deal_id) FILTER (WHERE d.deal_status = 'won') AS won_deals
    FROM sales_reps AS sr
    LEFT JOIN opportunities AS o
        ON sr.rep_id = o.rep_id
    LEFT JOIN deals AS d
        ON o.opportunity_id = d.opportunity_id
    GROUP BY sr.rep_id, sr.first_name, sr.last_name
)
SELECT
    rep_id,
    sales_rep_name,
    won_deals,
    RANK() OVER (
        ORDER BY won_deals DESC
    ) AS win_rank
FROM rep_wins
ORDER BY win_rank, sales_rep_name;

-- 19. Find sales reps with highest won revenue.
SELECT
    sr.rep_id,
    sr.first_name || ' ' || sr.last_name AS sales_rep_name,
    SUM(d.deal_value) FILTER (WHERE d.deal_status = 'won') AS won_revenue
FROM sales_reps AS sr
LEFT JOIN opportunities AS o
    ON sr.rep_id = o.rep_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
GROUP BY sr.rep_id, sr.first_name, sr.last_name
ORDER BY won_revenue DESC NULLS LAST;

-- 20. Find sales reps with highest average deal value.
SELECT
    sr.rep_id,
    sr.first_name || ' ' || sr.last_name AS sales_rep_name,
    ROUND(AVG(d.deal_value) FILTER (WHERE d.deal_status = 'won'), 2) AS average_won_deal_value
FROM sales_reps AS sr
LEFT JOIN opportunities AS o
    ON sr.rep_id = o.rep_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
GROUP BY sr.rep_id, sr.first_name, sr.last_name
ORDER BY average_won_deal_value DESC NULLS LAST;

-- 21. Calculate win rate by sales rep.
-- Win rate = won deals / total closed deals.
SELECT
    sr.rep_id,
    sr.first_name || ' ' || sr.last_name AS sales_rep_name,
    COUNT(d.deal_id) AS closed_deals,
    COUNT(d.deal_id) FILTER (WHERE d.deal_status = 'won') AS won_deals,
    ROUND(
        COUNT(d.deal_id) FILTER (WHERE d.deal_status = 'won') * 100.0
        / NULLIF(COUNT(d.deal_id), 0),
        2
    ) AS win_rate_percent
FROM sales_reps AS sr
LEFT JOIN opportunities AS o
    ON sr.rep_id = o.rep_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
GROUP BY sr.rep_id, sr.first_name, sr.last_name
ORDER BY win_rate_percent DESC NULLS LAST, won_deals DESC;

-- 22. Calculate win rate by lead source.
SELECT
    ls.source_name,
    COUNT(d.deal_id) AS closed_deals,
    COUNT(d.deal_id) FILTER (WHERE d.deal_status = 'won') AS won_deals,
    ROUND(
        COUNT(d.deal_id) FILTER (WHERE d.deal_status = 'won') * 100.0
        / NULLIF(COUNT(d.deal_id), 0),
        2
    ) AS win_rate_percent
FROM lead_sources AS ls
LEFT JOIN leads AS l
    ON ls.source_id = l.source_id
LEFT JOIN opportunities AS o
    ON l.lead_id = o.lead_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
GROUP BY ls.source_id, ls.source_name
ORDER BY win_rate_percent DESC NULLS LAST, won_deals DESC;

-- 23. Find top 10 highest value opportunities.
SELECT
    RANK() OVER (ORDER BY estimated_value DESC) AS value_rank,
    opportunity_id,
    opportunity_name,
    estimated_value,
    probability,
    opportunity_status,
    expected_close_date
FROM opportunities
ORDER BY value_rank, opportunity_id
LIMIT 10;

-- 24. Calculate open pipeline value.
SELECT
    SUM(estimated_value) AS open_pipeline_value
FROM opportunities
WHERE opportunity_status = 'open';

-- 25. Calculate weighted pipeline value.
-- Weighted pipeline = estimated_value * probability / 100 for open opportunities.
SELECT
    SUM(estimated_value * probability / 100.0) AS weighted_pipeline_value
FROM opportunities
WHERE opportunity_status = 'open';

-- 26. Calculate monthly lead generation trend.
SELECT
    DATE_TRUNC('month', created_date)::date AS lead_month,
    COUNT(*) AS new_leads
FROM leads
GROUP BY DATE_TRUNC('month', created_date)::date
ORDER BY lead_month;

-- 27. Calculate monthly won revenue trend.
SELECT
    DATE_TRUNC('month', d.closed_date)::date AS won_month,
    SUM(d.deal_value) AS won_revenue,
    COUNT(d.deal_id) AS won_deals
FROM deals AS d
WHERE d.deal_status = 'won'
GROUP BY DATE_TRUNC('month', d.closed_date)::date
ORDER BY won_month;

-- 28. Find most common loss reasons.
SELECT
    loss_reason,
    COUNT(*) AS lost_deal_count,
    SUM(deal_value) AS lost_pipeline_value
FROM deals
WHERE deal_status = 'lost'
GROUP BY loss_reason
ORDER BY lost_deal_count DESC, lost_pipeline_value DESC;

-- 29. Find high-value lost deals.
-- High-value lost deals are lost deals worth at least 500,000.
SELECT
    d.deal_id,
    o.opportunity_name,
    d.deal_value,
    d.loss_reason,
    d.closed_date
FROM deals AS d
JOIN opportunities AS o
    ON d.opportunity_id = o.opportunity_id
WHERE d.deal_status = 'lost'
  AND d.deal_value >= 500000
ORDER BY d.deal_value DESC;

-- 30. Find leads that never moved past contacted stage.
WITH latest_stage AS (
    SELECT
        lsh.lead_id,
        fs.stage_name,
        ROW_NUMBER() OVER (
            PARTITION BY lsh.lead_id
            ORDER BY fs.stage_order DESC
        ) AS stage_rank
    FROM lead_stage_history AS lsh
    JOIN funnel_stages AS fs
        ON lsh.stage_id = fs.stage_id
)
SELECT
    l.lead_id,
    l.first_name || ' ' || l.last_name AS lead_name,
    l.company_name,
    l.lead_status
FROM latest_stage AS ls
JOIN leads AS l
    ON ls.lead_id = l.lead_id
WHERE ls.stage_rank = 1
  AND ls.stage_name = 'contacted'
ORDER BY l.lead_id;

-- 31. Create a sales funnel KPI summary using CTE.
WITH lead_summary AS (
    SELECT
        COUNT(*) AS total_leads
    FROM leads
),
qualified_summary AS (
    SELECT
        COUNT(DISTINCT lsh.lead_id) AS qualified_leads
    FROM lead_stage_history AS lsh
    JOIN funnel_stages AS fs
        ON lsh.stage_id = fs.stage_id
    WHERE fs.stage_name = 'qualified'
),
opportunity_summary AS (
    SELECT
        COUNT(*) AS total_opportunities,
        COALESCE(SUM(estimated_value) FILTER (WHERE opportunity_status = 'open'), 0) AS open_pipeline_value,
        COALESCE(SUM(estimated_value * probability / 100.0) FILTER (WHERE opportunity_status = 'open'), 0) AS weighted_pipeline_value
    FROM opportunities
),
deal_summary AS (
    SELECT
        COUNT(*) FILTER (WHERE deal_status = 'won') AS won_deals,
        COUNT(*) FILTER (WHERE deal_status = 'lost') AS lost_deals,
        COALESCE(SUM(deal_value) FILTER (WHERE deal_status = 'won'), 0) AS won_revenue
    FROM deals
)
SELECT
    ls.total_leads,
    qs.qualified_leads,
    os.total_opportunities,
    ds.won_deals,
    ds.lost_deals,
    ROUND(qs.qualified_leads * 100.0 / NULLIF(ls.total_leads, 0), 2) AS lead_to_qualified_rate_percent,
    ROUND(ds.won_deals * 100.0 / NULLIF(ls.total_leads, 0), 2) AS lead_to_customer_rate_percent,
    ROUND(ds.won_deals * 100.0 / NULLIF(ds.won_deals + ds.lost_deals, 0), 2) AS win_rate_percent,
    ds.won_revenue,
    os.open_pipeline_value,
    os.weighted_pipeline_value,
    CASE
        WHEN ds.won_deals * 100.0 / NULLIF(ds.won_deals + ds.lost_deals, 0) >= 60 THEN 'strong_close_rate'
        WHEN os.weighted_pipeline_value >= os.open_pipeline_value * 0.4 THEN 'healthy_pipeline'
        ELSE 'needs_funnel_review'
    END AS funnel_health_status
FROM lead_summary AS ls
CROSS JOIN qualified_summary AS qs
CROSS JOIN opportunity_summary AS os
CROSS JOIN deal_summary AS ds;

-- 32. Build a basic Lead 360 view using SQL.
WITH latest_stage AS (
    SELECT
        lsh.lead_id,
        fs.stage_name,
        ROW_NUMBER() OVER (
            PARTITION BY lsh.lead_id
            ORDER BY fs.stage_order DESC
        ) AS stage_rank
    FROM lead_stage_history AS lsh
    JOIN funnel_stages AS fs
        ON lsh.stage_id = fs.stage_id
)
SELECT
    l.lead_id,
    l.first_name || ' ' || l.last_name AS lead_name,
    l.company_name,
    l.city,
    ls.source_name,
    sr.first_name || ' ' || sr.last_name AS assigned_rep_name,
    l.lead_status,
    lst.stage_name AS latest_stage,
    o.opportunity_status,
    o.estimated_value,
    d.deal_status,
    d.deal_value,
    l.created_date,
    o.expected_close_date
FROM leads AS l
JOIN lead_sources AS ls
    ON l.source_id = ls.source_id
JOIN sales_reps AS sr
    ON l.assigned_rep_id = sr.rep_id
LEFT JOIN latest_stage AS lst
    ON l.lead_id = lst.lead_id
   AND lst.stage_rank = 1
LEFT JOIN opportunities AS o
    ON l.lead_id = o.lead_id
LEFT JOIN deals AS d
    ON o.opportunity_id = d.opportunity_id
ORDER BY l.lead_id;

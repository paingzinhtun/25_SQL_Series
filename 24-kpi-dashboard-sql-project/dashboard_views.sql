-- Day 24: KPI Dashboard Engineering Using SQL
-- dashboard_views.sql

-- 1. Executive KPI Dashboard View
CREATE OR REPLACE VIEW executive_kpi_dashboard AS
WITH current_month AS (
    SELECT 
        SUM(i.total_sales_amount) as total_revenue,
        SUM(i.profit_amount) as total_profit,
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.customer_id) as active_customers
    FROM sales_orders o
    JOIN sales_order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'completed'
),
customer_metrics AS (
    SELECT 
        COUNT(*) as total_customers,
        SUM(CASE WHEN customer_status = 'churned' THEN 1 ELSE 0 END) as churned_customers
    FROM customers
)
SELECT 
    cm.total_revenue,
    cm.total_profit,
    cm.total_orders,
    cm.total_revenue / NULLIF(cm.total_orders, 0) as avg_order_value,
    cust.total_customers,
    cm.active_customers,
    cust.churned_customers,
    (cm.active_customers::DECIMAL / NULLIF(cust.total_customers, 0)) as customer_retention_rate,
    (cust.churned_customers::DECIMAL / NULLIF(cust.total_customers, 0)) as customer_churn_rate
FROM current_month cm CROSS JOIN customer_metrics cust;

-- 2. Sales Performance Dashboard View
CREATE OR REPLACE VIEW sales_performance_dashboard AS
SELECT 
    o.sales_channel,
    o.store_id,
    s.store_name,
    s.region,
    p.category,
    TO_CHAR(o.order_date, 'YYYY-MM') as sales_month,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(i.total_sales_amount) as total_revenue,
    SUM(i.profit_amount) as total_profit,
    SUM(i.total_sales_amount) / NULLIF(COUNT(DISTINCT o.order_id), 0) as avg_order_value
FROM sales_orders o
JOIN sales_order_items i ON o.order_id = i.order_id
LEFT JOIN stores s ON o.store_id = s.store_id
JOIN products p ON i.product_id = p.product_id
WHERE o.order_status = 'completed'
GROUP BY 1, 2, 3, 4, 5, 6;

-- 3. Customer Analytics Dashboard View
CREATE OR REPLACE VIEW customer_analytics_dashboard AS
SELECT 
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) as total_customers,
    SUM(o.total_order_amount) as total_revenue,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_order_amount) / NULLIF(COUNT(DISTINCT c.customer_id), 0) as customer_lifetime_value,
    SUM(CASE WHEN o.order_status = 'completed' THEN 1 ELSE 0 END) as completed_orders
FROM customers c
LEFT JOIN sales_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_segment;

-- 4. Product Performance Dashboard View
CREATE OR REPLACE VIEW product_performance_dashboard AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    SUM(i.quantity) as total_quantity_sold,
    SUM(i.total_sales_amount) as product_revenue,
    SUM(i.profit_amount) as product_profit,
    SUM(i.profit_amount) / NULLIF(SUM(i.total_sales_amount), 0) as profit_margin
FROM products p
JOIN sales_order_items i ON p.product_id = i.product_id
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1, 2, 3, 4;

-- 5. Regional Performance Dashboard View
CREATE OR REPLACE VIEW regional_performance_dashboard AS
SELECT 
    COALESCE(s.region, c.region) as region,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(i.total_sales_amount) as revenue_by_region,
    SUM(i.profit_amount) as profit_by_region
FROM sales_orders o
JOIN sales_order_items i ON o.order_id = i.order_id
LEFT JOIN stores s ON o.store_id = s.store_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- 6. Marketing Campaign Dashboard View
CREATE OR REPLACE VIEW marketing_campaign_dashboard AS
SELECT 
    mc.campaign_id,
    mc.campaign_name,
    mc.campaign_type,
    mc.campaign_cost,
    SUM(o.total_order_amount) as campaign_revenue_impact,
    (SUM(o.total_order_amount) - mc.campaign_cost) / NULLIF(mc.campaign_cost, 0) as ROI
FROM marketing_campaigns mc
LEFT JOIN sales_orders o ON o.order_date BETWEEN mc.start_date AND mc.end_date
AND o.order_status = 'completed'
GROUP BY 1, 2, 3, 4;

-- 7. Retention/Churn Dashboard View
CREATE OR REPLACE VIEW retention_churn_dashboard AS
SELECT 
    customer_status,
    COUNT(customer_id) as customer_count,
    COUNT(customer_id)::DECIMAL / SUM(COUNT(customer_id)) OVER() as percentage_of_total
FROM customers
GROUP BY customer_status;

-- 8. Monthly Trend Dashboard View
CREATE OR REPLACE VIEW monthly_trend_dashboard AS
WITH actuals AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) as sales_year,
        EXTRACT(MONTH FROM o.order_date) as sales_month,
        SUM(i.total_sales_amount) as monthly_revenue,
        SUM(i.profit_amount) as monthly_profit
    FROM sales_orders o
    JOIN sales_order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'completed'
    GROUP BY 1, 2
)
SELECT 
    a.sales_year,
    a.sales_month,
    a.monthly_revenue,
    a.monthly_profit,
    t.revenue_target,
    t.profit_target,
    a.monthly_revenue / NULLIF(t.revenue_target, 0) as target_achievement_rate,
    CASE WHEN a.monthly_revenue >= t.revenue_target THEN 'Achieved' ELSE 'Missed' END as trend_status
FROM actuals a
LEFT JOIN monthly_targets t ON a.sales_year = t.target_year AND a.sales_month = t.target_month;
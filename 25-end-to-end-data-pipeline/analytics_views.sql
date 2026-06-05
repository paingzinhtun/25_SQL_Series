-- Day 25: End-to-End Data Pipeline
-- analytics_views.sql: Analytics Layer for BI Tools

-- 1. Executive KPIs
CREATE OR REPLACE VIEW executive_kpis AS
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units_sold,
    SUM(gross_sales_amount) AS total_gross_revenue,
    SUM(discount_amount) AS total_discounts_given,
    SUM(net_sales_amount) AS total_net_revenue
FROM fact_sales;

-- 2. Sales Trends
CREATE OR REPLACE VIEW sales_trends AS
SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.net_sales_amount) AS monthly_revenue,
    COUNT(DISTINCT f.order_id) AS monthly_orders
FROM fact_sales f
JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1, 2, 3
ORDER BY 1, 2;

-- 3. Customer Performance
CREATE OR REPLACE VIEW customer_performance AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.region,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.net_sales_amount) AS lifetime_value,
    SUM(f.net_sales_amount) / NULLIF(COUNT(DISTINCT f.order_id), 0) AS average_order_value
FROM fact_sales f
JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY 1, 2, 3;

-- 4. Product Performance
CREATE OR REPLACE VIEW product_performance AS
SELECT 
    p.category,
    p.product_name,
    SUM(f.quantity) AS total_quantity_sold,
    SUM(f.net_sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1, 2;

-- 5. Regional Performance
CREATE OR REPLACE VIEW regional_performance AS
SELECT 
    COALESCE(s.city, c.city) AS primary_city,
    COALESCE(c.region, 'Unknown') AS region,
    SUM(f.net_sales_amount) AS regional_revenue
FROM fact_sales f
LEFT JOIN dim_store s ON f.store_sk = s.store_sk
JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY 1, 2;
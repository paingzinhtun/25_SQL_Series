-- Day 24: KPI Dashboard Engineering Using SQL
-- analysis_queries.sql

-- =========================================================
-- EXECUTIVE KPIs
-- =========================================================

-- 1. Calculate total revenue.
-- KPI: The lifeblood of the business, total revenue indicates top-line performance.
SELECT SUM(total_order_amount) AS total_revenue 
FROM sales_orders 
WHERE order_status = 'completed';

-- 2. Calculate total profit.
-- KPI: Bottom-line performance, indicates if the revenue is actually making money.
SELECT SUM(profit_amount) AS total_profit 
FROM sales_order_items i
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed';

-- 3. Calculate average order value.
-- KPI: Indicates customer purchasing power per transaction.
SELECT SUM(total_order_amount) / COUNT(DISTINCT order_id) AS avg_order_value
FROM sales_orders 
WHERE order_status = 'completed';

-- =========================================================
-- TREND ANALYSIS & TARGETS
-- =========================================================

-- 4. Calculate monthly revenue trend.
-- KPI: Monitors how sales grow or shrink over time.
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS month,
    SUM(total_order_amount) AS monthly_revenue
FROM sales_orders
WHERE order_status = 'completed'
GROUP BY 1 ORDER BY 1;

-- 5. Calculate monthly profit trend.
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    SUM(i.profit_amount) AS monthly_profit
FROM sales_orders o
JOIN sales_order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'completed'
GROUP BY 1 ORDER BY 1;

-- 6. Calculate revenue growth rate.
-- KPI: Month-over-month growth rate to track scaling.
WITH MonthlyRevenue AS (
    SELECT 
        TO_CHAR(o.order_date, 'YYYY-MM') AS month,
        SUM(i.total_sales_amount) AS revenue
    FROM sales_orders o
    JOIN sales_order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'completed'
    GROUP BY 1
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER(ORDER BY month) AS prev_month_revenue,
    (revenue - LAG(revenue) OVER(ORDER BY month)) / NULLIF(LAG(revenue) OVER(ORDER BY month), 0) AS revenue_growth_rate
FROM MonthlyRevenue;

-- 7. Calculate profit growth rate.
WITH MonthlyProfit AS (
    SELECT 
        TO_CHAR(o.order_date, 'YYYY-MM') AS month,
        SUM(i.profit_amount) AS profit
    FROM sales_orders o
    JOIN sales_order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'completed'
    GROUP BY 1
)
SELECT 
    month,
    profit,
    (profit - LAG(profit) OVER(ORDER BY month)) / NULLIF(LAG(profit) OVER(ORDER BY month), 0) AS profit_growth_rate
FROM MonthlyProfit;

-- 8. Compare target vs actual revenue.
-- KPI: Are we hitting our goals?
SELECT 
    t.target_year,
    t.target_month,
    t.revenue_target,
    COALESCE(SUM(o.total_order_amount), 0) AS actual_revenue,
    COALESCE(SUM(o.total_order_amount), 0) / NULLIF(t.revenue_target, 0) AS target_achievement
FROM monthly_targets t
LEFT JOIN sales_orders o ON EXTRACT(YEAR FROM o.order_date) = t.target_year 
    AND EXTRACT(MONTH FROM o.order_date) = t.target_month
    AND o.order_status = 'completed'
GROUP BY 1, 2, 3 ORDER BY 1, 2;

-- 9. Compare target vs actual profit.
SELECT 
    t.target_year,
    t.target_month,
    t.profit_target,
    COALESCE(SUM(i.profit_amount), 0) AS actual_profit,
    COALESCE(SUM(i.profit_amount), 0) / NULLIF(t.profit_target, 0) AS profit_target_achievement
FROM monthly_targets t
LEFT JOIN sales_orders o ON EXTRACT(YEAR FROM o.order_date) = t.target_year 
    AND EXTRACT(MONTH FROM o.order_date) = t.target_month AND o.order_status = 'completed'
LEFT JOIN sales_order_items i ON o.order_id = i.order_id
GROUP BY 1, 2, 3 ORDER BY 1, 2;

-- 10. Find months missing targets.
WITH Targets AS (
    SELECT 
        t.target_year, t.target_month, t.revenue_target,
        COALESCE(SUM(o.total_order_amount), 0) AS actual_revenue
    FROM monthly_targets t
    LEFT JOIN sales_orders o ON EXTRACT(YEAR FROM o.order_date) = t.target_year 
        AND EXTRACT(MONTH FROM o.order_date) = t.target_month AND o.order_status = 'completed'
    GROUP BY 1, 2, 3
)
SELECT * FROM Targets WHERE actual_revenue < revenue_target;

-- =========================================================
-- REGIONAL & STORE PERFORMANCE
-- =========================================================

-- 11. Calculate revenue by region.
SELECT COALESCE(s.region, c.region) AS region, SUM(o.total_order_amount) AS total_revenue
FROM sales_orders o
LEFT JOIN stores s ON o.store_id = s.store_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- 12. Calculate profit by region.
SELECT COALESCE(s.region, c.region) AS region, SUM(i.profit_amount) AS total_profit
FROM sales_orders o
JOIN sales_order_items i ON o.order_id = i.order_id
LEFT JOIN stores s ON o.store_id = s.store_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- 13. Rank regions by revenue.
WITH RegionRev AS (
    SELECT COALESCE(s.region, c.region) AS region, SUM(o.total_order_amount) AS revenue
    FROM sales_orders o
    LEFT JOIN stores s ON o.store_id = s.store_id
    LEFT JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'completed'
    GROUP BY 1
)
SELECT region, revenue, RANK() OVER(ORDER BY revenue DESC) as revenue_rank FROM RegionRev;

-- 14. Calculate revenue by store.
SELECT s.store_name, SUM(o.total_order_amount) AS store_revenue
FROM sales_orders o
JOIN stores s ON o.store_id = s.store_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- 15. Rank stores by revenue.
SELECT s.store_name, SUM(o.total_order_amount) AS store_revenue,
       DENSE_RANK() OVER(ORDER BY SUM(o.total_order_amount) DESC) as store_rank
FROM sales_orders o
JOIN stores s ON o.store_id = s.store_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- =========================================================
-- PRODUCT PERFORMANCE
-- =========================================================

-- 16. Calculate revenue by product category.
SELECT p.category, SUM(i.total_sales_amount) AS category_revenue
FROM sales_order_items i
JOIN products p ON i.product_id = p.product_id
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- 17. Rank product categories by revenue.
SELECT p.category, SUM(i.total_sales_amount) AS category_revenue,
       RANK() OVER(ORDER BY SUM(i.total_sales_amount) DESC) as category_rank
FROM sales_order_items i
JOIN products p ON i.product_id = p.product_id
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- 18. Find top-selling products.
SELECT p.product_name, SUM(i.quantity) as qty_sold, SUM(i.total_sales_amount) as revenue
FROM sales_order_items i
JOIN products p ON i.product_id = p.product_id
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1 ORDER BY revenue DESC LIMIT 10;

-- 19. Find low-performing products.
SELECT p.product_name, SUM(i.quantity) as qty_sold, SUM(i.total_sales_amount) as revenue
FROM sales_order_items i
JOIN products p ON i.product_id = p.product_id
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1 ORDER BY revenue ASC LIMIT 10;

-- 20. Calculate profit margin by category.
SELECT p.category, 
       SUM(i.profit_amount) / NULLIF(SUM(i.total_sales_amount), 0) AS profit_margin
FROM sales_order_items i
JOIN products p ON i.product_id = p.product_id
JOIN sales_orders o ON i.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1;

-- =========================================================
-- CUSTOMER ANALYTICS, RETENTION & CHURN
-- =========================================================

-- 21. Calculate customer retention rate.
SELECT 
    SUM(CASE WHEN customer_status = 'active' THEN 1 ELSE 0 END)::DECIMAL / NULLIF(COUNT(*), 0) AS retention_rate
FROM customers;

-- 22. Calculate customer churn rate.
SELECT 
    SUM(CASE WHEN customer_status = 'churned' THEN 1 ELSE 0 END)::DECIMAL / NULLIF(COUNT(*), 0) AS churn_rate
FROM customers;

-- 23. Find repeat customers.
SELECT customer_id, COUNT(order_id) as total_orders
FROM sales_orders
WHERE order_status = 'completed'
GROUP BY customer_id HAVING COUNT(order_id) > 1;

-- 24. Calculate repeat customer rate.
WITH CustomerOrderCounts AS (
    SELECT customer_id, COUNT(order_id) as total_orders
    FROM sales_orders WHERE order_status = 'completed' GROUP BY customer_id
)
SELECT 
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END)::DECIMAL / NULLIF(COUNT(*), 0) AS repeat_customer_rate
FROM CustomerOrderCounts;

-- 25. Calculate customer lifetime value.
SELECT c.customer_id, c.customer_name, SUM(o.total_order_amount) as clv
FROM customers c
JOIN sales_orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'completed'
GROUP BY 1, 2 ORDER BY clv DESC;

-- 26. Rank top customers by spending.
SELECT c.customer_name, SUM(o.total_order_amount) as spending,
       RANK() OVER(ORDER BY SUM(o.total_order_amount) DESC) as spender_rank
FROM customers c
JOIN sales_orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'completed'
GROUP BY 1 LIMIT 10;

-- 27. Analyze customer segment performance.
SELECT customer_segment, COUNT(customer_id) as num_customers,
       SUM(CASE WHEN customer_status = 'churned' THEN 1 ELSE 0 END) as churned_in_segment
FROM customers
GROUP BY 1;

-- =========================================================
-- CHANNEL & CAMPAIGN ROI
-- =========================================================

-- 28. Calculate sales by channel.
SELECT sales_channel, SUM(total_order_amount) as channel_revenue, COUNT(order_id) as orders
FROM sales_orders
WHERE order_status = 'completed'
GROUP BY 1 ORDER BY channel_revenue DESC;

-- 29. Compare online vs offline sales.
SELECT 
    CASE WHEN sales_channel IN ('website', 'mobile_app', 'marketplace') THEN 'Online' ELSE 'Offline' END as platform,
    SUM(total_order_amount) as revenue
FROM sales_orders
WHERE order_status = 'completed'
GROUP BY 1;

-- 30. Calculate campaign ROI.
SELECT 
    mc.campaign_name,
    mc.campaign_cost,
    SUM(o.total_order_amount) as revenue_generated,
    (SUM(o.total_order_amount) - mc.campaign_cost) / NULLIF(mc.campaign_cost, 0) AS roi
FROM marketing_campaigns mc
LEFT JOIN sales_orders o ON o.order_date BETWEEN mc.start_date AND mc.end_date AND o.order_status = 'completed'
GROUP BY 1, 2 ORDER BY roi DESC;

-- 31. Find best-performing campaigns.
SELECT mc.campaign_name, (SUM(o.total_order_amount) - mc.campaign_cost) / NULLIF(mc.campaign_cost, 0) AS roi
FROM marketing_campaigns mc
LEFT JOIN sales_orders o ON o.order_date BETWEEN mc.start_date AND mc.end_date AND o.order_status = 'completed'
GROUP BY 1, mc.campaign_cost
ORDER BY roi DESC NULLS LAST LIMIT 5;

-- 32. Analyze campaign impact during campaign period.
SELECT 
    mc.campaign_name,
    COUNT(DISTINCT o.order_id) as orders_during_campaign
FROM marketing_campaigns mc
LEFT JOIN sales_orders o ON o.order_date BETWEEN mc.start_date AND mc.end_date AND o.order_status = 'completed'
GROUP BY 1;

-- =========================================================
-- ADVANCED REPORTING & CTEs
-- =========================================================

-- 33. Calculate customer growth trend.
-- KPI: Measures cumulative or new customer signups per month.
SELECT 
    TO_CHAR(signup_date, 'YYYY-MM') as signup_month,
    COUNT(customer_id) as new_customers,
    SUM(COUNT(customer_id)) OVER(ORDER BY TO_CHAR(signup_date, 'YYYY-MM')) as cumulative_customers
FROM customers
GROUP BY 1 ORDER BY 1;

-- 34. Calculate active customer rate.
SELECT 
    (SUM(CASE WHEN customer_status = 'active' THEN 1 ELSE 0 END)::DECIMAL / NULLIF(COUNT(*), 0)) AS active_rate 
FROM customers;

-- 35. Build executive KPI summary using CTE.
WITH Revenue AS (
    SELECT SUM(total_order_amount) as rev FROM sales_orders WHERE order_status = 'completed'
), CustomersCTE AS (
    SELECT COUNT(*) as custs FROM customers
)
SELECT Revenue.rev AS total_revenue, CustomersCTE.custs AS total_customers
FROM Revenue CROSS JOIN CustomersCTE;

-- 36. Build sales trend analysis using window functions.
SELECT 
    order_date,
    total_order_amount,
    SUM(total_order_amount) OVER(ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_7d_revenue
FROM sales_orders
WHERE order_status = 'completed'
ORDER BY order_date LIMIT 20;

-- 37. Detect seasonal business trends.
SELECT 
    EXTRACT(QUARTER FROM order_date) as quarter,
    SUM(total_order_amount) as quarterly_revenue
FROM sales_orders
WHERE order_status = 'completed'
GROUP BY 1 ORDER BY 1;

-- 38. Create business recommendations using CASE WHEN.
SELECT 
    p.category,
    SUM(i.total_sales_amount) as rev,
    CASE 
        WHEN SUM(i.total_sales_amount) < 5000 THEN 'Review Pricing or Marketing'
        WHEN SUM(i.total_sales_amount) BETWEEN 5000 AND 15000 THEN 'Steady Performer'
        ELSE 'Top Category - Double Down' 
    END as recommendation
FROM sales_order_items i
JOIN products p ON i.product_id = p.product_id
JOIN sales_orders o ON i.order_id = o.order_id WHERE o.order_status = 'completed'
GROUP BY 1;

-- 39. Build BI-ready reporting summary.
-- Extracts core metrics for a clean summary dashboard widget
SELECT 
    (SELECT COUNT(order_id) FROM sales_orders WHERE order_status = 'completed') as total_sales_volume,
    (SELECT SUM(profit_amount) FROM sales_order_items i JOIN sales_orders o ON i.order_id = o.order_id WHERE o.order_status='completed') as total_profit_volume,
    (SELECT COUNT(customer_id) FROM customers WHERE customer_status = 'churned') as churned_volume;

-- 40. Create reusable KPI calculation query examples.
-- Example of parameterized-like structure for dashboards (often replaced by BI tools parameters)
WITH FilteredOrders AS (
    SELECT order_id, total_order_amount, order_date
    FROM sales_orders 
    WHERE order_status = 'completed' AND order_date >= '2023-01-01'
)
SELECT 
    COUNT(order_id) as KPI_OrderCount,
    SUM(total_order_amount) as KPI_TotalRevenue,
    SUM(total_order_amount)/NULLIF(COUNT(order_id), 0) as KPI_AOV
FROM FilteredOrders;
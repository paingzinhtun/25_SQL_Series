-- Day 25: End-to-End Data Pipeline
-- analytics_queries.sql: Advanced BI and analytics queries for the Gold Layer

-- ==========================================
-- 1-10: KPI & EXECUTIVE REPORTING
-- ==========================================

-- 1. Total Pipeline Processed Revenue
SELECT SUM(net_sales_amount) as total_pipeline_revenue FROM fact_sales;

-- 2. Total Orders Loaded Successfully
SELECT COUNT(DISTINCT order_id) as total_valid_orders FROM fact_sales;

-- 3. Average Order Value (AOV)
SELECT SUM(net_sales_amount)/COUNT(DISTINCT order_id) as AOV FROM fact_sales;

-- 4. Total Discount Impact
SELECT SUM(discount_amount) as total_revenue_lost_to_discounts FROM fact_sales;

-- 5. Total Units Sold
SELECT SUM(quantity) as total_volume_shipped FROM fact_sales;

-- 6. Revenue vs Discount Ratio
SELECT 
    SUM(discount_amount) / NULLIF(SUM(gross_sales_amount), 0) as discount_ratio
FROM fact_sales;

-- 7. Monthly Revenue Trend
SELECT 
    d.year, d.month_name, 
    SUM(f.net_sales_amount) as monthly_revenue
FROM fact_sales f JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1, 2 ORDER BY 1, 2;

-- 8. Quarterly Revenue Rollup
SELECT 
    d.year, d.quarter, 
    SUM(f.net_sales_amount) as quarterly_revenue
FROM fact_sales f JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1, 2 ORDER BY 1, 2;

-- 9. Daily Revenue Spikes
SELECT 
    d.full_date, SUM(f.net_sales_amount) as daily_revenue
FROM fact_sales f JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- 10. Weekend vs Weekday Sales (Are we busier on weekends?)
SELECT 
    d.is_weekend, 
    SUM(f.net_sales_amount) as revenue,
    COUNT(DISTINCT f.order_id) as traffic
FROM fact_sales f JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1;

-- ==========================================
-- 11-20: REGIONAL & STORE PERFORMANCE
-- ==========================================

-- 11. Top Performing Regions
SELECT 
    c.region, SUM(f.net_sales_amount) as revenue
FROM fact_sales f JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 12. Top Performing Stores
SELECT 
    s.store_name, SUM(f.net_sales_amount) as revenue
FROM fact_sales f JOIN dim_store s ON f.store_sk = s.store_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 13. Online vs Offline Split (Assuming NULL store_sk implies online)
SELECT 
    CASE WHEN store_sk IS NULL THEN 'Online' ELSE 'In-Store' END as channel,
    SUM(net_sales_amount) as revenue
FROM fact_sales
GROUP BY 1;

-- 14. Average Order Value by Region
SELECT 
    c.region, 
    SUM(f.net_sales_amount)/COUNT(DISTINCT f.order_id) as regional_aov
FROM fact_sales f JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 15. Store Traffic by Month
SELECT 
    s.store_name, d.month_name, COUNT(DISTINCT f.order_id) as foot_traffic
FROM fact_sales f JOIN dim_store s ON f.store_sk = s.store_sk JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1, 2;

-- 16. Lowest Performing Stores
SELECT 
    s.store_name, SUM(f.net_sales_amount) as revenue
FROM fact_sales f JOIN dim_store s ON f.store_sk = s.store_sk
GROUP BY 1 ORDER BY 2 ASC LIMIT 5;

-- 17. Most Discounted Stores
SELECT 
    s.store_name, SUM(f.discount_amount) as total_discounts
FROM fact_sales f JOIN dim_store s ON f.store_sk = s.store_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 18. Store Revenue Contribution %
WITH StoreRev AS (SELECT store_sk, SUM(net_sales_amount) as rev FROM fact_sales GROUP BY 1)
SELECT 
    s.store_name, rev,
    rev / SUM(rev) OVER() as contribution_percentage
FROM StoreRev r LEFT JOIN dim_store s ON r.store_sk = s.store_sk;

-- 19. City Revenue Heatmap
SELECT 
    COALESCE(s.city, c.city) as city, SUM(f.net_sales_amount) as revenue
FROM fact_sales f LEFT JOIN dim_store s ON f.store_sk = s.store_sk JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 20. Store Count by Region
SELECT city, COUNT(*) as active_stores FROM dim_store GROUP BY 1;

-- ==========================================
-- 21-30: PRODUCT PERFORMANCE
-- ==========================================

-- 21. Top Categories by Volume
SELECT 
    p.category, SUM(f.quantity) as volume
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 22. Top Categories by Revenue
SELECT 
    p.category, SUM(f.net_sales_amount) as revenue
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 23. Highest Discounted Categories
SELECT 
    p.category, SUM(f.discount_amount) as discounts
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 24. Top Selling Individual Products
SELECT 
    p.product_name, SUM(f.net_sales_amount) as revenue
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- 25. Products Driving the Most Traffic (Appearing in most unique orders)
SELECT 
    p.product_name, COUNT(DISTINCT f.order_id) as order_appearances
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1 ORDER BY 2 DESC;

-- 26. Category Contribution % using Window Functions
WITH CatRev AS (
    SELECT p.category, SUM(f.net_sales_amount) as rev
    FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk GROUP BY 1
)
SELECT category, rev, rev / SUM(rev) OVER() as cat_percentage FROM CatRev;

-- 27. Cross-Selling (Average items per order)
SELECT SUM(quantity)::DECIMAL / COUNT(DISTINCT order_id) as avg_items_per_order FROM fact_sales;

-- 28. Revenue per Item Type
SELECT 
    p.category, SUM(f.net_sales_amount) / SUM(f.quantity) as revenue_per_item
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1;

-- 29. Identifying Stale Inventory
-- Products in dimensions that never appear in facts
SELECT p.product_name FROM dim_product p LEFT JOIN fact_sales f ON p.product_sk = f.product_sk WHERE f.product_sk IS NULL;

-- 30. Top Grossing Products vs Net
SELECT 
    p.product_name, SUM(f.gross_sales_amount) as gross, SUM(f.net_sales_amount) as net,
    (SUM(f.gross_sales_amount) - SUM(f.net_sales_amount)) as total_discount_given
FROM fact_sales f JOIN dim_product p ON f.product_sk = p.product_sk
GROUP BY 1 ORDER BY gross DESC LIMIT 5;

-- ==========================================
-- 31-40: CUSTOMER ANALYTICS & GROWTH
-- ==========================================

-- 31. Top 10 VIP Customers
SELECT 
    c.customer_name, SUM(f.net_sales_amount) as lifetime_value
FROM fact_sales f JOIN dim_customer c ON f.customer_sk = c.customer_sk
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- 32. Customer Retention (Repeat Rate)
WITH CustOrders AS (SELECT customer_sk, COUNT(DISTINCT order_id) as orders FROM fact_sales GROUP BY 1)
SELECT SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) as repeat_rate FROM CustOrders;

-- 33. One-Time Buyers
WITH CustOrders AS (SELECT customer_sk, COUNT(DISTINCT order_id) as orders FROM fact_sales GROUP BY 1)
SELECT COUNT(*) as one_time_buyers FROM CustOrders WHERE orders = 1;

-- 34. Month-over-Month Growth (LAG)
WITH MonthlyRev AS (
    SELECT d.year, d.month, SUM(f.net_sales_amount) as rev 
    FROM fact_sales f JOIN dim_date d ON f.date_sk = d.date_sk GROUP BY 1, 2
)
SELECT 
    year, month, rev, 
    LAG(rev) OVER(ORDER BY year, month) as prev_rev,
    (rev - LAG(rev) OVER(ORDER BY year, month)) / NULLIF(LAG(rev) OVER(ORDER BY year, month), 0) as mom_growth
FROM MonthlyRev;

-- 35. Moving Average (Rolling 3 Month Revenue)
WITH MonthlyRev AS (
    SELECT d.year, d.month, SUM(f.net_sales_amount) as rev 
    FROM fact_sales f JOIN dim_date d ON f.date_sk = d.date_sk GROUP BY 1, 2
)
SELECT 
    year, month, rev,
    AVG(rev) OVER(ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as rolling_3m_avg
FROM MonthlyRev;

-- 36. Rank Customers by Region
WITH RegionSpenders AS (
    SELECT c.region, c.customer_name, SUM(f.net_sales_amount) as ltv
    FROM fact_sales f JOIN dim_customer c ON f.customer_sk = c.customer_sk GROUP BY 1, 2
)
SELECT region, customer_name, ltv,
       RANK() OVER(PARTITION BY region ORDER BY ltv DESC) as rank_in_region
FROM RegionSpenders;

-- 37. Days Between First and Last Order
SELECT 
    c.customer_name, 
    MAX(d.full_date) - MIN(d.full_date) as customer_lifespan_days
FROM fact_sales f JOIN dim_customer c ON f.customer_sk = c.customer_sk JOIN dim_date d ON f.date_sk = d.date_sk
GROUP BY 1 HAVING MAX(d.full_date) > MIN(d.full_date);

-- 38. Calculate Recency (Days since last order compared to max date in dataset)
WITH MaxDate AS (SELECT MAX(full_date) as md FROM dim_date JOIN fact_sales ON dim_date.date_sk = fact_sales.date_sk)
SELECT 
    c.customer_name, 
    MaxDate.md - MAX(d.full_date) as days_since_last_purchase
FROM fact_sales f JOIN dim_customer c ON f.customer_sk = c.customer_sk JOIN dim_date d ON f.date_sk = d.date_sk CROSS JOIN MaxDate
GROUP BY 1, MaxDate.md ORDER BY 2 ASC;

-- 39. Missing Region Fill-in Analytics
SELECT 
    COUNT(CASE WHEN region = 'Unknown' THEN 1 END) as missing_region_count,
    COUNT(*) as total_customers
FROM dim_customer;

-- 40. Pipeline Throughput Validation
SELECT 
    'Pipeline Processed Correctly' as status,
    COUNT(DISTINCT order_id) as total_orders_loaded,
    SUM(quantity) as total_items_cleansed,
    MIN(loaded_at) as pipeline_start,
    MAX(loaded_at) as pipeline_end
FROM fact_sales;
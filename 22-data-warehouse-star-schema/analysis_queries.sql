-- Day 22 - Data Warehouse Design with Star Schema
-- PostgreSQL warehouse analytics and BI queries

-- 1. Show all sales facts with dimensions joined.
SELECT
    fs.sales_key,
    fs.order_id,
    dd.full_date,
    dc.customer_name,
    dp.product_name,
    ds.store_name,
    de.employee_name,
    dch.channel_name,
    fs.quantity_sold,
    fs.total_sales_amount,
    fs.profit_amount
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
JOIN dim_customer AS dc
    ON fs.customer_key = dc.customer_key
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
JOIN dim_employee AS de
    ON fs.employee_key = de.employee_key
JOIN dim_channel AS dch
    ON fs.channel_key = dch.channel_key
ORDER BY dd.full_date, fs.order_id, fs.sales_key;

-- 2. Calculate total revenue.
SELECT
    SUM(total_sales_amount) AS total_revenue
FROM fact_sales;

-- 3. Calculate total profit.
SELECT
    SUM(profit_amount) AS total_profit
FROM fact_sales;

-- 4. Calculate total quantity sold.
SELECT
    SUM(quantity_sold) AS total_quantity_sold
FROM fact_sales;

-- 5. Calculate average order value.
-- Average order value = revenue / distinct orders.
SELECT
    ROUND(
        SUM(total_sales_amount) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM fact_sales;

-- 6. Calculate sales by year.
SELECT
    dd.year_number,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
GROUP BY dd.year_number
ORDER BY dd.year_number;

-- 7. Calculate sales by quarter.
SELECT
    dd.year_number,
    dd.quarter_number,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
GROUP BY dd.year_number, dd.quarter_number
ORDER BY dd.year_number, dd.quarter_number;

-- 8. Calculate sales by month.
SELECT
    dd.year_number,
    dd.month_number,
    dd.month_name,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
GROUP BY dd.year_number, dd.month_number, dd.month_name
ORDER BY dd.year_number, dd.month_number;

-- 9. Calculate sales by weekday.
SELECT
    dd.day_name,
    SUM(fs.total_sales_amount) AS total_revenue
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
GROUP BY dd.day_name
ORDER BY total_revenue DESC;

-- 10. Calculate sales by weekend vs weekday.
SELECT
    CASE WHEN dd.is_weekend THEN 'weekend' ELSE 'weekday' END AS day_type,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.quantity_sold) AS total_quantity_sold
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
GROUP BY CASE WHEN dd.is_weekend THEN 'weekend' ELSE 'weekday' END
ORDER BY total_revenue DESC;

-- 11. Calculate sales by region.
SELECT
    ds.region,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
GROUP BY ds.region
ORDER BY total_revenue DESC;

-- 12. Calculate sales by city.
SELECT
    ds.city,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
GROUP BY ds.city
ORDER BY total_revenue DESC;

-- 13. Calculate sales by store.
SELECT
    ds.store_name,
    ds.region,
    ds.store_type,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
GROUP BY ds.store_name, ds.region, ds.store_type
ORDER BY total_revenue DESC;

-- 14. Rank stores by revenue.
SELECT
    ds.store_name,
    ds.region,
    SUM(fs.total_sales_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.total_sales_amount) DESC) AS revenue_rank
FROM fact_sales AS fs
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
GROUP BY ds.store_name, ds.region
ORDER BY revenue_rank;

-- 15. Calculate sales by store type.
SELECT
    ds.store_type,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
GROUP BY ds.store_type
ORDER BY total_revenue DESC;

-- 16. Calculate sales by product category.
SELECT
    dp.category,
    SUM(fs.quantity_sold) AS total_quantity_sold,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_revenue DESC;

-- 17. Calculate sales by subcategory.
SELECT
    dp.category,
    dp.subcategory,
    SUM(fs.quantity_sold) AS total_quantity_sold,
    SUM(fs.total_sales_amount) AS total_revenue
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory
ORDER BY total_revenue DESC;

-- 18. Rank products by revenue.
SELECT
    dp.product_name,
    dp.category,
    SUM(fs.total_sales_amount) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY SUM(fs.total_sales_amount) DESC) AS revenue_rank
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name, dp.category
ORDER BY revenue_rank, dp.product_name;

-- 19. Rank products by profit.
SELECT
    dp.product_name,
    dp.category,
    SUM(fs.profit_amount) AS total_profit,
    RANK() OVER (ORDER BY SUM(fs.profit_amount) DESC) AS profit_rank
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.product_name, dp.category
ORDER BY profit_rank;

-- 20. Find low-performing products.
-- Low-performing products are products with revenue below average product revenue.
WITH product_revenue AS (
    SELECT
        dp.product_name,
        dp.category,
        SUM(fs.total_sales_amount) AS total_revenue
    FROM dim_product AS dp
    LEFT JOIN fact_sales AS fs
        ON dp.product_key = fs.product_key
    GROUP BY dp.product_name, dp.category
),
average_product_revenue AS (
    SELECT AVG(total_revenue) AS avg_revenue
    FROM product_revenue
)
SELECT
    pr.product_name,
    pr.category,
    COALESCE(pr.total_revenue, 0) AS total_revenue
FROM product_revenue AS pr
CROSS JOIN average_product_revenue AS apr
WHERE COALESCE(pr.total_revenue, 0) < apr.avg_revenue
ORDER BY total_revenue;

-- 21. Calculate sales by customer type.
SELECT
    dc.customer_type,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_sales_amount) AS total_revenue
FROM fact_sales AS fs
JOIN dim_customer AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_type
ORDER BY total_revenue DESC;

-- 22. Rank customers by spending.
SELECT
    dc.customer_name,
    dc.region,
    dc.customer_type,
    SUM(fs.total_sales_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(fs.total_sales_amount) DESC) AS customer_spend_rank
FROM fact_sales AS fs
JOIN dim_customer AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_name, dc.region, dc.customer_type
ORDER BY customer_spend_rank
LIMIT 20;

-- 23. Calculate repeat customer sales.
-- Repeat customer = customer with more than one distinct order.
WITH customer_orders AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(total_sales_amount) AS total_spent
    FROM fact_sales
    GROUP BY customer_key
)
SELECT
    CASE WHEN order_count > 1 THEN 'repeat_customer' ELSE 'one_time_customer' END AS customer_group,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS total_revenue
FROM customer_orders
GROUP BY CASE WHEN order_count > 1 THEN 'repeat_customer' ELSE 'one_time_customer' END;

-- 24. Calculate sales by sales channel.
SELECT
    dch.channel_name,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_channel AS dch
    ON fs.channel_key = dch.channel_key
GROUP BY dch.channel_name
ORDER BY total_revenue DESC;

-- 25. Compare online vs offline sales.
SELECT
    CASE
        WHEN dch.channel_name IN ('website', 'mobile_app', 'marketplace') THEN 'online'
        ELSE 'offline'
    END AS channel_group,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_sales_amount) AS total_revenue
FROM fact_sales AS fs
JOIN dim_channel AS dch
    ON fs.channel_key = dch.channel_key
GROUP BY CASE
    WHEN dch.channel_name IN ('website', 'mobile_app', 'marketplace') THEN 'online'
    ELSE 'offline'
END
ORDER BY total_revenue DESC;

-- 26. Calculate employee sales performance.
SELECT
    de.employee_name,
    de.department,
    de.role,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit
FROM fact_sales AS fs
JOIN dim_employee AS de
    ON fs.employee_key = de.employee_key
GROUP BY de.employee_name, de.department, de.role
ORDER BY total_revenue DESC;

-- 27. Rank employees by revenue generated.
SELECT
    de.employee_name,
    de.department,
    SUM(fs.total_sales_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.total_sales_amount) DESC) AS employee_revenue_rank
FROM fact_sales AS fs
JOIN dim_employee AS de
    ON fs.employee_key = de.employee_key
GROUP BY de.employee_name, de.department
ORDER BY employee_revenue_rank;

-- 28. Calculate average discount by category.
SELECT
    dp.category,
    ROUND(AVG(fs.discount_amount), 2) AS avg_discount_amount
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY avg_discount_amount DESC;

-- 29. Calculate profit margin by category.
-- Profit margin = profit / revenue.
SELECT
    dp.category,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit,
    ROUND(SUM(fs.profit_amount) * 100.0 / NULLIF(SUM(fs.total_sales_amount), 0), 2) AS profit_margin_percent
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY profit_margin_percent DESC;

-- 30. Calculate monthly growth trend.
-- Growth rate = (current period revenue - previous period revenue) / previous period revenue.
WITH monthly_sales AS (
    SELECT
        dd.year_number,
        dd.month_number,
        dd.month_name,
        SUM(fs.total_sales_amount) AS total_revenue
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    GROUP BY dd.year_number, dd.month_number, dd.month_name
),
monthly_with_lag AS (
    SELECT
        monthly_sales.*,
        LAG(total_revenue) OVER (
            ORDER BY year_number, month_number
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    year_number,
    month_number,
    month_name,
    total_revenue,
    previous_month_revenue,
    ROUND(
        (total_revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS monthly_growth_rate_percent
FROM monthly_with_lag
ORDER BY year_number, month_number;

-- 31. Calculate year-over-year growth.
WITH yearly_sales AS (
    SELECT
        dd.year_number,
        SUM(fs.total_sales_amount) AS total_revenue
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    GROUP BY dd.year_number
),
yearly_with_lag AS (
    SELECT
        year_number,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY year_number) AS previous_year_revenue
    FROM yearly_sales
)
SELECT
    year_number,
    total_revenue,
    previous_year_revenue,
    ROUND(
        (total_revenue - previous_year_revenue) * 100.0
        / NULLIF(previous_year_revenue, 0),
        2
    ) AS yoy_growth_rate_percent
FROM yearly_with_lag
ORDER BY year_number;

-- 32. Build top KPI summary using CTE.
WITH kpi_summary AS (
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_sales_amount) AS total_revenue,
        SUM(profit_amount) AS total_profit,
        SUM(quantity_sold) AS total_quantity_sold
    FROM fact_sales
)
SELECT
    total_orders,
    total_revenue,
    total_profit,
    total_quantity_sold,
    ROUND(total_revenue / NULLIF(total_orders, 0), 2) AS avg_order_value,
    ROUND(total_profit * 100.0 / NULLIF(total_revenue, 0), 2) AS profit_margin_percent
FROM kpi_summary;

-- 33. Build executive sales dashboard view using SQL.
WITH monthly_base AS (
    SELECT
        dd.year_number,
        dd.month_number,
        COUNT(DISTINCT fs.order_id) AS total_orders,
        SUM(fs.total_sales_amount) AS total_revenue,
        SUM(fs.profit_amount) AS total_profit,
        SUM(fs.quantity_sold) AS total_quantity_sold
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    GROUP BY dd.year_number, dd.month_number
),
monthly_growth AS (
    SELECT
        monthly_base.*,
        LAG(total_revenue) OVER (
            ORDER BY year_number, month_number
        ) AS previous_month_revenue
    FROM monthly_base
),
top_category AS (
    SELECT
        dd.year_number,
        dd.month_number,
        dp.category,
        ROW_NUMBER() OVER (
            PARTITION BY dd.year_number, dd.month_number
            ORDER BY SUM(fs.total_sales_amount) DESC
        ) AS category_rank
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    JOIN dim_product AS dp
        ON fs.product_key = dp.product_key
    GROUP BY dd.year_number, dd.month_number, dp.category
),
top_region AS (
    SELECT
        dd.year_number,
        dd.month_number,
        ds.region,
        ROW_NUMBER() OVER (
            PARTITION BY dd.year_number, dd.month_number
            ORDER BY SUM(fs.total_sales_amount) DESC
        ) AS region_rank
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    JOIN dim_store AS ds
        ON fs.store_key = ds.store_key
    GROUP BY dd.year_number, dd.month_number, ds.region
)
SELECT
    mg.year_number,
    mg.month_number,
    mg.total_orders,
    mg.total_revenue,
    mg.total_profit,
    mg.total_quantity_sold,
    ROUND(mg.total_revenue / NULLIF(mg.total_orders, 0), 2) AS avg_order_value,
    ROUND(
        (mg.total_revenue - mg.previous_month_revenue) * 100.0
        / NULLIF(mg.previous_month_revenue, 0),
        2
    ) AS growth_rate_percent,
    tc.category AS top_category,
    tr.region AS top_region
FROM monthly_growth AS mg
LEFT JOIN top_category AS tc
    ON mg.year_number = tc.year_number
   AND mg.month_number = tc.month_number
   AND tc.category_rank = 1
LEFT JOIN top_region AS tr
    ON mg.year_number = tr.year_number
   AND mg.month_number = tr.month_number
   AND tr.region_rank = 1
ORDER BY mg.year_number, mg.month_number;

-- 34. Build product performance dashboard view using SQL.
WITH product_performance AS (
    SELECT
        dp.product_name,
        dp.category,
        dp.subcategory,
        SUM(fs.quantity_sold) AS total_quantity_sold,
        SUM(fs.total_sales_amount) AS total_revenue,
        SUM(fs.profit_amount) AS total_profit,
        AVG(fs.discount_amount) AS avg_discount
    FROM dim_product AS dp
    LEFT JOIN fact_sales AS fs
        ON dp.product_key = fs.product_key
    GROUP BY dp.product_name, dp.category, dp.subcategory
)
SELECT
    product_name,
    category,
    subcategory,
    COALESCE(total_quantity_sold, 0) AS total_quantity_sold,
    COALESCE(total_revenue, 0) AS total_revenue,
    COALESCE(total_profit, 0) AS total_profit,
    ROUND(COALESCE(avg_discount, 0), 2) AS avg_discount,
    CASE
        WHEN COALESCE(total_revenue, 0) >= 10000000 THEN 'high_performer'
        WHEN COALESCE(total_revenue, 0) < 1000000 THEN 'low_performer'
        WHEN COALESCE(total_profit, 0) / NULLIF(COALESCE(total_revenue, 0), 0) < 0.20 THEN 'low_margin'
        ELSE 'stable'
    END AS performance_status
FROM product_performance
ORDER BY total_revenue DESC;

-- 35. Build store performance dashboard view using SQL.
WITH store_performance AS (
    SELECT
        ds.store_name,
        ds.region,
        ds.store_type,
        COUNT(DISTINCT fs.order_id) AS total_orders,
        SUM(fs.total_sales_amount) AS total_revenue,
        SUM(fs.profit_amount) AS total_profit,
        ROUND(SUM(fs.total_sales_amount) / NULLIF(COUNT(DISTINCT fs.order_id), 0), 2) AS avg_order_value
    FROM dim_store AS ds
    LEFT JOIN fact_sales AS fs
        ON ds.store_key = fs.store_key
    GROUP BY ds.store_name, ds.region, ds.store_type
)
SELECT
    store_name,
    region,
    store_type,
    total_orders,
    total_revenue,
    total_profit,
    avg_order_value,
    RANK() OVER (ORDER BY total_revenue DESC) AS store_rank
FROM store_performance
ORDER BY store_rank;

-- 36. Build customer analytics dashboard view using SQL.
WITH customer_performance AS (
    SELECT
        dc.customer_name,
        dc.region,
        dc.customer_type,
        COUNT(DISTINCT fs.order_id) AS total_orders,
        SUM(fs.total_sales_amount) AS total_spent,
        ROUND(SUM(fs.total_sales_amount) / NULLIF(COUNT(DISTINCT fs.order_id), 0), 2) AS avg_order_value
    FROM dim_customer AS dc
    LEFT JOIN fact_sales AS fs
        ON dc.customer_key = fs.customer_key
    GROUP BY dc.customer_name, dc.region, dc.customer_type
)
SELECT
    customer_name,
    region,
    customer_type,
    COALESCE(total_orders, 0) AS total_orders,
    COALESCE(total_spent, 0) AS total_spent,
    COALESCE(avg_order_value, 0) AS avg_order_value,
    CASE
        WHEN COALESCE(total_spent, 0) >= 8000000 THEN 'high_value_customer'
        WHEN COALESCE(total_orders, 0) >= 5 THEN 'repeat_customer'
        WHEN COALESCE(total_orders, 0) = 1 THEN 'one_time_customer'
        ELSE 'low_activity_customer'
    END AS customer_segment
FROM customer_performance
ORDER BY total_spent DESC;

-- 37. Build sales trend dashboard view using SQL.
WITH monthly_sales AS (
    SELECT
        dd.year_number,
        dd.month_number,
        SUM(fs.total_sales_amount) AS total_revenue,
        SUM(fs.profit_amount) AS total_profit,
        COUNT(DISTINCT fs.order_id) AS total_orders
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    GROUP BY dd.year_number, dd.month_number
),
monthly_trend AS (
    SELECT
        monthly_sales.*,
        LAG(total_revenue) OVER (
            ORDER BY year_number, month_number
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    year_number,
    month_number,
    total_revenue,
    total_profit,
    total_orders,
    ROUND(
        (total_revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_rate_percent,
    CASE
        WHEN previous_month_revenue IS NULL THEN 'first_period'
        WHEN total_revenue > previous_month_revenue THEN 'growing'
        WHEN total_revenue < previous_month_revenue THEN 'declining'
        ELSE 'flat'
    END AS trend_status
FROM monthly_trend
ORDER BY year_number, month_number;

-- 38. Detect seasonal sales trends.
SELECT
    dd.month_number,
    dd.month_name,
    SUM(fs.total_sales_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.total_sales_amount) DESC) AS seasonal_rank
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
GROUP BY dd.month_number, dd.month_name
ORDER BY seasonal_rank;

-- 39. Create business recommendations using CASE WHEN.
WITH category_summary AS (
    SELECT
        dp.category,
        SUM(fs.total_sales_amount) AS total_revenue,
        SUM(fs.profit_amount) AS total_profit,
        ROUND(SUM(fs.profit_amount) * 100.0 / NULLIF(SUM(fs.total_sales_amount), 0), 2) AS profit_margin_percent
    FROM fact_sales AS fs
    JOIN dim_product AS dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.category
)
SELECT
    category,
    total_revenue,
    total_profit,
    profit_margin_percent,
    CASE
        WHEN total_revenue >= 20000000 AND profit_margin_percent >= 30 THEN 'Expand high-performing category'
        WHEN total_revenue < 3000000 THEN 'Review low-performing products'
        WHEN profit_margin_percent < 20 THEN 'Improve profit margin'
        ELSE 'Maintain current performance'
    END AS business_recommendation
FROM category_summary
ORDER BY total_revenue DESC;

-- 40. Create warehouse-ready BI summary view.
CREATE OR REPLACE VIEW vw_bi_sales_summary AS
SELECT
    dd.year_number,
    dd.month_number,
    ds.region,
    ds.store_type,
    dp.category,
    dch.channel_name,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.quantity_sold) AS total_quantity_sold,
    SUM(fs.total_sales_amount) AS total_revenue,
    SUM(fs.profit_amount) AS total_profit,
    ROUND(SUM(fs.total_sales_amount) / NULLIF(COUNT(DISTINCT fs.order_id), 0), 2) AS avg_order_value,
    ROUND(SUM(fs.profit_amount) * 100.0 / NULLIF(SUM(fs.total_sales_amount), 0), 2) AS profit_margin_percent
FROM fact_sales AS fs
JOIN dim_date AS dd
    ON fs.date_key = dd.date_key
JOIN dim_store AS ds
    ON fs.store_key = ds.store_key
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
JOIN dim_channel AS dch
    ON fs.channel_key = dch.channel_key
GROUP BY
    dd.year_number,
    dd.month_number,
    ds.region,
    ds.store_type,
    dp.category,
    dch.channel_name;

SELECT
    *
FROM vw_bi_sales_summary
ORDER BY year_number, month_number, region, category;

-- Extra warehouse query: running revenue by month.
WITH monthly_sales AS (
    SELECT
        dd.year_number,
        dd.month_number,
        SUM(fs.total_sales_amount) AS total_revenue
    FROM fact_sales AS fs
    JOIN dim_date AS dd
        ON fs.date_key = dd.date_key
    GROUP BY dd.year_number, dd.month_number
)
SELECT
    year_number,
    month_number,
    total_revenue,
    SUM(total_revenue) OVER (
        ORDER BY year_number, month_number
    ) AS running_revenue
FROM monthly_sales
ORDER BY year_number, month_number;

-- Extra warehouse query: find categories above a revenue threshold using HAVING.
SELECT
    dp.category,
    SUM(fs.total_sales_amount) AS total_revenue
FROM fact_sales AS fs
JOIN dim_product AS dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category
HAVING SUM(fs.total_sales_amount) >= 5000000
ORDER BY total_revenue DESC;

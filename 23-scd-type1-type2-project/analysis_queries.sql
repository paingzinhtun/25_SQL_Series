-- Day 23: Slowly Changing Dimensions (SCD Type 1 & Type 2)
-- analysis_queries.sql

-- ==========================================
-- BASIC SCD TYPE 1 & 2 EXPLORATION
-- ==========================================

-- 1. Show all Type 1 customer records
-- Notice there is only one row per customer, showing only the latest state.
SELECT * FROM dim_customer_scd1 ORDER BY customer_id;

-- 2. Show all Type 2 customer history records
-- Notice multiple rows for C001 and C002.
SELECT * FROM dim_customer_scd2 ORDER BY customer_id, version_number;

-- 3. Show current customer records only
-- Essential filter for current state reporting.
SELECT * FROM dim_customer_scd2 WHERE is_current = TRUE ORDER BY customer_id;

-- 4. Show expired customer records
-- Represents historical states that are no longer active.
SELECT * FROM dim_customer_scd2 WHERE is_current = FALSE ORDER BY customer_id;

-- 5. Find customers with multiple versions
-- Using HAVING to find records with history.
SELECT customer_id, customer_name, COUNT(*) as total_versions
FROM dim_customer_scd2
GROUP BY customer_id, customer_name
HAVING COUNT(*) > 1;

-- 6. Find customers who changed city
-- Using self-join to compare versions.
SELECT 
    old_c.customer_id,
    old_c.customer_name,
    old_c.city AS previous_city,
    new_c.city AS new_city,
    new_c.effective_start_date AS date_changed
FROM dim_customer_scd2 old_c
JOIN dim_customer_scd2 new_c 
    ON old_c.customer_id = new_c.customer_id 
    AND old_c.version_number = new_c.version_number - 1
WHERE old_c.city != new_c.city;

-- 7. Find customers who changed segment
SELECT 
    old_c.customer_id,
    old_c.customer_name,
    old_c.customer_segment AS old_segment,
    new_c.customer_segment AS new_segment
FROM dim_customer_scd2 old_c
JOIN dim_customer_scd2 new_c 
    ON old_c.customer_id = new_c.customer_id 
    AND old_c.version_number = new_c.version_number - 1
WHERE old_c.customer_segment != new_c.customer_segment;

-- 8. Count customer version changes
SELECT sum(case when version_number > 1 then 1 else 0 end) as total_changes
FROM dim_customer_scd2;

-- 9. Show employee history records
SELECT * FROM dim_employee_scd2 ORDER BY employee_id, version_number;

-- 10. Find employees who changed department
SELECT 
    e1.employee_name,
    e1.department as old_department,
    e2.department as new_department,
    e2.effective_start_date as change_date
FROM dim_employee_scd2 e1
JOIN dim_employee_scd2 e2 ON e1.employee_id = e2.employee_id AND e1.version_number = e2.version_number - 1
WHERE e1.department != e2.department;

-- 11. Find employees with salary band changes
SELECT 
    e1.employee_name,
    e1.salary_band as old_band,
    e2.salary_band as new_band
FROM dim_employee_scd2 e1
JOIN dim_employee_scd2 e2 ON e1.employee_id = e2.employee_id AND e1.version_number = e2.version_number - 1
WHERE e1.salary_band != e2.salary_band;

-- 12. Count employee version changes
SELECT employee_id, MAX(version_number) - 1 as changes_made
FROM dim_employee_scd2
GROUP BY employee_id
HAVING MAX(version_number) > 1;

-- 13. Show product history records
SELECT * FROM dim_product_scd2 ORDER BY product_id, version_number;

-- 14. Find products that changed category
SELECT 
    p1.product_name,
    p1.category as old_category,
    p2.category as new_category
FROM dim_product_scd2 p1
JOIN dim_product_scd2 p2 ON p1.product_id = p2.product_id AND p1.version_number = p2.version_number - 1
WHERE p1.category != p2.category;

-- 15. Find products that changed price band
SELECT 
    p1.product_name,
    p1.price_band as old_band,
    p2.price_band as new_band
FROM dim_product_scd2 p1
JOIN dim_product_scd2 p2 ON p1.product_id = p2.product_id AND p1.version_number = p2.version_number - 1
WHERE p1.price_band != p2.price_band;

-- 16. Count product version changes
SELECT COUNT(*) FROM dim_product_scd2 WHERE version_number > 1;

-- 17. Compare SCD1 vs SCD2 results
-- Shows that SCD1 loses history, SCD2 retains it.
SELECT 
    'SCD1 (No History)' as scd_type, COUNT(*) as total_rows FROM dim_customer_scd1
UNION ALL
SELECT 
    'SCD2 (With History)' as scd_type, COUNT(*) as total_rows FROM dim_customer_scd2;

-- 18. Show latest/current dimension records
SELECT product_name, category, price_band FROM dim_product_scd2 WHERE is_current = TRUE;

-- 19. Show historical dimension records by date
-- Find what state a product was in on a specific date
SELECT product_name, category, price_band 
FROM dim_product_scd2 
WHERE '2023-02-01' BETWEEN effective_start_date AND COALESCE(effective_end_date, '9999-12-31')
AND product_id = 'P002';

-- ==========================================
-- FACT TO DIMENSION JOINS (HISTORICAL ACCURACY)
-- ==========================================

-- 20. Find sales joined to correct historical customer version
SELECT 
    f.sales_date,
    c.customer_name,
    c.city AS city_at_time_of_sale,
    f.total_sales_amount
FROM fact_sales f
JOIN dim_customer_scd2 c ON f.customer_sk = c.customer_sk
LIMIT 10;

-- 21. Find sales joined to correct historical employee version
SELECT 
    f.sales_date,
    e.employee_name,
    e.department AS department_at_time_of_sale,
    f.total_sales_amount
FROM fact_sales f
JOIN dim_employee_scd2 e ON f.employee_sk = e.employee_sk
LIMIT 10;

-- 22. Find sales joined to correct historical product version
SELECT 
    f.sales_date,
    p.product_name,
    p.category AS category_at_time_of_sale,
    f.total_sales_amount
FROM fact_sales f
JOIN dim_product_scd2 p ON f.product_sk = p.product_sk
LIMIT 10;

-- 23. Calculate sales by historical customer segment
-- accurately reflects segment at time of sale, not current segment
SELECT 
    c.customer_segment,
    SUM(f.total_sales_amount) as total_sales
FROM fact_sales f
JOIN dim_customer_scd2 c ON f.customer_sk = c.customer_sk
GROUP BY c.customer_segment
ORDER BY total_sales DESC;

-- 24. Calculate sales by historical product category
SELECT 
    p.category,
    SUM(f.total_sales_amount) as total_sales
FROM fact_sales f
JOIN dim_product_scd2 p ON f.product_sk = p.product_sk
GROUP BY p.category
ORDER BY total_sales DESC;

-- 25. Calculate sales by employee department history
SELECT 
    e.department,
    SUM(f.total_sales_amount) as total_sales
FROM fact_sales f
JOIN dim_employee_scd2 e ON f.employee_sk = e.employee_sk
GROUP BY e.department
ORDER BY total_sales DESC;

-- ==========================================
-- ADVANCED ANALYTICS & DASHBOARDS
-- ==========================================

-- 26. Find how many customers upgraded segment
WITH SegmentChanges AS (
    SELECT 
        customer_id,
        LAG(customer_segment) OVER(PARTITION BY customer_id ORDER BY version_number) as prev_segment,
        customer_segment as curr_segment
    FROM dim_customer_scd2
)
SELECT COUNT(*) as upgraded_customers 
FROM SegmentChanges 
WHERE prev_segment = 'Regular' AND curr_segment IN ('Premium', 'VIP');

-- 27. Find how many products changed category
WITH CatChanges AS (
    SELECT 
        product_id,
        LAG(category) OVER(PARTITION BY product_id ORDER BY version_number) as prev_cat,
        category as curr_cat
    FROM dim_product_scd2
)
SELECT COUNT(*) as category_changes 
FROM CatChanges 
WHERE prev_cat IS NOT NULL AND prev_cat != curr_cat;

-- 28. Find average duration of customer versions
-- How long does a customer stay in a specific state before changing?
SELECT 
    ROUND(AVG(effective_end_date - effective_start_date), 2) as avg_days_per_version
FROM dim_customer_scd2
WHERE effective_end_date IS NOT NULL;

-- 29. Find longest-running customer versions
SELECT 
    customer_name, 
    version_number,
    COALESCE(effective_end_date, CURRENT_DATE) - effective_start_date as days_active
FROM dim_customer_scd2
ORDER BY days_active DESC
LIMIT 5;

-- 30. Find most frequently changing employees
SELECT 
    employee_name, 
    MAX(version_number) as total_versions
FROM dim_employee_scd2
GROUP BY employee_name
ORDER BY total_versions DESC
LIMIT 5;

-- 31. Find most frequently changing customers
SELECT 
    customer_name, 
    MAX(version_number) as total_versions
FROM dim_customer_scd2
GROUP BY customer_name
ORDER BY total_versions DESC
LIMIT 5;

-- 32. Build customer history dashboard view
-- CTE to assemble complete picture
WITH CustomerStats AS (
    SELECT 
        customer_id,
        MIN(effective_start_date) as first_version_date,
        MAX(effective_start_date) as latest_version_date,
        MAX(version_number) as total_versions
    FROM dim_customer_scd2
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.customer_name,
    c.city as current_city,
    c.customer_segment as current_segment,
    s.total_versions,
    s.first_version_date,
    s.latest_version_date,
    CASE 
        WHEN s.total_versions = 1 THEN 'Stable'
        WHEN s.total_versions BETWEEN 2 AND 3 THEN 'Occasional Changes'
        ELSE 'Frequent Changes'
    END as change_frequency,
    'Active' as current_status
FROM dim_customer_scd2 c
JOIN CustomerStats s ON c.customer_id = s.customer_id
WHERE c.is_current = TRUE;

-- 33. Build employee history dashboard view
WITH EmployeeStats AS (
    SELECT 
        employee_id,
        MAX(version_number) as total_versions,
        SUM(CASE WHEN department IS DISTINCT FROM LAG(department) OVER(PARTITION BY employee_id ORDER BY version_number) THEN 1 ELSE 0 END) as dept_changes,
        SUM(CASE WHEN salary_band IS DISTINCT FROM LAG(salary_band) OVER(PARTITION BY employee_id ORDER BY version_number) THEN 1 ELSE 0 END) as salary_changes
    FROM dim_employee_scd2
    GROUP BY employee_id
)
SELECT 
    e.employee_id,
    e.employee_name,
    e.department as current_department,
    e.salary_band as current_salary_band,
    s.total_versions,
    COALESCE(s.dept_changes, 0) as department_changes,
    COALESCE(s.salary_changes, 0) as salary_band_changes,
    CASE WHEN s.total_versions > 1 THEN 'Dynamic Role' ELSE 'Stable Role' END as change_frequency
FROM dim_employee_scd2 e
JOIN EmployeeStats s ON e.employee_id = s.employee_id
WHERE e.is_current = TRUE;

-- 34. Build product history dashboard view
WITH ProductChanges AS (
    SELECT 
        product_id,
        version_number,
        CASE WHEN category IS DISTINCT FROM LAG(category) OVER(PARTITION BY product_id ORDER BY version_number) THEN 1 ELSE 0 END as is_cat_change,
        CASE WHEN price_band IS DISTINCT FROM LAG(price_band) OVER(PARTITION BY product_id ORDER BY version_number) THEN 1 ELSE 0 END as is_price_change
    FROM dim_product_scd2
),
ProductStats AS (
    SELECT 
        product_id,
        MAX(version_number) as total_versions,
        SUM(is_cat_change) as cat_changes,
        SUM(is_price_change) as price_changes
    FROM ProductChanges
    GROUP BY product_id
)
SELECT 
    p.product_id,
    p.product_name,
    p.category as current_category,
    p.price_band as current_price_band,
    s.total_versions,
    COALESCE(s.cat_changes, 0) as category_changes,
    COALESCE(s.price_changes, 0) as price_band_changes,
    CASE WHEN s.total_versions > 1 THEN 'Price/Cat Adjusted' ELSE 'Original Spec' END as change_frequency
FROM dim_product_scd2 p
JOIN ProductStats s ON p.product_id = s.product_id
WHERE p.is_current = TRUE;

-- 35. Build SCD monitoring KPI summary using CTE
WITH TotalRecords AS (
    SELECT 'Customer' as entity, COUNT(*) as rows, COUNT(DISTINCT customer_id) as uniques FROM dim_customer_scd2
    UNION ALL
    SELECT 'Employee' as entity, COUNT(*) as rows, COUNT(DISTINCT employee_id) as uniques FROM dim_employee_scd2
    UNION ALL
    SELECT 'Product' as entity, COUNT(*) as rows, COUNT(DISTINCT product_id) as uniques FROM dim_product_scd2
)
SELECT 
    entity,
    rows as total_rows_stored,
    uniques as unique_business_entities,
    (rows - uniques) as historical_versions_kept,
    ROUND((rows::numeric / NULLIF(uniques, 0)), 2) as avg_versions_per_entity
FROM TotalRecords;

-- 36. Detect records with unusual change frequency
-- For example, changing more than 3 times in a year
SELECT 
    customer_id, 
    customer_name, 
    COUNT(*) as versions_in_2023
FROM dim_customer_scd2
WHERE EXTRACT(YEAR FROM effective_start_date) = 2023
GROUP BY customer_id, customer_name
HAVING COUNT(*) > 2;

-- 37. Compare current vs historical analytics
-- DANGERS OF OVERWRITING DATA:
-- If we joined sales to current city vs historical city, numbers change!
WITH HistoricalSales AS (
    SELECT c.city, SUM(f.total_sales_amount) as amount
    FROM fact_sales f
    JOIN dim_customer_scd2 c ON f.customer_sk = c.customer_sk
    GROUP BY c.city
),
CurrentSales AS (
    SELECT current_c.city, SUM(f.total_sales_amount) as amount
    FROM fact_sales f
    JOIN dim_customer_scd2 historical_c ON f.customer_sk = historical_c.customer_sk
    JOIN dim_customer_scd2 current_c ON historical_c.customer_id = current_c.customer_id AND current_c.is_current = TRUE
    GROUP BY current_c.city
)
SELECT 
    h.city,
    h.amount as accurate_historical_sales,
    COALESCE(c.amount, 0) as flawed_current_sales,
    h.amount - COALESCE(c.amount, 0) as difference
FROM HistoricalSales h
LEFT JOIN CurrentSales c ON h.city = c.city
WHERE h.amount != COALESCE(c.amount, 0);

-- 38. Create warehouse recommendations using CASE WHEN
SELECT 
    'Customer Dimension' as dimension,
    MAX(version_number) as max_versions,
    CASE 
        WHEN MAX(version_number) > 5 THEN 'Investigate excessive updates - Review data quality process'
        WHEN MAX(version_number) BETWEEN 2 AND 5 THEN 'Monitor frequently changing dimensions'
        ELSE 'Maintain current process'
    END as recommendation
FROM dim_customer_scd2
UNION ALL
SELECT 
    'Employee Dimension',
    MAX(version_number),
    CASE 
        WHEN MAX(version_number) > 5 THEN 'Investigate excessive updates - Review data quality process'
        WHEN MAX(version_number) BETWEEN 2 AND 5 THEN 'Monitor frequently changing dimensions'
        ELSE 'Maintain current process'
    END
FROM dim_employee_scd2;

-- 39. Calculate historical sales trend by versioned dimensions
-- Showing how sales trend across different states of the product
SELECT 
    p.category,
    TO_CHAR(f.sales_date, 'YYYY-MM') as sales_month,
    SUM(f.total_sales_amount) as total_sales
FROM fact_sales f
JOIN dim_product_scd2 p ON f.product_sk = p.product_sk
GROUP BY p.category, TO_CHAR(f.sales_date, 'YYYY-MM')
ORDER BY sales_month, total_sales DESC;

-- 40. Demonstrate “as of date” historical lookup query
-- If a business user asks: "What did our customer base look like exactly on June 15th, 2023?"
SELECT 
    customer_id, 
    customer_name, 
    city, 
    customer_segment
FROM dim_customer_scd2
WHERE '2023-06-15' BETWEEN effective_start_date AND COALESCE(effective_end_date, '9999-12-31');
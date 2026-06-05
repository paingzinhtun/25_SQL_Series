-- Day 25: End-to-End Data Pipeline
-- data_quality_checks.sql: Pipeline Validation Queries

-- Data Engineers run these checks automatically to ensure pipeline integrity.

-- 1. Check for Duplicate Customers in Staging
-- Why: Ensures the ROW_NUMBER() deduplication logic worked perfectly.
SELECT customer_id, COUNT(*) as record_count
FROM stg_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 2. Check for Missing Dimensions in Fact Table (Orphaned Facts)
-- Why: If a fact table has a NULL customer_sk, it means an order came in for a customer that doesn't exist.
SELECT 'Missing Customer SK' as issue, COUNT(*) as issue_count
FROM fact_sales WHERE customer_sk IS NULL
UNION ALL
SELECT 'Missing Product SK', COUNT(*) 
FROM fact_sales WHERE product_sk IS NULL
UNION ALL
SELECT 'Missing Date SK', COUNT(*) 
FROM fact_sales WHERE date_sk IS NULL;

-- 3. Check for Negative Revenue
-- Why: The staging layer should have cleaned negative quantities. If net_sales_amount is negative, something failed.
SELECT order_item_id, net_sales_amount 
FROM fact_sales 
WHERE net_sales_amount < 0;

-- 4. Check for Unstandardized Categories
-- Why: Validates the INITCAP/TRIM transformations in staging.
SELECT category, COUNT(*)
FROM dim_product
WHERE category != INITCAP(TRIM(category))
GROUP BY category;

-- 5. Row Count Validation (Raw vs Staging vs Fact)
-- Why: Ensures no massive data loss occurred unless intentionally filtered (like CANCELLED orders).
SELECT 'raw_order_items' as table_name, COUNT(*) as total_rows FROM raw_order_items
UNION ALL
SELECT 'stg_order_items', COUNT(*) FROM stg_order_items
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- 6. Check for Valid Dates
-- Why: Validates that messy strings like '12/31/2023' and '2023-12-31' parsed correctly into the date dimension.
SELECT d.year, COUNT(*)
FROM fact_sales f
JOIN dim_date d ON f.date_sk = d.date_sk
WHERE d.year < 2000 OR d.year > 2030
GROUP BY d.year;
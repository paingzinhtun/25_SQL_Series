# Business & Analytics Questions

This document maps the SQL queries written in the analytics layer to real-world business value.

| Business Question | Why It Matters | SQL / Data Engineering Concept |
| :--- | :--- | :--- |
| **What is our total pipeline processed revenue?** | Validates top-line metrics and ensures no data was lost during ingestion. | `SUM()`, Fact Table Aggregation |
| **Are we busier on weekends vs weekdays?** | Drives staffing, inventory, and marketing decisions. | Dimension Joins, `GROUP BY` |
| **Which stores have the lowest performance?** | Identifies underperforming assets that may need to be closed or optimized. | `ORDER BY ASC`, `LIMIT` |
| **What is the revenue contribution percentage of each category?** | Tells executives which products actually drive the business. | `SUM() OVER()`, Window Functions |
| **How many customers are one-time buyers vs repeat?** | Evaluates product-market fit and retention success. | `COUNT(DISTINCT)`, `HAVING` |
| **What is our Month-over-Month (MoM) growth?** | The primary metric investors and executives use to measure company health. | `LAG()`, Date Dimensions |
| **Are there any orphaned facts in our pipeline?** | Data Engineering check: Ensures referential integrity in the Star Schema. | `IS NULL`, Data Quality Checks |
| **How many duplicates existed in the raw data?** | Highlights the necessity of the staging transformation layer. | `ROW_NUMBER()`, Deduplication |
| **Are there products in our catalog that have never sold?** | Identifies stale inventory taking up warehouse space. | `LEFT JOIN ... WHERE NULL` |
| **What is the rolling 3-month average revenue?** | Smooths out volatile monthly spikes to show true trajectory. | `AVG() OVER (ROWS BETWEEN...)` |
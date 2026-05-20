# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all customers with signup dates. | Provides the customer base and acquisition timeline. | `SELECT`, `ORDER BY` |
| List all products by category. | Shows the product catalog structure. | `SELECT`, `ORDER BY` |
| Show completed and paid orders. | Filters to real successful purchases. | `JOIN`, `WHERE` |
| Show detailed order items and line revenue. | Explains how order value is built from items. | `JOIN`, calculated columns |
| Calculate total revenue. | Measures actual sales after filtering invalid orders. | Revenue filtering, `SUM` |
| Calculate average order value. | Shows average revenue per successful order. | CTE, `AVG` |
| Find top customers by spending. | Identifies high-value customers. | CTE, `GROUP BY`, `LIMIT` |
| Find repeat customers. | Shows customer loyalty and purchase habit. | `GROUP BY`, `HAVING` |
| Find one-time customers. | Helps identify customers who may need reactivation. | `GROUP BY`, `HAVING` |
| Find customers with no orders. | Supports activation campaigns. | `LEFT JOIN`, `WHERE IS NULL` |
| Find customers inactive for 60 days. | Supports retention targeting. | CTE, date logic |
| Count orders per customer. | Measures purchase frequency. | `CASE WHEN`, aggregation |
| Calculate quantity purchased per customer. | Shows customer buying volume. | `LEFT JOIN`, `CASE WHEN` |
| Find first purchase date. | Identifies when customers first converted. | `MIN`, grouping |
| Find most recent purchase date. | Measures customer recency. | `MAX`, grouping |
| Calculate days between first and second purchase. | Measures speed of repeat purchase behavior. | CTE, `ROW_NUMBER()` |
| Calculate customer lifetime value basics. | Summarizes total customer value and AOV. | CTE, `NULLIF` |
| Calculate revenue by customer segment. | Shows which segments drive revenue. | `JOIN`, `GROUP BY` |
| Calculate AOV by customer segment. | Compares spending behavior across segments. | CTE, `AVG` |
| Find popular product categories. | Shows what customers buy most. | `GROUP BY`, `SUM` |
| Find top category for each customer. | Supports preference and personalization analysis. | CTE, `ROW_NUMBER()` |
| Calculate monthly revenue trend. | Shows revenue movement over time. | `DATE_TRUNC`, `GROUP BY` |
| Calculate monthly active customers. | Tracks customer activity by month. | `COUNT DISTINCT`, date logic |
| Create customer retention status. | Turns behavior into useful customer labels. | CTE, `CASE WHEN` |
| Rank customers by revenue. | Builds a customer value leaderboard. | `RANK()` |
| Build a Customer 360 view. | Combines behavior, value, preference, and retention in one view. | Multiple CTEs, `COALESCE` |
| Show payment status summary. | Confirms unpaid, refunded, and failed cases exist. | `GROUP BY`, `SUM` |
| Show order status summary. | Confirms completed, cancelled, returned, and pending cases exist. | `GROUP BY`, `COUNT` |

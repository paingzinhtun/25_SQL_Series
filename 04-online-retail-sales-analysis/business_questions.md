# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all customers. | Gives the business a basic customer directory. | `SELECT`, `ORDER BY` |
| List all products with categories and prices. | Helps the business review product catalog and pricing. | `SELECT`, `ORDER BY` |
| Show all orders with customer and store information. | Connects each order to the customer and branch involved. | `JOIN` |
| Show detailed order items with product names and line revenue. | Shows what was sold inside each order and how line revenue is calculated. | `JOIN`, calculated columns |
| Calculate total revenue from completed and paid orders. | Gives the core revenue KPI while excluding invalid revenue. | `WHERE`, `SUM`, revenue logic |
| Calculate daily sales revenue. | Helps track day-by-day sales performance. | `GROUP BY`, date filtering |
| Calculate monthly sales revenue. | Helps understand sales trends by month. | `DATE_TRUNC`, `GROUP BY` |
| Find top 5 best-selling products by quantity. | Shows which products customers buy most often. | `GROUP BY`, `SUM`, `LIMIT` |
| Find top 5 products by revenue. | Shows which products contribute the most money. | `GROUP BY`, calculated revenue |
| Find revenue by product category. | Helps identify the strongest product categories. | `GROUP BY`, aggregation |
| Find revenue by store or branch. | Shows branch performance and location strength. | `JOIN`, `GROUP BY` |
| Find top 5 customers by total spending. | Helps identify valuable customers. | `JOIN`, `SUM`, `LIMIT` |
| Count orders by order status. | Shows the operational mix of completed, cancelled, and pending orders. | `GROUP BY`, `COUNT` |
| Count payments by payment status. | Helps monitor paid, unpaid, and refunded payments. | `GROUP BY`, `SUM` |
| Calculate average order value. | Shows how much customers spend per completed paid order on average. | CTE, `AVG` |
| Find repeat customers. | Helps identify customers who return and buy again. | `GROUP BY`, `HAVING` |
| Find cancelled orders and their payment status. | Helps review cancelled orders and whether refunds or unpaid payments exist. | `LEFT JOIN`, `WHERE` |
| Rank stores by total revenue. | Shows which branches generate the most revenue. | CTE, `RANK()` |

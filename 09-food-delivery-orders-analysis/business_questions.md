# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all customers. | Provides the base customer reference list. | `SELECT`, `ORDER BY` |
| List all restaurants with cuisine type and city. | Helps understand the restaurant network. | `SELECT`, `ORDER BY` |
| List all menu items with restaurant names. | Shows what each restaurant sells. | `JOIN` |
| Show all orders with customer, restaurant, partner, and payment status. | Gives a complete operational view of each order. | Multiple joins, `LEFT JOIN`, `COALESCE` |
| Show detailed order items with line revenue. | Explains how item-level transactions create order value. | `JOIN`, calculated columns |
| Calculate total revenue from delivered and paid orders. | Measures real completed revenue. | `WHERE`, revenue filtering |
| Calculate revenue by restaurant. | Identifies which restaurants generate the most money. | CTE, `GROUP BY`, `SUM` |
| Calculate revenue by cuisine type. | Shows which cuisine categories perform best. | `JOIN`, `GROUP BY` |
| Find top restaurants by order count. | Measures restaurant demand. | `LEFT JOIN`, `COUNT`, `LIMIT` |
| Find top restaurants by revenue. | Measures restaurant financial performance. | CTE, `ROW_NUMBER`, window function |
| Find top customers by total spending. | Helps identify valuable customers. | CTE, `SUM`, `LIMIT` |
| Find repeat customers. | Shows customer retention and repeated usage. | `GROUP BY`, `HAVING` |
| Count orders by order status. | Tracks the order lifecycle. | `GROUP BY`, `COUNT` |
| Count payments by payment status. | Helps monitor unpaid, refunded, and failed payments. | `GROUP BY`, `SUM` |
| Find cancelled orders. | Helps investigate lost orders and customer issues. | `WHERE`, joins |
| Calculate average delivery time. | Measures delivery speed for completed orders. | Date/time calculation, `AVG` |
| Find delayed deliveries over 45 minutes. | Helps identify operational service problems. | CTE, date/time calculation |
| Rank delivery partners by completed deliveries. | Shows partner productivity. | `RANK()`, window function |
| Calculate average delivery rating by partner. | Measures service quality. | `LEFT JOIN`, `AVG` |
| Calculate average food rating by restaurant. | Measures restaurant quality from customer feedback. | `LEFT JOIN`, `AVG` |
| Find popular food categories by quantity sold. | Supports menu and category planning. | `GROUP BY`, `SUM` |
| Calculate daily order volume. | Shows daily demand trends. | Date grouping |
| Calculate monthly revenue trend. | Tracks business performance over time. | `DATE_TRUNC`, `GROUP BY` |
| Find restaurants with no orders. | Detects inactive or newly onboarded restaurants. | `LEFT JOIN`, `WHERE IS NULL` |
| Find customers with no orders. | Finds customers who may need activation. | `LEFT JOIN`, `WHERE IS NULL` |
| Create an operational KPI summary. | Converts order data into high-level business metrics. | CTE, `CASE WHEN`, `NULLIF` |
| Find delivery partners with no completed deliveries. | Helps identify inactive or unavailable delivery partners. | `LEFT JOIN`, `HAVING` |

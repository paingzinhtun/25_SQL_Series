# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all riders. | Shows the customer base of the platform. | `SELECT`, `ORDER BY` |
| List drivers with vehicle information. | Connects driver supply with vehicle capacity. | `LEFT JOIN` |
| List locations by city and type. | Helps understand pickup and dropoff coverage. | `SELECT`, `ORDER BY` |
| Show all trips with rider, driver, route, and payment status. | Gives an operational view of trip lifecycle and payment result. | Multiple `JOIN`s |
| Show completed and paid trips. | Filters to successful trips only. | `WHERE`, revenue filtering |
| Calculate total revenue. | Measures actual money earned by the platform. | CTE, `SUM` |
| Calculate average fare. | Shows average revenue per successful trip. | `AVG`, `ROUND` |
| Calculate average trip distance. | Helps understand trip length and service usage. | `AVG`, completed-trip filtering |
| Calculate average trip duration. | Helps monitor ride time and operational efficiency. | `AVG`, completed-trip filtering |
| Find top riders by completed trips. | Identifies frequent riders and loyal customers. | CTE, `RANK()` |
| Find top drivers by completed trips. | Identifies productive drivers. | CTE, `RANK()` |
| Find top drivers by revenue. | Shows which drivers generate the most paid trip value. | CTE, `GROUP BY`, `SUM` |
| Find riders with no completed trips. | Helps find riders who may need activation or support. | `LEFT JOIN`, `WHERE IS NULL` |
| Find drivers with no completed trips. | Helps identify inactive supply or onboarding issues. | `LEFT JOIN`, `WHERE IS NULL` |
| Count trips by status. | Shows the trip lifecycle mix. | `GROUP BY`, `COUNT` |
| Count payments by status. | Confirms paid, unpaid, refunded, and failed payment cases. | `GROUP BY`, `SUM` |
| Count cancellations by cancelled_by. | Shows whether riders, drivers, or system issues cause cancellations. | `GROUP BY`, `COALESCE` |
| Find common cancellation reasons. | Helps operations teams fix recurring problems. | `GROUP BY`, `ORDER BY` |
| Calculate cancellation rate. | Measures reliability of the marketplace. | CTE, `FILTER`, `NULLIF` |
| Find peak booking hours. | Helps match driver supply with demand. | `EXTRACT`, CTE, `RANK()` |
| Calculate daily trip volume. | Shows day-by-day demand. | Date casting, `FILTER` |
| Calculate monthly revenue trend. | Shows revenue movement over time. | `DATE_TRUNC`, CTE |
| Find top pickup locations. | Shows where trip demand starts. | `JOIN`, `GROUP BY`, `LIMIT` |
| Find top dropoff locations. | Shows where riders commonly travel. | `JOIN`, `GROUP BY`, `LIMIT` |
| Find most common routes. | Helps understand repeat travel patterns. | Self-style location joins, `GROUP BY` |
| Calculate average driver rating. | Measures service quality by driver. | `LEFT JOIN`, `AVG` |
| Calculate average rider rating. | Shows rider quality or behavior patterns. | `LEFT JOIN`, `AVG` |
| Find drivers with low ratings. | Helps identify drivers who may need training or review. | `HAVING` |
| Rank drivers by completed trips. | Builds a driver performance leaderboard. | CTE, `DENSE_RANK()` |
| Create an operational KPI summary. | Combines revenue, cancellation, open trips, and ratings into one dashboard-style output. | Multiple CTEs, `CASE WHEN` |

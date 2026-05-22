# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all users. | Shows the customer base and signup history. | `SELECT`, `ORDER BY` |
| List all subscription plans. | Explains the plan catalog and pricing model. | `SELECT`, `ORDER BY` |
| Show subscriptions with user and plan details. | Connects customers to subscription periods and plans. | `JOIN` |
| Show active subscriptions. | Identifies current paying or service-eligible customers. | `WHERE`, `JOIN` |
| Count active subscribers. | Measures current subscriber base. | `COUNT DISTINCT`, `WHERE` |
| Count subscriptions by status. | Shows lifecycle mix across active, cancelled, expired, trial, and paused. | `GROUP BY`, `COUNT` |
| Count active users by plan tier. | Shows which plan tiers currently have active customers. | `JOIN`, `GROUP BY` |
| Calculate total paid revenue. | Measures actual collected revenue. | `SUM`, revenue filtering |
| Calculate revenue by plan. | Shows which plans generate the most money. | `JOIN`, `GROUP BY` |
| Calculate revenue by plan tier. | Helps compare basic, standard, premium, family, and business tiers. | `GROUP BY`, aggregation |
| Calculate MRR approximation. | Estimates monthly recurring revenue from active subscriptions. | `JOIN`, `SUM`, business logic |
| Calculate ARPU. | Measures average revenue per paying user. | CTE, `NULLIF` |
| Find top users by paid amount. | Identifies high-value customers. | CTE, `RANK()` |
| Find users with failed payments. | Helps billing and customer support teams follow up. | `JOIN`, `WHERE` |
| Find users with no paid payment. | Finds trial or payment-blocked users. | CTE, `LEFT JOIN` |
| Show cancelled subscriptions with reasons. | Explains who churned and why. | `JOIN` |
| Count cancellations by reason. | Finds recurring churn drivers. | `GROUP BY`, `COUNT` |
| Calculate churn rate. | Measures subscription loss as a percentage of all subscription records. | CTE, `FILTER`, `NULLIF` |
| Find plans with highest cancellation count. | Shows which plans lose the most subscribers. | `WHERE`, `GROUP BY` |
| Find plan cancellation rate. | Compares cancellation risk across plans fairly. | `FILTER`, `NULLIF` |
| Find renewed users. | Identifies customers with more than one subscription period. | `GROUP BY`, `HAVING` |
| Find long-term subscribers. | Shows customers who stayed for a long time. | Date arithmetic, `COALESCE` |
| Calculate average subscription duration by plan. | Compares plan stickiness. | `AVG`, date logic |
| Calculate monthly new subscriptions. | Shows acquisition trend over time. | `DATE_TRUNC`, `GROUP BY` |
| Calculate monthly cancellations. | Shows churn trend over time. | `DATE_TRUNC`, `GROUP BY` |
| Analyze usage activity by user. | Connects product engagement to retention. | `LEFT JOIN`, `SUM`, `MAX` |
| Find high-usage users. | Identifies engaged customers. | `HAVING`, aggregation |
| Find low-usage active users at risk. | Finds active subscribers who may churn soon. | CTE, `COALESCE`, date logic |
| Find users with no recent usage. | Supports reactivation and retention campaigns. | `HAVING`, date logic |
| Create a subscription health summary. | Produces dashboard-style health metrics. | Multiple CTEs, `CASE WHEN` |
| Build a Subscriber 360 view. | Combines plan, revenue, usage, renewal, cancellation, and health status. | Multiple CTEs, `ROW_NUMBER()` |

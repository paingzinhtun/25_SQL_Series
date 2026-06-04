# KPI & Business Questions Mapping

| KPI / Business Question | Why It Matters | SQL / BI Concept |
| :--- | :--- | :--- |
| **Calculate total revenue.** | The lifeblood of the business, top-line performance. | `SUM()`, Aggregation |
| **Calculate total profit.** | Bottom-line performance, indicates true business health. | `JOIN`, `SUM()` |
| **Calculate average order value (AOV).** | Indicates customer purchasing power and checkout behavior. | Division, `COUNT(DISTINCT)` |
| **Calculate monthly revenue trend.** | Helps monitor growth or seasonal dips over time. | `GROUP BY`, Date functions |
| **Calculate revenue growth rate.** | Identifies the momentum of business scaling month-over-month. | `LAG()`, Window Functions |
| **Compare target vs actual revenue.** | Evaluates whether the business is hitting executive goals. | `LEFT JOIN`, `COALESCE` |
| **Rank regions by revenue.** | Directs resource allocation and expansion strategies. | `RANK()`, `DENSE_RANK()` |
| **Find low-performing products.** | Pinpoints inventory that may need discounting or removal. | `ORDER BY ASC`, `LIMIT` |
| **Calculate profit margin by category.** | Indicates which types of items are actually worth selling. | `NULLIF`, Math operations |
| **Calculate customer retention rate.** | It is cheaper to keep existing customers than acquire new ones. | `CASE WHEN`, Ratios |
| **Calculate customer churn rate.** | High churn means poor product fit or customer service. | `CASE WHEN`, Math logic |
| **Find repeat customers.** | Identifies the most loyal segment of the user base. | `HAVING COUNT > 1` |
| **Calculate customer lifetime value.** | Shows long-term value generated per customer. | `SUM()`, `GROUP BY` |
| **Compare online vs offline sales.** | Dictates real estate vs e-commerce investments. | `CASE WHEN` bucketing |
| **Calculate campaign ROI.** | Identifies if marketing spend is generating positive returns. | Business Formula, `JOIN` |
| **Calculate customer growth trend.** | Evaluates adoption velocity over time. | Cumulative `SUM() OVER()` |
| **Detect seasonal business trends.** | Prepares supply chain and hiring for peak seasons. | Date extraction, `GROUP BY` |
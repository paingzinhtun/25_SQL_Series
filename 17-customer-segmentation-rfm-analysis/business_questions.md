# Business Questions - Customer Segmentation with RFM Analysis

This file connects each business question with why it matters and the SQL concept practiced.

| Business Question | Why It Matters | SQL Concept |
|---|---|---|
| Who are all customers? | Provides the customer base for segmentation. | `SELECT`, `ORDER BY` |
| Which orders are completed and paid? | Ensures analysis uses real customer value, not failed or cancelled activity. | `JOIN`, `WHERE` |
| What revenue came from each order item? | Shows how order-level value is built from product lines. | Calculated columns |
| What is total completed paid revenue? | Gives the business a reliable revenue number. | CTE, `SUM` |
| How much revenue did each customer generate? | Identifies high-value customers. | `GROUP BY`, aggregation |
| How often does each customer purchase? | Measures frequency for RFM analysis. | `COUNT`, `GROUP BY` |
| When was each customer’s last purchase? | Measures recency for retention targeting. | `MAX`, date logic |
| How many days since the last purchase? | Finds recent and inactive customers using a fixed analysis date. | Date subtraction |
| What is each customer’s monetary value? | Measures spending value for segmentation. | CTE, `SUM` |
| What is the base RFM table? | Combines recency, frequency, and monetary value in one view. | CTE |
| What is each customer’s recency score? | Gives recent customers a higher score. | `NTILE`, window function |
| What is each customer’s frequency score? | Gives frequent buyers a higher score. | `NTILE` |
| What is each customer’s monetary score? | Gives high-spending customers a higher score. | `NTILE` |
| What is the combined RFM score? | Creates a compact score for ranking customers. | String concatenation |
| Which segment does each customer belong to? | Turns numeric scores into business-friendly groups. | `CASE WHEN` |
| How many customers are in each segment? | Shows the size of each marketing audience. | `GROUP BY`, `COUNT` |
| How much revenue comes from each segment? | Shows which segments drive the most value. | Segmented aggregation |
| What is average order value by segment? | Compares spending behavior across customer groups. | `AVG`, CTE |
| Who are champion customers? | Identifies customers who deserve VIP treatment. | RFM filtering |
| Who are loyal customers? | Identifies repeat buyers for loyalty offers. | RFM filtering |
| Who are potential loyalists? | Finds customers who may become loyal with nurturing. | RFM filtering |
| Which customers are at risk? | Finds valuable customers who have not purchased recently. | RFM filtering |
| Which customers are lost? | Finds customers with very old and low activity. | Date threshold, filtering |
| Who are one-time buyers? | Finds customers who may need a second-purchase campaign. | `HAVING` |
| Which customers have no completed paid orders? | Separates non-buyers from real customers in RFM analysis. | `LEFT JOIN`, filtered `COUNT` |
| Which customers are inactive? | Finds customers for reactivation campaigns. | Recency threshold |
| Who are the top customers by monetary value? | Supports VIP and customer value analysis. | `RANK`, `LIMIT` |
| Who are the top customers by frequency? | Identifies repeat buyers. | Window ranking |
| Who has the best combined RFM score? | Prioritizes strongest customers overall. | `DENSE_RANK` |
| What category does each customer prefer? | Supports personalized recommendations. | `ROW_NUMBER`, category ranking |
| What should a Customer 360 RFM view include? | Combines customer profile, RFM metrics, segment, preference, and action. | CTE, `COALESCE`, `CASE WHEN` |
| What marketing action fits each segment? | Connects segmentation to practical business decisions. | `CASE WHEN` |

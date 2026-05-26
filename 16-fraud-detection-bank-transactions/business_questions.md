# Business Questions - Fraud Detection with Bank Transactions

This file connects each risk-monitoring question with the business reason and SQL concept practiced.

| Risk Monitoring Question | Why It Matters | SQL Concept |
|---|---|---|
| Who are all customers in the system? | Provides the customer reference table for account and transaction monitoring. | `SELECT`, `ORDER BY` |
| Which accounts belong to which customers? | Helps connect transaction activity back to real customer records. | `JOIN`, foreign keys |
| Which cards belong to which accounts and customers? | Supports card-level monitoring without exposing real card numbers. | Multi-table `JOIN` |
| What details are available for each transaction? | Gives analysts a full transaction view with customer, account, card, and merchant context. | Multi-table `JOIN` |
| How many transactions are successful, failed, declined, or pending? | Helps monitor transaction quality and operational issues. | `GROUP BY`, `COUNT` |
| Which transaction channels are used most? | Shows whether activity mainly happens through ATM, POS, online, mobile app, or branch. | `GROUP BY`, `ORDER BY` |
| Which transaction types are most common? | Helps identify whether purchases, withdrawals, transfers, or bill payments dominate activity. | Aggregation |
| What is the total transaction amount by customer? | Helps identify customers with high attempted transaction activity. | `SUM`, `GROUP BY` |
| Which transactions are unusually large? | High-value transactions may need manual review. | `WHERE`, threshold filtering |
| Which transactions failed or were declined? | Failed and declined activity can indicate operational issues or suspicious patterns. | `WHERE IN` |
| Which accounts have many failed or declined transactions? | Repeated failure patterns can help prioritize review. | `GROUP BY`, `HAVING` |
| Which cards have repeated declined transactions? | Card-level decline patterns can indicate a card issue or a suspicious pattern. | `JOIN`, `HAVING` |
| Which transactions happened outside normal hours? | Late-night activity can be useful for risk monitoring. | `EXTRACT(HOUR)` |
| Which accounts had rapid transactions within minutes? | Rapid activity may indicate unusual transaction behavior. | `LAG`, window function |
| Which customers used multiple cities on the same day? | Multiple city activity can be useful for location-based review. | `COUNT(DISTINCT)`, `HAVING` |
| Which customers used multiple countries within 24 hours? | Close-together cross-country activity can be reviewed by risk teams. | `LAG`, time comparison |
| Which transactions happened away from the customer home city? | Different city activity can be normal, but it is useful for context. | `JOIN`, comparison filter |
| Which transactions were sudden amount spikes? | Large changes from normal behavior can be useful review signals. | Window `AVG`, CTE |
| Which merchants have high failed or declined activity? | Helps identify merchant, channel, or payment processing issues. | Filtered `COUNT`, `NULLIF` |
| Which merchant categories receive the most flags? | Shows where review activity is concentrated. | `JOIN`, aggregation |
| Which transactions were flagged and why? | Gives analysts a readable review queue. | `JOIN`, status reporting |
| Which rules generate the most flags? | Helps review whether rules are useful or too noisy. | `LEFT JOIN`, `COUNT` |
| What is the review status of flagged transactions? | Helps track pending, cleared, escalated, and confirmed issue review work. | `GROUP BY` |
| What is the flag rate by channel? | Shows which channels have higher review activity. | `COUNT(DISTINCT)`, `NULLIF` |
| What is the flag rate by transaction type? | Shows which transaction types have higher review activity. | Aggregation, rate calculation |
| What is the risk score per transaction? | Combines rule scores into a simple transaction-level review score. | CTE, `CASE WHEN` |
| What is the total risk score per customer? | Helps prioritize customers for manual review. | CTE, `RANK` |
| Which customers have high total risk score? | Creates a focused review list for risk teams. | CTE, threshold filtering |
| What review reason applies to each transaction? | Shows how rule-based logic can be explained with SQL. | `CASE WHEN` |
| Which customers should be prioritized for review? | Combines flags, scores, and activity into a review priority. | CTE, window ranking |
| What should a fraud monitoring dashboard show? | Produces a transaction-level dashboard-ready output for review. | CTE, `COALESCE`, `CASE WHEN` |

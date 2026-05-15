# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all customers. | Gives the bank a simple customer directory. | `SELECT`, `ORDER BY` |
| List all accounts with customer and branch information. | Shows who owns each account and where it is managed. | `JOIN` |
| Show all successful transactions. | Shows completed financial activity. | `WHERE`, `JOIN` |
| Show failed and pending transactions. | Helps operations review transactions that did not complete. | `WHERE`, status filtering |
| Calculate total deposits. | Measures total completed incoming money through deposits. | `SUM`, `WHERE` |
| Calculate total withdrawals. | Measures total completed outgoing money through withdrawals. | `SUM`, `WHERE` |
| Calculate net money movement per account. | Shows whether completed transactions increased or decreased each account. | CTE, `CASE WHEN`, `GROUP BY` |
| Show current balance for each account. | Gives a balance report for account review. | `JOIN`, `ORDER BY` |
| Find top 5 accounts by current balance. | Identifies high-balance accounts. | CTE, `ROW_NUMBER()` |
| Find total customer balance by branch. | Shows which branches hold the most customer balance. | `LEFT JOIN`, `SUM`, `GROUP BY` |
| Count accounts by account type. | Helps understand the mix of savings, current, and business accounts. | `GROUP BY`, `COUNT` |
| Count accounts by account status. | Shows active, frozen, and closed account counts. | `GROUP BY`, `COUNT` |
| Find customers with more than one account. | Identifies customers with deeper banking relationships. | `GROUP BY`, `HAVING` |
| Find customers with the highest number of transactions. | Shows the most active customers. | `JOIN`, `COUNT`, `GROUP BY` |
| Find large transactions above a threshold. | Helps detect transactions that may need review. | `WHERE`, filtering |
| Calculate daily transaction volume. | Helps monitor daily transaction activity. | `DATE_TRUNC`, `GROUP BY` |
| Calculate running balance per account. | Shows how balances change over time using transaction logic. | CTE, `CASE WHEN`, `SUM OVER` |
| Show transaction summary by transaction type and status. | Gives an operational view of transaction mix and completion status. | `GROUP BY`, aggregation |

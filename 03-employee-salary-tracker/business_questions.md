# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all employees with department and job role. | Helps HR see the company structure in one readable report. | `JOIN` |
| Show all active employees. | Helps the company focus on the current workforce. | `WHERE`, `JOIN` |
| Show employees by employment status. | Gives a quick view of active, resigned, and probation employees. | `GROUP BY`, `COUNT` |
| Count employees per department. | Shows department size and workforce distribution. | `LEFT JOIN`, `GROUP BY` |
| Calculate total monthly salary cost by department. | Helps management understand payroll cost by department. | `LEFT JOIN`, `SUM`, `GROUP BY` |
| Calculate average salary by department. | Helps compare compensation levels across departments. | `AVG`, `GROUP BY`, `HAVING` |
| Find the top 5 highest-paid employees. | Shows the highest individual salary costs. | `ORDER BY`, `LIMIT`, `JOIN` |
| Find employees without current salary records. | Helps HR find missing payroll data before processing salary. | `LEFT JOIN`, `WHERE IS NULL` |
| Show salary history for each employee. | Provides a record of salary changes over time. | `JOIN`, historical data |
| Find employees who received salary increases. | Helps identify employees with positive salary movement. | `WHERE`, comparison operators |
| Calculate salary increase amount and percentage. | Shows the size of salary changes in business terms. | Calculated columns, `NULLIF`, `ROUND` |
| Rank departments by payroll cost. | Helps identify departments with the highest salary cost. | CTE, `RANK()`, `SUM` |
| Find job roles with the highest average salary. | Helps understand which roles cost the most on average. | `GROUP BY`, `AVG`, `HAVING` |
| Group employees into salary bands. | Turns detailed salaries into easier business categories. | `CASE WHEN`, `LEFT JOIN` |
| Show company payroll summary. | Gives a high-level view of payroll and missing salary records. | Aggregation, `LEFT JOIN`, `COALESCE` |

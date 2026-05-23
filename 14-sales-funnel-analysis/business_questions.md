# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List leads with source and assigned sales rep. | Gives a complete view of lead ownership and origin. | `JOIN`, `ORDER BY` |
| List funnel stages in order. | Shows the structure of the sales process. | `SELECT`, `ORDER BY` |
| Show lead stage history. | Tracks how leads move through the funnel over time. | Multiple `JOIN`s |
| Count leads by status. | Shows current lead quality and lifecycle distribution. | `GROUP BY`, `COUNT` |
| Count leads by source. | Measures marketing source volume. | `LEFT JOIN`, `GROUP BY` |
| Count leads by city. | Shows geographic demand. | `GROUP BY` |
| Count leads assigned to each rep. | Helps balance sales workload. | `LEFT JOIN`, aggregation |
| Count leads at each latest stage. | Shows current funnel position. | CTE, `ROW_NUMBER()` |
| Calculate lead-created to qualified conversion. | Measures lead qualification effectiveness. | CTE, `FILTER`, `NULLIF` |
| Calculate qualified to opportunity conversion. | Shows how many qualified leads become pipeline. | CTE, conversion formula |
| Calculate opportunity to closed-won conversion. | Measures movement from pipeline to customer. | CTE, conversion formula |
| Calculate overall lead-to-customer conversion. | Shows total funnel effectiveness. | `LEFT JOIN`, `COUNT DISTINCT` |
| Find drop-off count by stage. | Shows where leads are lost between stages. | CTE, `LEAD()` |
| Find drop-off rate by stage. | Compares stage losses as percentages. | CTE, `LEAD()`, `NULLIF` |
| Calculate average time in each stage. | Helps identify slow stages in the sales process. | Date arithmetic, `AVG` |
| Find sources with highest conversion rate. | Finds sources that produce real customers, not only leads. | `LEFT JOIN`, conversion formula |
| Find sources with highest won revenue. | Shows which sources produce business value. | `SUM`, `FILTER` |
| Find reps with highest win count. | Identifies strong closers. | Window function, `RANK()` |
| Find reps with highest won revenue. | Shows revenue contribution by rep. | `SUM`, `GROUP BY` |
| Find reps with highest average deal value. | Shows who closes larger deals. | `AVG`, `FILTER` |
| Calculate win rate by sales rep. | Compares rep performance fairly. | `NULLIF`, win-rate formula |
| Calculate win rate by source. | Shows which sources produce winnable deals. | `LEFT JOIN`, win-rate formula |
| Find top value opportunities. | Helps prioritize large pipeline opportunities. | `RANK()`, `LIMIT` |
| Calculate open pipeline value. | Shows expected future sales opportunity. | `SUM`, `WHERE` |
| Calculate weighted pipeline value. | Discounts pipeline by probability. | Calculated aggregation |
| Calculate monthly lead generation trend. | Shows lead growth over time. | `DATE_TRUNC`, `GROUP BY` |
| Calculate monthly won revenue trend. | Shows closed revenue over time. | `DATE_TRUNC`, `SUM` |
| Find common loss reasons. | Helps improve pricing, fit, and follow-up process. | `GROUP BY`, `COUNT` |
| Find high-value lost deals. | Highlights painful lost opportunities. | `WHERE`, `ORDER BY` |
| Find leads that never moved past contacted. | Identifies follow-up or qualification issues. | CTE, `ROW_NUMBER()` |
| Create sales funnel KPI summary. | Combines funnel and revenue KPIs in one dashboard-style result. | Multiple CTEs, `CASE`/formulas |
| Build a Lead 360 view. | Combines source, rep, stage, opportunity, and deal details per lead. | Multiple `LEFT JOIN`s, CTE |

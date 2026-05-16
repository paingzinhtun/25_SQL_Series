# Analytical Questions

| Analytical Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all countries and populations. | Provides the base reference data for population-based analysis. | `SELECT`, `ORDER BY` |
| Show daily COVID stats with country names. | Makes the daily time-series data readable. | `JOIN` |
| Calculate total cases by country. | Shows cumulative case burden by country. | CTE, latest-date logic |
| Calculate total deaths by country. | Shows cumulative deaths by country. | CTE, latest-date logic |
| Calculate active cases by country. | Helps identify current pressure on public health systems. | CTE, latest-date logic |
| Find countries with the highest total cases. | Supports country comparison. | `GROUP BY`, `MAX` |
| Find countries with the highest total deaths. | Supports severity comparison. | `GROUP BY`, `MAX` |
| Calculate death rate by country. | Helps compare deaths relative to cases. | `NULLIF`, calculated rates |
| Calculate recovery rate by country. | Helps compare recovery progress. | `NULLIF`, calculated rates |
| Calculate cases per 100,000 population. | Normalizes cases by population size. | `NULLIF`, rate per population |
| Show daily new cases trend for each country. | Shows how cases change day by day. | `ORDER BY`, time-series analysis |
| Show monthly new cases trend. | Summarizes daily data into monthly reporting. | `DATE_TRUNC`, `GROUP BY` |
| Calculate 7-day moving average of new cases. | Smooths daily noise to show a clearer trend. | `AVG OVER`, window function |
| Calculate day-over-day change in new cases. | Shows whether daily new cases increased or decreased. | `LAG`, window function |
| Calculate daily growth rate. | Measures percentage growth compared with the previous day. | CTE, `LAG`, `NULLIF` |
| Rank countries by latest total cases. | Creates a clear country ranking. | CTE, `RANK()` |
| Find countries where cases are increasing in the latest period. | Helps identify countries with worsening recent trends. | CTE, `ROW_NUMBER`, `CASE WHEN` |
| Compare vaccination progress by country. | Shows vaccination scale across countries. | CTE, latest-date logic |
| Calculate percentage of population fully vaccinated. | Normalizes vaccination progress by population. | `NULLIF`, calculated percentage |
| Find countries with missing vaccination records. | Helps detect data quality gaps. | `LEFT JOIN`, `WHERE IS NULL` |
| Create a public health summary. | Converts numbers into easier status labels. | `CASE WHEN` |
| Calculate cumulative new cases. | Shows how daily counts accumulate over time. | `SUM OVER`, window function |

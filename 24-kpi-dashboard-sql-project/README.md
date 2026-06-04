# Day 24 — KPI Dashboard Engineering Using SQL

## Project Overview
This project focuses on the crucial link between raw data and business intelligence tools. Before data is visualized in tools like Power BI or Tableau, it needs to be modeled into a clean, calculated "analytics layer". This project builds an advanced dashboard-ready SQL architecture for a fictional retail and e-commerce business.

## Business Problem
A retail business wants to implement executive reporting. They have a raw database but need clean KPI calculations for revenue, profit, growth, retention, and campaign ROI. BI tools perform poorly or become unmanageable if they are forced to do all the heavy lifting. The business requires pre-calculated SQL views to ensure the dashboards are fast, scalable, and consistent.

## What Is a KPI?
A KPI (Key Performance Indicator) is a measurable value that demonstrates how effectively a company is achieving key business objectives.
- Example Metric: Total Sales
- Example KPI: Year-over-Year Revenue Growth Rate

## Why Businesses Need Dashboards
Dashboards centralize truth. They take complex, massive datasets and summarize them into visual executive summaries so leaders can make rapid, informed decisions. 

## Analytics Layer Explanation
The analytics layer sits between the raw database and the BI tool. Instead of connecting Power BI directly to thousands of messy transactional tables, Data Engineers build SQL Views (the analytics layer). This ensures:
1. **Consistency:** Revenue is calculated the same way everywhere.
2. **Performance:** The BI tool doesn't have to compute complex joins on the fly.
3. **Security:** Sensitive PII can be filtered out in the view.

## Dashboard View Explanations
This project includes 8 pre-built SQL views that simulate the exact tables a BI developer would import:
1. `executive_kpi_dashboard`: High-level metrics.
2. `sales_performance_dashboard`: Channel and store breakdowns.
3. `customer_analytics_dashboard`: Segments and Lifetime Value.
4. `product_performance_dashboard`: Margins and top products.
5. `regional_performance_dashboard`: Geographic mapping data.
6. `marketing_campaign_dashboard`: ROI and cost analysis.
7. `retention_churn_dashboard`: Active vs churned ratios.
8. `monthly_trend_dashboard`: Targets vs Actuals over time.

## KPI Formula Explanations
- **Revenue:** `SUM(total_sales_amount)` where status = completed.
- **Profit Margin:** `profit_amount / total_sales_amount`
- **ROI:** `(Revenue Generated - Campaign Cost) / Campaign Cost`
- **Retention Rate:** `Active Customers / Total Customers`
- **Growth Rate:** `(Current - Previous) / Previous`

## Executive Reporting Logic
Executive reporting requires stripping away the noise. Queries use `CTE`s and aggregate functions to roll up thousands of transactions into single readable numbers like "Total Monthly Profit".

## Trend Analysis Logic
Window functions like `LAG()` are essential for trend analysis. They allow us to compare a current row (e.g., this month's revenue) to a previous row (last month's revenue) to calculate momentum.

## Retention & Churn Logic
A churned customer is explicitly tracked with a status flag or calculated based on the recency of orders. A simple retention rate is derived from active versus total volume: `SUM(active)/COUNT(total)`.

## Campaign ROI Logic
Return on Investment compares the generated revenue of customers touched by a campaign versus the fixed cost. Formula: `(Revenue - Cost) / Cost`.

## BI Tool Integration Thinking
By designing flat, aggregated views (like the `monthly_trend_dashboard` view), we allow BI tools to simply SELECT * and render a line chart immediately, without requiring the BI tool to execute a 5-table JOIN.

## SQL Concepts Practiced
- Designing robust `VIEW`s
- Advanced `JOIN`s and `LEFT JOIN`s
- Subqueries and Common Table Expressions (`CTE`s)
- Window functions (`LAG`, `RANK`, `DENSE_RANK`, `SUM OVER`)
- Math operations and division by zero protection (`NULLIF`)
- Date aggregation (`TO_CHAR`, `EXTRACT`)

## BI & Analytics Engineering Concepts Practiced
- Business requirements mapping
- Centralizing metrics calculation
- Isolating the analytics layer from raw data
- Flattening data for BI Tool consumption
- Star-schema thinking for view projection

## Business Questions Answered
See `business_questions.md` for the full mapping of business requirements to SQL logic.

## Files in This Project
- `schema.sql`: Table creation for the retail analytics model.
- `insert_data.sql`: PL/pgSQL bulk insert scripts to simulate thousands of rows of real business data.
- `dashboard_views.sql`: 8 BI-ready reporting views.
- `analysis_queries.sql`: 40 advanced business queries explaining KPI logic.
- `business_questions.md`: KPI and strategy documentation.
- `README.md`: This file.

## Key Lessons
Data analysis is not just about writing queries; it's about engineering solutions that other people can use. By building an analytics layer, you ensure that the entire company operates on the same mathematical logic, making the business truly data-driven.

## How to Run This Project
Run the files in PostgreSQL in this exact order:
1. `schema.sql`
2. `insert_data.sql`
3. `dashboard_views.sql`
4. `analysis_queries.sql`

---

## LinkedIn Reflection Draft

Day 24/25 — SQL for Real Business Data Systems

Today I built a KPI Dashboard Engineering project using SQL.

This project helped me understand how businesses prepare data for dashboards and executive reporting.

A BI dashboard is not only about charts.

Behind every dashboard:
- KPIs must be calculated correctly
- business logic must be standardized
- trends must be reliable
- metrics must be reusable
- analytics layers must be clean

For this project, I created:
- dashboard-ready SQL views
- KPI calculations
- trend analysis logic
- retention and churn analysis
- campaign ROI analysis
- customer analytics dashboards
- product performance dashboards
- regional performance dashboards
- executive KPI summaries

Then I wrote SQL queries to analyze:
- revenue
- profit
- growth
- target achievement
- retention
- churn
- customer lifetime value
- campaign ROI
- seasonal trends
- business performance KPIs

SQL and BI concepts I practiced:
- dashboard engineering
- KPI logic
- analytics layers
- reusable SQL views
- CTEs
- window functions
- growth analysis
- retention analysis
- BI reporting thinking

My key lesson:
Dashboards are only as good as the underlying analytics logic.

Good SQL design makes business reporting consistent, scalable, and decision-friendly.

This foundation is extremely important for BI systems, Analytics Engineering, Data Engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏
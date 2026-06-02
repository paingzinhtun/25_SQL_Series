# Day 22 - Data Warehouse Design with Star Schema

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to design a beginner-friendly but professional data warehouse using a star schema. The project shows how a retail business can organize data for analytics, BI reporting, dashboards, and centralized KPI tracking.

This is not an OLTP transactional database project. It is an OLAP-style analytics modeling project.

## Business Problem

A retail business has operational systems for orders, customers, products, stores, and employees.

The problem is that reporting is slow and inconsistent because data is spread across operational systems.

The business wants:

- a clean analytics model
- fast BI queries
- centralized KPIs
- historical reporting
- dimensional analytics
- dashboard-ready structures

## OLTP vs OLAP Explanation

OLTP systems are designed for daily transactions.

Examples:

- create an order
- update inventory
- register a customer
- process a payment

OLAP systems are designed for analytics.

Examples:

- total sales by month
- profit by category
- store performance
- customer spending
- regional growth trends

This project focuses on OLAP thinking.

## Star Schema Explanation

A star schema has one central fact table connected to multiple dimension tables.

In this project:

- `fact_sales` is the central fact table
- `dim_date`, `dim_customer`, `dim_product`, `dim_store`, `dim_employee`, and `dim_channel` are dimension tables

The structure looks like a star because the fact table sits in the center and dimensions connect around it.

## Fact Table vs Dimension Table

Fact tables store measurable business events.

In this project, `fact_sales` stores:

- quantity sold
- unit price
- discount amount
- total sales amount
- total cost amount
- profit amount

Dimension tables store descriptive business context.

Examples:

- customer name and region
- product category and brand
- store city and store type
- employee department and role
- channel name
- date attributes

## Fact Table Grain Explanation

The grain of `fact_sales` is:

```text
One row per product sold per order.
```

This means one order can appear multiple times in the fact table if the order contains multiple products.

Defining the grain is important because it controls how measures should be counted and aggregated.

## Surrogate Key Explanation

The warehouse uses surrogate keys such as:

- `customer_key`
- `product_key`
- `store_key`
- `employee_key`
- `channel_key`

These are warehouse-generated keys.

The original source business IDs are also kept, such as:

- `customer_id`
- `product_id`
- `store_id`
- `employee_id`

Surrogate keys make the warehouse more stable and easier to manage for analytics.

## ETL Simulation Explanation

The `etl_simulation.sql` file demonstrates a simple warehouse loading flow.

It includes:

- staging tables
- raw source-like rows
- cleaning examples
- deduplication examples
- dimension loading
- surrogate key mapping
- fact table loading
- data quality checks

The simplified ETL flow is:

1. Load raw data into staging tables.
2. Clean and deduplicate source data.
3. Load dimensions first.
4. Join source records to dimensions to get surrogate keys.
5. Load the fact table.
6. Run data quality checks.

## Warehouse Analytics Explanation

The analysis queries use the star schema for BI reporting.

The fact table provides measures. The dimension tables provide ways to group, filter, and analyze those measures.

Examples:

- revenue by month uses `fact_sales` plus `dim_date`
- revenue by category uses `fact_sales` plus `dim_product`
- revenue by region uses `fact_sales` plus `dim_store`
- customer spending uses `fact_sales` plus `dim_customer`

## Dashboard View Explanations

The project includes dashboard-style SQL outputs:

- Executive sales dashboard
- Product performance dashboard
- Store performance dashboard
- Customer analytics dashboard
- Sales trend dashboard
- BI summary view

These are examples of how SQL can prepare clean reporting tables for BI tools.

## Business Recommendations

The project includes a simple recommendation query using `CASE WHEN`.

Example actions:

- Expand high-performing category
- Review low-performing products
- Increase marketing in weak regions
- Improve profit margin
- Strengthen online sales strategy
- Maintain current performance

The goal is to connect analytics with business action.

## SQL Concepts Practiced

- `SELECT`
- `WHERE`
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `CASE WHEN`
- CTEs
- Window functions
- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `LAG`
- `SUM OVER`
- `CREATE VIEW`
- `NULLIF`
- `COALESCE`

## Warehouse Concepts Practiced

- Data warehouse fundamentals
- Dimensional modeling
- Star schema design
- Fact tables
- Dimension tables
- Surrogate keys
- Source business IDs
- Fact table grain
- ETL simulation
- Staging tables
- Data quality checks
- BI-ready summary views
- OLTP vs OLAP thinking

## Business Questions Answered

- What are total sales by date?
- Which stores perform best?
- Which product categories drive revenue?
- Which regions have strongest performance?
- What are monthly and yearly trends?
- Which customers spend the most?
- Which sales channels perform best?
- Which employees generate the most sales?
- What is average order value?
- How do business KPIs change over time?
- Which products are low-performing?
- What is profit margin by category?
- What does an executive dashboard need?
- What should a BI summary view contain?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates the star schema warehouse tables. |
| `insert_data.sql` | Inserts realistic fictional dimension and fact data. |
| `etl_simulation.sql` | Demonstrates staging, cleaning, deduplication, surrogate key mapping, and loading. |
| `analysis_queries.sql` | Contains BI and warehouse analytics queries. |
| `business_questions.md` | Maps business questions to warehouse and SQL concepts. |
| `README.md` | Explains the project and learning goals. |

## Key Lessons

A data warehouse is not just a database.

It is designed to make analytics fast, consistent, and business-friendly.

Good warehouse design starts with clear questions:

- What is the business process?
- What is the grain of the fact table?
- Which measures should be stored?
- Which dimensions describe the facts?
- Which dashboards should this model support?

Star schemas are important because they make reporting easier for analysts, BI tools, and business users.

## How to Run This Project

Run the files in this order using PostgreSQL:

```sql
-- 1. Create warehouse tables
\i schema.sql

-- 2. Insert sample warehouse data
\i insert_data.sql

-- 3. Run ETL simulation
\i etl_simulation.sql

-- 4. Run BI analysis queries
\i analysis_queries.sql
```

If you are using pgAdmin, open each file and run them in the same order.

## LinkedIn Reflection Draft

Day 22/25 - SQL for Real Business Data Systems

Today I built a Data Warehouse Design project using a Star Schema in SQL.

This project helped me understand the difference between:
- transactional systems (OLTP)
and
- analytics systems (OLAP)

Instead of designing tables for day-to-day transactions, I designed a warehouse optimized for analytics and BI reporting.

For this project, I created:
- dimension tables
- a fact table
- surrogate keys
- a star schema
- ETL simulation logic
- analytics dashboard views

The warehouse included:
- dim_date
- dim_customer
- dim_product
- dim_store
- dim_employee
- dim_channel
- fact_sales

Then I wrote SQL queries to analyze:
- total revenue
- total profit
- sales trends
- regional performance
- product performance
- customer analytics
- employee performance
- store analytics
- growth trends
- seasonal trends
- KPI dashboards

SQL and warehouse concepts I practiced:
- star schema design
- dimensional modeling
- fact vs dimension thinking
- surrogate keys
- ETL simulation
- joins
- CTEs
- window functions
- growth analysis
- BI dashboard thinking

My key lesson:
A data warehouse is not just a database.

It is a system designed to make analytics fast, consistent, and business-friendly.

This foundation is extremely important for analytics engineering, BI systems, Data Engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome.

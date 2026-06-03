# Day 23 — Slowly Changing Dimensions (SCD Type 1 & Type 2)

## Project Overview
This project explores one of the most critical concepts in Data Warehousing and Data Engineering: **Slowly Changing Dimensions (SCD)**. 

When business data changes over time—such as a customer moving to a new city, or an employee receiving a promotion—a data warehouse must decide how to handle the update. 
- Do we overwrite the old data?
- Do we preserve the old data to maintain historical accuracy?

This project builds a schema that implements both **SCD Type 1** and **SCD Type 2**, populates it with fictional retail data, simulates ETL update processes, and provides advanced analytics queries demonstrating the importance of historical tracking.

## Business Problem
A retail business tracks customers, employees, products, and sales. Over time:
- Customers move to different cities or get upgraded to VIP segments.
- Employees change departments or salary bands.
- Products get re-categorized or change price bands.

If the business overwrites this data (Type 1), historical sales reports become inaccurate. For example, if a customer moves from Bago to Yangon, all their *past* sales in Bago suddenly look like they happened in Yangon. To prevent this, the business needs a way to preserve history (Type 2).

## Why Historical Data Matters
In analytics, **context is everything**. A sale is tied to the state of the business *at the exact moment the sale occurred*. Overwriting dimension data destroys that context, leading to flawed Business Intelligence (BI) dashboards and incorrect machine learning models.

## SCD Type 1 Explanation
**Type 1 overwrites old data.**
- **Use case:** Fixing typos, or updating fields where history doesn't matter (e.g., updating an email address).
- **Pros:** Simple ETL, saves storage space.
- **Cons:** Complete loss of historical context.

## SCD Type 2 Explanation
**Type 2 preserves history by adding a new row.**
- **Use case:** Tracking location changes, department transfers, price tier changes.
- **Pros:** Perfect historical accuracy.
- **Cons:** Complex ETL, requires more storage, necessitates surrogate keys.

## Surrogate Key Explanation
Why does Type 2 need Surrogate Keys? 
Because the Business Key (e.g., `customer_id = 'C001'`) will now appear multiple times in the dimension table (one row for each historical version). The Fact table needs a unique identifier (`customer_sk`) to link to the *exact specific version* of that customer at the time of the sale.

## Effective Date Logic
Type 2 uses `effective_start_date` and `effective_end_date` to manage versions. 
- The current, active row has an `effective_end_date` of `NULL` (or sometimes '9999-12-31').
- When a change happens, the current row's end date is updated, and a new row is inserted with a new start date.
- We also use an `is_current` boolean flag for fast querying.

## ETL Workflow Explanation
The project simulates ETL through two scripts:
1. `scd_type1_etl.sql`: Uses `ON CONFLICT DO UPDATE` to overwrite existing records.
2. `scd_type2_etl.sql`: Uses PL/pgSQL `DO` blocks to identify changes, expire old records, and insert new versioned rows.

## Historical Analytics & Dashboard Views
The `analysis_queries.sql` file provides over 40 queries, including:
- "As of date" lookups to see the business state on a specific day.
- CTEs generating Dashboard Views for Customer, Employee, and Product history.
- Join logic comparing flawed Type 1 sales reporting vs accurate Type 2 sales reporting.

## Warehouse Recommendations
Included queries evaluate the volatility of dimensions and suggest warehouse recommendations (e.g., "Investigate excessive updates" if a dimension changes too frequently), showing how Data Engineers monitor warehouse health.

## SQL Concepts Practiced
- Surrogate Keys & Constraints
- `ON CONFLICT` Upserts
- PL/pgSQL procedural blocks (`DO $$`)
- Advanced `JOIN` logic
- Common Table Expressions (CTEs)
- Window Functions (`LAG()`, `OVER()`)
- Date Math & Logic
- `COALESCE` and `NULLIF` handling

## Data Warehouse Concepts Practiced
- Dimensional Modeling (Star Schema elements)
- Slowly Changing Dimensions (Type 1 & 2)
- ETL update workflows
- Historical reporting accuracy
- Dimension versioning

## Files in This Project
- `schema.sql`: Table creation with Type 1 & Type 2 structures.
- `insert_data.sql`: Initial historical data load.
- `scd_type1_etl.sql`: Simulation of Type 1 overwrite logic.
- `scd_type2_etl.sql`: Simulation of Type 2 versioning logic.
- `analysis_queries.sql`: 40+ analytics and history queries.
- `business_questions.md`: Mapping of business needs to SQL concepts.
- `README.md`: This file.

## Key Lessons
A data warehouse is fundamentally different from an operational database. While an operational app only cares about "now", a data warehouse must remember "then". Implementing SCD Type 2 is how Data Engineers ensure the integrity of the company's memory.

## How to Run This Project
Run the files in PostgreSQL in this exact order:
1. `schema.sql`
2. `insert_data.sql`
3. `scd_type1_etl.sql`
4. `scd_type2_etl.sql`
5. `analysis_queries.sql`

---

## LinkedIn Reflection Draft

Day 23/25 — SQL for Real Business Data Systems

Today I built a Slowly Changing Dimensions (SCD) project using SQL.

This project helped me understand one important warehouse problem:

Business data changes over time.

Customers move cities.
Employees change departments.
Products move categories.

If we overwrite old data, we lose history.

So I learned:
- SCD Type 1 → overwrite old values
- SCD Type 2 → preserve historical versions

For this project, I created:
- Type 1 dimensions
- Type 2 dimensions
- historical version tracking
- effective date logic
- current vs historical records
- ETL simulation workflows
- historical analytics queries

Then I wrote SQL queries to analyze:
- customer history
- employee history
- product history
- historical sales attribution
- dimension version changes
- current vs historical analytics
- “as of date” lookups
- warehouse monitoring KPIs

SQL and warehouse concepts I practiced:
- surrogate keys
- dimensional modeling
- SCD Type 1
- SCD Type 2
- historical tracking
- ETL workflows
- joins
- CTEs
- window functions
- date logic
- warehouse history management

My key lesson:
A warehouse is not only about storing current data.

It is also about preserving business history correctly.

Historical accuracy is extremely important for analytics, reporting, BI systems, Data Engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏
# Day 8 — COVID Data Analysis

## Project Overview

This project simulates public health time-series data using PostgreSQL.

The goal is to practice SQL analysis for daily COVID-style case counts, deaths, recoveries, active cases, and vaccination progress.

The system tracks:

- Countries
- Daily COVID statistics
- Vaccinations

This project is not medical advice and does not use official real data. It uses fictional sample data for SQL learning.

## Real-World Problem

Public health teams, government departments, NGOs, and analysts often need to monitor disease trends over time.

They need to answer questions such as:

- How many total cases were reported?
- Which country or region had the highest cases?
- How did cases change over time?
- What is the daily growth rate?
- What is the 7-day moving average?
- Which countries have the highest death rate?
- Which countries have the highest recovery rate?
- Are there missing or inconsistent records?

SQL helps turn daily reporting data into useful trend analysis, comparisons, and data quality checks.

## Database Tables

### countries

Stores country information such as country name, region, and population.

Population is important because many public health metrics need to be normalized by population size.

### covid_daily_stats

Stores one row per country per report date.

This table includes new cases, total cases, new deaths, total deaths, new recoveries, total recoveries, and active cases.

The unique country/date constraint prevents duplicate daily records.

### vaccinations

Stores one row per country per report date for vaccination activity.

This table includes daily vaccinations, total vaccinations, and people fully vaccinated.

The unique country/date constraint prevents duplicate vaccination records.

## Entity Relationship Explanation

The database has three main entities:

- One country can have many daily COVID statistic records.
- One country can have many vaccination records.
- Each daily statistic belongs to one country.
- Each vaccination record belongs to one country.

Foreign keys protect the data by making sure:

- Every COVID daily stat belongs to a real country.
- Every vaccination record belongs to a real country.

## Time-Series Analysis Explanation

Time-series data records how a metric changes over time.

In this project, each country has daily COVID statistics across multiple dates.

This makes it possible to analyze:

- Daily trends
- Monthly summaries
- Day-over-day change
- Growth rate
- 7-day moving average
- Cumulative totals
- Latest available values

For time-series analysis, date logic is important. Many queries use the latest available date dynamically instead of hardcoding one date.

Window functions such as `LAG`, `AVG OVER`, `RANK`, and `SUM OVER` help compare current rows with previous rows or calculate rolling and cumulative values.

## SQL Concepts Practiced

- Creating tables
- Primary keys
- Foreign keys
- Unique constraints
- NOT NULL constraints
- CHECK constraints
- SELECT queries
- WHERE filtering
- INNER JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- ORDER BY
- CASE WHEN
- Date functions
- Common Table Expressions
- Window functions
- LAG
- Moving averages
- Growth rate calculations
- NULL handling with `NULLIF`
- Data quality checks

## Analytical Questions Answered

This project answers analytical questions such as:

- List all countries and populations.
- Show daily COVID stats with country names.
- Calculate total cases by country.
- Calculate total deaths by country.
- Calculate active cases by country.
- Find countries with the highest total cases.
- Find countries with the highest total deaths.
- Calculate death rate by country.
- Calculate recovery rate by country.
- Calculate cases per 100,000 population.
- Show daily new cases trends.
- Show monthly new cases trends.
- Calculate 7-day moving averages.
- Calculate day-over-day change.
- Calculate daily growth rate.
- Rank countries by latest total cases.
- Find countries where cases are increasing.
- Compare vaccination progress by country.
- Calculate percentage of population fully vaccinated.
- Find countries with missing vaccination records.
- Create a simple public health summary.
- Calculate cumulative new cases.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts fictional public health time-series data |
| `analysis_queries.sql` | Contains analytical SQL queries |
| `business_questions.md` | Explains each analytical question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

Time-series data is powerful because it shows change over time.

A single total can tell us what happened overall.

But trends help us understand:

1. Direction
2. Speed of change
3. Risk
4. Progress
5. Data quality issues

This type of analysis is useful not only for public health, but also for sales, finance, inventory, marketing, operations, and many other business systems.

It is also a strong foundation for Data Engineering pipelines, analytics dashboards, and future Data + AI solutions.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE covid_data_analysis;
```

Connect to the database:

```bash
psql -d covid_data_analysis
```

Run the files in this order:

```bash
psql -d covid_data_analysis -f schema.sql
psql -d covid_data_analysis -f insert_data.sql
psql -d covid_data_analysis -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 8/25 — SQL for Real Business Data Systems

Today I built a COVID Data Analysis project using SQL.

This project helped me practice time-series analysis.

Unlike previous projects such as retail, inventory, or banking, this project focuses on data that changes every day.

For this project, I modeled:

- countries
- covid_daily_stats
- vaccinations

Then I wrote SQL queries to analyze:

- total cases
- total deaths
- active cases
- death rate
- recovery rate
- cases per 100,000 population
- daily trends
- monthly trends
- 7-day moving averages
- day-over-day changes
- vaccination progress
- missing vaccination records

SQL concepts I practiced:

- joins
- grouping
- aggregation
- date functions
- CTEs
- window functions
- LAG
- moving averages
- rate calculations
- NULL handling

My key lesson:
Time-series data is powerful because it shows change over time.

A single number tells us what happened.
But trends help us understand direction, risk, and progress.

This same type of analysis is useful not only for public health, but also for sales, finance, inventory, marketing, and operations.

This foundation is important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

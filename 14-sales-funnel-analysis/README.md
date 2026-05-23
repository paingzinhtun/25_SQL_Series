# Day 14 — Sales Funnel Analysis

## Project Overview

This project analyzes a sales funnel using PostgreSQL.

The goal is to understand how businesses track leads from first contact to qualified lead, opportunity, proposal, negotiation, and finally closed won or closed lost.

This is an intermediate SQL project because it focuses on business logic:

- conversion rates
- stage drop-offs
- win rates
- source quality
- sales rep performance
- open pipeline value
- weighted pipeline value
- lead-level 360 reporting

## Business Problem

A business does not only need to know how many leads it has.

It needs to understand the full journey from lead to customer.

Useful business questions include:

- How many leads entered the funnel?
- How many leads became qualified?
- How many qualified leads became opportunities?
- How many opportunities became customers?
- Where do most leads drop off?
- Which marketing sources produce real revenue?
- Which sales reps close the most deals?
- What is the win rate?
- How much revenue is still in the pipeline?

SQL helps connect marketing, sales activity, opportunities, and deals into one analytical view.

## Database Tables

### lead_sources

Stores where leads came from.

Source type can be:

- `organic`
- `paid`
- `referral`
- `outbound`
- `event`
- `partner`

### sales_reps

Stores sales representative details such as name, email, region, and hire date.

### leads

Stores prospect information such as lead name, company, city, source, assigned rep, lead status, and created date.

Lead status can be:

- `new`
- `contacted`
- `qualified`
- `disqualified`
- `converted`

### funnel_stages

Stores the ordered sales funnel stages:

- `lead_created`
- `contacted`
- `qualified`
- `opportunity_created`
- `proposal_sent`
- `negotiation`
- `closed_won`
- `closed_lost`

### lead_stage_history

Stores when a lead entered and exited each funnel stage.

This table makes time-in-stage, latest-stage, and drop-off analysis possible.

### opportunities

Stores sales opportunities created from qualified leads.

Each opportunity has an estimated value, probability, status, created date, and expected close date.

Opportunity status can be:

- `open`
- `won`
- `lost`

### deals

Stores closed outcomes for opportunities.

Deal status can be:

- `won`
- `lost`

Lost deals include a loss reason such as price, no budget, competitor, no response, not ready, or poor fit.

## Entity Relationship Explanation

The main relationships are:

- One lead source can generate many leads.
- One sales rep can own many leads.
- One lead can move through many funnel stages.
- One lead can become one opportunity.
- One opportunity can become one closed deal.

Foreign keys protect these relationships.

For example:

- `leads.source_id` must match a real source.
- `leads.assigned_rep_id` must match a real sales rep.
- `lead_stage_history.lead_id` must match a real lead.
- `opportunities.lead_id` must match a real lead.
- `deals.opportunity_id` must match a real opportunity.

## Sales Funnel Lifecycle Explanation

The funnel starts when a lead is created.

Then the lead may move through:

1. contacted
2. qualified
3. opportunity created
4. proposal sent
5. negotiation
6. closed won or closed lost

Not every lead reaches every stage.

Some leads stop after contact, some are disqualified, some become open opportunities, and some become won or lost deals.

## Conversion Logic Explanation

Conversion rate measures how many records move from an earlier stage to a later stage.

Examples:

```sql
qualified leads / lead_created leads
opportunity_created leads / qualified leads
closed_won leads / opportunity_created leads
```

Overall lead-to-customer conversion is simplified as:

```sql
won deals / total leads
```

The SQL queries use `NULLIF` to avoid division by zero.

## Drop-off Logic Explanation

Drop-off shows where leads stop moving forward.

In this project:

```sql
drop-off count = leads at current stage - leads at next stage
drop-off rate = drop-off count / leads at current stage
```

This helps a business find where the funnel is leaking.

## Pipeline Value Explanation

Open pipeline value is the total estimated value of open opportunities:

```sql
SUM(estimated_value)
```

Weighted pipeline value adjusts open opportunities by probability:

```sql
SUM(estimated_value * probability / 100)
```

This is a simple revenue forecasting idea.

It does not guarantee future revenue, but it helps sales teams estimate likely pipeline value.

## Lead 360 View Explanation

A Lead 360 view combines useful lead-level information into one result.

The Lead 360 query includes:

- lead ID
- lead name
- company name
- city
- source
- assigned sales rep
- lead status
- latest funnel stage
- opportunity status
- estimated value
- deal status
- deal value
- created date
- expected close date

This kind of view is useful for CRM dashboards, sales operations, marketing analysis, and follow-up prioritization.

## SQL Concepts Practiced

This project practices:

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
- `ROW_NUMBER()`
- `RANK()`
- `LEAD()`
- `DATE_TRUNC`
- `FILTER`
- `COALESCE`
- `NULLIF`
- date arithmetic
- conversion rate calculation
- funnel analysis
- win-rate analysis
- pipeline analysis

## Business Questions Answered

The analysis queries answer questions such as:

- How many leads entered the funnel?
- Which sources generate the most leads?
- Which cities generate leads?
- Which sales reps own the most leads?
- How many leads are at each stage?
- What is lead-to-qualified conversion?
- What is qualified-to-opportunity conversion?
- What is opportunity-to-won conversion?
- What is overall lead-to-customer conversion?
- Where do leads drop off?
- How long do leads spend in each stage?
- Which sources convert best?
- Which sources generate the most won revenue?
- Which sales reps close the most deals?
- What is the win rate?
- What is the open pipeline value?
- What is weighted pipeline value?
- What are the most common loss reasons?
- What does a Lead 360 view look like?

## Files in This Project

| File | Description |
| --- | --- |
| `schema.sql` | Creates sales funnel tables, relationships, and constraints |
| `insert_data.sql` | Inserts realistic fictional sales funnel sample data |
| `analysis_queries.sql` | Contains funnel, conversion, source, rep, win/loss, and pipeline queries |
| `business_questions.md` | Maps each query to business value and SQL concepts |
| `README.md` | Explains the project, logic, and learning goals |

## Key Lessons

Sales funnel analysis is not only about counting leads.

It helps a business understand:

- which sources create quality leads
- where leads stop moving forward
- which reps close more deals
- why deals are lost
- how much open revenue is still possible

The most important lesson is that growth can leak at different funnel stages.

Good SQL analysis helps find those leaks.

## How to Run This Project

Run the files in this order using PostgreSQL:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

If you are using pgAdmin:

1. Open `schema.sql` and run it.
2. Open `insert_data.sql` and run it.
3. Open `analysis_queries.sql` and run each query one by one.

## LinkedIn Reflection Draft

Day 14/25 — SQL for Real Business Data Systems

Today I built a Sales Funnel Analysis project using SQL.

This project helped me understand how businesses turn leads into customers.

A business should not only ask:

“How many leads do we have?”

It should also ask:
- where do leads come from?
- how many leads become qualified?
- where do leads drop off?
- which sales reps close more deals?
- which sources generate real revenue?
- what is the win rate?
- how much revenue is still in the pipeline?

For this project, I modeled:
- lead_sources
- sales_reps
- leads
- funnel_stages
- lead_stage_history
- opportunities
- deals

Then I wrote SQL queries to analyze:
- lead volume
- funnel stages
- conversion rates
- stage drop-offs
- average time in each stage
- source performance
- sales rep performance
- win rate
- loss reasons
- open pipeline value
- weighted pipeline value
- monthly lead trends
- monthly won revenue
- basic Lead 360 view

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- date logic
- conversion rate calculation
- funnel analysis
- pipeline analysis

My key lesson:
Sales data becomes powerful when we can see the full journey from lead to customer.

A good funnel analysis helps a business understand not only revenue, but also where growth is leaking.

This foundation is important for CRM analytics, marketing analytics, Data Engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

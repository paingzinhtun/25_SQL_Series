# Day 13 — Subscription-Based Platform Analysis

## Project Overview

This project analyzes a subscription-based platform using PostgreSQL.

The goal is to understand how businesses like streaming apps, SaaS products, learning platforms, and membership services can track users, plans, subscriptions, payments, renewals, cancellations, usage, churn, and retention.

This is an intermediate SQL project because it focuses on business logic, not only table joins.

The project teaches:

- recurring revenue thinking
- active vs inactive subscriptions
- churn analysis
- renewal tracking
- plan performance
- usage-based retention risk
- customer health scoring
- Subscriber 360 reporting

## Business Problem

A subscription business does not only need to know total users.

It needs to know whether users are paying, staying, renewing, cancelling, and using the product.

Useful business questions include:

- How many active subscribers do we have?
- Which plans generate the most revenue?
- Which users cancelled?
- What is the churn rate?
- Which users renewed?
- Which users have failed payments?
- Which active users have low usage?
- Which customers are long-term subscribers?
- What does a useful Subscriber 360 view look like?

SQL helps turn subscription, payment, usage, and cancellation records into business insight.

## Database Tables

### users

Stores customer profile information such as name, email, city, phone number, and signup date.

### subscription_plans

Stores the product catalog for subscriptions.

Each plan has:

- a billing cycle
- a monthly price
- a plan tier

Billing cycle can be:

- `monthly`
- `quarterly`
- `yearly`

Plan tier can be:

- `basic`
- `standard`
- `premium`
- `family`
- `business`

### subscriptions

Stores each subscription period for a user.

A user can have multiple subscription records over time. This supports renewal analysis.

Subscription status can be:

- `active`
- `cancelled`
- `expired`
- `trial`
- `paused`

### payments

Stores payment attempts for subscriptions.

Payment status can be:

- `paid`
- `failed`
- `refunded`
- `pending`

Only `paid` payments count as revenue.

### usage_events

Stores product usage activity such as login, watch, listen, download, lesson view, or feature use.

Usage is important because low usage can be an early warning sign for churn.

### cancellations

Stores cancellation date and cancellation reason for cancelled subscriptions.

This helps the business understand why customers leave.

## Entity Relationship Explanation

The main relationships are:

- One user can have many subscriptions.
- One subscription plan can be used by many subscriptions.
- One subscription can have many payment records.
- One user can have many usage events.
- One cancelled subscription can have one cancellation record.

Foreign keys protect these relationships.

For example:

- `subscriptions.user_id` must match a real user.
- `subscriptions.plan_id` must match a real plan.
- `payments.subscription_id` must match a real subscription.
- `usage_events.user_id` must match a real user.
- `cancellations.subscription_id` must match a real subscription.

## Subscription Lifecycle Explanation

A subscription can move through different statuses:

- `trial`: user is trying the platform
- `active`: user currently has an active subscription
- `paused`: user temporarily stopped service
- `expired`: subscription ended without being active now
- `cancelled`: user cancelled the subscription

This lifecycle matters because active subscribers, cancelled subscribers, and trial users should not be analyzed in the same way.

## Revenue Logic Explanation

Revenue is counted only from payments where:

```sql
payment_status = 'paid'
```

Failed, refunded, and pending payments are not counted as real revenue.

Monthly recurring revenue is simplified as:

```sql
SUM(monthly_price) for active subscriptions
```

In this project, `monthly_price` stores the monthly equivalent for every plan, even if the billing cycle is quarterly or yearly.

## Churn Logic Explanation

Churn is simplified for learning as:

```sql
cancelled subscriptions / total subscriptions
```

Plan cancellation rate is simplified as:

```sql
cancelled subscriptions for a plan / total subscriptions for that plan
```

The queries use `NULLIF` to avoid division by zero.

This is not a complete production churn model, but it teaches the basic thinking behind churn analysis.

## Renewal Logic Explanation

Renewal is identified when a user has more than one subscription record.

This is a simple but useful pattern:

```sql
GROUP BY user_id
HAVING COUNT(subscription_id) > 1
```

This helps learners understand how repeated subscription periods can show retention or upgrade behavior.

## Subscriber 360 View Explanation

A Subscriber 360 view combines useful customer-level facts into one result.

The Subscriber 360 query includes:

- user ID
- customer name
- city
- signup date
- current plan
- subscription status
- total paid amount
- total usage minutes
- last usage date
- total subscription count
- cancellation count
- subscriber health status

This kind of view is useful for analytics dashboards, CRM systems, product teams, retention campaigns, and future recommendation systems.

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
- `DATE_TRUNC`
- `FILTER`
- `COALESCE`
- `NULLIF`
- date logic
- revenue filtering
- churn calculation
- renewal logic
- customer health scoring
- Subscriber 360 thinking

## Business Questions Answered

The analysis queries answer questions such as:

- How many active subscribers do we have?
- Which plans generate the most revenue?
- What is estimated MRR?
- What is average revenue per paying user?
- Which users have failed payments?
- Which users have no paid payment?
- Which users cancelled and why?
- What is the churn rate?
- Which plans have the highest cancellation rate?
- Which users renewed?
- Which users are long-term subscribers?
- How much usage does each user have?
- Which active users have low usage?
- Which users have no recent usage?
- What does a Subscriber 360 view look like?

## Files in This Project

| File | Description |
| --- | --- |
| `schema.sql` | Creates tables, relationships, and constraints |
| `insert_data.sql` | Inserts realistic fictional subscription data |
| `analysis_queries.sql` | Contains subscription, revenue, churn, usage, and retention queries |
| `business_questions.md` | Maps each query to business value and SQL concepts |
| `README.md` | Explains the project, logic, and learning goals |

## Key Lessons

Subscription analytics is different from one-time sales analysis.

A subscription business must understand:

- who is active
- who cancelled
- who renewed
- who paid successfully
- who is using the product
- who may churn soon

The most important lesson is that revenue and retention depend on business rules.

Counting all payments as revenue or all users as active subscribers would create misleading reports.

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

Day 13/25 — SQL for Real Business Data Systems

Today I built a Subscription-Based Platform Analysis project using SQL.

This project helped me understand how subscription businesses think about users, revenue, churn, and retention.

For a subscription platform, total users are not enough.

The business needs to know:
- who is active
- who cancelled
- who renewed
- which plan generates the most revenue
- which users are at risk of churn
- which customers are actually using the product

For this project, I modeled:
- users
- subscription_plans
- subscriptions
- payments
- usage_events
- cancellations

Then I wrote SQL queries to analyze:
- active subscribers
- subscription status
- revenue by plan
- monthly recurring revenue approximation
- average revenue per user
- failed payments
- churn rate
- cancellation reasons
- renewal behavior
- long-term subscribers
- usage activity
- low-usage active users
- basic Subscriber 360 view

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- date logic
- churn calculation
- renewal logic
- recurring revenue analysis
- customer health scoring

My key lesson:
Subscription analytics is not only about revenue.

It is about understanding whether customers are staying, using the product, paying successfully, and getting enough value to continue.

This foundation is important for SaaS analytics, product analytics, CRM systems, Data Engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

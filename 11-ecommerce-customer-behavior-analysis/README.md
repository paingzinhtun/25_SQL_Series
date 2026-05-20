# Day 11 — E-commerce Customer Behavior Analysis

## Project Overview

This project analyzes customer behavior for an e-commerce business using PostgreSQL.

The goal is to move beyond basic sales reporting and understand how customers behave over time.

The project focuses on:

- repeat purchases
- one-time customers
- inactive customers
- average order value
- customer lifetime value basics
- product category preferences
- first and latest purchase dates
- time between first and second purchase
- retention status
- a basic Customer 360 view

This is the start of the intermediate phase of the SQL series.

## Business Problem

An e-commerce business does not only need to know total sales.

It also needs to understand customer behavior.

Useful business questions include:

- Who are the most valuable customers?
- Which customers buy repeatedly?
- Which customers bought only once?
- Which customers have not purchased recently?
- Which customer segments bring the most revenue?
- Which categories do customers prefer?
- How long does it take customers to make a second purchase?
- Which customers should be targeted for retention campaigns?

SQL helps turn raw orders into customer-level insight.

## Database Tables

### customers

Stores customer profile information such as name, email, city, gender, and signup date.

### customer_segments

Stores business-defined customer segment labels:

- `new_customer`
- `regular_customer`
- `vip_customer`
- `inactive_customer`

### products

Stores product catalog information such as product name, category, and unit price.

### orders

Stores order-level information such as customer, order date, order status, and customer segment at the time of order.

### order_items

Stores product-level detail for each order.

This table is needed because one order can contain many products.

### payments

Stores payment method, payment status, and payment amount for each order.

Payment status is important because not every order is real revenue.

## Entity Relationship Explanation

The main relationships are:

- One customer can place many orders.
- One customer segment can be assigned to many orders.
- One order can contain many order items.
- One product can appear in many order items.
- One order has one payment record.

Foreign keys protect these relationships.

For example:

- `orders.customer_id` must match a real customer.
- `orders.segment_id` must match a real segment.
- `order_items.product_id` must match a real product.
- `payments.order_id` must match a real order.

## Customer Behavior Analysis Explanation

Customer behavior analysis looks at customers across time, not only transactions.

In this project, SQL is used to answer:

- When did a customer first purchase?
- When did they last purchase?
- How many times did they purchase?
- Did they purchase more than once?
- How much did they spend?
- Which category do they prefer?
- Are they active or inactive?

This is the foundation for CRM, retention, segmentation, personalization, and Customer 360 systems.

## Revenue Logic Explanation

Revenue is counted only when both conditions are true:

- `order_status = 'completed'`
- `payment_status = 'paid'`

Revenue is calculated from order items:

```sql
(quantity * unit_price) - discount_amount
```

This means cancelled, returned, pending, unpaid, refunded, and failed orders are not counted as real revenue.

This rule is repeated in the analysis queries so the business logic is clear.

## Retention Logic Explanation

The sample project uses `2026-05-08` as a fixed analysis date.

This keeps the results stable for learning.

The retention labels are:

- `no_order`: customer has no completed paid orders
- `new_customer`: customer has exactly one completed paid order
- `active_repeat_customer`: customer has more than one completed paid order and purchased within the last 60 days
- `inactive_repeat_customer`: customer has more than one completed paid order but last purchase is older than 60 days
- `vip_customer`: customer spending is at least `350000`

These labels are simple, but they show how SQL can turn transaction history into retention signals.

## Customer 360 View Explanation

A Customer 360 view combines important customer facts into one result.

The Customer 360 query includes:

- customer ID
- customer name
- city
- signup date
- first purchase date
- last purchase date
- total orders
- total spending
- average order value
- preferred category
- retention status

This kind of view is useful for analytics dashboards, CRM systems, marketing campaigns, and recommendation systems.

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
- `COUNT DISTINCT`
- `COALESCE`
- `NULLIF`
- date logic
- revenue filtering
- customer segmentation
- Customer 360 thinking

## Business Questions Answered

The analysis queries answer questions such as:

- What is total revenue?
- What is average order value?
- Who are the top customers by spending?
- Which customers buy repeatedly?
- Which customers bought only once?
- Which customers have no orders?
- Which customers have not purchased in the last 60 days?
- What is each customer's first purchase date?
- What is each customer's latest purchase date?
- How many days passed before a second purchase?
- What is each customer's lifetime value?
- Which segment brings the most revenue?
- Which product categories are most popular?
- What is each customer's preferred category?
- What is monthly revenue?
- What are monthly active customers?
- What is each customer's retention status?
- What does a basic Customer 360 view look like?

## Files in This Project

| File | Description |
| --- | --- |
| `schema.sql` | Creates tables, relationships, and constraints |
| `insert_data.sql` | Inserts realistic sample e-commerce customer behavior data |
| `analysis_queries.sql` | Contains customer behavior analysis queries |
| `business_questions.md` | Maps business questions to SQL concepts |
| `README.md` | Explains the project and learning goals |

## Key Lessons

Customer analytics is different from simple sales reporting.

Sales reporting asks:

> What was sold?

Customer behavior analysis asks:

> Who bought, how often, how much, how recently, and what do they prefer?

This makes SQL more useful for business decisions.

With the right queries, a business can identify VIP customers, inactive customers, repeat customers, one-time customers, and product preferences.

## How to Run This Project

Run the files in this order:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

Or run them manually in a PostgreSQL client such as:

- pgAdmin
- DBeaver
- TablePlus
- DataGrip
- `psql`

Recommended workflow:

1. Create a new PostgreSQL database.
2. Run `schema.sql`.
3. Run `insert_data.sql`.
4. Open `analysis_queries.sql`.
5. Run each query one by one and study the result.

## LinkedIn Reflection Draft

Day 11/25 — SQL for Real Business Data Systems

Today I built an E-commerce Customer Behavior Analysis project using SQL.

This project starts the intermediate phase of my SQL learning series.

In earlier projects, I focused on basic systems like students, library, salary, retail, banking, and inventory.

Today’s focus was deeper:

Not only “What was sold?”

But:

“How do customers behave?”

For this project, I modeled:
- customers
- customer_segments
- products
- orders
- order_items
- payments

Then I wrote SQL queries to analyze:
- total revenue
- average order value
- repeat customers
- one-time customers
- inactive customers
- first purchase date
- latest purchase date
- time between first and second purchase
- customer lifetime value basics
- preferred product category
- monthly active customers
- customer retention status
- basic Customer 360 view

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- date logic
- customer segmentation
- revenue filtering
- Customer 360 thinking

My key lesson:
Customer data becomes powerful when we stop looking only at transactions and start looking at behavior.

A business can use this kind of analysis to decide:
- who to retain
- who to reward
- who is inactive
- which category customers prefer
- which customers bring the most value

This is an important foundation for Data Engineering, Analytics, CRM systems, recommendation systems, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

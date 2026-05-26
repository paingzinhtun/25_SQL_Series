# Day 17 — Customer Segmentation with RFM Analysis

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to build a beginner-friendly but professional SQL project for customer segmentation using **RFM analysis**.

RFM stands for:

- **Recency**: how recently a customer purchased
- **Frequency**: how often a customer purchased
- **Monetary**: how much a customer spent

This project shows how customer behavior data can be transformed into useful CRM segments for loyalty, retention, reactivation, and personalized marketing.

## Business Problem

A retail or e-commerce business does not want to treat every customer the same way.

A customer who buys often and spends a lot should not receive the same message as a customer who bought once a year ago.

The business wants to answer questions such as:

- Who are our most valuable customers?
- Who purchased recently?
- Who purchases frequently?
- Who spends the most?
- Which customers are becoming inactive?
- Which customers bought only once?
- Which customers should receive loyalty offers?
- Which customers should receive reactivation campaigns?
- Which customers are VIP-like customers?

RFM analysis helps turn raw order data into customer groups that are easier to understand and act on.

## Database Tables

| Table | Purpose |
|---|---|
| `customers` | Stores customer profile and signup information |
| `products` | Stores product names, categories, and prices |
| `orders` | Stores customer order headers and order status |
| `order_items` | Stores products, quantities, prices, and discounts per order |
| `payments` | Stores payment method, payment status, and amount |
| `customer_segments` | Stores the segment names used in the RFM project |

## Entity Relationship Explanation

The data model follows a simple e-commerce structure:

- One customer can place many orders.
- One order can have many order items.
- Each order item belongs to one product.
- Each order has one payment record.
- Customer segments define the business labels used after RFM scoring.

The most important relationship for RFM is:

```text
customers -> orders -> payments
customers -> orders -> order_items -> products
```

This lets us calculate:

- last purchase date
- completed paid order count
- total customer spending
- preferred product category

## RFM Analysis Explanation

RFM analysis is a customer segmentation method based on three questions:

| RFM Metric | Question | Business Meaning |
|---|---|---|
| Recency | How recently did the customer purchase? | Recent customers are more engaged |
| Frequency | How often did the customer purchase? | Frequent customers show repeat behavior |
| Monetary | How much did the customer spend? | High monetary customers bring more value |

In this project, RFM only uses real customer value:

```sql
order_status = 'completed'
payment_status = 'paid'
```

Cancelled, returned, pending, unpaid, refunded, and failed records are intentionally excluded from RFM calculations.

## RFM Scoring Logic

The queries use a fixed analysis date:

```sql
DATE '2026-05-01'
```

This makes recency calculations reproducible.

The base metrics are:

```sql
Recency = analysis date - last completed paid purchase date
Frequency = count of completed paid orders
Monetary = sum of completed paid order revenue
```

Scoring uses values from 1 to 5:

- Recency score: lower recency days is better, so recent customers receive a higher score.
- Frequency score: higher order count receives a higher score.
- Monetary score: higher spending receives a higher score.

The project uses `NTILE(5)` to create beginner-friendly score groups.

## Customer Segmentation Logic

The analysis queries use `CASE WHEN` to map RFM scores into segments:

| Segment | Meaning |
|---|---|
| `champions` | Recent, frequent, high-spending customers |
| `loyal_customers` | Frequent buyers with good recent activity |
| `potential_loyalists` | Recent customers with moderate repeat behavior |
| `new_customers` | Recent customers with low purchase history |
| `at_risk` | Customers with value but weak recent activity |
| `cannot_lose_them` | High-value frequent customers who have not purchased recently |
| `hibernating` | Low activity customers with old purchase history |
| `lost_customers` | Very old and low activity customers |
| `one_time_buyers` | Customers with exactly one completed paid purchase |

Customers with no completed paid orders are handled separately as `no_completed_paid_orders`.

## Recommended Marketing Actions

Segmentation becomes useful when it leads to action.

Example actions:

| Segment | Recommended Action |
|---|---|
| `champions` | Send VIP loyalty reward |
| `loyal_customers` | Recommend related products |
| `potential_loyalists` | Send loyalty program invitation |
| `new_customers` | Welcome and educate new customer |
| `at_risk` | Send retention offer |
| `cannot_lose_them` | Send retention offer |
| `hibernating` | Send reactivation campaign |
| `lost_customers` | Send reactivation campaign |
| `one_time_buyers` | Recommend related products |

## Customer 360 RFM View Explanation

The Customer 360 RFM query combines customer profile data with behavior metrics:

- customer ID
- customer name
- city
- signup date
- last purchase date
- recency days
- frequency
- monetary value
- average order value
- recency score
- frequency score
- monetary score
- RFM score
- customer segment
- preferred category
- recommended action

This is useful because it creates one customer-level view for CRM, retention, loyalty, and marketing decisions.

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
- window functions
- `NTILE`
- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- date subtraction
- filtered counts
- `COALESCE`
- `NULLIF`
- customer segmentation
- Customer 360 thinking

## Business Questions Answered

The project answers questions such as:

- Who are all customers?
- Which orders are completed and paid?
- What is total completed paid revenue?
- What is revenue by customer?
- How often does each customer purchase?
- When was each customer’s last purchase?
- How many days since each customer last purchased?
- What is each customer’s monetary value?
- What are each customer’s RFM scores?
- Which segment does each customer belong to?
- How many customers are in each segment?
- Which segments generate the most revenue?
- Who are champion customers?
- Who are loyal customers?
- Who are potential loyalists?
- Who are at-risk customers?
- Who are lost customers?
- Who are one-time buyers?
- Which customers have no completed paid orders?
- What is each customer’s preferred category?
- What marketing action fits each segment?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts fictional customers, products, orders, payments, and segment definitions |
| `analysis_queries.sql` | Contains RFM, segmentation, ranking, and Customer 360 queries |
| `business_questions.md` | Maps business questions to SQL concepts |
| `README.md` | Explains the project, RFM logic, business value, and LinkedIn reflection |

## Key Lessons

RFM analysis helps businesses move beyond total revenue.

It helps answer better questions:

- Who should receive a loyalty reward?
- Who needs a retention offer?
- Who should receive a reactivation campaign?
- Which customers are becoming valuable?
- Which customers are no longer active?

The key lesson is:

> Customer segmentation turns transaction history into business action.

This is a strong foundation for CRM analytics, marketing analytics, recommendation systems, Data Engineering, and future Data + AI solutions.

## How to Run This Project

Run the SQL files in this order:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

If you are using pgAdmin:

1. Open your PostgreSQL database.
2. Run `schema.sql`.
3. Run `insert_data.sql`.
4. Open `analysis_queries.sql` and run each query one by one.

## LinkedIn Reflection Draft

Day 17/25 — SQL for Real Business Data Systems

Today I built a Customer Segmentation project using RFM Analysis in SQL.

RFM means:
- Recency: how recently a customer purchased
- Frequency: how often a customer purchased
- Monetary: how much a customer spent

This project helped me understand that not all customers are the same.

A business should not treat:
- a VIP customer
- a one-time buyer
- an inactive customer
- a loyal customer
- a lost customer

in the same way.

For this project, I modeled:
- customers
- products
- orders
- order_items
- payments
- customer_segments

Then I wrote SQL queries to analyze:
- last purchase date
- recency in days
- purchase frequency
- monetary value
- RFM scores
- customer segments
- revenue by segment
- one-time buyers
- at-risk customers
- lost customers
- preferred product category
- recommended marketing actions
- Customer 360 RFM view

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- NTILE
- date logic
- customer segmentation
- retention analysis

My key lesson:
Customer segmentation helps a business move from generic marketing to targeted decision-making.

Instead of asking “Who bought from us?”

A better question is:

“Which customers need loyalty rewards, retention offers, reactivation campaigns, or product recommendations?”

This foundation is important for CRM analytics, marketing analytics, Data Engineering, recommendation systems, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

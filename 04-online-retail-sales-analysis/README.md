# Day 4 — Online Retail Sales Analysis

## Project Overview

This project models a small online retail business using PostgreSQL.

The goal is to show how everyday retail transactions become structured data and business insights.

The system tracks:

- Customers
- Products
- Stores
- Orders
- Order items
- Payments

This project is beginner-friendly, but it follows practical retail database design ideas such as primary keys, foreign keys, transaction tables, status tracking, revenue calculations, and KPI reporting.

## Business Problem

A small online retail business wants to understand its sales performance.

The business owner does not only need a list of orders. They need answers to questions such as:

- How much revenue did the business generate?
- Which products sell the most?
- Which products generate the most revenue?
- Which customers spend the most?
- Which store or branch performs best?
- What are the daily and monthly sales trends?
- What is the average order value?
- Which product categories are strongest?
- Are there cancelled, pending, unpaid, or refunded orders?

SQL helps convert sales transactions into useful reports for owners, managers, and analysts.

## Database Tables

### customers

Stores customer profile information such as name, email, phone number, city, and customer segment.

### products

Stores product information such as product name, category, and unit price.

### stores

Stores branch or store information such as store name and city.

### orders

Stores order-level information such as customer, store, order date, and order status.

An order can be completed, cancelled, or pending.

### order_items

Stores the products inside each order.

This table is important because one order can contain many products. Each row records one product, its quantity, and the unit price at the time of the order.

### payments

Stores payment information for each order.

A payment can be paid, unpaid, or refunded. Payment methods include cash, card, mobile wallet, and bank transfer.

## Entity Relationship Explanation

The database has six main entities:

- One customer can place many orders.
- One store can handle many orders.
- One order can contain many order items.
- One product can appear in many order items.
- One order has one payment record in this beginner project.
- Payments describe whether the order was actually paid, unpaid, or refunded.

The `orders` table stores the transaction header.

The `order_items` table stores the transaction details.

The `payments` table stores whether money was actually received.

For revenue reporting, this project uses an important business rule:

Only count revenue when:

- `order_status = 'completed'`
- `payment_status = 'paid'`

Cancelled, pending, unpaid, and refunded records are still useful for operations, but they should not be counted as real revenue.

Foreign keys protect the data by making sure:

- Every order belongs to a real customer.
- Every order belongs to a real store.
- Every order item belongs to a real order.
- Every order item belongs to a real product.
- Every payment belongs to a real order.

The sample data is intentionally designed for analysis:

- Some customers place repeat orders.
- Some orders are completed and paid.
- Some orders are cancelled.
- Some orders are pending.
- Some payments are unpaid or refunded.
- Products are spread across categories such as Electronics, Grocery, Fashion, Beauty, Home, Stationery, and Personal Care.
- Stores are located in Myanmar cities.

## SQL Concepts Practiced

- Creating tables
- Primary keys
- Foreign keys
- Unique constraints
- NOT NULL constraints
- CHECK constraints
- INSERT statements
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
- Aggregations
- Revenue calculations

## Business Questions Answered

This project answers practical questions such as:

- List all customers.
- List all products with categories and prices.
- Show all orders with customer and store information.
- Show detailed order items with product names and line revenue.
- Calculate total revenue from completed and paid orders.
- Calculate daily sales revenue.
- Calculate monthly sales revenue.
- Find top 5 best-selling products by quantity.
- Find top 5 products by revenue.
- Find revenue by product category.
- Find revenue by store or branch.
- Find top 5 customers by total spending.
- Count orders by order status.
- Count payments by payment status.
- Calculate average order value.
- Find repeat customers.
- Find cancelled orders and their payment status.
- Rank stores by total revenue.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic sample data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

SQL is not only about selecting rows from tables.

A useful retail data system starts by understanding the business process:

1. Customers place orders.
2. Orders contain products.
3. Products have prices.
4. Payments confirm whether money was received.
5. Order and payment statuses decide what counts as revenue.
6. SQL turns those transactions into business KPIs.

The key lesson in this project is revenue logic.

Not every order should count as revenue. A cancelled order, pending order, unpaid order, or refunded order may exist in the database, but it should not inflate the business performance report.

This is the type of thinking used in dashboards, reporting systems, analytics workflows, and Data Engineering pipelines.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE online_retail_sales_analysis;
```

Connect to the database:

```bash
psql -d online_retail_sales_analysis
```

Run the files in this order:

```bash
psql -d online_retail_sales_analysis -f schema.sql
psql -d online_retail_sales_analysis -f insert_data.sql
psql -d online_retail_sales_analysis -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 4/25 — SQL for Real Business Data Systems

Today I built an Online Retail Sales Analysis project using SQL.

This project is very close to real business problems.

Many shops and online sellers have sales records.

But having sales data is not the same as having business insight.

In this project, I modeled:

- customers
- products
- stores
- orders
- order_items
- payments

Then I wrote SQL queries to answer questions like:

- How much revenue did the business generate?
- Which products sell the most?
- Which product categories perform best?
- Which customers spend the most?
- Which branch generates the most revenue?
- What is the average order value?
- Which orders were cancelled or unpaid?

SQL concepts I practiced:

- joins
- grouping
- aggregation
- revenue calculation
- date-based analysis
- CASE WHEN
- CTEs
- window functions
- ranking

My key lesson:
SQL is not just about querying tables.
SQL helps convert daily business transactions into useful insights.

This is the foundation for dashboards, reporting systems, Data Engineering pipelines, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

# Day 9 — Food Delivery Orders Analysis

## Project Overview

This project models a small food delivery platform using PostgreSQL.

The goal is to practice SQL with marketplace-style data where customers, restaurants, delivery partners, orders, payments, menu items, and ratings are connected.

The system tracks:

- Customers
- Restaurants
- Delivery partners
- Menu items
- Orders
- Order items
- Payments
- Delivery ratings

This project is beginner-friendly, but it is designed around real business questions that a delivery platform would care about.

## Business Problem

A food delivery platform needs to understand how its business is performing.

The platform wants to answer questions such as:

- Which restaurants receive the most orders?
- Which restaurants generate the most revenue?
- Which customers order repeatedly?
- Which delivery partners complete the most deliveries?
- What is the average delivery time?
- Which deliveries are delayed?
- Which orders are cancelled?
- Which payment methods and statuses are common?
- Which restaurants or customers have no activity?

SQL helps connect operational records and turn them into useful business reports.

## Database Tables

### customers

Stores customer profile information such as name, email, phone number, and city.

Customers can place many orders.

### restaurants

Stores restaurant information such as restaurant name, cuisine type, and city.

Restaurants can have many menu items and many orders.

### delivery_partners

Stores delivery partner information such as name, phone number, city, and vehicle type.

Delivery partners can be assigned to many orders.

### menu_items

Stores the items sold by each restaurant.

Each menu item belongs to one restaurant.

### orders

Stores the main order record.

This table connects a customer, restaurant, and delivery partner. It also tracks the order lifecycle using `order_status`.

### order_items

Stores the items inside each order.

This is important because one order can contain many menu items.

### payments

Stores payment information for each order.

The project uses payment status to separate real revenue from unpaid, refunded, or failed payments.

### delivery_ratings

Stores customer feedback after completed deliveries.

Ratings help analyze food quality and delivery service quality.

## Entity Relationship Explanation

The main relationships are:

- One customer can place many orders.
- One restaurant can receive many orders.
- One restaurant can have many menu items.
- One delivery partner can deliver many orders.
- One order can contain many order items.
- One order has one payment record.
- One delivered order can have one rating record.

Foreign keys protect these relationships.

For example:

- `orders.customer_id` must match a real customer.
- `orders.restaurant_id` must match a real restaurant.
- `order_items.item_id` must match a real menu item.
- `payments.order_id` must match a real order.

## Order Lifecycle Explanation

The `orders` table uses `order_status` to track the order lifecycle.

In this project, an order can be:

- `preparing`
- `out_for_delivery`
- `delivered`
- `cancelled`

This matters because different statuses should be treated differently in analysis.

For example:

- Delivered orders can be used for completed delivery time analysis.
- Cancelled orders should not be counted as successful revenue.
- Preparing and out-for-delivery orders are still incomplete.

## Revenue Logic Explanation

Revenue is counted only when both conditions are true:

- `order_status = 'delivered'`
- `payment_status = 'paid'`

This prevents incorrect revenue reporting.

For example:

- A cancelled order with a refunded payment is not real revenue.
- A preparing order with an unpaid payment is not real revenue.
- An out-for-delivery order is not complete yet, even if payment is already marked as paid.

This rule is repeated in the revenue queries so beginners can clearly see the business logic.

## Delivery Performance Logic Explanation

Delivery time is calculated using:

```sql
EXTRACT(EPOCH FROM (delivery_time - order_time)) / 60
```

This converts the time difference into minutes.

Delivery time analysis only includes:

- Delivered orders
- Orders where `delivery_time` is not null

Cancelled, preparing, and out-for-delivery orders are excluded from completed delivery time metrics.

Delayed deliveries are defined as delivered orders where delivery time is more than 45 minutes after order time.

## SQL Concepts Practiced

This project practices:

- `SELECT`
- `WHERE`
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `LIMIT`
- `CASE WHEN`
- `COALESCE`
- CTEs
- Window functions
- `RANK()`
- Date and time calculations
- `DATE_TRUNC`
- Revenue filtering
- Operational KPI analysis

## Business Questions Answered

The analysis queries answer questions such as:

- Which restaurants receive the most orders?
- Which restaurants generate the most revenue?
- Which cuisine types perform best?
- Which customers spend the most?
- Which customers order repeatedly?
- Which orders were cancelled?
- What is the average delivery time?
- Which deliveries were delayed?
- Which delivery partners completed the most deliveries?
- Which partners have low average ratings?
- Which restaurants have the best food ratings?
- Which food categories are most popular?
- What is daily order volume?
- What is monthly revenue?
- Which restaurants have no orders?
- Which customers have no orders?

## Files in This Project

| File | Description |
| --- | --- |
| `schema.sql` | Creates tables, relationships, and constraints |
| `insert_data.sql` | Inserts fictional sample food delivery data |
| `analysis_queries.sql` | Contains business analysis queries |
| `business_questions.md` | Maps business questions to SQL concepts |
| `README.md` | Explains the project and learning goals |

## Key Lessons

Food delivery data is not stored in one table.

Useful analysis comes from connecting different parts of the business:

- Customer behavior
- Restaurant performance
- Menu item sales
- Delivery operations
- Payment status
- Customer ratings

The most important lesson is that SQL is not only about syntax.

SQL helps define business rules clearly.

For example, revenue should not include cancelled, unpaid, refunded, or failed orders.

Delivery time should not include orders that were cancelled or not yet completed.

Good SQL analysis depends on both correct table relationships and correct business logic.

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

Day 9/25 — SQL for Real Business Data Systems

Today I built a Food Delivery Orders Analysis project using SQL.

This project helped me understand how marketplace-style platforms work from a data perspective.

A food delivery business is not only about orders.

It connects many moving parts:
- customers
- restaurants
- menu items
- delivery partners
- orders
- payments
- ratings

Then I wrote SQL queries to analyze:
- total revenue
- restaurant performance
- cuisine performance
- customer spending
- repeat customers
- cancelled orders
- delivery delays
- delivery partner performance
- food ratings
- delivery ratings
- daily order volume
- monthly revenue trends

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CTEs
- window functions
- CASE WHEN
- date/time calculations
- revenue filtering
- operational KPI analysis

My key lesson:
In marketplace businesses, data is not in one table.

Useful insight comes from connecting customers, sellers, delivery operations, payments, and feedback together.

This kind of thinking is important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

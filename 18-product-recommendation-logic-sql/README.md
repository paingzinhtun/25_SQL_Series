# Day 18 — Product Recommendation Logic with SQL

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to build a beginner-friendly but professional intermediate SQL project that shows how basic product recommendation logic can be created using SQL.

This project focuses on simple and explainable logic:

- popular products
- customer purchase history
- category preference
- frequently bought together products
- wishlist-based recommendations
- viewed-but-not-purchased products
- similar customer behavior
- recommendation scoring
- AI-ready customer-product feature preparation

## Important Disclaimer

This is **not** a machine learning recommendation system.

It is not a production recommendation engine.

This project is a SQL learning project that demonstrates simple, explainable recommendation logic. Real recommendation systems may use machine learning, experimentation, personalization rules, ranking models, privacy controls, and production monitoring.

The purpose here is to understand the foundation before moving into advanced AI systems.

## Business Problem

An e-commerce or retail business wants to recommend products to customers.

The business does not need to start with complex AI immediately. It can first answer useful questions with SQL:

- Which products are popular?
- Which products are frequently bought together?
- Which categories does each customer prefer?
- Which products did a customer view but not buy?
- Which products did a customer wishlist but not buy?
- Which products were bought by similar customers?
- Which products should be recommended first?

These questions help the business improve cross-selling, upselling, retention, and personalized marketing.

## Database Tables

| Table | Purpose |
|---|---|
| `customers` | Stores customer profile and signup information |
| `products` | Stores product catalog data such as category, brand, and price |
| `orders` | Stores customer order headers and order status |
| `order_items` | Stores products purchased inside each order |
| `payments` | Stores payment method, payment status, and paid amount |
| `product_views` | Stores product browsing behavior |
| `wishlists` | Stores products customers saved for later |
| `product_recommendations` | Stores example recommendation outputs with reason and score |

## Entity Relationship Explanation

The database follows a simple e-commerce structure:

- One customer can place many orders.
- One order can contain many products.
- Each order has one payment record.
- Customers can view many products.
- Customers can wishlist many products.
- Recommendation records connect customers to recommended products.

The main behavior path is:

```text
customers -> orders -> order_items -> products
customers -> product_views -> products
customers -> wishlists -> products
customers -> product_recommendations -> products
```

## Recommendation Logic Explanation

This project uses multiple explainable signals:

| Signal | Meaning |
|---|---|
| Purchase history | Strongest signal because the customer actually bought the product |
| Product popularity | Useful fallback when little customer-specific data exists |
| Category preference | Recommends products from categories the customer already likes |
| Frequently bought together | Recommends complementary products |
| Wishlist behavior | Uses saved products as high-intent signals |
| Product views | Uses browsing behavior as lower-intent signals |
| Similar customers | Recommends products bought by customers with overlapping preferences |

Actual purchase behavior only uses:

```sql
order_status = 'completed'
payment_status = 'paid'
```

Cancelled, returned, pending, unpaid, refunded, and failed records are not counted as real purchase behavior.

## Frequently Bought Together Logic

Frequently bought together logic uses a self-join on `order_items`.

If Product A and Product B appear in the same completed paid order, they are counted as a pair.

To avoid duplicate pair directions, the query uses:

```sql
oi1.product_id < oi2.product_id
```

This prevents counting both:

- Product A + Product B
- Product B + Product A

The recommendation idea is:

> If a customer bought Product A but has not bought Product B, recommend Product B.

## Category Preference Logic

Category preference is calculated from completed paid purchases.

The project includes two versions:

- preferred category by quantity purchased
- preferred category by spending

This helps answer:

> What type of products does this customer usually buy?

Then the business can recommend other products from that category that the customer has not purchased yet.

## Wishlist and View-Based Signals

Wishlists and views are interest signals.

They are not the same as purchases.

- A wishlist means the customer saved a product.
- A product view means the customer showed browsing interest.
- A completed paid order means the customer actually purchased.

The queries keep these ideas separate so the logic stays clear.

## Similar Customer Logic

The similar customer logic is intentionally simple.

The project finds customers who purchased from overlapping categories.

Then it recommends products bought by similar customers that the target customer has not purchased yet.

This is not advanced collaborative filtering. It is a beginner-friendly SQL version of the same general idea:

> Customers with similar behavior may be interested in similar products.

## Recommendation Scoring Logic

The project uses a simple scoring system:

| Recommendation Reason | Score |
|---|---:|
| `frequently_bought_together` | 5 |
| `wishlist_based` | 4 |
| `category_preference` | 3 |
| `similar_customer_behavior` | 3 |
| `viewed_not_purchased` | 2 |
| `popular_product` | 1 |

This makes recommendations easy to rank and explain.

## AI-Ready Feature Table Explanation

The final query builds a customer-product feature table.

It includes:

- customer ID
- product ID
- product category
- product price
- whether the customer purchased the product
- total quantity purchased
- total spend on the product
- whether the customer viewed the product
- view count
- whether the customer wishlisted the product
- whether the product matches the customer preferred category
- product popularity rank
- a simple example `recommended_label`

This is only a learning artifact.

It shows how SQL can prepare customer-product behavior features before future Data + AI work.

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
- `ROW_NUMBER`
- `RANK`
- self-joins
- anti-joins
- `CROSS JOIN`
- aggregation
- recommendation scoring
- feature table thinking

## Business Questions Answered

The project answers questions such as:

- Which products are most popular?
- Which products generate the most revenue?
- Which products are popular by category?
- What products has each customer purchased?
- What category does each customer prefer?
- Which products were viewed but not purchased?
- Which products were wishlisted but not purchased?
- Which products are frequently bought together?
- What should be recommended based on bought-together logic?
- What popular products has a customer not purchased?
- What products fit the customer’s preferred category?
- Which customers have no purchases but product views?
- What are the top recommendations per customer?
- What should a customer-product recommendation dashboard show?
- What features are useful for future recommendation models?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates customers, products, orders, interactions, and recommendation tables |
| `insert_data.sql` | Inserts fictional e-commerce behavior data |
| `analysis_queries.sql` | Contains recommendation logic and feature-table queries |
| `business_questions.md` | Maps recommendation questions to SQL concepts |
| `README.md` | Explains the project, business logic, SQL concepts, and LinkedIn reflection |

## Key Lessons

Recommendation systems do not start with AI.

They start with behavior:

- what customers bought
- what customers viewed
- what customers wishlisted
- which products are popular
- which products are often bought together
- what similar customers purchased

SQL is useful because it helps make that behavior visible, explainable, and ready for analytics or future AI workflows.

## How to Run This Project

Run the SQL files in this order:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

If you are using pgAdmin:

1. Open a PostgreSQL database.
2. Run `schema.sql`.
3. Run `insert_data.sql`.
4. Open `analysis_queries.sql` and run each query one by one.

## LinkedIn Reflection Draft

Day 18/25 — SQL for Real Business Data Systems

Today I built a basic Product Recommendation Logic project using SQL.

Important note:
This is not a machine learning recommendation system.
It is a simple SQL-based project to understand the foundation behind recommendations.

Before building AI recommendations, we need to understand customer-product behavior.

For this project, I modeled:
- customers
- products
- orders
- order_items
- payments
- product_views
- wishlists
- product_recommendations

Then I wrote SQL queries to analyze:
- popular products
- revenue by product
- customer purchase history
- customer preferred categories
- products frequently bought together
- products viewed but not purchased
- products wishlisted but not purchased
- similar customer behavior
- top recommendations per customer
- AI-ready customer-product feature table

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CTEs
- window functions
- self-joins
- CASE WHEN
- ranking
- recommendation scoring
- feature table thinking

My key lesson:
Recommendation systems do not start with AI.

They start with understanding behavior:
- what customers bought
- what they viewed
- what they wishlisted
- what similar customers purchased
- which products are commonly bought together

SQL helps prepare the foundation for recommendation engines, personalization systems, Data Engineering pipelines, feature engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

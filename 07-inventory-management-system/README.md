# Day 7 — Inventory Management System

## Project Overview

This project models a small retail or wholesale inventory system using PostgreSQL.

The goal is to show how businesses can track products, suppliers, warehouses, stock levels, stock movement, reorder rules, and inventory health.

The system tracks:

- Suppliers
- Products
- Warehouses
- Inventory
- Stock movements
- Reorder rules

This project is beginner-friendly, but it uses realistic inventory ideas such as stock movement transactions, reorder points, safety stock, stockout detection, and inventory valuation.

## Business Problem

A small retail or wholesale business wants to manage inventory more clearly.

The business owner needs to answer questions such as:

- Which products are currently low in stock?
- Which products need to be reordered?
- Which products are overstocked?
- Which products are slow-moving?
- Which suppliers provide which products?
- How much stock is available in each warehouse or branch?
- What is the total inventory value?
- Which products had the most stock movement?
- Which products are at risk of stockout?

SQL helps convert inventory records into useful purchasing, operations, and cash-flow insights.

## Database Tables

### suppliers

Stores supplier information such as supplier name, contact person, phone number, and city.

### products

Stores product information such as product name, category, supplier, unit cost, and selling price.

### warehouses

Stores warehouse or branch information such as warehouse name and city.

### inventory

Stores the current stock level for each product in each warehouse.

The unique product and warehouse pair prevents the same product from being duplicated in the same location.

### stock_movements

Stores stock activity over time.

Each row records product, warehouse, movement date, movement type, quantity, and a reference note.

### reorder_rules

Stores reorder settings for each product and warehouse.

This includes reorder point, reorder quantity, and safety stock.

## Entity Relationship Explanation

The database has six main entities:

- One supplier can provide many products.
- One product belongs to one supplier.
- One warehouse can store many products.
- One product can exist in many warehouses.
- One product can have many stock movement records.
- One product and warehouse pair can have one reorder rule.

The `inventory` table connects products and warehouses because stock is tracked by location.

The `stock_movements` table stores inventory activity over time.

The `reorder_rules` table stores the business rules used for purchasing decisions.

Foreign keys protect the data by making sure:

- Every product belongs to a real supplier.
- Every inventory record belongs to a real product and warehouse.
- Every stock movement belongs to a real product and warehouse.
- Every reorder rule belongs to a real product and warehouse.

## Inventory Movement Logic Explanation

Inventory movement is transaction-style data.

This project uses three simple movement types:

- `stock_in` means inventory came into the warehouse.
- `stock_out` means inventory left the warehouse.
- `adjustment` means inventory was corrected after a count or review.

For beginner-friendly analysis:

- Stock in and stock out are analyzed separately.
- Adjustments are stored for history but are not mixed into sales movement reports.
- `current_stock` is stored in the `inventory` table as the current operational number.

This keeps the project simple while still showing how inventory systems track activity over time.

## Reorder Logic Explanation

Reorder logic helps the business avoid stockouts.

This project uses simple rules:

- If `current_stock < reorder_point`, the product should be reordered.
- If `current_stock <= safety_stock`, the product is at stockout risk.
- If `current_stock = 0`, the product is already stocked out.
- If `current_stock > reorder_quantity * 2`, the product is treated as overstocked for this beginner project.

These rules are simple, but they teach the business logic behind inventory monitoring.

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
- Date filtering
- Common Table Expressions
- Window functions
- Aggregations
- Inventory valuation
- Reorder point analysis

## Business Questions Answered

This project answers practical questions such as:

- List all products with supplier information.
- Show current stock by product and warehouse.
- Calculate total stock available per product.
- Calculate total inventory value.
- Calculate potential sales value.
- Find products below reorder point.
- Generate reorder recommendations.
- Find products at risk of stockout.
- Find overstocked products.
- Find products with zero stock.
- Show stock movement history by product.
- Calculate total stock in by product.
- Calculate total stock out by product.
- Find fast-moving products.
- Find slow-moving products.
- Rank warehouses by total inventory value.
- Count products by category.
- Find suppliers with the most products.
- Find products with pricing problems.
- Create an inventory health summary.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic fictional inventory data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

Inventory data is not only about counting products.

A useful inventory system helps a business understand:

1. Which products are running low.
2. Which products should be reordered.
3. Which products are overstocked.
4. Which products are slow-moving.
5. Which suppliers support the product catalog.
6. How much cash is tied up in inventory.

Good inventory data helps a business reduce stockouts, avoid overbuying, protect cash flow, and make better purchasing decisions.

This is the type of business thinking that supports analytics, dashboards, Data Engineering pipelines, and future Data + AI solutions.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE inventory_management_system;
```

Connect to the database:

```bash
psql -d inventory_management_system
```

Run the files in this order:

```bash
psql -d inventory_management_system -f schema.sql
psql -d inventory_management_system -f insert_data.sql
psql -d inventory_management_system -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 7/25 — SQL for Real Business Data Systems

Today I built an Inventory Management System using SQL.

This project is very practical for small retail and wholesale businesses.

Having products in stock is not enough.

A business also needs to know:

- Which products are running low?
- Which products should be reordered?
- Which products are overstocked?
- Which products are slow-moving?
- Which suppliers provide which products?
- How much inventory value is currently stored?

For this project, I modeled:

- suppliers
- products
- warehouses
- inventory
- stock_movements
- reorder_rules

Then I wrote SQL queries to analyze:

- current stock
- inventory value
- reorder recommendations
- stockout risk
- fast-moving products
- slow-moving products
- supplier contribution
- warehouse inventory value

SQL concepts I practiced:

- joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- inventory movement logic
- reorder point analysis

My key lesson:
Inventory data is not only about counting products.

Good inventory data helps a business protect cash flow, avoid stockouts, reduce overbuying, and make better purchasing decisions.

This is a strong foundation for Data Engineering, Analytics, and future Data + AI solutions for real businesses.

Feedback and suggestions are always welcome 🙏

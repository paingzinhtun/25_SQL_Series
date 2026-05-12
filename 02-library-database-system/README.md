# Day 2 — Library Database System

## Project Overview

This project models a small library or learning center using PostgreSQL.

The goal is to show how real-world library operations become structured database tables and useful business reports.

The system tracks:

- Authors
- Books
- Members
- Borrow records

This project is beginner-friendly, but it uses professional database design ideas such as primary keys, foreign keys, unique constraints, status tracking, and reporting queries.

## Business Problem

A small library needs to manage its books, members, and borrowing activity.

The library does not only need to know which books it owns. It also needs to understand how books move through the system:

- Which books are currently borrowed?
- Which books are available?
- Which books are overdue?
- Which members borrow the most?
- Which categories are most popular?
- Which members have not borrowed any books?
- Which books have never been borrowed?
- How many books are borrowed each month?

SQL helps turn daily library operations into reliable data and practical reports.

## Database Tables

### authors

Stores author information such as author name and country.

### books

Stores book information such as title, author, category, published year, total copies, and available copies.

The `total_copies` column shows how many copies the library owns.

The `available_copies` column shows how many copies are currently available for members to borrow.

### members

Stores library member information such as name, email, phone number, city, and membership date.

### borrow_records

Stores borrowing activity. Each row represents one borrowing transaction.

This table records:

- Which member borrowed a book
- Which book was borrowed
- When the book was borrowed
- When it is due
- When it was returned
- Whether the record is borrowed, returned, or overdue

## Entity Relationship Explanation

The database has four main entities:

- One author can write many books.
- One book belongs to one author.
- One member can borrow many books over time.
- One book can appear in many borrow records over time.

The `borrow_records` table connects `members` and `books`.

This table is transaction-style data because it records activity over time. A member borrowing a book is an event. When that event happens, the library creates a new borrow record.

Foreign keys protect the data by making sure:

- Every book belongs to a real author.
- Every borrow record belongs to a real member.
- Every borrow record belongs to a real book.

The sample data is intentionally designed for analysis:

- Some books are returned.
- Some books are currently borrowed.
- Some books are overdue.
- One member has no borrow record.
- One book has never been borrowed.
- Several categories have enough activity for reporting.

In a production system, overdue status may be updated by an application or scheduled job based on the due date. In this beginner project, the `status` column keeps that logic easy to see.

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

## Business Questions Answered

This project answers practical questions such as:

- List all books with author names.
- Show all members and membership dates.
- Show current borrowed books.
- Show available books.
- Show overdue books.
- Show borrow history with member names and book titles.
- Count how many books each member has borrowed.
- Find members who have not borrowed any books.
- Find books that have never been borrowed.
- Find the most borrowed books.
- Find the most popular book categories.
- Count monthly borrow activity.
- Calculate average borrow duration for returned books.
- Show borrowing status summary.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic sample data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

SQL is not only about storing data.

A useful database starts with understanding the business process:

1. Identify the main entities.
2. Convert each entity into a table.
3. Define how the tables relate to each other.
4. Store activity as transaction records.
5. Use dates and statuses to understand what is happening now.
6. Write SQL queries that answer real operational questions.

For this project, the real-world process is library borrowing.

The `books` table stores inventory. The `members` table stores people. The `borrow_records` table stores activity.

Once the activity is stored correctly, SQL can help the library find overdue books, active members, popular categories, and unused inventory.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE library_database_system;
```

Connect to the database:

```bash
psql -d library_database_system
```

Run the files in this order:

```bash
psql -d library_database_system -f schema.sql
psql -d library_database_system -f insert_data.sql
psql -d library_database_system -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 2/25 — SQL for Real Business Data Systems

Today I built a Library Database System using SQL.

This project helped me understand how real-world operations become transaction data.

In a library, the important question is not only:
“What books do we have?”

The better questions are:

- Which books are currently borrowed?
- Which books are overdue?
- Which members are most active?
- Which categories are most popular?
- Which books have never been borrowed?

For this project, I modeled:

- authors
- books
- members
- borrow_records

SQL concepts I practiced:

- joins
- left joins
- date filtering
- grouping
- aggregation
- status tracking
- missing data detection

My key lesson:
A database is not just a place to store data.
A good database helps an organization track activity, find problems, and make better decisions.

This is the same foundation used in Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

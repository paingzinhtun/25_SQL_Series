# Day 6 — Simple Banking System

## Project Overview

This project models a simple banking or digital wallet system using PostgreSQL.

The goal is to show how financial transaction data can be structured and analyzed with SQL.

The system tracks:

- Customers
- Branches
- Accounts
- Transactions

This is a learning project, not a real production banking system. It avoids sensitive information and uses fictional sample data.

## Business Problem

A small bank or digital wallet company wants to manage customers, accounts, branches, balances, and transactions.

The business needs to answer questions such as:

- Which customers have which accounts?
- What is the current balance of each account?
- How much money was deposited or withdrawn?
- Which transactions failed or are still pending?
- Which accounts have the highest balances?
- Which branches hold the most total customer balance?
- Which customers made the most transactions?
- Are there unusual large transactions?
- How can we calculate running balance over time?

SQL helps turn financial records into useful operational and reporting insights.

## Database Tables

### customers

Stores customer profile information such as name, email, phone number, city, and customer type.

Customer type can be individual or business.

### branches

Stores bank branch information such as branch name and city.

### accounts

Stores bank account information such as account number, customer, branch, account type, opening date, current balance, and account status.

Account type can be savings, current, or business.

Account status can be active, frozen, or closed.

### transactions

Stores transaction activity for each account.

Transaction type can be deposit, withdrawal, transfer_in, transfer_out, or fee.

Transaction status can be success, failed, or pending.

## Entity Relationship Explanation

The database has four main entities:

- One customer can have many accounts.
- One branch can manage many accounts.
- One account belongs to one customer.
- One account belongs to one branch.
- One account can have many transactions.

Foreign keys protect the data by making sure:

- Every account belongs to a real customer.
- Every account belongs to a real branch.
- Every transaction belongs to a real account.

## Transaction Logic Explanation

This project uses simple debit and credit logic:

- `deposit` increases balance.
- `transfer_in` increases balance.
- `withdrawal` decreases balance.
- `transfer_out` decreases balance.
- `fee` decreases balance.

Transaction status is important.

Only transactions with `transaction_status = 'success'` should count as completed money movement.

Failed and pending transactions are still stored because they are useful for operations, support, and risk review. However, they should not change balances or completed financial reports.

The running balance query uses this rule:

- Successful deposits and transfer_in become positive amounts.
- Successful withdrawals, transfer_out, and fees become negative amounts.
- Failed and pending transactions become zero movement.

This keeps the SQL beginner-friendly while still teaching an important financial reporting idea.

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
- Aggregations
- Debit and credit logic
- Running balance calculation

## Business Questions Answered

This project answers practical questions such as:

- List all customers.
- List all accounts with customer and branch information.
- Show all successful transactions.
- Show failed and pending transactions.
- Calculate total deposits.
- Calculate total withdrawals.
- Calculate net money movement per account.
- Show current balance for each account.
- Find top 5 accounts by current balance.
- Find total customer balance by branch.
- Count accounts by account type.
- Count accounts by account status.
- Find customers with more than one account.
- Find customers with the highest number of transactions.
- Find large transactions above a chosen threshold.
- Calculate daily transaction volume.
- Calculate running balance per account.
- Show transaction summary by transaction type and status.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic fictional banking data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

Financial data requires careful logic.

It is not enough to simply sum all transactions.

A good banking report needs to understand:

1. Which transaction types increase money.
2. Which transaction types decrease money.
3. Which statuses represent completed movement.
4. Which statuses should be excluded from completed financial calculations.
5. How balances change over time.

This is why clear data modeling and business rules matter before building reports, dashboards, pipelines, or Data + AI systems.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE simple_banking_system;
```

Connect to the database:

```bash
psql -d simple_banking_system
```

Run the files in this order:

```bash
psql -d simple_banking_system -f schema.sql
psql -d simple_banking_system -f insert_data.sql
psql -d simple_banking_system -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 6/25 — SQL for Real Business Data Systems

Today I built a Simple Banking System using SQL.

This project helped me understand how financial transaction data works at a basic level.

In banking or digital wallet systems, the important part is not only storing transactions.

The real challenge is understanding money movement correctly.

For this project, I modeled:

- customers
- branches
- accounts
- transactions

Then I wrote SQL queries to answer questions like:

- Which customers have which accounts?
- What is the current balance of each account?
- How much money was deposited or withdrawn?
- Which transactions failed or are still pending?
- Which branches hold the most customer balance?
- Which customers made the most transactions?
- How can we calculate running balance over time?

SQL concepts I practiced:

- joins
- grouping
- aggregation
- CASE WHEN
- transaction status filtering
- debit and credit logic
- CTEs
- window functions
- running balance calculation

My key lesson:
In financial data, accuracy matters more than clever queries.

A wrong filter or wrong transaction logic can change the meaning of the numbers.

This is why clean data modeling, clear business rules, and careful SQL logic are important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

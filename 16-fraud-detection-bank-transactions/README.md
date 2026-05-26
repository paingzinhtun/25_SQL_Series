# Day 16 — Fraud Detection with Bank Transactions

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to practice intermediate SQL using a realistic financial monitoring use case. The project shows how banks, fintech apps, or digital wallet companies can use SQL to identify transaction patterns that may need manual review.

This project focuses on:

- customer, account, and card relationships
- transaction monitoring
- failed and declined transaction analysis
- high-value transaction detection
- late-night activity checks
- location-based review patterns
- rapid transaction analysis
- simple rule-based risk scoring
- dashboard-ready monitoring output

## Important Disclaimer

This is **not** a real fraud detection system.

This project does **not** confirm fraud.

It only demonstrates how SQL can be used to flag unusual transaction patterns for review. Real financial monitoring systems require stronger controls, domain experts, compliance review, privacy protection, model governance, and careful human decision-making.

In this project, a flagged transaction means:

> This transaction may need review.

It does not mean:

> This transaction is a confirmed issue.

## Business Problem

A bank or digital wallet company wants to monitor transactions across accounts, cards, merchants, locations, and channels.

The business wants to answer questions such as:

- Which transactions are unusually large?
- Which accounts have many failed or declined transactions?
- Which cards had repeated declined payments?
- Which customers made transactions from different cities or countries close together?
- Which transactions happened late at night?
- Which customers should be prioritized for manual review?
- Which transaction channels or types have higher review rates?

The purpose is to support responsible risk monitoring, not automatic accusation.

## Database Tables

| Table | Purpose |
|---|---|
| `customers` | Stores customer profile information such as name, city, and customer type |
| `accounts` | Stores bank or wallet accounts linked to customers |
| `cards` | Stores fictional masked cards linked to accounts |
| `merchants` | Stores merchant names, categories, cities, and countries |
| `transactions` | Stores transaction activity across accounts, cards, merchants, channels, and locations |
| `fraud_rules` | Stores simple review rules and risk scores |
| `flagged_transactions` | Stores transactions flagged for review by a rule |

## Entity Relationship Explanation

The database follows a simple financial monitoring structure:

- One customer can have one or more accounts.
- One account can have one or more cards.
- Each transaction belongs to an account.
- Each transaction uses a card.
- Each transaction happens with a merchant.
- A transaction can be flagged by one or more review rules.
- Each flag connects a transaction to a rule.

This design separates the main business entities:

- customers
- accounts
- cards
- merchants
- transactions
- rules
- review flags

That separation makes the data easier to query, explain, and audit.

## Transaction Monitoring Explanation

The `transactions` table stores the most important activity:

- when the transaction happened
- which account and card were used
- which merchant was involved
- transaction type
- amount
- status
- city and country
- channel

This makes it possible to analyze patterns such as:

- high-value transactions
- failed or declined transactions
- late-night activity
- transactions from different locations
- rapid transaction sequences

## Rule-Based Detection Explanation

This project uses simple rule-based logic.

Example rules include:

- transaction amount is at or above 1,000,000 MMK
- transaction happens between 11 PM and 5 AM
- several transactions happen within a few minutes
- card has repeated declined activity
- transaction country differs from normal local activity
- transaction amount is much higher than the customer's normal amount

These rules are intentionally simple so SQL learners can understand the logic.

## Risk Scoring Explanation

Each rule has a `risk_score`.

When a transaction is flagged by one or more active rules, the query can sum the rule scores:

```sql
total_risk_score = sum of active rule risk scores
```

The project then groups transactions into review levels:

| Risk Level | Meaning |
|---|---|
| `normal` | No review rule matched |
| `low_review` | One or more low-score review signals |
| `medium_review` | Stronger review signal |
| `high_review` | Multiple or high-score review signals |

These labels are only review priorities. They are not final decisions.

## Fraud Monitoring Dashboard View Explanation

The final dashboard query produces a transaction-level monitoring view with:

- transaction ID
- transaction date and time
- customer name
- account number
- masked card number
- merchant name
- merchant category
- transaction type
- channel
- amount
- transaction status
- transaction city and country
- review reason
- estimated review level

This is useful for analysts because it combines many related tables into one readable output.

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
- `LAG`
- `AVG OVER`
- `RANK`
- date and time functions
- filtered counts
- `COUNT(DISTINCT)`
- `COALESCE`
- `NULLIF`
- rule-based scoring
- dashboard-style SQL output

## Risk Questions Answered

The analysis queries answer questions such as:

- Which transactions are high-value?
- Which transactions failed or were declined?
- Which accounts have multiple failed or declined transactions?
- Which cards have repeated declined transactions?
- Which transactions happened late at night?
- Which accounts had rapid transactions?
- Which customers used multiple cities on the same day?
- Which customers used multiple countries close together?
- Which transactions happened away from the customer home city?
- Which transactions are sudden amount spikes?
- Which merchants have high failed activity?
- Which merchant categories have the most flagged transactions?
- Which rules generate the most review flags?
- What is the flag rate by channel?
- What is the flag rate by transaction type?
- What is the risk score per transaction?
- Which customers have the highest total risk score?
- What should a basic fraud monitoring dashboard show?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts fictional sample data for customers, accounts, cards, merchants, transactions, rules, and review flags |
| `analysis_queries.sql` | Contains risk monitoring and dashboard queries |
| `business_questions.md` | Maps each risk question to business value and SQL concepts |
| `README.md` | Explains the project, business logic, SQL concepts, and LinkedIn reflection |

## Key Lessons

SQL can help risk teams find patterns that deserve attention.

But responsible interpretation matters.

A high transaction amount, late-night transaction, or different city does not automatically mean wrongdoing. It may be a normal business payment, travel activity, or customer behavior.

The important lesson is:

> Good financial monitoring should be explainable, careful, and review-focused.

This project also shows why clean data modeling matters. Without proper relationships between customers, accounts, cards, merchants, transactions, and rules, it is difficult to build useful monitoring reports.

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

Day 16/25 — SQL for Real Business Data Systems

Today I built a basic Fraud Detection with Bank Transactions project using SQL.

Important note:
This is not a real fraud detection system.
It does not confirm fraud.
It only shows how SQL can be used to flag unusual transaction patterns for review.

For this project, I modeled:
- customers
- accounts
- cards
- merchants
- transactions
- fraud_rules
- flagged_transactions

Then I wrote SQL queries to analyze:
- high-value transactions
- failed and declined transactions
- repeated declined card activity
- late-night transactions
- rapid transactions from the same account
- transactions from different cities
- transactions from different countries
- transaction amount spikes
- flagged transactions by rule
- customer-level risk review list
- basic fraud monitoring dashboard view

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- LAG
- date/time analysis
- rule-based scoring
- risk monitoring logic

My key lesson:
Fraud analytics is not about accusing people.

It is about building careful, explainable systems that help teams review unusual patterns.

In financial data, accuracy, context, and responsible interpretation matter a lot.

This foundation is important for risk analytics, Data Engineering, financial monitoring, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

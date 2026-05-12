# Day 3 — Employee Salary Tracker

## Project Overview

This project models a small company's employee and payroll data using PostgreSQL.

The goal is to show how HR and payroll operations become structured database tables and useful business reports.

The system tracks:

- Departments
- Job roles
- Employees
- Current salaries
- Salary history

This project is beginner-friendly, but it follows practical database design ideas such as primary keys, foreign keys, unique constraints, status tracking, salary checks, and business-focused analysis queries.

## Business Problem

A small company needs to manage employees, departments, job roles, current salaries, and salary changes over time.

The company wants to answer questions such as:

- Which employees work in each department?
- What is the total salary cost by department?
- What is the average salary by department?
- Which employees earn the highest salaries?
- Which employees recently received salary changes?
- Which job roles are most expensive?
- Are there employees without salary records?

SQL helps turn HR operations into structured data that can support payroll reporting, workforce planning, and business decision-making.

## Database Tables

### departments

Stores company departments such as Engineering, Sales, Finance, Human Resources, and Operations.

### job_roles

Stores job titles and connects each role to a department.

For example, a Data Engineer role belongs to the Engineering department.

### employees

Stores employee profile information such as name, email, phone number, gender, city, department, role, hire date, and employment status.

The `employment_status` column tracks whether an employee is active, resigned, or on probation.

### salaries

Stores the current monthly salary for each employee.

In this beginner project, each employee can have only one current salary record. This is enforced with a `UNIQUE` constraint on `employee_id`.

### salary_history

Stores salary changes over time.

Each row records:

- The employee
- The old salary
- The new salary
- The change date
- The reason for the change

This table helps answer questions about raises, adjustments, and salary growth.

## Entity Relationship Explanation

The database has five main entities:

- One department can have many job roles.
- One department can have many employees.
- One job role can be assigned to many employees.
- One employee can have one current salary record.
- One employee can have many salary history records.

The `employees` table connects people to departments and job roles.

The `salaries` table stores current payroll cost.

The `salary_history` table stores historical salary changes. This is useful because payroll analysis often needs both the current amount and the change over time.

Foreign keys protect the data by making sure:

- Every job role belongs to a real department.
- Every employee belongs to a real department.
- Every employee has a real job role.
- Every salary record belongs to a real employee.
- Every salary history record belongs to a real employee.

The sample data is intentionally designed for analysis:

- Employees work across multiple departments.
- There are active, resigned, and probation employees.
- Some employees have no current salary record.
- Several employees have salary history records.
- Salary amounts vary enough to support ranking, salary bands, and department payroll analysis.

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

- List all employees with department and job role.
- Show all active employees.
- Show employees by employment status.
- Count employees per department.
- Calculate total monthly salary cost by department.
- Calculate average salary by department.
- Find the top 5 highest-paid employees.
- Find employees without current salary records.
- Show salary history for each employee.
- Find employees who received salary increases.
- Calculate salary increase amount and percentage.
- Rank departments by payroll cost.
- Find job roles with the highest average salary.
- Group employees into salary bands.
- Show company payroll summary.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic sample data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

SQL is not only useful for customer-facing data.

A useful internal business database starts by understanding the process:

1. Identify the main business entities.
2. Convert each entity into a table.
3. Define how the tables relate to each other.
4. Store current operational data.
5. Store history when changes matter.
6. Write SQL queries that answer business questions.

For this project, the real-world process is HR and payroll tracking.

The `employees` table stores workforce structure. The `salaries` table stores current payroll cost. The `salary_history` table stores salary changes over time.

Once this data is structured clearly, SQL can help the business understand department cost, salary gaps, role cost, employee status, and payroll planning.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE employee_salary_tracker;
```

Connect to the database:

```bash
psql -d employee_salary_tracker
```

Run the files in this order:

```bash
psql -d employee_salary_tracker -f schema.sql
psql -d employee_salary_tracker -f insert_data.sql
psql -d employee_salary_tracker -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 3/25 — SQL for Real Business Data Systems

Today I built an Employee Salary Tracker using SQL.

This project helped me understand how companies can use structured data to manage employees, departments, roles, and salary costs.

At first, it looks like a simple HR database.

But the real business questions are important:

- Which departments have the highest salary cost?
- What is the average salary by department?
- Which employees received salary increases?
- Which employees do not have salary records yet?
- Which job roles cost the company the most?

For this project, I modeled:

- departments
- job_roles
- employees
- salaries
- salary_history

SQL concepts I practiced:

- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- salary band analysis

My key lesson:
SQL is not only useful for sales or customer data.
It is also useful for internal business operations like HR, payroll, and workforce planning.

A good data system helps a business understand cost, people, and structure more clearly.

This foundation is important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

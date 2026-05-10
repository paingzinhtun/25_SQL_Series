# Day 1 — Student Management System

## Project Overview

This project models a small training center or school using PostgreSQL.

The goal is to show how real-world business entities become database tables, how those tables connect through relationships, and how SQL can answer useful operational questions.

The system tracks:

- Students
- Instructors
- Courses
- Enrollments

This is a beginner-friendly project, but it follows professional database design principles such as primary keys, foreign keys, unique constraints, clear naming, and business-focused reporting queries.

## Business Problem

A small training center needs a simple way to manage students, courses, instructors, and enrollments.

Without structured data, the school may struggle to answer questions such as:

- Which students are enrolled in each course?
- Which instructor teaches each course?
- How many students are enrolled in each course?
- Which courses are popular?
- Which students have not enrolled yet?
- Which courses have no students?
- How much revenue can each course generate?

SQL helps convert these daily business activities into structured tables and useful reports.

## Database Tables

### students

Stores student profile information such as name, email, phone number, date of birth, gender, and city.

### instructors

Stores instructor information including name, email, and area of expertise.

### courses

Stores course details such as course name, category, assigned instructor, course fee, start date, and end date.

### enrollments

Connects students to courses. This table records which student enrolled in which course, the enrollment date, and the enrollment status.

## Entity Relationship Explanation

The database has four main entities:

- A student can enroll in many courses.
- A course can have many students.
- An instructor can teach many courses.
- Each course is taught by one instructor.

The `enrollments` table is the bridge between `students` and `courses`.

This creates a many-to-many relationship:

- One student can appear in many enrollment records.
- One course can appear in many enrollment records.

Foreign keys protect the data by making sure:

- Every enrollment belongs to a real student.
- Every enrollment belongs to a real course.
- Every course is assigned to a real instructor.

The sample data is intentionally designed for analysis:

- Some students are enrolled in multiple courses.
- One student has no enrollment yet.
- One course has no enrolled students.
- Enrollment statuses include active, completed, and dropped.

These details make the JOIN, LEFT JOIN, GROUP BY, HAVING, and CASE WHEN examples easier to understand.

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
- Common Table Expressions
- Window functions
- Aggregations

## Business Questions Answered

This project answers practical questions such as:

- List all students.
- List all courses with instructor names.
- Show which students are enrolled in which courses.
- Count students per course.
- Find courses with no students.
- Find students with no enrollments.
- Find students enrolled in more than one course.
- Count active, completed, and dropped enrollments.
- Show expected revenue per course.
- Rank courses by enrolled student count.
- Find the most popular course category.
- Show each student's learning history.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic sample data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

SQL is not only about writing queries.

A good SQL project starts by understanding the business process:

1. Identify the real-world entities.
2. Convert each entity into a table.
3. Define relationships between tables.
4. Insert realistic data.
5. Ask business questions.
6. Write SQL queries that produce useful answers.

For this project, the real-world process is student enrollment. The main entities are students, instructors, courses, and enrollments.

Once those entities are structured properly, SQL can answer questions that help the school make better decisions.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE student_management_system;
```

Connect to the database:

```bash
psql -d student_management_system
```

Run the files in this order:

```bash
psql -d student_management_system -f schema.sql
psql -d student_management_system -f insert_data.sql
psql -d student_management_system -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 1/25 — SQL for Real Business Data Systems

Today I built a Student Management System using SQL.

At first, it looks like a simple beginner project.

But the real lesson is important:

Before building dashboards, pipelines, or AI systems, we need to understand how real-world data is structured.

In this project, I modeled:

- students
- instructors
- courses
- enrollments

Then I wrote SQL queries to answer questions like:

- Which students are enrolled in which courses?
- Which courses have the most students?
- Which students are not enrolled yet?
- How much expected revenue can each course generate?

SQL concepts I practiced:

- primary keys
- foreign keys
- joins
- aggregations
- left joins
- grouping
- ranking

My key lesson:
SQL is not just about syntax.
It is about understanding entities, relationships, and business questions.

This foundation is important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

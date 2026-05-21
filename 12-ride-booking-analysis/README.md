# Day 12 — Ride Booking Analysis

## Project Overview

This project analyzes ride-booking marketplace data using PostgreSQL.

The goal is to understand how platforms like Uber, Grab, or local taxi apps can track trips, riders, drivers, payments, cancellations, ratings, peak hours, routes, and operational performance.

This is an intermediate SQL project because it does not only count records. It connects multiple business areas:

- rider behavior
- driver performance
- trip lifecycle
- payment status
- cancellation reasons
- location and route demand
- service quality ratings
- marketplace KPI reporting

## Business Problem

A ride-booking company needs to understand more than total bookings.

Useful business questions include:

- Which drivers complete the most trips?
- Which riders book most frequently?
- Which trips were cancelled?
- Who cancels more: riders, drivers, or the system?
- Which booking hours are busiest?
- Which routes are most common?
- Which drivers have low ratings?
- How much real revenue did completed and paid trips generate?

SQL helps connect trip activity, payment status, driver supply, rider demand, and service quality into useful operational insight.

## Database Tables

### riders

Stores customer profile information such as rider name, email, city, and signup date.

### drivers

Stores driver profile information such as driver name, city, join date, and driver status.

Driver status can be:

- `active`
- `inactive`
- `suspended`

### vehicles

Stores the vehicle assigned to each driver.

Vehicle type can be:

- `taxi`
- `private_car`
- `motorcycle`
- `premium`

### locations

Stores pickup and dropoff locations.

Each location has a city and location type such as airport, mall, hotel, business area, residential area, or bus station.

### trips

Stores the main ride-booking transaction.

Each trip connects:

- one rider
- one driver
- one pickup location
- one dropoff location

It also stores booking time, pickup time, dropoff time, trip status, cancellation information, distance, duration, and fare.

### payments

Stores payment method, payment status, and payment amount for each trip.

Payment status is important because not every trip is real revenue.

### trip_ratings

Stores rider and driver ratings after completed trips.

Ratings are between 1 and 5.

## Entity Relationship Explanation

The main relationships are:

- One rider can book many trips.
- One driver can complete many trips.
- One driver has one vehicle in this beginner-friendly model.
- One trip has one pickup location and one dropoff location.
- One trip has one payment record.
- One completed trip can have one rating record.

Foreign keys protect these relationships.

For example:

- `trips.rider_id` must match a real rider.
- `trips.driver_id` must match a real driver.
- `trips.pickup_location_id` and `trips.dropoff_location_id` must match real locations.
- `payments.trip_id` must match a real trip.
- `trip_ratings.trip_id` must match a real trip.

## Trip Lifecycle Explanation

A trip can move through different statuses:

- `requested`: the trip has been requested but is not completed yet
- `in_progress`: the trip has started but has not finished yet
- `completed`: the trip was successfully completed
- `cancelled`: the trip was cancelled

Completed trips can have final distance, duration, fare, payment, and ratings.

Cancelled, requested, and in-progress trips should not be treated the same as completed trips in performance analysis.

## Revenue Logic Explanation

Revenue is counted only when both conditions are true:

- `trip_status = 'completed'`
- `payment_status = 'paid'`

This means the following records are excluded from real revenue:

- cancelled trips
- requested trips
- in-progress trips
- unpaid payments
- refunded payments
- failed payments

This rule is repeated in the SQL queries so the business logic stays clear.

## Cancellation Logic Explanation

Cancellation analysis uses trips where:

```sql
trip_status = 'cancelled'
```

The `cancelled_by` column shows who cancelled:

- `rider`
- `driver`
- `system`

The cancellation rate is calculated as:

```sql
cancelled trips / total trips
```

The SQL uses `NULLIF` to avoid division by zero.

## Driver Performance Logic Explanation

Driver performance is analyzed using:

- completed trip count
- completed paid revenue
- average driver rating
- low-rating detection
- driver ranking

This helps a platform understand both productivity and service quality.

A driver with many trips but low ratings may need support or review.

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
- Window functions
- `RANK()`
- `DENSE_RANK()`
- `EXTRACT`
- `DATE_TRUNC`
- `FILTER`
- `COALESCE`
- `NULLIF`
- date and time analysis
- revenue filtering
- cancellation analysis
- marketplace KPI analysis

## Business Questions Answered

The analysis queries answer questions such as:

- Who are all riders and drivers?
- Which vehicles are assigned to drivers?
- Which trips were completed and paid?
- What is total revenue?
- What is the average fare?
- What is the average trip distance and duration?
- Which riders book most often?
- Which drivers complete the most trips?
- Which drivers generate the most revenue?
- Which riders or drivers have no completed trips?
- What are the trip and payment status summaries?
- Who cancels more: riders, drivers, or the system?
- What is the cancellation rate?
- What are the peak booking hours?
- What are the top pickup and dropoff locations?
- What are the most common routes?
- Which drivers have low average ratings?
- What does an operational KPI summary look like?

## Files in This Project

| File | Description |
| --- | --- |
| `schema.sql` | Creates tables, relationships, and constraints |
| `insert_data.sql` | Inserts fictional ride-booking sample data |
| `analysis_queries.sql` | Contains operational and marketplace analysis queries |
| `business_questions.md` | Maps each question to business value and SQL concepts |
| `README.md` | Explains the project and learning goals |

## Key Lessons

Ride-booking data is marketplace data.

The platform has to balance demand from riders and supply from drivers.

SQL helps answer operational questions such as:

- Are riders booking frequently?
- Are drivers completing trips?
- Are cancellations too high?
- Are certain hours busier than others?
- Are some drivers receiving low ratings?
- Which routes and locations need more driver coverage?

The most important lesson is that business rules matter.

If cancelled, unpaid, refunded, or failed records are counted as revenue, the analysis becomes misleading.

## How to Run This Project

Run the files in this order using PostgreSQL:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

If you are using pgAdmin:

1. Open `schema.sql` and run it.
2. Open `insert_data.sql` and run it.
3. Open `analysis_queries.sql` and run each query one by one.

## LinkedIn Reflection Draft

Day 12/25 — SQL for Real Business Data Systems

Today I built a Ride Booking Analysis project using SQL.

This project helped me understand marketplace and operations data more deeply.

A ride-booking platform is not only about completed trips.

It also needs to understand:
- riders
- drivers
- vehicles
- pickup locations
- dropoff locations
- payments
- cancellations
- ratings
- peak hours
- routes

For this project, I modeled:
- riders
- drivers
- vehicles
- locations
- trips
- payments
- trip_ratings

Then I wrote SQL queries to analyze:
- total revenue
- average fare
- average distance
- average duration
- top riders
- top drivers
- cancellation rate
- cancellation reasons
- peak booking hours
- daily trip volume
- monthly revenue trend
- top pickup/dropoff locations
- most common routes
- driver ratings
- operational KPI summary

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- date/time analysis
- cancellation logic
- revenue filtering
- marketplace KPI analysis

My key lesson:
For platform businesses, completed transactions are only one part of the story.

The business also needs to understand demand, supply, delays, cancellations, service quality, and user behavior.

This kind of analysis is important for Data Engineering, Analytics, marketplace operations, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

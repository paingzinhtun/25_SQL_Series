# Day 19 — Logistics & Delivery Optimization

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to build a beginner-friendly but professional intermediate SQL project for logistics and delivery operations analysis.

This project shows how SQL can help analyze:

- delivery lifecycle performance
- delayed shipments
- failed and returned shipments
- route efficiency
- warehouse dispatch volume
- courier performance
- SLA breaches
- delivery cost
- cost per kilometer
- operational bottlenecks

## Business Problem

A logistics or e-commerce delivery company wants to improve delivery performance.

The business should not only ask:

> How many deliveries did we complete?

It should also ask:

- Which deliveries were delayed?
- Which routes have the most delays?
- Which couriers complete the most deliveries?
- Which warehouses dispatch the most shipments?
- Which cities and zones have the highest volume?
- Which couriers have high failed delivery rates?
- Which zones are expensive to deliver to?
- Which routes exceed SLA?
- Where are the operational bottlenecks?

## Database Tables

| Table | Purpose |
|---|---|
| `warehouses` | Stores origin warehouses and capacity |
| `couriers` | Stores courier details, vehicle type, and status |
| `customers` | Stores customer delivery information |
| `delivery_zones` | Stores destination zones and zone types |
| `routes` | Stores warehouse-to-zone routes, distance, and expected hours |
| `orders` | Stores customer order details |
| `shipments` | Tracks delivery assignment, timing, status, and attempts |
| `delivery_events` | Stores shipment lifecycle events |
| `delivery_costs` | Stores delivery cost components |

## Entity Relationship Explanation

The delivery flow connects multiple business entities:

- A customer places an order.
- An order has one shipment.
- A shipment is dispatched from a warehouse.
- A shipment is handled by a courier.
- A shipment follows a route.
- A route connects a warehouse to a delivery zone.
- A shipment has delivery events.
- A shipment has delivery cost records.

This structure makes it possible to analyze delivery performance from different angles:

- warehouse performance
- route performance
- courier performance
- zone cost
- customer delivery status

## Delivery Lifecycle Explanation

The simplified shipment lifecycle in this project includes:

1. `pending`
2. `dispatched`
3. `in_transit`
4. `delivered`
5. `delayed`
6. `failed`
7. `returned`

The `delivery_events` table stores event-level history such as:

- picked up
- departed warehouse
- arrived hub
- out for delivery
- delivery attempted
- delivered
- failed
- returned

## Delay Logic Explanation

A delivery is considered delayed when:

```sql
actual_delivery_time > expected_delivery_time
```

or when:

```sql
shipment_status = 'delayed'
```

Delay duration is calculated as:

```sql
actual_delivery_time - expected_delivery_time
```

Incomplete shipments with `actual_delivery_time IS NULL` are excluded from delivery duration calculations.

## SLA Breach Logic Explanation

Each route has an expected delivery time in hours.

Delivery duration is calculated as:

```sql
actual_delivery_time - dispatch_time
```

SLA breach is defined as:

```sql
delivery duration in hours > expected_delivery_hours
```

This is a simplified learning rule that helps learners understand operational KPI logic.

## Cost Analysis Logic

Delivery cost is split into:

- base cost
- distance cost
- handling cost
- failed attempt cost
- total cost

Cost per kilometer is calculated as:

```sql
total_cost / distance_km
```

The queries use `NULLIF` to avoid division by zero.

## Route Performance Dashboard View Explanation

The route dashboard query includes:

- route ID
- route name
- origin warehouse
- destination zone
- city
- zone type
- distance
- expected delivery hours
- total shipments
- delivered shipments
- delayed shipments
- failed shipments
- returned shipments
- average delivery hours
- delay rate
- failed rate
- SLA breach rate
- average delivery cost
- cost per kilometer
- route health status

This creates a practical route-level operations report.

## Courier Performance Dashboard View Explanation

The courier dashboard query includes:

- courier ID
- courier name
- city
- vehicle type
- courier status
- total shipments
- completed deliveries
- delayed deliveries
- failed deliveries
- returned deliveries
- average delivery hours
- delay rate
- failed rate
- courier performance status

This helps compare courier workload, reliability, and delivery quality.

## Recommended Operational Actions

The project uses `CASE WHEN` to create simple operational actions:

- Monitor route
- Improve route planning
- Review courier performance
- Reduce failed attempts
- Investigate high delivery cost
- Maintain current performance

These actions are intentionally simple so learners can connect metrics to decisions.

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
- `RANK`
- filtered aggregation
- date/time calculations
- `DATE_TRUNC`
- `COALESCE`
- `NULLIF`
- SLA logic
- cost analysis
- operations dashboard thinking

## Business Questions Answered

The project answers questions such as:

- Which deliveries were delayed?
- Which routes have the highest delay rate?
- Which routes breached SLA?
- Which couriers completed the most deliveries?
- Which couriers have high delay or failure rates?
- Which warehouses dispatch the most shipments?
- What is the average delivery time?
- What is the average delivery cost?
- Which zones are expensive to deliver to?
- Which shipments had multiple delivery attempts?
- What is the failed attempt cost impact?
- What is daily shipment volume?
- What is the monthly delivery performance trend?
- What should a route performance dashboard show?
- What should a courier performance dashboard show?
- What operational action should be recommended?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates the logistics database tables, keys, and constraints |
| `insert_data.sql` | Inserts fictional logistics, shipment, event, and cost data |
| `analysis_queries.sql` | Contains delivery performance, route, courier, cost, and dashboard queries |
| `business_questions.md` | Maps operations questions to SQL concepts |
| `README.md` | Explains the project, business logic, SQL concepts, and LinkedIn reflection |

## Key Lessons

Logistics data is not only about tracking packages.

Good delivery data helps a business:

- find delay patterns
- reduce failed deliveries
- improve route planning
- monitor courier performance
- control delivery cost
- improve customer experience

The key lesson is:

> Operational data becomes valuable when it helps teams find bottlenecks and make better decisions.

This project is not a real optimization algorithm. It demonstrates how SQL can prepare clean operational insights for future optimization, dashboards, and Data + AI systems.

## How to Run This Project

Run the SQL files in this order:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

If you are using pgAdmin:

1. Open your PostgreSQL database.
2. Run `schema.sql`.
3. Run `insert_data.sql`.
4. Open `analysis_queries.sql` and run each query one by one.

## LinkedIn Reflection Draft

Day 19/25 — SQL for Real Business Data Systems

Today I built a Logistics & Delivery Optimization project using SQL.

This project helped me understand how delivery operations can be analyzed using data.

A logistics business should not only ask:

“How many deliveries did we complete?”

It should also ask:
- which deliveries were delayed?
- which routes cause the most delays?
- which couriers have the best performance?
- which warehouses handle the most shipments?
- which zones are expensive to deliver to?
- which shipments breached SLA?
- where are the operational bottlenecks?

For this project, I modeled:
- warehouses
- couriers
- customers
- delivery_zones
- routes
- orders
- shipments
- delivery_events
- delivery_costs

Then I wrote SQL queries to analyze:
- delivery status
- delayed shipments
- failed deliveries
- returned shipments
- average delivery time
- SLA breaches
- route delay rate
- courier performance
- warehouse volume
- delivery cost
- cost per kilometer
- multiple delivery attempts
- route performance dashboard
- courier performance dashboard
- recommended operational actions

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- date/time calculations
- SLA logic
- cost analysis
- operations dashboard thinking

My key lesson:
Logistics data is not only about tracking packages.

It helps a business find delays, reduce failed deliveries, control cost, and improve customer experience.

This foundation is important for logistics analytics, operations analytics, Data Engineering, route optimization, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

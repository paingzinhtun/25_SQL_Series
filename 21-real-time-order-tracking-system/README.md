# Day 21 - Real-Time Order Tracking System (Simulated with SQL)

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to simulate how an e-commerce, food delivery, or logistics platform can track orders using timestamped operational events.

This is an advanced SQL project because it focuses on current-state logic, event timelines, SLA monitoring, stuck orders, driver activity, warehouse load, and operational dashboards.

## Important Disclaimer

This is **not** a true real-time streaming system.

It does not use Kafka, message queues, WebSockets, or distributed streaming infrastructure.

This project simulates real-time operational tracking using SQL tables, timestamped event logs, and dashboard-style queries.

## Business Problem

An e-commerce or delivery platform wants to track what is happening in operations right now.

The business wants to answer questions such as:

- Which orders are currently being prepared?
- Which orders are out for delivery?
- Which orders are delayed?
- Which orders are stuck at a status too long?
- Which drivers are currently active?
- Which warehouses are overloaded?
- Which orders missed SLA?
- Which customers are waiting too long?
- Which regions have operational bottlenecks?
- What is happening right now in operations?

## Database Tables

| Table | Purpose |
|---|---|
| `customers` | Stores customer information and city. |
| `warehouses` | Stores fulfillment locations and warehouse status. |
| `drivers` | Stores driver information, vehicle type, and current driver status. |
| `orders` | Stores customer orders, expected delivery time, amount, and payment status. |
| `order_items` | Stores products inside each order. |
| `order_status_events` | Core event log table for order status changes. |
| `delivery_routes` | Stores route distance, estimated duration, actual duration, and route status. |
| `driver_locations` | Stores timestamped driver location updates. |
| `operational_alerts` | Stores operational alerts for delayed orders, SLA breaches, inactive drivers, and route issues. |

## Entity Relationship Explanation

One customer can place many orders.

One warehouse can fulfill many orders.

One driver can be assigned to many orders.

One order can contain many order items.

One order can have many status events. This is the key event-driven part of the project.

One order has one delivery route in this simplified model.

One driver can have many location updates.

Operational alerts can be connected to an order, a driver, or both.

## Event-Driven Tracking Explanation

Instead of storing only one status column on the order, this project stores every status change in `order_status_events`.

Example event sequence:

```text
order_placed
payment_confirmed
preparing
packed
dispatched
in_transit
out_for_delivery
delivered
```

This event log allows SQL to answer both historical and current-state questions.

## Latest Status Logic

The latest order status is found with:

```sql
ROW_NUMBER() OVER (
    PARTITION BY order_id
    ORDER BY event_time DESC
)
```

The row with `ROW_NUMBER = 1` is the current status for that order.

This is one of the most important patterns in operational analytics.

## SLA Monitoring Logic

SLA means the promised service time.

In this project, an order missed SLA when:

```sql
delivered_time > expected_delivery_datetime
```

The SLA breach rate is calculated as:

```sql
sla_breached_deliveries / total_delivered_orders
```

`NULLIF` is used in rate calculations to avoid division by zero.

## Operational Alert Logic

Alerts are stored in `operational_alerts`.

Example alert types:

- `delayed_order`
- `sla_breach`
- `inactive_driver`
- `warehouse_overload`
- `failed_delivery`
- `route_delay`

Alert severity helps operations prioritize:

- `low`
- `medium`
- `high`
- `critical`

## Dashboard View Explanations

The project includes three dashboard-style SQL queries.

The current operations dashboard shows:

- latest order status
- latest status time
- expected delivery time
- SLA status
- route status
- active alert count
- operational priority

The driver activity dashboard shows:

- latest location update
- active delivery count
- completed delivery count
- delay rate
- inactivity status

The warehouse operations dashboard shows:

- active orders
- delayed orders
- average delivery duration
- SLA breach rate
- overload status

## Operational Recommendations

The recommendation query uses simple `CASE WHEN` logic.

Example actions:

- Investigate delayed orders
- Reassign overloaded drivers
- Increase warehouse staffing
- Monitor inactive drivers
- Optimize delivery route
- Maintain current operations

These are not automated decisions. They are simple examples of how SQL can support operational monitoring.

## SQL Concepts Practiced

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
- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `LAG`
- `LEAD`
- `SUM OVER`
- Timestamp calculations
- Duration calculations
- Latest-state logic
- SLA monitoring
- Dashboard-style SQL

## Business Questions Answered

- What is the latest status of each order?
- Which orders are active right now?
- Which orders are delayed?
- Which orders are cancelled or returned?
- Which orders missed SLA?
- How long did deliveries take?
- Which orders are stuck too long in preparing or dispatched?
- Which drivers are busy or inactive?
- Which drivers completed the most deliveries?
- Which warehouses are overloaded?
- Which routes are delayed?
- What is the route delay rate?
- Which alerts are unresolved or critical?
- What is the SLA breach rate?
- What is the cancellation rate?
- What is the return rate?
- What should operations investigate next?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates the operational tracking schema. |
| `insert_data.sql` | Inserts fictional sample data with realistic event sequences. |
| `analysis_queries.sql` | Contains operational monitoring and dashboard queries. |
| `business_questions.md` | Maps each question to business value and SQL concepts. |
| `README.md` | Explains the project, logic, and learning outcomes. |

## Key Lessons

Operational systems are not only about storing records.

They are about tracking state changes over time.

A single order can move through many statuses, and the latest status must be calculated carefully from the event log.

SQL can simulate important operational monitoring patterns such as latest-state logic, stuck-order detection, SLA breach tracking, alert triage, and dashboard reporting.

## How to Run This Project

Run the files in this order using PostgreSQL:

```sql
-- 1. Create tables
\i schema.sql

-- 2. Insert sample data
\i insert_data.sql

-- 3. Run analysis queries
\i analysis_queries.sql
```

If you are using pgAdmin, open each file and run them in the same order.

## LinkedIn Reflection Draft

Day 21/25 - SQL for Real Business Data Systems

Today I built a Real-Time Order Tracking System simulation using SQL.

This project helped me understand how operational systems track order status changes over time.

This is not a true real-time streaming system.

Instead, it simulates event-driven tracking using SQL event logs and timestamp-based status updates.

For this project, I modeled:
- customers
- warehouses
- drivers
- orders
- order_items
- order_status_events
- delivery_routes
- driver_locations
- operational_alerts

Then I wrote SQL queries to analyze:
- latest order status
- active deliveries
- delayed orders
- SLA breaches
- stuck orders
- driver activity
- warehouse operational load
- delayed routes
- operational alerts
- average time spent in status
- live tracking simulation
- operational dashboards
- operational recommendations

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- ROW_NUMBER
- LEAD
- LAG
- event tracking
- latest state logic
- operational monitoring thinking

My key lesson:
Operational systems are not only about storing data.

They are about tracking state changes, monitoring live operations, detecting bottlenecks, and helping teams respond quickly.

This foundation is important for operational analytics, event-driven systems, Data Engineering, monitoring systems, and future Data + AI solutions.

Feedback and suggestions are always welcome.

# Business Questions - Real-Time Order Tracking System

| Operational Monitoring Question | Why It Matters | SQL Concept |
|---|---|---|
| Which customers are in the system? | Defines the customer base for operational tracking. | SELECT, ORDER BY |
| Which drivers are available, busy, offline, or suspended? | Helps operations understand driver supply. | WHERE, CHECK values |
| Which warehouses are active, overloaded, or under maintenance? | Shows fulfillment capacity risk. | SELECT, filtering |
| Which orders belong to which customers, warehouses, and drivers? | Connects order ownership across the operation. | JOIN, LEFT JOIN |
| What is the full event timeline for each order? | Shows how an order moved through the lifecycle. | ORDER BY, event logs |
| What is the latest status of each order? | Creates current-state reporting from event history. | ROW_NUMBER |
| What does the current order status table show? | Gives a dashboard-ready view of each order now. | CTE, JOIN |
| How many orders are in each latest status? | Shows current operational workload by state. | GROUP BY |
| Which deliveries are currently active? | Helps monitor orders still moving through operations. | CTE, WHERE |
| Which orders are out for delivery now? | Helps support teams answer customer tracking questions. | Latest-state filtering |
| Which orders are delayed? | Flags orders needing operational attention. | CTE, WHERE |
| Which orders are cancelled? | Tracks failed demand and support impact. | Latest-state filtering |
| Which orders are returned? | Helps monitor reverse logistics. | Latest-state filtering |
| Which delivered orders missed SLA? | Measures service-level performance. | CTE, timestamp comparison |
| How long did each completed delivery take? | Shows order-level delivery speed. | EXTRACT, intervals |
| What is the average delivery duration? | Provides a high-level operational KPI. | AVG, date/time math |
| Which orders are stuck in preparing status? | Finds warehouse bottlenecks. | CTE, interval threshold |
| Which orders are stuck in dispatched status? | Finds dispatch or handoff bottlenecks. | CTE, interval threshold |
| Which drivers are currently busy? | Shows driver availability. | WHERE |
| Which drivers have inactive location updates? | Identifies drivers who may need follow-up. | ROW_NUMBER, timestamp threshold |
| Which drivers have the most active deliveries? | Shows workload concentration. | GROUP BY, latest status |
| Which drivers completed the most deliveries? | Supports driver performance monitoring. | RANK |
| Which warehouses are overloaded? | Flags fulfillment risk. | WHERE |
| How many active orders does each warehouse have? | Measures current warehouse load. | CTE, GROUP BY |
| Which warehouses have the highest operational load? | Helps prioritize staffing and support. | DENSE_RANK |
| Which routes are delayed? | Finds route-level bottlenecks. | WHERE, CASE logic |
| What is average route duration by city pair? | Compares delivery performance by route. | GROUP BY, AVG |
| What is route delay rate? | Measures reliability for each city pair. | CASE WHEN, NULLIF |
| How many alerts exist by severity? | Helps teams triage urgent issues. | GROUP BY, CASE ordering |
| How many alerts exist by alert type? | Shows the most common operational problems. | GROUP BY |
| Which alerts are unresolved? | Shows open work for operations teams. | WHERE |
| Which alerts are critical? | Highlights highest-priority issues. | WHERE |
| What is the SLA breach rate? | Measures delivery promise performance. | CTE, rate calculation |
| What is the cancellation rate? | Tracks order failure before delivery. | CTE, NULLIF |
| What is the return rate? | Tracks reverse delivery outcomes. | CTE, NULLIF |
| What are the main operational KPIs? | Combines key numbers into one summary. | CTE, scalar subqueries |
| What does the current operations dashboard show? | Combines latest status, SLA, routes, and alerts. | CTE, CASE WHEN |
| What does the driver activity dashboard show? | Combines status, location, active work, and delays. | CTE, FILTER |
| What does the warehouse operations dashboard show? | Combines load, delays, duration, and SLA rate. | CTE, aggregation |
| What action should operations take next? | Turns monitoring data into practical decisions. | CASE WHEN |
| What is the simulated live status of each order? | Demonstrates current-state tracking from event logs. | ROW_NUMBER |
| Where was each driver most recently located? | Supports driver monitoring and dispatch planning. | ROW_NUMBER |
| Which drivers have been inactive too long? | Helps identify possible tracking or service issues. | Timestamp comparison |
| Which orders have many status transitions? | Finds complex or noisy operational cases. | HAVING |
| How much time is spent in each status? | Reveals bottlenecks in the order lifecycle. | LEAD, interval calculation |
| What was the previous status before each current status? | Helps audit event sequence quality and state changes. | LAG |
| How are alerts accumulating over time? | Shows operational pressure trend. | SUM OVER |

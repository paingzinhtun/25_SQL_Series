# Business Questions - Logistics & Delivery Optimization

This file connects each logistics question with why it matters and the SQL concept practiced.

| Logistics / Operations Question | Why It Matters | SQL Concept |
|---|---|---|
| What warehouses does the business operate? | Provides origin locations for delivery flow analysis. | `SELECT`, `ORDER BY` |
| Which couriers are available and what vehicles do they use? | Helps understand delivery capacity and courier coverage. | Filtering and sorting |
| What routes connect warehouses to delivery zones? | Defines the delivery network for route analysis. | Multi-table `JOIN` |
| What is the full shipment context? | Connects orders, customers, warehouses, couriers, and routes. | Multi-table `JOIN` |
| What events happened for each shipment? | Shows shipment lifecycle history. | `ORDER BY`, event tracking |
| How many shipments are in each status? | Provides a basic operational health check. | `GROUP BY`, `COUNT` |
| How many orders are in each status? | Helps monitor order pipeline and fulfillment progress. | Aggregation |
| How many shipments were delivered? | Measures completed delivery volume. | `WHERE`, `COUNT` |
| What is the average delivery time? | Tracks customer experience and delivery efficiency. | Date/time calculation |
| Which shipments were delayed? | Identifies shipments needing operational review. | `WHERE`, business logic |
| Which shipments failed? | Helps reduce failed deliveries and retry cost. | Filtering |
| Which shipments were returned? | Helps investigate return patterns. | Filtering |
| How long were shipments delayed? | Quantifies delay severity. | Timestamp subtraction |
| How many SLA breaches happened by route? | Shows which routes miss delivery commitments. | `FILTER`, grouping |
| What is the SLA breach rate by route? | Normalizes breach counts by shipment volume. | `NULLIF`, rate calculation |
| Which routes have the highest delay rate? | Helps prioritize route planning improvements. | Rate calculation |
| Which routes have the highest failed delivery rate? | Finds routes with delivery reliability problems. | Aggregation |
| Which routes have the longest average delivery time? | Helps identify slow routes. | CTE, `RANK` |
| Which warehouses dispatch the most shipments? | Shows fulfillment volume by warehouse. | `LEFT JOIN`, `COUNT` |
| How do warehouses rank by shipment volume? | Identifies high-volume warehouses. | Window `RANK` |
| What is average delivery time by warehouse? | Shows warehouse-level operational performance. | Aggregation |
| Which couriers completed the most deliveries? | Identifies strong courier performance. | `COUNT`, `GROUP BY` |
| How do couriers rank by completed deliveries? | Creates a courier leaderboard. | Window function |
| What is courier delay rate? | Shows courier-level delivery timing issues. | Rate calculation |
| What is courier failed delivery rate? | Shows courier-level failure patterns. | `NULLIF`, aggregation |
| Which couriers have high delay or failure rates? | Helps prioritize coaching or route review. | CTE, filtering |
| What is the total cost by shipment? | Shows delivery cost components. | Cost reporting |
| What is average delivery cost by route? | Helps compare route cost efficiency. | `AVG`, grouping |
| What is average delivery cost by zone type? | Shows expensive delivery zone types. | `JOIN`, aggregation |
| Which shipments are high-cost? | Flags shipments that may need cost review. | Threshold filtering |
| Which delivery zones are high-cost? | Helps identify costly locations. | `HAVING` |
| What is cost per kilometer by route? | Normalizes cost against distance. | `NULLIF`, formula |
| Which shipments had multiple delivery attempts? | Helps reduce retry effort and failed attempt cost. | Filtering |
| How much cost comes from failed attempts? | Quantifies the cost impact of retries. | `SUM`, `AVG` |
| What is daily shipment volume? | Supports daily operations planning. | Date grouping |
| What is the monthly delivery trend? | Tracks delivery performance over time. | `DATE_TRUNC` |
| What is the overall delivery KPI summary? | Gives leaders a quick operations snapshot. | CTE |
| What should a route dashboard show? | Combines route timing, cost, delay, and SLA metrics. | Dashboard query |
| What should a courier dashboard show? | Combines courier volume, delays, failures, and performance status. | Dashboard query |
| What actions should operations teams take? | Converts metrics into practical actions. | `CASE WHEN` |

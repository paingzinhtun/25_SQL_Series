-- Day 19 - Logistics & Delivery Optimization
-- PostgreSQL analysis queries
--
-- Key formulas used in this project:
-- Delivery duration = actual_delivery_time - dispatch_time
-- Delay duration = actual_delivery_time - expected_delivery_time
-- SLA breach = delivery duration in hours > route expected_delivery_hours
-- Delay rate = delayed shipments / total shipments
-- Failed rate = failed shipments / total shipments
-- Cost per km = total_cost / distance_km

-- 1. List all warehouses.
SELECT
    warehouse_id,
    warehouse_name,
    city,
    capacity
FROM warehouses
ORDER BY warehouse_id;

-- 2. List all couriers with vehicle type and status.
SELECT
    courier_id,
    first_name || ' ' || last_name AS courier_name,
    phone_number,
    city,
    vehicle_type,
    courier_status
FROM couriers
ORDER BY courier_id;

-- 3. List all routes with warehouse, zone, distance, and expected delivery hours.
SELECT
    r.route_id,
    r.route_name,
    w.warehouse_name AS origin_warehouse,
    dz.zone_name AS destination_zone,
    dz.city,
    dz.zone_type,
    r.distance_km,
    r.expected_delivery_hours
FROM routes AS r
JOIN warehouses AS w ON r.origin_warehouse_id = w.warehouse_id
JOIN delivery_zones AS dz ON r.destination_zone_id = dz.zone_id
ORDER BY r.route_id;

-- 4. Show all shipments with order, customer, warehouse, courier, route, and status.
SELECT
    s.shipment_id,
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city AS customer_city,
    w.warehouse_name,
    co.first_name || ' ' || co.last_name AS courier_name,
    r.route_name,
    s.dispatch_time,
    s.expected_delivery_time,
    s.actual_delivery_time,
    s.shipment_status,
    s.delivery_attempts
FROM shipments AS s
JOIN orders AS o ON s.order_id = o.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN warehouses AS w ON s.warehouse_id = w.warehouse_id
JOIN couriers AS co ON s.courier_id = co.courier_id
JOIN routes AS r ON s.route_id = r.route_id
ORDER BY s.shipment_id;

-- 5. Show delivery event history by shipment.
SELECT
    de.shipment_id,
    de.event_time,
    de.event_type,
    de.event_location,
    de.event_note
FROM delivery_events AS de
ORDER BY de.shipment_id, de.event_time;

-- 6. Count shipments by shipment status.
SELECT
    shipment_status,
    COUNT(*) AS shipment_count
FROM shipments
GROUP BY shipment_status
ORDER BY shipment_count DESC;

-- 7. Count orders by order status.
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 8. Calculate total delivered shipments.
SELECT
    COUNT(*) AS total_delivered_shipments
FROM shipments
WHERE shipment_status = 'delivered';

-- 9. Calculate average delivery time for delivered shipments.
-- Incomplete shipments are excluded because actual_delivery_time is NULL.
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (actual_delivery_time - dispatch_time)) / 3600),
        2
    ) AS average_delivery_hours
FROM shipments
WHERE actual_delivery_time IS NOT NULL
  AND dispatch_time IS NOT NULL
  AND shipment_status IN ('delivered', 'delayed');

-- 10. Find delayed shipments.
-- A shipment is delayed if status is delayed or actual delivery is after expected delivery.
SELECT
    shipment_id,
    dispatch_time,
    expected_delivery_time,
    actual_delivery_time,
    shipment_status
FROM shipments
WHERE shipment_status = 'delayed'
   OR actual_delivery_time > expected_delivery_time
ORDER BY shipment_id;

-- 11. Find failed shipments.
SELECT
    shipment_id,
    order_id,
    courier_id,
    route_id,
    delivery_attempts
FROM shipments
WHERE shipment_status = 'failed'
ORDER BY shipment_id;

-- 12. Find returned shipments.
SELECT
    shipment_id,
    order_id,
    courier_id,
    route_id,
    delivery_attempts
FROM shipments
WHERE shipment_status = 'returned'
ORDER BY shipment_id;

-- 13. Calculate delay duration in hours.
-- Delay duration only applies when actual_delivery_time is later than expected_delivery_time.
SELECT
    shipment_id,
    expected_delivery_time,
    actual_delivery_time,
    ROUND(
        EXTRACT(EPOCH FROM (actual_delivery_time - expected_delivery_time)) / 3600,
        2
    ) AS delay_hours
FROM shipments
WHERE actual_delivery_time > expected_delivery_time
ORDER BY delay_hours DESC;

-- 14. Calculate SLA breach count by route.
-- SLA breach = actual delivery duration in hours > expected_delivery_hours.
SELECT
    r.route_id,
    r.route_name,
    COUNT(*) FILTER (
        WHERE EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600
              > r.expected_delivery_hours
    ) AS sla_breach_count
FROM routes AS r
LEFT JOIN shipments AS s ON r.route_id = s.route_id
GROUP BY r.route_id, r.route_name
ORDER BY sla_breach_count DESC;

-- 15. Calculate SLA breach rate by route.
SELECT
    r.route_id,
    r.route_name,
    COUNT(s.shipment_id) FILTER (WHERE s.actual_delivery_time IS NOT NULL) AS completed_or_attempted_shipments,
    COUNT(*) FILTER (
        WHERE s.actual_delivery_time IS NOT NULL
          AND EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600
              > r.expected_delivery_hours
    ) AS sla_breach_count,
    ROUND(
        COUNT(*) FILTER (
            WHERE s.actual_delivery_time IS NOT NULL
              AND EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600
                  > r.expected_delivery_hours
        ) * 100.0 / NULLIF(COUNT(s.shipment_id) FILTER (WHERE s.actual_delivery_time IS NOT NULL), 0),
        2
    ) AS sla_breach_rate_percent
FROM routes AS r
LEFT JOIN shipments AS s ON r.route_id = s.route_id
GROUP BY r.route_id, r.route_name
ORDER BY sla_breach_rate_percent DESC NULLS LAST;

-- 16. Find routes with highest delay rate.
-- Delay rate = delayed shipments / total shipments.
SELECT
    r.route_id,
    r.route_name,
    COUNT(s.shipment_id) AS total_shipments,
    COUNT(*) FILTER (
        WHERE s.shipment_status = 'delayed'
           OR s.actual_delivery_time > s.expected_delivery_time
    ) AS delayed_shipments,
    ROUND(
        COUNT(*) FILTER (
            WHERE s.shipment_status = 'delayed'
               OR s.actual_delivery_time > s.expected_delivery_time
        ) * 100.0 / NULLIF(COUNT(s.shipment_id), 0),
        2
    ) AS delay_rate_percent
FROM routes AS r
LEFT JOIN shipments AS s ON r.route_id = s.route_id
GROUP BY r.route_id, r.route_name
ORDER BY delay_rate_percent DESC NULLS LAST;

-- 17. Find routes with highest failed delivery rate.
SELECT
    r.route_id,
    r.route_name,
    COUNT(s.shipment_id) AS total_shipments,
    COUNT(*) FILTER (WHERE s.shipment_status = 'failed') AS failed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE s.shipment_status = 'failed') * 100.0
        / NULLIF(COUNT(s.shipment_id), 0),
        2
    ) AS failed_rate_percent
FROM routes AS r
LEFT JOIN shipments AS s ON r.route_id = s.route_id
GROUP BY r.route_id, r.route_name
ORDER BY failed_rate_percent DESC NULLS LAST;

-- 18. Rank routes by average delivery time.
WITH route_delivery_time AS (
    SELECT
        r.route_id,
        r.route_name,
        ROUND(AVG(EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600), 2) AS avg_delivery_hours
    FROM routes AS r
    JOIN shipments AS s ON r.route_id = s.route_id
    WHERE s.actual_delivery_time IS NOT NULL
      AND s.dispatch_time IS NOT NULL
    GROUP BY r.route_id, r.route_name
)
SELECT
    RANK() OVER (ORDER BY avg_delivery_hours DESC) AS route_time_rank,
    route_id,
    route_name,
    avg_delivery_hours
FROM route_delivery_time
ORDER BY route_time_rank;

-- 19. Count shipments by warehouse.
SELECT
    w.warehouse_id,
    w.warehouse_name,
    COUNT(s.shipment_id) AS shipment_count
FROM warehouses AS w
LEFT JOIN shipments AS s ON w.warehouse_id = s.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name
ORDER BY shipment_count DESC;

-- 20. Rank warehouses by shipment volume.
SELECT
    w.warehouse_id,
    w.warehouse_name,
    COUNT(s.shipment_id) AS shipment_count,
    RANK() OVER (ORDER BY COUNT(s.shipment_id) DESC) AS warehouse_volume_rank
FROM warehouses AS w
LEFT JOIN shipments AS s ON w.warehouse_id = s.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name
ORDER BY warehouse_volume_rank;

-- 21. Calculate average dispatch-to-delivery time by warehouse.
SELECT
    w.warehouse_id,
    w.warehouse_name,
    ROUND(AVG(EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600), 2) AS avg_delivery_hours
FROM warehouses AS w
JOIN shipments AS s ON w.warehouse_id = s.warehouse_id
WHERE s.actual_delivery_time IS NOT NULL
  AND s.dispatch_time IS NOT NULL
GROUP BY w.warehouse_id, w.warehouse_name
ORDER BY avg_delivery_hours DESC;

-- 22. Count completed deliveries by courier.
SELECT
    c.courier_id,
    c.first_name || ' ' || c.last_name AS courier_name,
    COUNT(s.shipment_id) AS completed_deliveries
FROM couriers AS c
LEFT JOIN shipments AS s
    ON c.courier_id = s.courier_id
   AND s.shipment_status = 'delivered'
GROUP BY c.courier_id, courier_name
ORDER BY completed_deliveries DESC;

-- 23. Rank couriers by completed deliveries.
SELECT
    c.courier_id,
    c.first_name || ' ' || c.last_name AS courier_name,
    COUNT(s.shipment_id) FILTER (WHERE s.shipment_status = 'delivered') AS completed_deliveries,
    RANK() OVER (
        ORDER BY COUNT(s.shipment_id) FILTER (WHERE s.shipment_status = 'delivered') DESC
    ) AS courier_rank
FROM couriers AS c
LEFT JOIN shipments AS s ON c.courier_id = s.courier_id
GROUP BY c.courier_id, courier_name
ORDER BY courier_rank;

-- 24. Calculate courier delay rate.
SELECT
    c.courier_id,
    c.first_name || ' ' || c.last_name AS courier_name,
    COUNT(s.shipment_id) AS total_shipments,
    COUNT(*) FILTER (
        WHERE s.shipment_status = 'delayed'
           OR s.actual_delivery_time > s.expected_delivery_time
    ) AS delayed_shipments,
    ROUND(
        COUNT(*) FILTER (
            WHERE s.shipment_status = 'delayed'
               OR s.actual_delivery_time > s.expected_delivery_time
        ) * 100.0 / NULLIF(COUNT(s.shipment_id), 0),
        2
    ) AS delay_rate_percent
FROM couriers AS c
LEFT JOIN shipments AS s ON c.courier_id = s.courier_id
GROUP BY c.courier_id, courier_name
ORDER BY delay_rate_percent DESC NULLS LAST;

-- 25. Calculate courier failed delivery rate.
SELECT
    c.courier_id,
    c.first_name || ' ' || c.last_name AS courier_name,
    COUNT(s.shipment_id) AS total_shipments,
    COUNT(*) FILTER (WHERE s.shipment_status = 'failed') AS failed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE s.shipment_status = 'failed') * 100.0
        / NULLIF(COUNT(s.shipment_id), 0),
        2
    ) AS failed_rate_percent
FROM couriers AS c
LEFT JOIN shipments AS s ON c.courier_id = s.courier_id
GROUP BY c.courier_id, courier_name
ORDER BY failed_rate_percent DESC NULLS LAST;

-- 26. Find couriers with high delay or failure rates.
WITH courier_metrics AS (
    SELECT
        c.courier_id,
        c.first_name || ' ' || c.last_name AS courier_name,
        COUNT(s.shipment_id) AS total_shipments,
        ROUND(
            COUNT(*) FILTER (
                WHERE s.shipment_status = 'delayed'
                   OR s.actual_delivery_time > s.expected_delivery_time
            ) * 100.0 / NULLIF(COUNT(s.shipment_id), 0),
            2
        ) AS delay_rate_percent,
        ROUND(
            COUNT(*) FILTER (WHERE s.shipment_status = 'failed') * 100.0
            / NULLIF(COUNT(s.shipment_id), 0),
            2
        ) AS failed_rate_percent
    FROM couriers AS c
    LEFT JOIN shipments AS s ON c.courier_id = s.courier_id
    GROUP BY c.courier_id, courier_name
)
SELECT *
FROM courier_metrics
WHERE COALESCE(delay_rate_percent, 0) >= 30
   OR COALESCE(failed_rate_percent, 0) >= 20
ORDER BY delay_rate_percent DESC NULLS LAST, failed_rate_percent DESC NULLS LAST;

-- 27. Calculate total delivery cost by shipment.
SELECT
    shipment_id,
    base_cost,
    distance_cost,
    handling_cost,
    failed_attempt_cost,
    total_cost
FROM delivery_costs
ORDER BY total_cost DESC;

-- 28. Calculate average delivery cost by route.
SELECT
    r.route_id,
    r.route_name,
    ROUND(AVG(dc.total_cost), 2) AS avg_delivery_cost
FROM routes AS r
JOIN shipments AS s ON r.route_id = s.route_id
JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
GROUP BY r.route_id, r.route_name
ORDER BY avg_delivery_cost DESC;

-- 29. Calculate average delivery cost by zone type.
SELECT
    dz.zone_type,
    ROUND(AVG(dc.total_cost), 2) AS avg_delivery_cost
FROM delivery_zones AS dz
JOIN routes AS r ON dz.zone_id = r.destination_zone_id
JOIN shipments AS s ON r.route_id = s.route_id
JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
GROUP BY dz.zone_type
ORDER BY avg_delivery_cost DESC;

-- 30. Find high-cost shipments.
-- Example threshold: total_cost >= 40,000 MMK.
SELECT
    s.shipment_id,
    r.route_name,
    dz.zone_type,
    dc.total_cost
FROM shipments AS s
JOIN routes AS r ON s.route_id = r.route_id
JOIN delivery_zones AS dz ON r.destination_zone_id = dz.zone_id
JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
WHERE dc.total_cost >= 40000
ORDER BY dc.total_cost DESC;

-- 31. Find high-cost delivery zones.
SELECT
    dz.zone_id,
    dz.zone_name,
    dz.city,
    dz.zone_type,
    ROUND(AVG(dc.total_cost), 2) AS avg_delivery_cost
FROM delivery_zones AS dz
JOIN routes AS r ON dz.zone_id = r.destination_zone_id
JOIN shipments AS s ON r.route_id = s.route_id
JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
GROUP BY dz.zone_id, dz.zone_name, dz.city, dz.zone_type
HAVING AVG(dc.total_cost) >= 25000
ORDER BY avg_delivery_cost DESC;

-- 32. Calculate cost per kilometer by route.
SELECT
    r.route_id,
    r.route_name,
    r.distance_km,
    ROUND(AVG(dc.total_cost) / NULLIF(r.distance_km, 0), 2) AS cost_per_km
FROM routes AS r
JOIN shipments AS s ON r.route_id = s.route_id
JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
GROUP BY r.route_id, r.route_name, r.distance_km
ORDER BY cost_per_km DESC;

-- 33. Find shipments with multiple delivery attempts.
SELECT
    shipment_id,
    order_id,
    shipment_status,
    delivery_attempts
FROM shipments
WHERE delivery_attempts > 1
ORDER BY delivery_attempts DESC, shipment_id;

-- 34. Calculate failed attempt cost impact.
SELECT
    SUM(failed_attempt_cost) AS total_failed_attempt_cost,
    ROUND(AVG(failed_attempt_cost), 2) AS avg_failed_attempt_cost,
    COUNT(*) FILTER (WHERE failed_attempt_cost > 0) AS shipments_with_failed_attempt_cost
FROM delivery_costs;

-- 35. Calculate daily shipment volume.
SELECT
    DATE(dispatch_time) AS dispatch_date,
    COUNT(*) AS shipment_count
FROM shipments
WHERE dispatch_time IS NOT NULL
GROUP BY DATE(dispatch_time)
ORDER BY dispatch_date;

-- 36. Calculate monthly delivery performance trend.
SELECT
    DATE_TRUNC('month', dispatch_time)::DATE AS delivery_month,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE shipment_status = 'delivered') AS delivered_shipments,
    COUNT(*) FILTER (WHERE shipment_status = 'delayed') AS delayed_shipments,
    COUNT(*) FILTER (WHERE shipment_status = 'failed') AS failed_shipments,
    ROUND(
        COUNT(*) FILTER (WHERE shipment_status = 'delivered') * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS delivered_rate_percent
FROM shipments
WHERE dispatch_time IS NOT NULL
GROUP BY DATE_TRUNC('month', dispatch_time)::DATE
ORDER BY delivery_month;

-- 37. Create a delivery operations KPI summary using CTE.
WITH shipment_metrics AS (
    SELECT
        COUNT(*) AS total_shipments,
        COUNT(*) FILTER (WHERE shipment_status = 'delivered') AS delivered_shipments,
        COUNT(*) FILTER (WHERE shipment_status = 'delayed') AS delayed_shipments,
        COUNT(*) FILTER (WHERE shipment_status = 'failed') AS failed_shipments,
        COUNT(*) FILTER (WHERE shipment_status = 'returned') AS returned_shipments,
        ROUND(AVG(EXTRACT(EPOCH FROM (actual_delivery_time - dispatch_time)) / 3600), 2) AS avg_delivery_hours
    FROM shipments
    WHERE dispatch_time IS NOT NULL
),
cost_metrics AS (
    SELECT
        SUM(total_cost) AS total_delivery_cost,
        ROUND(AVG(total_cost), 2) AS avg_delivery_cost
    FROM delivery_costs
)
SELECT
    sm.total_shipments,
    sm.delivered_shipments,
    sm.delayed_shipments,
    sm.failed_shipments,
    sm.returned_shipments,
    sm.avg_delivery_hours,
    cm.total_delivery_cost,
    cm.avg_delivery_cost,
    ROUND(sm.delivered_shipments * 100.0 / NULLIF(sm.total_shipments, 0), 2) AS delivery_success_rate_percent
FROM shipment_metrics AS sm
CROSS JOIN cost_metrics AS cm;

-- 38. Build a route performance dashboard view using SQL.
WITH route_metrics AS (
    SELECT
        r.route_id,
        r.route_name,
        w.warehouse_name AS origin_warehouse,
        dz.zone_name AS destination_zone,
        dz.city,
        dz.zone_type,
        r.distance_km,
        r.expected_delivery_hours,
        COUNT(s.shipment_id) AS total_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'delivered') AS delivered_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'delayed') AS delayed_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'failed') AS failed_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'returned') AS returned_shipments,
        ROUND(AVG(EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600), 2) AS avg_delivery_hours,
        ROUND(AVG(dc.total_cost), 2) AS avg_delivery_cost,
        ROUND(AVG(dc.total_cost) / NULLIF(r.distance_km, 0), 2) AS cost_per_km,
        COUNT(*) FILTER (
            WHERE s.actual_delivery_time IS NOT NULL
              AND EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600
                  > r.expected_delivery_hours
        ) AS sla_breaches
    FROM routes AS r
    JOIN warehouses AS w ON r.origin_warehouse_id = w.warehouse_id
    JOIN delivery_zones AS dz ON r.destination_zone_id = dz.zone_id
    LEFT JOIN shipments AS s ON r.route_id = s.route_id
    LEFT JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
    GROUP BY r.route_id, r.route_name, w.warehouse_name, dz.zone_name, dz.city, dz.zone_type, r.distance_km, r.expected_delivery_hours
)
SELECT
    route_id,
    route_name,
    origin_warehouse,
    destination_zone,
    city,
    zone_type,
    distance_km,
    expected_delivery_hours,
    total_shipments,
    delivered_shipments,
    delayed_shipments,
    failed_shipments,
    returned_shipments,
    avg_delivery_hours,
    ROUND(delayed_shipments * 100.0 / NULLIF(total_shipments, 0), 2) AS delay_rate,
    ROUND(failed_shipments * 100.0 / NULLIF(total_shipments, 0), 2) AS failed_rate,
    ROUND(sla_breaches * 100.0 / NULLIF(total_shipments, 0), 2) AS sla_breach_rate,
    avg_delivery_cost,
    cost_per_km,
    CASE
        WHEN failed_shipments * 100.0 / NULLIF(total_shipments, 0) >= 20 THEN 'reduce_failed_deliveries'
        WHEN delayed_shipments * 100.0 / NULLIF(total_shipments, 0) >= 30 THEN 'improve_route_planning'
        WHEN cost_per_km >= 1000 THEN 'investigate_high_delivery_cost'
        ELSE 'healthy_route'
    END AS route_health_status
FROM route_metrics
ORDER BY delay_rate DESC NULLS LAST, failed_rate DESC NULLS LAST;

-- 39. Build a courier performance dashboard view using SQL.
WITH courier_metrics AS (
    SELECT
        c.courier_id,
        c.first_name || ' ' || c.last_name AS courier_name,
        c.city,
        c.vehicle_type,
        c.courier_status,
        COUNT(s.shipment_id) AS total_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'delivered') AS completed_deliveries,
        COUNT(*) FILTER (WHERE s.shipment_status = 'delayed') AS delayed_deliveries,
        COUNT(*) FILTER (WHERE s.shipment_status = 'failed') AS failed_deliveries,
        COUNT(*) FILTER (WHERE s.shipment_status = 'returned') AS returned_deliveries,
        ROUND(AVG(EXTRACT(EPOCH FROM (s.actual_delivery_time - s.dispatch_time)) / 3600), 2) AS avg_delivery_hours
    FROM couriers AS c
    LEFT JOIN shipments AS s ON c.courier_id = s.courier_id
    GROUP BY c.courier_id, courier_name, c.city, c.vehicle_type, c.courier_status
)
SELECT
    courier_id,
    courier_name,
    city,
    vehicle_type,
    courier_status,
    total_shipments,
    completed_deliveries,
    delayed_deliveries,
    failed_deliveries,
    returned_deliveries,
    avg_delivery_hours,
    ROUND(delayed_deliveries * 100.0 / NULLIF(total_shipments, 0), 2) AS delay_rate,
    ROUND(failed_deliveries * 100.0 / NULLIF(total_shipments, 0), 2) AS failed_rate,
    CASE
        WHEN total_shipments = 0 THEN 'no_recent_shipments'
        WHEN failed_deliveries * 100.0 / NULLIF(total_shipments, 0) >= 20 THEN 'review_courier_performance'
        WHEN delayed_deliveries * 100.0 / NULLIF(total_shipments, 0) >= 30 THEN 'monitor_delivery_delays'
        WHEN completed_deliveries >= 8 THEN 'strong_performer'
        ELSE 'maintain_current_performance'
    END AS courier_performance_status
FROM courier_metrics
ORDER BY completed_deliveries DESC, delay_rate DESC NULLS LAST;

-- 40. Create recommended operational actions using CASE WHEN.
WITH route_summary AS (
    SELECT
        r.route_id,
        r.route_name,
        COUNT(s.shipment_id) AS total_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'delayed') AS delayed_shipments,
        COUNT(*) FILTER (WHERE s.shipment_status = 'failed') AS failed_shipments,
        ROUND(AVG(dc.total_cost), 2) AS avg_delivery_cost
    FROM routes AS r
    LEFT JOIN shipments AS s ON r.route_id = s.route_id
    LEFT JOIN delivery_costs AS dc ON s.shipment_id = dc.shipment_id
    GROUP BY r.route_id, r.route_name
)
SELECT
    route_id,
    route_name,
    total_shipments,
    delayed_shipments,
    failed_shipments,
    avg_delivery_cost,
    CASE
        WHEN failed_shipments >= 2 THEN 'Reduce failed attempts'
        WHEN delayed_shipments >= 3 THEN 'Improve route planning'
        WHEN avg_delivery_cost >= 35000 THEN 'Investigate high delivery cost'
        WHEN total_shipments >= 8 THEN 'Monitor route'
        ELSE 'Maintain current performance'
    END AS recommended_operational_action
FROM route_summary
ORDER BY recommended_operational_action, route_id;

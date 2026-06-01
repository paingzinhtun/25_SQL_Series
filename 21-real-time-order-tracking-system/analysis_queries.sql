-- Day 21 - Real-Time Order Tracking System (Simulated with SQL)
-- PostgreSQL operational monitoring queries

-- For repeatable "current time" examples, this project uses a fixed analysis timestamp.
-- In a real dashboard, this would usually be CURRENT_TIMESTAMP.

-- 1. List all customers.
SELECT
    customer_id,
    first_name,
    last_name,
    phone_number,
    city,
    created_at
FROM customers
ORDER BY customer_id;

-- 2. List all drivers with current status.
SELECT
    driver_id,
    first_name || ' ' || last_name AS driver_name,
    phone_number,
    city,
    vehicle_type,
    driver_status
FROM drivers
ORDER BY driver_status, driver_name;

-- 3. List all warehouses with current status.
SELECT
    warehouse_id,
    warehouse_name,
    city,
    warehouse_status
FROM warehouses
ORDER BY warehouse_status, warehouse_name;

-- 4. Show all orders with customer and warehouse information.
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city AS customer_city,
    w.warehouse_name,
    w.city AS warehouse_city,
    d.first_name || ' ' || d.last_name AS driver_name,
    o.order_datetime,
    o.expected_delivery_datetime,
    o.total_amount,
    o.payment_status
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN warehouses AS w
    ON o.warehouse_id = w.warehouse_id
LEFT JOIN drivers AS d
    ON o.driver_id = d.driver_id
ORDER BY o.order_datetime;

-- 5. Show full order event timeline by order.
SELECT
    ose.order_id,
    ose.event_time,
    ose.order_status,
    ose.status_note,
    ose.updated_by
FROM order_status_events AS ose
ORDER BY ose.order_id, ose.event_time;

-- 6. Find latest order status using window functions.
-- Latest status is the event with the newest event_time for each order.
WITH ranked_events AS (
    SELECT
        ose.*,
        ROW_NUMBER() OVER (
            PARTITION BY ose.order_id
            ORDER BY ose.event_time DESC, ose.event_id DESC
        ) AS status_rank
    FROM order_status_events AS ose
)
SELECT
    order_id,
    event_time AS latest_status_time,
    order_status AS latest_order_status,
    status_note
FROM ranked_events
WHERE status_rank = 1
ORDER BY order_id;

-- 7. Build current order status table.
WITH latest_status AS (
    SELECT
        ose.order_id,
        ose.event_time,
        ose.order_status,
        ROW_NUMBER() OVER (
            PARTITION BY ose.order_id
            ORDER BY ose.event_time DESC, ose.event_id DESC
        ) AS status_rank
    FROM order_status_events AS ose
)
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    w.warehouse_name,
    d.first_name || ' ' || d.last_name AS driver_name,
    ls.order_status AS current_order_status,
    ls.event_time AS current_status_time,
    o.expected_delivery_datetime
FROM latest_status AS ls
JOIN orders AS o
    ON ls.order_id = o.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN warehouses AS w
    ON o.warehouse_id = w.warehouse_id
LEFT JOIN drivers AS d
    ON o.driver_id = d.driver_id
WHERE ls.status_rank = 1
ORDER BY o.order_id;

-- 8. Count orders by latest status.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    order_status AS latest_order_status,
    COUNT(*) AS order_count
FROM latest_status
WHERE status_rank = 1
GROUP BY order_status
ORDER BY order_count DESC;

-- 9. Find currently active deliveries.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    o.order_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    ls.order_status,
    ls.event_time
FROM latest_status AS ls
JOIN orders AS o
    ON ls.order_id = o.order_id
JOIN drivers AS d
    ON o.driver_id = d.driver_id
WHERE ls.status_rank = 1
  AND ls.order_status IN ('dispatched', 'in_transit', 'out_for_delivery', 'delayed')
ORDER BY ls.event_time;

-- 10. Find orders currently out for delivery.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    order_id,
    event_time AS out_for_delivery_since
FROM latest_status
WHERE status_rank = 1
  AND order_status = 'out_for_delivery'
ORDER BY out_for_delivery_since;

-- 11. Find delayed orders.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    o.order_id,
    ls.event_time AS delayed_since,
    o.expected_delivery_datetime
FROM latest_status AS ls
JOIN orders AS o
    ON ls.order_id = o.order_id
WHERE ls.status_rank = 1
  AND ls.order_status = 'delayed'
ORDER BY delayed_since;

-- 12. Find cancelled orders.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    order_id,
    event_time AS cancelled_at
FROM latest_status
WHERE status_rank = 1
  AND order_status = 'cancelled'
ORDER BY cancelled_at;

-- 13. Find returned orders.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    order_id,
    event_time AS returned_at
FROM latest_status
WHERE status_rank = 1
  AND order_status = 'returned'
ORDER BY returned_at;

-- 14. Find orders that missed SLA.
-- SLA breach means the delivered event happened after expected_delivery_datetime.
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.expected_delivery_datetime,
        MAX(ose.event_time) AS delivered_time
    FROM orders AS o
    JOIN order_status_events AS ose
        ON o.order_id = ose.order_id
    WHERE ose.order_status = 'delivered'
    GROUP BY o.order_id, o.expected_delivery_datetime
)
SELECT
    order_id,
    expected_delivery_datetime,
    delivered_time,
    ROUND(EXTRACT(EPOCH FROM (delivered_time - expected_delivery_datetime)) / 3600, 2) AS hours_late
FROM delivered_orders
WHERE delivered_time > expected_delivery_datetime
ORDER BY hours_late DESC;

-- 15. Calculate delivery duration for completed orders.
-- Delivery duration = delivered_time - order_datetime.
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.order_datetime,
        MAX(ose.event_time) AS delivered_time
    FROM orders AS o
    JOIN order_status_events AS ose
        ON o.order_id = ose.order_id
    WHERE ose.order_status = 'delivered'
    GROUP BY o.order_id, o.order_datetime
)
SELECT
    order_id,
    order_datetime,
    delivered_time,
    ROUND(EXTRACT(EPOCH FROM (delivered_time - order_datetime)) / 60, 2) AS delivery_duration_minutes
FROM delivered_orders
ORDER BY delivery_duration_minutes DESC;

-- 16. Calculate average delivery duration.
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.order_datetime,
        MAX(ose.event_time) AS delivered_time
    FROM orders AS o
    JOIN order_status_events AS ose
        ON o.order_id = ose.order_id
    WHERE ose.order_status = 'delivered'
    GROUP BY o.order_id, o.order_datetime
)
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM (delivered_time - order_datetime)) / 60), 2) AS avg_delivery_duration_minutes
FROM delivered_orders;

-- 17. Find orders stuck in preparing status too long.
-- Stuck preparing means latest status is preparing for more than 2 hours.
WITH analysis_time AS (
    SELECT TIMESTAMP '2026-05-09 10:00:00' AS analysis_timestamp
),
latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    ls.order_id,
    ls.event_time AS preparing_since,
    ROUND(EXTRACT(EPOCH FROM (t.analysis_timestamp - ls.event_time)) / 3600, 2) AS hours_in_preparing
FROM latest_status AS ls
CROSS JOIN analysis_time AS t
WHERE ls.status_rank = 1
  AND ls.order_status = 'preparing'
  AND t.analysis_timestamp - ls.event_time > INTERVAL '2 hours'
ORDER BY hours_in_preparing DESC;

-- 18. Find orders stuck in dispatched status too long.
-- Stuck dispatched means latest status is dispatched for more than 3 hours.
WITH analysis_time AS (
    SELECT TIMESTAMP '2026-05-09 10:00:00' AS analysis_timestamp
),
latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    ls.order_id,
    ls.event_time AS dispatched_since,
    ROUND(EXTRACT(EPOCH FROM (t.analysis_timestamp - ls.event_time)) / 3600, 2) AS hours_in_dispatched
FROM latest_status AS ls
CROSS JOIN analysis_time AS t
WHERE ls.status_rank = 1
  AND ls.order_status = 'dispatched'
  AND t.analysis_timestamp - ls.event_time > INTERVAL '3 hours'
ORDER BY hours_in_dispatched DESC;

-- 19. Find drivers currently busy.
SELECT
    driver_id,
    first_name || ' ' || last_name AS driver_name,
    city,
    vehicle_type,
    driver_status
FROM drivers
WHERE driver_status = 'busy'
ORDER BY driver_name;

-- 20. Find inactive drivers based on latest location update.
-- Inactive means the latest location update is older than 60 minutes from the fixed analysis time.
WITH analysis_time AS (
    SELECT TIMESTAMP '2026-05-09 10:00:00' AS analysis_timestamp
),
latest_location AS (
    SELECT
        dl.*,
        ROW_NUMBER() OVER (
            PARTITION BY dl.driver_id
            ORDER BY dl.location_time DESC, dl.location_id DESC
        ) AS location_rank
    FROM driver_locations AS dl
)
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    ll.location_time AS latest_location_time,
    ROUND(EXTRACT(EPOCH FROM (t.analysis_timestamp - ll.location_time)) / 60, 2) AS minutes_since_update
FROM latest_location AS ll
JOIN drivers AS d
    ON ll.driver_id = d.driver_id
CROSS JOIN analysis_time AS t
WHERE ll.location_rank = 1
  AND t.analysis_timestamp - ll.location_time > INTERVAL '60 minutes'
ORDER BY minutes_since_update DESC;

-- 21. Find drivers with highest active deliveries.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    COUNT(ls.order_id) AS active_delivery_count
FROM drivers AS d
LEFT JOIN orders AS o
    ON d.driver_id = o.driver_id
LEFT JOIN latest_status AS ls
    ON o.order_id = ls.order_id
   AND ls.status_rank = 1
   AND ls.order_status IN ('dispatched', 'in_transit', 'out_for_delivery', 'delayed')
GROUP BY d.driver_id, d.first_name, d.last_name
ORDER BY active_delivery_count DESC;

-- 22. Rank drivers by completed deliveries.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
),
driver_completed AS (
    SELECT
        d.driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        COUNT(ls.order_id) AS completed_delivery_count
    FROM drivers AS d
    LEFT JOIN orders AS o
        ON d.driver_id = o.driver_id
    LEFT JOIN latest_status AS ls
        ON o.order_id = ls.order_id
       AND ls.status_rank = 1
       AND ls.order_status = 'delivered'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT
    driver_id,
    driver_name,
    completed_delivery_count,
    RANK() OVER (ORDER BY completed_delivery_count DESC) AS completed_delivery_rank
FROM driver_completed
ORDER BY completed_delivery_rank, driver_name;

-- 23. Find overloaded warehouses.
SELECT
    warehouse_id,
    warehouse_name,
    city,
    warehouse_status
FROM warehouses
WHERE warehouse_status = 'overloaded'
ORDER BY warehouse_name;

-- 24. Count active orders by warehouse.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    w.warehouse_name,
    COALESCE(
        SUM(
            CASE
                WHEN ls.order_status NOT IN ('delivered', 'cancelled', 'returned') THEN 1
                ELSE 0
            END
        ),
        0
    ) AS active_orders
FROM warehouses AS w
LEFT JOIN orders AS o
    ON w.warehouse_id = o.warehouse_id
LEFT JOIN latest_status AS ls
    ON o.order_id = ls.order_id
   AND ls.status_rank = 1
GROUP BY w.warehouse_id, w.warehouse_name
ORDER BY active_orders DESC;

-- 25. Rank warehouses by operational load.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
),
warehouse_load AS (
    SELECT
        w.warehouse_id,
        w.warehouse_name,
        COALESCE(
            SUM(
                CASE
                    WHEN ls.order_status NOT IN ('delivered', 'cancelled', 'returned') THEN 1
                    ELSE 0
                END
            ),
            0
        ) AS active_orders
    FROM warehouses AS w
    LEFT JOIN orders AS o
        ON w.warehouse_id = o.warehouse_id
    LEFT JOIN latest_status AS ls
        ON o.order_id = ls.order_id
       AND ls.status_rank = 1
    GROUP BY w.warehouse_id, w.warehouse_name
)
SELECT
    warehouse_id,
    warehouse_name,
    active_orders,
    DENSE_RANK() OVER (ORDER BY active_orders DESC) AS load_rank
FROM warehouse_load
ORDER BY load_rank;

-- 26. Find delayed routes.
SELECT
    route_id,
    order_id,
    origin_city,
    destination_city,
    estimated_duration_minutes,
    actual_duration_minutes,
    route_status
FROM delivery_routes
WHERE route_status = 'delayed'
   OR actual_duration_minutes > estimated_duration_minutes
ORDER BY COALESCE(actual_duration_minutes - estimated_duration_minutes, 0) DESC;

-- 27. Calculate average route duration by city pair.
SELECT
    origin_city,
    destination_city,
    ROUND(AVG(actual_duration_minutes), 2) AS avg_actual_duration_minutes
FROM delivery_routes
WHERE actual_duration_minutes IS NOT NULL
GROUP BY origin_city, destination_city
ORDER BY avg_actual_duration_minutes DESC;

-- 28. Calculate route delay rate.
-- Route delay rate = delayed routes / total routes for each city pair.
SELECT
    origin_city,
    destination_city,
    COUNT(*) AS total_routes,
    SUM(CASE WHEN route_status = 'delayed' OR actual_duration_minutes > estimated_duration_minutes THEN 1 ELSE 0 END) AS delayed_routes,
    ROUND(
        SUM(CASE WHEN route_status = 'delayed' OR actual_duration_minutes > estimated_duration_minutes THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS route_delay_rate_percent
FROM delivery_routes
GROUP BY origin_city, destination_city
ORDER BY route_delay_rate_percent DESC;

-- 29. Find operational alerts by severity.
SELECT
    alert_severity,
    COUNT(*) AS alert_count
FROM operational_alerts
GROUP BY alert_severity
ORDER BY
    CASE alert_severity
        WHEN 'critical' THEN 1
        WHEN 'high' THEN 2
        WHEN 'medium' THEN 3
        ELSE 4
    END;

-- 30. Count alerts by type.
SELECT
    alert_type,
    COUNT(*) AS alert_count
FROM operational_alerts
GROUP BY alert_type
ORDER BY alert_count DESC;

-- 31. Find unresolved alerts.
SELECT
    alert_id,
    order_id,
    driver_id,
    alert_type,
    alert_severity,
    alert_time,
    alert_status
FROM operational_alerts
WHERE alert_status IN ('open', 'investigating')
ORDER BY alert_time DESC;

-- 32. Find critical alerts.
SELECT
    alert_id,
    order_id,
    driver_id,
    alert_type,
    alert_message,
    alert_time,
    alert_status
FROM operational_alerts
WHERE alert_severity = 'critical'
ORDER BY alert_time DESC;

-- 33. Calculate SLA breach rate.
-- SLA breach rate = delivered orders after expected time / total delivered orders.
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.expected_delivery_datetime,
        MAX(ose.event_time) AS delivered_time
    FROM orders AS o
    JOIN order_status_events AS ose
        ON o.order_id = ose.order_id
    WHERE ose.order_status = 'delivered'
    GROUP BY o.order_id, o.expected_delivery_datetime
)
SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN delivered_time > expected_delivery_datetime THEN 1 ELSE 0 END) AS sla_breached_orders,
    ROUND(
        SUM(CASE WHEN delivered_time > expected_delivery_datetime THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS sla_breach_rate_percent
FROM delivered_orders;

-- 34. Calculate order cancellation rate.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'cancelled' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_percent
FROM latest_status
WHERE status_rank = 1;

-- 35. Calculate order return rate.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        SUM(CASE WHEN order_status = 'returned' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_percent
FROM latest_status
WHERE status_rank = 1;

-- 36. Build operational KPI summary using CTE.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
),
current_orders AS (
    SELECT
        order_id,
        order_status
    FROM latest_status
    WHERE status_rank = 1
),
delivered_orders AS (
    SELECT
        o.order_id,
        o.expected_delivery_datetime,
        MAX(ose.event_time) AS delivered_time
    FROM orders AS o
    JOIN order_status_events AS ose
        ON o.order_id = ose.order_id
    WHERE ose.order_status = 'delivered'
    GROUP BY o.order_id, o.expected_delivery_datetime
)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN co.order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN co.order_status = 'delayed' THEN 1 ELSE 0 END) AS delayed_orders,
    SUM(CASE WHEN co.order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN co.order_status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    (SELECT COUNT(*) FROM operational_alerts WHERE alert_status IN ('open', 'investigating')) AS unresolved_alerts,
    (SELECT COUNT(*) FROM delivered_orders WHERE delivered_time > expected_delivery_datetime) AS sla_breaches
FROM current_orders AS co;

-- 37. Build current operations dashboard view using SQL.
WITH latest_status AS (
    SELECT
        ose.order_id,
        ose.order_status,
        ose.event_time,
        ROW_NUMBER() OVER (
            PARTITION BY ose.order_id
            ORDER BY ose.event_time DESC, ose.event_id DESC
        ) AS status_rank
    FROM order_status_events AS ose
),
alert_summary AS (
    SELECT
        order_id,
        COUNT(*) FILTER (WHERE alert_status IN ('open', 'investigating')) AS active_alert_count,
        COUNT(*) FILTER (
            WHERE alert_status IN ('open', 'investigating')
              AND alert_severity = 'critical'
        ) AS critical_alert_count
    FROM operational_alerts
    GROUP BY order_id
)
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    w.warehouse_name,
    d.first_name || ' ' || d.last_name AS driver_name,
    ls.order_status AS latest_order_status,
    ls.event_time AS latest_status_time,
    o.expected_delivery_datetime,
    CASE
        WHEN ls.order_status = 'delivered' AND ls.event_time <= o.expected_delivery_datetime THEN 'within_sla'
        WHEN ls.order_status = 'delivered' AND ls.event_time > o.expected_delivery_datetime THEN 'sla_breached'
        WHEN TIMESTAMP '2026-05-09 10:00:00' > o.expected_delivery_datetime
             AND ls.order_status NOT IN ('delivered', 'cancelled', 'returned') THEN 'at_risk_or_breached'
        ELSE 'in_progress'
    END AS sla_status,
    dr.route_status AS current_route_status,
    COALESCE(a.active_alert_count, 0) AS active_alert_count,
    CASE
        WHEN COALESCE(a.active_alert_count, 0) >= 2
          OR COALESCE(a.critical_alert_count, 0) > 0 THEN 'critical'
        WHEN ls.order_status IN ('delayed', 'returned') THEN 'urgent'
        WHEN ls.order_status IN ('preparing', 'dispatched', 'in_transit', 'out_for_delivery') THEN 'monitor'
        ELSE 'normal'
    END AS operational_priority
FROM latest_status AS ls
JOIN orders AS o
    ON ls.order_id = o.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN warehouses AS w
    ON o.warehouse_id = w.warehouse_id
LEFT JOIN drivers AS d
    ON o.driver_id = d.driver_id
LEFT JOIN delivery_routes AS dr
    ON o.order_id = dr.order_id
LEFT JOIN alert_summary AS a
    ON o.order_id = a.order_id
WHERE ls.status_rank = 1
ORDER BY
    CASE
        WHEN COALESCE(a.active_alert_count, 0) >= 2
          OR COALESCE(a.critical_alert_count, 0) > 0 THEN 1
        WHEN ls.order_status IN ('delayed', 'returned') THEN 2
        WHEN ls.order_status IN ('preparing', 'dispatched', 'in_transit', 'out_for_delivery') THEN 3
        ELSE 4
    END,
    latest_status_time;

-- 38. Build driver activity dashboard view using SQL.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
),
latest_location AS (
    SELECT
        dl.driver_id,
        dl.location_time,
        ROW_NUMBER() OVER (
            PARTITION BY dl.driver_id
            ORDER BY dl.location_time DESC, dl.location_id DESC
        ) AS location_rank
    FROM driver_locations AS dl
),
driver_orders AS (
    SELECT
        d.driver_id,
        COUNT(o.order_id) FILTER (
            WHERE ls.order_status IN ('dispatched', 'in_transit', 'out_for_delivery', 'delayed')
        ) AS active_delivery_count,
        COUNT(o.order_id) FILTER (WHERE ls.order_status = 'delivered') AS completed_delivery_count,
        COUNT(o.order_id) FILTER (WHERE ls.order_status = 'delayed') AS delayed_delivery_count,
        COUNT(o.order_id) AS total_assigned_orders
    FROM drivers AS d
    LEFT JOIN orders AS o
        ON d.driver_id = o.driver_id
    LEFT JOIN latest_status AS ls
        ON o.order_id = ls.order_id
       AND ls.status_rank = 1
    GROUP BY d.driver_id
)
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    d.city,
    d.vehicle_type,
    d.driver_status,
    ll.location_time AS latest_location_time,
    COALESCE(doa.active_delivery_count, 0) AS active_delivery_count,
    COALESCE(doa.completed_delivery_count, 0) AS completed_delivery_count,
    ROUND(
        COALESCE(doa.delayed_delivery_count, 0) * 100.0
        / NULLIF(COALESCE(doa.total_assigned_orders, 0), 0),
        2
    ) AS delay_rate_percent,
    CASE
        WHEN TIMESTAMP '2026-05-09 10:00:00' - ll.location_time > INTERVAL '60 minutes' THEN 'inactive_too_long'
        WHEN d.driver_status IN ('offline', 'suspended') THEN 'not_available'
        ELSE 'active_recently'
    END AS inactivity_status
FROM drivers AS d
LEFT JOIN latest_location AS ll
    ON d.driver_id = ll.driver_id
   AND ll.location_rank = 1
LEFT JOIN driver_orders AS doa
    ON d.driver_id = doa.driver_id
ORDER BY active_delivery_count DESC, delay_rate_percent DESC NULLS LAST;

-- 39. Build warehouse operations dashboard view using SQL.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
),
delivered_orders AS (
    SELECT
        o.order_id,
        o.warehouse_id,
        o.order_datetime,
        o.expected_delivery_datetime,
        MAX(ose.event_time) AS delivered_time
    FROM orders AS o
    JOIN order_status_events AS ose
        ON o.order_id = ose.order_id
    WHERE ose.order_status = 'delivered'
    GROUP BY o.order_id, o.warehouse_id, o.order_datetime, o.expected_delivery_datetime
)
SELECT
    w.warehouse_id,
    w.warehouse_name,
    w.city,
    w.warehouse_status,
    COUNT(o.order_id) FILTER (
        WHERE ls.order_status NOT IN ('delivered', 'cancelled', 'returned')
    ) AS active_orders,
    COUNT(o.order_id) FILTER (WHERE ls.order_status = 'delayed') AS delayed_orders,
    ROUND(AVG(EXTRACT(EPOCH FROM (do2.delivered_time - do2.order_datetime)) / 60), 2) AS avg_delivery_duration_minutes,
    ROUND(
        COUNT(do2.order_id) FILTER (WHERE do2.delivered_time > do2.expected_delivery_datetime) * 100.0
        / NULLIF(COUNT(do2.order_id), 0),
        2
    ) AS sla_breach_rate_percent,
    CASE
        WHEN w.warehouse_status = 'overloaded' THEN 'overloaded_by_status'
        WHEN COUNT(o.order_id) FILTER (
            WHERE ls.order_status NOT IN ('delivered', 'cancelled', 'returned')
        ) >= 10 THEN 'high_active_load'
        ELSE 'normal_load'
    END AS overload_status
FROM warehouses AS w
LEFT JOIN orders AS o
    ON w.warehouse_id = o.warehouse_id
LEFT JOIN latest_status AS ls
    ON o.order_id = ls.order_id
   AND ls.status_rank = 1
LEFT JOIN delivered_orders AS do2
    ON o.order_id = do2.order_id
GROUP BY w.warehouse_id, w.warehouse_name, w.city, w.warehouse_status
ORDER BY active_orders DESC;

-- 40. Create operational recommendations using CASE WHEN.
WITH latest_status AS (
    SELECT
        order_id,
        order_status,
        event_time,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY event_time DESC, event_id DESC
        ) AS status_rank
    FROM order_status_events
),
current_orders AS (
    SELECT
        o.order_id,
        o.warehouse_id,
        o.driver_id,
        ls.order_status,
        ls.event_time,
        dr.route_status
    FROM orders AS o
    JOIN latest_status AS ls
        ON o.order_id = ls.order_id
       AND ls.status_rank = 1
    LEFT JOIN delivery_routes AS dr
        ON o.order_id = dr.order_id
)
SELECT
    co.order_id,
    co.order_status,
    co.route_status,
    CASE
        WHEN co.order_status = 'delayed' THEN 'Investigate delayed orders'
        WHEN co.route_status = 'delayed' THEN 'Optimize delivery route'
        WHEN co.order_status IN ('preparing', 'dispatched')
             AND TIMESTAMP '2026-05-09 10:00:00' - co.event_time > INTERVAL '2 hours' THEN 'Escalate stuck order'
        WHEN w.warehouse_status = 'overloaded' THEN 'Increase warehouse staffing'
        WHEN d.driver_status IN ('offline', 'suspended') THEN 'Monitor inactive drivers'
        ELSE 'Maintain current operations'
    END AS recommended_action
FROM current_orders AS co
JOIN warehouses AS w
    ON co.warehouse_id = w.warehouse_id
LEFT JOIN drivers AS d
    ON co.driver_id = d.driver_id
ORDER BY co.order_id;

-- 41. Simulate live tracking latest status query.
WITH live_latest_status AS (
    SELECT
        ose.order_id,
        ose.event_time,
        ose.order_status,
        ROW_NUMBER() OVER (
            PARTITION BY ose.order_id
            ORDER BY ose.event_time DESC, ose.event_id DESC
        ) AS status_rank
    FROM order_status_events AS ose
    WHERE ose.event_time <= TIMESTAMP '2026-05-09 10:00:00'
)
SELECT
    order_id,
    order_status AS live_order_status,
    event_time AS live_status_time
FROM live_latest_status
WHERE status_rank = 1
ORDER BY live_status_time DESC;

-- 42. Find most recent driver location per driver.
WITH latest_location AS (
    SELECT
        dl.*,
        ROW_NUMBER() OVER (
            PARTITION BY dl.driver_id
            ORDER BY dl.location_time DESC, dl.location_id DESC
        ) AS location_rank
    FROM driver_locations AS dl
)
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    ll.location_time,
    ll.city,
    ll.latitude,
    ll.longitude,
    ll.is_active
FROM latest_location AS ll
JOIN drivers AS d
    ON ll.driver_id = d.driver_id
WHERE ll.location_rank = 1
ORDER BY ll.location_time DESC;

-- 43. Detect drivers inactive for too long.
WITH latest_location AS (
    SELECT
        driver_id,
        location_time,
        ROW_NUMBER() OVER (
            PARTITION BY driver_id
            ORDER BY location_time DESC, location_id DESC
        ) AS location_rank
    FROM driver_locations
)
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    d.driver_status,
    ll.location_time,
    ROUND(EXTRACT(EPOCH FROM (TIMESTAMP '2026-05-09 10:00:00' - ll.location_time)) / 60, 2) AS inactive_minutes
FROM latest_location AS ll
JOIN drivers AS d
    ON ll.driver_id = d.driver_id
WHERE ll.location_rank = 1
  AND TIMESTAMP '2026-05-09 10:00:00' - ll.location_time > INTERVAL '60 minutes'
ORDER BY inactive_minutes DESC;

-- 44. Find orders with excessive status transitions.
SELECT
    order_id,
    COUNT(*) AS status_transition_count
FROM order_status_events
GROUP BY order_id
HAVING COUNT(*) >= 8
ORDER BY status_transition_count DESC, order_id;

-- 45. Calculate average time spent in each status.
-- LEAD gets the next event_time, then the query measures how long each status lasted.
WITH status_steps AS (
    SELECT
        order_id,
        order_status,
        event_time,
        LEAD(event_time) OVER (
            PARTITION BY order_id
            ORDER BY event_time, event_id
        ) AS next_event_time
    FROM order_status_events
)
SELECT
    order_status,
    ROUND(AVG(EXTRACT(EPOCH FROM (next_event_time - event_time)) / 60), 2) AS avg_minutes_in_status
FROM status_steps
WHERE next_event_time IS NOT NULL
GROUP BY order_status
ORDER BY avg_minutes_in_status DESC;

-- Extra event helper: compare each status with the previous status.
-- LAG is useful for auditing status transitions in an event log.
SELECT
    order_id,
    event_time,
    LAG(order_status) OVER (
        PARTITION BY order_id
        ORDER BY event_time, event_id
    ) AS previous_status,
    order_status AS current_status
FROM order_status_events
ORDER BY order_id, event_time;

-- Extra trend helper: cumulative operational alerts over time.
SELECT
    alert_time::date AS alert_date,
    COUNT(*) AS daily_alerts,
    SUM(COUNT(*)) OVER (ORDER BY alert_time::date) AS cumulative_alerts
FROM operational_alerts
GROUP BY alert_time::date
ORDER BY alert_date;

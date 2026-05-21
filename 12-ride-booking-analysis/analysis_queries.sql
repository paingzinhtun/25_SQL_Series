-- Day 12 - Ride Booking Analysis
-- Analysis queries for PostgreSQL
--
-- Revenue rule used throughout this file:
-- Count only trips where trip_status = 'completed' and payment_status = 'paid'.
-- Cancelled, requested, in_progress, unpaid, refunded, and failed records are not real revenue.

-- 1. List all riders.
SELECT
    rider_id,
    first_name,
    last_name,
    email,
    city,
    signup_date
FROM riders
ORDER BY signup_date, rider_id;

-- 2. List all drivers with vehicle information.
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    d.city,
    d.driver_status,
    v.vehicle_type,
    v.vehicle_model,
    v.plate_number
FROM drivers AS d
LEFT JOIN vehicles AS v
    ON d.driver_id = v.driver_id
ORDER BY d.driver_id;

-- 3. List all locations by city and location type.
SELECT
    city,
    location_type,
    location_name
FROM locations
ORDER BY city, location_type, location_name;

-- 4. Show all trips with rider, driver, pickup, dropoff, and payment status.
SELECT
    t.trip_id,
    t.booking_time,
    r.first_name || ' ' || r.last_name AS rider_name,
    d.first_name || ' ' || d.last_name AS driver_name,
    pickup.location_name AS pickup_location,
    dropoff.location_name AS dropoff_location,
    t.trip_status,
    p.payment_status,
    t.fare_amount
FROM trips AS t
JOIN riders AS r
    ON t.rider_id = r.rider_id
JOIN drivers AS d
    ON t.driver_id = d.driver_id
JOIN locations AS pickup
    ON t.pickup_location_id = pickup.location_id
JOIN locations AS dropoff
    ON t.dropoff_location_id = dropoff.location_id
JOIN payments AS p
    ON t.trip_id = p.trip_id
ORDER BY t.booking_time, t.trip_id;

-- 5. Show only completed and paid trips.
SELECT
    t.trip_id,
    t.booking_time,
    r.first_name || ' ' || r.last_name AS rider_name,
    d.first_name || ' ' || d.last_name AS driver_name,
    t.distance_km,
    t.duration_minutes,
    p.amount AS paid_amount
FROM trips AS t
JOIN riders AS r
    ON t.rider_id = r.rider_id
JOIN drivers AS d
    ON t.driver_id = d.driver_id
JOIN payments AS p
    ON t.trip_id = p.trip_id
WHERE t.trip_status = 'completed'
  AND p.payment_status = 'paid'
ORDER BY t.booking_time;

-- 6. Calculate total revenue from completed and paid trips.
WITH completed_paid_trips AS (
    SELECT
        t.trip_id,
        p.amount
    FROM trips AS t
    JOIN payments AS p
        ON t.trip_id = p.trip_id
    WHERE t.trip_status = 'completed'
      AND p.payment_status = 'paid'
)
SELECT
    SUM(amount) AS total_revenue
FROM completed_paid_trips;

-- 7. Calculate average fare per completed paid trip.
SELECT
    ROUND(AVG(p.amount), 2) AS average_fare
FROM trips AS t
JOIN payments AS p
    ON t.trip_id = p.trip_id
WHERE t.trip_status = 'completed'
  AND p.payment_status = 'paid';

-- 8. Calculate average trip distance.
-- Distance metrics use completed trips only because incomplete trips may not have final distance.
SELECT
    ROUND(AVG(distance_km), 2) AS average_distance_km
FROM trips
WHERE trip_status = 'completed'
  AND distance_km IS NOT NULL;

-- 9. Calculate average trip duration.
-- Duration metrics use completed trips only because cancelled/requested trips do not have final duration.
SELECT
    ROUND(AVG(duration_minutes), 2) AS average_duration_minutes
FROM trips
WHERE trip_status = 'completed'
  AND duration_minutes IS NOT NULL;

-- 10. Find top 10 riders by number of completed trips.
WITH rider_completed_trips AS (
    SELECT
        r.rider_id,
        r.first_name || ' ' || r.last_name AS rider_name,
        COUNT(t.trip_id) AS completed_trips,
        RANK() OVER (ORDER BY COUNT(t.trip_id) DESC) AS rider_rank
    FROM riders AS r
    JOIN trips AS t
        ON r.rider_id = t.rider_id
    WHERE t.trip_status = 'completed'
    GROUP BY r.rider_id, r.first_name, r.last_name
)
SELECT
    rider_rank,
    rider_id,
    rider_name,
    completed_trips
FROM rider_completed_trips
ORDER BY rider_rank, rider_name
LIMIT 10;

-- 11. Find top 10 drivers by number of completed trips.
WITH driver_completed_trips AS (
    SELECT
        d.driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        COUNT(t.trip_id) AS completed_trips,
        RANK() OVER (ORDER BY COUNT(t.trip_id) DESC) AS driver_rank
    FROM drivers AS d
    JOIN trips AS t
        ON d.driver_id = t.driver_id
    WHERE t.trip_status = 'completed'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT
    driver_rank,
    driver_id,
    driver_name,
    completed_trips
FROM driver_completed_trips
ORDER BY driver_rank, driver_name
LIMIT 10;

-- 12. Find top 10 drivers by total revenue generated.
WITH driver_revenue AS (
    SELECT
        d.driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        SUM(p.amount) AS total_revenue
    FROM drivers AS d
    JOIN trips AS t
        ON d.driver_id = t.driver_id
    JOIN payments AS p
        ON t.trip_id = p.trip_id
    WHERE t.trip_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT
    driver_id,
    driver_name,
    total_revenue
FROM driver_revenue
ORDER BY total_revenue DESC
LIMIT 10;

-- 13. Find riders with no completed trips.
SELECT
    r.rider_id,
    r.first_name || ' ' || r.last_name AS rider_name,
    r.city
FROM riders AS r
LEFT JOIN trips AS t
    ON r.rider_id = t.rider_id
   AND t.trip_status = 'completed'
WHERE t.trip_id IS NULL
ORDER BY r.rider_id;

-- 14. Find drivers with no completed trips.
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    d.driver_status,
    d.city
FROM drivers AS d
LEFT JOIN trips AS t
    ON d.driver_id = t.driver_id
   AND t.trip_status = 'completed'
WHERE t.trip_id IS NULL
ORDER BY d.driver_id;

-- 15. Count trips by trip status.
SELECT
    trip_status,
    COUNT(*) AS total_trips
FROM trips
GROUP BY trip_status
ORDER BY total_trips DESC;

-- 16. Count payments by payment status.
SELECT
    payment_status,
    COUNT(*) AS total_payments,
    SUM(amount) AS total_payment_amount
FROM payments
GROUP BY payment_status
ORDER BY total_payments DESC;

-- 17. Count cancellations by cancelled_by.
SELECT
    COALESCE(cancelled_by, 'not_cancelled') AS cancelled_by,
    COUNT(*) AS total_trips
FROM trips
WHERE trip_status = 'cancelled'
GROUP BY cancelled_by
ORDER BY total_trips DESC;

-- 18. Find most common cancellation reasons.
SELECT
    cancellation_reason,
    COUNT(*) AS cancellation_count
FROM trips
WHERE trip_status = 'cancelled'
GROUP BY cancellation_reason
ORDER BY cancellation_count DESC, cancellation_reason;

-- 19. Calculate cancellation rate.
-- Cancellation rate = cancelled trips / all trips.
-- NULLIF prevents division by zero if the trips table is empty.
WITH trip_counts AS (
    SELECT
        COUNT(*) AS total_trips,
        COUNT(*) FILTER (WHERE trip_status = 'cancelled') AS cancelled_trips
    FROM trips
)
SELECT
    total_trips,
    cancelled_trips,
    ROUND(cancelled_trips * 100.0 / NULLIF(total_trips, 0), 2) AS cancellation_rate_percent
FROM trip_counts;

-- 20. Find peak booking hours.
-- EXTRACT(HOUR FROM booking_time) returns the hour of day from 0 to 23.
WITH hourly_demand AS (
    SELECT
        EXTRACT(HOUR FROM booking_time) AS booking_hour,
        COUNT(*) AS total_bookings
    FROM trips
    GROUP BY EXTRACT(HOUR FROM booking_time)
),
ranked_hours AS (
    SELECT
        booking_hour,
        total_bookings,
        RANK() OVER (ORDER BY total_bookings DESC) AS demand_rank
    FROM hourly_demand
)
SELECT
    demand_rank,
    booking_hour,
    total_bookings
FROM ranked_hours
ORDER BY demand_rank, booking_hour;

-- 21. Calculate daily trip volume.
SELECT
    booking_time::date AS trip_date,
    COUNT(*) AS total_bookings,
    COUNT(*) FILTER (WHERE trip_status = 'completed') AS completed_trips,
    COUNT(*) FILTER (WHERE trip_status = 'cancelled') AS cancelled_trips
FROM trips
GROUP BY booking_time::date
ORDER BY trip_date;

-- 22. Calculate monthly revenue trend.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', t.booking_time)::date AS revenue_month,
        SUM(p.amount) AS total_revenue,
        COUNT(t.trip_id) AS completed_paid_trips
    FROM trips AS t
    JOIN payments AS p
        ON t.trip_id = p.trip_id
    WHERE t.trip_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY DATE_TRUNC('month', t.booking_time)::date
)
SELECT
    revenue_month,
    completed_paid_trips,
    total_revenue
FROM monthly_revenue
ORDER BY revenue_month;

-- 23. Find top pickup locations.
SELECT
    l.location_name,
    l.city,
    COUNT(t.trip_id) AS pickup_count
FROM locations AS l
JOIN trips AS t
    ON l.location_id = t.pickup_location_id
GROUP BY l.location_id, l.location_name, l.city
ORDER BY pickup_count DESC, l.location_name
LIMIT 10;

-- 24. Find top dropoff locations.
SELECT
    l.location_name,
    l.city,
    COUNT(t.trip_id) AS dropoff_count
FROM locations AS l
JOIN trips AS t
    ON l.location_id = t.dropoff_location_id
GROUP BY l.location_id, l.location_name, l.city
ORDER BY dropoff_count DESC, l.location_name
LIMIT 10;

-- 25. Find most common routes.
SELECT
    pickup.location_name AS pickup_location,
    dropoff.location_name AS dropoff_location,
    COUNT(t.trip_id) AS total_trips,
    COUNT(*) FILTER (WHERE t.trip_status = 'completed') AS completed_trips
FROM trips AS t
JOIN locations AS pickup
    ON t.pickup_location_id = pickup.location_id
JOIN locations AS dropoff
    ON t.dropoff_location_id = dropoff.location_id
GROUP BY pickup.location_name, dropoff.location_name
ORDER BY total_trips DESC, completed_trips DESC, pickup_location
LIMIT 10;

-- 26. Calculate average driver rating.
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    ROUND(AVG(tr.driver_rating), 2) AS average_driver_rating,
    COUNT(tr.rating_id) AS total_ratings
FROM drivers AS d
LEFT JOIN trip_ratings AS tr
    ON d.driver_id = tr.driver_id
GROUP BY d.driver_id, d.first_name, d.last_name
ORDER BY average_driver_rating DESC NULLS LAST, total_ratings DESC;

-- 27. Calculate average rider rating.
SELECT
    r.rider_id,
    r.first_name || ' ' || r.last_name AS rider_name,
    ROUND(AVG(tr.rider_rating), 2) AS average_rider_rating,
    COUNT(tr.rating_id) AS total_ratings
FROM riders AS r
LEFT JOIN trip_ratings AS tr
    ON r.rider_id = tr.rider_id
GROUP BY r.rider_id, r.first_name, r.last_name
ORDER BY average_rider_rating DESC NULLS LAST, total_ratings DESC;

-- 28. Find drivers with low average rating below 3.5.
SELECT
    d.driver_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    ROUND(AVG(tr.driver_rating), 2) AS average_driver_rating,
    COUNT(tr.rating_id) AS total_ratings
FROM drivers AS d
JOIN trip_ratings AS tr
    ON d.driver_id = tr.driver_id
GROUP BY d.driver_id, d.first_name, d.last_name
HAVING AVG(tr.driver_rating) < 3.5
ORDER BY average_driver_rating, total_ratings DESC;

-- 29. Rank drivers by completed trips using a window function.
WITH driver_stats AS (
    SELECT
        d.driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        COUNT(t.trip_id) AS completed_trips
    FROM drivers AS d
    LEFT JOIN trips AS t
        ON d.driver_id = t.driver_id
       AND t.trip_status = 'completed'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT
    driver_id,
    driver_name,
    completed_trips,
    DENSE_RANK() OVER (ORDER BY completed_trips DESC) AS completed_trip_rank
FROM driver_stats
ORDER BY completed_trip_rank, driver_name;

-- 30. Create an operational KPI summary using CTEs and CASE WHEN.
-- This combines marketplace health, revenue, cancellation, and service quality metrics in one result.
WITH trip_summary AS (
    SELECT
        COUNT(*) AS total_bookings,
        COUNT(*) FILTER (WHERE trip_status = 'completed') AS completed_trips,
        COUNT(*) FILTER (WHERE trip_status = 'cancelled') AS cancelled_trips,
        COUNT(*) FILTER (WHERE trip_status IN ('requested', 'in_progress')) AS open_trips
    FROM trips
),
revenue_summary AS (
    SELECT
        COALESCE(SUM(p.amount), 0) AS total_revenue,
        ROUND(AVG(p.amount), 2) AS average_paid_fare
    FROM trips AS t
    JOIN payments AS p
        ON t.trip_id = p.trip_id
    WHERE t.trip_status = 'completed'
      AND p.payment_status = 'paid'
),
rating_summary AS (
    SELECT
        ROUND(AVG(driver_rating), 2) AS average_driver_rating,
        ROUND(AVG(rider_rating), 2) AS average_rider_rating
    FROM trip_ratings
)
SELECT
    ts.total_bookings,
    ts.completed_trips,
    ts.cancelled_trips,
    ts.open_trips,
    ROUND(ts.cancelled_trips * 100.0 / NULLIF(ts.total_bookings, 0), 2) AS cancellation_rate_percent,
    rs.total_revenue,
    rs.average_paid_fare,
    rts.average_driver_rating,
    rts.average_rider_rating,
    CASE
        WHEN ts.cancelled_trips * 100.0 / NULLIF(ts.total_bookings, 0) >= 20 THEN 'high_cancellation_attention_needed'
        WHEN rts.average_driver_rating < 4 THEN 'service_quality_attention_needed'
        ELSE 'operations_look_stable'
    END AS operational_status
FROM trip_summary AS ts
CROSS JOIN revenue_summary AS rs
CROSS JOIN rating_summary AS rts;

-- Day 9 - Food Delivery Orders Analysis
-- Analysis queries for PostgreSQL
--
-- Revenue queries count only delivered orders with paid payments.
-- Delivery-time metrics count only completed delivered orders.

-- 1. List all customers.
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone_number,
    city,
    created_at
FROM customers
ORDER BY customer_id;

-- 2. List all restaurants with cuisine type and city.
SELECT
    restaurant_id,
    restaurant_name,
    cuisine_type,
    city
FROM restaurants
ORDER BY restaurant_name;

-- 3. List all menu items with restaurant names.
SELECT
    r.restaurant_name,
    mi.item_name,
    mi.category,
    mi.price,
    mi.is_available
FROM menu_items AS mi
JOIN restaurants AS r
    ON mi.restaurant_id = r.restaurant_id
ORDER BY r.restaurant_name, mi.item_name;

-- 4. Show all orders with customer, restaurant, delivery partner, and payment status.
-- COALESCE gives readable labels when a value is missing.
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    r.restaurant_name,
    COALESCE(dp.first_name || ' ' || dp.last_name, 'No partner assigned') AS delivery_partner,
    o.order_status,
    COALESCE(p.payment_status, 'No payment record') AS payment_status,
    p.payment_method,
    p.amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id
LEFT JOIN delivery_partners AS dp
    ON o.partner_id = dp.partner_id
LEFT JOIN payments AS p
    ON o.order_id = p.order_id
ORDER BY o.order_date, o.order_id;

-- 5. Show detailed order items with item names and line revenue.
SELECT
    oi.order_id,
    r.restaurant_name,
    mi.item_name,
    mi.category,
    oi.quantity,
    oi.item_price,
    oi.quantity * oi.item_price AS line_revenue
FROM order_items AS oi
JOIN menu_items AS mi
    ON oi.item_id = mi.item_id
JOIN restaurants AS r
    ON mi.restaurant_id = r.restaurant_id
ORDER BY oi.order_id, mi.item_name;

-- 6. Calculate total revenue from delivered and paid orders.
-- Revenue excludes cancelled, preparing, out-for-delivery, unpaid, refunded, and failed orders.
SELECT
    SUM(p.amount) AS total_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_status = 'paid';

-- 7. Calculate revenue by restaurant.
WITH delivered_paid_orders AS (
    SELECT
        o.restaurant_id,
        p.amount
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
      AND p.payment_status = 'paid'
)
SELECT
    r.restaurant_name,
    SUM(dpo.amount) AS total_revenue
FROM delivered_paid_orders AS dpo
JOIN restaurants AS r
    ON dpo.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY total_revenue DESC;

-- 8. Calculate revenue by cuisine type.
SELECT
    r.cuisine_type,
    SUM(p.amount) AS total_revenue
FROM orders AS o
JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_status = 'paid'
GROUP BY r.cuisine_type
ORDER BY total_revenue DESC;

-- 9. Find top 5 restaurants by order count.
SELECT
    r.restaurant_name,
    COUNT(o.order_id) AS total_orders
FROM restaurants AS r
LEFT JOIN orders AS o
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY total_orders DESC, r.restaurant_name
LIMIT 5;

-- 10. Find top 5 restaurants by revenue.
-- ROW_NUMBER ranks restaurants after revenue is calculated.
WITH restaurant_revenue AS (
    SELECT
        r.restaurant_name,
        SUM(p.amount) AS total_revenue
    FROM orders AS o
    JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
      AND p.payment_status = 'paid'
    GROUP BY r.restaurant_id, r.restaurant_name
),
ranked_restaurants AS (
    SELECT
        restaurant_name,
        total_revenue,
        ROW_NUMBER() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM restaurant_revenue
)
SELECT
    restaurant_name,
    total_revenue,
    revenue_rank
FROM ranked_restaurants
WHERE revenue_rank <= 5
ORDER BY revenue_rank;

-- 11. Find top 5 customers by total spending.
WITH customer_spending AS (
    SELECT
        o.customer_id,
        SUM(p.amount) AS total_spending
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id
)
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    cs.total_spending
FROM customer_spending AS cs
JOIN customers AS c
    ON cs.customer_id = c.customer_id
ORDER BY cs.total_spending DESC
LIMIT 5;

-- 12. Find repeat customers.
-- HAVING filters grouped customers after counting their orders.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS order_count
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC, customer_name;

-- 13. Count orders by order status.
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 14. Count payments by payment status.
SELECT
    payment_status,
    COUNT(*) AS total_payments,
    SUM(amount) AS total_payment_amount
FROM payments
GROUP BY payment_status
ORDER BY total_payments DESC;

-- 15. Find cancelled orders with customer and restaurant details.
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    r.restaurant_name,
    p.payment_status,
    p.amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id
LEFT JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'cancelled'
ORDER BY o.order_date, o.order_id;

-- 16. Calculate average delivery time for delivered orders.
-- EXTRACT(EPOCH FROM interval) returns seconds. Dividing by 60 converts it to minutes.
SELECT
    ROUND(
        AVG(EXTRACT(EPOCH FROM (delivery_time - order_time)) / 60),
        2
    ) AS average_delivery_minutes
FROM orders
WHERE order_status = 'delivered'
  AND delivery_time IS NOT NULL;

-- 17. Find delayed deliveries where delivery time is more than 45 minutes after order time.
WITH delivery_durations AS (
    SELECT
        o.order_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        r.restaurant_name,
        dp.first_name || ' ' || dp.last_name AS delivery_partner,
        EXTRACT(EPOCH FROM (o.delivery_time - o.order_time)) / 60 AS delivery_minutes
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    JOIN restaurants AS r
        ON o.restaurant_id = r.restaurant_id
    JOIN delivery_partners AS dp
        ON o.partner_id = dp.partner_id
    WHERE o.order_status = 'delivered'
      AND o.delivery_time IS NOT NULL
)
SELECT
    order_id,
    customer_name,
    restaurant_name,
    delivery_partner,
    ROUND(delivery_minutes, 2) AS delivery_minutes
FROM delivery_durations
WHERE delivery_minutes > 45
ORDER BY delivery_minutes DESC;

-- 18. Rank delivery partners by completed deliveries.
SELECT
    dp.first_name || ' ' || dp.last_name AS delivery_partner,
    COUNT(o.order_id) AS completed_deliveries,
    RANK() OVER (
        ORDER BY COUNT(o.order_id) DESC
    ) AS completed_delivery_rank
FROM delivery_partners AS dp
LEFT JOIN orders AS o
    ON dp.partner_id = o.partner_id
   AND o.order_status = 'delivered'
GROUP BY dp.partner_id, dp.first_name, dp.last_name
ORDER BY completed_delivery_rank, delivery_partner;

-- 19. Calculate average delivery rating by delivery partner.
SELECT
    dp.first_name || ' ' || dp.last_name AS delivery_partner,
    COUNT(dr.rating_id) AS rating_count,
    ROUND(AVG(dr.delivery_rating), 2) AS average_delivery_rating
FROM delivery_partners AS dp
LEFT JOIN delivery_ratings AS dr
    ON dp.partner_id = dr.partner_id
GROUP BY dp.partner_id, dp.first_name, dp.last_name
ORDER BY average_delivery_rating NULLS LAST, rating_count DESC;

-- 20. Calculate average food rating by restaurant.
SELECT
    r.restaurant_name,
    COUNT(dr.rating_id) AS rating_count,
    ROUND(AVG(dr.food_rating), 2) AS average_food_rating
FROM restaurants AS r
LEFT JOIN delivery_ratings AS dr
    ON r.restaurant_id = dr.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY average_food_rating DESC NULLS LAST, rating_count DESC;

-- 21. Find most popular food categories by quantity sold.
SELECT
    mi.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items AS oi
JOIN menu_items AS mi
    ON oi.item_id = mi.item_id
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_status = 'paid'
GROUP BY mi.category
ORDER BY total_quantity_sold DESC;

-- 22. Calculate daily order volume.
SELECT
    order_date,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- 23. Calculate monthly revenue trend.
SELECT
    DATE_TRUNC('month', o.order_date)::date AS revenue_month,
    SUM(p.amount) AS monthly_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
  AND p.payment_status = 'paid'
GROUP BY DATE_TRUNC('month', o.order_date)::date
ORDER BY revenue_month;

-- 24. Find restaurants with no orders.
SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine_type,
    r.city
FROM restaurants AS r
LEFT JOIN orders AS o
    ON r.restaurant_id = o.restaurant_id
WHERE o.order_id IS NULL
ORDER BY r.restaurant_name;

-- 25. Find customers with no orders.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY customer_name;

-- 26. Create an operational KPI summary using a CTE and CASE WHEN.
-- The CASE WHEN logic converts raw KPI numbers into simple business labels.
WITH kpi_summary AS (
    SELECT
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered_orders,
        SUM(CASE WHEN order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
        ROUND(
            AVG(
                CASE
                    WHEN order_status = 'delivered' AND delivery_time IS NOT NULL
                        THEN EXTRACT(EPOCH FROM (delivery_time - order_time)) / 60
                END
            ),
            2
        ) AS average_delivery_minutes
    FROM orders
)
SELECT
    total_orders,
    delivered_orders,
    cancelled_orders,
    average_delivery_minutes,
    ROUND((cancelled_orders::numeric / NULLIF(total_orders, 0)) * 100, 2) AS cancellation_rate_percentage,
    CASE
        WHEN average_delivery_minutes <= 35 THEN 'Fast delivery performance'
        WHEN average_delivery_minutes <= 45 THEN 'Acceptable delivery performance'
        ELSE 'Delivery performance needs attention'
    END AS delivery_performance_status
FROM kpi_summary;

-- 27. Find delivery partners with no completed deliveries.
SELECT
    dp.partner_id,
    dp.first_name || ' ' || dp.last_name AS delivery_partner,
    dp.city,
    dp.vehicle_type,
    COUNT(o.order_id) AS completed_deliveries
FROM delivery_partners AS dp
LEFT JOIN orders AS o
    ON dp.partner_id = o.partner_id
   AND o.order_status = 'delivered'
GROUP BY dp.partner_id, dp.first_name, dp.last_name, dp.city, dp.vehicle_type
HAVING COUNT(o.order_id) = 0
ORDER BY delivery_partner;

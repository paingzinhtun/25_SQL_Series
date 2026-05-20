-- Day 11 - E-commerce Customer Behavior Analysis
-- Analysis queries for PostgreSQL
--
-- Revenue rule used throughout this file:
-- Count only orders where order_status = 'completed' and payment_status = 'paid'.
-- Revenue is calculated from order items:
-- (quantity * unit_price) - discount_amount.

-- 1. List all customers with their signup dates.
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    city,
    gender,
    signup_date
FROM customers
ORDER BY signup_date, customer_id;

-- 2. List all products by category.
SELECT
    category,
    product_name,
    unit_price
FROM products
ORDER BY category, product_name;

-- 3. Show all completed and paid orders with customer information.
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    cs.segment_name,
    p.payment_method,
    p.payment_status
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN customer_segments AS cs
    ON o.segment_id = cs.segment_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
ORDER BY o.order_date, o.order_id;

-- 4. Show detailed order items with product names and line revenue.
-- This shows item-level math for every order.
-- Actual revenue reports later filter to completed and paid orders only.
SELECT
    o.order_id,
    o.order_date,
    pr.product_name,
    pr.category,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    (oi.quantity * oi.unit_price) - oi.discount_amount AS line_revenue
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN products AS pr
    ON oi.product_id = pr.product_id
ORDER BY o.order_id, pr.product_name;

-- 5. Calculate total revenue from completed and paid orders.
SELECT
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS total_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid';

-- 6. Calculate average order value.
-- AOV = completed paid revenue / completed paid order count.
WITH completed_paid_order_revenue AS (
    SELECT
        o.order_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.order_id
)
SELECT
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM completed_paid_order_revenue;

-- 7. Find top 10 customers by total spending.
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS total_spending
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    cr.total_spending
FROM customer_revenue AS cr
JOIN customers AS c
    ON cr.customer_id = c.customer_id
ORDER BY cr.total_spending DESC
LIMIT 10;

-- 8. Find repeat customers.
-- Repeat customers have more than one completed paid order.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(DISTINCT o.order_id) AS completed_paid_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY completed_paid_orders DESC, customer_name;

-- 9. Find one-time customers.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(DISTINCT o.order_id) AS completed_paid_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT o.order_id) = 1
ORDER BY customer_name;

-- 10. Find customers with no orders.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    c.signup_date
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.signup_date;

-- 11. Find customers who have not purchased in the last 60 days.
-- This sample uses 2026-05-08 as the analysis date for stable results.
WITH last_purchases AS (
    SELECT
        o.customer_id,
        MAX(o.order_date) AS last_purchase_date
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    lp.last_purchase_date,
    DATE '2026-05-08' - lp.last_purchase_date AS days_since_last_purchase
FROM customers AS c
JOIN last_purchases AS lp
    ON c.customer_id = lp.customer_id
WHERE lp.last_purchase_date < DATE '2026-05-08' - 60
ORDER BY lp.last_purchase_date;

-- 12. Calculate number of completed paid orders per customer.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'completed' AND p.payment_status = 'paid' THEN o.order_id
    END) AS completed_paid_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN payments AS p
    ON o.order_id = p.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY completed_paid_orders DESC, customer_name;

-- 13. Calculate total quantity purchased per customer.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(
        CASE
            WHEN o.order_status = 'completed' AND p.payment_status = 'paid' THEN oi.quantity
            ELSE 0
        END
    ), 0) AS total_quantity_purchased
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN payments AS p
    ON o.order_id = p.order_id
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_quantity_purchased DESC, customer_name;

-- 14. Find each customer's first purchase date.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    MIN(o.order_date) AS first_purchase_date
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY first_purchase_date;

-- 15. Find each customer's most recent purchase date.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    MAX(o.order_date) AS last_purchase_date
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY last_purchase_date DESC;

-- 16. Calculate days between first and second purchase.
WITH ranked_purchases AS (
    SELECT
        o.customer_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS purchase_number
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
),
first_second_purchase AS (
    SELECT
        customer_id,
        MAX(CASE WHEN purchase_number = 1 THEN order_date END) AS first_purchase_date,
        MAX(CASE WHEN purchase_number = 2 THEN order_date END) AS second_purchase_date
    FROM ranked_purchases
    WHERE purchase_number <= 2
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    fsp.first_purchase_date,
    fsp.second_purchase_date,
    fsp.second_purchase_date - fsp.first_purchase_date AS days_to_second_purchase
FROM first_second_purchase AS fsp
JOIN customers AS c
    ON fsp.customer_id = c.customer_id
WHERE fsp.second_purchase_date IS NOT NULL
ORDER BY days_to_second_purchase;

-- 17. Calculate customer lifetime value basics using total spending.
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS total_spending
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    cr.total_orders,
    cr.total_spending,
    ROUND(cr.total_spending / NULLIF(cr.total_orders, 0), 2) AS average_order_value
FROM customer_revenue AS cr
JOIN customers AS c
    ON cr.customer_id = c.customer_id
ORDER BY cr.total_spending DESC;

-- 18. Calculate revenue by customer segment.
SELECT
    cs.segment_name,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS total_revenue
FROM orders AS o
JOIN customer_segments AS cs
    ON o.segment_id = cs.segment_id
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY cs.segment_id, cs.segment_name
ORDER BY total_revenue DESC;

-- 19. Calculate average order value by customer segment.
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.segment_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.segment_id
)
SELECT
    cs.segment_name,
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM order_revenue AS orv
JOIN customer_segments AS cs
    ON orv.segment_id = cs.segment_id
GROUP BY cs.segment_id, cs.segment_name
ORDER BY average_order_value DESC;

-- 20. Find most popular product categories by quantity sold.
SELECT
    pr.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS pr
    ON oi.product_id = pr.product_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY pr.category
ORDER BY total_quantity_sold DESC;

-- 21. Find top product category for each customer.
WITH customer_category_quantity AS (
    SELECT
        o.customer_id,
        pr.category,
        SUM(oi.quantity) AS total_quantity
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS pr
        ON oi.product_id = pr.product_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id, pr.category
),
ranked_categories AS (
    SELECT
        customer_id,
        category,
        total_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY total_quantity DESC, category
        ) AS category_rank
    FROM customer_category_quantity
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rc.category AS preferred_category,
    rc.total_quantity
FROM ranked_categories AS rc
JOIN customers AS c
    ON rc.customer_id = c.customer_id
WHERE rc.category_rank = 1
ORDER BY customer_name;

-- 22. Calculate monthly revenue trend.
SELECT
    DATE_TRUNC('month', o.order_date)::date AS revenue_month,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS monthly_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY DATE_TRUNC('month', o.order_date)::date
ORDER BY revenue_month;

-- 23. Calculate monthly active customers.
SELECT
    DATE_TRUNC('month', o.order_date)::date AS active_month,
    COUNT(DISTINCT o.customer_id) AS monthly_active_customers
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY DATE_TRUNC('month', o.order_date)::date
ORDER BY active_month;

-- 24. Create a simple customer retention status using CASE WHEN.
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT CASE
            WHEN p.payment_id IS NOT NULL THEN o.order_id
        END) AS total_orders,
        MAX(CASE
            WHEN p.payment_id IS NOT NULL THEN o.order_date
        END) AS last_purchase_date,
        COALESCE(SUM(
            CASE
                WHEN p.payment_id IS NOT NULL THEN (oi.quantity * oi.unit_price) - oi.discount_amount
                ELSE 0
            END
        ), 0) AS total_spending
    FROM customers AS c
    LEFT JOIN orders AS o
        ON c.customer_id = o.customer_id
       AND o.order_status = 'completed'
    LEFT JOIN payments AS p
        ON o.order_id = p.order_id
       AND p.payment_status = 'paid'
    LEFT JOIN order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    cm.total_orders,
    cm.last_purchase_date,
    cm.total_spending,
    CASE
        WHEN cm.total_orders = 0 THEN 'no_order'
        WHEN cm.total_spending >= 350000 THEN 'vip_customer'
        WHEN cm.total_orders = 1 THEN 'new_customer'
        WHEN cm.last_purchase_date >= DATE '2026-05-08' - 60 THEN 'active_repeat_customer'
        ELSE 'inactive_repeat_customer'
    END AS retention_status
FROM customer_metrics AS cm
JOIN customers AS c
    ON cm.customer_id = c.customer_id
ORDER BY retention_status, cm.total_spending DESC;

-- 25. Rank customers by total revenue using a window function.
WITH customer_revenue AS (
    SELECT
        o.customer_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS total_revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    cr.total_revenue,
    RANK() OVER (
        ORDER BY cr.total_revenue DESC
    ) AS revenue_rank
FROM customer_revenue AS cr
JOIN customers AS c
    ON cr.customer_id = c.customer_id
ORDER BY revenue_rank, customer_name;

-- 26. Build a basic Customer 360 view using SQL.
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
customer_summary AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date,
        MAX(order_date) AS last_purchase_date,
        COUNT(order_id) AS total_orders,
        SUM(order_revenue) AS total_spending,
        ROUND(AVG(order_revenue), 2) AS average_order_value
    FROM order_revenue
    GROUP BY customer_id
),
category_spending AS (
    SELECT
        o.customer_id,
        pr.category,
        SUM(oi.quantity) AS total_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY SUM(oi.quantity) DESC, pr.category
        ) AS category_rank
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    JOIN products AS pr
        ON oi.product_id = pr.product_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.customer_id, pr.category
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    c.signup_date,
    cs.first_purchase_date,
    cs.last_purchase_date,
    COALESCE(cs.total_orders, 0) AS total_orders,
    COALESCE(cs.total_spending, 0) AS total_spending,
    cs.average_order_value,
    COALESCE(cat.category, 'No preferred category yet') AS preferred_category,
    CASE
        WHEN COALESCE(cs.total_orders, 0) = 0 THEN 'no_order'
        WHEN COALESCE(cs.total_spending, 0) >= 350000 THEN 'vip_customer'
        WHEN cs.total_orders = 1 THEN 'new_customer'
        WHEN cs.last_purchase_date >= DATE '2026-05-08' - 60 THEN 'active_repeat_customer'
        ELSE 'inactive_repeat_customer'
    END AS retention_status
FROM customers AS c
LEFT JOIN customer_summary AS cs
    ON c.customer_id = cs.customer_id
LEFT JOIN category_spending AS cat
    ON c.customer_id = cat.customer_id
   AND cat.category_rank = 1
ORDER BY total_spending DESC, customer_name;

-- 27. Show payment status summary.
SELECT
    payment_status,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_payment_amount
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC;

-- 28. Show order status summary.
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

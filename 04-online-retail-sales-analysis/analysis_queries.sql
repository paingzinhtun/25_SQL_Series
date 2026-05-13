-- Day 4 - Online Retail Sales Analysis
-- Business analysis queries for PostgreSQL

-- 1. List all customers.
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    city,
    customer_segment,
    created_at
FROM customers
ORDER BY customer_id;

-- 2. List all products with categories and prices.
SELECT
    product_id,
    product_name,
    category,
    unit_price
FROM products
ORDER BY category, product_name;

-- 3. Show all orders with customer and store information.
-- Orders connect customers to stores and show the current order status.
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    s.store_name,
    s.city AS store_city,
    o.order_status
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN stores AS s
    ON o.store_id = s.store_id
ORDER BY o.order_date, o.order_id;

-- 4. Show detailed order items with product names and line revenue.
-- Line revenue is quantity multiplied by the unit price stored on the order item.
SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;

-- 5. Calculate total revenue from completed and paid orders.
-- Business rule: only completed orders with paid payments count as real revenue.
SELECT
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid';

-- 6. Calculate daily sales revenue.
SELECT
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS daily_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY o.order_date
ORDER BY o.order_date;

-- 7. Calculate monthly sales revenue.
-- DATE_TRUNC groups order dates into calendar months.
SELECT
    DATE_TRUNC('month', o.order_date)::date AS sales_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY DATE_TRUNC('month', o.order_date)::date
ORDER BY sales_month;

-- 8. Find top 5 best-selling products by quantity.
SELECT
    pr.product_name,
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
GROUP BY pr.product_id, pr.product_name, pr.category
ORDER BY total_quantity_sold DESC, pr.product_name
LIMIT 5;

-- 9. Find top 5 products by revenue.
SELECT
    pr.product_name,
    pr.category,
    SUM(oi.quantity * oi.unit_price) AS product_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS pr
    ON oi.product_id = pr.product_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY pr.product_id, pr.product_name, pr.category
ORDER BY product_revenue DESC, pr.product_name
LIMIT 5;

-- 10. Find revenue by product category.
SELECT
    pr.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
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
ORDER BY category_revenue DESC;

-- 11. Find revenue by store or branch.
SELECT
    s.store_name,
    s.city,
    SUM(oi.quantity * oi.unit_price) AS store_revenue
FROM orders AS o
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN stores AS s
    ON o.store_id = s.store_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY s.store_id, s.store_name, s.city
ORDER BY store_revenue DESC;

-- 12. Find top 5 customers by total spending.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY total_spending DESC, customer_name
LIMIT 5;

-- 13. Count orders by order status.
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC, order_status;

-- 14. Count payments by payment status.
-- CASE WHEN adds a beginner-friendly business meaning for each payment status.
SELECT
    payment_status,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_payment_amount,
    CASE
        WHEN payment_status = 'paid' THEN 'Money received'
        WHEN payment_status = 'unpaid' THEN 'Money not received yet'
        WHEN payment_status = 'refunded' THEN 'Money returned to customer'
    END AS payment_status_meaning
FROM payments
GROUP BY payment_status
ORDER BY payment_count DESC, payment_status;

-- 15. Calculate average order value.
-- A CTE calculates revenue per order first, then AVG calculates the average order value.
WITH completed_paid_orders AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
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
FROM completed_paid_orders;

-- 16. Find repeat customers.
-- HAVING filters grouped customers after their completed paid order count is calculated.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(DISTINCT o.order_id) AS completed_paid_order_count,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY completed_paid_order_count DESC, total_spending DESC;

-- 17. Find cancelled orders and their payment status.
-- LEFT JOIN is used so cancelled orders still appear even if payment data is missing later.
SELECT
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_status,
    p.payment_status,
    p.amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
LEFT JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'cancelled'
ORDER BY o.order_date, o.order_id;

-- 18. Rank stores by total revenue.
-- The CTE calculates revenue by store, then RANK shows store performance order.
WITH store_revenue AS (
    SELECT
        s.store_id,
        s.store_name,
        s.city,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM stores AS s
    JOIN orders AS o
        ON s.store_id = o.store_id
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY s.store_id, s.store_name, s.city
)
SELECT
    store_name,
    city,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM store_revenue
ORDER BY revenue_rank, store_name;

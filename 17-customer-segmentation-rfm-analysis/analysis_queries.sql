-- Day 17 - Customer Segmentation with RFM Analysis
-- PostgreSQL analysis queries
--
-- Fixed analysis date for reproducible recency calculations:
-- DATE '2026-05-01'
--
-- RFM rules used in this project:
-- Recency = days since last completed paid purchase
-- Frequency = number of completed paid orders
-- Monetary = total spending from completed paid orders
-- Only orders where order_status = 'completed' and payment_status = 'paid' count toward RFM.

-- 1. List all customers.
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    city,
    signup_date
FROM customers
ORDER BY customer_id;

-- 2. List all completed and paid orders with customer information.
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    p.payment_status,
    p.amount AS paid_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
ORDER BY o.order_date, o.order_id;

-- 3. Show order items with product names and line revenue.
-- Line revenue = quantity * unit_price - discount_amount.
SELECT
    oi.order_item_id,
    oi.order_id,
    pr.product_name,
    pr.category,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    (oi.quantity * oi.unit_price) - oi.discount_amount AS line_revenue
FROM order_items AS oi
JOIN products AS pr
    ON oi.product_id = pr.product_id
ORDER BY oi.order_id, oi.order_item_id;

-- 4. Calculate total revenue from completed and paid orders.
WITH valid_order_revenue AS (
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
    SUM(order_revenue) AS total_revenue
FROM valid_order_revenue;

-- 5. Calculate revenue by customer.
WITH valid_order_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(vor.order_revenue) AS total_revenue
FROM valid_order_revenue AS vor
JOIN customers AS c
    ON vor.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_revenue DESC;

-- 6. Calculate order frequency by customer.
-- Frequency means completed paid order count.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS frequency
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, customer_name
ORDER BY frequency DESC;

-- 7. Calculate last purchase date by customer.
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
GROUP BY c.customer_id, customer_name
ORDER BY last_purchase_date DESC;

-- 8. Calculate recency in days using a fixed analysis date.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    MAX(o.order_date) AS last_purchase_date,
    (DATE '2026-05-01' - MAX(o.order_date))::INTEGER AS recency_days
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, customer_name
ORDER BY recency_days;

-- 9. Calculate monetary value per customer.
WITH valid_order_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(vor.order_revenue) AS monetary_value
FROM valid_order_revenue AS vor
JOIN customers AS c
    ON vor.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY monetary_value DESC;

-- 10. Build a basic RFM base table with recency, frequency, and monetary value.
WITH valid_order_revenue AS (
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
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    MAX(vor.order_date) AS last_purchase_date,
    (DATE '2026-05-01' - MAX(vor.order_date))::INTEGER AS recency_days,
    COUNT(vor.order_id) AS frequency,
    SUM(vor.order_revenue) AS monetary_value
FROM customers AS c
JOIN valid_order_revenue AS vor
    ON c.customer_id = vor.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY monetary_value DESC;

-- 11. Assign recency scores from 1 to 5.
-- Lower recency is better, so ordering by recency_days DESC gives the newest customers score 5.
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        (DATE '2026-05-01' - MAX(o.order_date))::INTEGER AS recency_days
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    recency_days,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score
FROM rfm_base
ORDER BY recency_score DESC, recency_days;

-- 12. Assign frequency scores from 1 to 5.
-- Higher frequency is better.
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COUNT(o.order_id) AS frequency
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN payments AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    frequency,
    NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score
FROM rfm_base
ORDER BY frequency_score DESC, frequency DESC;

-- 13. Assign monetary scores from 1 to 5.
-- Higher monetary value is better.
WITH customer_monetary AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS monetary_value
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN payments AS p
        ON o.order_id = p.order_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    monetary_value,
    NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
FROM customer_monetary
ORDER BY monetary_score DESC, monetary_value DESC;

-- 14. Combine RFM scores into one RFM score string.
WITH valid_order_revenue AS (
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
rfm_base AS (
    SELECT
        customer_id,
        (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days,
        COUNT(order_id) AS frequency,
        SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rs.recency_score,
    rs.frequency_score,
    rs.monetary_score,
    rs.recency_score::TEXT || rs.frequency_score::TEXT || rs.monetary_score::TEXT AS rfm_score
FROM rfm_scores AS rs
JOIN customers AS c
    ON rs.customer_id = c.customer_id
ORDER BY rfm_score DESC;

-- 15. Segment customers using CASE WHEN based on RFM scores.
WITH valid_order_revenue AS (
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
rfm_base AS (
    SELECT
        customer_id,
        (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days,
        COUNT(order_id) AS frequency,
        SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rs.recency_days,
    rs.frequency,
    rs.monetary_value,
    rs.recency_score,
    rs.frequency_score,
    rs.monetary_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'champions'
        WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'cannot_lose_them'
        WHEN frequency_score >= 4 AND recency_score >= 3 THEN 'loyal_customers'
        WHEN recency_score >= 4 AND frequency BETWEEN 2 AND 3 THEN 'potential_loyalists'
        WHEN recency_score >= 4 AND frequency = 1 THEN 'new_customers'
        WHEN frequency = 1 THEN 'one_time_buyers'
        WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'at_risk'
        WHEN recency_score = 1 AND frequency_score <= 2 THEN 'lost_customers'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'hibernating'
        ELSE 'at_risk'
    END AS customer_segment
FROM rfm_scores AS rs
JOIN customers AS c
    ON rs.customer_id = c.customer_id
ORDER BY customer_segment, monetary_value DESC;

-- 16. Count customers by segment.
WITH valid_order_revenue AS (
    SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p ON o.order_id = p.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
rfm_base AS (
    SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
),
segments AS (
    SELECT
        customer_id,
        monetary_value,
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'champions'
            WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'cannot_lose_them'
            WHEN frequency_score >= 4 AND recency_score >= 3 THEN 'loyal_customers'
            WHEN recency_score >= 4 AND frequency BETWEEN 2 AND 3 THEN 'potential_loyalists'
            WHEN recency_score >= 4 AND frequency = 1 THEN 'new_customers'
            WHEN frequency = 1 THEN 'one_time_buyers'
            WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'at_risk'
            WHEN recency_score = 1 AND frequency_score <= 2 THEN 'lost_customers'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'hibernating'
            ELSE 'at_risk'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM segments
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- 17. Calculate revenue by segment.
WITH valid_order_revenue AS (
    SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p ON o.order_id = p.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
rfm_base AS (
    SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
),
segments AS (
    SELECT
        monetary_value,
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'champions'
            WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'cannot_lose_them'
            WHEN frequency_score >= 4 AND recency_score >= 3 THEN 'loyal_customers'
            WHEN recency_score >= 4 AND frequency BETWEEN 2 AND 3 THEN 'potential_loyalists'
            WHEN recency_score >= 4 AND frequency = 1 THEN 'new_customers'
            WHEN frequency = 1 THEN 'one_time_buyers'
            WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'at_risk'
            WHEN recency_score = 1 AND frequency_score <= 2 THEN 'lost_customers'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'hibernating'
            ELSE 'at_risk'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    SUM(monetary_value) AS segment_revenue
FROM segments
GROUP BY customer_segment
ORDER BY segment_revenue DESC;

-- 18. Calculate average order value by segment.
WITH valid_order_revenue AS (
    SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o
    JOIN payments AS p ON o.order_id = p.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
rfm_base AS (
    SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
),
segments AS (
    SELECT
        customer_id,
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'champions'
            WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'cannot_lose_them'
            WHEN frequency_score >= 4 AND recency_score >= 3 THEN 'loyal_customers'
            WHEN recency_score >= 4 AND frequency BETWEEN 2 AND 3 THEN 'potential_loyalists'
            WHEN recency_score >= 4 AND frequency = 1 THEN 'new_customers'
            WHEN frequency = 1 THEN 'one_time_buyers'
            WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'at_risk'
            WHEN recency_score = 1 AND frequency_score <= 2 THEN 'lost_customers'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'hibernating'
            ELSE 'at_risk'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    s.customer_segment,
    ROUND(AVG(vor.order_revenue), 2) AS average_order_value
FROM segments AS s
JOIN valid_order_revenue AS vor
    ON s.customer_id = vor.customer_id
GROUP BY s.customer_segment
ORDER BY average_order_value DESC;

-- 19. Find champion customers.
-- Champions have strong recency, frequency, and monetary scores.
WITH rfm AS (
    SELECT * FROM (
        WITH valid_order_revenue AS (
            SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
            FROM orders AS o
            JOIN payments AS p ON o.order_id = p.order_id
            JOIN order_items AS oi ON o.order_id = oi.order_id
            WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
            GROUP BY o.order_id, o.customer_id, o.order_date
        ),
        rfm_base AS (
            SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
            FROM valid_order_revenue GROUP BY customer_id
        )
        SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
        FROM rfm_base
    ) AS scored
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rfm.recency_days,
    rfm.frequency,
    rfm.monetary_value
FROM rfm
JOIN customers AS c ON rfm.customer_id = c.customer_id
WHERE rfm.recency_score >= 4
  AND rfm.frequency_score >= 4
  AND rfm.monetary_score >= 4
ORDER BY rfm.monetary_value DESC;

-- 20. Find loyal customers.
WITH rfm AS (
    SELECT * FROM (
        WITH valid_order_revenue AS (
            SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
            FROM orders AS o JOIN payments AS p ON o.order_id = p.order_id JOIN order_items AS oi ON o.order_id = oi.order_id
            WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
            GROUP BY o.order_id, o.customer_id, o.order_date
        ),
        rfm_base AS (
            SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
            FROM valid_order_revenue GROUP BY customer_id
        )
        SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
        FROM rfm_base
    ) AS scored
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rfm.frequency,
    rfm.recency_days,
    rfm.monetary_value
FROM rfm
JOIN customers AS c ON rfm.customer_id = c.customer_id
WHERE rfm.frequency_score >= 4
  AND rfm.recency_score >= 3
ORDER BY rfm.frequency DESC, rfm.monetary_value DESC;

-- 21. Find potential loyalists.
WITH rfm AS (
    SELECT * FROM (
        WITH valid_order_revenue AS (
            SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
            FROM orders AS o JOIN payments AS p ON o.order_id = p.order_id JOIN order_items AS oi ON o.order_id = oi.order_id
            WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
            GROUP BY o.order_id, o.customer_id, o.order_date
        ),
        rfm_base AS (
            SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
            FROM valid_order_revenue GROUP BY customer_id
        )
        SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score FROM rfm_base
    ) AS scored
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rfm.recency_days,
    rfm.frequency,
    rfm.monetary_value
FROM rfm
JOIN customers AS c ON rfm.customer_id = c.customer_id
WHERE rfm.recency_score >= 4
  AND rfm.frequency BETWEEN 2 AND 3
ORDER BY rfm.recency_days, rfm.frequency DESC;

-- 22. Find at-risk customers.
WITH rfm AS (
    SELECT * FROM (
        WITH valid_order_revenue AS (
            SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
            FROM orders AS o JOIN payments AS p ON o.order_id = p.order_id JOIN order_items AS oi ON o.order_id = oi.order_id
            WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
            GROUP BY o.order_id, o.customer_id, o.order_date
        ),
        rfm_base AS (
            SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
            FROM valid_order_revenue GROUP BY customer_id
        )
        SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
        FROM rfm_base
    ) AS scored
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    rfm.recency_days,
    rfm.frequency,
    rfm.monetary_value
FROM rfm
JOIN customers AS c ON rfm.customer_id = c.customer_id
WHERE rfm.recency_score <= 2
  AND rfm.monetary_score >= 4
ORDER BY rfm.monetary_value DESC;

-- 23. Find lost customers.
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        (DATE '2026-05-01' - MAX(o.order_date))::INTEGER AS recency_days,
        COUNT(o.order_id) AS frequency
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS p ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    recency_days,
    frequency
FROM rfm_base
WHERE recency_days >= 180
  AND frequency <= 2
ORDER BY recency_days DESC;

-- 24. Find one-time buyers.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS completed_paid_orders
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN payments AS p ON o.order_id = p.order_id
WHERE o.order_status = 'completed'
  AND p.payment_status = 'paid'
GROUP BY c.customer_id, customer_name
HAVING COUNT(o.order_id) = 1
ORDER BY customer_name;

-- 25. Find customers with no completed paid orders.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    COUNT(o.order_id) AS all_order_attempts
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN payments AS p
    ON o.order_id = p.order_id
GROUP BY c.customer_id, customer_name, c.city
HAVING COUNT(o.order_id) FILTER (
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
) = 0
ORDER BY c.customer_id;

-- 26. Find inactive customers based on recency threshold.
-- Example threshold: no completed paid purchase in the last 120 days.
WITH rfm_base AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        MAX(o.order_date) AS last_purchase_date,
        (DATE '2026-05-01' - MAX(o.order_date))::INTEGER AS recency_days
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS p ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT *
FROM rfm_base
WHERE recency_days > 120
ORDER BY recency_days DESC;

-- 27. Find top 10 customers by monetary value.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS monetary_value
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS p ON o.order_id = p.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT
    RANK() OVER (ORDER BY monetary_value DESC) AS monetary_rank,
    customer_id,
    customer_name,
    monetary_value
FROM customer_revenue
ORDER BY monetary_rank
LIMIT 10;

-- 28. Find top 10 customers by frequency.
WITH customer_frequency AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COUNT(o.order_id) AS frequency
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS p ON o.order_id = p.order_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name
)
SELECT
    RANK() OVER (ORDER BY frequency DESC) AS frequency_rank,
    customer_id,
    customer_name,
    frequency
FROM customer_frequency
ORDER BY frequency_rank
LIMIT 10;

-- 29. Find top customers by combined RFM score.
WITH valid_order_revenue AS (
    SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o JOIN payments AS p ON o.order_id = p.order_id JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
rfm_base AS (
    SELECT customer_id, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue GROUP BY customer_id
),
rfm_scores AS (
    SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS combined_rfm_score,
    DENSE_RANK() OVER (
        ORDER BY recency_score + frequency_score + monetary_score DESC
    ) AS rfm_rank
FROM rfm_scores AS rs
JOIN customers AS c ON rs.customer_id = c.customer_id
ORDER BY rfm_rank, customer_name;

-- 30. Find preferred product category per customer.
WITH category_spend AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        pr.category,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS category_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM((oi.quantity * oi.unit_price) - oi.discount_amount) DESC
        ) AS category_rank
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS p ON o.order_id = p.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS pr ON oi.product_id = pr.product_id
    WHERE o.order_status = 'completed'
      AND p.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name, pr.category
)
SELECT
    customer_id,
    customer_name,
    category AS preferred_category,
    category_revenue
FROM category_spend
WHERE category_rank = 1
ORDER BY customer_id;

-- 31. Build a Customer 360 RFM view.
WITH valid_order_revenue AS (
    SELECT o.order_id, o.customer_id, o.order_date, SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS order_revenue
    FROM orders AS o JOIN payments AS p ON o.order_id = p.order_id JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed' AND p.payment_status = 'paid'
    GROUP BY o.order_id, o.customer_id, o.order_date
),
rfm_base AS (
    SELECT customer_id, MAX(order_date) AS last_purchase_date, (DATE '2026-05-01' - MAX(order_date))::INTEGER AS recency_days, COUNT(order_id) AS frequency, SUM(order_revenue) AS monetary_value
    FROM valid_order_revenue GROUP BY customer_id
),
rfm_scores AS (
    SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score, NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score, NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
),
preferred_category AS (
    SELECT customer_id, category AS preferred_category
    FROM (
        SELECT
            o.customer_id,
            pr.category,
            ROW_NUMBER() OVER (
                PARTITION BY o.customer_id
                ORDER BY SUM((oi.quantity * oi.unit_price) - oi.discount_amount) DESC
            ) AS category_rank
        FROM orders AS o
        JOIN payments AS p ON o.order_id = p.order_id
        JOIN order_items AS oi ON o.order_id = oi.order_id
        JOIN products AS pr ON oi.product_id = pr.product_id
        WHERE o.order_status = 'completed'
          AND p.payment_status = 'paid'
        GROUP BY o.customer_id, pr.category
    ) AS ranked_categories
    WHERE category_rank = 1
),
customer_360 AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.city,
        c.signup_date,
        rs.last_purchase_date,
        rs.recency_days,
        COALESCE(rs.frequency, 0) AS frequency,
        COALESCE(rs.monetary_value, 0) AS monetary_value,
        ROUND(COALESCE(rs.monetary_value, 0) / NULLIF(rs.frequency, 0), 2) AS average_order_value,
        rs.recency_score,
        rs.frequency_score,
        rs.monetary_score,
        rs.recency_score::TEXT || rs.frequency_score::TEXT || rs.monetary_score::TEXT AS rfm_score,
        pc.preferred_category,
        CASE
            WHEN rs.customer_id IS NULL THEN 'no_completed_paid_orders'
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'champions'
            WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'cannot_lose_them'
            WHEN frequency_score >= 4 AND recency_score >= 3 THEN 'loyal_customers'
            WHEN recency_score >= 4 AND frequency BETWEEN 2 AND 3 THEN 'potential_loyalists'
            WHEN recency_score >= 4 AND frequency = 1 THEN 'new_customers'
            WHEN frequency = 1 THEN 'one_time_buyers'
            WHEN recency_score <= 2 AND monetary_score >= 4 THEN 'at_risk'
            WHEN recency_score = 1 AND frequency_score <= 2 THEN 'lost_customers'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'hibernating'
            ELSE 'at_risk'
        END AS customer_segment
    FROM customers AS c
    LEFT JOIN rfm_scores AS rs ON c.customer_id = rs.customer_id
    LEFT JOIN preferred_category AS pc ON c.customer_id = pc.customer_id
)
SELECT
    *,
    CASE
        WHEN customer_segment = 'champions' THEN 'Send VIP loyalty reward'
        WHEN customer_segment = 'loyal_customers' THEN 'Recommend related products'
        WHEN customer_segment = 'potential_loyalists' THEN 'Send loyalty program invitation'
        WHEN customer_segment = 'new_customers' THEN 'Welcome and educate new customer'
        WHEN customer_segment IN ('at_risk', 'cannot_lose_them') THEN 'Send retention offer'
        WHEN customer_segment IN ('hibernating', 'lost_customers') THEN 'Send reactivation campaign'
        WHEN customer_segment = 'one_time_buyers' THEN 'Recommend related products'
        ELSE 'No action / monitor'
    END AS recommended_action
FROM customer_360
ORDER BY monetary_value DESC, recency_days NULLS LAST;

-- 32. Create recommended marketing actions by segment using CASE WHEN.
SELECT
    segment_name,
    CASE
        WHEN segment_name = 'champions' THEN 'Send VIP loyalty reward'
        WHEN segment_name = 'loyal_customers' THEN 'Recommend related products'
        WHEN segment_name = 'potential_loyalists' THEN 'Send loyalty program invitation'
        WHEN segment_name = 'new_customers' THEN 'Welcome and educate new customer'
        WHEN segment_name IN ('at_risk', 'cannot_lose_them') THEN 'Send retention offer'
        WHEN segment_name IN ('hibernating', 'lost_customers') THEN 'Send reactivation campaign'
        WHEN segment_name = 'one_time_buyers' THEN 'Recommend related products'
        ELSE 'No action / monitor'
    END AS recommended_action
FROM customer_segments
ORDER BY segment_id;

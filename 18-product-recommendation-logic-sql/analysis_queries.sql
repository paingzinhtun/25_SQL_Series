-- Day 18 - Product Recommendation Logic with SQL
-- PostgreSQL analysis queries
--
-- Important:
-- This is not a machine learning recommendation system.
-- It demonstrates simple, explainable SQL recommendation logic.
--
-- Actual purchase behavior uses only:
-- order_status = 'completed' AND payment_status = 'paid'
-- Views and wishlists are interest signals, not confirmed purchases.

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

-- 2. List all products by category and brand.
SELECT
    product_id,
    product_name,
    category,
    brand,
    unit_price
FROM products
ORDER BY category, brand, product_name;

-- 3. Show completed and paid purchases with customer and product details.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_id,
    o.order_date,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    (oi.quantity * oi.unit_price) - oi.discount_amount AS line_revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN payments AS pay
    ON o.order_id = pay.order_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'completed'
  AND pay.payment_status = 'paid'
ORDER BY c.customer_id, o.order_date, o.order_id;

-- 4. Show product views with customer and product details.
SELECT
    pv.view_id,
    pv.view_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id,
    p.product_name,
    p.category
FROM product_views AS pv
JOIN customers AS c
    ON pv.customer_id = c.customer_id
JOIN products AS p
    ON pv.product_id = p.product_id
ORDER BY pv.view_date, pv.view_id;

-- 5. Show wishlist items with customer and product details.
SELECT
    w.wishlist_id,
    w.added_date,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id,
    p.product_name,
    p.category
FROM wishlists AS w
JOIN customers AS c
    ON w.customer_id = c.customer_id
JOIN products AS p
    ON w.product_id = p.product_id
ORDER BY w.added_date, w.wishlist_id;

-- 6. Calculate total quantity sold by product.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(
        SUM(oi.quantity) FILTER (
            WHERE o.order_status = 'completed'
              AND pay.payment_status = 'paid'
        ),
        0
    ) AS total_quantity_sold
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
LEFT JOIN payments AS pay
    ON o.order_id = pay.order_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC;

-- 7. Calculate total revenue by product.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) FILTER (
            WHERE o.order_status = 'completed'
              AND pay.payment_status = 'paid'
        ),
        0
    ) AS product_revenue
FROM products AS p
LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id
LEFT JOIN orders AS o
    ON oi.order_id = o.order_id
LEFT JOIN payments AS pay
    ON o.order_id = pay.order_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY product_revenue DESC;

-- 8. Find top 10 most popular products by quantity sold.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN payments AS pay
    ON o.order_id = pay.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'completed'
  AND pay.payment_status = 'paid'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- 9. Find top 10 products by revenue.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS product_revenue
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
JOIN payments AS pay
    ON o.order_id = pay.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'completed'
  AND pay.payment_status = 'paid'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY product_revenue DESC
LIMIT 10;

-- 10. Find most popular products by category.
WITH product_sales AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.quantity) DESC
        ) AS category_popularity_rank
    FROM order_items AS oi
    JOIN orders AS o ON oi.order_id = o.order_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT *
FROM product_sales
WHERE category_popularity_rank = 1
ORDER BY category;

-- 11. Find each customer's purchased products.
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_purchased
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN payments AS pay ON o.order_id = pay.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
WHERE o.order_status = 'completed'
  AND pay.payment_status = 'paid'
GROUP BY c.customer_id, customer_name, p.product_id, p.product_name
ORDER BY c.customer_id, total_quantity_purchased DESC;

-- 12. Find each customer's preferred category based on purchase quantity.
WITH customer_category_quantity AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        p.category,
        SUM(oi.quantity) AS category_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM(oi.quantity) DESC
        ) AS category_rank
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name, p.category
)
SELECT
    customer_id,
    customer_name,
    category AS preferred_category_by_quantity,
    category_quantity
FROM customer_category_quantity
WHERE category_rank = 1
ORDER BY customer_id;

-- 13. Find each customer's preferred category based on spending.
WITH customer_category_spend AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        p.category,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS category_spend,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY SUM((oi.quantity * oi.unit_price) - oi.discount_amount) DESC
        ) AS category_rank
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY c.customer_id, customer_name, p.category
)
SELECT
    customer_id,
    customer_name,
    category AS preferred_category_by_spending,
    category_spend
FROM customer_category_spend
WHERE category_rank = 1
ORDER BY customer_id;

-- 14. Find products viewed but not purchased by each customer.
WITH purchased_products AS (
    SELECT DISTINCT
        o.customer_id,
        oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id,
    p.product_name,
    p.category,
    COUNT(pv.view_id) AS view_count
FROM product_views AS pv
JOIN customers AS c ON pv.customer_id = c.customer_id
JOIN products AS p ON pv.product_id = p.product_id
LEFT JOIN purchased_products AS pp
    ON pv.customer_id = pp.customer_id
   AND pv.product_id = pp.product_id
WHERE pp.product_id IS NULL
GROUP BY c.customer_id, customer_name, p.product_id, p.product_name, p.category
ORDER BY c.customer_id, view_count DESC;

-- 15. Find products wishlisted but not purchased by each customer.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id,
    p.product_name,
    p.category,
    w.added_date
FROM wishlists AS w
JOIN customers AS c ON w.customer_id = c.customer_id
JOIN products AS p ON w.product_id = p.product_id
LEFT JOIN purchased_products AS pp
    ON w.customer_id = pp.customer_id
   AND w.product_id = pp.product_id
WHERE pp.product_id IS NULL
ORDER BY c.customer_id, w.added_date;

-- 16. Find product pairs frequently bought together in the same order.
-- The product_id condition avoids duplicate pair directions such as A-B and B-A.
SELECT
    oi1.product_id AS product_a_id,
    p1.product_name AS product_a_name,
    oi2.product_id AS product_b_id,
    p2.product_name AS product_b_name,
    COUNT(DISTINCT oi1.order_id) AS bought_together_count
FROM order_items AS oi1
JOIN order_items AS oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id
JOIN orders AS o ON oi1.order_id = o.order_id
JOIN payments AS pay ON o.order_id = pay.order_id
JOIN products AS p1 ON oi1.product_id = p1.product_id
JOIN products AS p2 ON oi2.product_id = p2.product_id
WHERE o.order_status = 'completed'
  AND pay.payment_status = 'paid'
GROUP BY oi1.product_id, p1.product_name, oi2.product_id, p2.product_name
HAVING COUNT(DISTINCT oi1.order_id) >= 2
ORDER BY bought_together_count DESC;

-- 17. Rank frequently bought together product pairs.
WITH product_pairs AS (
    SELECT
        oi1.product_id AS product_a_id,
        p1.product_name AS product_a_name,
        oi2.product_id AS product_b_id,
        p2.product_name AS product_b_name,
        COUNT(DISTINCT oi1.order_id) AS bought_together_count
    FROM order_items AS oi1
    JOIN order_items AS oi2
        ON oi1.order_id = oi2.order_id
       AND oi1.product_id < oi2.product_id
    JOIN orders AS o ON oi1.order_id = o.order_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN products AS p1 ON oi1.product_id = p1.product_id
    JOIN products AS p2 ON oi2.product_id = p2.product_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY oi1.product_id, p1.product_name, oi2.product_id, p2.product_name
)
SELECT
    RANK() OVER (ORDER BY bought_together_count DESC) AS pair_rank,
    product_a_name,
    product_b_name,
    bought_together_count
FROM product_pairs
ORDER BY pair_rank, product_a_name;

-- 18. Recommend products based on frequently bought together logic.
-- If a customer bought Product A but not Product B, recommend Product B.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
),
product_pairs AS (
    SELECT
        oi1.product_id AS product_a_id,
        oi2.product_id AS product_b_id,
        COUNT(DISTINCT oi1.order_id) AS bought_together_count
    FROM order_items AS oi1
    JOIN order_items AS oi2
        ON oi1.order_id = oi2.order_id
       AND oi1.product_id < oi2.product_id
    JOIN orders AS o ON oi1.order_id = o.order_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY oi1.product_id, oi2.product_id
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    pb.product_id AS recommended_product_id,
    pb.product_name AS recommended_product_name,
    pp.bought_together_count,
    'frequently_bought_together' AS recommendation_reason
FROM purchased_products AS bought_a
JOIN product_pairs AS pp
    ON bought_a.product_id = pp.product_a_id
JOIN customers AS c
    ON bought_a.customer_id = c.customer_id
JOIN products AS pb
    ON pp.product_b_id = pb.product_id
LEFT JOIN purchased_products AS already_bought_b
    ON bought_a.customer_id = already_bought_b.customer_id
   AND pp.product_b_id = already_bought_b.product_id
WHERE already_bought_b.product_id IS NULL
ORDER BY c.customer_id, pp.bought_together_count DESC;

-- 19. Recommend popular products a customer has not purchased yet.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
),
popular_products AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold,
        RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS popularity_rank
    FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY p.product_id, p.product_name
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    pp.product_id AS recommended_product_id,
    pp.product_name AS recommended_product_name,
    pp.popularity_rank,
    'popular_product' AS recommendation_reason
FROM customers AS c
CROSS JOIN popular_products AS pp
LEFT JOIN purchased_products AS bought
    ON c.customer_id = bought.customer_id
   AND pp.product_id = bought.product_id
WHERE bought.product_id IS NULL
  AND pp.popularity_rank <= 5
ORDER BY c.customer_id, pp.popularity_rank;

-- 20. Recommend products from a customer's preferred category that they have not purchased yet.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
),
preferred_category AS (
    SELECT customer_id, category
    FROM (
        SELECT
            o.customer_id,
            p.category,
            ROW_NUMBER() OVER (
                PARTITION BY o.customer_id
                ORDER BY SUM(oi.quantity) DESC
            ) AS category_rank
        FROM orders AS o
        JOIN payments AS pay ON o.order_id = pay.order_id
        JOIN order_items AS oi ON o.order_id = oi.order_id
        JOIN products AS p ON oi.product_id = p.product_id
        WHERE o.order_status = 'completed'
          AND pay.payment_status = 'paid'
        GROUP BY o.customer_id, p.category
    ) AS ranked_categories
    WHERE category_rank = 1
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id AS recommended_product_id,
    p.product_name AS recommended_product_name,
    p.category,
    'category_preference' AS recommendation_reason
FROM preferred_category AS pc
JOIN customers AS c ON pc.customer_id = c.customer_id
JOIN products AS p ON pc.category = p.category
LEFT JOIN purchased_products AS bought
    ON pc.customer_id = bought.customer_id
   AND p.product_id = bought.product_id
WHERE bought.product_id IS NULL
ORDER BY c.customer_id, p.unit_price DESC;

-- 21. Recommend wishlist products that have not been purchased yet.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id AS recommended_product_id,
    p.product_name AS recommended_product_name,
    'wishlist_based' AS recommendation_reason
FROM wishlists AS w
JOIN customers AS c ON w.customer_id = c.customer_id
JOIN products AS p ON w.product_id = p.product_id
LEFT JOIN purchased_products AS bought
    ON w.customer_id = bought.customer_id
   AND w.product_id = bought.product_id
WHERE bought.product_id IS NULL
ORDER BY c.customer_id, w.added_date;

-- 22. Recommend viewed-but-not-purchased products.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id AS recommended_product_id,
    p.product_name AS recommended_product_name,
    COUNT(pv.view_id) AS view_count,
    'viewed_not_purchased' AS recommendation_reason
FROM product_views AS pv
JOIN customers AS c ON pv.customer_id = c.customer_id
JOIN products AS p ON pv.product_id = p.product_id
LEFT JOIN purchased_products AS bought
    ON pv.customer_id = bought.customer_id
   AND pv.product_id = bought.product_id
WHERE bought.product_id IS NULL
GROUP BY c.customer_id, customer_name, p.product_id, p.product_name
ORDER BY c.customer_id, view_count DESC;

-- 23. Find similar customers based on shared purchased categories.
WITH customer_categories AS (
    SELECT DISTINCT
        o.customer_id,
        p.category
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
)
SELECT
    cc1.customer_id AS customer_id,
    cc2.customer_id AS similar_customer_id,
    COUNT(*) AS shared_category_count
FROM customer_categories AS cc1
JOIN customer_categories AS cc2
    ON cc1.category = cc2.category
   AND cc1.customer_id <> cc2.customer_id
GROUP BY cc1.customer_id, cc2.customer_id
HAVING COUNT(*) >= 1
ORDER BY customer_id, shared_category_count DESC;

-- 24. Recommend products bought by similar customers but not yet bought by the target customer.
WITH purchased_products AS (
    SELECT DISTINCT o.customer_id, oi.product_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
),
customer_categories AS (
    SELECT DISTINCT
        o.customer_id,
        p.category
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
),
similar_customers AS (
    SELECT
        cc1.customer_id,
        cc2.customer_id AS similar_customer_id,
        COUNT(*) AS shared_category_count
    FROM customer_categories AS cc1
    JOIN customer_categories AS cc2
        ON cc1.category = cc2.category
       AND cc1.customer_id <> cc2.customer_id
    GROUP BY cc1.customer_id, cc2.customer_id
)
SELECT
    sc.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_id AS recommended_product_id,
    p.product_name AS recommended_product_name,
    COUNT(DISTINCT sc.similar_customer_id) AS similar_customers_who_bought,
    'similar_customer_behavior' AS recommendation_reason
FROM similar_customers AS sc
JOIN purchased_products AS similar_bought
    ON sc.similar_customer_id = similar_bought.customer_id
JOIN products AS p
    ON similar_bought.product_id = p.product_id
JOIN customers AS c
    ON sc.customer_id = c.customer_id
LEFT JOIN purchased_products AS target_bought
    ON sc.customer_id = target_bought.customer_id
   AND similar_bought.product_id = target_bought.product_id
WHERE target_bought.product_id IS NULL
GROUP BY sc.customer_id, customer_name, p.product_id, p.product_name
ORDER BY sc.customer_id, similar_customers_who_bought DESC;

-- 25. Create a simple recommendation score using CASE WHEN.
WITH recommendation_pool AS (
    SELECT customer_id, recommended_product_id, recommendation_reason
    FROM product_recommendations
)
SELECT
    customer_id,
    recommended_product_id,
    recommendation_reason,
    CASE recommendation_reason
        WHEN 'frequently_bought_together' THEN 5
        WHEN 'wishlist_based' THEN 4
        WHEN 'category_preference' THEN 3
        WHEN 'similar_customer_behavior' THEN 3
        WHEN 'viewed_not_purchased' THEN 2
        WHEN 'popular_product' THEN 1
        ELSE 1
    END AS recommendation_score
FROM recommendation_pool
ORDER BY customer_id, recommendation_score DESC;

-- 26. Rank recommendations per customer using a window function.
SELECT
    pr.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    pr.recommended_product_id,
    p.product_name AS recommended_product_name,
    pr.recommendation_reason,
    pr.recommendation_score,
    ROW_NUMBER() OVER (
        PARTITION BY pr.customer_id
        ORDER BY pr.recommendation_score DESC, pr.recommended_product_id
    ) AS recommendation_rank
FROM product_recommendations AS pr
JOIN customers AS c ON pr.customer_id = c.customer_id
JOIN products AS p ON pr.recommended_product_id = p.product_id
ORDER BY pr.customer_id, recommendation_rank;

-- 27. Show top 3 recommendations per customer.
WITH ranked_recommendations AS (
    SELECT
        pr.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        pr.recommended_product_id,
        p.product_name AS recommended_product_name,
        pr.recommendation_reason,
        pr.recommendation_score,
        ROW_NUMBER() OVER (
            PARTITION BY pr.customer_id
            ORDER BY pr.recommendation_score DESC, pr.recommended_product_id
        ) AS recommendation_rank
    FROM product_recommendations AS pr
    JOIN customers AS c ON pr.customer_id = c.customer_id
    JOIN products AS p ON pr.recommended_product_id = p.product_id
)
SELECT *
FROM ranked_recommendations
WHERE recommendation_rank <= 3
ORDER BY customer_id, recommendation_rank;

-- 28. Find customers with no purchases but product views.
WITH purchasing_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(pv.view_id) AS view_count
FROM customers AS c
JOIN product_views AS pv ON c.customer_id = pv.customer_id
LEFT JOIN purchasing_customers AS pc
    ON c.customer_id = pc.customer_id
WHERE pc.customer_id IS NULL
GROUP BY c.customer_id, customer_name
ORDER BY view_count DESC;

-- 29. Recommend popular products to customers with no purchases.
WITH purchasing_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
),
popular_products AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold,
        RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS popularity_rank
    FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id
    JOIN payments AS pay ON o.order_id = pay.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY p.product_id, p.product_name
)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    pp.product_id AS recommended_product_id,
    pp.product_name AS recommended_product_name,
    'popular_product' AS recommendation_reason
FROM customers AS c
CROSS JOIN popular_products AS pp
LEFT JOIN purchasing_customers AS pc
    ON c.customer_id = pc.customer_id
WHERE pc.customer_id IS NULL
  AND pp.popularity_rank <= 3
ORDER BY c.customer_id, pp.popularity_rank;

-- 30. Calculate recommendation reasons summary.
SELECT
    recommendation_reason,
    COUNT(*) AS recommendation_count,
    ROUND(AVG(recommendation_score), 2) AS average_score
FROM product_recommendations
GROUP BY recommendation_reason
ORDER BY recommendation_count DESC, average_score DESC;

-- 31. Build a customer-product recommendation dashboard view.
SELECT
    pr.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    pr.recommended_product_id,
    p.product_name AS recommended_product_name,
    p.category,
    p.brand,
    p.unit_price,
    pr.recommendation_reason,
    pr.recommendation_score,
    ROW_NUMBER() OVER (
        PARTITION BY pr.customer_id
        ORDER BY pr.recommendation_score DESC, pr.recommended_product_id
    ) AS recommendation_rank
FROM product_recommendations AS pr
JOIN customers AS c
    ON pr.customer_id = c.customer_id
JOIN products AS p
    ON pr.recommended_product_id = p.product_id
ORDER BY pr.customer_id, recommendation_rank;

-- 32. Build an AI-ready customer-product feature table using SQL.
-- This is a learning artifact, not a real machine learning training dataset.
WITH purchase_features AS (
    SELECT
        o.customer_id,
        oi.product_id,
        SUM(oi.quantity) AS total_quantity_purchased,
        SUM((oi.quantity * oi.unit_price) - oi.discount_amount) AS total_spent_on_product
    FROM orders AS o
    JOIN payments AS pay ON o.order_id = pay.order_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND pay.payment_status = 'paid'
    GROUP BY o.customer_id, oi.product_id
),
view_features AS (
    SELECT
        customer_id,
        product_id,
        COUNT(*) AS view_count
    FROM product_views
    GROUP BY customer_id, product_id
),
wishlist_features AS (
    SELECT DISTINCT
        customer_id,
        product_id
    FROM wishlists
),
preferred_category AS (
    SELECT customer_id, category
    FROM (
        SELECT
            o.customer_id,
            p.category,
            ROW_NUMBER() OVER (
                PARTITION BY o.customer_id
                ORDER BY SUM(oi.quantity) DESC
            ) AS category_rank
        FROM orders AS o
        JOIN payments AS pay ON o.order_id = pay.order_id
        JOIN order_items AS oi ON o.order_id = oi.order_id
        JOIN products AS p ON oi.product_id = p.product_id
        WHERE o.order_status = 'completed'
          AND pay.payment_status = 'paid'
        GROUP BY o.customer_id, p.category
    ) AS ranked_categories
    WHERE category_rank = 1
),
product_popularity AS (
    SELECT
        p.product_id,
        RANK() OVER (
            ORDER BY COALESCE(
                SUM(oi.quantity) FILTER (
                    WHERE o.order_status = 'completed'
                      AND pay.payment_status = 'paid'
                ),
                0
            ) DESC
        ) AS product_popularity_rank
    FROM products AS p
    LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
    LEFT JOIN orders AS o ON oi.order_id = o.order_id
    LEFT JOIN payments AS pay ON o.order_id = pay.order_id
    GROUP BY p.product_id
)
SELECT
    c.customer_id,
    p.product_id,
    p.category AS product_category,
    p.unit_price AS product_price,
    CASE WHEN pf.product_id IS NOT NULL THEN 1 ELSE 0 END AS has_purchased,
    COALESCE(pf.total_quantity_purchased, 0) AS total_quantity_purchased,
    COALESCE(pf.total_spent_on_product, 0) AS total_spent_on_product,
    CASE WHEN vf.product_id IS NOT NULL THEN 1 ELSE 0 END AS has_viewed,
    COALESCE(vf.view_count, 0) AS view_count,
    CASE WHEN wf.product_id IS NOT NULL THEN 1 ELSE 0 END AS has_wishlisted,
    CASE WHEN pc.category = p.category THEN 1 ELSE 0 END AS same_as_preferred_category,
    pp.product_popularity_rank,
    CASE
        WHEN pf.product_id IS NOT NULL THEN 1
        WHEN wf.product_id IS NOT NULL THEN 1
        WHEN COALESCE(vf.view_count, 0) >= 2 THEN 1
        ELSE 0
    END AS recommended_label
FROM customers AS c
CROSS JOIN products AS p
LEFT JOIN purchase_features AS pf
    ON c.customer_id = pf.customer_id
   AND p.product_id = pf.product_id
LEFT JOIN view_features AS vf
    ON c.customer_id = vf.customer_id
   AND p.product_id = vf.product_id
LEFT JOIN wishlist_features AS wf
    ON c.customer_id = wf.customer_id
   AND p.product_id = wf.product_id
LEFT JOIN preferred_category AS pc
    ON c.customer_id = pc.customer_id
LEFT JOIN product_popularity AS pp
    ON p.product_id = pp.product_id
ORDER BY c.customer_id, p.product_id;

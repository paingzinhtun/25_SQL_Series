-- Day 7 - Inventory Management System
-- Business analysis queries for PostgreSQL

-- 1. List all products with supplier information.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    s.supplier_name,
    s.contact_person,
    s.city AS supplier_city,
    p.unit_cost,
    p.selling_price
FROM products AS p
JOIN suppliers AS s
    ON p.supplier_id = s.supplier_id
ORDER BY p.category, p.product_name;

-- 2. Show current stock by product and warehouse.
SELECT
    p.product_name,
    p.category,
    w.warehouse_name,
    w.city,
    i.current_stock,
    i.last_updated
FROM inventory AS i
JOIN products AS p
    ON i.product_id = p.product_id
JOIN warehouses AS w
    ON i.warehouse_id = w.warehouse_id
ORDER BY p.product_name, w.warehouse_name;

-- 3. Calculate total stock available per product across all warehouses.
SELECT
    p.product_name,
    p.category,
    SUM(i.current_stock) AS total_stock_available
FROM products AS p
LEFT JOIN inventory AS i
    ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_stock_available DESC, p.product_name;

-- 4. Calculate total inventory value using unit cost.
SELECT
    SUM(i.current_stock * p.unit_cost) AS total_inventory_value
FROM inventory AS i
JOIN products AS p
    ON i.product_id = p.product_id;

-- 5. Calculate potential sales value using selling price.
SELECT
    SUM(i.current_stock * p.selling_price) AS potential_sales_value
FROM inventory AS i
JOIN products AS p
    ON i.product_id = p.product_id;

-- 6. Find products below reorder point.
-- Reorder logic compares current_stock with reorder_point for each product and warehouse.
SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    rr.reorder_point
FROM reorder_rules AS rr
JOIN inventory AS i
    ON rr.product_id = i.product_id
   AND rr.warehouse_id = i.warehouse_id
JOIN products AS p
    ON rr.product_id = p.product_id
JOIN warehouses AS w
    ON rr.warehouse_id = w.warehouse_id
WHERE i.current_stock < rr.reorder_point
ORDER BY i.current_stock, p.product_name;

-- 7. Generate reorder recommendation with reorder quantity.
SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    rr.reorder_point,
    rr.reorder_quantity,
    rr.safety_stock,
    CASE
        WHEN i.current_stock <= rr.safety_stock THEN 'Urgent reorder'
        WHEN i.current_stock < rr.reorder_point THEN 'Reorder soon'
        ELSE 'Stock level ok'
    END AS reorder_recommendation
FROM reorder_rules AS rr
JOIN inventory AS i
    ON rr.product_id = i.product_id
   AND rr.warehouse_id = i.warehouse_id
JOIN products AS p
    ON rr.product_id = p.product_id
JOIN warehouses AS w
    ON rr.warehouse_id = w.warehouse_id
WHERE i.current_stock < rr.reorder_point
ORDER BY reorder_recommendation, i.current_stock;

-- 8. Find products at risk of stockout.
-- Stockout risk is defined as current_stock less than or equal to safety_stock.
SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    rr.safety_stock
FROM reorder_rules AS rr
JOIN inventory AS i
    ON rr.product_id = i.product_id
   AND rr.warehouse_id = i.warehouse_id
JOIN products AS p
    ON rr.product_id = p.product_id
JOIN warehouses AS w
    ON rr.warehouse_id = w.warehouse_id
WHERE i.current_stock <= rr.safety_stock
ORDER BY i.current_stock, p.product_name;

-- 9. Find overstocked products.
-- Simple overstock rule: current_stock is greater than twice the reorder quantity.
SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    rr.reorder_quantity,
    rr.reorder_quantity * 2 AS overstock_threshold
FROM reorder_rules AS rr
JOIN inventory AS i
    ON rr.product_id = i.product_id
   AND rr.warehouse_id = i.warehouse_id
JOIN products AS p
    ON rr.product_id = p.product_id
JOIN warehouses AS w
    ON rr.warehouse_id = w.warehouse_id
WHERE i.current_stock > rr.reorder_quantity * 2
ORDER BY i.current_stock DESC;

-- 10. Find products with zero stock.
SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock
FROM inventory AS i
JOIN products AS p
    ON i.product_id = p.product_id
JOIN warehouses AS w
    ON i.warehouse_id = w.warehouse_id
WHERE i.current_stock = 0
ORDER BY p.product_name, w.warehouse_name;

-- 11. Show stock movement history by product.
SELECT
    p.product_name,
    w.warehouse_name,
    sm.movement_date,
    sm.movement_type,
    sm.quantity,
    sm.reference_note
FROM stock_movements AS sm
JOIN products AS p
    ON sm.product_id = p.product_id
JOIN warehouses AS w
    ON sm.warehouse_id = w.warehouse_id
ORDER BY p.product_name, sm.movement_date, sm.movement_id;

-- 12. Calculate total stock in by product.
SELECT
    p.product_name,
    COALESCE(SUM(sm.quantity), 0) AS total_stock_in
FROM products AS p
LEFT JOIN stock_movements AS sm
    ON p.product_id = sm.product_id
   AND sm.movement_type = 'stock_in'
GROUP BY p.product_id, p.product_name
ORDER BY total_stock_in DESC, p.product_name;

-- 13. Calculate total stock out by product.
SELECT
    p.product_name,
    COALESCE(SUM(sm.quantity), 0) AS total_stock_out
FROM products AS p
LEFT JOIN stock_movements AS sm
    ON p.product_id = sm.product_id
   AND sm.movement_type = 'stock_out'
GROUP BY p.product_id, p.product_name
ORDER BY total_stock_out DESC, p.product_name;

-- 14. Find fast-moving products based on stock_out quantity.
-- Fast-moving products are products with high total stock_out quantity.
WITH stock_out_totals AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(sm.quantity) AS total_stock_out
    FROM products AS p
    JOIN stock_movements AS sm
        ON p.product_id = sm.product_id
    WHERE sm.movement_type = 'stock_out'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    total_stock_out,
    RANK() OVER (
        ORDER BY total_stock_out DESC
    ) AS movement_rank
FROM stock_out_totals
ORDER BY movement_rank, product_name
LIMIT 5;

-- 15. Find slow-moving products based on low recent stock_out activity.
-- Recent period: April 2026. Low movement means total stock_out is less than 20.
WITH recent_stock_out AS (
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(sm.quantity), 0) AS april_stock_out
    FROM products AS p
    LEFT JOIN stock_movements AS sm
        ON p.product_id = sm.product_id
       AND sm.movement_type = 'stock_out'
       AND sm.movement_date >= '2026-04-01'
       AND sm.movement_date < '2026-05-01'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    april_stock_out
FROM recent_stock_out
WHERE april_stock_out < 20
ORDER BY april_stock_out, product_name;

-- 16. Rank warehouses by total inventory value.
WITH warehouse_inventory_value AS (
    SELECT
        w.warehouse_id,
        w.warehouse_name,
        w.city,
        SUM(i.current_stock * p.unit_cost) AS inventory_value
    FROM warehouses AS w
    LEFT JOIN inventory AS i
        ON w.warehouse_id = i.warehouse_id
    LEFT JOIN products AS p
        ON i.product_id = p.product_id
    GROUP BY w.warehouse_id, w.warehouse_name, w.city
)
SELECT
    warehouse_name,
    city,
    inventory_value,
    RANK() OVER (
        ORDER BY inventory_value DESC
    ) AS inventory_value_rank
FROM warehouse_inventory_value
ORDER BY inventory_value_rank, warehouse_name;

-- 17. Count products by category.
SELECT
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC, category;

-- 18. Find suppliers with the most products.
SELECT
    s.supplier_name,
    s.city,
    COUNT(p.product_id) AS product_count
FROM suppliers AS s
LEFT JOIN products AS p
    ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name, s.city
HAVING COUNT(p.product_id) > 0
ORDER BY product_count DESC, s.supplier_name;

-- 19. Show products where selling price is lower than or equal to unit cost.
-- These products may have pricing problems because they do not show a positive gross margin.
SELECT
    product_name,
    category,
    unit_cost,
    selling_price,
    selling_price - unit_cost AS unit_margin
FROM products
WHERE selling_price <= unit_cost
ORDER BY unit_margin, product_name;

-- 20. Create an inventory health summary using CASE WHEN.
-- The logic is checked per product and warehouse.
SELECT
    p.product_name,
    w.warehouse_name,
    i.current_stock,
    COALESCE(rr.reorder_point::text, 'No rule') AS reorder_point,
    COALESCE(rr.safety_stock::text, 'No rule') AS safety_stock,
    COALESCE(rr.reorder_quantity::text, 'No rule') AS reorder_quantity,
    CASE
        WHEN rr.rule_id IS NULL THEN 'No reorder rule'
        WHEN i.current_stock = 0 THEN 'Stockout'
        WHEN i.current_stock <= rr.safety_stock THEN 'Stockout risk'
        WHEN i.current_stock < rr.reorder_point THEN 'Below reorder point'
        WHEN i.current_stock > rr.reorder_quantity * 2 THEN 'Overstocked'
        ELSE 'Healthy'
    END AS inventory_health_status
FROM inventory AS i
JOIN products AS p
    ON i.product_id = p.product_id
JOIN warehouses AS w
    ON i.warehouse_id = w.warehouse_id
LEFT JOIN reorder_rules AS rr
    ON i.product_id = rr.product_id
   AND i.warehouse_id = rr.warehouse_id
ORDER BY inventory_health_status, p.product_name, w.warehouse_name;

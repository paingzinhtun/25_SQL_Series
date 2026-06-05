-- Day 25: End-to-End Data Pipeline
-- fact_loads.sql: Load Gold Fact Table

-- Fact Grain: One row per product sold per order
-- To load the fact table, we join the staging transactions to the dimension tables to retrieve the Surrogate Keys (_sk).

INSERT INTO fact_sales (
    order_item_id, 
    order_id, 
    customer_sk, 
    product_sk, 
    store_sk, 
    date_sk, 
    quantity, 
    unit_price, 
    discount_amount, 
    gross_sales_amount, 
    net_sales_amount
)
SELECT 
    i.order_item_id,
    i.order_id,
    c.customer_sk,
    p.product_sk,
    s.store_sk,
    d.date_sk,
    i.quantity,
    i.unit_price,
    i.discount,
    (i.quantity * i.unit_price) AS gross_sales_amount,
    ((i.quantity * i.unit_price) - i.discount) AS net_sales_amount
FROM stg_order_items i
JOIN stg_orders o ON i.order_id = o.order_id
-- Join Dimensions to get SKs
JOIN dim_customer c ON o.customer_id = c.customer_id
JOIN dim_product p ON i.product_id = p.product_id
-- Use LEFT JOIN for stores since online orders might not have a store_id
LEFT JOIN dim_store s ON o.store_id = s.store_id
JOIN dim_date d ON o.order_date = d.full_date
-- Ensure we don't load cancelled/returned orders into the primary sales fact if we only want completed sales.
-- For a comprehensive fact, we load all and filter in analytics, but here we filter 'COMPLETED' for simplicity.
WHERE o.status = 'COMPLETED'
-- Prevent duplicate loads if pipeline runs twice
AND NOT EXISTS (
    SELECT 1 FROM fact_sales f WHERE f.order_item_id = i.order_item_id
);
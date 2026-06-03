-- Day 23: Slowly Changing Dimensions (SCD Type 1 & Type 2)
-- scd_type1_etl.sql
-- Simulates the ETL process for an SCD Type 1 Dimension

/*
=============================================================================
SCD Type 1 Explanation:
Type 1 methodology OVERWRITES existing data with new data. 
It does not track history.
Benefits: Easy to maintain, requires less storage space.
Disadvantages: Complete loss of historical context. If a customer moves from
Bago to Yangon, all previous sales are now attributed to Yangon in reports.
=============================================================================
*/

-- Step 1: Create a staging table to represent incoming new/updated data from source systems
DROP TABLE IF EXISTS stg_customer_updates;
CREATE TABLE stg_customer_updates (
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100),
    customer_segment VARCHAR(50),
    email VARCHAR(100)
);

-- Insert simulated updates (some existing customers, some new)
INSERT INTO stg_customer_updates VALUES
('C003', 'Kyaw Zin', 'Mandalay', 'Mandalay Region', 'Regular', 'kyaw.z@example.com'), -- Changed city
('C005', 'Zayar Lin', 'Taunggyi', 'Shan State', 'VIP', 'zayar.l@example.com'), -- Upgraded segment
('C031', 'Thura Aung', 'Yangon', 'Yangon Region', 'Regular', 'thura.a@example.com'); -- NEW Customer

-- Step 2: Perform Upsert (Update existing, Insert new) using PostgreSQL ON CONFLICT

-- In PostgreSQL, to use ON CONFLICT, we need a unique constraint on the business key.
-- Our schema.sql already defined: customer_id VARCHAR(50) NOT NULL UNIQUE

INSERT INTO dim_customer_scd1 (customer_id, customer_name, city, region, customer_segment, email, updated_at)
SELECT 
    customer_id, 
    customer_name, 
    city, 
    region, 
    customer_segment, 
    email,
    CURRENT_TIMESTAMP
FROM stg_customer_updates
ON CONFLICT (customer_id) 
DO UPDATE SET 
    customer_name = EXCLUDED.customer_name,
    city = EXCLUDED.city,
    region = EXCLUDED.region,
    customer_segment = EXCLUDED.customer_segment,
    email = EXCLUDED.email,
    updated_at = CURRENT_TIMESTAMP
-- Only update if something actually changed to save I/O
WHERE 
    dim_customer_scd1.customer_name IS DISTINCT FROM EXCLUDED.customer_name OR
    dim_customer_scd1.city IS DISTINCT FROM EXCLUDED.city OR
    dim_customer_scd1.region IS DISTINCT FROM EXCLUDED.region OR
    dim_customer_scd1.customer_segment IS DISTINCT FROM EXCLUDED.customer_segment OR
    dim_customer_scd1.email IS DISTINCT FROM EXCLUDED.email;

-- Note: In older SQL dialects or standard SQL, this is often done with a MERGE statement
-- or separate UPDATE and INSERT statements.
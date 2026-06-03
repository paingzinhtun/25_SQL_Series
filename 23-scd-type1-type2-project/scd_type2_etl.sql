-- Day 23: Slowly Changing Dimensions (SCD Type 1 & Type 2)
-- scd_type2_etl.sql
-- Simulates the ETL process for an SCD Type 2 Dimension

/*
=============================================================================
SCD Type 2 Explanation:
Type 2 methodology PRESERVES historical data by adding a new row for each change.
Benefits: Perfect historical accuracy. Sales are attributed to the exact state
of the dimension at the time the sale occurred.
Disadvantages: More complex ETL, requires more storage, requires surrogate keys.
=============================================================================
*/

-- Step 1: Create a staging table for incoming employee updates
DROP TABLE IF EXISTS stg_employee_updates;
CREATE TABLE stg_employee_updates (
    employee_id VARCHAR(50),
    employee_name VARCHAR(100),
    department VARCHAR(100),
    role VARCHAR(100),
    city VARCHAR(100),
    salary_band VARCHAR(50),
    update_date DATE
);

-- Insert simulated updates
INSERT INTO stg_employee_updates VALUES
('E003', 'Ko Ko', 'Logistics', 'Senior Driver', 'Yangon', 'Band B', '2024-01-01'), -- Changed role and salary band
('E004', 'Ma Ma', 'Management', 'HR Director', 'Naypyidaw', 'Band D', '2024-01-01'), -- Changed department, role, band
('E016', 'Chaw Chaw', 'Sales', 'Sales Associate', 'Yangon', 'Band A', '2024-01-01'); -- NEW Employee

-- Step 2: The SCD Type 2 ETL Process

-- Part A: Handle Existing Records that Changed (Expire old, prepare new)
-- 1. Identify which existing records have changes
-- 2. Update the old record: set effective_end_date and is_current = FALSE
-- 3. Insert the new record with incremented version_number

DO $$
DECLARE
    rec RECORD;
    v_current_version INT;
BEGIN
    FOR rec IN SELECT * FROM stg_employee_updates LOOP
        
        -- Check if employee exists and is currently active
        IF EXISTS (SELECT 1 FROM dim_employee_scd2 WHERE employee_id = rec.employee_id AND is_current = TRUE) THEN
            
            -- Check if any monitored attributes actually changed
            IF EXISTS (
                SELECT 1 FROM dim_employee_scd2 
                WHERE employee_id = rec.employee_id 
                  AND is_current = TRUE
                  AND (
                      department IS DISTINCT FROM rec.department OR
                      role IS DISTINCT FROM rec.role OR
                      city IS DISTINCT FROM rec.city OR
                      salary_band IS DISTINCT FROM rec.salary_band
                  )
            ) THEN
                
                -- Get the current version number
                SELECT version_number INTO v_current_version
                FROM dim_employee_scd2 
                WHERE employee_id = rec.employee_id AND is_current = TRUE;
                
                -- Expire the current record (set end date to one day before update)
                UPDATE dim_employee_scd2
                SET effective_end_date = rec.update_date - INTERVAL '1 day',
                    is_current = FALSE
                WHERE employee_id = rec.employee_id AND is_current = TRUE;
                
                -- Insert the new version
                INSERT INTO dim_employee_scd2 (
                    employee_id, employee_name, department, role, city, salary_band, 
                    effective_start_date, effective_end_date, is_current, version_number
                ) VALUES (
                    rec.employee_id, rec.employee_name, rec.department, rec.role, rec.city, rec.salary_band,
                    rec.update_date, NULL, TRUE, v_current_version + 1
                );
                
            END IF;
            
        ELSE
            -- Part B: Handle Completely New Records
            INSERT INTO dim_employee_scd2 (
                employee_id, employee_name, department, role, city, salary_band, 
                effective_start_date, effective_end_date, is_current, version_number
            ) VALUES (
                rec.employee_id, rec.employee_name, rec.department, rec.role, rec.city, rec.salary_band,
                rec.update_date, NULL, TRUE, 1
            );
        END IF;
        
    END LOOP;
END $$;
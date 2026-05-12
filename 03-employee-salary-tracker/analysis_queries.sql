-- Day 3 - Employee Salary Tracker
-- Business analysis queries for PostgreSQL

-- 1. List all employees with department and job role.
-- The employees table stores department_id and role_id, but joins show readable names.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    jr.role_name,
    e.city,
    e.hire_date,
    e.employment_status
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.department_id
JOIN job_roles AS jr
    ON e.role_id = jr.role_id
ORDER BY d.department_name, employee_name;

-- 2. Show all active employees.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    jr.role_name,
    e.hire_date
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.department_id
JOIN job_roles AS jr
    ON e.role_id = jr.role_id
WHERE e.employment_status = 'active'
ORDER BY e.hire_date;

-- 3. Show employees by employment status.
-- This helps HR quickly see active, resigned, and probation employee counts.
SELECT
    employment_status,
    COUNT(*) AS employee_count
FROM employees
GROUP BY employment_status
ORDER BY employee_count DESC, employment_status;

-- 4. Count employees per department.
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC, d.department_name;

-- 5. Calculate total monthly salary cost by department.
-- LEFT JOIN keeps departments in the result even if a department has missing salary data.
SELECT
    d.department_name,
    COALESCE(SUM(s.monthly_salary), 0) AS total_monthly_salary_cost
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
LEFT JOIN salaries AS s
    ON e.employee_id = s.employee_id
GROUP BY d.department_id, d.department_name
ORDER BY total_monthly_salary_cost DESC;

-- 6. Calculate average salary by department.
-- AVG ignores NULL values, so employees without salary records are not included in the average.
SELECT
    d.department_name,
    ROUND(AVG(s.monthly_salary), 2) AS average_monthly_salary
FROM departments AS d
LEFT JOIN employees AS e
    ON d.department_id = e.department_id
LEFT JOIN salaries AS s
    ON e.employee_id = s.employee_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(s.salary_id) > 0
ORDER BY average_monthly_salary DESC;

-- 7. Find the top 5 highest-paid employees.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    jr.role_name,
    s.monthly_salary
FROM salaries AS s
JOIN employees AS e
    ON s.employee_id = e.employee_id
JOIN departments AS d
    ON e.department_id = d.department_id
JOIN job_roles AS jr
    ON e.role_id = jr.role_id
ORDER BY s.monthly_salary DESC
LIMIT 5;

-- 8. Find employees without current salary records.
-- After a LEFT JOIN, missing salary records appear as NULL.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    jr.role_name,
    e.employment_status
FROM employees AS e
LEFT JOIN salaries AS s
    ON e.employee_id = s.employee_id
JOIN departments AS d
    ON e.department_id = d.department_id
JOIN job_roles AS jr
    ON e.role_id = jr.role_id
WHERE s.salary_id IS NULL
ORDER BY employee_name;

-- 9. Show salary history for each employee.
-- CURRENT_DATE - change_date shows how many days have passed since the salary change.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    sh.old_salary,
    sh.new_salary,
    sh.change_date,
    CURRENT_DATE - sh.change_date AS days_since_change,
    sh.change_reason
FROM salary_history AS sh
JOIN employees AS e
    ON sh.employee_id = e.employee_id
ORDER BY sh.change_date DESC, employee_name;

-- 10. Find employees who received salary increases.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    sh.old_salary,
    sh.new_salary,
    sh.change_date,
    sh.change_reason
FROM salary_history AS sh
JOIN employees AS e
    ON sh.employee_id = e.employee_id
WHERE sh.new_salary > sh.old_salary
ORDER BY sh.change_date DESC, employee_name;

-- 11. Calculate salary increase amount and percentage.
-- NULLIF prevents division by zero if an old salary is ever recorded as 0.
-- This query only includes increases, so decreases are excluded from the increase report.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    sh.old_salary,
    sh.new_salary,
    sh.new_salary - sh.old_salary AS salary_change_amount,
    ROUND(
        ((sh.new_salary - sh.old_salary) / NULLIF(sh.old_salary, 0)) * 100,
        2
    ) AS salary_change_percentage
FROM salary_history AS sh
JOIN employees AS e
    ON sh.employee_id = e.employee_id
WHERE sh.new_salary > sh.old_salary
ORDER BY salary_change_percentage DESC NULLS LAST, employee_name;

-- 12. Rank departments by payroll cost.
-- A CTE calculates payroll first, then a window function ranks departments.
WITH department_payroll AS (
    SELECT
        d.department_id,
        d.department_name,
        COALESCE(SUM(s.monthly_salary), 0) AS total_monthly_payroll
    FROM departments AS d
    LEFT JOIN employees AS e
        ON d.department_id = e.department_id
    LEFT JOIN salaries AS s
        ON e.employee_id = s.employee_id
    GROUP BY d.department_id, d.department_name
)
SELECT
    department_name,
    total_monthly_payroll,
    RANK() OVER (
        ORDER BY total_monthly_payroll DESC
    ) AS payroll_rank
FROM department_payroll
ORDER BY payroll_rank, department_name;

-- 13. Find job roles with the highest average salary.
SELECT
    jr.role_name,
    d.department_name,
    COUNT(s.salary_id) AS salary_record_count,
    ROUND(AVG(s.monthly_salary), 2) AS average_monthly_salary
FROM job_roles AS jr
JOIN departments AS d
    ON jr.department_id = d.department_id
LEFT JOIN employees AS e
    ON jr.role_id = e.role_id
LEFT JOIN salaries AS s
    ON e.employee_id = s.employee_id
GROUP BY jr.role_id, jr.role_name, d.department_name
HAVING COUNT(s.salary_id) > 0
ORDER BY average_monthly_salary DESC;

-- 14. Group employees into salary bands using CASE WHEN.
-- CASE WHEN turns numeric salary values into business-friendly groups.
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    s.monthly_salary,
    CASE
        WHEN s.monthly_salary IS NULL THEN 'No salary record'
        WHEN s.monthly_salary < 800000 THEN 'Entry band'
        WHEN s.monthly_salary < 1200000 THEN 'Mid band'
        WHEN s.monthly_salary < 1700000 THEN 'Senior band'
        ELSE 'Leadership band'
    END AS salary_band
FROM employees AS e
LEFT JOIN salaries AS s
    ON e.employee_id = s.employee_id
JOIN departments AS d
    ON e.department_id = d.department_id
ORDER BY s.monthly_salary DESC NULLS LAST, employee_name;

-- 15. Show company payroll summary: total employees, total monthly payroll, average salary.
SELECT
    COUNT(e.employee_id) AS total_employees,
    COUNT(s.salary_id) AS employees_with_salary_records,
    COUNT(e.employee_id) - COUNT(s.salary_id) AS employees_without_salary_records,
    COALESCE(SUM(s.monthly_salary), 0) AS total_monthly_payroll,
    ROUND(AVG(s.monthly_salary), 2) AS average_monthly_salary
FROM employees AS e
LEFT JOIN salaries AS s
    ON e.employee_id = s.employee_id;

-- Day 3 - Employee Salary Tracker
-- PostgreSQL schema

-- Drop child tables first because they depend on parent tables through foreign keys.
DROP TABLE IF EXISTS salary_history;
DROP TABLE IF EXISTS salaries;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS job_roles;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE job_roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    department_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_job_roles_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id),

    CONSTRAINT uq_job_roles_role_department
        UNIQUE (role_name, department_id)
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(30) UNIQUE,
    gender VARCHAR(20),
    city VARCHAR(60) NOT NULL,
    department_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    hire_date DATE NOT NULL,
    employment_status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id),

    CONSTRAINT fk_employees_role
        FOREIGN KEY (role_id)
        REFERENCES job_roles (role_id),

    CONSTRAINT chk_employees_gender
        CHECK (gender IN ('male', 'female', 'other') OR gender IS NULL),

    CONSTRAINT chk_employees_status
        CHECK (employment_status IN ('active', 'resigned', 'probation'))
);

-- The salaries table stores the current salary for each employee.
-- UNIQUE (employee_id) keeps this beginner project to one current salary row per employee.
CREATE TABLE salaries (
    salary_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL UNIQUE,
    monthly_salary NUMERIC(12, 2) NOT NULL,
    effective_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_salaries_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id),

    CONSTRAINT chk_salaries_monthly_salary
        CHECK (monthly_salary >= 0)
);

-- The salary_history table stores salary changes over time.
-- It is separate from salaries so learners can compare current salary and past changes.
CREATE TABLE salary_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    old_salary NUMERIC(12, 2) NOT NULL,
    new_salary NUMERIC(12, 2) NOT NULL,
    change_date DATE NOT NULL,
    change_reason VARCHAR(150) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_salary_history_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id),

    CONSTRAINT chk_salary_history_old_salary
        CHECK (old_salary >= 0),

    CONSTRAINT chk_salary_history_new_salary
        CHECK (new_salary >= 0)
);

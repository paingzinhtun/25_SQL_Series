-- Day 3 - Employee Salary Tracker
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Employees are spread across multiple departments.
-- - Employment statuses include active, resigned, and probation.
-- - Thura Aung and Myo Thant have no current salary records.
-- - Several employees have salary history records.
-- - Salary amounts vary enough for payroll rankings and salary bands.

INSERT INTO departments (
    department_name,
    location
) VALUES
    ('Engineering', 'Yangon Office'),
    ('Sales', 'Mandalay Office'),
    ('Finance', 'Yangon Office'),
    ('Human Resources', 'Yangon Office'),
    ('Operations', 'Naypyidaw Office');

INSERT INTO job_roles (
    role_name,
    department_id
) VALUES
    ('Data Engineer', 1),
    ('Backend Developer', 1),
    ('QA Analyst', 1),
    ('Sales Executive', 2),
    ('Sales Manager', 2),
    ('Accountant', 3),
    ('HR Officer', 4),
    ('Operations Coordinator', 5),
    ('Operations Manager', 5),
    ('Finance Manager', 3);

INSERT INTO employees (
    first_name,
    last_name,
    email,
    phone_number,
    gender,
    city,
    department_id,
    role_id,
    hire_date,
    employment_status
) VALUES
    ('Aung', 'Min', 'aung.min.hr@example.com', '09-440001001', 'male', 'Yangon', 1, 1, '2022-03-10', 'active'),
    ('Su', 'Mon', 'su.mon.hr@example.com', '09-440001002', 'female', 'Mandalay', 2, 4, '2023-01-15', 'active'),
    ('Thandar', 'Hlaing', 'thandar.hlaing.hr@example.com', '09-440001003', 'female', 'Yangon', 3, 6, '2021-07-01', 'active'),
    ('Kyaw', 'Zin', 'kyaw.zin.hr@example.com', '09-440001004', 'male', 'Yangon', 1, 2, '2022-09-20', 'active'),
    ('May', 'Thu', 'may.thu.hr@example.com', '09-440001005', 'female', 'Bago', 4, 7, '2024-02-05', 'probation'),
    ('Htet', 'Aung', 'htet.aung.hr@example.com', '09-440001006', 'male', 'Taunggyi', 5, 8, '2023-04-12', 'active'),
    ('Nilar', 'Win', 'nilar.win.hr@example.com', '09-440001007', 'female', 'Mawlamyine', 2, 5, '2020-11-18', 'active'),
    ('Min', 'Khant', 'min.khant.hr@example.com', '09-440001008', 'male', 'Mandalay', 1, 3, '2023-06-01', 'active'),
    ('Ei', 'Phyo', 'ei.phyo.hr@example.com', '09-440001009', 'female', 'Yangon', 3, 10, '2019-08-22', 'active'),
    ('Ye', 'Naing', 'ye.naing.hr@example.com', '09-440001010', 'male', 'Pathein', 5, 9, '2021-12-01', 'active'),
    ('Wai', 'Yan', 'wai.yan.hr@example.com', '09-440001011', 'male', 'Yangon', 1, 2, '2024-01-10', 'probation'),
    ('Khin', 'Sandi', 'khin.sandi.hr@example.com', '09-440001012', 'female', 'Naypyidaw', 4, 7, '2022-05-16', 'active'),
    ('Myo', 'Thant', 'myo.thant.hr@example.com', '09-440001013', 'male', 'Mandalay', 2, 4, '2020-03-03', 'resigned'),
    ('Hnin', 'Yu', 'hnin.yu.hr@example.com', '09-440001014', 'female', 'Yangon', 3, 6, '2024-03-01', 'probation'),
    ('Thura', 'Aung', 'thura.aung.hr@example.com', '09-440001015', 'male', 'Bago', 5, 8, '2024-04-01', 'active'),
    ('Yamin', 'Oo', 'yamin.oo.hr@example.com', '09-440001016', 'female', 'Yangon', 1, 1, '2021-01-11', 'active');

INSERT INTO salaries (
    employee_id,
    monthly_salary,
    effective_date
) VALUES
    (1, 1800000.00, '2025-01-01'),
    (2, 950000.00, '2025-01-01'),
    (3, 1200000.00, '2025-01-01'),
    (4, 1600000.00, '2025-01-01'),
    (5, 650000.00, '2026-02-05'),
    (6, 850000.00, '2025-01-01'),
    (7, 1450000.00, '2025-01-01'),
    (8, 900000.00, '2025-01-01'),
    (9, 1750000.00, '2025-01-01'),
    (10, 1500000.00, '2025-01-01'),
    (11, 700000.00, '2026-01-10'),
    (12, 900000.00, '2025-01-01'),
    (14, 750000.00, '2026-03-01'),
    (16, 2100000.00, '2025-01-01');

INSERT INTO salary_history (
    employee_id,
    old_salary,
    new_salary,
    change_date,
    change_reason
) VALUES
    (1, 1500000.00, 1800000.00, '2025-01-01', 'Annual performance increase'),
    (4, 1400000.00, 1600000.00, '2025-01-01', 'Promotion adjustment'),
    (7, 1300000.00, 1450000.00, '2025-01-01', 'Sales target achievement'),
    (9, 1600000.00, 1750000.00, '2025-01-01', 'Finance leadership adjustment'),
    (10, 1350000.00, 1500000.00, '2025-01-01', 'Operations leadership adjustment'),
    (12, 820000.00, 900000.00, '2025-01-01', 'Annual performance increase'),
    (13, 850000.00, 800000.00, '2024-12-01', 'Role transition before resignation'),
    (16, 1850000.00, 2100000.00, '2025-01-01', 'Senior data role adjustment'),
    (3, 1100000.00, 1200000.00, '2025-01-01', 'Annual salary review');

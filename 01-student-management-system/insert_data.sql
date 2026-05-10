-- Day 1 - Student Management System
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Wai Yan has no enrollment.
-- - Business English for IT has no enrolled students.
-- - Several students are enrolled in more than one course.
-- - Enrollment statuses include active, completed, and dropped.

INSERT INTO students (
    first_name,
    last_name,
    email,
    phone_number,
    date_of_birth,
    gender,
    city
) VALUES
    ('Aung', 'Min', 'aung.min@example.com', '09-420001001', '2001-03-12', 'male', 'Yangon'),
    ('Su', 'Mon', 'su.mon@example.com', '09-420001002', '2002-07-22', 'female', 'Mandalay'),
    ('Thandar', 'Hlaing', 'thandar.hlaing@example.com', '09-420001003', '2000-11-05', 'female', 'Naypyidaw'),
    ('Kyaw', 'Zin', 'kyaw.zin@example.com', '09-420001004', '1999-01-18', 'male', 'Yangon'),
    ('May', 'Thu', 'may.thu@example.com', '09-420001005', '2003-05-30', 'female', 'Bago'),
    ('Htet', 'Aung', 'htet.aung@example.com', '09-420001006', '2001-09-14', 'male', 'Taunggyi'),
    ('Nilar', 'Win', 'nilar.win@example.com', '09-420001007', '2002-02-25', 'female', 'Mawlamyine'),
    ('Min', 'Khant', 'min.khant@example.com', '09-420001008', '1998-12-09', 'male', 'Mandalay'),
    ('Ei', 'Phyo', 'ei.phyo@example.com', '09-420001009', '2000-04-16', 'female', 'Yangon'),
    ('Ye', 'Naing', 'ye.naing@example.com', '09-420001010', '2001-08-03', 'male', 'Pathein'),
    ('Wai', 'Yan', 'wai.yan@example.com', '09-420001011', '2003-10-27', 'male', 'Yangon');

INSERT INTO instructors (
    first_name,
    last_name,
    email,
    expertise
) VALUES
    ('Daw Khin', 'Mar', 'khin.mar@example.com', 'Database Systems'),
    ('U Zaw', 'Linn', 'zaw.linn@example.com', 'Web Development'),
    ('Daw Mya', 'Sandi', 'mya.sandi@example.com', 'Business Analytics'),
    ('U Thet', 'Paing', 'thet.paing@example.com', 'Cloud Computing');

INSERT INTO courses (
    course_name,
    category,
    instructor_id,
    course_fee,
    start_date,
    end_date
) VALUES
    ('SQL Fundamentals', 'Data', 1, 120000.00, '2026-06-01', '2026-06-30'),
    ('Python for Beginners', 'Programming', 2, 150000.00, '2026-06-05', '2026-07-05'),
    ('Data Analytics with Excel', 'Data', 3, 100000.00, '2026-06-10', '2026-07-10'),
    ('Web Development Basics', 'Programming', 2, 180000.00, '2026-07-01', '2026-08-15'),
    ('Cloud Foundations', 'Cloud', 4, 200000.00, '2026-07-10', '2026-08-20'),
    ('Business English for IT', 'Communication', 3, 90000.00, '2026-08-01', '2026-08-31');

INSERT INTO enrollments (
    student_id,
    course_id,
    enrollment_date,
    status
) VALUES
    (1, 1, '2026-05-20', 'active'),
    (1, 2, '2026-05-21', 'active'),
    (2, 1, '2026-05-20', 'active'),
    (2, 3, '2026-05-25', 'completed'),
    (3, 1, '2026-05-22', 'active'),
    (3, 4, '2026-06-02', 'active'),
    (4, 2, '2026-05-23', 'dropped'),
    (5, 3, '2026-05-26', 'active'),
    (5, 4, '2026-06-03', 'active'),
    (6, 1, '2026-05-24', 'completed'),
    (6, 5, '2026-06-15', 'active'),
    (7, 3, '2026-05-27', 'active'),
    (8, 4, '2026-06-04', 'active'),
    (8, 5, '2026-06-16', 'active'),
    (9, 2, '2026-05-28', 'completed'),
    (10, 1, '2026-05-29', 'active');

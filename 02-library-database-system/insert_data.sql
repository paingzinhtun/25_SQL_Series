-- Day 2 - Library Database System
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Some borrow records are returned.
-- - Some borrow records are currently borrowed.
-- - Some borrow records are overdue.
-- - Wai Yan has no borrow record.
-- - Public Speaking Practice has never been borrowed.

INSERT INTO authors (
    author_name,
    country
) VALUES
    ('Nay Lin Aung', 'Myanmar'),
    ('Hnin Wut Yee', 'Myanmar'),
    ('Mya Thida', 'Myanmar'),
    ('Ko Ko Naing', 'Myanmar'),
    ('Emily Carter', 'United Kingdom'),
    ('David Chen', 'Singapore');

INSERT INTO books (
    title,
    author_id,
    category,
    published_year,
    total_copies,
    available_copies
) VALUES
    ('SQL Basics for Libraries', 1, 'Data', 2021, 3, 1),
    ('Practical Python', 2, 'Programming', 2020, 4, 2),
    ('Data Analysis with Spreadsheets', 3, 'Data', 2019, 2, 2),
    ('Myanmar History Notes', 4, 'History', 2018, 2, 1),
    ('Business Communication', 5, 'Business', 2022, 3, 2),
    ('Introduction to Cloud', 6, 'Technology', 2023, 2, 1),
    ('English Grammar Essentials', 5, 'Language', 2021, 5, 5),
    ('AI Concepts for Beginners', 6, 'Technology', 2024, 1, 0),
    ('Financial Literacy Basics', 3, 'Business', 2017, 2, 2),
    ('Web Design Starter', 2, 'Programming', 2020, 3, 3),
    ('Children Stories of Myanmar', 4, 'Literature', 2016, 4, 3),
    ('Public Speaking Practice', 5, 'Communication', 2022, 1, 1);

INSERT INTO members (
    first_name,
    last_name,
    email,
    phone_number,
    city,
    membership_date
) VALUES
    ('Aung', 'Min', 'aung.min.library@example.com', '09-430001001', 'Yangon', '2025-11-10'),
    ('Su', 'Mon', 'su.mon.library@example.com', '09-430001002', 'Mandalay', '2025-12-05'),
    ('Thandar', 'Hlaing', 'thandar.hlaing.library@example.com', '09-430001003', 'Naypyidaw', '2026-01-08'),
    ('Kyaw', 'Zin', 'kyaw.zin.library@example.com', '09-430001004', 'Yangon', '2026-01-15'),
    ('May', 'Thu', 'may.thu.library@example.com', '09-430001005', 'Bago', '2026-02-01'),
    ('Htet', 'Aung', 'htet.aung.library@example.com', '09-430001006', 'Taunggyi', '2026-02-12'),
    ('Nilar', 'Win', 'nilar.win.library@example.com', '09-430001007', 'Mawlamyine', '2026-02-20'),
    ('Min', 'Khant', 'min.khant.library@example.com', '09-430001008', 'Mandalay', '2026-03-02'),
    ('Ei', 'Phyo', 'ei.phyo.library@example.com', '09-430001009', 'Yangon', '2026-03-18'),
    ('Ye', 'Naing', 'ye.naing.library@example.com', '09-430001010', 'Pathein', '2026-04-01'),
    ('Wai', 'Yan', 'wai.yan.library@example.com', '09-430001011', 'Yangon', '2026-04-20');

INSERT INTO borrow_records (
    member_id,
    book_id,
    borrow_date,
    due_date,
    return_date,
    status
) VALUES
    (1, 1, '2026-01-05', '2026-01-19', '2026-01-15', 'returned'),
    (2, 2, '2026-01-10', '2026-01-24', '2026-01-23', 'returned'),
    (3, 3, '2026-01-15', '2026-01-29', '2026-01-28', 'returned'),
    (4, 4, '2026-02-01', '2026-02-15', '2026-02-16', 'returned'),
    (5, 5, '2026-02-05', '2026-02-19', '2026-02-18', 'returned'),
    (1, 3, '2026-02-20', '2026-03-05', '2026-03-02', 'returned'),
    (2, 1, '2026-03-01', '2026-03-15', '2026-03-12', 'returned'),
    (6, 7, '2026-03-05', '2026-03-19', '2026-03-18', 'returned'),
    (7, 9, '2026-03-12', '2026-03-26', '2026-03-25', 'returned'),
    (8, 10, '2026-03-18', '2026-04-01', '2026-04-01', 'returned'),
    (3, 2, '2026-04-25', '2026-05-20', NULL, 'borrowed'),
    (4, 1, '2026-04-28', '2026-05-12', NULL, 'borrowed'),
    (5, 6, '2026-04-30', '2026-05-14', NULL, 'borrowed'),
    (6, 11, '2026-05-01', '2026-05-15', NULL, 'borrowed'),
    (7, 5, '2026-05-02', '2026-05-16', NULL, 'borrowed'),
    (8, 2, '2026-05-03', '2026-05-17', NULL, 'borrowed'),
    (9, 4, '2026-03-20', '2026-04-03', NULL, 'overdue'),
    (10, 8, '2026-03-25', '2026-04-08', NULL, 'overdue'),
    (1, 1, '2026-04-05', '2026-04-19', NULL, 'overdue');

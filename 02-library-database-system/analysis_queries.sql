-- Day 2 - Library Database System
-- Business analysis queries for PostgreSQL

-- 1. List all books with author names.
-- The books table stores author_id, but the JOIN lets us show readable author names.
SELECT
    b.book_id,
    b.title,
    a.author_name,
    b.category,
    b.published_year,
    b.total_copies,
    b.available_copies
FROM books AS b
JOIN authors AS a
    ON b.author_id = a.author_id
ORDER BY b.title;

-- 2. Show all members and their membership dates.
SELECT
    member_id,
    first_name,
    last_name,
    email,
    city,
    membership_date
FROM members
ORDER BY membership_date, member_id;

-- 3. Show current borrowed books.
-- Current borrowed books are records that are not returned yet.
-- This includes normal borrowed records and overdue records.
SELECT
    br.borrow_id,
    b.title,
    m.first_name || ' ' || m.last_name AS member_name,
    br.borrow_date,
    br.due_date,
    br.status
FROM borrow_records AS br
JOIN books AS b
    ON br.book_id = b.book_id
JOIN members AS m
    ON br.member_id = m.member_id
WHERE br.status IN ('borrowed', 'overdue')
ORDER BY br.due_date;

-- 4. Show available books.
-- A book is available when available_copies is greater than zero.
SELECT
    b.book_id,
    b.title,
    a.author_name,
    b.category,
    b.available_copies
FROM books AS b
JOIN authors AS a
    ON b.author_id = a.author_id
WHERE b.available_copies > 0
ORDER BY b.title;

-- 5. Show overdue books.
-- CURRENT_DATE makes the days_overdue calculation update when the query is run.
SELECT
    br.borrow_id,
    b.title,
    m.first_name || ' ' || m.last_name AS member_name,
    br.borrow_date,
    br.due_date,
    CURRENT_DATE - br.due_date AS days_overdue
FROM borrow_records AS br
JOIN books AS b
    ON br.book_id = b.book_id
JOIN members AS m
    ON br.member_id = m.member_id
WHERE br.status = 'overdue'
ORDER BY br.due_date;

-- 6. Show borrow history with member name and book title.
SELECT
    br.borrow_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    br.borrow_date,
    br.due_date,
    br.return_date,
    br.status
FROM borrow_records AS br
JOIN members AS m
    ON br.member_id = m.member_id
JOIN books AS b
    ON br.book_id = b.book_id
ORDER BY br.borrow_date, br.borrow_id;

-- 7. Count how many books each member has borrowed.
-- LEFT JOIN keeps members in the result even when they have never borrowed a book.
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    COUNT(br.borrow_id) AS borrowed_book_count
FROM members AS m
LEFT JOIN borrow_records AS br
    ON m.member_id = br.member_id
GROUP BY m.member_id, m.first_name, m.last_name
ORDER BY borrowed_book_count DESC, member_name;

-- 8. Find members who have not borrowed any books.
-- After a LEFT JOIN, missing borrow records appear as NULL.
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    m.city,
    m.membership_date
FROM members AS m
LEFT JOIN borrow_records AS br
    ON m.member_id = br.member_id
WHERE br.borrow_id IS NULL
ORDER BY m.membership_date;

-- 9. Find books that have never been borrowed.
SELECT
    b.book_id,
    b.title,
    a.author_name,
    b.category
FROM books AS b
JOIN authors AS a
    ON b.author_id = a.author_id
LEFT JOIN borrow_records AS br
    ON b.book_id = br.book_id
WHERE br.borrow_id IS NULL
ORDER BY b.title;

-- 10. Find the most borrowed books.
-- The CTE counts borrow records first, then the window function ranks the books.
WITH book_borrow_counts AS (
    SELECT
        b.book_id,
        b.title,
        COUNT(br.borrow_id) AS borrow_count
    FROM books AS b
    LEFT JOIN borrow_records AS br
        ON b.book_id = br.book_id
    GROUP BY b.book_id, b.title
    HAVING COUNT(br.borrow_id) > 0
)
SELECT
    title,
    borrow_count,
    RANK() OVER (
        ORDER BY borrow_count DESC
    ) AS borrow_rank
FROM book_borrow_counts
ORDER BY borrow_rank, title;

-- 11. Find the most popular book categories.
SELECT
    b.category,
    COUNT(br.borrow_id) AS borrow_count
FROM books AS b
LEFT JOIN borrow_records AS br
    ON b.book_id = br.book_id
GROUP BY b.category
HAVING COUNT(br.borrow_id) > 0
ORDER BY borrow_count DESC, b.category;

-- 12. Count monthly borrow activity.
-- DATE_TRUNC groups many borrow dates into the same month.
SELECT
    DATE_TRUNC('month', borrow_date)::date AS borrow_month,
    COUNT(*) AS borrow_count
FROM borrow_records
GROUP BY DATE_TRUNC('month', borrow_date)::date
ORDER BY borrow_month;

-- 13. Calculate average borrow duration for returned books.
-- return_date - borrow_date gives the number of days a book was kept.
SELECT
    ROUND(AVG(return_date - borrow_date), 2) AS average_borrow_days
FROM borrow_records
WHERE status = 'returned';

-- 14. Show borrowing status summary: borrowed, returned, overdue.
-- CASE WHEN adds a beginner-friendly explanation beside each status.
SELECT
    status,
    COUNT(*) AS record_count,
    CASE
        WHEN status = 'borrowed' THEN 'Book is currently borrowed and not late'
        WHEN status = 'returned' THEN 'Book has been returned'
        WHEN status = 'overdue' THEN 'Book is late and still not returned'
    END AS status_meaning
FROM borrow_records
GROUP BY status
ORDER BY status;

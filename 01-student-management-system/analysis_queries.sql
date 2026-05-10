-- Day 1 - Student Management System
-- Business analysis queries for PostgreSQL

-- 1. List all students.
SELECT
    student_id,
    first_name,
    last_name,
    email,
    city,
    created_at
FROM students
ORDER BY student_id;

-- 2. List all courses with instructor names.
-- The courses table stores instructor_id, but the JOIN lets us show readable names.
SELECT
    c.course_id,
    c.course_name,
    c.category,
    c.course_fee,
    c.start_date,
    c.end_date,
    i.first_name || ' ' || i.last_name AS instructor_name
FROM courses AS c
JOIN instructors AS i
    ON c.instructor_id = i.instructor_id
ORDER BY c.start_date;

-- 3. Show which students are enrolled in which courses.
-- The enrollments table connects each student to each course.
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    c.course_name,
    e.enrollment_date,
    e.status
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.student_id
JOIN courses AS c
    ON e.course_id = c.course_id
ORDER BY student_name, c.course_name;

-- 4. Count students per course.
-- LEFT JOIN keeps courses in the result even when they have zero enrollments.
SELECT
    c.course_name,
    COUNT(e.enrollment_id) AS enrolled_student_count
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY enrolled_student_count DESC, c.course_name;

-- 5. Find courses with no students.
-- After a LEFT JOIN, missing enrollment records appear as NULL.
SELECT
    c.course_id,
    c.course_name,
    c.category
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL
ORDER BY c.course_name;

-- 6. Find students with no enrollments.
-- This is useful for follow-up because the student exists but has not joined a course yet.
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    s.email,
    s.city
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
WHERE e.enrollment_id IS NULL
ORDER BY student_name;

-- 7. Find students enrolled in more than one course.
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    COUNT(e.enrollment_id) AS course_count
FROM students AS s
JOIN enrollments AS e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(e.enrollment_id) > 1
ORDER BY course_count DESC, student_name;

-- 8. Count active, completed, and dropped enrollments.
-- CASE WHEN lets us count different statuses in separate columns.
SELECT
    COUNT(CASE WHEN status = 'active' THEN 1 END) AS active_enrollments,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_enrollments,
    COUNT(CASE WHEN status = 'dropped' THEN 1 END) AS dropped_enrollments,
    COUNT(*) AS total_enrollments
FROM enrollments;

-- 9. Show total expected revenue per course based on enrollments and course fee.
-- Dropped enrollments are excluded because they usually should not count as expected revenue.
SELECT
    c.course_name,
    c.course_fee,
    COUNT(e.enrollment_id) AS enrollment_count,
    COUNT(CASE WHEN e.status IN ('active', 'completed') THEN 1 END) AS billable_enrollment_count,
    COUNT(CASE WHEN e.status IN ('active', 'completed') THEN 1 END) * c.course_fee AS expected_revenue
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.course_fee
ORDER BY expected_revenue DESC, c.course_name;

-- 10. Rank courses by number of enrolled students.
-- A CTE creates a temporary result that makes the ranking step easier to read.
WITH course_enrollment_counts AS (
    SELECT
        c.course_id,
        c.course_name,
        COUNT(e.enrollment_id) AS enrolled_student_count
    FROM courses AS c
    LEFT JOIN enrollments AS e
        ON c.course_id = e.course_id
    GROUP BY c.course_id, c.course_name
)
SELECT
    course_name,
    enrolled_student_count,
    RANK() OVER (
        ORDER BY enrolled_student_count DESC
    ) AS popularity_rank
FROM course_enrollment_counts
ORDER BY popularity_rank, course_name;

-- 11. Find the most popular course category.
-- The first CTE counts enrollments by category, and the second CTE ranks them.
WITH category_counts AS (
    SELECT
        c.category,
        COUNT(e.enrollment_id) AS enrollment_count
    FROM courses AS c
    LEFT JOIN enrollments AS e
        ON c.course_id = e.course_id
    GROUP BY c.category
),
ranked_categories AS (
    SELECT
        category,
        enrollment_count,
        RANK() OVER (
            ORDER BY enrollment_count DESC
        ) AS category_rank
    FROM category_counts
)
SELECT
    category,
    enrollment_count
FROM ranked_categories
WHERE category_rank = 1;

-- 12. Show student learning history by student.
-- STRING_AGG combines many course rows into one readable history per student.
SELECT
    s.student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    COUNT(e.enrollment_id) AS total_courses,
    COALESCE(
        STRING_AGG(
            c.course_name || ' (' || e.status || ')',
            ', '
            ORDER BY e.enrollment_date
        ),
        'No courses yet'
    ) AS learning_history
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
LEFT JOIN courses AS c
    ON e.course_id = c.course_id
GROUP BY s.student_id, s.first_name, s.last_name
ORDER BY student_name;

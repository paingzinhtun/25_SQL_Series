# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all students. | Gives the school a simple student directory. | `SELECT`, `ORDER BY` |
| List all courses with instructor names. | Helps staff see who is responsible for each course. | `JOIN` |
| Show which students are enrolled in which courses. | Connects student activity to course operations. | `JOIN`, many-to-many relationships |
| Count students per course. | Shows course demand and class size. | `LEFT JOIN`, `GROUP BY`, `COUNT` |
| Find courses with no students. | Helps identify courses that may need marketing or schedule review. | `LEFT JOIN`, `WHERE IS NULL` |
| Find students with no enrollments. | Helps the school follow up with registered students who have not joined a course. | `LEFT JOIN`, `WHERE IS NULL` |
| Find students enrolled in more than one course. | Identifies highly engaged students and cross-selling opportunities. | `GROUP BY`, `HAVING` |
| Count active, completed, and dropped enrollments. | Gives a quick view of enrollment status and student progress. | `CASE WHEN`, aggregation |
| Show total expected revenue per course. | Helps estimate course-level income from active and completed enrollments. | `JOIN`, `CASE WHEN`, calculated columns |
| Rank courses by number of enrolled students. | Shows the most and least popular courses. | CTE, window function, `RANK()` |
| Find the most popular course category. | Helps the school understand which learning areas have the highest demand. | CTE, `GROUP BY`, `RANK()` |
| Show student learning history by student. | Provides a simple view of each student's course journey. | `LEFT JOIN`, `STRING_AGG`, `COALESCE` |

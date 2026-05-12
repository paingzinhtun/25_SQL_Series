# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all books with author names. | Gives the library a readable catalog instead of only showing author IDs. | `JOIN` |
| Show all members and their membership dates. | Helps staff understand who joined and when. | `SELECT`, `ORDER BY` |
| Show current borrowed books. | Helps the library know which books are outside the library right now. | `WHERE`, `JOIN` |
| Show available books. | Helps staff and members see which books can be borrowed. | `WHERE`, filtering |
| Show overdue books. | Helps staff follow up on books that are late. | `WHERE`, date calculation |
| Show borrow history with member name and book title. | Creates a complete activity history for library operations. | `JOIN`, transaction data |
| Count how many books each member has borrowed. | Shows member activity and engagement. | `LEFT JOIN`, `GROUP BY`, `COUNT` |
| Find members who have not borrowed any books. | Helps the library identify inactive members. | `LEFT JOIN`, `WHERE IS NULL` |
| Find books that have never been borrowed. | Helps identify unused inventory. | `LEFT JOIN`, `WHERE IS NULL` |
| Find the most borrowed books. | Shows which books are in highest demand. | CTE, `GROUP BY`, `HAVING`, `RANK()` |
| Find the most popular book categories. | Helps guide future book purchases and category planning. | `GROUP BY`, `HAVING`, aggregation |
| Count monthly borrow activity. | Shows borrowing trends over time. | `DATE_TRUNC`, `GROUP BY` |
| Calculate average borrow duration for returned books. | Helps understand how long members usually keep books. | Date arithmetic, `AVG` |
| Show borrowing status summary. | Gives a quick operational view of borrowed, returned, and overdue records. | `CASE WHEN`, `GROUP BY` |

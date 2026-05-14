# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all movies with their directors. | Helps build a readable content catalog. | `JOIN` |
| List all movies with their genres. | Shows how content is categorized for browsing and filtering. | Bridge table, `STRING_AGG` |
| List all movies with their actors. | Shows cast information for each movie. | Bridge table, `JOIN` |
| Show movies that have multiple genres. | Helps learners understand that one movie can belong to many categories. | `GROUP BY`, `HAVING` |
| Show actors who acted in more than one movie. | Identifies recurring actors in the content catalog. | `GROUP BY`, `HAVING` |
| Find average rating for each movie. | Shows audience feedback and content quality. | `LEFT JOIN`, `AVG` |
| Find top 5 highest-rated movies. | Helps identify the best-rated content. | `GROUP BY`, `ORDER BY`, `LIMIT` |
| Find movies with no ratings. | Finds content that needs more user feedback. | `LEFT JOIN`, `WHERE IS NULL` |
| Find movies with no watch history. | Finds content that has not been viewed yet. | `LEFT JOIN`, `WHERE IS NULL` |
| Count movies by genre. | Shows content inventory by category. | Bridge table, `GROUP BY` |
| Find most watched genres. | Helps understand what users prefer to watch. | `JOIN`, `GROUP BY`, aggregation |
| Find users who watched the most movies. | Identifies highly active users. | `COUNT DISTINCT`, `GROUP BY` |
| Find users who completed the most movies. | Shows meaningful engagement, not just started views. | Boolean filtering, `WHERE` |
| Calculate total watch time by user. | Helps measure user activity and platform usage. | `SUM`, calculated columns |
| Find most watched movies. | Shows which movies are most popular. | `GROUP BY`, `CASE WHEN` |
| Rank actors by number of movies. | Shows actors with the most appearances. | Window function, `RANK()` |
| Find top-rated movies by genre. | Helps surface the best content in each category. | CTE, `RANK()` |
| Recommend popular movies from a user's most watched genre. | Demonstrates basic recommendation thinking using SQL. | CTE, `NOT EXISTS`, recommendation logic |

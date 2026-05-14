-- Day 5 - Movie Database System
-- Business analysis queries for PostgreSQL

-- 1. List all movies with their directors.
SELECT
    m.movie_id,
    m.title,
    m.release_year,
    d.director_name,
    m.duration_minutes,
    m.language
FROM movies AS m
JOIN directors AS d
    ON m.director_id = d.director_id
ORDER BY m.release_year DESC, m.title;

-- 2. List all movies with their genres.
-- STRING_AGG combines multiple genre rows into one readable list per movie.
SELECT
    m.movie_id,
    m.title,
    STRING_AGG(g.genre_name, ', ' ORDER BY g.genre_name) AS genres
FROM movies AS m
JOIN movie_genres AS mg
    ON m.movie_id = mg.movie_id
JOIN genres AS g
    ON mg.genre_id = g.genre_id
GROUP BY m.movie_id, m.title
ORDER BY m.title;

-- 3. List all movies with their actors.
-- The movie_actors bridge table connects each movie to many actors.
SELECT
    m.movie_id,
    m.title,
    STRING_AGG(a.actor_name || ' as ' || ma.character_name, ', ' ORDER BY a.actor_name) AS actors
FROM movies AS m
JOIN movie_actors AS ma
    ON m.movie_id = ma.movie_id
JOIN actors AS a
    ON ma.actor_id = a.actor_id
GROUP BY m.movie_id, m.title
ORDER BY m.title;

-- 4. Show movies that have multiple genres.
SELECT
    m.movie_id,
    m.title,
    COUNT(mg.genre_id) AS genre_count
FROM movies AS m
JOIN movie_genres AS mg
    ON m.movie_id = mg.movie_id
GROUP BY m.movie_id, m.title
HAVING COUNT(mg.genre_id) > 1
ORDER BY genre_count DESC, m.title;

-- 5. Show actors who acted in more than one movie.
SELECT
    a.actor_id,
    a.actor_name,
    COUNT(ma.movie_id) AS movie_count
FROM actors AS a
JOIN movie_actors AS ma
    ON a.actor_id = ma.actor_id
GROUP BY a.actor_id, a.actor_name
HAVING COUNT(ma.movie_id) > 1
ORDER BY movie_count DESC, a.actor_name;

-- 6. Find average rating for each movie.
-- LEFT JOIN keeps unrated movies in the result.
SELECT
    m.movie_id,
    m.title,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.rating_id) AS rating_count
FROM movies AS m
LEFT JOIN ratings AS r
    ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
ORDER BY average_rating DESC NULLS LAST, m.title;

-- 7. Find top 5 highest-rated movies.
SELECT
    m.title,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.rating_id) AS rating_count
FROM movies AS m
JOIN ratings AS r
    ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
HAVING COUNT(r.rating_id) >= 1
ORDER BY average_rating DESC, rating_count DESC, m.title
LIMIT 5;

-- 8. Find movies with no ratings.
SELECT
    m.movie_id,
    m.title,
    m.release_year
FROM movies AS m
LEFT JOIN ratings AS r
    ON m.movie_id = r.movie_id
WHERE r.rating_id IS NULL
ORDER BY m.title;

-- 9. Find movies with no watch history.
SELECT
    m.movie_id,
    m.title,
    m.release_year
FROM movies AS m
LEFT JOIN watch_history AS wh
    ON m.movie_id = wh.movie_id
WHERE wh.watch_id IS NULL
ORDER BY m.title;

-- 10. Count movies by genre.
SELECT
    g.genre_name,
    COUNT(mg.movie_id) AS movie_count
FROM genres AS g
LEFT JOIN movie_genres AS mg
    ON g.genre_id = mg.genre_id
GROUP BY g.genre_id, g.genre_name
ORDER BY movie_count DESC, g.genre_name;

-- 11. Find most watched genres.
SELECT
    g.genre_name,
    COUNT(wh.watch_id) AS watch_count,
    SUM(wh.watch_duration_minutes) AS total_watch_minutes
FROM genres AS g
JOIN movie_genres AS mg
    ON g.genre_id = mg.genre_id
JOIN watch_history AS wh
    ON mg.movie_id = wh.movie_id
GROUP BY g.genre_id, g.genre_name
ORDER BY watch_count DESC, total_watch_minutes DESC;

-- 12. Find users who watched the most movies.
-- COUNT(DISTINCT movie_id) counts unique movies instead of repeated watch events.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS user_name,
    COUNT(DISTINCT wh.movie_id) AS unique_movies_watched,
    COUNT(wh.watch_id) AS total_watch_events
FROM users AS u
JOIN watch_history AS wh
    ON u.user_id = wh.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY unique_movies_watched DESC, total_watch_events DESC, user_name;

-- 13. Find users who completed the most movies.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS user_name,
    COUNT(DISTINCT wh.movie_id) AS completed_movie_count
FROM users AS u
JOIN watch_history AS wh
    ON u.user_id = wh.user_id
WHERE wh.completed = TRUE
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY completed_movie_count DESC, user_name;

-- 14. Calculate total watch time by user.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS user_name,
    SUM(wh.watch_duration_minutes) AS total_watch_minutes,
    ROUND(SUM(wh.watch_duration_minutes) / 60.0, 2) AS total_watch_hours
FROM users AS u
JOIN watch_history AS wh
    ON u.user_id = wh.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_watch_minutes DESC, user_name;

-- 15. Find most watched movies.
SELECT
    m.movie_id,
    m.title,
    COUNT(wh.watch_id) AS watch_count,
    SUM(CASE WHEN wh.completed = TRUE THEN 1 ELSE 0 END) AS completed_watch_count
FROM movies AS m
JOIN watch_history AS wh
    ON m.movie_id = wh.movie_id
GROUP BY m.movie_id, m.title
ORDER BY watch_count DESC, completed_watch_count DESC, m.title;

-- 16. Rank actors by number of movies.
-- RANK gives the same rank to actors with the same movie count.
SELECT
    a.actor_name,
    COUNT(ma.movie_id) AS movie_count,
    RANK() OVER (
        ORDER BY COUNT(ma.movie_id) DESC
    ) AS actor_rank
FROM actors AS a
JOIN movie_actors AS ma
    ON a.actor_id = ma.actor_id
GROUP BY a.actor_id, a.actor_name
ORDER BY actor_rank, a.actor_name;

-- 17. Find top-rated movies by genre.
-- The first CTE calculates movie ratings, and the second CTE ranks movies inside each genre.
WITH movie_rating_by_genre AS (
    SELECT
        g.genre_name,
        m.movie_id,
        m.title,
        ROUND(AVG(r.rating), 2) AS average_rating,
        COUNT(r.rating_id) AS rating_count
    FROM genres AS g
    JOIN movie_genres AS mg
        ON g.genre_id = mg.genre_id
    JOIN movies AS m
        ON mg.movie_id = m.movie_id
    JOIN ratings AS r
        ON m.movie_id = r.movie_id
    GROUP BY g.genre_name, m.movie_id, m.title
),
ranked_movies AS (
    SELECT
        genre_name,
        title,
        average_rating,
        rating_count,
        RANK() OVER (
            PARTITION BY genre_name
            ORDER BY average_rating DESC, rating_count DESC
        ) AS genre_rank
    FROM movie_rating_by_genre
)
SELECT
    genre_name,
    title,
    average_rating,
    rating_count
FROM ranked_movies
WHERE genre_rank = 1
ORDER BY genre_name, title;

-- 18. Create a basic recommendation query:
-- Recommend popular movies from user 1's most watched genre that user 1 has not watched yet.
WITH user_genre_watch_counts AS (
    SELECT
        mg.genre_id,
        g.genre_name,
        COUNT(wh.watch_id) AS user_watch_count
    FROM watch_history AS wh
    JOIN movie_genres AS mg
        ON wh.movie_id = mg.movie_id
    JOIN genres AS g
        ON mg.genre_id = g.genre_id
    WHERE wh.user_id = 1
    GROUP BY mg.genre_id, g.genre_name
),
favorite_genre AS (
    SELECT
        genre_id,
        genre_name
    FROM user_genre_watch_counts
    ORDER BY user_watch_count DESC, genre_name
    LIMIT 1
),
popular_movies_in_genre AS (
    SELECT
        m.movie_id,
        m.title,
        fg.genre_name,
        COUNT(DISTINCT wh.watch_id) AS platform_watch_count,
        ROUND(AVG(r.rating), 2) AS average_rating
    FROM favorite_genre AS fg
    JOIN movie_genres AS mg
        ON fg.genre_id = mg.genre_id
    JOIN movies AS m
        ON mg.movie_id = m.movie_id
    LEFT JOIN watch_history AS wh
        ON m.movie_id = wh.movie_id
    LEFT JOIN ratings AS r
        ON m.movie_id = r.movie_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM watch_history AS user_watch
        WHERE user_watch.user_id = 1
          AND user_watch.movie_id = m.movie_id
    )
    GROUP BY m.movie_id, m.title, fg.genre_name
)
SELECT
    title,
    genre_name AS recommendation_reason,
    platform_watch_count,
    average_rating
FROM popular_movies_in_genre
ORDER BY platform_watch_count DESC, average_rating DESC NULLS LAST, title
LIMIT 5;

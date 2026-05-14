-- Day 5 - Movie Database System
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Movies can have multiple actors and multiple genres.
-- - Actors can appear in multiple movies.
-- - Users can rate and watch multiple movies.
-- - Hidden Orchard has no ratings and no watch history.
-- - Watch history includes both completed and not completed views.

INSERT INTO directors (
    director_name,
    country
) VALUES
    ('Min Htet Naing', 'Myanmar'),
    ('Khin Ma Ma', 'Myanmar'),
    ('Christopher Nolan', 'United Kingdom'),
    ('Greta Gerwig', 'United States'),
    ('Bong Joon Ho', 'South Korea'),
    ('Hayao Miyazaki', 'Japan'),
    ('Zaw Myint Oo', 'Myanmar'),
    ('Ava Chen', 'Singapore');

INSERT INTO actors (
    actor_name,
    country
) VALUES
    ('Aung Ko', 'Myanmar'),
    ('Thandar Hlaing', 'Myanmar'),
    ('Kyaw Zin', 'Myanmar'),
    ('May Thu', 'Myanmar'),
    ('Htet Aung', 'Myanmar'),
    ('Nilar Win', 'Myanmar'),
    ('Min Khant', 'Myanmar'),
    ('Ei Phyo', 'Myanmar'),
    ('Ye Naing', 'Myanmar'),
    ('Khin Sandi', 'Myanmar'),
    ('Leonardo DiCaprio', 'United States'),
    ('Margot Robbie', 'Australia'),
    ('Song Kang-ho', 'South Korea'),
    ('Rinko Kikuchi', 'Japan'),
    ('Dev Patel', 'United Kingdom');

INSERT INTO genres (
    genre_name
) VALUES
    ('Drama'),
    ('Comedy'),
    ('Action'),
    ('Thriller'),
    ('Romance'),
    ('Documentary'),
    ('Animation'),
    ('Sci-Fi'),
    ('Family'),
    ('Mystery');

INSERT INTO movies (
    title,
    release_year,
    director_id,
    duration_minutes,
    language
) VALUES
    ('Yangon Dreams', 2021, 1, 115, 'Burmese'),
    ('Mandalay Nights', 2022, 2, 105, 'Burmese'),
    ('River to Bagan', 2020, 7, 98, 'Burmese'),
    ('Data City', 2024, 8, 110, 'English'),
    ('Quantum Loop', 2023, 3, 130, 'English'),
    ('Market Day', 2019, 1, 95, 'Burmese'),
    ('Silent Lake', 2021, 5, 118, 'Korean'),
    ('Paper Lanterns', 2018, 6, 102, 'Japanese'),
    ('Startup Hearts', 2022, 8, 100, 'English'),
    ('Last Train Home', 2020, 2, 112, 'Burmese'),
    ('Code of Shadows', 2024, 3, 125, 'English'),
    ('Family Weekend', 2021, 4, 96, 'English'),
    ('Ocean Memory', 2019, 5, 108, 'Korean'),
    ('Village Voices', 2023, 7, 90, 'Burmese'),
    ('Neon Streets', 2024, 8, 122, 'English'),
    ('Hidden Orchard', 2022, 1, 101, 'Burmese');

INSERT INTO movie_actors (
    movie_id,
    actor_id,
    character_name
) VALUES
    (1, 1, 'Ko Min'),
    (1, 2, 'Ma Hnin'),
    (1, 7, 'Best Friend'),
    (2, 3, 'Detective Zaw'),
    (2, 4, 'Mya'),
    (2, 8, 'Journalist'),
    (3, 5, 'Boat Guide'),
    (3, 6, 'Teacher'),
    (4, 7, 'Data Analyst'),
    (4, 8, 'Product Manager'),
    (4, 15, 'Founder'),
    (5, 11, 'Scientist'),
    (5, 12, 'Commander'),
    (5, 15, 'Engineer'),
    (6, 1, 'Shop Owner'),
    (6, 4, 'Customer'),
    (7, 13, 'Inspector Park'),
    (7, 6, 'Translator'),
    (8, 14, 'Lantern Maker'),
    (8, 10, 'Grandmother'),
    (9, 2, 'Designer'),
    (9, 7, 'Developer'),
    (9, 15, 'Investor'),
    (10, 3, 'Station Master'),
    (10, 9, 'Passenger'),
    (11, 11, 'Agent Reed'),
    (11, 12, 'Mira'),
    (11, 5, 'Security Lead'),
    (12, 4, 'Mother'),
    (12, 10, 'Aunt'),
    (13, 13, 'Fisherman'),
    (13, 14, 'Researcher'),
    (14, 6, 'Narrator'),
    (14, 9, 'Village Leader'),
    (15, 8, 'Runner'),
    (15, 11, 'Detective Gray'),
    (15, 12, 'Street Racer'),
    (16, 1, 'Farmer'),
    (16, 10, 'Neighbor');

INSERT INTO movie_genres (
    movie_id,
    genre_id
) VALUES
    (1, 1),
    (1, 5),
    (2, 1),
    (2, 10),
    (3, 6),
    (3, 9),
    (4, 8),
    (4, 4),
    (5, 8),
    (5, 3),
    (5, 4),
    (6, 2),
    (6, 9),
    (7, 1),
    (7, 4),
    (7, 10),
    (8, 7),
    (8, 9),
    (9, 2),
    (9, 5),
    (10, 1),
    (10, 4),
    (11, 3),
    (11, 4),
    (11, 10),
    (12, 2),
    (12, 9),
    (13, 1),
    (13, 10),
    (14, 6),
    (14, 1),
    (15, 3),
    (15, 8),
    (16, 1);

INSERT INTO users (
    first_name,
    last_name,
    email,
    city
) VALUES
    ('Aung', 'Min', 'aung.min.movie@example.com', 'Yangon'),
    ('Su', 'Mon', 'su.mon.movie@example.com', 'Mandalay'),
    ('Thandar', 'Hlaing', 'thandar.hlaing.movie@example.com', 'Naypyidaw'),
    ('Kyaw', 'Zin', 'kyaw.zin.movie@example.com', 'Yangon'),
    ('May', 'Thu', 'may.thu.movie@example.com', 'Bago'),
    ('Htet', 'Aung', 'htet.aung.movie@example.com', 'Taunggyi'),
    ('Nilar', 'Win', 'nilar.win.movie@example.com', 'Mawlamyine'),
    ('Min', 'Khant', 'min.khant.movie@example.com', 'Mandalay'),
    ('Ei', 'Phyo', 'ei.phyo.movie@example.com', 'Yangon'),
    ('Ye', 'Naing', 'ye.naing.movie@example.com', 'Pathein'),
    ('Khin', 'Sandi', 'khin.sandi.movie@example.com', 'Naypyidaw'),
    ('Yamin', 'Oo', 'yamin.oo.movie@example.com', 'Taunggyi');

INSERT INTO ratings (
    user_id,
    movie_id,
    rating,
    review_text,
    rating_date
) VALUES
    (1, 1, 5, 'Warm and emotional story.', '2026-01-05'),
    (1, 4, 4, 'Interesting tech setting.', '2026-01-07'),
    (1, 5, 5, 'Strong sci-fi thriller.', '2026-01-10'),
    (2, 1, 4, 'Beautiful local story.', '2026-01-11'),
    (2, 2, 5, 'Great mystery mood.', '2026-01-14'),
    (2, 9, 4, 'Fun and practical.', '2026-01-18'),
    (3, 3, 4, 'Calm documentary style.', '2026-01-20'),
    (3, 7, 5, 'Excellent suspense.', '2026-01-25'),
    (4, 5, 4, 'Complex but exciting.', '2026-02-01'),
    (4, 11, 5, 'Fast and sharp.', '2026-02-05'),
    (5, 6, 4, 'Simple and funny.', '2026-02-08'),
    (5, 12, 5, 'Good family movie.', '2026-02-10'),
    (6, 8, 5, 'Beautiful animation.', '2026-02-12'),
    (6, 13, 4, 'Quiet but powerful.', '2026-02-15'),
    (7, 10, 4, 'Emotional ending.', '2026-02-18'),
    (7, 14, 5, 'Important local voices.', '2026-02-20'),
    (8, 15, 4, 'Stylish action scenes.', '2026-03-02'),
    (8, 4, 5, 'Loved the data theme.', '2026-03-04'),
    (9, 2, 4, 'Good performances.', '2026-03-06'),
    (9, 7, 4, 'Dark and memorable.', '2026-03-08'),
    (10, 11, 4, 'Good thriller pacing.', '2026-03-10'),
    (10, 15, 5, 'Very entertaining.', '2026-03-12'),
    (11, 3, 5, 'Peaceful and educational.', '2026-03-15'),
    (11, 8, 4, 'Good for family viewing.', '2026-03-18'),
    (12, 12, 4, 'Light and enjoyable.', '2026-03-20'),
    (12, 13, 5, 'Excellent acting.', '2026-03-22'),
    (1, 11, 4, 'Smart action movie.', '2026-03-25');

INSERT INTO watch_history (
    user_id,
    movie_id,
    watch_date,
    watch_duration_minutes,
    completed
) VALUES
    (1, 1, '2026-01-03', 115, TRUE),
    (1, 4, '2026-01-06', 80, FALSE),
    (1, 5, '2026-01-09', 130, TRUE),
    (1, 11, '2026-03-24', 125, TRUE),
    (2, 1, '2026-01-10', 115, TRUE),
    (2, 2, '2026-01-13', 105, TRUE),
    (2, 9, '2026-01-17', 100, TRUE),
    (3, 3, '2026-01-19', 98, TRUE),
    (3, 7, '2026-01-24', 118, TRUE),
    (3, 14, '2026-02-19', 90, TRUE),
    (4, 5, '2026-01-31', 90, FALSE),
    (4, 11, '2026-02-04', 125, TRUE),
    (4, 15, '2026-03-11', 122, TRUE),
    (5, 6, '2026-02-07', 95, TRUE),
    (5, 12, '2026-02-09', 96, TRUE),
    (5, 1, '2026-02-11', 60, FALSE),
    (6, 8, '2026-02-11', 102, TRUE),
    (6, 13, '2026-02-14', 108, TRUE),
    (6, 12, '2026-02-16', 96, TRUE),
    (7, 10, '2026-02-17', 112, TRUE),
    (7, 14, '2026-02-19', 90, TRUE),
    (7, 3, '2026-02-21', 70, FALSE),
    (8, 15, '2026-03-01', 122, TRUE),
    (8, 4, '2026-03-03', 110, TRUE),
    (8, 5, '2026-03-05', 130, TRUE),
    (9, 2, '2026-03-05', 105, TRUE),
    (9, 7, '2026-03-07', 118, TRUE),
    (9, 10, '2026-03-09', 90, FALSE),
    (10, 11, '2026-03-09', 125, TRUE),
    (10, 15, '2026-03-11', 122, TRUE),
    (10, 5, '2026-03-13', 130, TRUE),
    (11, 3, '2026-03-14', 98, TRUE),
    (11, 8, '2026-03-17', 102, TRUE),
    (11, 14, '2026-03-19', 90, TRUE),
    (12, 12, '2026-03-19', 96, TRUE),
    (12, 13, '2026-03-21', 108, TRUE),
    (12, 9, '2026-03-23', 100, TRUE);

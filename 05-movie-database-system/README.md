# Day 5 — Movie Database System

## Project Overview

This project models a movie or streaming platform using PostgreSQL.

The goal is to show how platforms like IMDb, Netflix, or streaming services can structure content, people, ratings, and watch activity.

The system tracks:

- Movies
- Actors
- Directors
- Genres
- Users
- Ratings
- Watch history

This project is beginner-friendly, but it introduces an important real-world database concept: many-to-many relationships.

## Business Problem

A movie or streaming platform needs to manage content and understand user behavior.

The platform wants to answer questions such as:

- Which movies belong to which genres?
- Which actors acted in which movies?
- Which movies have the highest ratings?
- Which genres are most watched?
- Which users watch the most movies?
- Which movies have never been watched?
- Which actors appear in the most movies?
- Which movies can be recommended based on genre popularity?

SQL helps turn a content catalog and user activity into useful insights for content teams, product teams, and recommendation systems.

## Database Tables

### movies

Stores movie information such as title, release year, director, duration, and language.

### actors

Stores actor information such as actor name and country.

### directors

Stores director information such as director name and country.

### genres

Stores movie categories such as Drama, Comedy, Action, Thriller, Romance, Documentary, Animation, Sci-Fi, Family, and Mystery.

### movie_actors

Connects movies and actors.

This is a bridge table because one movie can have many actors, and one actor can appear in many movies.

### movie_genres

Connects movies and genres.

This is also a bridge table because one movie can have many genres, and one genre can contain many movies.

### users

Stores platform user information such as name, email, and city.

### ratings

Stores user ratings and reviews.

The `rating` value must be between 1 and 5. A unique constraint prevents the same user from rating the same movie more than once.

### watch_history

Stores user watch activity.

This table records which user watched which movie, the watch date, watch duration, and whether the movie was completed.

## Entity Relationship Explanation

The database has several core entities:

- A director can direct many movies.
- A movie belongs to one director.
- A user can rate many movies.
- A movie can receive many ratings.
- A user can watch many movies.
- A movie can appear in many watch history records.

The `ratings` table captures user feedback.

The `watch_history` table captures behavior over time.

Together, ratings and watch history help the platform understand content quality and user engagement.

## Many-to-Many Relationship Explanation

Many-to-many relationships are the most important lesson in this project.

In real content platforms:

- One movie can have many actors.
- One actor can appear in many movies.
- One movie can belong to many genres.
- One genre can contain many movies.

These relationships cannot be stored cleanly by putting actor names or genre names directly inside the `movies` table.

Instead, this project uses bridge tables:

- `movie_actors`
- `movie_genres`

Each bridge table stores pairs of IDs.

For example, if movie 1 has actor 1 and actor 2, the `movie_actors` table stores two rows. This keeps the data flexible, searchable, and easier to analyze.

## SQL Concepts Practiced

- Creating tables
- Primary keys
- Foreign keys
- Composite primary keys
- Unique constraints
- NOT NULL constraints
- CHECK constraints
- Bridge tables
- Many-to-many relationships
- SELECT queries
- WHERE filtering
- INNER JOIN
- LEFT JOIN
- GROUP BY
- HAVING
- ORDER BY
- CASE WHEN
- Boolean filtering
- Common Table Expressions
- Window functions
- Aggregations
- Basic recommendation logic

## Business Questions Answered

This project answers practical questions such as:

- List all movies with their directors.
- List all movies with their genres.
- List all movies with their actors.
- Show movies that have multiple genres.
- Show actors who acted in more than one movie.
- Find average rating for each movie.
- Find top 5 highest-rated movies.
- Find movies with no ratings.
- Find movies with no watch history.
- Count movies by genre.
- Find most watched genres.
- Find users who watched the most movies.
- Find users who completed the most movies.
- Calculate total watch time by user.
- Find most watched movies.
- Rank actors by number of movies.
- Find top-rated movies by genre.
- Recommend popular movies from a user's most watched genre.

## Files in This Project

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the database tables, keys, and constraints |
| `insert_data.sql` | Inserts realistic sample data |
| `analysis_queries.sql` | Contains business reporting queries |
| `business_questions.md` | Explains each business question, why it matters, and the SQL concept practiced |
| `README.md` | Documents the project and learning goals |

## Key Lessons

Good data modeling matters before analytics or AI.

A content platform needs clean structure before it can answer business questions:

1. Movies need directors, actors, and genres.
2. Actors and genres require bridge tables because the relationships are many-to-many.
3. Ratings help measure user opinion.
4. Watch history helps measure user behavior.
5. SQL can combine catalog data and behavior data to create useful insights.
6. Recommendation logic starts with simple patterns, such as suggesting popular content from a user's favorite genre.

This same idea applies beyond movie platforms. E-commerce, education, healthcare, fintech, and many other business systems also need strong data modeling before analytics, dashboards, or AI can work well.

## How to Run This Project

Make sure PostgreSQL is installed and running.

Create a database:

```sql
CREATE DATABASE movie_database_system;
```

Connect to the database:

```bash
psql -d movie_database_system
```

Run the files in this order:

```bash
psql -d movie_database_system -f schema.sql
psql -d movie_database_system -f insert_data.sql
psql -d movie_database_system -f analysis_queries.sql
```

If you are already inside `psql`, you can run:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

## LinkedIn Reflection Draft

Day 5/25 — SQL for Real Business Data Systems

Today I built a Movie Database System using SQL.

This project helped me understand one important database concept:

Many-to-many relationships.

In real platforms, one movie can have many actors.
One actor can appear in many movies.
One movie can also belong to many genres.
One genre can contain many movies.

To model this properly, I used bridge tables such as:

- movie_actors
- movie_genres

For this project, I modeled:

- movies
- actors
- directors
- genres
- users
- ratings
- watch_history

Then I wrote SQL queries to answer questions like:

- Which movies have the highest ratings?
- Which genres are most watched?
- Which actors appear in the most movies?
- Which users watch the most content?
- Which movies have never been watched?
- How can we create a basic recommendation query using SQL?

SQL concepts I practiced:

- many-to-many relationships
- bridge tables
- joins
- left joins
- grouping
- aggregation
- CTEs
- window functions
- ranking
- basic recommendation logic

My key lesson:
Good data modeling matters before analytics or AI.

Before a platform can recommend movies, analyze user behavior, build dashboards, or create data pipelines, the data needs to be structured correctly.

This same idea applies to e-commerce, education, healthcare, fintech, and many other business systems.

This foundation is important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

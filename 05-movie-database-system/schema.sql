-- Day 5 - Movie Database System
-- PostgreSQL schema

-- Drop child tables first because they depend on parent tables through foreign keys.
DROP TABLE IF EXISTS watch_history;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS movie_actors;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS actors;
DROP TABLE IF EXISTS directors;

CREATE TABLE directors (
    director_id SERIAL PRIMARY KEY,
    director_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(60),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE actors (
    actor_id SERIAL PRIMARY KEY,
    actor_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(60),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(60) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL UNIQUE,
    release_year INTEGER NOT NULL,
    director_id INTEGER NOT NULL,
    duration_minutes INTEGER NOT NULL,
    language VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_movies_director
        FOREIGN KEY (director_id)
        REFERENCES directors (director_id),

    CONSTRAINT chk_movies_release_year
        CHECK (release_year BETWEEN 1900 AND 2100),

    CONSTRAINT chk_movies_duration
        CHECK (duration_minutes > 0)
);

-- Bridge table: one movie can have many actors, and one actor can act in many movies.
CREATE TABLE movie_actors (
    movie_id INTEGER NOT NULL,
    actor_id INTEGER NOT NULL,
    character_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_movie_actors
        PRIMARY KEY (movie_id, actor_id),

    CONSTRAINT fk_movie_actors_movie
        FOREIGN KEY (movie_id)
        REFERENCES movies (movie_id),

    CONSTRAINT fk_movie_actors_actor
        FOREIGN KEY (actor_id)
        REFERENCES actors (actor_id)
);

-- Bridge table: one movie can have many genres, and one genre can contain many movies.
CREATE TABLE movie_genres (
    movie_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_movie_genres
        PRIMARY KEY (movie_id, genre_id),

    CONSTRAINT fk_movie_genres_movie
        FOREIGN KEY (movie_id)
        REFERENCES movies (movie_id),

    CONSTRAINT fk_movie_genres_genre
        FOREIGN KEY (genre_id)
        REFERENCES genres (genre_id)
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    review_text TEXT,
    rating_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ratings_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_ratings_movie
        FOREIGN KEY (movie_id)
        REFERENCES movies (movie_id),

    CONSTRAINT chk_ratings_value
        CHECK (rating BETWEEN 1 AND 5),

    CONSTRAINT uq_ratings_user_movie
        UNIQUE (user_id, movie_id)
);

CREATE TABLE watch_history (
    watch_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    watch_date DATE NOT NULL,
    watch_duration_minutes INTEGER NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_watch_history_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_watch_history_movie
        FOREIGN KEY (movie_id)
        REFERENCES movies (movie_id),

    CONSTRAINT chk_watch_history_duration
        CHECK (watch_duration_minutes >= 0)
);

-- Day 10 - Football World Cup Dashboard
-- PostgreSQL schema
--
-- This project uses real pre-tournament data where available.
-- Player rows are labeled by squad status so learners do not confuse
-- recent/provisional player examples with official final World Cup squads.

DROP TABLE IF EXISTS substitutions;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS match_stats;
DROP TABLE IF EXISTS goals;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS stadiums;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS teams;

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL UNIQUE,
    confederation VARCHAR(20) NOT NULL,
    group_name CHAR(1) NOT NULL,
    coach_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_teams_confederation
        CHECK (confederation IN ('AFC', 'CAF', 'CONCACAF', 'CONMEBOL', 'OFC', 'UEFA')),

    CONSTRAINT chk_teams_group
        CHECK (group_name IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'))
);

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL,
    player_name VARCHAR(100) NOT NULL,
    shirt_number INTEGER NOT NULL,
    position VARCHAR(30) NOT NULL,
    preferred_foot VARCHAR(10) NOT NULL,
    squad_status VARCHAR(40) NOT NULL DEFAULT 'recent_player_example',
    source_note VARCHAR(200) NOT NULL DEFAULT 'Not an official final FIFA World Cup 2026 squad row',
    source_updated_date DATE NOT NULL DEFAULT DATE '2026-05-19',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_players_team
        FOREIGN KEY (team_id)
        REFERENCES teams (team_id),

    CONSTRAINT uq_players_team_name
        UNIQUE (team_id, player_name),

    CONSTRAINT uq_players_team_shirt
        UNIQUE (team_id, shirt_number),

    CONSTRAINT chk_players_position
        CHECK (position IN ('goalkeeper', 'defender', 'midfielder', 'forward')),

    CONSTRAINT chk_players_preferred_foot
        CHECK (preferred_foot IN ('left', 'right', 'both')),

    CONSTRAINT chk_players_squad_status
        CHECK (squad_status IN (
            'official_final_squad',
            'provisional_squad',
            'recent_player_example',
            'player_pool'
        )),

    CONSTRAINT chk_players_shirt_number
        CHECK (shirt_number BETWEEN 1 AND 99)
);

CREATE TABLE stadiums (
    stadium_id SERIAL PRIMARY KEY,
    stadium_name VARCHAR(120) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    country VARCHAR(80) NOT NULL,
    capacity INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_stadiums_capacity
        CHECK (capacity > 0)
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    match_date DATE NOT NULL,
    stage VARCHAR(30) NOT NULL,
    stadium_id INTEGER NOT NULL,
    home_team_id INTEGER NOT NULL,
    away_team_id INTEGER NOT NULL,
    home_score INTEGER,
    away_score INTEGER,
    winner_team_id INTEGER,
    attendance INTEGER,
    match_status VARCHAR(20) NOT NULL DEFAULT 'completed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_matches_stadium
        FOREIGN KEY (stadium_id)
        REFERENCES stadiums (stadium_id),

    CONSTRAINT fk_matches_home_team
        FOREIGN KEY (home_team_id)
        REFERENCES teams (team_id),

    CONSTRAINT fk_matches_away_team
        FOREIGN KEY (away_team_id)
        REFERENCES teams (team_id),

    CONSTRAINT fk_matches_winner_team
        FOREIGN KEY (winner_team_id)
        REFERENCES teams (team_id),

    CONSTRAINT chk_matches_stage
        CHECK (stage IN ('group_stage', 'semi_final', 'final')),

    CONSTRAINT chk_matches_scores
        CHECK (
            home_score IS NULL
            OR home_score >= 0
        ),

    CONSTRAINT chk_matches_away_score
        CHECK (
            away_score IS NULL
            OR away_score >= 0
        ),

    CONSTRAINT chk_matches_attendance
        CHECK (
            attendance IS NULL
            OR attendance >= 0
        ),

    CONSTRAINT chk_matches_status
        CHECK (match_status IN ('scheduled', 'completed')),

    CONSTRAINT chk_matches_different_teams
        CHECK (home_team_id <> away_team_id),

    CONSTRAINT chk_matches_winner_is_participant
        CHECK (
            winner_team_id IS NULL
            OR winner_team_id IN (home_team_id, away_team_id)
        )
);

CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    assist_player_id INTEGER,
    goal_minute INTEGER NOT NULL,
    goal_type VARCHAR(30) NOT NULL,
    is_own_goal BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_goals_match
        FOREIGN KEY (match_id)
        REFERENCES matches (match_id),

    CONSTRAINT fk_goals_team
        FOREIGN KEY (team_id)
        REFERENCES teams (team_id),

    CONSTRAINT fk_goals_player
        FOREIGN KEY (player_id)
        REFERENCES players (player_id),

    CONSTRAINT fk_goals_assist_player
        FOREIGN KEY (assist_player_id)
        REFERENCES players (player_id),

    CONSTRAINT chk_goals_minute
        CHECK (goal_minute BETWEEN 1 AND 130),

    CONSTRAINT chk_goals_type
        CHECK (goal_type IN ('open_play', 'penalty', 'free_kick', 'header', 'own_goal'))
);

CREATE TABLE match_stats (
    stat_id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    possession_pct NUMERIC(5, 2) NOT NULL,
    shots INTEGER NOT NULL,
    shots_on_target INTEGER NOT NULL,
    corners INTEGER NOT NULL,
    fouls INTEGER NOT NULL,
    passes_completed INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_match_stats_match
        FOREIGN KEY (match_id)
        REFERENCES matches (match_id),

    CONSTRAINT fk_match_stats_team
        FOREIGN KEY (team_id)
        REFERENCES teams (team_id),

    CONSTRAINT uq_match_stats_match_team
        UNIQUE (match_id, team_id),

    CONSTRAINT chk_match_stats_possession
        CHECK (possession_pct BETWEEN 0 AND 100),

    CONSTRAINT chk_match_stats_non_negative
        CHECK (
            shots >= 0
            AND shots_on_target >= 0
            AND corners >= 0
            AND fouls >= 0
            AND passes_completed >= 0
        ),

    CONSTRAINT chk_match_stats_shots_on_target
        CHECK (shots_on_target <= shots)
);

CREATE TABLE cards (
    card_id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    card_minute INTEGER NOT NULL,
    card_type VARCHAR(10) NOT NULL,
    reason VARCHAR(120),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cards_match
        FOREIGN KEY (match_id)
        REFERENCES matches (match_id),

    CONSTRAINT fk_cards_team
        FOREIGN KEY (team_id)
        REFERENCES teams (team_id),

    CONSTRAINT fk_cards_player
        FOREIGN KEY (player_id)
        REFERENCES players (player_id),

    CONSTRAINT chk_cards_minute
        CHECK (card_minute BETWEEN 1 AND 130),

    CONSTRAINT chk_cards_type
        CHECK (card_type IN ('yellow', 'red'))
);

CREATE TABLE substitutions (
    substitution_id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    player_out_id INTEGER NOT NULL,
    player_in_id INTEGER NOT NULL,
    substitution_minute INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_substitutions_match
        FOREIGN KEY (match_id)
        REFERENCES matches (match_id),

    CONSTRAINT fk_substitutions_team
        FOREIGN KEY (team_id)
        REFERENCES teams (team_id),

    CONSTRAINT fk_substitutions_player_out
        FOREIGN KEY (player_out_id)
        REFERENCES players (player_id),

    CONSTRAINT fk_substitutions_player_in
        FOREIGN KEY (player_in_id)
        REFERENCES players (player_id),

    CONSTRAINT chk_substitutions_minute
        CHECK (substitution_minute BETWEEN 1 AND 130),

    CONSTRAINT chk_substitutions_different_players
        CHECK (player_out_id <> player_in_id)
);

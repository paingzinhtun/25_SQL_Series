-- Day 8 - COVID Data Analysis
-- PostgreSQL schema
--
-- This is a SQL learning project with fictional sample data.
-- It is not medical advice and does not use official public health data.

DROP TABLE IF EXISTS vaccinations;
DROP TABLE IF EXISTS covid_daily_stats;
DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    region VARCHAR(80) NOT NULL,
    population BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_countries_population
        CHECK (population > 0)
);

CREATE TABLE covid_daily_stats (
    stat_id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL,
    report_date DATE NOT NULL,
    new_cases INTEGER NOT NULL,
    total_cases INTEGER NOT NULL,
    new_deaths INTEGER NOT NULL,
    total_deaths INTEGER NOT NULL,
    new_recoveries INTEGER NOT NULL,
    total_recoveries INTEGER NOT NULL,
    active_cases INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_covid_daily_stats_country
        FOREIGN KEY (country_id)
        REFERENCES countries (country_id),

    CONSTRAINT uq_covid_daily_stats_country_date
        UNIQUE (country_id, report_date),

    CONSTRAINT chk_covid_daily_stats_new_cases
        CHECK (new_cases >= 0),

    CONSTRAINT chk_covid_daily_stats_total_cases
        CHECK (total_cases >= 0),

    CONSTRAINT chk_covid_daily_stats_new_deaths
        CHECK (new_deaths >= 0),

    CONSTRAINT chk_covid_daily_stats_total_deaths
        CHECK (total_deaths >= 0),

    CONSTRAINT chk_covid_daily_stats_new_recoveries
        CHECK (new_recoveries >= 0),

    CONSTRAINT chk_covid_daily_stats_total_recoveries
        CHECK (total_recoveries >= 0),

    CONSTRAINT chk_covid_daily_stats_active_cases
        CHECK (active_cases >= 0)
);

CREATE TABLE vaccinations (
    vaccination_id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL,
    report_date DATE NOT NULL,
    daily_vaccinations INTEGER NOT NULL,
    total_vaccinations BIGINT NOT NULL,
    people_fully_vaccinated BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vaccinations_country
        FOREIGN KEY (country_id)
        REFERENCES countries (country_id),

    CONSTRAINT uq_vaccinations_country_date
        UNIQUE (country_id, report_date),

    CONSTRAINT chk_vaccinations_daily
        CHECK (daily_vaccinations >= 0),

    CONSTRAINT chk_vaccinations_total
        CHECK (total_vaccinations >= 0),

    CONSTRAINT chk_vaccinations_fully_vaccinated
        CHECK (people_fully_vaccinated >= 0)
);

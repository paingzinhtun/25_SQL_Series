# Day 10 — Football World Cup 2026 Dashboard

## Project Overview

This project builds a PostgreSQL dashboard project for the 2026 FIFA World Cup.

The goal is to practice SQL with real tournament-style data:

- 48 qualified teams
- 12 groups
- host stadiums
- scheduled fixtures
- tournament readiness checks

Important note: this project does not fake final squads, match results, goals, cards, or substitutions. Player rows are labeled with `squad_status` so recent/provisional player data is not confused with official final FIFA squad data.

As of 2026-05-19:

- The 48 qualified teams are known.
- Groups and fixture information are available.
- Some national teams have announced provisional or selected squads.
- FIFA says squads remain provisional until final squad lists are announced on 2026-06-02.
- Match results and event data are not available because the tournament has not started.
- Player rows in this project are recent/current national-team player examples, not official final World Cup squads.

## Real-World Problem

Sports organizations, broadcasters, analysts, and fan platforms need structured data before, during, and after a tournament.

Before the tournament starts, analysts need to answer questions such as:

- Which teams qualified?
- Which confederations have the most teams?
- Which teams are in each group?
- Which stadiums are hosting matches?
- Which host countries have the most stadiums?
- Which fixtures are already loaded?
- Which teams are not yet included in the fixture sample?
- Which player rows are loaded for each team, and what is their squad status?
- What is the position mix across the player examples?
- Is the dataset ready for final squads and match events later?

SQL helps turn tournament reference data into a clean dashboard foundation.

## Database Tables

### teams

Stores qualified national teams, confederation, group name, and coach name.

### players

Stores real recent/current national-team player examples.

These rows are useful for practicing player joins and squad-style queries, but they are not labeled as final official squads. The `squad_status`, `source_note`, and `source_updated_date` columns make the data status explicit and allow verified final squad rows to be loaded later.

### stadiums

Stores real host stadium information such as stadium name, city, country, and capacity.

### matches

Stores scheduled fixture information.

Because the matches have not been played yet, `home_score`, `away_score`, `winner_team_id`, and `attendance` are nullable.

### goals

Stores goal events after matches are played.

This table is empty before the tournament starts.

### match_stats

Stores team-level match statistics such as possession, shots, corners, fouls, and completed passes.

This table is empty before matches are played.

### cards

Stores yellow and red card events.

This table is empty before matches are played.

### substitutions

Stores substitution events.

This table is empty before matches are played.

## Entity Relationship Explanation

The database is designed so it can grow from pre-tournament data into full match analytics.

The main relationships are:

- One team can have many players.
- One stadium can host many matches.
- One match has one home team and one away team.
- One match can later have many goals.
- One match can later have match statistics for both teams.
- One match can later have many cards and substitutions.

Foreign keys protect these relationships.

For example:

- `players.team_id` must match a real team.
- `matches.stadium_id` must match a real stadium.
- `goals.player_id` must match a real player.
- `match_stats.match_id` must match a real match.

## Sports Analytics Metrics Explanation

This version focuses on pre-tournament analytics.

### Group Composition

Each World Cup group should contain four teams.

The query using `HAVING COUNT(*) = 4` checks group completeness.

### Confederation Representation

Counting teams by confederation helps show regional representation.

### Fixture Coverage

Fixture coverage checks which teams already appear in the loaded fixture sample.

This is useful when building a dataset gradually from official sources.

### Stadium Capacity

Stadium capacity can be used for venue rankings and capacity-share analysis.

The query uses:

```sql
capacity / total_capacity * 100
```

`NULLIF` is used to avoid division by zero.

### Data Readiness

The data readiness query counts rows across all major tables.

This makes it clear which parts of the dataset are ready now and which parts should be filled later.

## SQL Concepts Practiced

This project practices:

- `SELECT`
- `WHERE`
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `CASE WHEN`
- CTEs
- `UNION`
- `UNION ALL`
- `STRING_AGG`
- Window functions
- `RANK()`
- `DENSE_RANK()`
- `ROW_NUMBER()`
- `NULLIF`
- Scalar subqueries
- Data readiness checks

## Analytical Questions Answered

The analysis queries answer questions such as:

- Which teams qualified?
- Which teams are in each group?
- How many teams qualified from each confederation?
- Do all groups have four teams?
- Which stadiums are hosting the tournament?
- Which host country has the most stadiums?
- Which stadiums have the largest capacity?
- Which scheduled fixtures are loaded?
- Which fixtures happen on opening day?
- Which matches involve host nations?
- Which teams are not yet included in the fixture sample?
- Which player rows are loaded by team and squad status?
- What is the position mix by team?
- Which teams have no goalkeeper example loaded yet?
- Which player examples belong to opening-day teams?
- What is the pre-tournament dashboard KPI summary?
- Which tables are ready, and which are waiting for official squad or match-event data?

## Files in This Project

| File | Description |
| --- | --- |
| `schema.sql` | Creates tables, relationships, and constraints |
| `insert_data.sql` | Inserts real pre-tournament team, stadium, and fixture sample data |
| `analysis_queries.sql` | Contains pre-tournament dashboard queries |
| `business_questions.md` | Maps analytical questions to SQL concepts |
| `README.md` | Explains the project and learning goals |

## Key Lessons

Real data projects require honesty about data availability.

It is better to leave a table empty than to fill it with fake data and call it real.

For this project:

- Teams and groups are available now.
- Stadium data is available now.
- Fixture data can be loaded from official schedules.
- Recent/provisional player examples are included for SQL practice.
- Final squads should be loaded only after official final squad lists are published.
- Goals, cards, substitutions, and match stats should be loaded after matches are played.

This is how real analytics systems grow over time.

First, we model the structure.

Then, we load reliable data as it becomes available.

## How to Run This Project

Run the files in this order:

```sql
\i schema.sql
\i insert_data.sql
\i analysis_queries.sql
```

Or run them manually in a PostgreSQL client such as:

- pgAdmin
- DBeaver
- TablePlus
- DataGrip
- `psql`

Recommended workflow:

1. Create a new PostgreSQL database.
2. Run `schema.sql`.
3. Run `insert_data.sql`.
4. Open `analysis_queries.sql`.
5. Run each query one by one and study the result.
6. Add official player squads when FIFA publishes final squad lists, using `squad_status = 'official_final_squad'`.
7. Add goals, cards, substitutions, and match stats after matches are played.

## LinkedIn Reflection Draft

Day 10/25 — SQL for Real Business Data Systems

Today I changed my Day 10 project into a Football World Cup 2026 Dashboard using SQL.

At first, I planned to build a sports analytics dashboard with fictional data.

But because the 2026 World Cup is coming soon, I wanted this project to be closer to a real-world use case.

The important lesson was not only SQL.

It was also about data availability.

For this project, I modeled:
- teams
- players
- stadiums
- matches
- goals
- match statistics
- cards
- substitutions

But I separated the data clearly:
- qualified teams
- groups
- host stadiums
- scheduled fixture samples
- recent/provisional player examples for practice

I did not label recent/provisional player examples as official final squads, and I did not fake match results.

Those should be added only when official data becomes available.

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- player data-readiness checks
- HAVING
- CASE WHEN
- CTEs
- window functions
- NULL handling
- dashboard KPI queries
- data readiness checks

My key lesson:
Real data projects require both technical skill and data honesty.

A good database is not only about storing rows.

It should clearly show what data is available, what is missing, and what can be added later.

This mindset is important for Data Engineering, Analytics, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏

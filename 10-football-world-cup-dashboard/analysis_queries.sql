-- Day 10 - Football World Cup 2026 Dashboard
-- Analysis queries for PostgreSQL
--
-- This project uses real pre-tournament data where available.
-- Final official squad rows, scores, goals, cards, substitutions, and match statistics are not inserted yet.

-- 1. List all qualified teams.
SELECT
    team_id,
    team_name,
    confederation,
    group_name
FROM teams
ORDER BY group_name, team_name;

-- 2. Count teams by confederation.
SELECT
    confederation,
    COUNT(*) AS team_count
FROM teams
GROUP BY confederation
ORDER BY team_count DESC, confederation;

-- 2a. List recent/current player examples loaded for SQL practice.
-- These rows are not official final World Cup squads.
SELECT
    t.team_name,
    p.player_name,
    p.shirt_number,
    p.position,
    p.preferred_foot,
    p.squad_status,
    p.source_updated_date
FROM players AS p
JOIN teams AS t
    ON p.team_id = t.team_id
ORDER BY t.group_name, t.team_name, p.shirt_number;

-- 3. Count teams by group.
SELECT
    group_name,
    COUNT(*) AS team_count
FROM teams
GROUP BY group_name
ORDER BY group_name;

-- 4. Show each group with its teams in one row.
SELECT
    group_name,
    STRING_AGG(team_name, ', ' ORDER BY team_name) AS teams_in_group
FROM teams
GROUP BY group_name
ORDER BY group_name;

-- 5. Find groups that have exactly 4 teams.
-- HAVING filters groups after counting teams.
SELECT
    group_name,
    COUNT(*) AS team_count
FROM teams
GROUP BY group_name
HAVING COUNT(*) = 4
ORDER BY group_name;

-- 6. List all host stadiums.
SELECT
    stadium_id,
    stadium_name,
    city,
    country,
    capacity
FROM stadiums
ORDER BY country, city;

-- 7. Count stadiums by host country.
SELECT
    country,
    COUNT(*) AS stadium_count
FROM stadiums
GROUP BY country
ORDER BY stadium_count DESC, country;

-- 8. Rank stadiums by capacity.
SELECT
    stadium_name,
    city,
    country,
    capacity,
    RANK() OVER (
        ORDER BY capacity DESC
    ) AS capacity_rank
FROM stadiums
ORDER BY capacity_rank;

-- 9. List scheduled matches with teams and stadiums.
SELECT
    m.match_id,
    m.match_date,
    m.stage,
    home.team_name AS home_team,
    away.team_name AS away_team,
    s.stadium_name,
    s.city,
    s.country,
    m.match_status
FROM matches AS m
JOIN teams AS home
    ON m.home_team_id = home.team_id
JOIN teams AS away
    ON m.away_team_id = away.team_id
JOIN stadiums AS s
    ON m.stadium_id = s.stadium_id
ORDER BY m.match_date, m.match_id;

-- 10. Count scheduled matches by date.
SELECT
    match_date,
    COUNT(*) AS scheduled_matches
FROM matches
GROUP BY match_date
ORDER BY match_date;

-- 11. Count scheduled matches by host country.
SELECT
    s.country,
    COUNT(m.match_id) AS scheduled_matches
FROM stadiums AS s
LEFT JOIN matches AS m
    ON s.stadium_id = m.stadium_id
GROUP BY s.country
ORDER BY scheduled_matches DESC, s.country;

-- 12. Count scheduled matches by stadium.
SELECT
    s.stadium_name,
    s.city,
    s.country,
    COUNT(m.match_id) AS scheduled_matches
FROM stadiums AS s
LEFT JOIN matches AS m
    ON s.stadium_id = m.stadium_id
GROUP BY s.stadium_id, s.stadium_name, s.city, s.country
ORDER BY scheduled_matches DESC, s.stadium_name;

-- 13. Find stadiums in the sample that do not yet have a scheduled match row.
SELECT
    s.stadium_name,
    s.city,
    s.country
FROM stadiums AS s
LEFT JOIN matches AS m
    ON s.stadium_id = m.stadium_id
WHERE m.match_id IS NULL
ORDER BY s.country, s.city;

-- 14. Count scheduled matches by team.
WITH team_fixture_rows AS (
    SELECT home_team_id AS team_id
    FROM matches
    UNION ALL
    SELECT away_team_id AS team_id
    FROM matches
)
SELECT
    t.team_name,
    t.group_name,
    COUNT(tfr.team_id) AS scheduled_matches
FROM teams AS t
LEFT JOIN team_fixture_rows AS tfr
    ON t.team_id = tfr.team_id
GROUP BY t.team_id, t.team_name, t.group_name
ORDER BY scheduled_matches DESC, t.group_name, t.team_name;

-- 15. Find teams not yet included in this fixture sample.
WITH team_fixture_rows AS (
    SELECT home_team_id AS team_id
    FROM matches
    UNION
    SELECT away_team_id AS team_id
    FROM matches
)
SELECT
    t.team_name,
    t.group_name,
    t.confederation
FROM teams AS t
LEFT JOIN team_fixture_rows AS tfr
    ON t.team_id = tfr.team_id
WHERE tfr.team_id IS NULL
ORDER BY t.group_name, t.team_name;

-- 16. Show opening-day matches.
SELECT
    m.match_date,
    home.team_name AS home_team,
    away.team_name AS away_team,
    s.stadium_name,
    s.city,
    s.country
FROM matches AS m
JOIN teams AS home
    ON m.home_team_id = home.team_id
JOIN teams AS away
    ON m.away_team_id = away.team_id
JOIN stadiums AS s
    ON m.stadium_id = s.stadium_id
WHERE m.match_date = (
    SELECT MIN(match_date)
    FROM matches
)
ORDER BY m.match_id;

-- 17. Show matches involving host nations.
SELECT
    m.match_date,
    home.team_name AS home_team,
    away.team_name AS away_team,
    s.stadium_name
FROM matches AS m
JOIN teams AS home
    ON m.home_team_id = home.team_id
JOIN teams AS away
    ON m.away_team_id = away.team_id
JOIN stadiums AS s
    ON m.stadium_id = s.stadium_id
WHERE home.team_name IN ('Mexico', 'Canada', 'United States')
   OR away.team_name IN ('Mexico', 'Canada', 'United States')
ORDER BY m.match_date;

-- 18. Rank teams inside each group alphabetically.
SELECT
    group_name,
    team_name,
    confederation,
    ROW_NUMBER() OVER (
        PARTITION BY group_name
        ORDER BY team_name
    ) AS alphabetical_group_position
FROM teams
ORDER BY group_name, alphabetical_group_position;

-- 19. Rank confederations by number of qualified teams.
WITH confederation_counts AS (
    SELECT
        confederation,
        COUNT(*) AS team_count
    FROM teams
    GROUP BY confederation
)
SELECT
    confederation,
    team_count,
    DENSE_RANK() OVER (
        ORDER BY team_count DESC
    ) AS confederation_rank
FROM confederation_counts
ORDER BY confederation_rank, confederation;

-- 20. Calculate average stadium capacity by host country.
SELECT
    country,
    ROUND(AVG(capacity), 2) AS average_capacity
FROM stadiums
GROUP BY country
ORDER BY average_capacity DESC;

-- 21. Calculate each stadium capacity as a share of total capacity.
WITH total_capacity AS (
    SELECT SUM(capacity) AS all_stadium_capacity
    FROM stadiums
)
SELECT
    s.stadium_name,
    s.city,
    s.country,
    s.capacity,
    ROUND((s.capacity::numeric / NULLIF(tc.all_stadium_capacity, 0)) * 100, 2) AS capacity_share_percentage
FROM stadiums AS s
CROSS JOIN total_capacity AS tc
ORDER BY capacity_share_percentage DESC;

-- 22. Show tournament data readiness.
-- This is useful because final official squads and match events are not fully available before the tournament.
SELECT
    'teams' AS dataset,
    COUNT(*) AS row_count
FROM teams
UNION ALL
SELECT 'players', COUNT(*) FROM players
UNION ALL
SELECT 'stadiums', COUNT(*) FROM stadiums
UNION ALL
SELECT 'matches', COUNT(*) FROM matches
UNION ALL
SELECT 'goals', COUNT(*) FROM goals
UNION ALL
SELECT 'match_stats', COUNT(*) FROM match_stats
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'substitutions', COUNT(*) FROM substitutions
ORDER BY dataset;

-- 23. Create a pre-tournament dashboard KPI summary.
SELECT
    (SELECT COUNT(*) FROM teams) AS qualified_teams,
    (SELECT COUNT(DISTINCT group_name) FROM teams) AS tournament_groups,
    (SELECT COUNT(*) FROM stadiums) AS host_stadiums,
    (SELECT COUNT(DISTINCT country) FROM stadiums) AS host_countries,
    (SELECT COUNT(*) FROM matches) AS scheduled_matches_in_sample,
    (SELECT COUNT(*) FROM players) AS player_rows_loaded,
    (SELECT COUNT(*) FROM players WHERE squad_status = 'official_final_squad') AS official_final_squad_rows_loaded;

-- 24. Create a simple fixture availability summary using CASE WHEN.
WITH fixture_counts AS (
    SELECT
        t.team_name,
        t.group_name,
        COUNT(m.match_id) AS scheduled_matches
    FROM teams AS t
    LEFT JOIN matches AS m
        ON t.team_id IN (m.home_team_id, m.away_team_id)
    GROUP BY t.team_id, t.team_name, t.group_name
)
SELECT
    team_name,
    group_name,
    scheduled_matches,
    CASE
        WHEN scheduled_matches = 0 THEN 'Fixture not loaded in sample yet'
        WHEN scheduled_matches = 1 THEN 'One fixture loaded'
        ELSE 'Multiple fixtures loaded'
    END AS fixture_status
FROM fixture_counts
ORDER BY group_name, team_name;

-- 25. Count player rows loaded by team and squad status.
-- This checks how much player-level data is currently available for each team.
SELECT
    t.team_name,
    t.group_name,
    COALESCE(p.squad_status, 'no_player_rows_loaded') AS squad_status,
    COUNT(p.player_id) AS player_rows_loaded
FROM teams AS t
LEFT JOIN players AS p
    ON t.team_id = p.team_id
GROUP BY t.team_id, t.team_name, t.group_name, COALESCE(p.squad_status, 'no_player_rows_loaded')
ORDER BY player_rows_loaded DESC, t.group_name, t.team_name;

-- 26. Count player examples by position.
-- This helps learners understand squad structure.
SELECT
    position,
    COUNT(*) AS player_count
FROM players
GROUP BY position
ORDER BY player_count DESC, position;

-- 27. Show position mix by team.
SELECT
    t.team_name,
    SUM(CASE WHEN p.position = 'goalkeeper' THEN 1 ELSE 0 END) AS goalkeepers,
    SUM(CASE WHEN p.position = 'defender' THEN 1 ELSE 0 END) AS defenders,
    SUM(CASE WHEN p.position = 'midfielder' THEN 1 ELSE 0 END) AS midfielders,
    SUM(CASE WHEN p.position = 'forward' THEN 1 ELSE 0 END) AS forwards
FROM teams AS t
LEFT JOIN players AS p
    ON t.team_id = p.team_id
GROUP BY t.team_id, t.team_name
ORDER BY t.team_name;

-- 28. Count player examples by preferred foot.
SELECT
    preferred_foot,
    COUNT(*) AS player_count
FROM players
GROUP BY preferred_foot
ORDER BY player_count DESC, preferred_foot;

-- 29. Find groups with the most forward player examples.
SELECT
    t.group_name,
    COUNT(p.player_id) AS forward_count
FROM teams AS t
JOIN players AS p
    ON t.team_id = p.team_id
WHERE p.position = 'forward'
GROUP BY t.group_name
ORDER BY forward_count DESC, t.group_name;

-- 30. Rank players within each team by shirt number.
-- This is not a performance ranking. It demonstrates window functions with player data.
SELECT
    t.team_name,
    p.player_name,
    p.shirt_number,
    p.position,
    p.squad_status,
    ROW_NUMBER() OVER (
        PARTITION BY p.team_id
        ORDER BY p.shirt_number
    ) AS team_shirt_order
FROM players AS p
JOIN teams AS t
    ON p.team_id = t.team_id
ORDER BY t.team_name, team_shirt_order;

-- 31. Find teams that currently have no goalkeeper example loaded.
-- This is a data-readiness check, not a football judgment.
SELECT
    t.team_name,
    t.group_name
FROM teams AS t
LEFT JOIN players AS p
    ON t.team_id = p.team_id
   AND p.position = 'goalkeeper'
WHERE p.player_id IS NULL
ORDER BY t.group_name, t.team_name;

-- 32. Create a player data readiness summary using CASE WHEN.
-- A final World Cup squad has 23 to 26 players, so this labels current data coverage.
WITH player_counts AS (
    SELECT
        t.team_id,
        t.team_name,
        COUNT(p.player_id) AS player_rows_loaded,
        COUNT(p.player_id) FILTER (
            WHERE p.squad_status = 'official_final_squad'
        ) AS official_final_squad_rows
    FROM teams AS t
    LEFT JOIN players AS p
        ON t.team_id = p.team_id
    GROUP BY t.team_id, t.team_name
)
SELECT
    team_name,
    player_rows_loaded,
    official_final_squad_rows,
    CASE
        WHEN official_final_squad_rows BETWEEN 23 AND 26 THEN 'Official final squad loaded'
        WHEN player_rows_loaded = 0 THEN 'No player rows loaded'
        WHEN official_final_squad_rows = 0 THEN 'Only recent/provisional player examples loaded'
        ELSE 'Partial official final squad rows loaded'
    END AS player_data_status
FROM player_counts
ORDER BY team_name;

-- 33. Show player examples for teams in opening-day matches.
WITH opening_day_teams AS (
    SELECT home_team_id AS team_id
    FROM matches
    WHERE match_date = (SELECT MIN(match_date) FROM matches)
    UNION
    SELECT away_team_id AS team_id
    FROM matches
    WHERE match_date = (SELECT MIN(match_date) FROM matches)
)
SELECT
    t.team_name,
    p.player_name,
    p.position,
    p.shirt_number
FROM opening_day_teams AS odt
JOIN teams AS t
    ON odt.team_id = t.team_id
JOIN players AS p
    ON t.team_id = p.team_id
ORDER BY t.team_name, p.shirt_number;

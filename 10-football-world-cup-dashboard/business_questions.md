# Analytical Questions

| Analytical Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all qualified teams. | Shows the confirmed 48-team tournament field. | `SELECT`, `ORDER BY` |
| Count teams by confederation. | Shows regional representation in the tournament. | `GROUP BY`, `COUNT` |
| List recent/current player examples with squad status. | Supports player-team join practice while avoiding confusion with official final squads. | `JOIN`, `ORDER BY` |
| Count teams by group. | Checks that each group has four teams. | `GROUP BY`, `COUNT` |
| Show each group with its teams in one row. | Makes group composition easy to read. | `STRING_AGG`, `GROUP BY` |
| Find groups that have exactly four teams. | Validates tournament group completeness. | `HAVING` |
| List all host stadiums. | Provides venue reference data. | `SELECT`, `ORDER BY` |
| Count stadiums by host country. | Shows how hosting is distributed across countries. | `GROUP BY`, `COUNT` |
| Rank stadiums by capacity. | Creates a venue capacity leaderboard. | `RANK()` |
| List scheduled matches with teams and stadiums. | Creates a readable fixture report. | Multiple joins |
| Count scheduled matches by date. | Shows fixture density by date. | `GROUP BY`, date analysis |
| Count scheduled matches by host country. | Shows where loaded fixtures are hosted. | `LEFT JOIN`, aggregation |
| Count scheduled matches by stadium. | Shows stadium usage in the fixture sample. | `LEFT JOIN`, `COUNT` |
| Find stadiums without a loaded match row. | Helps detect incomplete fixture loading. | `LEFT JOIN`, `WHERE IS NULL` |
| Count scheduled matches by team. | Shows each team's loaded fixture count. | CTE, `UNION ALL` |
| Find teams not yet included in the fixture sample. | Helps identify incomplete fixture data. | CTE, `LEFT JOIN` |
| Show opening-day matches. | Highlights the tournament start. | Subquery, date filtering |
| Show matches involving host nations. | Tracks Mexico, Canada, and United States fixtures. | `WHERE`, `IN` |
| Rank teams inside each group alphabetically. | Demonstrates ranking within partitions. | `ROW_NUMBER()` |
| Rank confederations by qualified teams. | Shows regional strength by team count. | CTE, `DENSE_RANK()` |
| Calculate average stadium capacity by host country. | Compares host infrastructure. | `AVG`, `GROUP BY` |
| Calculate stadium capacity share. | Shows each stadium's share of total capacity. | CTE, `NULLIF` |
| Show tournament data readiness. | Makes missing official squads/events explicit. | `UNION ALL`, row counts |
| Create a pre-tournament dashboard KPI summary. | Provides high-level tournament setup metrics. | Scalar subqueries |
| Create a fixture availability summary. | Labels fixture coverage status for each team. | CTE, `CASE WHEN` |
| Count player rows loaded by team and squad status. | Shows current player-data coverage and whether rows are final or provisional/example data. | `LEFT JOIN`, `COUNT`, `COALESCE` |
| Count player examples by position. | Explains squad-role structure. | `GROUP BY`, `COUNT` |
| Show position mix by team. | Compares goalkeeper, defender, midfielder, and forward examples. | `CASE WHEN`, aggregation |
| Count player examples by preferred foot. | Shows player-profile distribution. | `GROUP BY`, `COUNT` |
| Find groups with the most forward player examples. | Connects player positions with tournament groups. | `JOIN`, `WHERE`, `GROUP BY` |
| Rank players within each team by shirt number. | Practices player-level window functions. | `ROW_NUMBER()` |
| Find teams without a goalkeeper example. | Demonstrates player data-readiness checks. | `LEFT JOIN`, `WHERE IS NULL` |
| Create a player data readiness summary. | Labels whether official final squad rows are loaded or only recent/provisional examples exist. | CTE, `CASE WHEN`, filtered aggregate |
| Show player examples for opening-day teams. | Connects fixtures to player examples. | CTE, `UNION`, joins |

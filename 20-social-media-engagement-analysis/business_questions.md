# Business Questions — Social Media Engagement Analysis

| Content / Business Question | Why It Matters | SQL Concept |
|---|---|---|
| Which accounts are included in the analysis? | Helps define the reporting scope across platforms and account types. | SELECT, ORDER BY |
| Which posts belong to which accounts and campaigns? | Connects content output to campaigns and publishing channels. | JOIN, LEFT JOIN |
| What is the total engagement for each post? | Shows which posts created audience response beyond views. | Calculated columns |
| What is the engagement rate per post? | Normalizes engagement by reach so small and large posts can be compared fairly. | Arithmetic, NULLIF |
| Which posts have the highest engagement? | Identifies content that generated the most audience action. | ORDER BY, LIMIT |
| Which posts have the highest engagement rate? | Finds efficient posts that performed well relative to impressions. | Rate calculation |
| Which high-impression posts had low engagement? | Finds content that reached people but did not resonate. | CTE, WHERE |
| Which low-impression posts had high engagement rate? | Finds strong content that may deserve reposting or promotion. | CTE, filtering |
| Which posts generated the most saves? | Saves can indicate content people want to revisit. | ORDER BY |
| Which posts generated the most shares? | Shares can indicate content people want to spread. | ORDER BY |
| Which posts generated the most comments? | Comments show conversation and audience participation. | ORDER BY |
| What is average engagement by content type? | Helps decide whether text, video, carousel, or polls work better. | GROUP BY, AVG |
| What is average engagement rate by content type? | Compares content formats after adjusting for reach. | GROUP BY, rate calculation |
| What is average engagement by content category? | Shows which topics create the most response. | GROUP BY, AVG |
| What is average engagement rate by content category? | Helps compare topic effectiveness fairly. | GROUP BY, NULLIF |
| Which content categories rank highest by engagement? | Helps prioritize future content themes. | RANK window function |
| Which posting days perform best? | Helps improve publishing schedule decisions. | TO_CHAR, GROUP BY |
| Which posting hours perform best? | Helps identify strong publishing time windows. | EXTRACT, GROUP BY |
| How many posts are published daily? | Tracks content consistency and publishing volume. | Date grouping |
| How many posts are published monthly? | Supports monthly content planning and review. | DATE_TRUNC |
| How much did each account grow in followers? | Measures audience growth over the analysis period. | CTE, ROW_NUMBER |
| What is follower growth rate by account? | Normalizes growth for accounts with different starting sizes. | CTE, NULLIF |
| Which accounts grew the fastest? | Identifies strong creator or brand growth. | CTE, ORDER BY |
| Which accounts are flat or declining? | Flags accounts that may need strategy review. | Window functions |
| Which campaigns generated the most engagement? | Measures campaign-level content performance. | LEFT JOIN, aggregation |
| Which campaigns had the best engagement rate? | Compares campaigns based on response relative to reach. | GROUP BY, NULLIF |
| Which campaigns drove follower growth? | Connects campaign activity to audience growth. | CTE, window functions |
| Which hashtags are used most often? | Shows common content themes and tagging habits. | GROUP BY, COUNT |
| Which hashtags have the highest average engagement? | Helps identify hashtags associated with stronger content. | JOIN, HAVING |
| Which posts received negative sentiment comments? | Helps creators review feedback and improve content. | WHERE, GROUP BY |
| What is the comment sentiment distribution? | Summarizes audience tone across posts. | GROUP BY |
| What are profile click and link click rates? | Measures whether content drives deeper action. | Rate calculation |
| What does a content performance dashboard show? | Combines reach, engagement, clicks, and status in one view. | CTE, CASE WHEN |
| What does an account growth dashboard show? | Combines follower growth and average engagement by account. | CTE, COALESCE |
| What content strategy actions are recommended? | Turns analytics into practical next steps. | CASE WHEN |
| Which posts rank highest inside each account? | Helps each account understand its own best posts. | DENSE_RANK |
| How do followers change day by day? | Shows account growth trend instead of only start and end values. | LAG |

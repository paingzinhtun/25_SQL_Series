-- Day 20 - Social Media Engagement Analysis
-- PostgreSQL analysis queries

-- 1. List all accounts.
SELECT
    account_id,
    account_name,
    platform,
    account_type,
    city,
    created_at
FROM accounts
ORDER BY platform, account_name;

-- 2. List all posts with account and campaign information.
SELECT
    p.post_id,
    a.account_name,
    a.platform,
    c.campaign_name,
    p.post_date,
    p.post_time,
    p.content_type,
    p.content_category,
    p.post_caption
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
LEFT JOIN campaigns AS c
    ON p.campaign_id = c.campaign_id
ORDER BY p.post_date, p.post_time;

-- 3. Show post metrics with calculated total engagement.
-- Total engagement = likes + comments_count + shares + saves.
SELECT
    p.post_id,
    a.account_name,
    p.content_type,
    p.content_category,
    pm.impressions,
    pm.likes,
    pm.comments_count,
    pm.shares,
    pm.saves,
    (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY total_engagement DESC;

-- 4. Calculate engagement rate per post.
-- Engagement rate = total engagement / impressions. NULLIF prevents division by zero.
SELECT
    p.post_id,
    a.account_name,
    p.content_type,
    p.content_category,
    pm.impressions,
    (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
    ROUND(
        (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
        / NULLIF(pm.impressions, 0),
        2
    ) AS engagement_rate_percent
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY engagement_rate_percent DESC;

-- 5. Find top 10 posts by total engagement.
SELECT
    p.post_id,
    a.account_name,
    p.content_category,
    (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY total_engagement DESC
LIMIT 10;

-- 6. Find top 10 posts by engagement rate.
SELECT
    p.post_id,
    a.account_name,
    p.content_type,
    p.content_category,
    pm.impressions,
    (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
    ROUND(
        (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
        / NULLIF(pm.impressions, 0),
        2
    ) AS engagement_rate_percent
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY engagement_rate_percent DESC
LIMIT 10;

-- 7. Find posts with high impressions but low engagement rate.
-- This highlights posts that reached many people but did not create enough response.
WITH post_performance AS (
    SELECT
        p.post_id,
        a.account_name,
        p.content_type,
        p.content_category,
        pm.impressions,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0) AS engagement_rate_percent
    FROM posts AS p
    JOIN accounts AS a
        ON p.account_id = a.account_id
    JOIN post_metrics AS pm
        ON p.post_id = pm.post_id
)
SELECT
    post_id,
    account_name,
    content_type,
    content_category,
    impressions,
    total_engagement,
    ROUND(engagement_rate_percent, 2) AS engagement_rate_percent
FROM post_performance
WHERE impressions >= 50000
  AND engagement_rate_percent < 1.0
ORDER BY impressions DESC;

-- 8. Find posts with low impressions but high engagement rate.
-- These posts may be good content that needs better distribution.
WITH post_performance AS (
    SELECT
        p.post_id,
        a.account_name,
        p.content_type,
        p.content_category,
        pm.impressions,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0) AS engagement_rate_percent
    FROM posts AS p
    JOIN accounts AS a
        ON p.account_id = a.account_id
    JOIN post_metrics AS pm
        ON p.post_id = pm.post_id
)
SELECT
    post_id,
    account_name,
    content_type,
    content_category,
    impressions,
    total_engagement,
    ROUND(engagement_rate_percent, 2) AS engagement_rate_percent
FROM post_performance
WHERE impressions <= 2000
  AND engagement_rate_percent >= 20.0
ORDER BY engagement_rate_percent DESC;

-- 9. Find posts with the most saves.
SELECT
    p.post_id,
    a.account_name,
    p.content_category,
    pm.saves
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY pm.saves DESC
LIMIT 10;

-- 10. Find posts with the most shares.
SELECT
    p.post_id,
    a.account_name,
    p.content_category,
    pm.shares
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY pm.shares DESC
LIMIT 10;

-- 11. Find posts with the most comments.
SELECT
    p.post_id,
    a.account_name,
    p.content_category,
    pm.comments_count
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY pm.comments_count DESC
LIMIT 10;

-- 12. Calculate average engagement by content type.
SELECT
    p.content_type,
    ROUND(AVG(pm.likes + pm.comments_count + pm.shares + pm.saves), 2) AS avg_engagement
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY p.content_type
ORDER BY avg_engagement DESC;

-- 13. Calculate average engagement rate by content type.
SELECT
    p.content_type,
    ROUND(
        AVG(
            (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0)
        ),
        2
    ) AS avg_engagement_rate_percent
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY p.content_type
ORDER BY avg_engagement_rate_percent DESC;

-- 14. Calculate average engagement by content category.
SELECT
    p.content_category,
    ROUND(AVG(pm.likes + pm.comments_count + pm.shares + pm.saves), 2) AS avg_engagement
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY p.content_category
ORDER BY avg_engagement DESC;

-- 15. Calculate average engagement rate by content category.
SELECT
    p.content_category,
    ROUND(
        AVG(
            (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0)
        ),
        2
    ) AS avg_engagement_rate_percent
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY p.content_category
ORDER BY avg_engagement_rate_percent DESC;

-- 16. Rank content categories by total engagement.
SELECT
    p.content_category,
    SUM(pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
    RANK() OVER (
        ORDER BY SUM(pm.likes + pm.comments_count + pm.shares + pm.saves) DESC
    ) AS engagement_rank
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY p.content_category
ORDER BY engagement_rank;

-- 17. Find best posting days by average engagement.
SELECT
    TRIM(TO_CHAR(p.post_date, 'Day')) AS posting_day,
    ROUND(AVG(pm.likes + pm.comments_count + pm.shares + pm.saves), 2) AS avg_engagement
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY TRIM(TO_CHAR(p.post_date, 'Day'))
ORDER BY avg_engagement DESC;

-- 18. Find best posting hours by average engagement.
SELECT
    EXTRACT(HOUR FROM p.post_time) AS posting_hour,
    ROUND(AVG(pm.likes + pm.comments_count + pm.shares + pm.saves), 2) AS avg_engagement
FROM posts AS p
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY EXTRACT(HOUR FROM p.post_time)
ORDER BY avg_engagement DESC;

-- 19. Calculate daily post volume.
SELECT
    post_date,
    COUNT(*) AS total_posts
FROM posts
GROUP BY post_date
ORDER BY post_date;

-- 20. Calculate monthly post volume.
SELECT
    DATE_TRUNC('month', post_date)::date AS post_month,
    COUNT(*) AS total_posts
FROM posts
GROUP BY DATE_TRUNC('month', post_date)::date
ORDER BY post_month;

-- 21. Calculate follower growth by account.
-- Follower growth = latest follower_count - earliest follower_count.
WITH ranked_snapshots AS (
    SELECT
        fd.account_id,
        fd.snapshot_date,
        fd.follower_count,
        ROW_NUMBER() OVER (
            PARTITION BY fd.account_id
            ORDER BY fd.snapshot_date ASC
        ) AS first_row,
        ROW_NUMBER() OVER (
            PARTITION BY fd.account_id
            ORDER BY fd.snapshot_date DESC
        ) AS latest_row
    FROM followers_daily AS fd
),
growth AS (
    SELECT
        account_id,
        MAX(CASE WHEN first_row = 1 THEN snapshot_date END) AS first_snapshot_date,
        MAX(CASE WHEN latest_row = 1 THEN snapshot_date END) AS latest_snapshot_date,
        MAX(CASE WHEN first_row = 1 THEN follower_count END) AS starting_followers,
        MAX(CASE WHEN latest_row = 1 THEN follower_count END) AS latest_followers
    FROM ranked_snapshots
    GROUP BY account_id
)
SELECT
    a.account_name,
    a.platform,
    g.first_snapshot_date,
    g.latest_snapshot_date,
    g.starting_followers,
    g.latest_followers,
    (g.latest_followers - g.starting_followers) AS follower_growth
FROM growth AS g
JOIN accounts AS a
    ON g.account_id = a.account_id
ORDER BY follower_growth DESC;

-- 22. Calculate follower growth rate by account.
-- Follower growth rate = follower growth / starting followers.
WITH ranked_snapshots AS (
    SELECT
        fd.account_id,
        fd.snapshot_date,
        fd.follower_count,
        ROW_NUMBER() OVER (
            PARTITION BY fd.account_id
            ORDER BY fd.snapshot_date ASC
        ) AS first_row,
        ROW_NUMBER() OVER (
            PARTITION BY fd.account_id
            ORDER BY fd.snapshot_date DESC
        ) AS latest_row
    FROM followers_daily AS fd
),
growth AS (
    SELECT
        account_id,
        MAX(CASE WHEN first_row = 1 THEN follower_count END) AS starting_followers,
        MAX(CASE WHEN latest_row = 1 THEN follower_count END) AS latest_followers
    FROM ranked_snapshots
    GROUP BY account_id
)
SELECT
    a.account_name,
    a.platform,
    g.starting_followers,
    g.latest_followers,
    (g.latest_followers - g.starting_followers) AS follower_growth,
    ROUND(
        (g.latest_followers - g.starting_followers) * 100.0
        / NULLIF(g.starting_followers, 0),
        2
    ) AS follower_growth_rate_percent
FROM growth AS g
JOIN accounts AS a
    ON g.account_id = a.account_id
ORDER BY follower_growth_rate_percent DESC;

-- 23. Find accounts with strongest follower growth.
WITH follower_growth AS (
    SELECT
        fd.account_id,
        MIN(fd.follower_count) FILTER (
            WHERE fd.snapshot_date = (
                SELECT MIN(fd2.snapshot_date)
                FROM followers_daily AS fd2
                WHERE fd2.account_id = fd.account_id
            )
        ) AS starting_followers,
        MAX(fd.follower_count) FILTER (
            WHERE fd.snapshot_date = (
                SELECT MAX(fd3.snapshot_date)
                FROM followers_daily AS fd3
                WHERE fd3.account_id = fd.account_id
            )
        ) AS latest_followers
    FROM followers_daily AS fd
    GROUP BY fd.account_id
)
SELECT
    a.account_name,
    a.platform,
    (fg.latest_followers - fg.starting_followers) AS follower_growth
FROM follower_growth AS fg
JOIN accounts AS a
    ON fg.account_id = a.account_id
ORDER BY follower_growth DESC
LIMIT 5;

-- 24. Find accounts with flat or declining follower growth.
WITH follower_growth AS (
    SELECT
        account_id,
        FIRST_VALUE(follower_count) OVER (
            PARTITION BY account_id
            ORDER BY snapshot_date
        ) AS starting_followers,
        LAST_VALUE(follower_count) OVER (
            PARTITION BY account_id
            ORDER BY snapshot_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS latest_followers
    FROM followers_daily
),
account_growth AS (
    SELECT DISTINCT
        account_id,
        starting_followers,
        latest_followers,
        latest_followers - starting_followers AS follower_growth
    FROM follower_growth
)
SELECT
    a.account_name,
    a.platform,
    ag.starting_followers,
    ag.latest_followers,
    ag.follower_growth
FROM account_growth AS ag
JOIN accounts AS a
    ON ag.account_id = a.account_id
WHERE ag.follower_growth <= 100
ORDER BY ag.follower_growth;

-- 25. Calculate campaign performance by total engagement.
SELECT
    c.campaign_name,
    c.campaign_goal,
    COUNT(p.post_id) AS total_posts,
    COALESCE(SUM(pm.likes + pm.comments_count + pm.shares + pm.saves), 0) AS total_engagement
FROM campaigns AS c
LEFT JOIN posts AS p
    ON c.campaign_id = p.campaign_id
LEFT JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY c.campaign_id, c.campaign_name, c.campaign_goal
ORDER BY total_engagement DESC;

-- 26. Calculate campaign performance by engagement rate.
SELECT
    c.campaign_name,
    c.campaign_goal,
    COUNT(p.post_id) AS total_posts,
    ROUND(
        SUM(pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
        / NULLIF(SUM(pm.impressions), 0),
        2
    ) AS campaign_engagement_rate_percent
FROM campaigns AS c
LEFT JOIN posts AS p
    ON c.campaign_id = p.campaign_id
LEFT JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY c.campaign_id, c.campaign_name, c.campaign_goal
ORDER BY campaign_engagement_rate_percent DESC NULLS LAST;

-- 27. Find best campaigns by follower growth during campaign period.
-- This compares follower counts for accounts that posted under each campaign.
WITH campaign_accounts AS (
    SELECT DISTINCT
        p.campaign_id,
        p.account_id
    FROM posts AS p
    WHERE p.campaign_id IS NOT NULL
),
campaign_snapshots AS (
    SELECT
        c.campaign_id,
        ca.account_id,
        fd.snapshot_date,
        fd.follower_count,
        ROW_NUMBER() OVER (
            PARTITION BY c.campaign_id, ca.account_id
            ORDER BY fd.snapshot_date
        ) AS first_row,
        ROW_NUMBER() OVER (
            PARTITION BY c.campaign_id, ca.account_id
            ORDER BY fd.snapshot_date DESC
        ) AS latest_row
    FROM campaigns AS c
    JOIN campaign_accounts AS ca
        ON c.campaign_id = ca.campaign_id
    JOIN followers_daily AS fd
        ON ca.account_id = fd.account_id
       AND fd.snapshot_date BETWEEN c.start_date AND COALESCE(c.end_date, CURRENT_DATE)
),
campaign_growth AS (
    SELECT
        campaign_id,
        account_id,
        MAX(CASE WHEN first_row = 1 THEN follower_count END) AS starting_followers,
        MAX(CASE WHEN latest_row = 1 THEN follower_count END) AS latest_followers
    FROM campaign_snapshots
    GROUP BY campaign_id, account_id
)
SELECT
    c.campaign_name,
    SUM(cg.latest_followers - cg.starting_followers) AS estimated_follower_growth
FROM campaign_growth AS cg
JOIN campaigns AS c
    ON cg.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.campaign_name
ORDER BY estimated_follower_growth DESC;

-- 28. Find most used hashtags.
SELECT
    h.hashtag_text,
    COUNT(ph.post_id) AS usage_count
FROM hashtags AS h
JOIN post_hashtags AS ph
    ON h.hashtag_id = ph.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_text
ORDER BY usage_count DESC, h.hashtag_text;

-- 29. Find hashtags with highest average engagement.
SELECT
    h.hashtag_text,
    COUNT(DISTINCT p.post_id) AS post_count,
    ROUND(AVG(pm.likes + pm.comments_count + pm.shares + pm.saves), 2) AS avg_engagement
FROM hashtags AS h
JOIN post_hashtags AS ph
    ON h.hashtag_id = ph.hashtag_id
JOIN posts AS p
    ON ph.post_id = p.post_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
GROUP BY h.hashtag_id, h.hashtag_text
HAVING COUNT(DISTINCT p.post_id) >= 3
ORDER BY avg_engagement DESC;

-- 30. Find posts with negative sentiment comments.
SELECT
    p.post_id,
    a.account_name,
    p.content_category,
    COUNT(c.comment_id) AS negative_comment_count
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN comments AS c
    ON p.post_id = c.post_id
WHERE c.sentiment = 'negative'
GROUP BY p.post_id, a.account_name, p.content_category
ORDER BY negative_comment_count DESC, p.post_id;

-- 31. Count comments by sentiment.
SELECT
    sentiment,
    COUNT(*) AS comment_count
FROM comments
GROUP BY sentiment
ORDER BY comment_count DESC;

-- 32. Calculate profile click rate and link click rate.
-- Profile click rate = profile_clicks / impressions.
-- Link click rate = link_clicks / impressions.
SELECT
    p.post_id,
    a.account_name,
    pm.impressions,
    pm.profile_clicks,
    pm.link_clicks,
    ROUND(pm.profile_clicks * 100.0 / NULLIF(pm.impressions, 0), 2) AS profile_click_rate_percent,
    ROUND(pm.link_clicks * 100.0 / NULLIF(pm.impressions, 0), 2) AS link_click_rate_percent
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY link_click_rate_percent DESC;

-- 33. Build a content performance dashboard view using SQL.
WITH content_dashboard AS (
    SELECT
        p.post_id,
        a.account_name,
        a.platform,
        c.campaign_name,
        p.post_date,
        p.post_time,
        p.content_type,
        p.content_category,
        pm.impressions,
        pm.views,
        pm.likes,
        pm.comments_count,
        pm.shares,
        pm.saves,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0) AS engagement_rate_percent,
        pm.profile_clicks,
        pm.link_clicks,
        pm.profile_clicks * 100.0 / NULLIF(pm.impressions, 0) AS profile_click_rate_percent,
        pm.link_clicks * 100.0 / NULLIF(pm.impressions, 0) AS link_click_rate_percent
    FROM posts AS p
    JOIN accounts AS a
        ON p.account_id = a.account_id
    LEFT JOIN campaigns AS c
        ON p.campaign_id = c.campaign_id
    JOIN post_metrics AS pm
        ON p.post_id = pm.post_id
)
SELECT
    post_id,
    account_name,
    platform,
    campaign_name,
    post_date,
    post_time,
    content_type,
    content_category,
    impressions,
    views,
    likes,
    comments_count,
    shares,
    saves,
    total_engagement,
    ROUND(engagement_rate_percent, 2) AS engagement_rate_percent,
    profile_clicks,
    link_clicks,
    ROUND(profile_click_rate_percent, 2) AS profile_click_rate_percent,
    ROUND(link_click_rate_percent, 2) AS link_click_rate_percent,
    CASE
        WHEN impressions >= 50000 AND engagement_rate_percent < 1 THEN 'high_reach_low_engagement'
        WHEN saves >= 500 THEN 'strong_saves'
        WHEN shares >= 500 THEN 'strong_shares'
        WHEN engagement_rate_percent >= 10 THEN 'high_engagement'
        ELSE 'needs_improvement'
    END AS performance_status
FROM content_dashboard
ORDER BY total_engagement DESC;

-- 34. Build an account growth dashboard view using SQL.
WITH account_followers AS (
    SELECT
        fd.account_id,
        fd.snapshot_date,
        fd.follower_count,
        ROW_NUMBER() OVER (
            PARTITION BY fd.account_id
            ORDER BY fd.snapshot_date
        ) AS first_row,
        ROW_NUMBER() OVER (
            PARTITION BY fd.account_id
            ORDER BY fd.snapshot_date DESC
        ) AS latest_row
    FROM followers_daily AS fd
),
growth AS (
    SELECT
        account_id,
        MAX(CASE WHEN first_row = 1 THEN snapshot_date END) AS first_snapshot_date,
        MAX(CASE WHEN latest_row = 1 THEN snapshot_date END) AS latest_snapshot_date,
        MAX(CASE WHEN first_row = 1 THEN follower_count END) AS starting_followers,
        MAX(CASE WHEN latest_row = 1 THEN follower_count END) AS latest_followers
    FROM account_followers
    GROUP BY account_id
),
post_summary AS (
    SELECT
        p.account_id,
        COUNT(p.post_id) AS total_posts,
        AVG(
            (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0)
        ) AS avg_engagement_rate_percent
    FROM posts AS p
    JOIN post_metrics AS pm
        ON p.post_id = pm.post_id
    GROUP BY p.account_id
)
SELECT
    a.account_id,
    a.account_name,
    a.platform,
    a.account_type,
    g.first_snapshot_date,
    g.latest_snapshot_date,
    g.starting_followers,
    g.latest_followers,
    (g.latest_followers - g.starting_followers) AS follower_growth,
    ROUND(
        (g.latest_followers - g.starting_followers) * 100.0
        / NULLIF(g.starting_followers, 0),
        2
    ) AS follower_growth_rate_percent,
    COALESCE(ps.total_posts, 0) AS total_posts,
    ROUND(COALESCE(ps.avg_engagement_rate_percent, 0), 2) AS avg_engagement_rate_percent,
    CASE
        WHEN (g.latest_followers - g.starting_followers) * 100.0
             / NULLIF(g.starting_followers, 0) >= 10 THEN 'strong_growth'
        WHEN (g.latest_followers - g.starting_followers) > 100 THEN 'moderate_growth'
        WHEN (g.latest_followers - g.starting_followers) < 0 THEN 'declining'
        ELSE 'flat_growth'
    END AS growth_status
FROM growth AS g
JOIN accounts AS a
    ON g.account_id = a.account_id
LEFT JOIN post_summary AS ps
    ON a.account_id = ps.account_id
ORDER BY follower_growth DESC;

-- 35. Create content strategy recommendations using CASE WHEN.
WITH post_performance AS (
    SELECT
        p.post_id,
        a.account_name,
        p.content_type,
        p.content_category,
        pm.impressions,
        pm.likes,
        pm.comments_count,
        pm.shares,
        pm.saves,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
        (pm.likes + pm.comments_count + pm.shares + pm.saves) * 100.0
            / NULLIF(pm.impressions, 0) AS engagement_rate_percent
    FROM posts AS p
    JOIN accounts AS a
        ON p.account_id = a.account_id
    JOIN post_metrics AS pm
        ON p.post_id = pm.post_id
)
SELECT
    post_id,
    account_name,
    content_type,
    content_category,
    impressions,
    total_engagement,
    ROUND(engagement_rate_percent, 2) AS engagement_rate_percent,
    CASE
        WHEN content_category = 'education' AND engagement_rate_percent >= 5 THEN 'Create more educational posts'
        WHEN impressions >= 50000 AND engagement_rate_percent < 1 THEN 'Improve hook or CTA'
        WHEN saves >= 500 THEN 'Repurpose high-save posts'
        WHEN comments_count >= 300 THEN 'Turn strong comments into follow-up content'
        WHEN post_id IN (
            SELECT DISTINCT post_id
            FROM comments
            WHERE sentiment = 'negative'
        ) THEN 'Review negative feedback'
        ELSE 'Continue current strategy'
    END AS recommended_content_action
FROM post_performance
ORDER BY total_engagement DESC;

-- Extra dashboard helper: rank posts inside each account by engagement.
SELECT
    a.account_name,
    p.post_id,
    p.content_category,
    (pm.likes + pm.comments_count + pm.shares + pm.saves) AS total_engagement,
    DENSE_RANK() OVER (
        PARTITION BY a.account_id
        ORDER BY (pm.likes + pm.comments_count + pm.shares + pm.saves) DESC
    ) AS account_engagement_rank
FROM posts AS p
JOIN accounts AS a
    ON p.account_id = a.account_id
JOIN post_metrics AS pm
    ON p.post_id = pm.post_id
ORDER BY a.account_name, account_engagement_rank;

-- Extra trend helper: compare each follower snapshot with the previous day.
SELECT
    a.account_name,
    fd.snapshot_date,
    fd.follower_count,
    LAG(fd.follower_count) OVER (
        PARTITION BY fd.account_id
        ORDER BY fd.snapshot_date
    ) AS previous_follower_count,
    fd.follower_count - LAG(fd.follower_count) OVER (
        PARTITION BY fd.account_id
        ORDER BY fd.snapshot_date
    ) AS daily_follower_change
FROM followers_daily AS fd
JOIN accounts AS a
    ON fd.account_id = a.account_id
ORDER BY a.account_name, fd.snapshot_date;

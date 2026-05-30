-- Day 20 - Social Media Engagement Analysis
-- PostgreSQL sample data

INSERT INTO accounts (account_id, account_name, platform, account_type, city)
VALUES
    (1, 'Yangon Data Journal', 'linkedin', 'creator', 'Yangon'),
    (2, 'Mandalay Market Hub', 'facebook', 'brand', 'Mandalay'),
    (3, 'Naypyidaw Tech School', 'youtube', 'company', 'Naypyidaw'),
    (4, 'Bago Home Studio', 'instagram', 'brand', 'Bago'),
    (5, 'Taunggyi Travel Notes', 'tiktok', 'creator', 'Taunggyi'),
    (6, 'Mawlamyine Career Lab', 'linkedin', 'company', 'Mawlamyine'),
    (7, 'Pathein Food Diary', 'x', 'personal', 'Pathein'),
    (8, 'Monywa Startup Voice', 'facebook', 'creator', 'Monywa');

INSERT INTO campaigns (campaign_id, campaign_name, campaign_goal, start_date, end_date, campaign_status)
VALUES
    (1, 'SQL Learning Sprint', 'engagement', '2026-04-01', '2026-04-30', 'completed'),
    (2, 'Summer Product Launch', 'product_launch', '2026-04-05', '2026-05-05', 'active'),
    (3, 'Creator Growth Month', 'community_growth', '2026-04-10', '2026-05-10', 'active'),
    (4, 'Career Webinar Leads', 'lead_generation', '2026-04-15', '2026-05-15', 'active'),
    (5, 'Brand Awareness Push', 'awareness', '2026-03-20', '2026-04-20', 'completed'),
    (6, 'Local Food Stories', 'engagement', '2026-04-12', '2026-05-02', 'paused'),
    (7, 'Travel Short Video Test', 'awareness', '2026-04-18', '2026-05-08', 'active'),
    (8, 'Old Campaign Cleanup', 'lead_generation', '2026-03-01', '2026-03-21', 'cancelled');

INSERT INTO followers_daily (
    account_id,
    snapshot_date,
    follower_count,
    following_count
)
SELECT
    account_id,
    DATE '2026-04-20' + (day_number - 1),
    CASE account_id
        WHEN 1 THEN 12000 + (day_number * 130)
        WHEN 2 THEN 8500 + (day_number * 40)
        WHEN 3 THEN 18000 + (day_number * 95)
        WHEN 4 THEN 6200 + (day_number * 5)
        WHEN 5 THEN 25500 - (day_number * 25)
        WHEN 6 THEN 9400 + (day_number * 75)
        WHEN 7 THEN 4100
        WHEN 8 THEN 7600 + (day_number * 110)
    END AS follower_count,
    CASE account_id
        WHEN 1 THEN 620
        WHEN 2 THEN 540
        WHEN 3 THEN 310
        WHEN 4 THEN 880
        WHEN 5 THEN 430
        WHEN 6 THEN 520
        WHEN 7 THEN 390
        WHEN 8 THEN 670
    END AS following_count
FROM generate_series(1, 8) AS accounts(account_id)
CROSS JOIN generate_series(1, 15) AS days(day_number);

INSERT INTO hashtags (hashtag_id, hashtag_text)
VALUES
    (1, '#SQLLearning'),
    (2, '#DataAnalytics'),
    (3, '#MyanmarBusiness'),
    (4, '#ContentStrategy'),
    (5, '#CreatorGrowth'),
    (6, '#MarketingAnalytics'),
    (7, '#LinkedInLearning'),
    (8, '#SmallBusiness'),
    (9, '#ProductLaunch'),
    (10, '#Education'),
    (11, '#CareerGrowth'),
    (12, '#DigitalMarketing'),
    (13, '#FoodStories'),
    (14, '#TravelMyanmar'),
    (15, '#TechEducation'),
    (16, '#StartupMyanmar'),
    (17, '#CommunityBuilding'),
    (18, '#CaseStudy'),
    (19, '#Tutorial'),
    (20, '#BehindTheScenes'),
    (21, '#BrandAwareness'),
    (22, '#SocialMediaTips'),
    (23, '#CustomerInsights'),
    (24, '#DataEngineering'),
    (25, '#BusinessGrowth');

INSERT INTO posts (
    post_id,
    account_id,
    campaign_id,
    post_date,
    post_time,
    content_type,
    content_category,
    post_caption
)
SELECT
    post_number,
    ((post_number - 1) % 8) + 1 AS account_id,
    ((post_number - 1) % 8) + 1 AS campaign_id,
    DATE '2026-04-21' + ((post_number - 1) % 20) AS post_date,
    TIME '07:00' + (((post_number - 1) % 12) * INTERVAL '1 hour') AS post_time,
    CASE ((post_number - 1) % 7)
        WHEN 0 THEN 'text'
        WHEN 1 THEN 'image'
        WHEN 2 THEN 'carousel'
        WHEN 3 THEN 'video'
        WHEN 4 THEN 'short_video'
        WHEN 5 THEN 'article'
        ELSE 'poll'
    END AS content_type,
    CASE ((post_number - 1) % 9)
        WHEN 0 THEN 'education'
        WHEN 1 THEN 'storytelling'
        WHEN 2 THEN 'case_study'
        WHEN 3 THEN 'behind_the_scenes'
        WHEN 4 THEN 'product'
        WHEN 5 THEN 'personal_journey'
        WHEN 6 THEN 'tutorial'
        WHEN 7 THEN 'opinion'
        ELSE 'announcement'
    END AS content_category,
    'Fictional social media post ' || post_number || ' for content performance analysis.' AS post_caption
FROM generate_series(1, 80) AS posts(post_number);

INSERT INTO post_metrics (
    post_id,
    metric_date,
    impressions,
    views,
    likes,
    comments_count,
    shares,
    saves,
    profile_clicks,
    link_clicks
)
SELECT
    post_id,
    post_date + 1 AS metric_date,
    CASE
        WHEN post_id IN (3, 16, 29, 52) THEN 95000
        WHEN post_id IN (7, 22, 45, 64) THEN 1200
        ELSE 5000 + (post_id * 280)
    END AS impressions,
    CASE
        WHEN post_id IN (3, 16, 29, 52) THEN 42000
        WHEN post_id IN (7, 22, 45, 64) THEN 900
        ELSE 2800 + (post_id * 130)
    END AS views,
    CASE
        WHEN post_id IN (3, 16, 29, 52) THEN 90
        WHEN post_id IN (7, 22, 45, 64) THEN 310
        WHEN post_id IN (10, 33, 58) THEN 1200
        ELSE 120 + (post_id * 9)
    END AS likes,
    CASE
        WHEN post_id IN (15, 55) THEN 470
        WHEN post_id IN (3, 16, 29, 52) THEN 8
        WHEN post_id IN (7, 22, 45, 64) THEN 95
        ELSE 15 + (post_id % 45)
    END AS comments_count,
    CASE
        WHEN post_id IN (12, 40, 61) THEN 620
        WHEN post_id IN (3, 16, 29, 52) THEN 4
        WHEN post_id IN (7, 22, 45, 64) THEN 85
        ELSE 12 + (post_id % 35)
    END AS shares,
    CASE
        WHEN post_id IN (10, 33, 58) THEN 760
        WHEN post_id IN (3, 16, 29, 52) THEN 3
        WHEN post_id IN (7, 22, 45, 64) THEN 115
        ELSE 20 + (post_id % 50)
    END AS saves,
    CASE
        WHEN post_id IN (7, 22, 45, 64) THEN 180
        ELSE 30 + (post_id % 90)
    END AS profile_clicks,
    CASE
        WHEN post_id IN (10, 33, 58) THEN 220
        ELSE 10 + (post_id % 70)
    END AS link_clicks
FROM posts;

INSERT INTO comments (
    post_id,
    commenter_name,
    comment_text,
    comment_date,
    sentiment
)
SELECT
    ((comment_number - 1) % 80) + 1 AS post_id,
    'Audience Member ' || comment_number AS commenter_name,
    CASE
        WHEN comment_number % 10 = 0 THEN 'This could be clearer for beginners.'
        WHEN comment_number % 3 = 0 THEN 'Useful idea, I want to compare it with my own content.'
        ELSE 'This is practical and easy to understand.'
    END AS comment_text,
    DATE '2026-04-22' + ((comment_number - 1) % 20) AS comment_date,
    CASE
        WHEN comment_number % 10 = 0 THEN 'negative'
        WHEN comment_number % 3 = 0 THEN 'neutral'
        ELSE 'positive'
    END AS sentiment
FROM generate_series(1, 160) AS comments(comment_number);

INSERT INTO post_hashtags (post_id, hashtag_id)
SELECT
    post_id,
    hashtag_id
FROM (
    SELECT
        post_id,
        ((post_id + (offset_number * 7) - 1) % 25) + 1 AS hashtag_id
    FROM generate_series(1, 80) AS posts(post_id)
    CROSS JOIN generate_series(1, 3) AS offsets(offset_number)
) AS hashtag_pairs
ORDER BY post_id, hashtag_id
LIMIT 180;

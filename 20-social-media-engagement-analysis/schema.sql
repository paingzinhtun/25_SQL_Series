-- Day 20 - Social Media Engagement Analysis
-- PostgreSQL schema

DROP TABLE IF EXISTS post_hashtags;
DROP TABLE IF EXISTS hashtags;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS post_metrics;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS followers_daily;
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    account_name VARCHAR(120) NOT NULL UNIQUE,
    platform VARCHAR(30) NOT NULL
        CHECK (platform IN ('linkedin', 'facebook', 'instagram', 'tiktok', 'youtube', 'x')),
    account_type VARCHAR(30) NOT NULL
        CHECK (account_type IN ('creator', 'brand', 'company', 'personal')),
    city VARCHAR(80) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE followers_daily (
    follower_snapshot_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    snapshot_date DATE NOT NULL,
    follower_count INTEGER NOT NULL CHECK (follower_count >= 0),
    following_count INTEGER NOT NULL CHECK (following_count >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_followers_daily_account
        FOREIGN KEY (account_id)
        REFERENCES accounts (account_id),
    CONSTRAINT uq_followers_account_date
        UNIQUE (account_id, snapshot_date)
);

CREATE TABLE campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(120) NOT NULL UNIQUE,
    campaign_goal VARCHAR(40) NOT NULL
        CHECK (campaign_goal IN ('awareness', 'engagement', 'lead_generation', 'community_growth', 'product_launch')),
    start_date DATE NOT NULL,
    end_date DATE,
    campaign_status VARCHAR(30) NOT NULL
        CHECK (campaign_status IN ('active', 'completed', 'paused', 'cancelled')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_campaign_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    campaign_id INTEGER,
    post_date DATE NOT NULL,
    post_time TIME NOT NULL,
    content_type VARCHAR(30) NOT NULL
        CHECK (content_type IN ('text', 'image', 'carousel', 'video', 'short_video', 'article', 'poll')),
    content_category VARCHAR(40) NOT NULL
        CHECK (
            content_category IN (
                'education',
                'storytelling',
                'case_study',
                'behind_the_scenes',
                'product',
                'personal_journey',
                'tutorial',
                'opinion',
                'announcement'
            )
        ),
    post_caption TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_account
        FOREIGN KEY (account_id)
        REFERENCES accounts (account_id),
    CONSTRAINT fk_posts_campaign
        FOREIGN KEY (campaign_id)
        REFERENCES campaigns (campaign_id)
);

CREATE TABLE post_metrics (
    metric_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL UNIQUE,
    metric_date DATE NOT NULL,
    impressions INTEGER NOT NULL CHECK (impressions >= 0),
    views INTEGER NOT NULL CHECK (views >= 0),
    likes INTEGER NOT NULL CHECK (likes >= 0),
    comments_count INTEGER NOT NULL CHECK (comments_count >= 0),
    shares INTEGER NOT NULL CHECK (shares >= 0),
    saves INTEGER NOT NULL CHECK (saves >= 0),
    profile_clicks INTEGER NOT NULL CHECK (profile_clicks >= 0),
    link_clicks INTEGER NOT NULL CHECK (link_clicks >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_post_metrics_post
        FOREIGN KEY (post_id)
        REFERENCES posts (post_id)
);

CREATE TABLE comments (
    comment_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL,
    commenter_name VARCHAR(80) NOT NULL,
    comment_text TEXT NOT NULL,
    comment_date DATE NOT NULL,
    sentiment VARCHAR(20) NOT NULL
        CHECK (sentiment IN ('positive', 'neutral', 'negative')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_post
        FOREIGN KEY (post_id)
        REFERENCES posts (post_id)
);

CREATE TABLE hashtags (
    hashtag_id SERIAL PRIMARY KEY,
    hashtag_text VARCHAR(80) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_hashtags (
    post_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    CONSTRAINT pk_post_hashtags
        PRIMARY KEY (post_id, hashtag_id),
    CONSTRAINT fk_post_hashtags_post
        FOREIGN KEY (post_id)
        REFERENCES posts (post_id),
    CONSTRAINT fk_post_hashtags_hashtag
        FOREIGN KEY (hashtag_id)
        REFERENCES hashtags (hashtag_id)
);

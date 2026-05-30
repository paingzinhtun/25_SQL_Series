# Day 20 — Social Media Engagement Analysis

## Project Overview

This project is part of the **25 Days of SQL for Real Business Data Systems** series.

The goal is to build a beginner-friendly but professional SQL project for analyzing social media content performance. It shows how creators, brands, marketing teams, and companies can use SQL to understand posts, engagement, followers, campaigns, hashtags, comments, and audience growth.

This project is not about chasing vanity metrics. Views and likes are useful, but they are only part of the story. Better content analytics connects reach, engagement, clicks, saves, shares, follower growth, and campaign goals.

## Business Problem

A creator, brand, or company wants to understand which social media content performs best.

The business wants to answer questions such as:

- Which posts received the most engagement?
- Which content categories perform best?
- Which posting days or times work best?
- Which posts generated the most saves or shares?
- Which accounts are growing fastest?
- What is the engagement rate by post?
- What is the follower growth trend?
- Which hashtags are associated with high engagement?
- Which campaigns generated the best content performance?
- What type of content should we create more of?

## Database Tables

| Table | Purpose |
|---|---|
| `accounts` | Stores social media accounts, platforms, account types, and cities. |
| `followers_daily` | Stores daily follower snapshots for each account. |
| `campaigns` | Stores campaign names, goals, dates, and status. |
| `posts` | Stores published content, content type, category, date, time, and caption. |
| `post_metrics` | Stores impressions, views, likes, comments, shares, saves, and clicks. |
| `comments` | Stores audience comments and simple sentiment labels. |
| `hashtags` | Stores reusable hashtag values. |
| `post_hashtags` | Bridge table connecting posts and hashtags. |

## Entity Relationship Explanation

One account can publish many posts.

One campaign can include many posts.

One post has one metrics record in this simplified project.

One post can have many comments.

One post can use many hashtags, and one hashtag can appear on many posts. This many-to-many relationship is modeled using the `post_hashtags` bridge table.

Follower counts are stored as daily snapshots in `followers_daily`, which makes it possible to calculate follower growth over time.

## Engagement Logic Explanation

In this project:

```sql
total_engagement = likes + comments_count + shares + saves
```

Engagement rate is calculated as:

```sql
engagement_rate = total_engagement / impressions
```

The queries multiply by `100.0` to show the result as a percentage.

`NULLIF(impressions, 0)` is used to avoid division by zero.

## Follower Growth Logic Explanation

Follower growth is calculated by comparing the latest follower snapshot with the earliest follower snapshot:

```sql
follower_growth = latest_followers - starting_followers
```

Follower growth rate is calculated as:

```sql
follower_growth_rate = follower_growth / starting_followers
```

This helps compare small and large accounts more fairly.

## Hashtag Performance Logic

Hashtag performance is analyzed by connecting:

- `hashtags`
- `post_hashtags`
- `posts`
- `post_metrics`

This helps answer:

- Which hashtags are used most often?
- Which hashtags appear on high-engagement posts?

The goal is not to claim that a hashtag caused performance, but to identify useful patterns.

## Campaign Performance Logic

Campaign performance is measured using:

- number of posts
- total engagement
- campaign engagement rate
- estimated follower growth during the campaign period

This helps connect content strategy with campaign goals such as awareness, engagement, lead generation, product launch, or community growth.

## Content Dashboard View Explanation

The content dashboard query combines post-level metrics into one reporting view:

- post information
- account and platform
- campaign
- impressions and views
- likes, comments, shares, and saves
- total engagement
- engagement rate
- profile click rate
- link click rate
- performance status

Example performance statuses:

- `high_engagement`
- `high_reach_low_engagement`
- `strong_saves`
- `strong_shares`
- `needs_improvement`

## Account Growth Dashboard View Explanation

The account growth dashboard query shows:

- starting followers
- latest followers
- follower growth
- follower growth rate
- total posts
- average engagement rate
- growth status

Example growth statuses:

- `strong_growth`
- `moderate_growth`
- `flat_growth`
- `declining`

## Content Strategy Recommendations

The final recommendation query uses `CASE WHEN` logic to translate metrics into actions.

Examples:

- Create more educational posts
- Improve hook or CTA
- Repurpose high-save posts
- Turn strong comments into follow-up content
- Review negative feedback
- Continue current strategy

This is simple rule-based analytics, not an AI recommendation system.

## SQL Concepts Practiced

- `SELECT`
- `WHERE`
- `JOIN`
- `LEFT JOIN`
- `GROUP BY`
- `HAVING`
- `ORDER BY`
- `CASE WHEN`
- CTEs
- Window functions
- `ROW_NUMBER`
- `RANK`
- `DENSE_RANK`
- `LAG`
- Date functions
- Time functions
- Rate calculations
- `NULLIF`
- `COALESCE`
- Bridge tables
- Dashboard-style SQL reporting

## Business Questions Answered

- Which posts received the most engagement?
- Which posts had the best engagement rate?
- Which high-reach posts had weak engagement?
- Which low-reach posts had strong engagement rate?
- Which posts generated the most saves?
- Which posts generated the most shares?
- Which content types perform best?
- Which content categories perform best?
- Which posting days and hours perform best?
- Which accounts gained the most followers?
- Which accounts are flat or declining?
- Which campaigns performed best?
- Which hashtags are used most often?
- Which hashtags are associated with high engagement?
- Which posts received negative sentiment comments?
- What are profile click and link click rates?
- What actions should the content team take next?

## Files in This Project

| File | Description |
|---|---|
| `schema.sql` | Creates all tables, keys, relationships, and constraints. |
| `insert_data.sql` | Inserts realistic fictional social media sample data. |
| `analysis_queries.sql` | Contains business and content analytics queries. |
| `business_questions.md` | Maps each question to business value and SQL concepts. |
| `README.md` | Explains the project, logic, and learning outcomes. |

## Key Lessons

Social media analytics is more useful when it connects content, audience behavior, and business goals.

High impressions do not always mean strong performance. A post can reach many people but still have weak engagement.

Saves, shares, comments, clicks, and follower growth help give a more complete view of content quality.

SQL is a strong foundation for marketing analytics, creator analytics, campaign reporting, and future Data + AI solutions.

## How to Run This Project

Run the files in this order using PostgreSQL:

```sql
-- 1. Create tables
\i schema.sql

-- 2. Insert sample data
\i insert_data.sql

-- 3. Run analysis queries
\i analysis_queries.sql
```

If you are using pgAdmin, open each file and run them in the same order.

## LinkedIn Reflection Draft

Day 20/25 — SQL for Real Business Data Systems

Today I built a Social Media Engagement Analysis project using SQL.

This project is useful for creators, brands, and businesses that want to understand content performance.

Social media analytics is not only about views or likes.

The better questions are:
- which posts create real engagement?
- which content categories work best?
- which posting times perform better?
- which posts get saved or shared?
- which hashtags are associated with high engagement?
- which campaigns perform well?
- which accounts are growing fastest?
- what content should we create more of?

For this project, I modeled:
- accounts
- followers_daily
- campaigns
- posts
- post_metrics
- comments
- hashtags
- post_hashtags

Then I wrote SQL queries to analyze:
- total engagement
- engagement rate
- top-performing posts
- high reach but low engagement posts
- content type performance
- content category performance
- best posting days and hours
- follower growth
- campaign performance
- hashtag performance
- comment sentiment
- profile click rate
- link click rate
- content performance dashboard
- account growth dashboard
- strategy recommendations

SQL concepts I practiced:
- joins
- left joins
- grouping
- aggregation
- CASE WHEN
- CTEs
- window functions
- LAG
- date/time analysis
- rate calculations
- dashboard view thinking

My key lesson:
Social media data becomes useful when we connect content, audience behavior, and business goals.

Views and likes are only surface metrics.

Better analytics helps us understand what content creates attention, trust, engagement, and growth.

This foundation is important for marketing analytics, creator analytics, Data Engineering, and future Data + AI solutions.

Feedback and suggestions are always welcome.

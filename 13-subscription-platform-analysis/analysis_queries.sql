-- Day 13 - Subscription-Based Platform Analysis
-- Analysis queries for PostgreSQL
--
-- Stable analysis date used in this project: 2026-05-08.
-- Revenue rule: count only payments where payment_status = 'paid'.
-- Active subscriber rule: count only subscriptions where subscription_status = 'active'.

-- 1. List all users.
SELECT
    user_id,
    first_name,
    last_name,
    email,
    city,
    signup_date
FROM users
ORDER BY signup_date, user_id;

-- 2. List all subscription plans.
SELECT
    plan_id,
    plan_name,
    billing_cycle,
    plan_tier,
    monthly_price
FROM subscription_plans
ORDER BY monthly_price, plan_id;

-- 3. Show all subscriptions with user and plan information.
SELECT
    s.subscription_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    sp.plan_name,
    sp.plan_tier,
    s.start_date,
    s.end_date,
    s.subscription_status,
    s.auto_renew
FROM subscriptions AS s
JOIN users AS u
    ON s.user_id = u.user_id
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
ORDER BY s.start_date, s.subscription_id;

-- 4. Show active subscriptions.
SELECT
    s.subscription_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    sp.plan_name,
    sp.monthly_price,
    s.start_date,
    s.auto_renew
FROM subscriptions AS s
JOIN users AS u
    ON s.user_id = u.user_id
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE s.subscription_status = 'active'
ORDER BY s.start_date;

-- 5. Count active subscribers.
-- Active subscribers are distinct users with at least one active subscription.
SELECT
    COUNT(DISTINCT user_id) AS active_subscribers
FROM subscriptions
WHERE subscription_status = 'active';

-- 6. Count subscriptions by status.
SELECT
    subscription_status,
    COUNT(*) AS total_subscriptions
FROM subscriptions
GROUP BY subscription_status
ORDER BY total_subscriptions DESC;

-- 7. Count active users by plan tier.
SELECT
    sp.plan_tier,
    COUNT(DISTINCT s.user_id) AS active_users
FROM subscriptions AS s
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE s.subscription_status = 'active'
GROUP BY sp.plan_tier
ORDER BY active_users DESC, sp.plan_tier;

-- 8. Calculate total revenue from paid payments.
SELECT
    SUM(amount) AS total_paid_revenue
FROM payments
WHERE payment_status = 'paid';

-- 9. Calculate revenue by subscription plan.
SELECT
    sp.plan_name,
    SUM(p.amount) AS total_paid_revenue
FROM payments AS p
JOIN subscriptions AS s
    ON p.subscription_id = s.subscription_id
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE p.payment_status = 'paid'
GROUP BY sp.plan_id, sp.plan_name
ORDER BY total_paid_revenue DESC;

-- 10. Calculate revenue by plan tier.
SELECT
    sp.plan_tier,
    SUM(p.amount) AS total_paid_revenue
FROM payments AS p
JOIN subscriptions AS s
    ON p.subscription_id = s.subscription_id
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE p.payment_status = 'paid'
GROUP BY sp.plan_tier
ORDER BY total_paid_revenue DESC;

-- 11. Calculate monthly recurring revenue approximation.
-- MRR approximation = sum of monthly_price for active subscriptions.
-- In this project, monthly_price is already the monthly equivalent for quarterly and yearly plans.
SELECT
    SUM(sp.monthly_price) AS estimated_mrr
FROM subscriptions AS s
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE s.subscription_status = 'active';

-- 12. Calculate average revenue per paying user.
-- ARPU = total paid revenue / number of users with paid payments.
WITH user_revenue AS (
    SELECT
        s.user_id,
        SUM(p.amount) AS total_paid_amount
    FROM payments AS p
    JOIN subscriptions AS s
        ON p.subscription_id = s.subscription_id
    WHERE p.payment_status = 'paid'
    GROUP BY s.user_id
)
SELECT
    ROUND(SUM(total_paid_amount) / NULLIF(COUNT(user_id), 0), 2) AS average_revenue_per_paying_user
FROM user_revenue;

-- 13. Find top 10 users by total paid amount.
WITH user_revenue AS (
    SELECT
        s.user_id,
        SUM(p.amount) AS total_paid_amount
    FROM payments AS p
    JOIN subscriptions AS s
        ON p.subscription_id = s.subscription_id
    WHERE p.payment_status = 'paid'
    GROUP BY s.user_id
),
ranked_users AS (
    SELECT
        user_id,
        total_paid_amount,
        RANK() OVER (ORDER BY total_paid_amount DESC) AS revenue_rank
    FROM user_revenue
)
SELECT
    ru.revenue_rank,
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.city,
    ru.total_paid_amount
FROM ranked_users AS ru
JOIN users AS u
    ON ru.user_id = u.user_id
ORDER BY ru.revenue_rank, customer_name
LIMIT 10;

-- 14. Find users with failed payments.
SELECT DISTINCT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.city,
    p.payment_date,
    p.amount
FROM users AS u
JOIN subscriptions AS s
    ON u.user_id = s.user_id
JOIN payments AS p
    ON s.subscription_id = p.subscription_id
WHERE p.payment_status = 'failed'
ORDER BY p.payment_date, customer_name;

-- 15. Find users with no paid payment.
WITH paid_users AS (
    SELECT DISTINCT
        s.user_id
    FROM subscriptions AS s
    JOIN payments AS p
        ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'paid'
)
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.city
FROM users AS u
LEFT JOIN paid_users AS pu
    ON u.user_id = pu.user_id
WHERE pu.user_id IS NULL
ORDER BY u.user_id;

-- 16. Find cancelled subscriptions with cancellation reasons.
SELECT
    c.cancellation_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    sp.plan_name,
    s.start_date,
    s.end_date,
    c.cancellation_date,
    c.cancellation_reason
FROM cancellations AS c
JOIN subscriptions AS s
    ON c.subscription_id = s.subscription_id
JOIN users AS u
    ON s.user_id = u.user_id
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
ORDER BY c.cancellation_date;

-- 17. Calculate cancellation count by reason.
SELECT
    cancellation_reason,
    COUNT(*) AS cancellation_count
FROM cancellations
GROUP BY cancellation_reason
ORDER BY cancellation_count DESC, cancellation_reason;

-- 18. Calculate churn rate.
-- Simplified churn rate = cancelled subscriptions / total subscriptions.
WITH subscription_counts AS (
    SELECT
        COUNT(*) AS total_subscriptions,
        COUNT(*) FILTER (WHERE subscription_status = 'cancelled') AS cancelled_subscriptions
    FROM subscriptions
)
SELECT
    total_subscriptions,
    cancelled_subscriptions,
    ROUND(cancelled_subscriptions * 100.0 / NULLIF(total_subscriptions, 0), 2) AS churn_rate_percent
FROM subscription_counts;

-- 19. Find plans with highest cancellation count.
SELECT
    sp.plan_name,
    COUNT(s.subscription_id) AS cancellation_count
FROM subscriptions AS s
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE s.subscription_status = 'cancelled'
GROUP BY sp.plan_id, sp.plan_name
ORDER BY cancellation_count DESC, sp.plan_name;

-- 20. Find plan cancellation rate.
-- Plan cancellation rate = cancelled subscriptions for a plan / total subscriptions for that plan.
SELECT
    sp.plan_name,
    COUNT(s.subscription_id) AS total_subscriptions,
    COUNT(s.subscription_id) FILTER (WHERE s.subscription_status = 'cancelled') AS cancelled_subscriptions,
    ROUND(
        COUNT(s.subscription_id) FILTER (WHERE s.subscription_status = 'cancelled') * 100.0
        / NULLIF(COUNT(s.subscription_id), 0),
        2
    ) AS plan_cancellation_rate_percent
FROM subscription_plans AS sp
LEFT JOIN subscriptions AS s
    ON sp.plan_id = s.plan_id
GROUP BY sp.plan_id, sp.plan_name
ORDER BY plan_cancellation_rate_percent DESC, sp.plan_name;

-- 21. Find users who renewed subscriptions.
-- In this project, renewal means a user has more than one subscription record.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    COUNT(s.subscription_id) AS total_subscription_periods
FROM users AS u
JOIN subscriptions AS s
    ON u.user_id = s.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(s.subscription_id) > 1
ORDER BY total_subscription_periods DESC, customer_name;

-- 22. Find long-term subscribers based on subscription duration.
-- Active subscriptions use the fixed analysis date as the current date.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    sp.plan_name,
    s.start_date,
    COALESCE(s.end_date, DATE '2026-05-08') AS measured_end_date,
    COALESCE(s.end_date, DATE '2026-05-08') - s.start_date AS subscription_days
FROM subscriptions AS s
JOIN users AS u
    ON s.user_id = u.user_id
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
WHERE COALESCE(s.end_date, DATE '2026-05-08') - s.start_date >= 180
ORDER BY subscription_days DESC;

-- 23. Calculate average subscription duration by plan.
SELECT
    sp.plan_name,
    ROUND(AVG(COALESCE(s.end_date, DATE '2026-05-08') - s.start_date), 2) AS average_subscription_days
FROM subscriptions AS s
JOIN subscription_plans AS sp
    ON s.plan_id = sp.plan_id
GROUP BY sp.plan_id, sp.plan_name
ORDER BY average_subscription_days DESC;

-- 24. Calculate monthly new subscriptions.
SELECT
    DATE_TRUNC('month', start_date)::date AS subscription_month,
    COUNT(*) AS new_subscriptions
FROM subscriptions
GROUP BY DATE_TRUNC('month', start_date)::date
ORDER BY subscription_month;

-- 25. Calculate monthly cancellations.
SELECT
    DATE_TRUNC('month', cancellation_date)::date AS cancellation_month,
    COUNT(*) AS cancellations
FROM cancellations
GROUP BY DATE_TRUNC('month', cancellation_date)::date
ORDER BY cancellation_month;

-- 26. Analyze usage activity by user.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    COUNT(ue.event_id) AS total_usage_events,
    COALESCE(SUM(ue.usage_minutes), 0) AS total_usage_minutes,
    MAX(ue.event_date) AS last_usage_date
FROM users AS u
LEFT JOIN usage_events AS ue
    ON u.user_id = ue.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_usage_minutes DESC, customer_name;

-- 27. Find high-usage users.
-- High usage is defined here as at least 600 total usage minutes.
WITH usage_totals AS (
    SELECT
        u.user_id,
        u.first_name || ' ' || u.last_name AS customer_name,
        SUM(ue.usage_minutes) AS total_usage_minutes
    FROM users AS u
    JOIN usage_events AS ue
        ON u.user_id = ue.user_id
    GROUP BY u.user_id, u.first_name, u.last_name
),
ranked_usage AS (
    SELECT
        user_id,
        customer_name,
        total_usage_minutes,
        RANK() OVER (ORDER BY total_usage_minutes DESC) AS usage_rank
    FROM usage_totals
)
SELECT
    usage_rank,
    user_id,
    customer_name,
    total_usage_minutes
FROM ranked_usage
WHERE total_usage_minutes >= 600
ORDER BY usage_rank, customer_name;

-- 28. Find low-usage active users at risk of churn.
-- Risk definition: active subscriber with less than 60 usage minutes in the last 30 days.
WITH recent_usage AS (
    SELECT
        user_id,
        SUM(usage_minutes) AS recent_usage_minutes,
        MAX(event_date) AS last_usage_date
    FROM usage_events
    WHERE event_date >= DATE '2026-05-08' - 30
    GROUP BY user_id
),
active_subscribers AS (
    SELECT DISTINCT
        user_id
    FROM subscriptions
    WHERE subscription_status = 'active'
)
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    COALESCE(ru.recent_usage_minutes, 0) AS recent_usage_minutes,
    ru.last_usage_date
FROM active_subscribers AS a
JOIN users AS u
    ON a.user_id = u.user_id
LEFT JOIN recent_usage AS ru
    ON u.user_id = ru.user_id
WHERE COALESCE(ru.recent_usage_minutes, 0) < 60
ORDER BY recent_usage_minutes, customer_name;

-- 29. Find users with no usage in the last 30 days.
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    MAX(ue.event_date) AS last_usage_date
FROM users AS u
LEFT JOIN usage_events AS ue
    ON u.user_id = ue.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING MAX(ue.event_date) < DATE '2026-05-08' - 30
    OR MAX(ue.event_date) IS NULL
ORDER BY last_usage_date NULLS FIRST, customer_name;

-- 30. Create a subscription health summary using CTE and CASE WHEN.
WITH subscription_metrics AS (
    SELECT
        user_id,
        COUNT(DISTINCT s.subscription_id) AS total_subscription_count,
        COUNT(DISTINCT s.subscription_id) FILTER (WHERE s.subscription_status = 'active') AS active_subscription_count,
        COUNT(DISTINCT s.subscription_id) FILTER (WHERE s.subscription_status = 'cancelled') AS cancelled_subscription_count
    FROM subscriptions AS s
    GROUP BY user_id
),
payment_metrics AS (
    SELECT
        s.user_id,
        COALESCE(SUM(p.amount) FILTER (WHERE p.payment_status = 'paid'), 0) AS total_paid_amount
    FROM subscriptions AS s
    LEFT JOIN payments AS p
        ON s.subscription_id = p.subscription_id
    GROUP BY s.user_id
),
usage_metrics AS (
    SELECT
        user_id,
        COALESCE(SUM(usage_minutes) FILTER (WHERE event_date >= DATE '2026-05-08' - 30), 0) AS recent_usage_minutes
    FROM usage_events
    GROUP BY user_id
),
subscriber_metrics AS (
    SELECT
        u.user_id,
        COALESCE(sm.total_subscription_count, 0) AS total_subscription_count,
        COALESCE(sm.active_subscription_count, 0) AS active_subscription_count,
        COALESCE(sm.cancelled_subscription_count, 0) AS cancelled_subscription_count,
        COALESCE(pm.total_paid_amount, 0) AS total_paid_amount,
        COALESCE(um.recent_usage_minutes, 0) AS recent_usage_minutes
    FROM users AS u
    LEFT JOIN subscription_metrics AS sm
        ON u.user_id = sm.user_id
    LEFT JOIN payment_metrics AS pm
        ON u.user_id = pm.user_id
    LEFT JOIN usage_metrics AS um
        ON u.user_id = um.user_id
)
SELECT
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE active_subscription_count > 0) AS users_with_active_subscription,
    COUNT(*) FILTER (WHERE cancelled_subscription_count > 0) AS users_with_cancellation,
    COUNT(*) FILTER (WHERE total_paid_amount = 0) AS users_with_no_paid_payment,
    COUNT(*) FILTER (WHERE active_subscription_count > 0 AND recent_usage_minutes < 60) AS active_low_usage_risk_users,
    CASE
        WHEN COUNT(*) FILTER (WHERE active_subscription_count > 0 AND recent_usage_minutes < 60) >= 5
            THEN 'retention_attention_needed'
        ELSE 'subscription_health_looks_stable'
    END AS health_summary
FROM subscriber_metrics;

-- 31. Build a basic Subscriber 360 view using SQL.
-- This combines plan, revenue, usage, renewal, cancellation, and health status for each user.
WITH latest_subscription AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY s.user_id
            ORDER BY s.start_date DESC, s.subscription_id DESC
        ) AS subscription_rank
    FROM subscriptions AS s
),
user_payments AS (
    SELECT
        s.user_id,
        SUM(p.amount) FILTER (WHERE p.payment_status = 'paid') AS total_paid_amount
    FROM subscriptions AS s
    LEFT JOIN payments AS p
        ON s.subscription_id = p.subscription_id
    GROUP BY s.user_id
),
user_usage AS (
    SELECT
        user_id,
        SUM(usage_minutes) AS total_usage_minutes,
        SUM(usage_minutes) FILTER (WHERE event_date >= DATE '2026-05-08' - 30) AS recent_usage_minutes,
        MAX(event_date) AS last_usage_date
    FROM usage_events
    GROUP BY user_id
),
user_cancellations AS (
    SELECT
        s.user_id,
        COUNT(c.cancellation_id) AS cancellation_count
    FROM subscriptions AS s
    LEFT JOIN cancellations AS c
        ON s.subscription_id = c.subscription_id
    GROUP BY s.user_id
),
user_subscription_counts AS (
    SELECT
        user_id,
        COUNT(*) AS total_subscription_count
    FROM subscriptions
    GROUP BY user_id
)
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.city,
    u.signup_date,
    sp.plan_name AS current_plan,
    ls.subscription_status,
    COALESCE(up.total_paid_amount, 0) AS total_paid_amount,
    COALESCE(uu.total_usage_minutes, 0) AS total_usage_minutes,
    uu.last_usage_date,
    COALESCE(usc.total_subscription_count, 0) AS total_subscription_count,
    COALESCE(uc.cancellation_count, 0) AS cancellation_count,
    CASE
        WHEN ls.subscription_status = 'trial' THEN 'trial_user'
        WHEN COALESCE(up.total_paid_amount, 0) = 0 THEN 'no_paid_payment'
        WHEN ls.subscription_status = 'active' AND COALESCE(uu.recent_usage_minutes, 0) >= 300 THEN 'active_high_usage'
        WHEN ls.subscription_status = 'active' AND COALESCE(uu.recent_usage_minutes, 0) < 60 THEN 'active_low_usage_risk'
        WHEN ls.subscription_status = 'cancelled' THEN 'cancelled'
        WHEN ls.subscription_status = 'expired' THEN 'expired'
        WHEN ls.subscription_status = 'paused' THEN 'paused_user'
        ELSE 'needs_review'
    END AS subscriber_health_status
FROM users AS u
LEFT JOIN latest_subscription AS ls
    ON u.user_id = ls.user_id
   AND ls.subscription_rank = 1
LEFT JOIN subscription_plans AS sp
    ON ls.plan_id = sp.plan_id
LEFT JOIN user_payments AS up
    ON u.user_id = up.user_id
LEFT JOIN user_usage AS uu
    ON u.user_id = uu.user_id
LEFT JOIN user_cancellations AS uc
    ON u.user_id = uc.user_id
LEFT JOIN user_subscription_counts AS usc
    ON u.user_id = usc.user_id
ORDER BY total_paid_amount DESC, customer_name;

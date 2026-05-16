-- Day 8 - COVID Data Analysis
-- Analysis queries for PostgreSQL
--
-- This project uses fictional sample data for SQL learning.

-- 1. List all countries and populations.
SELECT
    country_id,
    country_name,
    region,
    population
FROM countries
ORDER BY country_name;

-- 2. Show daily COVID stats with country names.
SELECT
    c.country_name,
    c.region,
    cds.report_date,
    cds.new_cases,
    cds.total_cases,
    cds.new_deaths,
    cds.total_deaths,
    cds.new_recoveries,
    cds.total_recoveries,
    cds.active_cases
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY c.country_name, cds.report_date;

-- 3. Calculate total cases by country using the latest available date.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    cds.report_date,
    cds.total_cases
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY cds.total_cases DESC;

-- 4. Calculate total deaths by country using the latest available date.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    cds.report_date,
    cds.total_deaths
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY cds.total_deaths DESC;

-- 5. Calculate active cases by country using latest available date.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    cds.report_date,
    cds.active_cases
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY cds.active_cases DESC;

-- 6. Find countries with the highest total cases.
SELECT
    c.country_name,
    MAX(cds.total_cases) AS highest_total_cases
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
GROUP BY c.country_id, c.country_name
ORDER BY highest_total_cases DESC;

-- 7. Find countries with the highest total deaths.
SELECT
    c.country_name,
    MAX(cds.total_deaths) AS highest_total_deaths
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
GROUP BY c.country_id, c.country_name
ORDER BY highest_total_deaths DESC;

-- 8. Calculate death rate by country.
-- Formula: total_deaths / total_cases * 100.
-- NULLIF avoids division by zero.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    cds.total_cases,
    cds.total_deaths,
    ROUND((cds.total_deaths::numeric / NULLIF(cds.total_cases, 0)) * 100, 2) AS death_rate_percentage
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY death_rate_percentage DESC;

-- 9. Calculate recovery rate by country.
-- Formula: total_recoveries / total_cases * 100.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    cds.total_cases,
    cds.total_recoveries,
    ROUND((cds.total_recoveries::numeric / NULLIF(cds.total_cases, 0)) * 100, 2) AS recovery_rate_percentage
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY recovery_rate_percentage DESC;

-- 10. Calculate cases per 100,000 population.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    c.population,
    cds.total_cases,
    ROUND((cds.total_cases::numeric / NULLIF(c.population, 0)) * 100000, 2) AS cases_per_100k_population
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY cases_per_100k_population DESC;

-- 11. Show daily new cases trend for each country.
SELECT
    c.country_name,
    cds.report_date,
    cds.new_cases
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY c.country_name, cds.report_date;

-- 12. Show monthly new cases trend.
-- HAVING filters grouped results after aggregation.
SELECT
    c.country_name,
    DATE_TRUNC('month', cds.report_date)::date AS report_month,
    SUM(cds.new_cases) AS monthly_new_cases
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
GROUP BY c.country_name, DATE_TRUNC('month', cds.report_date)::date
HAVING SUM(cds.new_cases) > 0
ORDER BY report_month, c.country_name;

-- 13. Calculate 7-day moving average of new cases.
-- AVG OVER looks at the current day and the previous 6 rows for each country.
SELECT
    c.country_name,
    cds.report_date,
    cds.new_cases,
    ROUND(
        AVG(cds.new_cases) OVER (
            PARTITION BY cds.country_id
            ORDER BY cds.report_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS seven_day_moving_average
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY c.country_name, cds.report_date;

-- 14. Calculate day-over-day change in new cases using LAG.
SELECT
    c.country_name,
    cds.report_date,
    cds.new_cases,
    LAG(cds.new_cases) OVER (
        PARTITION BY cds.country_id
        ORDER BY cds.report_date
    ) AS previous_day_new_cases,
    cds.new_cases - LAG(cds.new_cases) OVER (
        PARTITION BY cds.country_id
        ORDER BY cds.report_date
    ) AS day_over_day_change
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY c.country_name, cds.report_date;

-- 15. Calculate daily growth rate using previous day total cases.
-- Formula: (today total - previous total) / previous total * 100.
WITH totals_with_previous_day AS (
    SELECT
        country_id,
        report_date,
        total_cases,
        LAG(total_cases) OVER (
            PARTITION BY country_id
            ORDER BY report_date
        ) AS previous_total_cases
    FROM covid_daily_stats
)
SELECT
    c.country_name,
    twp.report_date,
    twp.total_cases,
    twp.previous_total_cases,
    ROUND(
        ((twp.total_cases - twp.previous_total_cases)::numeric / NULLIF(twp.previous_total_cases, 0)) * 100,
        2
    ) AS daily_growth_rate_percentage
FROM totals_with_previous_day AS twp
JOIN countries AS c
    ON twp.country_id = c.country_id
ORDER BY c.country_name, twp.report_date;

-- 16. Rank countries by latest total cases.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
),
latest_totals AS (
    SELECT
        c.country_name,
        cds.total_cases
    FROM latest_country_stats AS latest
    JOIN covid_daily_stats AS cds
        ON latest.country_id = cds.country_id
       AND latest.latest_report_date = cds.report_date
    JOIN countries AS c
        ON cds.country_id = c.country_id
)
SELECT
    country_name,
    total_cases,
    RANK() OVER (
        ORDER BY total_cases DESC
    ) AS total_cases_rank
FROM latest_totals
ORDER BY total_cases_rank, country_name;

-- 17. Find countries where cases are increasing in the latest period.
-- This compares the latest 3-day average with the previous 3-day average.
WITH numbered_stats AS (
    SELECT
        country_id,
        report_date,
        new_cases,
        ROW_NUMBER() OVER (
            PARTITION BY country_id
            ORDER BY report_date DESC
        ) AS recent_day_number
    FROM covid_daily_stats
),
period_averages AS (
    SELECT
        country_id,
        AVG(CASE WHEN recent_day_number BETWEEN 1 AND 3 THEN new_cases END) AS latest_3_day_average,
        AVG(CASE WHEN recent_day_number BETWEEN 4 AND 6 THEN new_cases END) AS previous_3_day_average
    FROM numbered_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    ROUND(pa.previous_3_day_average, 2) AS previous_3_day_average,
    ROUND(pa.latest_3_day_average, 2) AS latest_3_day_average,
    ROUND(pa.latest_3_day_average - pa.previous_3_day_average, 2) AS average_change
FROM period_averages AS pa
JOIN countries AS c
    ON pa.country_id = c.country_id
WHERE pa.latest_3_day_average > pa.previous_3_day_average
ORDER BY average_change DESC;

-- 18. Compare vaccination progress by country using latest vaccination date.
WITH latest_vaccination_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM vaccinations
    GROUP BY country_id
)
SELECT
    c.country_name,
    v.report_date,
    v.total_vaccinations,
    v.people_fully_vaccinated
FROM latest_vaccination_stats AS latest
JOIN vaccinations AS v
    ON latest.country_id = v.country_id
   AND latest.latest_report_date = v.report_date
JOIN countries AS c
    ON v.country_id = c.country_id
ORDER BY v.total_vaccinations DESC;

-- 19. Calculate percentage of population fully vaccinated.
WITH latest_vaccination_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM vaccinations
    GROUP BY country_id
)
SELECT
    c.country_name,
    c.population,
    v.people_fully_vaccinated,
    ROUND((v.people_fully_vaccinated::numeric / NULLIF(c.population, 0)) * 100, 2) AS fully_vaccinated_percentage
FROM latest_vaccination_stats AS latest
JOIN vaccinations AS v
    ON latest.country_id = v.country_id
   AND latest.latest_report_date = v.report_date
JOIN countries AS c
    ON v.country_id = c.country_id
ORDER BY fully_vaccinated_percentage DESC;

-- 20. Find countries with missing vaccination records.
-- A missing record means a country/date exists in covid_daily_stats but not in vaccinations.
SELECT
    c.country_name,
    cds.report_date
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
LEFT JOIN vaccinations AS v
    ON cds.country_id = v.country_id
   AND cds.report_date = v.report_date
WHERE v.vaccination_id IS NULL
ORDER BY c.country_name, cds.report_date;

-- 21. Create a simple public health summary using CASE WHEN.
WITH latest_country_stats AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_report_date
    FROM covid_daily_stats
    GROUP BY country_id
)
SELECT
    c.country_name,
    cds.total_cases,
    cds.active_cases,
    ROUND((cds.total_deaths::numeric / NULLIF(cds.total_cases, 0)) * 100, 2) AS death_rate_percentage,
    CASE
        WHEN cds.active_cases >= 40000 THEN 'High active case burden'
        WHEN cds.active_cases >= 10000 THEN 'Moderate active case burden'
        ELSE 'Lower active case burden'
    END AS public_health_status
FROM latest_country_stats AS latest
JOIN covid_daily_stats AS cds
    ON latest.country_id = cds.country_id
   AND latest.latest_report_date = cds.report_date
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY cds.active_cases DESC;

-- 22. Calculate cumulative new cases using SUM OVER.
-- This demonstrates how daily values can be accumulated over time.
SELECT
    c.country_name,
    cds.report_date,
    cds.new_cases,
    SUM(cds.new_cases) OVER (
        PARTITION BY cds.country_id
        ORDER BY cds.report_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_new_cases_in_sample
FROM covid_daily_stats AS cds
JOIN countries AS c
    ON cds.country_id = c.country_id
ORDER BY c.country_name, cds.report_date;

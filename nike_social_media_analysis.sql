----------------------------- 1. Platform Comparison
CREATE VIEW platform_performance AS
select 
platform,
sum(views) as total_views,
avg(engagement_rate) as avg_engagement_rate
from trends
group by platform;

----------------------------- 2. Top 5 countries
CREATE VIEW top_5_countries AS
SELECT 
    country, platform, total_views
FROM (
	select
    country,
    platform,
    total_views,
    row_number() over (
    partition by platform
    order by total_views desc
    ) as rank_sum
from country_summary
) ranked
where rank_sum <= 5
order by platform,total_views desc;

----------------------------- 3. Average completion_rate and avg_watch_time_sec 
CREATE VIEW Category_performance AS
SELECT 
    category,
    AVG(completion_rate) AS avg_completion_rate,
    AVG(avg_watch_time_sec) AS avg_watch_time_sec
FROM
    trends
GROUP BY category;

----------------------------- 4. Top 10 author_handle 
CREATE VIEW top_10_author_handle AS
SELECT
    author_handle,
    creator_avg_views
FROM creators
ORDER BY creator_avg_views DESC;

----------------------------- 5. Top 20 hashtags
CREATE VIEW top_20_hashtag AS
with top_20 as (
select
hashtag,
sum(views) as total_views
from trends
group by hashtag
order by total_views desc
),
ranked as (
select 
t.hashtag,
t.engagement_rate,
row_number() over (
partition by t.hashtag
order by t.engagement_rate
) as rn,
count(*) over (
partition by t.hashtag
) as cnt
    FROM trends t
    INNER JOIN top_20 x
        ON t.hashtag = x.hashtag
)
SELECT
    x.hashtag,
    x.total_views,
    AVG(r.engagement_rate) AS median_engagement_rate
FROM top_20 x
JOIN ranked r
    ON x.hashtag = r.hashtag
WHERE r.rn IN (
    FLOOR((r.cnt + 1) / 2),
    CEIL((r.cnt + 1) / 2)
)
GROUP BY
    x.hashtag,
    x.total_views
ORDER BY x.total_views DESC;

----------------------------- 6. Top 10 author_handle 
CREATE VIEW emoji_impact AS
with ranked as (
select
has_emoji,
engagement_per_1k,
row_number() over (
partition by has_emoji
order by engagement_per_1k
) as rn,
count(*) over ( 
partition by has_emoji
) as cnt
from trends
)
select 
has_emoji,
avg(engagement_per_1k) as median_engagement_per_1k
from ranked
where rn in(
floor((cnt+1)/2),
ceil((cnt+1)/2)
)
group by has_emoji;

----------------------------- 7. upload_timing
CREATE VIEW upload_timing AS
select 
publish_dayofweek,
upload_hour,
avg(views) as avg_views,
avg(completion_rate) as avg_completion_rate
from trends
group by publish_dayofweek,upload_hour 
order by avg_views desc;

----------------------------- 8. Trend Momentum
create view trend_momentum as 
with ranked as (
select
 trend_type,
 engagement_velocity,
 trend_duration_days,
 
 row_number() over (
 partition by trend_type
 order by engagement_velocity
 ) as velocity_rn,
 count(*) over (
 partition by trend_type
 ) as velocity_cnt,
 
 row_number() over (
 partition by trend_type
 order by trend_duration_days
 ) as duration_rn,
 
 count(*) over (
 partition by trend_type
 ) as duration_cnt
from trends
)
select 
	trend_type,
	
    AVG(
        CASE
            WHEN velocity_rn IN (
                FLOOR((velocity_cnt + 1) / 2),
                CEIL((velocity_cnt + 1) / 2)
            )
            THEN engagement_velocity
        END
    ) AS median_engagement_velocity,

    AVG(
        CASE
            WHEN duration_rn IN (
                FLOOR((duration_cnt + 1) / 2),
                CEIL((duration_cnt + 1) / 2)
            )
            THEN trend_duration_days
        END
    ) AS median_trend_duration_days

FROM ranked
GROUP BY trend_type
ORDER BY trend_type;

----------------------------- 9. Device Analysis
create view device_analysis as 
select 
device_type,
device_brand,
avg(completion_rate) as avg_completion_rate 
from trends
group by device_type,device_brand
order by avg_completion_rate  desc;

----------------------------- 10. Traffic Sources
create view Traffic_sources as
with ranked as (
select 
traffic_source,
completion_rate,
row_number() over (
partition by traffic_source
order by completion_rate
) as rn,
count(*) over (
partition by traffic_source
) as cnt
from trends
)
select 
traffic_source,
avg(completion_rate) as median_completion_rate
from ranked
where rn in (
floor((cnt+1)/2),
ceil((cnt+1)/2)
)
group by traffic_source
order by median_completion_rate desc;

----------------------------- 11. Seasonal Insights
create view Seasonal_insights as
SELECT
    event_season,
    AVG(views) AS avg_views,
    AVG(engagement_rate) AS avg_engagement_rate
FROM trends
GROUP BY event_season
ORDER BY avg_views DESC;

----------------------------- 12. Data Quality Check
create view Data_quality_check as
SELECT
    row_id,
    likes,
    comments,
    shares,
    saves,
    engagement_total,
    (likes + comments + shares + saves) AS calculated_engagement
FROM trends
WHERE engagement_total <> (likes + comments + shares + saves);
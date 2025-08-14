-- Calculate 7-day retention rate by cohort
WITH user_cohorts AS (
  SELECT 
    user_id, 
    MIN(DATE(login_timestamp)) as first_login_date
  FROM user_activity 
  GROUP BY user_id
),
retention_analysis AS (
  SELECT 
    uc.first_login_date,
    COUNT(DISTINCT uc.user_id) as new_users,
    COUNT(DISTINCT CASE 
      WHEN ua.login_timestamp >= DATE(uc.first_login_date, '+7 days') 
      THEN uc.user_id 
    END) as retained_users_week1
  FROM user_cohorts uc
  LEFT JOIN user_activity ua ON uc.user_id = ua.user_id
  GROUP BY uc.first_login_date
)
SELECT 
  first_login_date,
  new_users,
  retained_users_week1,
  ROUND(retained_users_week1 * 100.0 / new_users, 2) as retention_rate_pct
FROM retention_analysis
ORDER BY first_login_date;


-- Daily and hourly usage patterns
SELECT 
  CASE strftime('%w', login_timestamp)
    WHEN '0' THEN 'Sunday'
    WHEN '1' THEN 'Monday' 
    WHEN '2' THEN 'Tuesday'
    WHEN '3' THEN 'Wednesday'
    WHEN '4' THEN 'Thursday'
    WHEN '5' THEN 'Friday'
    WHEN '6' THEN 'Saturday'
  END as day_of_week,
  COUNT(DISTINCT user_id) as daily_active_users,
  COUNT(*) as total_sessions,
  AVG(session_duration_minutes) as avg_session_duration,
  MAX(COUNT(DISTINCT user_id)) OVER() as peak_daily_users
FROM user_activity
GROUP BY strftime('%w', login_timestamp)
ORDER BY daily_active_users DESC;

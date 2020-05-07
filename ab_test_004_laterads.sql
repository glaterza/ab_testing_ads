/*I need the AB overview board for the experiment 004_LaterAds on Solitaire Showtime only for data where players are below level 40. If its easier I would be fine with values for

    conversions
    ad bookings
    iap bookings
    total bookings
    sessions
    dau
*/


-- query
SELECT
  activity_dt,
  market_cd,
  ab_test.ab_test_rule_desc           AS abtest_group,
  COUNT (DISTINCT account_id)         AS DAU,
  SUM(session_qty)                    AS sessions,
  SUM(user_ad_gross_revenue_amt)      AS ad_bookings,
  SUM(user_gross_revenue_amt)         AS iap_bookings,
  SUM(user_ad_gross_revenue_amt)+
  SUM(user_gross_revenue_amt)         AS total_bookings,
  SUM(
    CASE
      WHEN first_conversion_dt = activity_dt
        THEN 1
        ELSE 0
     END)                             AS conversions
FROM pr_analytics_delta.user_application_activity
LATERAL VIEW explode(ab_test_list)    AS ab_test
WHERE activity_dt > '2020-04-25' AND
      lower(application_family_name) = 'solitaire showtime' AND 
      lower(ab_test.ab_test_name) = '004_laterads' AND
      level_cd <= 40    -- decía menos de cuarenta. Asumo que quieren el level 40 también.
GROUP BY activity_dt, 
         market_cd, 
         ab_test.ab_test_rule_desc
ORDER BY activity_dt asc,
         market_cd asc
;

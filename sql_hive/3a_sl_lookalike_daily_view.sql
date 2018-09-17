-- ------------------------------------------------------------
-- step 3: summarize daily view & session count (must complete step 2A first)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS atlantis.sl_lookalike_daily_view;
CREATE TABLE atlantis.sl_lookalike_daily_view AS
SELECT 
    member_srl
    ,dt
    ,category
    ,COUNT(*) AS ctv_
    ,COUNT(DISTINCT session_id) AS cts_
FROM atlantis.sl_lookalike_active_customer_activity_log
    WHERE action = 'VIEW'
GROUP BY member_srl, dt, category
ORDER BY member_srl, dt, category;

-- check
SELECT * FROM atlantis.sl_lookalike_daily_view LIMIT 100;

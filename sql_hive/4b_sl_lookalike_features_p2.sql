-- ------------------------------------------------------------
-- step 4B: feature engineering (part 2)
-- can be run as soon as 2B is completed 
-- ------------------------------------------------------------
DROP TABLE IF EXISTS atlantis.sl_lookalike_features_p2;
CREATE TABLE atlantis.sl_lookalike_features_p2 AS
SELECT 
    member_srl
    ,ref_dt
    ,category
    ,COALESCE(COUNT(*), 0) AS cto_
    ,COALESCE(SUM(qty_), 0) AS ctq_
    ,COALESCE(SUM(gmv_), 0) AS tas_
FROM (
    SELECT 
        g.member_srl
        ,d.ref_dt
        ,g.category
        ,g.dt
        ,g.qty_
        ,g.gmv_
    FROM 
        atlantis.sl_lookalike_sampling_dates AS d
    LEFT JOIN
        atlantis.sl_lookalike_daily_sale AS g
    WHERE
        -- warning:
        -- (SELECT f_dt FROM atlantis.sl_lookalike_vars) does not work
        -- replace with 20170901
        g.dt BETWEEN 20170901 AND d.ref_dt
    ) AS z
GROUP BY member_srl, ref_dt, category
ORDER BY member_srl, ref_dt, category;
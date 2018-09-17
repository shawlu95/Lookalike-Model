DROP TABLE IF EXISTS atlantis.sl_lookalike_features_p1;
CREATE TABLE atlantis.sl_lookalike_features_p1 AS
SELECT 
    member_srl
    ,ref_dt
    ,category
    ,start_dt
    ,aay
    ,r_dt
    ,l_dt
    ,f_dt
    ,cd_range
    ,CASE
        WHEN start_dt > 20170901
            THEN DATEDIFF(
                    DATE_FORMAT(from_unixtime(unix_timestamp(cast(ref_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    ,DATE_FORMAT(from_unixtime(unix_timestamp(cast(start_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    ) 
        ELSE 
            DATEDIFF(
                    DATE_FORMAT(from_unixtime(unix_timestamp(cast(ref_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    ,DATE_FORMAT(from_unixtime(unix_timestamp(cast(20170901 AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    ) 
    END AS ad_range
    ,ctv_
    ,cts_
    ,dsl
    ,vsl
    ,ssl
FROM (
    SELECT 
        a.member_srl
        ,a.ref_dt
        ,a.category
        ,u.start_dt
        ,ROUND(CAST(DATEDIFF(
                    DATE_FORMAT(from_unixtime(unix_timestamp(cast(a.ref_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    ,DATE_FORMAT(from_unixtime(unix_timestamp(cast(u.start_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    )  AS FLOAT) / 365, 2) AS aay
        ,COALESCE(b.r_dt, MIN(a.dt)) AS r_dt
        ,MIN(a.dt) AS l_dt 
        ,MAX(a.dt) AS f_dt 
        ,DATEDIFF(
            DATE_FORMAT(from_unixtime(unix_timestamp(cast(MAX(a.dt) AS string),'yyyyMMdd')),'yyyy-MM-dd')
            ,DATE_FORMAT(from_unixtime(unix_timestamp(cast(MIN(a.dt) AS string),'yyyyMMdd')),'yyyy-MM-dd')
            ) AS cd_range
        ,SUM(a.ctv_) AS ctv_
        ,SUM(a.cts_) AS cts_
        ,DATEDIFF(
            DATE_FORMAT(from_unixtime(unix_timestamp(cast(a.ref_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
            ,DATE_FORMAT(from_unixtime(unix_timestamp(cast(COALESCE(b.r_dt, MIN(a.dt)) AS string),'yyyyMMdd')),'yyyy-MM-dd')
            ) AS dsl
        ,SUM(
            CASE WHEN b.r_dt IS NULL THEN a.ctv_
            WHEN b.r_dt IS NOT NULL AND a.dt BETWEEN b.r_dt AND a.ref_dt THEN a.ctv_
            ELSE 0
            END
        ) AS vsl
        ,SUM(
            CASE WHEN b.r_dt IS NULL THEN a.cts_
            WHEN b.r_dt IS NOT NULL AND a.dt BETWEEN b.r_dt AND a.ref_dt THEN a.cts_
            ELSE 0
            END
        ) AS ssl
    FROM (
        SELECT 
            v.member_srl
            ,d.ref_dt
            ,v.category
            ,v.dt
            ,v.ctv_
            ,v.cts_
        FROM 
            atlantis.sl_lookalike_sampling_dates AS d
        LEFT JOIN
            atlantis.sl_lookalike_daily_view AS v
        -- warning:
        -- (SELECT f_dt FROM atlantis.sl_lookalike_vars) does not work
        -- replace with 20170901
        WHERE v.dt BETWEEN 20170901 AND d.ref_dt
        ) AS a
    LEFT JOIN bimart.cs_user_state AS u
    ON a.member_srl = u.member_srl
    LEFT JOIN (
        SELECT
        g.member_srl
        ,g.category
        ,d.ref_dt
        ,MAX(g.dt) AS r_dt
        FROM atlantis.sl_lookalike_sampling_dates AS d
        LEFT JOIN atlantis.sl_lookalike_daily_sale AS g
                WHERE g.dt < d.ref_dt
        GROUP BY member_srl, ref_dt, category
    ) AS b
    ON a.member_srl = b.member_srl
        AND a.category = b.category
        AND a.ref_dt = b.ref_dt
    GROUP BY a.member_srl, a.ref_dt, a.category, u.start_dt, b.r_dt
) AS z
ORDER BY member_srl, ref_dt DESC, category;
-- ------------------------------------------------------------
-- step 5: merge feature part 1 & 2 (must complete step 4A & 4B)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS atlantis.sl_lookalike_features;
CREATE TABLE atlantis.sl_lookalike_features AS
SELECT 
    A.member_srl
    ,A.ref_dt
    ,A.category
    ,A.start_dt
    ,A.r_dt
    ,A.l_dt
    ,A.f_dt
    ,COALESCE(B.cto_, 0) AS cto_
    ,ROUND((COALESCE(B.cto_, 0) * 366) / (A.ad_range + 1), 2) AS cto
    ,COALESCE(B.ctq_, 0) AS ctq_
    ,ROUND((COALESCE(B.ctq_, 0) * 366) / (A.ad_range + 1), 2) AS ctq
    ,A.ctv_
    ,ROUND((A.ctv_ * 366) / (A.ad_range + 1), 2) AS ctv
    ,A.cts_
    ,ROUND((A.cts_ * 366) / (A.ad_range + 1), 2) AS cts
    ,A.ad_range
    ,A.cd_range
    ,ROUND(COALESCE(A.ad_range, 0) / COALESCE(B.cto_, 1), 2) AS dpo
    ,ROUND(COALESCE(A.ad_range, 0) / COALESCE(B.ctq_, 1), 2) AS dpq
    ,A.dsl
    ,ROUND(COALESCE(B.tas_, 0) / COALESCE(B.cto_, 1), 2) AS gpo
    ,ROUND(COALESCE(B.tas_, 0) / COALESCE(B.ctq_, 1), 2) AS gpq
    ,ROUND(COALESCE(B.tas_, 0) / (A.ad_range + 1), 2) AS gpd
    ,ROUND(CAST(A.ctv_ AS FLOAT) / COALESCE(B.cto_, 1), 2) AS vpo
    ,ROUND(CAST(A.ctv_ AS FLOAT) / COALESCE(B.ctq_, 1), 2) AS vpq
    ,A.vsl
    ,ROUND(CAST(A.cts_ AS FLOAT) / COALESCE(B.cto_, 1), 2) AS spo
    ,ROUND(CAST(A.cts_ AS FLOAT) / COALESCE(B.ctq_, 1), 2) AS spq
    ,A.ssl
    ,COALESCE(B.tas_, 0) AS tas_
    ,ROUND((COALESCE(B.tas_, 0) * 366) / (A.ad_range + 1), 2) AS aas
    ,C.age 
    ,C.gender AS sex
    ,A.aay
FROM atlantis.sl_lookalike_features_p1 AS A
LEFT JOIN atlantis.sl_lookalike_features_p2 AS B
ON A.member_srl = B.member_srl
    AND A.ref_dt = B.ref_dt
    AND A.category = B.category
LEFT JOIN bimart.cs_user_state AS C
    ON A.member_srl = C.member_srl
ORDER BY A.member_srl, A.ref_dt DESC, A.category;

SELECT * FROM atlantis.sl_lookalike_features LIMIT 100;

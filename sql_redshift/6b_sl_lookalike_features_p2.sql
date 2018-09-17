DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_p2;
CREATE TABLE sb_marketing.sl_lookalike_features_p2 AS
SELECT 
	A.member_srl
	,A.ref_dt
	,A.category
	,A.start_dt
	,A.f_dt
	,A.l_dt
	,A.cd_range
	,A.ad_range
	,COALESCE(A.cto_, 0) AS cto_
	,CAST((CAST(COALESCE(A.cto_, 0) AS FLOAT) * 366) / (A.ad_range + 1) AS NUMERIC(36, 2)) AS cto
	,COALESCE(A.ctq_, 0) AS ctq_
	,CAST((CAST(COALESCE(A.ctq_, 0) AS FLOAT) * 366) / (A.ad_range + 1) AS NUMERIC(36, 2)) AS ctq
	,CAST(CAST(COALESCE(A.ad_range, 0) AS FLOAT) / COALESCE(A.cto_ + 1, 1) AS NUMERIC(36, 2)) AS dpo
	,CAST(CAST(COALESCE(A.ad_range, 0) AS FLOAT) / COALESCE(A.ctq_ + 1, 1) AS NUMERIC(36, 2)) AS dpq
	,A.dsl
	,A.gpo
	,A.gpq
	,CAST(CAST(COALESCE(A.tas_, 0) AS FLOAT) / (A.ad_range + 1) AS NUMERIC(36, 2)) AS gpd
	,A.tas_
	,CAST(CAST(COALESCE(A.tas_, 0) AS FLOAT) * 366 / (A.ad_range + 1) AS NUMERIC(36, 2)) AS aas
FROM sb_marketing.sl_lookalike_features_tmp_p2 AS A
WHERE ref_dt > start_dt
ORDER BY 1, 2 DESC, 3;
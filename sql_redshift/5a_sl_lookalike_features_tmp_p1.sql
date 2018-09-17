DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_tmp_p1;
CREATE TABLE sb_marketing.sl_lookalike_features_tmp_p1 AS
SELECT 
	a.member_srl
	,ref_dt
	,a.category
	,u.start_dt
	,MIN(dt) AS f_dt
	,MAX(dt) AS l_dt
	,DATEDIFF(DAY
			,DATE(MIN(dt))
			,DATE(MAX(dt))) AS cd_range
	,DATEDIFF(DAY
					,DATE((SELECT f_dt FROM sb_marketing.sl_lookalike_vars))
					,DATE(ref_dt))
	AS ad_range
	,COUNT(*) AS cto_
	,SUM(qty_sum) AS ctq_
	,DATEDIFF(DAY
			,DATE(MAX(dt))
			,DATE(ref_dt)) AS dsl
	,CAST(CAST(SUM(gmv_sum) AS FLOAT) / COUNT(*) AS NUMERIC(36, 2)) AS gpo
	,CAST(CAST(SUM(gmv_sum) AS FLOAT) / SUM(qty_sum) AS NUMERIC(36, 2)) AS gpq
	,SUM(gmv_sum) AS tas_
FROM (
	SELECT 
		member_srl
		,d.ref_dt
		,s.dt
		,s.qty_sum
		,s.gmv_sum
		,s.category
	FROM 
		sb_marketing.sl_lookalike_sampling_dates AS d,
		sb_marketing.sl_lookalike_daily_sale_p1 AS s
	WHERE
		s.dt BETWEEN (SELECT f_dt FROM sb_marketing.sl_lookalike_vars) AND d.ref_dt
		AND member_srl IN (SELECT member_srl FROM sb_marketing.sl_lookalike_active_customers_p1)
) AS a
LEFT JOIN
bimart.cs_user_state AS u
	ON a.member_srl = u.member_srl
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2 DESC, 3;
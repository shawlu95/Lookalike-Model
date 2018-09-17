DROP TABLE IF EXISTS atlantis.sl_lookalike_features_final_tmp;
CREATE TABLE atlantis.sl_lookalike_features_final_tmp AS
SELECT 
	a.member_srl
	,CASE
		WHEN category IS NULL THEN 'null'
		else category
	END as category
	,a.cto
	,a.ctq
	,a.ctv
	,a.cts
	,a.dpo
	,a.dpq
	,a.dsl
	,a.gpo
	,a.gpq
	,a.gpd
	,a.vpo
	,a.vpq
	,a.vsl
	,a.spo
	,a.spq
	,a.ssl
	,a.aas
	,b.age
	,CASE 
		WHEN b.gender = 'F' THEN 1
		WHEN (b.gender IS NULL OR b.gender = 999) THEN NULL
		ELSE 0
	END AS sex
	,ROUND(CAST(DATEDIFF(
                    DATE_FORMAT(from_unixtime(unix_timestamp(cast(a.ref_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    ,DATE_FORMAT(from_unixtime(unix_timestamp(cast(b.start_dt AS string),'yyyyMMdd')),'yyyy-MM-dd')
                    )  AS FLOAT) / 365, 2) AS aay
FROM atlantis.sl_lookalike_features AS a
LEFT JOIN bimart.cs_user_state AS b
ON a.member_srl = b.member_srl
		-- warning:
        -- (SELECT f_dt FROM atlantis.sl_lookalike_vars) does not work
        -- replace with 20170901
	WHERE ref_dt = 20180901
ORDER BY member_srl, category;

DROP TABLE IF EXISTS atlantis.sl_lookalike_features_final;
CREATE TABLE atlantis.sl_lookalike_features_final AS
SELECT DISTINCT * FROM atlantis.sl_lookalike_features_final_tmp;

-- drop all intermediate table if necessary
DROP TABLE IF EXISTS atlantis.sl_lookalike_vars;
DROP TABLE IF EXISTS atlantis.sl_lookalike_sampling_dates;
DROP TABLE IF EXISTS atlantis.sl_lookalike_active_customers;
DROP TABLE IF EXISTS atlantis.sl_lookalike_active_customer_activity_log;
DROP TABLE IF EXISTS atlantis.sl_lookalike_daily_sale;
DROP TABLE IF EXISTS atlantis.sl_lookalike_daily_view;
DROP TABLE IF EXISTS atlantis.sl_lookalike_features_p1;
DROP TABLE IF EXISTS atlantis.sl_lookalike_features_p2;
DROP TABLE IF EXISTS atlantis.sl_lookalike_features;
DROP TABLE IF EXISTS atlantis.sl_lookalike_features_final_tmp;
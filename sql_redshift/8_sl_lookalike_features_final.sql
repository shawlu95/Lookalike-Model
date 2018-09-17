DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_final_tmp;
CREATE TABLE sb_marketing.sl_lookalike_features_final_tmp AS
SELECT 
	a.member_srl
	,CASE
		WHEN category IS NULL THEN 'null'
		else category
	END as category
	,a.cto
	,a.ctq
	,a.dpo
	,a.dpq
	,a.dsl
	,a.gpo
	,a.gpq
	,a.gpd
	,a.aas
	,b.age
	,CASE 
		WHEN b.gender = 'F' THEN 1
		WHEN (b.gender IS NULL OR b.gender = 999) THEN NULL
		ELSE 0
	END AS sex
	,ROUND(CAST(DATEDIFF(DAY, DATE(b.start_dt), DATE(a.ref_dt)) AS FLOAT) / 365, 2) AS aay
FROM sb_marketing.sl_lookalike_features AS a
LEFT JOIN bimart.cs_user_state AS b
ON a.member_srl = b.member_srl
	WHERE ref_dt = (SELECT l_dt FROM sb_marketing.sl_lookalike_vars)
ORDER BY member_srl, category;

DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_final;
CREATE TABLE sb_marketing.sl_lookalike_features_final AS
SELECT DISTINCT * FROM sb_marketing.sl_lookalike_features_final_tmp;

DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_final_tmp;

-- return 125553557
SELECT COUNT(*) FROM sb_marketing.sl_lookalike_features_final;

-- return 11144745
SELECT COUNT(DISTINCT member_srl) FROM sb_marketing.sl_lookalike_features_final;

-- return 106
SELECT COUNT(DISTINCT category) FROM sb_marketing.sl_lookalike_features_final;

-- check category
SELECT DISTINCT category FROM sb_marketing.sl_lookalike_features_final ORDER BY category;

-- check that 'all' category is properly loaded
SELECT DISTINCT * FROM sb_marketing.sl_lookalike_features_final
WHERE category = 'all' AND cto IS NOT NULL LIMIT 100;

-- check that 'null' category is properly loaded
SELECT DISTINCT * FROM sb_marketing.sl_lookalike_features_final
WHERE category = 'null' AND cto IS NOT NULL LIMIT 100;

-- drop all intermediate table if necessary
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_vars;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_sampling_dates;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_active_customers;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_active_customers_p1;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_active_customers_p2;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_daily_sale;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_daily_sale_p1;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_daily_sale_p2;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_tmp_p1;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_tmp_p2;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_tmp_all_cat;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_p1;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_p2;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features_all_cat;
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features;
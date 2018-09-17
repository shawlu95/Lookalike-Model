-- merge
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_features;
CREATE TABLE sb_marketing.sl_lookalike_features AS
SELECT * FROM sb_marketing.sl_lookalike_features_p1 ORDER BY member_srl, ref_dt DESC, category;

INSERT INTO sb_marketing.sl_lookalike_features
SELECT * FROM sb_marketing.sl_lookalike_features_p2 ORDER BY member_srl, ref_dt DESC, category;

INSERT INTO sb_marketing.sl_lookalike_features
SELECT 
	member_srl
	,ref_dt
	,'all' AS category 
	,start_dt
	,f_dt
	,l_dt
	,cd_range
	,ad_range
	,cto_
	,cto
	,ctq_
	,ctq
	,dpo
	,dpq
	,dsl
	,gpo
	,gpq
	,gpd
	,tas_
	,aas
FROM sb_marketing.sl_lookalike_features_all_cat ORDER BY member_srl, ref_dt DESC, category;

SELECT COUNT(DISTINCT member_srl) FROM sb_marketing.sl_lookalike_features;
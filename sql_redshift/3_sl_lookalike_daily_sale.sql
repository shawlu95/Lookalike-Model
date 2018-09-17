DROP TABLE IF EXISTS sb_marketing.sl_lookalike_daily_sale;
CREATE TABLE sb_marketing.sl_lookalike_daily_sale AS
SELECT 
	a.member_srl
	,a.dt
	-- warning: must use CONCAT twice in redshift
	,CONCAT(CONCAT(c.unitname1, ' - '), c.unitname2) AS category 
	,SUM(a.gmv) AS gmv_sum
	,SUM(a.qty) AS qty_sum
FROM (
	SELECT
		member_srl
		,category_id
		,sale_basis_dy AS dt
		,gmv
		,qty
	FROM bimart.cs_sales
	WHERE 
		member_srl IN (SELECT member_srl FROM sb_marketing.sl_lookalike_active_customers)
		AND return_flag = 1
		AND sale_or_delivery = 'S'
	) AS a
LEFT JOIN
  bimart.management_category_hier_curr AS c 
ON a.category_id = c.mngcateid 
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

-- check
SELECT * FROM sb_marketing.sl_lookalike_daily_sale ORDER BY member_srl, dt, category LIMIT 100;
SELECT COUNT(DISTINCT member_srl) FROM sb_marketing.sl_lookalike_daily_sale;
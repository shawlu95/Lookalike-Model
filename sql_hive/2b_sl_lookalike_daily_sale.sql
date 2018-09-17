-- ------------------------------------------------------------
-- step 2B: summarize daily sale (this step can be run in parallel as step 2A)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS atlantis.sl_lookalike_daily_sale;
CREATE TABLE atlantis.sl_lookalike_daily_sale AS
SELECT 
    a.member_srl
    ,a.dt
    ,a.category
    ,SUM(a.gmv) AS gmv_
    ,SUM(a.qty) AS qty_
FROM (
    SELECT
        s.member_srl
        ,s.sale_basis_dy AS dt
        ,CONCAT(c.unitname1, ' - ', c.unitname2) AS category
        ,s.gmv
        ,s.qty
    FROM bimart.cs_sales AS s
    LEFT JOIN
        bimart.management_category_hier_curr AS c 
        ON s.category_id = c.mngcateid 
    WHERE 
        s.return_flag = 1
        AND s.sale_or_delivery = 'S'
        AND s.member_srl IN (SELECT member_srl FROM atlantis.sl_lookalike_active_customers)
    ) AS a
GROUP BY member_srl, dt, category
ORDER BY member_srl, dt, category;

-- check
SELECT * FROM atlantis.sl_lookalike_daily_sale ORDER BY member_srl, dt, category LIMIT 100;
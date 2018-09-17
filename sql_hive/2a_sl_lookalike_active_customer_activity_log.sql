-- ------------------------------------------------------------
-- step 2A: activity log for active customers, join product category column 
-- ------------------------------------------------------------
DROP TABLE IF EXISTS atlantis.sl_lookalike_active_customer_activity_log;
CREATE TABLE atlantis.sl_lookalike_active_customer_activity_log AS
SELECT
    a.member_srl
    ,a.session_id
    ,a.action
    ,a.dt
    ,a.platform
    ,b.categoryid AS category_id
    ,CONCAT(c.unitname1, ' - ', c.unitname2) AS category
FROM
    indexing_platform.user_behavior_log a
    LEFT JOIN
        bimart.ddd_product_vendor_item b 
        ON b.vendoritemid = a.vendoritem_id
    LEFT JOIN
        bimart.management_category_hier_curr AS c 
        ON b.categoryid = c.mngcateid
WHERE
    a.member_srl IN (
        SELECT member_srl FROM atlantis.sl_lookalike_active_customers 
    );

-- check
SELECT * FROM atlantis.sl_lookalike_active_customer_activity_log LIMIT 100;
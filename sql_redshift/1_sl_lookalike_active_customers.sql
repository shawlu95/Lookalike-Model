-- selective active customers in recent 1 year
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_active_customers;
CREATE TABLE sb_marketing.sl_lookalike_active_customers AS 
    SELECT  
        member_srl
    FROM bimart.cs_sales 
    WHERE sale_basis_dy BETWEEN 20170901
    					AND 20180831
        AND return_flag = 1
        AND sale_or_delivery = 'S'
    GROUP BY member_srl;

-- check
SELECT COUNT(*) FROM sb_marketing.sl_lookalike_active_customers;
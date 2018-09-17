-- ------------------------------------------------------------
-- step 1: create a population of customer srl 
-- ------------------------------------------------------------
DROP TABLE IF EXISTS atlantis.sl_lookalike_active_customers;
CREATE TABLE atlantis.sl_lookalike_active_customers AS 
    SELECT  
        DISTINCT member_srl
    FROM bimart.cs_sales 
    WHERE sale_basis_dy BETWEEN 20170901
                        AND 20180831
        AND return_flag = 1
        AND sale_or_delivery = 'S'
    -- LIMIT 10
 ;

-- returns 11,159,096
SELECT COUNT(DISTINCT member_srl) FROM atlantis.sl_lookalike_active_customers;
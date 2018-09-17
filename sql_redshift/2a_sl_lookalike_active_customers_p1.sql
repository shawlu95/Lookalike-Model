DROP TABLE IF EXISTS sb_marketing.sl_lookalike_active_customers_p1;
CREATE TABLE sb_marketing.sl_lookalike_active_customers_p1 AS 
    SELECT * FROM sb_marketing.sl_lookalike_active_customers OFFSET 0 LIMIT 5000000;
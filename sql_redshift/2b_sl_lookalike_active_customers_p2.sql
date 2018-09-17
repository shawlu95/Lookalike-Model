-- rest of 6 million
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_active_customers_p2;
CREATE TABLE sb_marketing.sl_lookalike_active_customers_p2 AS 
    SELECT * FROM sb_marketing.sl_lookalike_active_customers OFFSET 5000000;
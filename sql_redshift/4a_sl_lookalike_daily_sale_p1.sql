DROP TABLE IF EXISTS sb_marketing.sl_lookalike_daily_sale_p1;
CREATE TABLE sb_marketing.sl_lookalike_daily_sale_p1 AS
SELECT * FROM
	sb_marketing.sl_lookalike_daily_sale
WHERE member_srl IN (SELECT member_srl FROM sb_marketing.sl_lookalike_active_customers_p1);
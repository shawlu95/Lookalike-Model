-- warning: do not cast f_dt l_dt into date
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_vars;
CREATE TABLE sb_marketing.sl_lookalike_vars AS SELECT 
   20170901             AS f_dt, 
   20180901             AS l_dt, 
   20180901             AS rf_dt;
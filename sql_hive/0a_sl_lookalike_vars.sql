-- Replace all occurences of hard-coded dates below
-- f_dt = 20170901 # earliest(first) cut-off date, before which data are not considered
-- l_dt = 20180831 # latest cut-off date, after which data are not considered
-- rf_dt = 20180831 # hypothetical current date as reference (now)  

DROP TABLE IF EXISTS atlantis.sl_lookalike_vars;
CREATE TABLE atlantis.sl_lookalike_vars AS 
SELECT 
   20170901             AS f_dt, 
   20180831             AS l_dt, 
   20180831             AS rf_dt;

DROP TABLE IF EXISTS atlantis.sl_lookalike_sampling_dates_tmp;
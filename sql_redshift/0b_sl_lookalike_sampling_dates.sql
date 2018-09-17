-- ------------------------------------------------------------
-- create a table of sampling dates
-- ------------------------------------------------------------
BEGIN TRANSACTION;

-- short table: use full year's data, starting from f_dt the single date in the table belows
DROP TABLE IF EXISTS sb_marketing.sl_lookalike_sampling_dates;
CREATE TABLE sb_marketing.sl_lookalike_sampling_dates AS
SELECT CAST(y.x + m.x + d.x AS INT) AS ref_dt 
FROM (
	SELECT '2018' x
) AS y CROSS JOIN (
	SELECT '09' x
) AS m CROSS JOIN (
	SELECT '01' x
) AS d ORDER BY ref_dt;

-- ------------------------------------------------------------
-- expanded table
-- Samples are taken at many different dates. For example, 20180101, 20180115, 20180201... 20180901
-- for each sampling date, data taken into account are in range:
-- 		f_dt ~ 20180101
-- 		f_dt ~ 20180115
-- 		f_dt ~ 20180201 etc.
-- Note that the earliest date in which data are used is defiend in f_dt variable,
-- so if a sampling date is earlier than f_dt, that sampling date is meaningless.
-- ------------------------------------------------------------
-- DROP TABLE IF EXISTS sb_marketing.sl_lookalike_sampling_dates;
-- CREATE TABLE sb_marketing.sl_lookalike_sampling_dates AS
-- SELECT CAST(y.x + m.x + d.x AS INT) AS ref_dt 
-- FROM (
-- 	SELECT '2017' x UNION ALL
-- 	SELECT '2018' x
-- ) AS y CROSS JOIN (
-- 	SELECT '01' x UNION ALL
-- 	SELECT '02' x UNION ALL
-- 	SELECT '03' x UNION ALL
-- 	SELECT '04' x UNION ALL
-- 	SELECT '05' x UNION ALL
-- 	SELECT '06' x UNION ALL
-- 	SELECT '07' x UNION ALL
-- 	SELECT '08' x UNION ALL
-- 	SELECT '09' x UNION ALL
-- 	SELECT '10' x UNION ALL
-- 	SELECT '11' x UNION ALL
-- 	SELECT '12' x
-- ) AS m CROSS JOIN (
-- 	SELECT '01' x UNION ALL
-- 	SELECT '15' x
-- ) AS d ORDER BY ref_dt;

DELETE FROM sb_marketing.sl_lookalike_sampling_dates
WHERE ref_dt NOT BETWEEN 
	(SELECT f_dt FROM sb_marketing.sl_lookalike_vars) 
	AND 
	(SELECT l_dt FROM sb_marketing.sl_lookalike_vars);

SELECT * FROM sb_marketing.sl_lookalike_sampling_dates ORDER BY ref_dt;

COMMIT;
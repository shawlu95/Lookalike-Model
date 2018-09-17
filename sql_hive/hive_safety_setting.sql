-- If you see the following error, add these two lines in front of your code.
-- ------------------------------------------------------------
-- Error while compiling statement: 
-- FAILED: SemanticException Cartesian products are disabled for safety reasons. 
-- If you know what you are doing, please make sure that hive.strict.checks.cartesian.
-- product is set to false and that hive.mapred.mode is not set to 'strict' to enable them.
-- ------------------------------------------------------------
SET hive.strict.checks.large.query = false; 
SET hive.mapred.mode = nonstrict; 
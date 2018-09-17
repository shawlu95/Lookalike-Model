README

The series of .sql files in the hive_sql directory is designed for producing the complete feature table for the lookalike model. 

FILENAME
The first character of filename denotes the order by which the files should be run. Run the files in increasing numeric order. For example, file starting with '2' cannot be run prior to file starting with '1' has been run. 

The second character of filename denotes whether the file can be run in parallel. For example, file starting with '2b' can be run independently with file starting with '2a' at the same time.

The remaining character of the filename denotes the name of the table the file should output. For example, "0a_sl_lookalike_vars.sql" will output the table 'atlantis.0a_sl_lookalike_vars.' The characters 'sl' stands for initials of Shaw Lu, who created the lookalike model. In case of confusion, contact Shaw at shawlu95@gmail.com.

TABLES
The following tables will be created. Only the last table is used by the lookalike model. The rest of the tables are intermediate ones, and can be deleted after the final table has been filled.
	atlantis.sl_lookalike_vars
	atlantis.sl_lookalike_sampling_dates
	atlantis.sl_lookalike_active_customers
	atlantis.sl_lookalike_active_customer_activity_log
	atlantis.sl_lookalike_daily_sale
	atlantis.sl_lookalike_daily_view
	atlantis.sl_lookalike_features_p1
	atlantis.sl_lookalike_features_p2
	atlantis.sl_lookalike_features
	atlantis.sl_lookalike_features_final

HOW TO USE
The sample code tabulates customer features by the date Sept 1, 2018. Most recent 1 year history is taken into account. Variable first date (f_dt) denotes the earliest date included (Sept 1, 2017); last date(l_dt) denotes the most recent date included (Sept 1, 2018); reference date(ref_dt) denotes the reference date, which can be any date between l_dt and f_dt for debugging purporse. In the final table, ref_dt is the same as l_dt.

The sl_lookalike_sampling_dates table specifies a series of reference date (ref_dt) between first date (f_dt) and last date (l_dt), taken twice a month. Altough only the last reference date is used in the final model. Multiple reference dates provide a chance to observe how each feature evolve over time (warning, only the last reference date uses the full-year data).

WARNING:
Unlike Redshift, HIVE does not allow using (SELECT f_dt FROM atlantis.sl_lookalike_vars) as a subclause, rendering the sl_lookalike_vars table useless (except for bookkepping convenience). To apply the model to a different time range, you MUST replace EVERY occurence of hard-coded dates in every filebelow:
	0a_sl_lookalike_vars.sql
	0b_sl_lookalike_sampling_dates.sql
	4a_sl_lookalike_features_p1.sql
	4a_sl_lookalike_features_p2.sql
	6_sl_lookalike_features_final.sql
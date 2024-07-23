-- Set some limits on resource usage by DuckDB
PRAGMA enable_progress_bar;
SET default_null_order = 'NULLS LAST';
SET threads = 8;
SET memory_limit = '3GB';
SET max_memory = '3GB';

-- 1) Read all certificates.csv files into a raw_certificates table
CREATE TABLE raw_certificates AS 
SELECT *
FROM '/home/jose/code/epc_analysis/raw_data/*/certificates.csv';
-- Took ~7 minutes

-- 1) Read all recommendations.csv files into a raw_recommendations table
CREATE TABLE raw_recommendations AS 
SELECT *
FROM '/home/jose/code/epc_analysis/raw_data/*/recommendations.csv';
-- Took ~3 minutes

-- Check how many rows we have imported
SELECT COUNT(*)
FROM raw_certificates;
-- 26,286,559
SELECT COUNT(*)
FROM raw_recommendations;
-- 102,610,085

-- After these tables have been loaded, we have ~5.9GB of disk usage in the duckdb directory



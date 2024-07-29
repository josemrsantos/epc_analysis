-- Set some limits on resource usage by DuckDB
PRAGMA enable_progress_bar;
SET default_null_order = 'NULLS LAST';
SET threads = 8;
SET memory_limit = '3GB';
SET max_memory = '3GB';


----------------------------------------------------------------------------
-- Stage 1: Get only the latest (current) certifications and recommendations
----------------------------------------------------------------------------

-- Create table temp_order
CREATE TABLE temp_order AS
SELECT ROW_NUMBER() OVER(PARTITION BY UPRN ORDER BY INSPECTION_DATE DESC) AS row_order, UPRN , LMK_KEY 
FROM raw_certificates c 
;
-- ~40 seconds

-- CREATE table last_certificates
CREATE TABLE last_certificates AS
SELECT *
FROM raw_certificates c
INNER JOIN temp_order t ON c.LMK_KEY = t.LMK_KEY
WHERE t.row_order=1;
-- ~ 8 minutes


-- CREATE table last_recommendations
CREATE TABLE last_recommendations AS
SELECT r.*
FROM raw_recommendations r
INNER JOIN last_certificates c ON r.LMK_KEY = c.LMK_KEY;
-- 2.5 minutes

-- Check how many rows we have imported
SELECT COUNT(*)
FROM last_certificates;
-- 18,273,518 (From the raw 26,286,559)
SELECT COUNT(*)
FROM last_recommendations;
-- 69,354,865 (From the raw 102,610,085)



----------------------------------------------------------------------------
-- Stage 2: Remove PII data
----------------------------------------------------------------------------
-- Might give indication of the location of the house
ALTER TABLE last_certificates DROP address;
-- Might give indication of the location of the house
ALTER TABLE last_certificates DROP address1; 
-- Might give indication of the location of the house
ALTER TABLE last_certificates DROP address2;
-- Might give indication of the location of the house
ALTER TABLE last_certificates DROP address3;
-- Some postcode only have 1 or 2 houses
ALTER TABLE last_certificates DROP postcode; 
-- This gives the exact location of the house
ALTER TABLE last_certificates DROP uprn;
-- This seems related to the uprn. And we also don't really need it.
ALTER TABLE last_certificates DROP building_reference_number; 
CHECKPOINT;

----------------------------------------------------------------------------
-- Stage 3: Clean/merge some fields in the certificates 
----------------------------------------------------------------------------
CREATE TABLE certificates AS 
SELECT *
     , CASE TENURE WHEN 'owner-occupied' THEN 'owner-occupied'
                   WHEN 'rental (private)' THEN 'rental (private)'
                   WHEN 'rental (social)' THEN 'rental (social)'
                   ELSE 'Other' END AS tenure_agg
     , try_cast(CONSTRUCTION_AGE_BAND AS INTEGER) AS exact_construction_year
     , YEAR(LODGEMENT_DATE) AS exact_lodgement_year
FROM last_certificates ;
-- < 1 minute

-- Remove some strange entries on the total_floor_size
-- I did a few spot checks and values < 6.5 or > 500 did not make sense (assuming these are sq m) 
-- , yet we have 33491, before setting these records with TOTAL_FLOOR_AREA=NULL
--SELECT count(*)
--FROM certificates
--WHERE TOTAL_FLOOR_AREA > 500 OR TOTAL_FLOOR_AREA < 6.5
--;
UPDATE certificates 
SET TOTAL_FLOOR_AREA = NULL 
WHERE TOTAL_FLOOR_AREA < 6.5 OR TOTAL_FLOOR_AREA > 500;

-- Remove UPRN_1
ALTER TABLE certificates DROP UPRN_1;
-- Remobe LMK_KEY_1
ALTER TABLE certificates DROP LMK_KEY_1;
-- Remove UPRN_SOURCE
ALTER TABLE certificates DROP UPRN_SOURCE;
-- Remove WIND_TURBINE_COUNT (not enough in the dataset)
ALTER TABLE certificates DROP WIND_TURBINE_COUNT;

-- Fix some constuction dates that seem to be typos
-- We only have a few (less than 50) certificats with dates in the future, so it is safer to ignore those
UPDATE certificates 
SET CURRENT_ENERGY_RATING = 'INVALID!'
WHERE exact_construction_year > 2024;
UPDATE certificates
SET exact_construction_year = NULL
WHERE exact_construction_year > 2024;


----------------------------------------------------------------------------
-- Stage 4: Clean/merge some fields in the recommendations 
----------------------------------------------------------------------------
-- Code to fix1: Set single values to value - value (eg £13 -> '13 - 13')
UPDATE last_recommendations
SET indicative_cost = replace(replace(indicative_cost, '£', ''), '-', '') || ' - ' || replace(replace(indicative_cost, '£', ''), '-', '')
WHERE trim(split_part(replace(replace(COALESCE(indicative_cost, '£0 - £0'), '£', ''), ',', ''), '-', 2))='';
-- Code to fix2: Set negative values to positive (eg -£13  -> '13 - 13')
UPDATE last_recommendations
SET indicative_cost = replace(replace(indicative_cost, '£', ''), '-', '') || ' - ' || replace(replace(indicative_cost, '£', ''), '-', '')
WHERE trim(split_part(replace(replace(COALESCE(indicative_cost, '£0 - £0'), '£', ''), ',', ''), '-', 1)) = '';
-- New table LAST_RECOMMENDATIONS_COST
CREATE TABLE recommendations AS
SELECT trim(split_part(replace(replace(COALESCE(indicative_cost, '£0 - £0'), '£', ''), ',', ''), '-', 1))::INT AS min_spend
     , trim(split_part(replace(replace(COALESCE(indicative_cost, '£0 - £0'), '£', ''), ',', ''), '-', 2))::INT AS max_spend
     , *
FROM last_recommendations;

----------------------------------------------------------------------------
-- Stage 5: Drop no longer needed tables
----------------------------------------------------------------------------
DROP TABLE last_recommendations;
DROP TABLE last_certificates;
DROP TABLE raw_recommendations;
DROP TABLE raw_certificates;
DROP TABLE temp_order;

CHECKPOINT; -- In DuckDB this statement synchronizes data in the write-ahead log (WAL) to the database data file


----------------------------------------------------------------------------
-- Stage 6: Convert resulting tables to CSV files (to be able to send them to Tableau Public)
----------------------------------------------------------------------------

COPY recommendations TO '/home/jose/code/epc_analysis/output_tables/recommendations.csv' (HEADER, DELIMITER ',');
-- < 1 minute
-- 15GB (when the query "finished", the file size was only 2.6GB)
-- 18,273,519 rows (We have 18,273,518 rows in the table, but this includes the header)
COPY certificates TO '/home/jose/code/epc_analysis/output_tables/certificates.csv' (HEADER, DELIMITER ',');
-- < 2 minutes,
-- 11 GB
-- 69,354,866 (We have 69,354,865 rows in the table, but this includes the header)

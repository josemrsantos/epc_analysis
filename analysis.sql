-----------------------------------------
-- New built vs old built EPC rating
-----------------------------------------

-- Highest and lowest evergy rating, by construction Year (with over 1000 properties built that Year)
SELECT EXACT_CONSTRUCTION_YEAR::varchar
     , min(CURRENT_ENERGY_RATING) AS highest_energy_rating
     , max(CURRENT_ENERGY_RATING) AS lowest_energy_rating
     , count(*)
FROM certificates
GROUP BY 1
HAVING COUNT(*) > 1000
  AND max(CURRENT_ENERGY_RATING) <> 'INVALID!'
ORDER BY 1 DESC NULLS LAST;
-- In later Years (since 2009), the highest EPC ratings seem to be A (the lowest is still G though)
-- "CAST(EXACT_CONSTRUCTION_YEAR AS VARCHAR)","highest_energy_rating","lowest_energy_rating","count_star()"
-- "2024",A,G,8430
-- "2023",A,G,47415
-- "2022",A,G,123528
-- "2021",A,G,172040
-- "2020",A,G,77159
-- "2019",A,G,58656
-- "2018",A,G,28968
-- "2017",A,E,12304
-- "2016",A,F,7047
-- "2015",A,E,1438
-- "2014",A,E,3213


-- lowest, average and highest evergy efficiency, by construction Year (with over 1000 properties built that Year)
SELECT EXACT_CONSTRUCTION_YEAR::varchar
     , min(CURRENT_ENERGY_EFFICIENCY) AS lowest_energy_efficiency
     , avg(CURRENT_ENERGY_EFFICIENCY)::BIGINT AS average_energy_efficiency
     , max(CURRENT_ENERGY_EFFICIENCY) AS highest_energy_efficiency
FROM certificates
GROUP BY 1
HAVING COUNT(*) > 1000
  AND max(CURRENT_ENERGY_RATING) <> 'INVALID!'
ORDER BY 1 DESC NULLS LAST;
-- Despite a few outliners (on the max and min), the average energy efficiency for new properties, seem to be on the 83/84 mark.
-- "CAST(EXACT_CONSTRUCTION_YEAR AS VARCHAR)","lowest_energy_efficiency","average_energy_efficiency","highest_energy_efficiency"
-- "2024",6,83,211
-- "2023",1,83,164
-- "2022",1,83,164
-- "2021",1,83,991
-- "2020",1,83,135
-- "2019",1,84,220
-- "2018",15,84,122
-- "2017",39,84,108
-- "2016",23,84,115
-- "2015",43,83,104
-- "2014",52,84,111


-----------------------------------------
-- How much money must be spent to move 
-- above the F Ratting (E is the minimum 
-- allowed by law to rent a home privatly) 
--------
SELECT c.CURRENT_ENERGY_RATING
     , c.POTENTIAL_ENERGY_RATING 
 --    , min(r.MIN_SPEND) AS min_spend REMOVED AS FOR MOST CASES THIS IS 0. Another case of bad data quality ?
     , max(r.MAX_SPEND) AS max_spend
     , (SUM(r.MIN_SPEND) / count(c.LMK_KEY))::INT AS average_min_sped_per_home
     , count(c.*) AS number_of_homes
FROM certificates c
LEFT JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
WHERE c.CURRENT_ENERGY_RATING IN ('F', 'G') 
  AND c.POTENTIAL_ENERGY_RATING IN ('A', 'B', 'C', 'D', 'E')
  AND c.tenure_agg = 'rental (private)'
GROUP BY 1,2
ORDER BY 4 DESC;
-- On average, the maximum that a home should need to improve (from F to A), would be £3,609, 
-- but there is a "spend cap" (of £3,500) for reaching the minimum allowed by law (Rating E)
-- A landlord spending £3,500 can apply for an exception, even if not able to reach the rating E
-- It is also worth noticing that there are 85,354 homes that could improve from F to C at an average cost of £2161
-- "CURRENT_ENERGY_RATING","POTENTIAL_ENERGY_RATING","max_spend","average_min_sped_per_home","number_of_homes"
-- F,A,25000,3668,26771
-- G,A,25000,3562,9819
-- G,B,25000,2917,17268
-- F,B,25000,2675,58045
-- G,C,25000,2498,23396
-- G,D,25000,2252,16955
-- F,C,25000,2161,85364
-- G,E,25000,1519,11994
-- F,D,25000,1362,55046
-- F,E,25000,663,57945


-----------------------------------------
-- Total spend in England and Wales to get 
-- above the F Ratting (E is the minimum 
-- allowed by law to rent a home privatly) 
-----------------------------------------
SELECT SUM(r.MIN_SPEND) AS total_min_spend 
     , SUM(r.MAX_SPEND) AS total_max_spend
FROM certificates c
LEFT JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
WHERE c.CURRENT_ENERGY_RATING in ('F', 'G') 
--  AND c.CURRENT_ENERGY_RATING <> 'INVALID!'
  AND c.POTENTIAL_ENERGY_RATING in ('A', 'B', 'C', 'D', 'E')
  AND c.tenure_agg = 'rental (private)'
;
-- Getting all privately rented homes to at least the E rating would cost in total between £751,483,481 and $1,455,312,401


-----------------------------------------
-- Total spend in England and Wales to get 
-- above the F Ratting (E is the minimum 
-- allowed by law to rent a home privatly),
-- by spending no more than £3500.  
-----------------------------------------
WITH only_one_recomendation AS (
 SELECT c.LMK_KEY
      , count(r.*) AS total
FROM certificates c
LEFT JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
GROUP BY 1 
HAVING count(r.*) = 1      
)
SELECT MIN(r.MIN_SPEND) AS min_spend 
     , MAX(r.MAX_SPEND) AS max_spend
     , count(DISTINCT c.LMK_KEY) AS number_of_homes 
FROM certificates c
-- INNER JOIN only_one_recomendation one ON one.LMK_KEY = c.LMK_KEY 
LEFT JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
WHERE c.CURRENT_ENERGY_RATING in ('F', 'G') 
  AND r.max_spend < 3500
  AND r.MIN_SPEND > 0 -- TO remove possible glitches in the data
  AND c.POTENTIAL_ENERGY_RATING in ('A', 'B', 'C', 'D', 'E')
  AND c.tenure_agg = 'rental (private)'
;
-- There are 41,444 homes in England/Wales that are being rented in the private sector, 
-- where the landlord would need to spend less than £3,500 to upgrade it to the minimum required by law.
-- "min_spend","max_spend","number_of_homes"
-- 5,3200,41444
-- There are 159 homes that would only need to make 1 recommended change. (commented INNER JOIN)
-- I have not included the query here, but there are 4 homes where the landlord would need to spend £30 to be within the Law.
-- "min_spend","max_spend","number_of_homes"
-- 15,3000,159


-- This is a collection of inconsistencies in the dataset. We have possible:
--  - Input errors
--  - Recommendations for improvements to the same rating
--  - Recommendations for improvements to the rating F (for properties that are being rented) when the minimum by law is the rating E
SELECT c.TENURE_AGG 
     , c.CURRENT_ENERGY_RATING
     , c.POTENTIAL_ENERGY_RATING 
     , count(DISTINCT c.LMK_KEY) AS total_number_of_homes
     , avg(r.MIN_SPEND)::INT average_min_spend
     , CASE WHEN c.CURRENT_ENERGY_RATING < c.POTENTIAL_ENERGY_RATING THEN 'Input error ?'
          WHEN c.CURRENT_ENERGY_RATING = c.POTENTIAL_ENERGY_RATING THEN 'Improvement to the same rating ?'
          ELSE 'Improvement to bellow the Rating E' END AS possible_data_error
FROM certificates c
LEFT JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
WHERE POTENTIAL_ENERGY_RATING > 'E'
  AND CURRENT_ENERGY_RATING <> 'INVALID!'
  AND POTENTIAL_ENERGY_RATING <> 'INVALID!'
  AND tenure_agg = 'rental (private)'
GROUP BY 1,2,3;
-- There is a significant ammount of homes that have a low EPC rating and no recommendation is made to achieve (at least) E
-- "tenure_agg","CURRENT_ENERGY_RATING","POTENTIAL_ENERGY_RATING","total_number_of_homes","average_min_spend","possible_data_error"
-- rental (private),E,F,1,1608,Input error ?
-- rental (private),G,F,3126,695,Improvement to bellow the Rating E
-- rental (private),F,F,5343,663,Improvement to the same rating ?
-- rental (private),G,G,2080,663,Improvement to the same rating ?



-- Total number of homes  being rented (private) with an EPC bellow E
SELECT c.TENURE_AGG 
     , count(c.LMK_KEY) AS total_number_home
FROM certificates c
WHERE CURRENT_ENERGY_RATING in ('F', 'G') -- Current EPC rating is either F or G
  AND tenure_agg = 'rental (private)' -- Home is being rented private
GROUP BY 1;
-- These home might be being rented illegally or not. No way to tell from the dataset alone as 
-- the information about exceptions seems to be missing
-- rental (private)	66,363


-- Total number of homes (private or social) being rented with an EPC bellow E and no recommendation to go to E or above
SELECT c.TENURE_AGG 
     , count(c.LMK_KEY) AS total_number_home
FROM certificates c
WHERE POTENTIAL_ENERGY_RATING in ('F', 'G')
  AND CURRENT_ENERGY_RATING in ('F', 'G') -- Current EPC rating is either F or G
  AND CURRENT_ENERGY_RATING <> 'INVALID!'
  AND POTENTIAL_ENERGY_RATING <> 'INVALID!'
  AND tenure_agg = 'rental (private)' -- Private rent
GROUP BY 1;
-- These homes are not only being rented illegally, but also don't seem to have a recommendation to improve to the
-- minimum required by law (EPC rating E).
-- rental (private)	10549

-----------------------------------------
-- New built vs old built EPC rating
-----------------------------------------

-- Highest and lowest evergy rating, by construction Year
SELECT EXACT_CONSTRUCTION_YEAR::varchar
     , min(CURRENT_ENERGY_RATING) AS highest_energy_rating
     , max(CURRENT_ENERGY_RATING) AS lowest_energy_rating
     , count(*)
FROM certificates
GROUP BY 1
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
-- "2013",A,E,847
-- "2012",A,D,310
-- "2011",A,F,110
-- "2010",A,F,364
-- "2009",A,D,83
-- "2008",B,D,33
-- "2007",A,E,29
-- "2006",B,E,22
-- "2005",A,E,58
-- "2004",C,F,9
-- "2003",B,C,7
-- "2002",B,D,14
-- "2001",C,C,1
-- "2000",C,D,13
-- "1998",C,C,4
-- "1996",C,D,17
-- "1995",C,E,10
-- "1993",C,C,1
-- "1992",C,D,3
-- "1990",C,D,4
-- "1987",C,D,3
-- "1985",B,D,17
-- "1983",C,C,9
-- "1981",C,D,4
-- "1980",C,E,6
-- "1975",A,E,26
-- "1972",B,B,1
-- "1970",B,E,38
-- "1969",C,C,1
-- "1967",C,D,3
-- "1965",B,G,45
-- "1963",E,G,49
-- "1960",B,E,11
-- "1957",F,G,2
-- "1956",C,C,7
-- "1954",C,C,1
-- "1952",D,D,1
-- "1950",A,E,27
-- "1947",C,D,4
-- "1945",B,B,1
-- "1940",C,E,26
-- "1938",B,C,4
-- "1935",C,C,6
-- "1930",B,E,94
-- "1929",B,D,65
-- "1927",E,E,1
-- "1925",C,C,3
-- "1920",B,E,43
-- "1915",D,D,1
-- "1910",B,D,11
-- "1907",B,C,5
-- "1904",B,D,26
-- "1903",C,C,1
-- "1902",C,C,1
-- "1900",A,F,391
-- "1891",B,B,1
-- "1890",A,D,18
-- "1889",C,D,2
-- "1888",C,C,1
-- "1885",B,B,1
-- "1881",D,D,1
-- "1880",B,E,11
-- "1876",E,E,1
-- "1870",C,C,2
-- "1867",E,E,1
-- "1851",C,C,3
-- "1850",B,E,7
-- "1849",B,C,7
-- "1836",C,C,1
-- "1830",E,E,1
-- "1825",E,E,1
-- "1820",D,D,2
-- "1805",C,D,2
-- "1800",B,F,23
-- "1783",C,C,1
-- "1750",E,E,1
-- "1700",C,C,3
-- "1600",C,C,1
-- NULL,A,INVALID!,17730355



-- Year, current_energy_rating
WITH by_year AS 
(
SELECT EXACT_CONSTRUCTION_YEAR
     , count(*) AS total
FROM certificates
GROUP BY 1
)
SELECT '-- ' AS com
     , certificates.EXACT_CONSTRUCTION_YEAR::varchar
     , CURRENT_ENERGY_RATING
     , ((count(*) * 100) / by_year.total)::INT AS percentage
FROM certificates
INNER JOIN by_year ON by_year.EXACT_CONSTRUCTION_YEAR = certificates.EXACT_CONSTRUCTION_YEAR
GROUP BY 1, 2, 3, by_year.total
HAVING ((count(*) * 100) / by_year.total)::INT > 50
ORDER BY 2 DESC, 3 ASC NULLS LAST;
-- Running this query clearly shows that since 2009 the most common EPC Ratting is still B
--- 2024	B	71
-- 	2023	B	75
-- 	2022	B	81
-- 	2021	B	83
-- 	2020	B	87
-- 	2019	B	89
-- 	2018	B	92
-- 	2017	B	91
-- 	2016	B	93
-- 	2015	B	88
-- 	2014	B	94
-- 	2013	B	91
-- 	2012	B	77
-- 	2011	B	57
-- 	2010	B	89
-- 	2009	C	64
-- 	2008	C	79
-- 	2007	C	69
-- 	2004	D	56
-- 	2003	B	71
-- 	2002	B	71
-- 	2001	C	100
-- 	2000	C	69
-- 	1998	C	100
-- 	1996	D	88
-- 	1995	C	80
-- 	1993	C	100
-- 	1992	C	67
-- 	1987	C	67
-- 	1985	B	94
-- 	1983	C	100
-- 	1981	C	75
-- 	1980	C	67
-- 	1975	A	85
-- 	1972	B	100
-- 	1970	C	68
-- 	1969	C	100
-- 	1967	D	67
-- 	1963	E	69
-- 	1956	C	100
-- 	1954	C	100
-- 	1952	D	100
-- 	1950	C	52
-- 	1947	C	75
-- 	1945	B	100
-- 	1940	C	88
-- 	1935	C	100
-- 	1930	C	69
-- 	1929	B	54
-- 	1927	E	100
-- 	1925	C	100
-- 	1915	D	100
-- 	1910	C	64
-- 	1907	C	80
-- 	1903	C	100
-- 	1902	C	100


-----------------------------------------
-- How much money must be spent to move 
-- above the F Ratting (E is the minimum 
-- allowed by law to rent a home) 
-----------------------------------------

SELECT '-- ' AS com
     , c.CURRENT_ENERGY_RATING
     , c.POTENTIAL_ENERGY_RATING 
     , SUM(r.MIN_SPEND) AS total_min_spend
     , SUM(r.MAX_SPEND) AS total_max_spend
     , (SUM(r.MIN_SPEND) / count(c.LMK_KEY))::INT AS average_min_sped_per_home
FROM certificates c
INNER JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
WHERE c.CURRENT_ENERGY_RATING > 'E' 
  AND c.CURRENT_ENERGY_RATING <> 'INVALID!'
  AND c.POTENTIAL_ENERGY_RATING < c.CURRENT_ENERGY_RATING
GROUP BY 1,2,3
ORDER BY 6 DESC;
-- On average, the maximum that a home should need to improve (from F to A), would be £3,609, 
-- but there is a "spend cap" (of £3,500) for reaching the minimum allowed by law (Rating E)
-- A landlord spending £3,500 can apply for an exception, even if not able to reach the rating E
-- 	F	A	612785835	1092723850	3609
-- 	G	A	196452450	356094860	3522
-- 	G	B	549157860	1045951270	2672
-- 	G	C	568848769	1090930029	2567
-- 	F	B	1969574380	3630856310	2516
-- 	G	D	350065255	668020250	2459
-- 	F	C	2480033188	4625975778	2282
-- 	G	E	175939920	338002570	1954
-- 	F	D	985474356	1840123716	1828
-- 	G	F	98394022	192204592	1037
-- 	F	E	376523996	735581946	951

-- Homes that only have recommendations to move up to the energy rating of F (bellow the minimum allowed by law to be able to rent a home)
SELECT c.TENURE_AGG 
     , c.CURRENT_ENERGY_RATING
     , c.POTENTIAL_ENERGY_RATING 
     , count(c.LMK_KEY) AS total_number_home
FROM certificates c
INNER JOIN recommendations r ON c.LMK_KEY = r.LMK_KEY
WHERE POTENTIAL_ENERGY_RATING > 'E'
  AND CURRENT_ENERGY_RATING <> 'INVALID!'
  AND POTENTIAL_ENERGY_RATING <> 'INVALID!'
  AND tenure_agg = 'rental (private)'
GROUP BY 1,2,3;
-- There is a significant ammount of homes that have a low EPC rating and no recommendation is made to achieve (at least) E
-- rental (private)	E	F	3        <- Input error ?
-- rental (private)	F	F	23085
-- rental (private)	G	F	14855
-- rental (private)	G	G	8166


-- Total number of homes (private or social) being rented with an EPC bellow E
SELECT c.TENURE_AGG 
     , count(c.LMK_KEY) AS total_number_home
FROM certificates c
WHERE POTENTIAL_ENERGY_RATING in ('F', 'G')
  AND CURRENT_ENERGY_RATING in ('F', 'G') -- Current EPC rating is either F or G
  AND CURRENT_ENERGY_RATING <> 'INVALID!'
  AND POTENTIAL_ENERGY_RATING <> 'INVALID!'
  AND tenure_agg like 'rental%' -- Home is being rented
GROUP BY 1;
-- These homes are not only being rented illegally, but also don't seem to have a recommendation to improve to the
-- minimum required by law (EPC rating E).
-- rental (private)	10549
-- rental (social)	2973

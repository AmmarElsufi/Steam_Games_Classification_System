SHOW DATABASES  ;
USE steam_games_recommendations_system ; 
SHOW TABLES ; 

-- ----------------------------------------------------------------------------------------------------------------------------------------
## Making a data clone 

-- CREATE TABLE  data_clone
-- 	LIKE steam_games_extracted_phase_1 ; 

-- INSERT INTO data_clone 
-- 	SELECT * FROM steam_games_extracted_phase_1 ; 


-- ---------------------------------------------------------------------------------------------------------------------------------------
DESC data_clone ; 
SELECT * FROM  data_clone ; 
SELECT COUNT(*) FROM  data_clone ; 
-- --------------------------
# fixing 
UPDATE data_clone 
	SET title = TRIM(title) ; 
    
UPDATE data_clone 
	SET rating = TRIM(rating) ; 

-- -----------------------------
## FiXing title entries 

 -- DETECTING 
SELECT * FROM data_clone
WHERE title REGEXP '[^A-Za-z0-9 ]';

SELECT COUNT(*) FROM data_clone
WHERE title REGEXP '[^A-Za-z0-9 ]';

-- Update the titles by removing unwanted characters based on the pattern
UPDATE data_clone 
	SET title = REGEXP_REPLACE(title , "[^A-Za-z0-9 ]" , " ")
	WHERE title REGEXP "[^A-Za-z0-9 ]" ; 

UPDATE data_clone 
	SET title = TRIM(title) ;

SELECT * FROM data_clone 
	WHERE title = "" ; 
    
SELECT * FROM data_clone 
	WHERE title = "" ; 

DELETE FROM data_clone 
	WHERE title = "" ; 

-- --------------------------
# Ckeck from Dublicats
WITH duplicated_titles AS (
	SELECT app_id , COUNT(*) 
		FROM data_clone
		GROUP BY 1
		HAVING COUNT(*) > 1 )
	
SELECT COUNT(*) FROM data_clone ;
-- --------------------------
# editing date foramt
SELECT DISTINCT date_release
FROM data_clone
LIMIT 10 ;

SELECT COUNT(*) FROM 
	(SELECT STR_TO_DATE(date_release ,"%Y-%c-%d")  FROM  data_clone) AS converted_date ; 

UPDATE data_clone 
	SET date_release =  STR_TO_DATE(date_release ,"%Y-%c-%d") ;

ALTER TABLE data_clone 
	MODIFY date_release		DATE ;  
    
DESC data_clone ;
 
-- ---------------------------------------------------------------------------------------------------------------------------------------------------
## DATA EXPLORATION
SELECT * FROM data_clone LIMIT 50; 
SELECT COUNT(*) FROM  data_clone ;

-- ----------------------------------------------
# Date range
SELECT MAX(date_release) , MIN(date_release) , ( YEAR(MAX(date_release)) - YEAR(MIN(date_release)))  AS years_date_rage    
	FROM data_clone ; 

-- --------------------------------------------
# Categorical date freq and percentage

SELECT rating , COUNT(rating)  AS freq , COUNT(rating)/(SELECT COUNT(*) FROM steam_games_extracted_phase_1 )*100  AS percentage
	FROM data_clone 
    GROUP BY rating 
    ORDER BY freq DESC  ;

SELECT win , COUNT(win)  AS freq , COUNT(win)/(SELECT COUNT(*) FROM steam_games_extracted_phase_1 )*100  AS percentage
	FROM data_clone 
    GROUP BY win 
    ORDER BY freq DESC ;

SELECT mac , COUNT(mac)  AS freq , COUNT(mac)/(SELECT COUNT(*) FROM steam_games_extracted_phase_1 )*100  AS percentage
	FROM data_clone 
    GROUP BY mac
    ORDER BY freq DESC ;
    
SELECT linux , COUNT(linux)  AS freq , COUNT(linux)/(SELECT COUNT(*) FROM steam_games_extracted_phase_1 )*100  AS percentage
	FROM data_clone 
    GROUP BY linux
    ORDER BY freq DESC ;

SELECT steam_deck , COUNT(steam_deck)  AS freq , COUNT(steam_deck)/(SELECT COUNT(*) FROM steam_games_extracted_phase_1 )*100  AS percentage
	FROM data_clone 
    GROUP BY steam_deck
    ORDER BY freq DESC ;

SELECT * FROM data_clone --  I just wanna know :|
	WHERE steam_deck = "FALSE" ; 

-- --------------------------------------------
# Grouping and Aggregation

SELECT rating  ,
	   COUNT(app_id)  AS  num_of_games , 
       ROUND(AVG(num_of_recommendations)) AS avg_of_recommendations , 
       ROUND(AVG(num_of_user_reviews)) AS avg_of_user_reviews , 
       ROUND(AVG(price_final)) AS avg_price_for_this_rating , 
	   ROUND(AVG(num_of_played_hours)) AS avg_played_hours
	FROM data_clone 
	GROUP BY 1 ; 
-- --------------------------------------------
-- Asking some questions 

SELECT title , rating , date_release , price_final , discount  FROM  data_clone 
	WHERE rating = "Overwhelmingly Positive"
    ORDER BY price_final DESC ;
    
    
SELECT title , rating , date_release , price_final , discount  FROM  data_clone 
	WHERE rating = "Overwhelmingly Positive"
    ORDER BY date_release ASC ;

SELECT title , rating , date_release , price_final , discount  FROM  data_clone 
	WHERE rating = "Overwhelmingly Positive" AND price_final = 0
    ORDER BY date_release DESC ;

SELECT title , rating , price_final , discount , date_release FROM data_clone 
	WHERE price_final = (SELECT MAX(price_final) FROM data_clone) ;  

SELECT COUNT(*)/(SELECT COUNT(*) FROM data_clone where price_final > 30 ) 
	FROM data_clone 
	WHERE price_final > 30 AND rating = "Overwhelmingly Positive" ;
-- --------------------------------------------
SELECT title , rating , price_final , price_original , discount , date_release FROM data_clone 
	WHERE discount != 0 ; 

SELECT COUNT(*) , ROUND((COUNT(*)/45523)*100)  AS per FROM (SELECT title , rating , price_final , price_original , discount , date_release FROM data_clone 
	WHERE discount != 0 ) AS dicounted_games ; 
    
SELECT * FROM  
	(SELECT title , rating , price_final , price_original , discount , date_release FROM data_clone 
	WHERE discount != 0 ) AS dicounted_games 
    WHERE rating = "Overwhelmingly Positive" ;
    
    SELECT * FROM  
	(SELECT title , rating , price_final , price_original , discount , date_release FROM data_clone 
	WHERE discount != 0 ) AS dicounted_games 
    WHERE rating = "Overwhelmingly Positive" ;
    
    
    SELECT COUNT(*) FROM  
	(SELECT title , rating , price_final , price_original , discount , date_release FROM data_clone 
	WHERE discount != 0 ) AS dicounted_games 
    WHERE rating = "Overwhelmingly Positive" ;
    

-- -------------------------------------------
## Analyzing Time Series Data

WITH time_ana AS (
SELECT YEAR(date_release) AS `year` , 
		MONTH (date_release) AS `month` ,
        COUNT(app_id) AS games_count   ,
        SUM(price_final) AS sum_price
	FROM data_clone
	GROUP BY 1 , 2 
    ORDER BY 1 , 2 )
SELECT `year` , `month` , games_count FROM time_ana WHERE games_count IN ( SELECT MAX(games_count) AS max_games_count FROM time_ana GROUP BY `year`)  ; 


SELECT YEAR(date_release) AS `year` , ROUND( SUM(price_final) )  AS `sum price per year`
	FROM data_clone 
    GROUP BY 1 
    ORDER BY 1 ; 


SELECT YEAR(date_release) AS `year` ,
        COUNT(*) AS `freq`  
	FROM data_clone
	GROUP BY 1 
    ORDER BY 1 ; 
    

SELECT YEAR(date_release) AS `year` , 
	   ROUND(AVG(num_of_played_hours)) AS avg_of_played_hours_for_each_game  , 
       ROUND(SUM(num_of_played_hours)) AS sum_of_played_hours 
	FROM data_clone
    GROUP BY 1 
    ORDER BY  1 ; 

SELECT YEAR(date_release) AS `year` , 
	   ROUND(AVG(num_of_user_reviews)) AS avg_of_user_reviews_for_each_game ,
	   ROUND(SUM(num_of_user_reviews)) AS sum_num_of_user_reviews
	FROM data_clone
    GROUP BY 1 
    ORDER BY  1 ;
    
    
SELECT YEAR(date_release) AS `year` , 
	   ROUND(AVG(num_of_recommendations)) AS avg_of_recommendations_for_each_game ,
	   ROUND(SUM(num_of_recommendations)) AS sum_num_of_recommendations
	FROM data_clone
    GROUP BY 1 
    ORDER BY  1 ;
    
-- --------------------------------------------------------------------

SELECT * FROM data_clone ; 

SELECT rating , ROUND(AVG(positive_ratio)) `avg positive ratio`   , ROUND(AVG(price_final)) 	AS `avg price`
	FROM data_clone
    GROUP BY 1 
    ORDER BY 2 DESC ; 

SELECT rating , ROUND(AVG(game_age)) `avg game age`
	FROM data_clone
    GROUP BY 1 
    ORDER BY 2 DESC ; 
    
SELECT  title , rating , game_age
	FROM data_clone
    ORDER BY 3 DESC ; 

-- -----------------------------------------------------------

SELECT title , rating , date_release , price_final FROM data_clone 
	WHERE YEAR(date_release) = 2018  AND  rating = "Overwhelmingly Positive" 
    ORDER BY date_release ; 

SELECT title , rating , date_release , price_final FROM data_clone 
	WHERE YEAR(date_release) = 2023  AND  rating = "Overwhelmingly Positive" 
    ORDER BY date_release ; 

-- --------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------------------
-- extracting the final data --> steam_games_extracted_phase_2
-- SELECT *
-- INTO OUTFILE 'D:\AI\Projects\full_ML_projects\steam_games_recommendations_system\extracted_data\phase_2\steam_games_extracted_phase_2.csv'
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- FROM  data_clone ; 















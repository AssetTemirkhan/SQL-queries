--Homework Assignment SQL Foundation – DDL (function)

--Tasks


--1
/*
Create a function that will return the most popular film for each country (where country is an input paramenter).
The function should return the result set in the following view: 
Query (example):select * from core.most_popular_films_by_countries(array['Afghanistan','Brazil','United States’]);
*/

CREATE SCHEMA IF NOT EXISTS core AUTHORIZATION postgres;


CREATE OR REPLACE FUNCTION core.most_popular_films_by_countries (IN select_country TEXT[] DEFAULT ARRAY['United States'])
RETURNS TABLE (country TEXT,
			   film TEXT,
			   rating MPAA_RATING,
			   language BPCHAR(20),
			   length INT2,
			   release_year YEAR,
			   rented INTEGER)
AS $$
BEGIN

RETURN QUERY
SELECT 
	rented_movies.country AS country,
	rented_movies.film AS film,
	rented_movies.rating AS rating,
	rented_movies.language AS language,  
	rented_movies.length AS length,
	rented_movies.release_year AS release_year,
	rented_movies.rented::INTEGER AS rented
FROM 
	(SELECT cou.country AS country,
			fil.title AS film,
			fil.rating,
			fil.length,
			fil.release_year,
			fil.film_id,
			cou.country_id,
			lan.name AS language,  
			COUNT (ren.rental_id) AS rented,  					--number of rented films
			ROW_NUMBER() OVER (PARTITION BY cou.country_id ORDER BY COUNT (ren.rental_id) DESC, fil.title ASC) AS row_num  --number of row by country ordered by COUNT(rental_id) DESC maximum rented number film will be first (1) on the list then ordered by film title if number of rate is the same
	FROM public.rental ren, 												
		 public.inventory inv,												
		 public.film fil, 																								
		 public.customer cus,   			   				
		 public.address addr, 								
		 public.city cit, 									
		 public.country cou,
		 public.language lan
	WHERE ren.inventory_id = inv.inventory_id AND 					
		  fil.film_id =inv.film_id AND								
		  cus.customer_id = ren.customer_id AND	
	      cus.address_id = addr.address_id AND  		
		  cit.city_id = addr.city_id AND         	
		  cou.country_id  = cit.country_id AND 
		  lan.language_id = fil.language_id AND
		  LOWER(cou.country) =  ANY (ARRAY(SELECT LOWER(x) FROM UNNEST(select_country) x))  --used to compare each value in the input array select_country with the lowercase version of the country name in the table. used UNNEST to convert the input array into a set of rows. used LOWER to convert the country name to lowercase. used ANY operator to compared lowercase country names in resulting set with the country names in the table, if there is a match condition returns TRUE and the row is included in the result set
	GROUP BY fil.film_id , cou.country_id, lan.language_id 	) AS rented_movies
WHERE rented_movies.row_num = 1  															--select film with row_num 1 (max rented number)
ORDER BY rented_movies.rented DESC, rented_movies.country ASC, rented_movies.film ASC;


END;
$$
LANGUAGE plpgsql;


/*
--Query (example):
SELECT * 
FROM core.most_popular_films_by_countries(ARRAY['Afghanistan','Brazil','United States']);

*/



--2
/*
Create a function that will return a list of films by part of the title in stock (for example, films with the word 'love' in the title).
• So, the title of films consists of ‘%...%’, and if a film with the title is out of stock, please return a message: a movie with that title was not found
• The function should return the result set in the following view (notice: row_num field is generated counter field (1,2, …, 100, 101, …))
Query (example):select * from core.films_in_stock_by_title('%love%’);
*/

CREATE OR REPLACE FUNCTION core.films_in_stock_by_title(IN select_film TEXT)
RETURNS TABLE (row_num INTEGER,
               film_title TEXT,
               language BPCHAR(20),
               customer_name TEXT,
               rental_date TIMESTAMP WITH TIME ZONE
               )
AS $$

BEGIN

RETURN QUERY
SELECT CAST(ROW_NUMBER() OVER (PARTITION BY rental_movies.language ORDER BY rental_movies.rental_date DESC) AS INTEGER) AS row_num,
       rental_movies.film_title,
       rental_movies.language,
       rental_movies.customer_name,
       rental_movies.rental_date
FROM
    (SELECT ROW_NUMBER() OVER (PARTITION BY fil.title, (cus.first_name IS NULL) ORDER BY ren.return_date DESC) AS row_num,  --use row_num to find last returned film by return date, used "cus.first_name IS NULL" to find films that have never been rented (films with data in inventory table but there is no data in rental table)   
	   fil.title AS film_title,
	   lan.name AS language,
	   CASE WHEN cus.first_name IS NULL THEN 'Not Rented Yet'
     	    WHEN cus.last_name IS NULL THEN 'Not Rented Yet'
     		ELSE cus.first_name || ' ' || cus.last_name 
	   END AS customer_name,                             --used CASE for films that have never been rented (films with data in inventory table but there is no data in rental table), for them Customer data is empty (NULL), so if there film in inventory that was never rented or not rented yet, for that films the Customer name will be "Not Rented Yet"  
	   ren.rental_date AS rental_date
	 FROM public.inventory inv						 	 --used LEFT JOIN to find all films in invertory table, there films that never been rented 
		  LEFT JOIN public.film fil      ON fil.film_id = inv.film_id
		  INNER JOIN public.language lan ON fil.language_id = lan.language_id
		  LEFT JOIN public.rental ren    ON inv.inventory_id = ren.inventory_id 
		  LEFT JOIN public.customer cus	 ON ren.customer_id = cus.customer_id
	WHERE
		(ren.return_date IS NOT NULL OR (ren.return_date IS NULL AND ren.rental_id IS NULL))  --used "return_date IS NOT NULL" to find all films that was returned and in stock, used "ren.return_date IS NULL AND ren.rental_id IS NULL" tofind allfilms that is in stock but not rented yet (never rented)
	) AS rental_movies
WHERE rental_movies.row_num = 1 AND 														  --used 1 to return all films with max return date 
      UPPER(rental_movies.film_title) LIKE '%' || UPPER(select_film) || '%';   				  --used '%' to not write % in query

IF NOT FOUND THEN
    RETURN QUERY
	SELECT 1, 																				 				--used for return in case of movie not found used all rows because if not used it there is an error message if there only message 
		   'a movie with that title'||' '|| (select_film) || ' ' || 'was not found'::TEXT AS film_title,
		   NULL::BPCHAR(20) AS language,
		   NULL::TEXT AS customer_name,
		   NULL::TIMESTAMP WITH TIME ZONE AS rental_date;  

   
END IF;  

END;
$$
LANGUAGE plpgsql;
--------
/* 
SELECT * 
FROM core.films_in_stock_by_title('love');

--not found 
SELECT * 
FROM core.films_in_stock_by_title('London');


--film that not rented yet (never rented)
SELECT * 
FROM core.films_in_stock_by_title('ACADEMY DINOSAUR');

*/

/*
IF NOT FOUND THEN
     RAISE INFO  'a movie with that title was not found'; 
*/




--Homework Assignment SQL Foundation – DDL (function)

--Tasks

--3
/*
Create function that inserts new movie with the given name in ‘film’ table. ‘release_year’, ‘language’ are optional arguments and default to current year and 
Klingon respectively. The function must return film_id of the inserted movie. 
*/


CREATE OR REPLACE FUNCTION core.add_new_film (
											  new_title TEXT, 
											  new_description TEXT DEFAULT NULL, 
											  new_release_year YEAR DEFAULT NULL, 
											  new_language_id INTEGER DEFAULT NULL,
											  new_original_language_id INTEGER DEFAULT NULL,
											  new_rental_duration INTEGER DEFAULT 3,
											  new_rental_rate NUMERIC(4, 2) DEFAULT 4.99,
											  new_length INTEGER DEFAULT 60,
											  new_replacement_cost NUMERIC(5, 2) DEFAULT 19.99,
											  new_rating MPAA_RATING DEFAULT 'G'::MPAA_RATING,
											  new_last_update TIMESTAMP WITH TIME ZONE DEFAULT NOW()
											)
RETURNS INTEGER AS $$
DECLARE
    film_id INTEGER;
BEGIN
  -- Check if the release year is given, use the current year if year not added
  IF new_release_year IS NULL THEN
    new_release_year := EXTRACT(YEAR FROM NOW());
  END IF;
  
  -- Get the language_id for the given language
  IF new_language_id IS NULL THEN   		--use the Klingon language_id if language not added
  SELECT language_id INTO new_language_id 
  FROM language 
  WHERE LOWER(name) = LOWER('Klingon');
	
  -- if the language Klingon does not exist, insert it to language table
  IF NOT FOUND THEN 
  INSERT INTO language (name)
  SELECT name
  FROM 
  (SELECT 'Klingon' AS name) AS new_language
  WHERE NOT EXISTS (SELECT name FROM "language" lan WHERE LOWER(lan.name) = LOWER(new_language.name))  --cheking language data for dublicates
  RETURNING language_id INTO new_language_id;
  END IF;
ELSE
	new_language_id := new_language_id;      --if languange_id is added by user used this id 
END IF;

  -- insert the new film
	INSERT INTO film (title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update)
	SELECT * FROM (
			VALUES (new_title, new_description, new_release_year, new_language_id, new_original_language_id, new_rental_duration, new_rental_rate, new_length, new_replacement_cost, new_rating, new_last_update)
	)AS add_film (title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update)
	WHERE (UPPER(add_film.title), add_film.release_year) NOT IN (SELECT UPPER(title), release_year    --checking film title, year for dublicates
											 				     FROM film)
	RETURNING film.film_id INTO film_id; 
	
  RETURN film_id;  
END;
$$ LANGUAGE plpgsql;


/*
 * 
SELECT * FROM core.add_new_film('Puss in Boots: The Last Wish', 'When Puss in Boots discovers that his passion for adventure has taken its toll and he has burned through eight of his nine lives, he launches an epic journey to restore them by finding the mythical Last Wish', NULL, NULL, NULL, 2, 10.99, 90, 24.99, 'G');

SELECT * FROM core.add_new_film('A Man Called Otto');

SELECT * FROM core.add_new_film('Top Gun: Maverick', 'Top Gun', 2022, 1, 2, 3, 9.99, 130, 19.99, 'PG-13');


SELECT fil.title,
	   fil.release_year,
	   lan."name" AS language
FROM public.film fil,
	 public.language lan
WHERE fil.language_id = lan.language_id
AND LOWER(fil.title) IN (LOWER('Puss in Boots: The Last Wish'), LOWER('A Man Called Otto'), LOWER('Top Gun: Maverick'));

*/
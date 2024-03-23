-- Homework Assignment SQL Foundation SELECT

-- Part 1: Write SQL queries to retrieve the following data
-- P1.1 All comedy movies released between 2000 and 2004, alphabetical
-- P1.2 Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue)
-- P1.3 Top-3 actors by number of movies they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)
-- P1.4 Number of comedy, horror and action movies per year (columns: release_year, number_of_action_movies, number_of_horror_movies, number_of_comedy_movies), sorted by release year in descending ORDER


-- P1.1 All comedy movies released between 2000 and 2004, alphabetical v.1

SELECT fil.title AS film_title,     											--title of the film 
	   fil.release_year AS film_released_year									--year in which the movie was released
FROM film fil             														--stores film data such as title, release year, length, rating, etc.
WHERE fil.release_year BETWEEN 2000 AND 2004 AND								--movies released between 2000 and 2004
   	  fil.film_id IN (SELECT filcat.film_id 									--data with film id  
				      FROM film_category filcat   				  				--stores the relationships between films and categories
				      WHERE filcat.category_id =   				    			--film category id
				  						(SELECT cat.category_id 			 	--category id
				  						FROM category cat               	  	--stores film’s categories data
				  						WHERE lower(cat.name) = 'comedy'))  	--select category type
ORDER BY fil.title;  															--order by default is ascending order 



-- P1.1 All comedy movies released between 2000 and 2004, alphabetical v.2
				 
 


SELECT fil.title AS film_title,                     --title of the film 
	   fil.release_year AS film_released_year, 		--year in which the movie was released
	   cat.name AS category_name					--film category name
FROM film fil, 										--stores film data such as title, release year, length, rating, etc.
	 film_category filcat,							--stores the relationships between films and categories
	 category cat 									--stores film’s categories data
WHERE fil.release_year BETWEEN 2000 AND 2004 AND	--movies released between 2000 and 2004
 	  fil.film_id = filcat.film_id           AND    --relation by film_id in film and film_category tables
	  filcat.category_id = cat.category_id   AND	--relation by category_id in category and film_category tables
      lower(cat.name) = 'comedy'					--select category type by name
ORDER BY fil.title;					



-- P1.2 Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue) v.1


SELECT COALESCE (addr.address, '--')  || ' ' || COALESCE(addr.address2, '--')  AS store_addresses,  	--use COALESCE because address2 contains NULL value, and after concatenated columns result was NULL   
	   sum(pay.amount) AS revenue    																	--aggregated revenue 
FROM payment pay, 																						--stores customer’s payments
	 staff sta,																				 			--stores staff data
	 address addr,  																					--stores address data for staff and customers
	 store sto																							--contains the store data including manager staff and address
WHERE pay.payment_date >= to_date('2017', 'YYYY') AND   												--select data for year 2017
	  pay.payment_date < to_date('2018', 'YYYY')  AND  													--select data for year 2017
	  sta.staff_id = pay.staff_id 				  AND													--relation by staff_id in staff and payment tables
      sto.store_id = sta.store_id				  AND													--relation by store_id in store and staff tables
      sto.address_id = addr.address_id																	--relation by address_id in store and address tables
GROUP BY  addr.address, addr.address2;  																--groups rows by address and address2 that have the same values into summary rows


-- P1.2 Revenue of every rental store for year 2017 (columns: address and address2 – as one column, revenue) v.2

SELECT sum(pay.amount) AS revenue, 																		--aggregated revenue 
	   date_part('year', pay.payment_date ) AS pay_year, 												--year data
	   sto.store_id AS store_id, 																		--store id data
	   COALESCE (addr.address, '--')  || ' ' || COALESCE(addr.address2, '--')  AS store_addresses		--use COALESCE because address2 contains NULL value, and after concatenated columns result was NULL 
FROM payment pay, 																						--stores customer’s payments
	 staff staf,																				 		--stores staff data
	 address addr,  																					--stores address data for staff and customers
	 store sto																							--contains the store data including manager staff and address
WHERE pay.payment_date >= to_date('2017', 'YYYY') AND													--select data for year 2017
	  pay.payment_date < to_date('2018', 'YYYY')  AND 													--select data for year 2017
 	  staf.staff_id = pay.staff_id 				  AND													--relation by staff_id in staff and payment tables
 	  sto.store_id = staf.store_id				  AND													--relation by store_id in store and staff tables
 	  sto.address_id = addr.address_id																	--relation by address_id in store and address tables
GROUP BY pay_year, sto.store_id, addr.address, addr.address2; 											--groups rows by address and address2 that have the same values into summary rows



-- P1.3 Top-3 actors by number of movies they took part in (columns: first_name, last_name, number_of_movies, sorted by number_of_movies in descending order)


SELECT 	act.actor_id,												--actor unique identifier number
		act.first_name,   							 			 	--actor first name
		act.last_name, 							 					--actor last name
		COUNT(flmact.actor_id) AS number_of_movies				 	--actor aggregated number of movies
FROM actor act   													--stores actors data including first name and last name
INNER JOIN film_actor flmact ON flmact.actor_id = act.actor_id		--stores the relationships between films and actors, relation by actor_id in actor and film_actor tables
GROUP BY act.actor_id, act.first_name, act.last_name  			 	--groups rows by actor_id, first_name and last_name that have the same values into summary rows
ORDER BY number_of_movies DESC, act.first_name DESC					--order by number_of_movies in descending order 
LIMIT (3); 	 														--select first 3 limited numbers of records and the additional criteria - sorting by first_name descending order because some actors/actresses can have the same number of act movies



-- P1.4 Number of comedy, horror and action movies per year (columns: release_year, number_of_action_movies, number_of_horror_movies, number_of_comedy_movies), sorted by release year in descending ORDER

SELECT  fil.release_year AS release_year,  												    --year in which the movie was released
SUM(CASE WHEN lower(cat.name) = ('action') THEN 1 ELSE 0 END) AS number_of_action_movies,   --aggregated number of action movies, use SUM and CASE statement becasue it is easiest way to count number of movies by each category on same table 
SUM(CASE WHEN lower(cat.name) = ('horror') THEN 1 ELSE 0 END) AS number_of_horror_movies,   --aggregated number of horror movies
SUM(CASE WHEN lower(cat.name) = ('comedy') THEN 1 ELSE 0 END) AS number_of_comedy_movies 	--aggregated number of comedy movies
FROM film fil, 																			    --stores film data such as title, release year, length, rating, etc.
 	 film_category filcat, 																	--stores the relationships between films and categories
	 category cat 																		    --stores film’s categories data
WHERE fil.film_id = filcat.film_id          AND												--relation by film_id in film and film_category tables
 	  filcat.category_id = cat.category_id  AND 											--relation by category_id in film_category and category tables
 	  lower(cat.name) IN ('action','horror','comedy') 										--select category type by name
GROUP  BY fil.release_year 																    --groups rows by release_year that have the same values into summary rows
ORDER BY fil.release_year DESC; 															--order by release_year in descending order 




--Part 2: Solve the following problems with the help of SQL
--P2.1. Which staff members made the highest revenue for each store and deserve a bonus for 2017 year?
--P2.2. Which 5 movies were rented more than others and what's expected audience age for those movies?
--P2.3. Which actors/actresses didn't act for a longer period of time than others


--P2.1. Which staff members made the highest revenue for each store and deserve a bonus for 2017 year?

WITH sum_revenue_by_staff AS ( 																				--alias for sum revenue by staff data
								SELECT staf.first_name,														--first name of the staff member
	   								   staf.last_name,  													--last name of the staff member 
	   								   addr.address  	AS store_address, 									--line of an address
	  	    						   sum(pay.amount)  AS revenue    										--aggregated revenue 
								FROM  staff staf, 															--stores staff data
	 								  payment pay, 															--stores customer’s payments
									  address addr,															--stores address data for staff and customers
									  store sto 															--contains the store data including manager staff and address
	 							WHERE pay.payment_date >= to_date('2017', 'YYYY')  AND 						--select data for year 2017
	 								  pay.payment_date < to_date('2018', 'YYYY')   AND						--select data for year 2017
									  staf.staff_id = pay.staff_id 				   AND						--relation by staff_id in staff and payment tables
								 	  sto.store_id = staf.store_id				   AND						--relation by store_id in store and staff tables
 	  								  sto.address_id = addr.address_id										--relation by address_id in address and store tables
								GROUP BY  staf.first_name, staf.last_name, store_address)					--groups rows by first_name, last_name and store_id that have the same values into summary rows																			

SELECT rvnst.first_name, 																					--first name of the staff member
	   rvnst.last_name, 																					--last name of the staff member
	   rvnst.revenue, 																						--aggregated revenue 
	   rvnst.store_address 																					--line of an address
FROM sum_revenue_by_staff 	rvnst																			--alias for sum revenue by staff data
WHERE (rvnst.revenue, rvnst.store_address) IN (SELECT MAX(rvnst2.revenue), 
														  rvnst2.store_address 
											   FROM sum_revenue_by_staff rvnst2
											   GROUP BY rvnst2.store_address); 								--max revenue by store address   



--P2.2. Which 5 movies were rented more than others and what's expected audience age for those movies?

--film ratings meaning
-- G – General Audiences. All ages admitted. 0-12, 12+
-- PG – Parental Guidance Suggested.Some material may not be suitable for children. 0-12, 12+
-- PG-13 – Parents Strongly Cautioned. Some material may be inappropriate for children under 13. 13-16, 16+
-- R – Restricted. Under 17 requires accompanying parent or adult guardian. 17+
-- NC-17 – Adults Only. No One 17 and Under Admitted. 18+
											   
SELECT fil.title AS movie_title, 								--title of the film 
	   COUNT(ren.rental_id) AS rented_number, 					--aggregated number of rented movies
	   fil.rating AS movie_rating,								--rating assigned to the film
	   (CASE WHEN fil.rating = ('G') THEN '0-12, 12+'
	  	     WHEN fil.rating = ('PG') THEN '0-12, 12+' 
	  	     WHEN fil.rating = ('PG-13') THEN '13-16, 16+' 	 
	  	     WHEN fil.rating = ('R') THEN '17+' 
	 		 WHEN fil.rating = ('NC-17') THEN '18+'    			
 		END) AS expected_audience_age 							--expected audience age by film rating
FROM rental ren, 												--stores rental data
	 inventory inv,												--stores inventory data
	 film fil 													--stores film data such as title, release year, length, rating, etc.
WHERE ren.inventory_id = inv.inventory_id AND 					--relation by inventory_id in rental and inventory tables
 	  fil.film_id =inv.film_id 									--relation by film_id in film and inventory tables
GROUP BY fil.title, fil.rating  								--groups rows by title, rating that have the same values into summary rows
ORDER BY rented_number DESC, movie_title DESC    		        --order by rental_id in descending order and the additional criteria - sorting by movie_title in descending order, because some number of rented movies can have the same data	
LIMIT (5); 														--select first 5 limited numbers of records



--P2.3. Which actors/actresses didn't act for a longer period of time than others

WITH actors_act_years AS (  																				--alias for actor all movie released years data
							  SELECT act.actor_id,	  														--actor unique identifier number
									 act.first_name,      													--actor first name
									 act.last_name,															--actor last name
									 fil.release_year   													--year in which the movie was released
							  FROM 	actor act,  															--stores actors data including first name and last name
									film fil,  																--stores film data such as title, release year, length, rating, etc.
									film_actor filact  														--stores the relationships between films and actors
							  WHERE act.actor_id = filact.actor_id AND 										--relation by actor_id in actor and film_actor tables
									fil.film_id = filact.film_id 											--relation by film_id in film and film_actor tables
							  GROUP BY act.actor_id, act.first_name, act.last_name, fil.release_year  		--groups rows by actor_id, first_name, last_name, release_year that have the same values into summary rows
							  ORDER BY act.actor_id ASC,  fil.release_year DESC 							--order by max actor_id in ascending order and release_year in descending order
						  																					--used group by and order by to easy calculate row_num, because release_year can contain few data for one year
						  ),
	 	
	 act_row_num AS       ( 																				--alias for calculate row_num of actor released years data
							  SELECT accy.actor_id,  														--actor unique identifier number
							         accy.first_name, 														--actor first name
							         accy.last_name, 														--actor last name
							         accy.release_year,														--year in which the movie was released
							         
							         (SELECT count(*) 														--count number of row in a result set
							          FROM actors_act_years accy_2  										--alias for actor all movie released years data 2, used the same alias because released year data is in one column
							          WHERE accy_2.actor_id = accy.actor_id AND 							--relation by actor_id in actors_act_years and actors_act_years 2 table aliases
							         		accy_2.release_year >= accy.release_year) as row_num  			--number of row in a result set, used for compare released movie year between each other and find difference between them 
							  
							  FROM actors_act_years accy 													--alias for actor all movie released years data, used the same alias because released year data is in one column
						  ),
																			    
	 row_num_diff AS 	  ( 																																 	 			 --alias for find difference between actor movie released years	 
							  SELECT row_a.actor_id,  														   													 			 --actor unique identifier number
		         			  		 row_a.first_name, 																											 			 --actor first name
		         			 		 row_a.last_name, 																											 			 --actor last name
		         			  		 row_a.release_year AS a_release_year, 																						 			 --year in which the movie was released
		         			  		 (CASE WHEN row_b.release_year IS NULL THEN 0 ELSE row_b.release_year END) AS b_release_year,                           	 			 --previous year in which the movie was released. used case because previous release year can contain NULL value
		         			  		 (CASE WHEN (row_b.release_year - row_a.release_year) IS NULL THEN 0 ELSE (row_b.release_year - row_a.release_year) END) AS diff 		 --difference between movie released year and previous year in which the movie was released, compare row_b and row_a released year and find diference between movie released year. used case because  previous release year can contain NULL value
							   FROM act_row_num row_a 																													     --alias for calculate row_num of actor released years data row_a, used the same alias because released year data is in one column  
							   LEFT JOIN act_row_num row_b ON row_a.row_num = row_b.row_num + 1 AND		 			    												 	 --alias for calculate row_num of actor released years data row_b, used the same alias because released year data is in one column. relation by row_num in alias act_row_num row_a and alias act_row_num row_b row_num + 1 (used + 1 for compare released years between each other that in one column). used LEFT JOIN because there are no matches in the right table act_row_num row_b by one released year
							  							 	  row_a.actor_id = row_b.actor_id 																			 	 --relation by actor_id in alias act_row_num row_a and alias act_row_num row_b
						  )					 

SELECT rndf.actor_id, 																						--actor unique identifier number
	   rndf.first_name,  																					--actor first name
	   rndf.last_name, 																						--actor last name
   	   MAX (rndf.diff) AS max_not_act_years 																--actors/actresses did not act max years
FROM row_num_diff rndf 																						--alias for find difference between actor movie released years
GROUP BY rndf.actor_id, rndf.first_name, rndf.last_name 													--groups rows by actor_id, first_name, last_name that have the same values into summary rows
HAVING   MAX (rndf.diff) = (SELECT (MAX (rndf_2.diff))  					    							--max years actors/actresses did not act
						 	FROM row_num_diff rndf_2) 														--alias for find difference between actor movie released years
ORDER BY max_not_act_years DESC, rndf.first_name DESC;    									            	--order by max_not_act_years in descending order and the additional criteria - sorting by first_name descending order because some actors/actresses can have the same did not act max years
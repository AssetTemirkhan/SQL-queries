-- Homework Assignment SQL Foundation – DML

-- Task 1
-- 1.1. Choose your top-3 favorite movies and add them to 'film' table. Fill rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3  weeks respectively.

--insert gladiator movie
INSERT INTO public.film (title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update, special_features)
VALUES 
--insert gladiator movie
('GLADIATOR', 'A former Roman General sets out to exact vengeance against the corrupt emperor who murdered his family and sent him into slavery', 2000, 1, NULL, 1, 4.99, 155, 29.99, 'R', current_timestamp, '{Trailers, Commentaries, Deleted Scenes, Behind the Scenes}'),
--insert rush hour movie
('RUSH HOUR', 'A loyal and dedicated Hong Kong Inspector teams up with a reckless and loudmouthed L.A.P.D. detective to rescue the Chinese Consul kidnapped daughter, while trying to arrest a dangerous crime lord along the way', 1998, 1, NULL, 2, 9.99, 98, 19.99, 'PG-13', current_timestamp, '{Trailers, Commentaries, Deleted Scenes, Behind the Scenes}'),
--insert the italian job movie
('THE ITALIAN JOB', 'After being betrayed and left for dead in Italy, Charlie Croker and his team plan an elaborate gold heist against their former ally', 2003, 1, NULL, 3, 19.99, 111, 9.99, 'PG-13', current_timestamp, '{Trailers}');
COMMIT;



-- 1.2. Add actors who play leading roles in your favorite movies to 'actor' and 'film_actor' tables (6 or more actors in total).

INSERT INTO public.actor (first_name, last_name, last_update)
--insert gladiator movie actors
 VALUES('RUSSELL','CROWE', current_timestamp),
       ('JOAQUIN', 'PHOENIX', current_timestamp),
       ('CONNIE', 'NIELSEN', current_timestamp),
--insert rush hour movie actors
       ('JACKIE', 'CHAN', current_timestamp),
       ('CHRIS', 'TUCKER', current_timestamp),
       ('KEN', 'LEUNG', current_timestamp),
--insert the italian job movie actors
       ('MARK', 'WAHLBERG', current_timestamp),
       ('CHARLIZE', 'THERON', current_timestamp),
	   ('JASON', 'STATHAM', current_timestamp);
COMMIT;



-- insert actor_id and film_id to film_actor table

-- insert actor_id and film id of GLADIATOR movie										        
INSERT INTO public.film_actor (actor_id, film_id, last_update) 
SELECT film_actors.actor_id, 													    					
	   film_name.film_id, 																				
	   current_timestamp AS last_update  																
FROM 
	(SELECT act.actor_id 																				
 	 FROM public.actor act 																				
  	 WHERE (UPPER(act.first_name) = 'CONNIE' AND UPPER(act.last_name) = 'NIELSEN') OR   				
	       (UPPER(act.first_name) = 'JOAQUIN' AND UPPER(act.last_name) =  'PHOENIX') OR  				
	       (UPPER(act.first_name) = 'RUSSELL' AND UPPER(act.last_name) = 'CROWE')) AS film_actors,  	
			  
	(SELECT fil.film_id  																				
     FROM public.film fil 																				
     WHERE UPPER(fil.title) IN ('GLADIATOR')) AS film_name; 											
COMMIT;
		
		
-- insert actor_id and film id of RUSH HOUR movie
INSERT INTO public.film_actor (actor_id, film_id, last_update) 
SELECT film_actors.actor_id, 													    
	   film_name.film_id, 															
	   current_timestamp AS last_update  											
FROM 
	(SELECT act.actor_id 														
     FROM public.actor act 																
  	 WHERE (UPPER(act.first_name) = 'KEN' AND UPPER(act.last_name) = 'LEUNG') OR  						
           (UPPER(act.first_name) = 'CHRIS' AND UPPER(act.last_name) =  'TUCKER') OR					
		   (UPPER(act.first_name) = 'JACKIE' AND UPPER(act.last_name) = 'CHAN')) AS film_actors,   	
			  
	(SELECT fil.film_id  														
  	 FROM public.film fil 																
  	 WHERE UPPER(fil.title) IN ('RUSH HOUR')) AS film_name;							
COMMIT;		
	    
	   
-- insert actor_id and film id of THE ITALIAN JOB movie										        
INSERT INTO public.film_actor (actor_id, film_id, last_update) 
SELECT film_actors.actor_id, 													    
	   film_name.film_id, 															
	   current_timestamp AS last_update  											
FROM 
	(SELECT act.actor_id 														
     FROM public.actor act 																
  	 WHERE (UPPER(act.first_name) = 'JASON' AND UPPER(act.last_name) = 'STATHAM') OR  					
   	       (UPPER(act.first_name) = 'CHARLIZE' AND UPPER(act.last_name) =  'THERON') OR 				
		   (UPPER(act.first_name) = 'MARK' AND UPPER(act.last_name) = 'WAHLBERG')) AS film_actors, 	
			  
	(SELECT fil.film_id  														
     FROM public.film fil 																
     WHERE UPPER(fil.title) IN ('THE ITALIAN JOB')) AS film_name; 					
COMMIT;
	
										  
-- 1.3. Add your favorite movies to any store's inventory.

--insert GLADIATOR, RUSH HOUR, THE ITALIAN JOB movies data to inventory table 1
INSERT INTO public.inventory (film_id, store_id, last_update)  				 
SELECT fil.film_id, 														
	   (SELECT sto.store_id 												
	    FROM public.store sto 												
		ORDER BY RANDOM() LIMIT 1) AS store_id,								--order by the random function to return the random number of store_id from the store table to insert data of different store 
		NOW() AS last_update							   					
FROM public.film fil 														
WHERE UPPER(fil.title) IN ('GLADIATOR', 'RUSH HOUR', 'THE ITALIAN JOB'); 	
COMMIT;

--insert GLADIATOR movie data to inventory table 2
INSERT INTO public.inventory (film_id, store_id, last_update) 							
SELECT fil.film_id,  									
	   (SELECT sto.store_id  								
		FROM public.store sto  									
		ORDER BY RANDOM() LIMIT 1) AS store_id,  		
	    NOW() AS last_update								
FROM public.film fil 											
WHERE UPPER(fil.title) IN ('GLADIATOR'); 					
COMMIT;
						
--insert RUSH HOUR movie data to inventory table 2
INSERT INTO public.inventory (film_id, store_id, last_update) 							
SELECT fil.film_id, 									
	   (SELECT sto.store_id 								
	    FROM public.store sto 									
	    ORDER BY RANDOM() LIMIT 1) AS store_id, 		
	    NOW() AS last_update									    
FROM public.film fil 											
WHERE UPPER(fil.title) IN ('RUSH HOUR');						
COMMIT;

--insert THE ITALIAN JOB movie data to inventory table 2
INSERT INTO public.inventory (film_id, store_id, last_update) 							 
SELECT fil.film_id,										
	   (SELECT sto.store_id  								
	    FROM public.store sto 									
	    ORDER BY RANDOM() LIMIT 1) AS store_id, 		
	    NOW() AS last_update								
FROM public.film fil 											
WHERE UPPER(fil.title) IN ('THE ITALIAN JOB'); 				
COMMIT;



-- 1.4
/* Alter any existing customer in the database who has at least 43 rental and 43 payment records. Change his/her personal data to yours (first name, 
last name, address, etc.). Do not perform any updates on 'address' table, as it can impact multiple records with the same address. Change 
customer's create_date value to current_date */


--need to add new address for make update address_id to new customer, because it is not allowed to make changes (update) in address table 

--insert new address for update customer address id
INSERT INTO public.address (address, address2, district, city_id, postal_code, phone, last_update) 
SELECT '732 Al Wahdah Street' AS address,    	 --new address data
	    NULL AS address2,                    	 --new address 2 data is null decided keep null, because in the most address2 there are no data
	    'Al Wahdah' AS district, 			 	 --new district data
	    new_address_city.city_id AS city_id, 	 --new city_id data, unique identifier number of city from city table
	    '307501' AS postal_code, 				 --new postal_code data
		'971581234567' AS phone, 				 --new phone number data
		NOW() AS last_update
FROM 
	(SELECT cit.city_id
	 FROM public.city cit
     WHERE UPPER(cit.city)='ABU DHABI' AND    	 --select city for new address 
		      cit.country_id = (SELECT country_id
		      					FROM public.country cou
		      				    WHERE UPPER(cou.country) = 'UNITED ARAB EMIRATES') --select country of city for new address 
	) AS new_address_city;
COMMIT;
 

--update customer table data 
UPDATE public.customer 
SET first_name = 'ASSET',  																--new customer first_name
    last_name  = 'TEMIRKHAN', 															--new customer last_name 
    email = 'ASSET.TEMIKHAN@sakilacustomer.org', 										--new customer email 
    create_date = current_date,  														
    address_id = (SELECT addr.address_id 												--news customer address_id, select new added address from previos query
    			  FROM public.address addr  											
    			  WHERE UPPER(addr.address) = '732 AL WAHDAH STREET' AND  				--select new added address data, used address name, because address_id can be different in other database
    				    UPPER(addr.district) = 'AL WAHDAH' AND  						--select new added district data, used district name, because address_id can be different in other database
    				    UPPER(addr.postal_code) = '307501'),							--select new added postal_code data, used postal_code name, because address_id can be different in other database
	last_update = NOW() 																
WHERE customer_id = (SELECT cus.customer_id				 								--select one of the customers who have 43 or more rental and 43 or more payment records, payments and rental numbers are the same	
					 FROM public.rental ren,
					      public.customer cus,
					      public.payment pay
				     WHERE ren.customer_id = cus.customer_id AND 
				           ren.rental_id = pay.rental_id AND 
				           pay.customer_id = cus.customer_id 
				     GROUP BY cus.customer_id
				     HAVING COUNT(ren.customer_id) >= 43 AND  	--customer rental number records that equal or more than 43 numbers
				     		COUNT(pay.payment_id) >= 43       	--customer payment number records that equal or more than 43 numbers
				     ORDER BY RANDOM ()  					   	--order by the random function to return the random customer from the customer table, decided use random because it can be any customer who have rental and payment data equal or more than 43 numbers 
				     LIMIT 1  								    
				     );
COMMIT;
						   
						   
-- 1.5 Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'

-- found releation to customer in 2 tables payment and rental

-- remove records releted to updated customer from payment table
DELETE FROM public.payment pay
WHERE pay.customer_id = (SELECT cus.customer_id 
						 FROM public.customer cus 
						 WHERE UPPER(cus.first_name) = 'ASSET' AND
    						   UPPER(cus.last_name) = 'TEMIRKHAN');
COMMIT;

-- remove records releted to updated customer from rental table   						
DELETE FROM public.rental ren
WHERE ren.customer_id = (SELECT cus.customer_id 
					 	 FROM public.customer cus 
					 	 WHERE UPPER(cus.first_name) = 'ASSET' AND
    						   UPPER(cus.last_name) = 'TEMIRKHAN');				
COMMIT;

-- 1.6. Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)

-- need to add at least 3 rents for each movies, used insert few times

-- rental GLADIATOR, RUSH HOUR, THE ITALIAN JOB movie 1, 2
    					
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT 
	(NOW() - RANDOM() * INTERVAL '10 minutes') AS rental_date,  			--rental date calculated from current date and time minus 10 minute (past date) use random function to generates a random number and interval of 10 minutes to make all data in different rental time
	inv_id_table.inventory_id, 												
	cus_id_table.customer_id, 												
	(NOW() + (30 * RANDOM()) * INTERVAL '1 day') AS return_date,	 		--rental date calculated from current date and time use random function to generates a random number and interval of 30 days to make all data in different return date and time			
	(SELECT staf.staff_id 													
     FROM public.staff staf 												
     WHERE staf.store_id = inv_id_table.store_id 							
     ORDER BY RANDOM() LIMIT 1) AS staff_id, 								--order by the random function to return the random number of store_id from the store table to insert data of different store 
     NOW() AS last_update 													
FROM 
	(SELECT inv.store_id,  																			
			inv.inventory_id  																		
	 FROM public.inventory inv, 																	
          public.film fil																			
	 WHERE inv.film_id = fil.film_id AND															
	 	   UPPER(fil.title) IN ('GLADIATOR', 'RUSH HOUR', 'THE ITALIAN JOB') ) AS inv_id_table, 	
	(SELECT cus.customer_id  																
	 FROM public.customer cus  															
	 WHERE UPPER(cus.first_name) = 'ASSET' AND  											
    	   UPPER(cus.last_name) = 'TEMIRKHAN') AS cus_id_table;    						    									
COMMIT;


--rental gladiator movie 3
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT 
	(NOW() - RANDOM() * INTERVAL '10 minutes') AS rental_date,
	inv_id_table.inventory_id,
	cus_id_table.customer_id, 						
	(NOW() + (30 * RANDOM()) * INTERVAL '1 day') AS return_date,				
	(SELECT staf.staff_id 
     FROM public.staff staf
     WHERE staf.store_id = inv_id_table.store_id
     ORDER BY RANDOM() LIMIT 1) AS staff_id,
     NOW() AS last_update
FROM 
	(SELECT inv.store_id, 
			inv.inventory_id 
	 FROM public.inventory inv,
     	  public.film fil
     WHERE inv.film_id = fil.film_id AND
	  	   UPPER(fil.title) IN ('GLADIATOR') ) AS inv_id_table,
	(SELECT cus.customer_id 
	 FROM public.customer cus 
	 WHERE UPPER(cus.first_name) = 'ASSET' AND
    	   UPPER(cus.last_name) = 'TEMIRKHAN') AS cus_id_table;
    					
COMMIT;

--rental rush hour movie 3
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT 
	(NOW() - RANDOM() * INTERVAL '10 minutes') AS rental_date,
	inv_id_table.inventory_id,
	cus_id_table.customer_id, 						
	(NOW() + (30 * RANDOM()) * INTERVAL '1 day') AS return_date,				
	(SELECT staf.staff_id 
     FROM public.staff staf
     WHERE staf.store_id = inv_id_table.store_id
     ORDER BY RANDOM() LIMIT 1) AS staff_id,
     NOW() AS last_update
FROM 
	(SELECT inv.store_id, 
	   		inv.inventory_id 
	 FROM public.inventory inv,
          public.film fil
	 WHERE inv.film_id = fil.film_id AND
	       UPPER(fil.title) IN ('RUSH HOUR') ) AS inv_id_table,
	(SELECT cus.customer_id 
	 FROM public.customer cus 
	 WHERE UPPER(cus.first_name) = 'ASSET' AND
    	   UPPER(cus.last_name) = 'TEMIRKHAN') AS cus_id_table;  
    					
COMMIT;

 --rental the italian job movie 3
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT 
	(NOW() - RANDOM() * INTERVAL '10 minutes') AS rental_date,
	inv_id_table.inventory_id,
	cus_id_table.customer_id, 						
	(NOW() + (30 * RANDOM()) * INTERVAL '1 day') AS return_date,				
	(SELECT staf.staff_id 
     FROM public.staff staf
     WHERE staf.store_id = inv_id_table.store_id
     ORDER BY RANDOM() LIMIT 1) AS staff_id,
     NOW() AS last_update
FROM 
	(SELECT inv.store_id, 
			inv.inventory_id 
	FROM public.inventory inv,
         public.film fil
	WHERE inv.film_id = fil.film_id AND
	 	  UPPER(fil.title) IN ('THE ITALIAN JOB') ) AS inv_id_table,
	(SELECT cus.customer_id 
	 FROM public.customer cus 
	 WHERE UPPER(cus.first_name) = 'ASSET' AND
    	   UPPER(cus.last_name) = 'TEMIRKHAN') AS cus_id_table;  				
   					
COMMIT;
    					 					

--create a table partition because without partition new data for current date (2023) would not add

CREATE TABLE public.payment_p2023_01 PARTITION OF public.payment
FOR VALUES FROM ('2023-01-01 00:00:00+6:00') TO ('2023-02-01 00:00:00+6:00');

ALTER TABLE public.payment_p2023_01 OWNER TO postgres;
COMMIT;

CREATE TABLE public.payment_p2023_02 PARTITION OF public.payment
FOR VALUES FROM ('2023-02-01 00:00:00+6:00') TO ('2023-03-01 00:00:00+6:00');

ALTER TABLE public.payment_p2023_02 OWNER TO postgres;
COMMIT;

CREATE TABLE public.payment_p2023_03 PARTITION OF public.payment
FOR VALUES FROM ('2023-03-01 00:00:00+6:00') TO ('2023-04-01 00:00:00+6:00');

ALTER TABLE public.payment_p2023_03 OWNER TO postgres;
COMMIT;

CREATE TABLE public.payment_p2023_04 PARTITION OF public.payment
FOR VALUES FROM ('2023-04-01 00:00:00+6:00') TO ('2023-05-01 00:00:00+6:00');

ALTER TABLE public.payment_p2023_04 OWNER TO postgres;
COMMIT;

---insert payment for rent of GLADIATOR, RUSH HOUR, THE ITALIAN JOB movies
INSERT INTO public.payment (customer_id, staff_id, rental_id, amount, payment_date)
SELECT 
ren.customer_id AS customer_id,
ren.staff_id AS staff_id,
ren.rental_id AS rental_id,
CASE WHEN DATE_PART('day', ren.return_date - ren.rental_date::date) > rental_duration  								--amount calculated by rental rate for any period within the rental duration value, if it exceeds, customer pay an extra $1 for each additional day 
	 THEN rental_rate + ((DATE_PART('day', ren.return_date - ren.rental_date::date) - fil.rental_duration) * 1) 	--for calculated that amount I found difference between return_date and rental_date and if it is more than rental_duration find difference between rented days and rental_duration and multiply it to 1, use ::date for count days from midnight 
	 ELSE rental_rate  																							    --if rental period in the rental duration value then add rental rate amount
END AS amount,    
(ren.return_date + INTERVAL '10 minutes') AS payment_date 											   				--payment date calculated from return date and time and plus 10 minutes
FROM public.film fil,
	 public.inventory inv,
	 public.rental ren
WHERE fil.film_id = inv.film_id AND
	  UPPER(fil.title) IN ('GLADIATOR', 'RUSH HOUR', 'THE ITALIAN JOB') AND
	  inv.inventory_id = ren.inventory_id AND 
	  ren.customer_id = (SELECT cus.customer_id 
						 FROM public.customer cus 
					 	 WHERE UPPER(cus.first_name) = 'ASSET' AND
    						   UPPER(cus.last_name) = 'TEMIRKHAN');
COMMIT;


--------------

--task 1 select data

-- 1.1.
SELECT *
FROM public.film fil
WHERE UPPER(fil.title) IN ('GLADIATOR', 'RUSH HOUR', 'THE ITALIAN JOB');

-- 1.2. Add actors who play leading roles in your favorite movies to 'actor' and 'film_actor' tables (6 or more actors in total).


SELECT *
FROM public.actor act
WHERE 
	--GLADIATOR
	(UPPER(act.first_name) = 'CONNIE' AND UPPER(act.last_name) = 'NIELSEN') OR   				
	(UPPER(act.first_name) = 'JOAQUIN' AND UPPER(act.last_name) =  'PHOENIX') OR  				
	(UPPER(act.first_name) = 'RUSSELL' AND UPPER(act.last_name) = 'CROWE')  OR
	--RUSH HOUR
	(UPPER(act.first_name) = 'KEN' AND UPPER(act.last_name) = 'LEUNG') OR  						
	(UPPER(act.first_name) = 'CHRIS' AND UPPER(act.last_name) =  'TUCKER') OR					
	(UPPER(act.first_name) = 'JACKIE' AND UPPER(act.last_name) = 'CHAN') OR
	--THE ITALIAN JOB
	(UPPER(act.first_name) = 'JASON' AND UPPER(act.last_name) = 'STATHAM') OR  					
	(UPPER(act.first_name) = 'CHARLIZE' AND UPPER(act.last_name) =  'THERON') OR 				
	(UPPER(act.first_name) = 'MARK' AND UPPER(act.last_name) = 'WAHLBERG');

-- film and actors	 
	 
SELECT film_name.title AS film, 														
	   film_actors.first_name,
	   film_actors.last_name
FROM public.film_actor filact,
	(SELECT act.actor_id,
	    	act.first_name,
			act.last_name
	 FROM public.actor act 																
	 WHERE  
	 		--GLADIATOR
	      (UPPER(act.first_name) = 'CONNIE' AND UPPER(act.last_name) = 'NIELSEN') OR   				
		  (UPPER(act.first_name) = 'JOAQUIN' AND UPPER(act.last_name) =  'PHOENIX') OR  				
		  (UPPER(act.first_name) = 'RUSSELL' AND UPPER(act.last_name) = 'CROWE')  OR
		    --RUSH HOUR
		  (UPPER(act.first_name) = 'KEN' AND UPPER(act.last_name) = 'LEUNG') OR  						
		  (UPPER(act.first_name) = 'CHRIS' AND UPPER(act.last_name) =  'TUCKER') OR					
	  	  (UPPER(act.first_name) = 'JACKIE' AND UPPER(act.last_name) = 'CHAN') OR
		    --THE ITALIAN JOB
		  (UPPER(act.first_name) = 'JASON' AND UPPER(act.last_name) = 'STATHAM') OR  					
		  (UPPER(act.first_name) = 'CHARLIZE' AND UPPER(act.last_name) =  'THERON') OR 				
	      (UPPER(act.first_name) = 'MARK' AND UPPER(act.last_name) = 'WAHLBERG')) AS film_actors,   	
				  
	 (SELECT fil.film_id, 
			 fil.title  														
	  FROM public.film fil 																
	  WHERE UPPER(fil.title) IN ('GLADIATOR', 'RUSH HOUR', 'THE ITALIAN JOB')) AS film_name
WHERE filact.film_id = film_name.film_id AND
	  filact.actor_id = film_actors.actor_id;
	    
	 
-- 1.3. Add your favorite movies to any store's inventory.
SELECT *
FROM public.inventory inv
WHERE inv.film_id  IN (SELECT fil.film_id
					   FROM public.film fil
					   WHERE UPPER(fil.title) IN ('GLADIATOR', 'RUSH HOUR', 'THE ITALIAN JOB')
					   );
					  
-- 1.4 
/* Alter any existing customer in the database who has at least 43 rental and 43 payment records. Change his/her personal data to yours (first name, 
last name, address, etc.). Do not perform any updates on 'address' table, as it can impact multiple records with the same address. Change 
customer's create_date value to current_date */
					  
--select new address data
SELECT *
FROM public.address addr  																	
WHERE UPPER(addr.address) = '732 AL WAHDAH STREET' AND  				
      UPPER(addr.district) = 'AL WAHDAH' AND  						
      UPPER(addr.postal_code) = '307501';
     
--select customer update data
SELECT *
FROM public.customer cus
WHERE UPPER(cus.first_name) = 'ASSET' AND 
	  UPPER(cus.last_name)  = 'TEMIRKHAN'; 
	 
-- 1.5 Remove data
	 
-- 1.6. Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)
SELECT *
FROM public.rental ren
WHERE ren.customer_id  = (SELECT cus.customer_id  																
	  					  FROM customer cus  															
	  					  WHERE UPPER(cus.first_name) = 'ASSET' AND  											
    	   				        UPPER(cus.last_name)  = 'TEMIRKHAN');	
    	   				
SELECT *
FROM public.payment pay
WHERE pay.customer_id  = (SELECT cus.customer_id  																
	  					  FROM customer cus  															
	  					  WHERE UPPER(cus.first_name) = 'ASSET' AND  											
    	   				        UPPER(cus.last_name) = 'TEMIRKHAN');
    	   				       
--select amount calculation data    	   				        
SELECT fil.title,
   	   fil.film_id,
   	   fil.rental_duration,
   	   fil.rental_rate,
       DATE_PART('day', ren.return_date - ren.rental_date::date) AS rental_days,
       pay.amount,
   	   ren.return_date, 
   	   ren.rental_date
FROM public.rental ren,
   	 public.inventory inv,
   	 public.film fil,
   	 public.payment pay
WHERE ren.inventory_id = inv.inventory_id AND 
  	  inv.film_id = fil.film_id AND 
   	  pay.rental_id = ren.rental_id AND
   	  ren.customer_id  = (SELECT cus.customer_id  																
	 					  FROM public.customer cus  															
	  					  WHERE UPPER(cus.first_name) = 'ASSET' AND  											
    	   				  		UPPER(cus.last_name)  = 'TEMIRKHAN');	
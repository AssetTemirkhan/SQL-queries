-- Verification Task


--1.1. Top-3 most selling movie categories of all time and total dvd rental income for each category. Only consider dvd rental customers from the USA.

WITH us_customers AS ( 									   			    --alias for customers from United States (USA)
						SELECT cus.customer_id,  						--customer unique identifier number
							   cus.first_name, 							--customer first name
							   cus.last_name, 							--customer last name
							   cou.country 								--customer country name
						FROM customer cus,   			   				--stores customer data
							 address addr, 								--stores address data for staff and customers
							 city cit, 									--stores city names
							 country cou 								--stores country names
						WHERE cus.address_id =addr.address_id AND  		--relation by address_id in customer and address tables
							  cit.city_id = addr.city_id AND         	--relation by city_id in city and address tables
							  cou.country_id  = cit.country_id AND	 	--relation by country_id in country and city tables
							  lower(cou.country) = 'united states')	 	--select country by name
	 
SELECT 
cat.name AS film_category,  									--film category name 
sum(pay.amount) AS income   									--rental income 
FROM rental ren, 												--stores rental data
	 inventory inv,												--stores inventory data
	 film fil, 													--stores film data such as title, release year, length, rating, etc.
 	 film_category filcat, 										--stores the relationships between films and categories
	 category cat, 												--stores film’s categories data
     payment pay, 												--stores customer’s payments
     us_customers usc											--alias for customers from United States (USA)
WHERE ren.inventory_id = inv.inventory_id AND 					--relation by inventory_id in rental and inventory tables
 	  fil.film_id =inv.film_id AND								--relation by film_id in film and inventory tables
      fil.film_id = filcat.film_id AND							--relation by film_id in film and film_category tables
 	  filcat.category_id = cat.category_id AND 					--relation by category_id in film_category and category tables
	  ren.rental_id = pay.rental_id AND  						--relation by rental_id in rental and payment tables
	  usc.customer_id = pay.customer_id 					 	--relation by customer_id in alias for customers from United States (USA) and payment tables
GROUP BY cat.name  												--groups rows by category name that have the same values into summary rows
ORDER BY income DESC 											--order by income in descending order 
LIMIT 3; 														--select first 3 limited numbers of records



-- 2. For each client, display a list of horrors that he had ever rented (in one column, separated by commas), and the amount of money that he paid for it

	 
SELECT 
cus.customer_id, 												 --customer unique identifier number
cus.first_name, 												 --customer first name
cus.last_name, 													 --customer last name
sum(pay.amount) AS total_rent_amount,							 --total rent amount that customer paid 
STRING_AGG (DISTINCT fil.title, ',') AS rent_films 			     --each film title that was rent by customers sepaseparated by comma, used STRING_AGG because it is easy way to concatenate a list of strings and places a separator between them, use DISTINCT because customers rented the same film few times in diffent days 
FROM rental ren, 												 --stores rental data
	 inventory inv,												 --stores inventory data
	 film fil, 													 --stores film data such as title, release year, length, rating, etc.
 	 film_category filcat, 										 --stores the relationships between films and categories
	 category cat, 												 --stores film’s categories data
     payment pay, 												 --stores customer’s payments
     customer cus 												 --stores customer data
WHERE ren.inventory_id = inv.inventory_id AND 					 --relation by inventory_id in rental and inventory tables
 	  fil.film_id =inv.film_id 	 AND							 --relation by film_id in film and inventory tables
      fil.film_id = filcat.film_id          AND					 --relation by film_id in film and film_category tables
 	  filcat.category_id = cat.category_id  AND 				 --relation by category_id in film_category and category tables
	  ren.rental_id = pay.rental_id	 AND   						 --relation by rental_id in rental and payment tables
	  cus.customer_id = ren.customer_id AND  					 --relation by customer_id in customer and payment tables
	  lower(cat.name) = ('horror')  							 --select category by name
GROUP BY cus.customer_id, cus.first_name, cus.last_name 		 --groups rows by customer_id, first_name, last_name  that have the same values into summary rows
ORDER BY first_name, last_name, rent_films; 					 --order by total_rent_amount in descending order 



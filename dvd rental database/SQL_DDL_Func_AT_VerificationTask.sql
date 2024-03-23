--Verification Task SQL Foundation – DDL (function)
/*
 * 
Create one function that reports all information for a particular client and timeframe:
• Customer's name, surname and email address;
• Number of films rented during specified timeframe;
• Comma-separated list of rented films at the end of specified time period;
• Total number of payments made during specified time period;
• Total amount paid during specified time period;
Function's input arguments: client_id, left_boundary, right_boundary.
The function must analyze specified timeframe [left_boundary, right_boundary] and output specified information for this timeframe.
Function's result format: table with 2 columns ‘metric_name’ and ‘metric_value’.

*/

CREATE OR REPLACE FUNCTION public.customer_rents_info (client_id INTEGER, left_boundary DATE, right_boundary DATE)
RETURNS TABLE (metric_name TEXT,
			   metric_value TEXT)
AS $$
DECLARE 
	customer_count INTEGER;
BEGIN
	SELECT COUNT(*) INTO customer_count    --check is there any customer id if there is no customer id there will be information about it
	FROM public.customer
	WHERE customer_id = client_id;
	
	IF customer_count = 0 THEN
	RETURN QUERY SELECT 'No data' AS metric_name, 'There is no data for selected customer id' AS metric_value;
	END IF;
	
	RETURN QUERY
	WITH customer_rents AS (
							SELECT 
								cus.first_name || ' ' || cus.last_name || ', ' || cus.email AS customer_info,
								COUNT (ren.rental_id) AS num_of_films_rented,
								STRING_AGG (DISTINCT fil.title, ',') AS rented_films_titles, 				 --each film title that was rent by customers separated by comma, used STRING_AGG because it is easy way to concatenate a list of strings and places a separator between them, use DISTINCT because customers rented the same film few times 			 
								COUNT(pay.payment_id) AS num_of_payments,
								SUM(pay.amount) AS payments_amount
						 	FROM 
								public.rental ren,
								public.inventory inv,
								public.film fil,
								public.payment pay, 
								public.customer cus
						  	WHERE 
							 	ren.inventory_id = inv.inventory_id AND
							 	fil.film_id = inv.film_id AND
							 	ren.rental_id = pay.rental_id AND
							 	cus.customer_id = ren.customer_id AND 
							 	cus.customer_id = pay.customer_id AND 
								cus.customer_id = client_id AND  			 
								ren.rental_date >= left_boundary AND 	 
								ren.rental_date <= right_boundary 			
						 	GROUP BY cus.customer_id						
							)
SELECT 'customer_info' AS metric_name, customer_info
FROM customer_rents

UNION ALL   --used union all to have in result set data as Example of result

SELECT 'num_of_films_rented' AS metric_name, num_of_films_rented::TEXT  	--casts the num_of_rented_films column values to the "TEXT"
FROM customer_rents

UNION ALL

SELECT 'rented_films_titles' AS metric_name, rented_films_titles
FROM customer_rents

UNION ALL

SELECT 'num_of_payments' AS metric_name, num_of_payments::TEXT  	 		--casts the num_of_rented_films column values to the "TEXT"	
FROM customer_rents

UNION ALL
SELECT 'payments_amount' AS metric_name, payments_amount::TEXT 				--casts the num_of_rented_films column values to the "TEXT"	
FROM customer_rents;

END;
$$
LANGUAGE plpgsql;

/*

SELECT * FROM public.customer_rents_info(1,'2005-05-25', '2006-05-25');

SELECT * FROM public.customer_rents_info(2222,'2007-05-25', '2007-05-25');

*/


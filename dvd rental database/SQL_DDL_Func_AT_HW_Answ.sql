--Homework Assignment SQL Foundation – DDL (function)

--Tasks

--4
/*
Prepare answers to the following questions:
• What operations do the following functions perform: film_in_stock, film_not_in_stock, inventory_in_stock, get_customer_balance, 
inventory_held_by_customer, rewards_report, last_day? You can find these functions in dvd_rental database.
• Why does ‘rewards_report’ function return 0 rows? Correct and recreate the function, so that it's able to return rows properly.
• Is there any function that can potentially be removed from the dvd_rental codebase? If so, which one and why?
• * The ‘get_customer_balance’ function describes the business requirements for calculating the client balance. Unfortunately, not all of 
them are implemented in this function. Try to change function using the requirements from the comments.
• * How do ‘group_concat’ and ‘_group_concat’ functions work? (database creation script might help) Where are they used?
• * What does ‘last_updated’ function do? Where is it used? 
• * What is tmpSQL variable for in ‘rewards_report’ function? Can this function be recreated without EXECUTE statement and dynamic SQL? 
Why?
*/

/*
--4.1
What operations do the following functions perform:
4.1.1. film_in_stock
film_in_stock function takes two input parameters p_film_id and p_store_id and retuns an output parameter p_film_count all parameters in type of integer.
Function returns a set of inventory_id for specified film and store, based on added conditions film_id = p_film_id, store_id = p_store_id, and inventory_in_stock returns true for inventory_id, checks if the item is in stock. 


4.1.2. film_not_in_stock
it is opposite of film_in_stock
film_not_in_stock function takes two input parameters p_film_id and p_store_id and retuns an output parameter p_film_count all parameters in type of integer.
Function returns a set of inventory_id for specified film and store, based on added conditions film_id = p_film_id, store_id = p_store_id, and inventory_in_stock return false for inventory_id, checks if the item is not in stock. 

4.1.3. inventory_in_stock
Function inventory_in_stock takes a single input parameter p_inventory_id of type integer and returns a boolean value indication that the film is in stock.TRUE in stock, FALSE not in stock.

Function counts the number of rows in rental table for given inventory_id, and store the result in the v_rentals variable.
If v_rentals = 0 the function returns TRUE, that mean that the item is in stock.

If v_rentals not equal to 0 the function counts the number of rows in the inventory and rental table, where inventory_id = p_inventory_id and the return_date from return table is NULL. 
Result of number of rows store in v_out variable. If v_out > 0 then function return FALSE, that mean that the item is not in stock. If v_out not greated than 0 the function returns TRUE, that mean that the item is in stock. 

4.1.4. get_customer_balance

Function get_customer_balance calculates the balance of a customer with a given ID p_customer_id(integer) and specified effective date p_effective_date (timestamp with time zone). 
The rental fees are calculated by summing the rental rate for each film rented by customer, the calculation using a SELECT statement with SUM aggregate function and the result is stored in v_rentfees variable. The COALESCE function used to return 0 if there are no matching records, which means that the customer did not rent any film.
The overdue fees are calculated by checking the difference between the return date and rental date for each rental and if it is more than rental_duration multiplied by 1 day, the over fee calculated by subtracting the rental duration from difference between the rental return_date and rental_date and converting the result to seconds using EXTRACT function, the number of seconds is then divided to 86400(number of seconds in day) to convert it to days.
If the difference between the rental return_date and rental_date is not more than the rental_duration multiplied by 1 day, the ELSE clause is executed and a 0 is returned. Calculation using CASE statement with SUM aggregate function to sum results. Result is stored in the v_overfees variable.
The sum of calculation of all customer payments with given p_customer_id and p_effective_date. Result is stored in the v_payments variable.
The final customer balance is calculated by adding the rental fees, overdue fees and subtracting the payments. This result calculated as v_rentfees + v_overfees – v_payments and returned using RETRUN statement.


4.1.5. inventory_held_by_customer

Function is to show the customer_id of the customer who currently holds a rental film identified by the inventory_id. The function checking the rental table for any records with a matching invertory_id and NULL in return_date, which means that the film is currently rented and has not been returned.
Function takes a single input parameter p_inventory_id of type integer and returns a v_customer_id value type of integer. 
The result of the SELECT statement is stored in the variable v_customer_id and returned as the result of the function.


4.1.6. rewards_report

Function returns a set of customers who meet the criteria of minimum monthly purchases and minimum dollar amount purchased in the last 3 months. 
Sanity checks check if the input parameters min_monthly_purchases and min_dollar_amount_purchased are greater than 0, and  if one of the them is equal to 0 it is raise an exception with an error message.
Date calculates the start and end dates of the last 3 months and store them in last_month_start and last_month_end variable.
Create a temporary table tmpCustomer to store customer_id of customers who meet the purchase criteria.
Find all customers who have made purchases in the last month that are greater that the min_dollar_amount_purchased and have made more than min_monthly_purchases purchases and insert the customer_id into the temporary table.
By execute query to select all customers who meet the requirements and return the result set. The function returns each row of the result set one by one using the RETURN NEXT statement.
Drop the temporary table tmpCustomer.
Returns the set of customers who meet the rewards criteria.

4.1.7. last_day

Function takes a timestamp with time zone as an input and returns the last day of the month as a date.
Use EXTRACT function to extracts the month and year from the input timestamp.
Use CASE statement to determine if the month is December(=12).
If the month is December(12) then calculates the last day of the month by subtracting 1 day from the first day of the next year.
If the month is not December then calculates the last day of the month by subtracting 1 day from the first day of the next month.
Return result as a date data type.


4.2. Why does ‘rewards_report’ function return 0 rows? Correct and recreate the function, so that it's able to return rows properly.

rewards_report return 0 rows because of parameter specified in last_month_start, there was minus 3 month interval from current date, in the database there are no any data for this period, because of this function returns 0 rows.

changed rewards_report function
added last_month_start in parameter to function, now need to specify the month for which need get the data  


SELECT * 
FROM public.rewards_report(5,20, '2017-01-26');

min_monthly_purchases 		- 5
min_dollar_amount_purchased - 20
last_month_start 			- '2017-01-26'

---------

CREATE OR REPLACE FUNCTION rewards_report(min_monthly_purchases INTEGER, min_dollar_amount_purchased NUMERIC, last_month_start DATE DEFAULT CURRENT_DATE - '3 month'::interval) RETURNS SETOF customer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
DECLARE
   	--last_month_start DATE;
    last_month_end DATE;
	rr RECORD;
	tmpSQL TEXT;
BEGIN

    /* Some sanity checks... */
    IF min_monthly_purchases = 0 THEN
        RAISE EXCEPTION 'Minimum monthly purchases parameter must be > 0';
    END IF;
    IF min_dollar_amount_purchased = 0.00 THEN
        RAISE EXCEPTION 'Minimum monthly dollar amount purchased parameter must be > $0.00';
    END IF;

    --last_month_start := CURRENT_DATE - '3 month'::interval;
    last_month_start := to_date((extract(YEAR FROM last_month_start) || '-' || extract(MONTH FROM last_month_start) || '-01'),'YYYY-MM-DD');
    last_month_end := LAST_DAY(last_month_start);

    /*
    Create a temporary storage area for Customer IDs.
    */
    CREATE TEMPORARY TABLE tmpCustomer (customer_id INTEGER NOT NULL PRIMARY KEY);

    /*
    Find all customers meeting the monthly purchase requirements
    */

    tmpSQL := 'INSERT INTO tmpCustomer (customer_id)
        SELECT p.customer_id
        FROM payment AS p
        WHERE DATE(p.payment_date) BETWEEN '||quote_literal(last_month_start) ||' AND '|| quote_literal(last_month_end) || '
        GROUP BY p.customer_id
        HAVING SUM(p.amount) > '|| min_dollar_amount_purchased || '
        AND COUNT(p.customer_id) > ' ||min_monthly_purchases ;

    EXECUTE tmpSQL;

    /*
    Output ALL customer information of matching rewardees.
    Customize output as needed.
    */
    FOR rr IN EXECUTE 'SELECT c.* FROM tmpCustomer AS t INNER JOIN customer AS c ON t.customer_id = c.customer_id' LOOP
        RETURN NEXT rr;
    END LOOP;

    /* Clean up */
    tmpSQL := 'DROP TABLE tmpCustomer';
    EXECUTE tmpSQL;

RETURN;
END
$_$;

---------
/*
4.3. Is there any function that can potentially be removed from the dvd_rental codebase? If so, which one and why?

film_not_in_stock function can be removed because there other similar function film_in_stock, we can use only film_in_stock function, if film_in_stock returns no results it means that the film is not in stock.

last_day can be removed, instead function can be used SELECT to get last day of the month

for example
SELECT (DATE_TRUNC ('month', current_date) + INTERVAL '1 month - 1 day')::DATE;
SELECT (DATE_TRUNC ('month', '2023-03-01'::DATE) + INTERVAL '1 month - 1 day')::DATE;

inventory_held_by_customer function can be removed because there other similar function inventory_in_stock, we can use only inventory_in_stock, if inventory_in_stock returns FALSE it means that the film is not in stock.


4.4. The ‘get_customer_balance’ function describes the business requirements for calculating the client balance. 
Unfortunately, not all of them are implemented in this function. Try to change function using the requirements from the comments

changed function, added v_replacement_fees to add replacement_cost to overdue with rental_duration 2 times
--#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST


CREATE OR REPLACE FUNCTION get_customer_balance(p_customer_id integer, p_effective_date timestamp with time zone) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
       --#OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
       --#THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
       --#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
       --#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
       --#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
       --#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
DECLARE
    v_rentfees DECIMAL(5,2); --#FEES PAID TO RENT THE VIDEOS INITIALLY
    v_overfees INTEGER;      --#LATE FEES FOR PRIOR RENTALS
    v_payments DECIMAL(5,2); --#SUM OF PAYMENTS MADE PREVIOUSLY
	v_replacement_fees DECIMAL(5, 2); --#REPLACEMENT FEES FOR PRIOR RENTALS

BEGIN
	--#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
    SELECT COALESCE(SUM(film.rental_rate),0) INTO v_rentfees
    FROM film, inventory, rental
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;
	
	--#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
    SELECT COALESCE(SUM(CASE 
                           WHEN (rental.return_date - rental.rental_date) > (film.rental_duration * '1 day'::interval)
                           THEN EXTRACT(epoch FROM ((rental.return_date - rental.rental_date) - (film.rental_duration * '1 day'::interval)))::INTEGER / 86400 -- * 1 dollar
                           ELSE 0
                        END),0) 
    INTO v_overfees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;
	  
	--#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
    SELECT COALESCE(SUM(CASE
					   	   WHEN (rental.return_date - rental.rental_date) > (film.rental_duration * 2 * '1 day'::interval)
					   	   THEN film.replacement_cost
					   	   ELSE 0
					   	END),0)
	INTO v_replacement_fees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id; 
    
	--#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
	SELECT COALESCE(SUM(payment.amount),0) INTO v_payments
    FROM payment
    WHERE payment.payment_date <= p_effective_date
    AND payment.customer_id = p_customer_id;

    RETURN v_rentfees + v_overfees + v_replacement_fees - v_payments;
END
$$;


4.5. How do ‘group_concat’ and ‘_group_concat’ functions work? (database creation script might help) Where are they used?

_group_concat 
function concatenates two text inputs separated by a comma and space. If one the input is NULL it returns the non-NULL input.

group_concat
It is aggregate function used to concatenate a set of values and returns a single value as a result. It takes as input a text value and concatenate using SFUNC (state transition function) with _group_concat function.
 
Where are they used?
_group_concat used in group_concat aggregate function
group_concat used in database in views (actor_info, film_list, nicer_but_slower_film_list) to create a list of films or actors who mention the criteria


4.6. What does ‘last_updated’ function do? Where is it used? 
last_updated is a trigger function, it is update the value of las_update column in the table to the current timestamp in any modifications(insert, update) made to the row in table.

Where is it used? 
last_updated function used in a create trigger (last_update) that be executed to any update in any row in actor, address, category, city, country, customer, film, film_actor, film_category, inventory, language, rental, staff, store tables.


4.7. What is tmpSQL variable for in ‘rewards_report’ function? Can this function be recreated without EXECUTE statement and dynamic SQL? Why?
tmpSQL is used to store a text type variable then executed using the EXECUTE statement.

Can this function be recreated without EXECUTE statement and dynamic SQL? 
Yes, it is possible to recreate this function without EXECUTE statement and dinamic SQL, by using standart SQL statement.

Why? 


*/
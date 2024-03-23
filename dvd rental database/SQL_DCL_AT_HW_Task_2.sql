--Homework Assignment
--SQL Foundation – DCL

--Please use Auto-Commit


/*
2. Implement role-based authentication model for dvd_rental database:
2.1. Create group roles: DB developer, backend tester (read-only), customer (read-only for film and actor)
2.2 Create personalized role for any customer already existing in the dvd_rental database. Role name must be client_{first_name}_{last_name} (omit curly brackets). Customer's payment and rental history must not be empty.
• Assign proper privileges to each role.
• Verify that all roles are working as intended.
*/


--2.1. Create group roles: DB developer, backend tester (read-only), customer (read-only for film and actor)

--DB developer
CREATE ROLE db_developer LOGIN PASSWORD 'db_dev123';

GRANT CONNECT ON DATABASE postgres TO db_developer;

GRANT CREATE, USAGE ON SCHEMA public TO db_developer;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO db_developer;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO db_developer;   --grant permision to all sequences in public schema to db_developer role


SET ROLE db_developer;

SELECT current_user;

--data in actor table updated correct
UPDATE public.actor
SET first_name = 'ASSET'
WHERE actor_id = 1;  


--select data in actor table
SELECT * 
FROM public.actor
WHERE actor_id=1;


INSERT INTO  public.actor (first_name, last_name) VALUES ('Denis', 'Denis');


SELECT * 
FROM public.actor act
WHERE LOWER (act.first_name) = LOWER('Denis') AND
	  LOWER (act.last_name) = LOWER('Denis');
	 

RESET ROLE;

-- backend tester (read-only)
CREATE ROLE backend_tester LOGIN PASSWORD 'back_test_123';

GRANT CONNECT ON DATABASE postgres TO backend_tester;

GRANT USAGE ON SCHEMA public TO backend_tester;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO backend_tester;


SET ROLE backend_tester;

SELECT current_user;

--have access only for select data
SELECT * 
FROM public.actor;

-- do not have access to update data, ERROR: permission denied for table actor
UPDATE public.actor
SET first_name = 'ASSET'
WHERE actor_id = 1;   

--have access only for select data
SELECT * FROM public.customer;

--do not have access to insert data, ERROR: permission denied for table film

INSERT INTO public.film (title, description, release_year, language_id, original_language_id, rental_duration, rental_rate, length, replacement_cost, rating, last_update, special_features)
VALUES 
--insert gladiator movie
('GLADIATOR', 'A former Roman General sets out to exact vengeance against the corrupt emperor who murdered his family and sent him into slavery', 2000, 1, NULL, 1, 4.99, 155, 29.99, 'R', current_timestamp, '{Trailers, Commentaries, Deleted Scenes, Behind the Scenes}');

RESET ROLE;

--customer (read-only for film and actor)
CREATE ROLE customer LOGIN PASSWORD 'customer123';

GRANT CONNECT ON DATABASE postgres TO customer;

GRANT USAGE ON SCHEMA public TO customer;

GRANT SELECT ON public.film TO customer;

GRANT SELECT ON public.actor TO customer;


SET ROLE customer;

SELECT current_user;

SELECT * FROM public.film;   --have access to select data 

SELECT * FROM public.actor;

SELECT * FROM public.city;   --do not have access to select data, ERROR: permission denied for table city

RESET ROLE;

--2.2 Create personalized role for any customer already existing in the dvd_rental database. Role name must be client_{first_name}_{last_name} (omit curly brackets). Customer's payment and rental history must not be empty.

--function to create a customer personalized role by id
CREATE OR REPLACE FUNCTION create_personalized_role(i_customer_id INTEGER)
RETURNS TEXT 
AS $$
DECLARE
  client_role RECORD;   --information about customer role
  client_role_found TEXT;
  client_new_role TEXT;
BEGIN
    SELECT cus.first_name, 
           cus.last_name, 
           cus.customer_id
    INTO client_role
    FROM public.customer cus
    WHERE cus.customer_id = i_customer_id AND
          EXISTS (SELECT 1 FROM public.payment pay WHERE pay.customer_id = cus.customer_id) AND    --check if customer have any payment records
          EXISTS (SELECT 1 FROM public.rental ren WHERE ren.customer_id = cus.customer_id);        --check if customer have any rental records
     
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'There is no customer with id = % or his payment/rental data is empty', i_customer_id;
    END IF;
   
    SELECT rolname
    INTO client_role_found
    FROM pg_roles
    WHERE rolname = LOWER(format('client_%s_%s', client_role.first_name, client_role.last_name));
    
    IF FOUND THEN
        RAISE EXCEPTION 'There is a role for the customer_id = % with rolename = %', i_customer_id, client_role_found;
    END IF;

    client_new_role := LOWER('client_'||client_role.first_name||'_'||client_role.last_name);
    
    --create new personal role
    EXECUTE 'CREATE ROLE ' ||client_new_role|| ' WITH LOGIN';
   	
   	EXECUTE 'GRANT CONNECT ON DATABASE postgres TO ' ||client_new_role;
    
   	EXECUTE 'GRANT customer TO ' ||client_new_role;
    
    RETURN client_new_role;
END;
$$
LANGUAGE plpgsql;

--create a customer role with ID 470
SELECT create_personalized_role(470);

--there is a check for customer, if there is no customer with added ID there will be a notification
SELECT create_personalized_role(99999);


 
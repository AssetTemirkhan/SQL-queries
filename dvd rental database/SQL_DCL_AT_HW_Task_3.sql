--Homework Assignment
--SQL Foundation – DCL

--Please use Auto-Commit

/*
3 
Read about row-level security (https://www.postgresql.org/docs/12/ddl-rowsecurity.html) and configure it for your database, so that the 
customer can only access his own data in "rental" and "payment" tables (verify using the personalized role you previously created).

*/

--3.1.customer table
--customer view policy for db_developer role
CREATE POLICY db_developer_customers_view ON customer
TO db_developer
USING (TRUE)
WITH CHECK (TRUE);  --for update

--customer view policy for backend_tester role
CREATE POLICY backend_tester_customers_view ON customer
FOR SELECT    --read only
TO backend_tester
USING (TRUE);

--customer view policy for customer role
CREATE POLICY customer_customers_view ON customer
FOR SELECT  --read only his/her data
TO customer
USING (LOWER(first_name) = SPLIT_PART(CURRENT_USER, '_', 2) AND    --use split to get customer first name(2) and get last name (3)
	   LOWER(last_name) = SPLIT_PART(CURRENT_USER, '_', 3)
	  );

--grant permission to table customer to role customer
GRANT SELECT ON public.customer TO customer;

--enable row-level security on the customer table
ALTER TABLE public.customer ENABLE ROW LEVEL SECURITY;


--3.2.rental table
--rental view policy for db_developer role
CREATE POLICY db_developer_rental_view ON rental
TO db_developer
USING (TRUE)
WITH CHECK (TRUE);

--rental view policy for backend_tester role
CREATE POLICY backend_tester_rental_view ON rental
FOR SELECT    
TO backend_tester
USING (TRUE);

--rental data view for customer
CREATE POLICY customer_view_his_rental_data ON rental
FOR SELECT 
TO customer
USING (customer_id = (SELECT customer_id
					  FROM public.customer 
					  WHERE LOWER(first_name) = SPLIT_PART(CURRENT_USER, '_', 2) AND
					  	    LOWER(last_name) = SPLIT_PART(CURRENT_USER, '_', 3)
					  	    ));
                     
     
--grant permission to rental table to customer role
GRANT SELECT ON public.rental TO customer;   

--enable row-level security on the rental table
ALTER TABLE public.rental ENABLE ROW LEVEL SECURITY;




--3.3.payment table
--payment view policy for db_developer role
CREATE POLICY db_developer_payment_view ON payment
TO db_developer
USING (TRUE)
WITH CHECK (TRUE);

--payment view policy for backend_tester role
CREATE POLICY backend_tester_payment_view ON payment
FOR SELECT   
TO backend_tester
USING (TRUE);

--rental data view for customer
CREATE POLICY customer_view_his_payment_data ON payment
FOR SELECT 
TO customer
USING (customer_id = (SELECT customer_id
					  FROM public.customer 
					  WHERE LOWER(first_name) = SPLIT_PART(CURRENT_USER, '_', 2) AND
					  	    LOWER(last_name) = SPLIT_PART(CURRENT_USER, '_', 3)
					  	    ));
                     
     
--grant permission to rental table to customer role
GRANT SELECT ON public.payment TO customer;   

--enable row-level security on the rental table
ALTER TABLE public.payment ENABLE ROW LEVEL SECURITY;



/*
--checking 
--1.db_developer role check
SET ROLE db_developer;

SELECT current_user;

SELECT * FROM  public.customer;

SELECT * FROM  public.rental;

SELECT * FROM  public.payment;


--data is update by db_developer role
UPDATE public.customer
SET first_name ='Asset'
WHERE customer_id =2;

SELECT * FROM  
public.customer
WHERE customer_id =2;

--data is insert by db_developer role
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (NOW(),1525,459,NULL, 1);

RESET ROLE;


--2.backend_tester role check
SET ROLE backend_tester;

SELECT current_user;

SELECT * FROM  public.customer;

SELECT * FROM  public.rental;

SELECT * FROM  public.payment;


--data is not update by backend_tester role, ERROR: permission denied for table customer
UPDATE public.customer
SET first_name ='Asset'
WHERE customer_id =2;


--data is not insert by backend_tester role, ERROR: permission denied for table rental
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (NOW(),1525,459,NULL, 1);

RESET ROLE;



--3.customer role check
SET ROLE customer;

SELECT current_user;

--all data is empty because there is no customer user in database
SELECT * FROM  public.customer;

SELECT * FROM  public.rental;

SELECT * FROM  public.payment;


--data is not update by customer role, ERROR: permission denied for table customer
UPDATE public.customer
SET first_name ='Asset'
WHERE customer_id =2;


--data is not insert by customer role, ERROR: permission denied for table rental
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (NOW(),1525,459,NULL, 1);

RESET ROLE;


--4.client_gordon_allard role check
SET ROLE client_gordon_allard;

SELECT current_user;

--can view only his GORDON ALLARD with customer_id=470 data 
SELECT * FROM  public.customer;

SELECT * FROM  public.rental;

SELECT * FROM  public.payment;


--data is not update by client_gordon_allard role, ERROR: permission denied for table customer
UPDATE public.customer
SET first_name ='Asset'
WHERE customer_id =2;


--data is not insert by client_gordon_allard role, ERROR: permission denied for table rental
INSERT INTO public.rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES (NOW(),1525,459,NULL, 1);

RESET ROLE;

*/
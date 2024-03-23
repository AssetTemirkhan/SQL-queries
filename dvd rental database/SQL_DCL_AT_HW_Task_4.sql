--Homework Assignment
--SQL Foundation – DCL

--Please use Auto-Commit


/*
4. Prepare answers to the following questions:
4.1. How can one restrict access to certain columns of a database table?
4.2. What is the difference between user identification and user authentication?
4.3. What are the recommended authentication protocols for PostgreSQL?
4.4. What is proxy authentication in PostgreSQL and what is it for? Why does it make the previously discussed role-based access control easier to implement?

*/

/*
4.1. How can one restrict access to certain columns of a database table?

To restrict access to certain columns of a database table can be done by use database permissions and privileges. For example by creating new role with limited access to only specific columns of the table.

CREATE ROLE restrict_access LOGIN PASSWORD 'restrict_access123';

GRANT SELECT (title, description, release_year) ON public.film to restrict_access;   --restrict access to certain columns 

SET ROLE restrict_access;

SELECT current_user;

but need to specify column names in select

SELECT title, 
	   description, 
	   release_year
FROM public.film;

if we tried to select all data there will be an error message that we do not have permission for table film, because we have access only to columns (title, description, release_year)

SELECT *
FROM public.film; 

RESET ROLE;


another way to restrict access to certain columns of a database table can be done by using VIEW with limit access to certain columns and exposes the columns for specific role

CREATE ROLE restrict_access LOGIN PASSWORD 'restrict_access123';

CREATE VIEW restrict_access_view AS SELECT title, description, release_year FROM public.film;
  
GRANT SELECT ON restrict_access_view TO restrict_access;

SET ROLE restrict_access;

SELECT current_user;
 
SELECT * FROM restrict_access_view;

or

SELECT title 
FROM restrict_access_view;  

RESET ROLE;


4.2. What is the difference between user identification and user authentication?

User identification refers to the process of identifying a user by their username, for example user: Asset Temirkhan.

User authentication refers to the process of verifying that the user is who he/she claim to be by checking thier password or other authentication credentials, for example user: asset.temirkhan, password: asset123


4.3. What are the recommended authentication protocols for PostgreSQL?

PostgreSQL supports several authentication protocols

Password based authentication. This method uses a password stored on the server to authenticate users, it is simple and easy to use.

LDAP authentication, Lightweight Directory Access Protocol operates similarly to Password based authentication, except that it uses LDAP as the password verification method. 
LDAP used only to validate the user name/password pairs. User should be already exist in the database before LDAP can be used for authentication.

Certificate authentication, this method uses SSL certificates to perform authentication. 
Using this authentication method, server will require that the client provide a valid certificate, no password promt will be sent to the client.


4.4. What is proxy authentication in PostgreSQL and what is it for? Why does it make the previously discussed role-based access control easier to implement?

Proxy authentication in PostgreSQL is a mechanism that allows a Superuser to log in as a different user and perform actions on their behalf. It is useful when needs to connect to a database using a single database user account, but different roles/users need to access to the database with their own credentials. 

Why does it make the previously discussed role-based access control easier to implement?
This is allows us check and control who can access the database and what actions they can perform.
We can use it by set role that we need, run queries that need and then reset role again to Superuser. 
Also, in this case no need to create New Database Connection by role/user that we need to check, we can switch to role that we need.

SET ROLE db_developer;

SELECT current_user;

RESET ROLE;

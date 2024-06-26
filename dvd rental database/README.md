PostgreSQL Sample Database

Summary: in this tutorial, we will introduce you to a PostgreSQL sample database that you can use for learning and practicing PostgreSQL.

We will use the DVD rental database to demonstrate the features of PostgreSQL.

The DVD rental database represents the business processes of a DVD rental store. The DVD rental database has many objects, including:

15 tables
1 trigger
7 views
8 functions
1 domain
13 sequences
DVD Rental ER Model

In the diagram, the asterisk (*), which appears in front of the field, indicates the primary key.

PostgreSQL Sample Database Tables
There are 15 tables in the DVD Rental database:

actor – stores actor data including first name and last name.
film – stores film data such as title, release year, length, rating, etc.
film_actor – stores the relationships between films and actors.
category – stores film’s categories data.
film_category- stores the relationships between films and categories.
store – contains the store data including manager staff and address.
inventory – stores inventory data.
rental – stores rental data.
payment – stores customer’s payments.
staff – stores staff data.
customer – stores customer data.
address – stores address data for staff and customers
city – stores city names.
country – stores country names.

Download DVD Rental Sample Database
https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip

https://www.postgresqltutorial.com/postgresql-getting-started/postgresql-sample-database/

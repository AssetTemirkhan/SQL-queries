--Homework Assignment
--SQL Foundation – DCL

/*
--1. Figure out what security precautions are already used in your 'dvd_rental' database; -- send description
1.1. There is check authentication method, you need to authorized to have access to the data.
1.2. There are different roles: 
	
pg_checkpoint, pg_database_owner, pg_execute_server_program, pg_read_all_data, pg_read_all_settings, pg_read_all_stats, pg_read_server_files, pg_signal_backend, pg_stat_scan_tables, pg_write_all_data, pg_write_server_files roles
	NOSUPERUSER	  		- role cannot act as a superuser 
	NOCREATEDB 	  		- role cannot create new databases
	NOCREATEROLE  		- role cannot create new roles 
	INHERIT 	  		- role inherits the privileges of roles it is a member of
	NOLOGIN 	  		- role cannot be used to log in to the database
	NOREPLICATION 	    - role cannot be used as a replication role 
	NOBYPASSRLS   		- role cannot bypass row-level security policies
	CONNECTION LIMIT -1 - there is not limit on the number of simultaneous connections
	
pg_monitor role:	
	NOSUPERUSER	  		- role cannot act as a superuser 
	NOCREATEDB 	  		- role cannot create new databases
	NOCREATEROLE  		- role cannot create new roles 
	INHERIT 	  		- role inherits the privileges of roles it is a member of
	NOLOGIN 	  		- role cannot be used to log in to the database
	NOREPLICATION 	    - role cannot be used as a replication role 
	NOBYPASSRLS   		- role cannot bypass row-level security policies
	CONNECTION LIMIT -1 - there is not limit on the number of simultaneous connections
	
	pg_read_all_settings - role can read all the settings in the database
	pg_read_all_stats 	 - role can read all statistics in the database
	pg_stat_scan_tables  - role can scan all tables to collect statistics

		
postgres role:
	SUPERUSER  			- has superuser privileges and can perform any action
	CREATEDB  			- can create new databases
	CREATEROLE 			- can create new roles 
	INHERIT 			- new objects created by the role inherit its permissions
	LOGIN 	 			- can log in to the database
	REPLICATION 		- can be a replication role
	BYPASSRLS			- can bypass row-level security
	CONNECTION LIMIT -1 - unlimited simultaneous connections allowed for the role			
	

*/
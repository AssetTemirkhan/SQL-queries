--Verification Task SQL Foundation – DDL

--Task 1
/*
Create database that monitors workload, capabilities and activities of our city's health institutions.
The database needs to represent institutions, their locations, staffing, capacity, capabilities and patients' visits.

Constraints:
✓ 6+ tables
✓ 5+ rows in every table, 50+ rows total
✓ 3NF, Primary and Foreign keys must be defined
✓ Not null constraints where appropriate and at least 2 check constraints of other type
✓ Using DEFAULT and GENERATED ALWAYS AS are encouraged

*/


CREATE DATABASE at_hospital OWNER postgres;

--after create database please create new connection to at_hospital database


CREATE SCHEMA IF NOT EXISTS at_hospital AUTHORIZATION postgres;
SET search_path = at_hospital;

--country
CREATE TABLE IF NOT EXISTS at_hospital.country (
											      country_id SERIAL NOT NULL CONSTRAINT country_pk PRIMARY KEY,  -- used SERIAL to generate a sequence of integers
											      country_name VARCHAR(60) NOT NULL,
											      last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
											      CONSTRAINT country_name_unique UNIQUE (country_name)
											   	 );						
ALTER TABLE at_hospital.country OWNER TO postgres;

--city
CREATE TABLE IF NOT EXISTS at_hospital.city (
											   city_id SERIAL NOT NULL CONSTRAINT city_pk PRIMARY KEY,
											   country_id INTEGER NOT NULL,
											   city_name VARCHAR(60) NOT NULL,
											   last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
											   CONSTRAINT country_id_fkey FOREIGN KEY (country_id) REFERENCES at_hospital.country(country_id) 
												); 
ALTER TABLE at_hospital.city OWNER TO postgres;

--institution
CREATE TABLE IF NOT EXISTS at_hospital.institution (institution_id SERIAL NOT NULL CONSTRAINT institution_pk PRIMARY KEY,
											          institution_name VARCHAR(60) NOT NULL,
											          city_id INTEGER NOT NULL,
												      last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL
									   				 );
ALTER TABLE at_hospital.institution OWNER TO postgres;

--address (location)
CREATE TABLE IF NOT EXISTS at_hospital.address (address_id SERIAL NOT NULL CONSTRAINT address_pk PRIMARY KEY,
												  city_id INTEGER NOT NULL,
												  institution_id INTEGER NOT NULL,
												  address VARCHAR(100) NOT NULL,
												  building VARCHAR (20) NOT NULL,
												  phone VARCHAR (30) NOT NULL,
												  last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
											      CONSTRAINT city_id_fkey FOREIGN KEY (city_id) REFERENCES at_hospital.city(city_id),
											      CONSTRAINT institution_id_fkey FOREIGN KEY (institution_id) REFERENCES at_hospital.institution(institution_id)
											     );
ALTER TABLE at_hospital.address OWNER TO postgres;

--room_type
CREATE TABLE IF NOT EXISTS at_hospital.room_type (room_type_id SERIAL NOT NULL CONSTRAINT room_type_pk PRIMARY KEY,
												    room_type_name VARCHAR (60) NOT NULL,
												    room_beds INTEGER NOT NULL,
												    last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL
												   );
ALTER TABLE at_hospital.room_type OWNER TO postgres;

--room
--available - true (available), false (not available)

CREATE TABLE IF NOT EXISTS at_hospital.room (room_id SERIAL NOT NULL CONSTRAINT room_pk PRIMARY KEY,
											   room_type_id INTEGER NOT NULL,
											   address_id INTEGER NOT NULL,
											   room_number INTEGER NOT NULL,
											   available BOOLEAN NOT NULL,
											   last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
											   CONSTRAINT room_type_id_fkey FOREIGN KEY (room_type_id) REFERENCES at_hospital.room_type(room_type_id),
											   CONSTRAINT address_id_fkey FOREIGN KEY (address_id) REFERENCES at_hospital.address(address_id)
											   );
ALTER TABLE at_hospital.room OWNER TO postgres;

--department
CREATE TABLE IF NOT EXISTS at_hospital.department (department_id SERIAL NOT NULL CONSTRAINT department_pk PRIMARY KEY,
													 department_name VARCHAR(60) NOT NULL,
													 last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL
													);
ALTER TABLE at_hospital.department OWNER TO postgres;

--staff_position
CREATE TABLE IF NOT EXISTS at_hospital.staff_position (staff_position_id SERIAL NOT NULL CONSTRAINT staff_position_pk PRIMARY KEY,
														 staff_position_name VARCHAR (60) NOT NULL,
														 last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL
														);
ALTER TABLE at_hospital.staff_position OWNER TO postgres;

--staff
CREATE TABLE IF NOT EXISTS at_hospital.staff (staff_id SERIAL NOT NULL CONSTRAINT staff_pk PRIMARY KEY,
												department_id INTEGER NOT NULL,
												first_name VARCHAR(30) NOT NULL,
												last_name VARCHAR (30) NOT NULL,
												full_name  VARCHAR (60) GENERATED ALWAYS AS (first_name ||' '||last_name) STORED NOT NULL,
												phone VARCHAR (30) NOT NULL,
												email VARCHAR (60) NOT NULL,
												staff_position_id INTEGER NOT NULL,
												last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
												CONSTRAINT department_id_fkey FOREIGN KEY (department_id) REFERENCES at_hospital.department(department_id),
												CONSTRAINT staff_position_id_fkey FOREIGN KEY (staff_position_id) REFERENCES at_hospital.staff_position(staff_position_id),
										        CONSTRAINT staff_email_unique UNIQUE (email));
ALTER TABLE at_hospital.staff OWNER TO postgres;

--department_head
CREATE TABLE IF NOT EXISTS at_hospital.department_head (department_head_id SERIAL NOT NULL CONSTRAINT department_head_pk PRIMARY KEY,
													 	 department_id INTEGER NOT NULL,
													 	 staff_id INTEGER NOT NULL,
													 	 last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
													 	 CONSTRAINT department_id_fkey FOREIGN KEY (department_id) REFERENCES at_hospital.department(department_id),
													 	 CONSTRAINT staff_id_fkey FOREIGN KEY (staff_id) REFERENCES at_hospital.staff(staff_id)
													 	 );					 	
ALTER TABLE at_hospital.department_head OWNER TO postgres;

--hospital_procedure
CREATE TABLE IF NOT EXISTS at_hospital.hospital_procedure (hospital_procedure_id SERIAL NOT NULL CONSTRAINT hospital_procedure_pk PRIMARY KEY,
															 department_id INTEGER NOT NULL,								           					 
															 procedure_name VARCHAR (60) NOT NULL,
								           					 procedure_cost DECIMAL(10,2) DEFAULT 1 NOT NULL,
														     last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
														     CONSTRAINT procedure_cost_check CHECK(procedure_cost > 0), 							--check that procedure_cost is more than 0
															 CONSTRAINT procedure_department_id_fkey FOREIGN KEY (department_id) REFERENCES at_hospital.department(department_id)
															 );					 	
ALTER TABLE at_hospital.department_head OWNER TO postgres;

--patient
CREATE TABLE IF NOT EXISTS at_hospital.patient (patient_id SERIAL NOT NULL CONSTRAINT patient_pk PRIMARY KEY,
												  first_name VARCHAR(30) NOT NULL,
												  last_name VARCHAR (30) NOT NULL,
												  full_name  VARCHAR (60) GENERATED ALWAYS AS (first_name ||' '||last_name) STORED NOT NULL,
												  phone VARCHAR (30) NOT NULL,
												  email VARCHAR (60) NOT NULL,
												  insurance_number VARCHAR (30) NOT NULL,
												  last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
										          CONSTRAINT patient_email_unique UNIQUE (email, insurance_number));
ALTER TABLE at_hospital.patient OWNER TO postgres;


--patient_visit
CREATE TABLE IF NOT EXISTS at_hospital.patient_visit (patient_visit_id SERIAL NOT NULL CONSTRAINT patient_visit_pk PRIMARY KEY,
														staff_id INTEGER NOT NULL,
														patient_id INTEGER NOT NULL,
														room_id INTEGER NOT NULL,
														hospital_procedure_id INTEGER NOT NULL,
														start_date_time TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
														end_date_time TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
													 	last_update TIMESTAMP WITH time zone DEFAULT NOW() NOT NULL,
														CONSTRAINT staff_id_fkey FOREIGN KEY (staff_id) REFERENCES at_hospital.staff(staff_id),
													 	CONSTRAINT patient_id_fkey FOREIGN KEY (patient_id) REFERENCES at_hospital.patient(patient_id),
													 	CONSTRAINT room_id_fkey FOREIGN KEY (room_id) REFERENCES at_hospital.room(room_id),
													 	CONSTRAINT hospital_procedure_fkey FOREIGN KEY (hospital_procedure_id) REFERENCES at_hospital.hospital_procedure(hospital_procedure_id),
													 	CONSTRAINT start_end_date_check CHECK(start_date_time < end_date_time) 																		--check that start_date_time is less than end_date_time date
													   );
ALTER TABLE at_hospital.patient_visit OWNER TO postgres;



-- insert data to tables

--insert to country table
INSERT INTO at_hospital.country (country_name, last_update)
SELECT * FROM (
VALUES ('Denmark', NOW()),
	   ('Spain', NOW()),
	   ('South Korea', NOW()),
	   ('France', NOW()),
	   ('Australia', NOW())) AS country_to_add (country_name, last_update)
WHERE UPPER (country_to_add.country_name) NOT IN (SELECT UPPER(cou.country_name)  -- check new country_name by country_name in the country table in UPPER CASE
											      FROM at_hospital.country cou);
COMMIT;

--insert to city table with checing for dublicates
INSERT INTO at_hospital.city (country_id, city_name, last_update)
SELECT * FROM (
VALUES ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'DENMARK'), 'Aarhus', NOW()),    --country_id, city_name, last_update
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'DENMARK'), 'Copenhagen', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'SPAIN'), 'Madrid', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'SPAIN'), 'Barcelona', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'SOUTH KOREA'), 'Seoul', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'SOUTH KOREA'), 'Busan', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'FRANCE'), 'Paris', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'FRANCE'), 'Marseille', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'AUSTRALIA'), 'Sydney', NOW()),
	   ((SELECT con.country_id FROM at_hospital.country con WHERE UPPER(con.country_name) = 'AUSTRALIA'), 'Melbourne', NOW())
) AS city_to_add (country_id, city_name, last_update)
WHERE (UPPER(city_to_add.city_name)) NOT IN (SELECT UPPER(city_name)   -- check new added city by name in the city table in UPPER CASE
											 FROM at_hospital.city);
COMMIT;

--insert institution data
INSERT INTO at_hospital.institution (institution_name, city_id, last_update)
SELECT * FROM (
VALUES ('At Hospital', (SELECT cit.city_id  FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'copenhagen'), NOW()),   						--institution_name, city_id, last_update
	   ('Amager Hospital on the island of Amager', (SELECT cit.city_id  FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'copenhagen'), NOW()), 	 	
	   ('Bispebjerg Hospital', (SELECT cit.city_id  FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'aarhus'), NOW()), 	 	
	   ('Quirónsalud Madrid University Hospital', (SELECT cit.city_id  FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'madrid'), NOW()), 	 
	   ('Quirónsalud Barcelona Hospital', (SELECT cit.city_id  FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'barcelona'), NOW()),
	   ('H Plus Yangji Hospital', (SELECT cit.city_id  FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'seoul'), NOW())	

	   ) AS institution_to_add (institution_name, city_id, last_update)
WHERE (UPPER(institution_to_add.institution_name)) NOT IN (SELECT UPPER(institution_name)   -- check new added institution name by name in the institution table in UPPER CASE
											 FROM at_hospital.institution);
COMMIT;

--insert to address table 
INSERT INTO at_hospital.address (city_id, institution_id, address, building, phone, last_update)
SELECT * FROM (
VALUES ((SELECT cit.city_id FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'copenhagen'),    --city_id  address,
		(SELECT ins.institution_id FROM at_hospital.institution ins WHERE LOWER(ins.institution_name) = 'at hospital'), --institution_id
		 'Blegdamsvej', '9', '+45 55 55 55 55', NOW()), --address, building, phone, last_update
		
		((SELECT cit.city_id FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'madrid'),    --city_id  address,
		(SELECT ins.institution_id FROM at_hospital.institution ins WHERE LOWER(ins.institution_name) = 'quirónsalud madrid university hospital'), --institution_id
		 'C. Diego de Velázquez', '1', '+34 999 99 99 99', NOW()), --address, building, phone, last_update 
		
	    ((SELECT cit.city_id FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'barcelona'),    --city_id  address,
		(SELECT ins.institution_id FROM at_hospital.institution ins WHERE LOWER(ins.institution_name) = 'quirónsalud barcelona hospital'), --institution_id
		 'Plaça Alfonso Comín', '5', '+34 888 88 88 88', NOW()), --address, building, phone, last_update  
		
		 ((SELECT cit.city_id FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'aarhus'),    --city_id  address,
		(SELECT ins.institution_id FROM at_hospital.institution ins WHERE LOWER(ins.institution_name) = 'bispebjerg hospital'), --institution_id
		 'Bispebjerg Bakke', '23', '+45 38 39 39 39', NOW()), --address, building, phone, last_update   
		
		((SELECT cit.city_id FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'copenhagen'),    --city_id  address,
		(SELECT ins.institution_id FROM at_hospital.institution ins WHERE LOWER(ins.institution_name) = 'amager hospital on the island of amager'), --institution_id
		 'Italiensvej', '1', '+45 38 38 38 38', NOW()), --address, building, phone, last_update   
		 
		 ((SELECT cit.city_id FROM at_hospital.city cit WHERE LOWER(cit.city_name) = 'seoul'),    --city_id  address,
		(SELECT ins.institution_id FROM at_hospital.institution ins WHERE LOWER(ins.institution_name) = 'h plus yangji hospital'), --institution_id
		 'Nambusunhwan-ro', '1636', '+82 1818-1818', NOW()) --address, building, phone, last_update   
	  
		 
	   ) AS address_to_add (city_id, institution_id, address, building, phone, last_update)
WHERE (UPPER(address_to_add.address), UPPER(address_to_add.building), UPPER(address_to_add.phone)) NOT IN (SELECT UPPER(address), UPPER(building), UPPER(phone)   -- check new added city by name in the city tablein UPPER CASE
											 															   FROM at_hospital.address);
COMMIT;

--insert room_type
INSERT INTO at_hospital.room_type (room_type_name, room_beds, last_update)
SELECT * FROM (
VALUES ('Twin Sharing Room', 2, NOW ()),
	   ('Premium Twin Sharing Room', 2, NOW ()),
	   ('Deluxe Room', 1, NOW ()),
	   ('Premium Deluxe', 1, NOW ()),
	   ('Suite', 1, NOW ())) AS room_type_to_add (room_type_name, room_beds, last_update)
WHERE UPPER (room_type_to_add.room_type_name) NOT IN (SELECT UPPER(rtyp.room_type_name)  -- check new room_type by room_type in the room_type table in UPPER CASE
											   		  FROM at_hospital.room_type rtyp);
COMMIT;


--insert room twin sharing room
--available - true (available) and false (not available)  
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'twin sharing room'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 101, TRUE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, unavailable, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;		

--insert room 2 twin sharing room
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'twin sharing room'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 102, FALSE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 3 premium twin sharing room
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'premium twin sharing room'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 201, FALSE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 4 premium twin sharing room
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'premium twin sharing room'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 202, TRUE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 5 deluxe room
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'deluxe room'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 301, FALSE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 6 deluxe room
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'deluxe room'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 302, TRUE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 7 premium deluxe
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'premium deluxe'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 401, TRUE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 8 premium deluxe
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'premium deluxe'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 402, TRUE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	

--insert room 9 suite
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'suite'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 501, FALSE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
										FROM at_hospital.room);
COMMIT;	


--insert room 10 suite
INSERT INTO at_hospital.room (room_type_id, address_id, room_number, available, last_update)
SELECT * FROM (
VALUES ((SELECT roo.room_type_id FROM at_hospital.room_type roo WHERE LOWER(roo.room_type_name) = 'suite'),    --room_type_id,
		(SELECT addr.address_id  FROM at_hospital.address addr WHERE LOWER(addr.address) = 'blegdamsvej' AND LOWER(addr.building)='9' AND LOWER(addr.phone) = '+45 55 55 55 55' ),  --address_id
		 502, FALSE, NOW()) --room_number, available status, last_update
	   ) AS room_to_add (room_type_id, address_id, room_number, available, last_update)
WHERE (room_to_add.room_number) NOT IN (SELECT room_number  -- check new room_number by room_number in the room table
									    FROM at_hospital.room);
COMMIT;	

--department
INSERT INTO at_hospital.department(department_name, last_update)
SELECT * FROM (
VALUES ('Dental', NOW()),
	   ('Gastroenterology', NOW()),
	   ('Neurology', NOW()),
	   ('Ophthalmology', NOW()),
	   ('Endocrinology', NOW()),
	   ('Oncology', NOW())) AS department_to_add (department_name, last_update)
WHERE UPPER (department_to_add.department_name) NOT IN (SELECT UPPER(department_name)  -- check new department_name by department_name in the department table in UPPER CASE
											   			FROM at_hospital.department);
COMMIT;


--staff_position
INSERT INTO at_hospital.staff_position (staff_position_name, last_update)
SELECT * FROM (
VALUES ('Physician', NOW()),
	   ('Physician Assistant', NOW()),
	   ('Nurse', NOW()),
	   ('Nurse Assistant', NOW()),
	   ('Therapist', NOW()),
	   ('Therapist Assistant', NOW()),
	   ('Dental', NOW()),
	   ('Dental Assistant', NOW()),
	   ('Pharmacist', NOW()),
	   ('Pharmacist Assistant', NOW())) AS staff_position_to_add (staff_position_name, last_update)
WHERE UPPER (staff_position_to_add.staff_position_name) NOT IN (SELECT UPPER(staff_position_name)  -- check new staff_position_name by staff_position_name in the staff_position table in UPPER CASE
											   					FROM at_hospital.staff_position);
COMMIT;


--staff
INSERT INTO at_hospital.staff (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'dental'),    				 --department_id,
		'Asset', 'Temirkhan', '+45 55 12 22 22', 'asset.temirkhan@at_hospital.com',												 --first_name, last_name, phone, email, 
        (SELECT stpos.staff_position_id FROM at_hospital.staff_position stpos WHERE LOWER(stpos.staff_position_name) = 'dental'),  --staff_position_id
	    NOW() 																													     --last_update
        )) AS staff_to_add (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
WHERE (UPPER(staff_to_add.first_name), UPPER(staff_to_add.last_name), UPPER(staff_to_add.email))  NOT IN (SELECT UPPER (sta.first_name), UPPER(sta.last_name), UPPER(sta.email)   		   -- check new staff by first_name, last_name, email in the staff table
											   														      FROM at_hospital.staff sta);
COMMIT;

--staff 2
INSERT INTO at_hospital.staff (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'oncology'),    					 --department_id,
		'Dennis', 'Bergkamp', '+45 55 10 10 10', 'dennis.bergkamp@at_hospital.com',												 	 --first_name, last_name, phone, email, 
        (SELECT stpos.staff_position_id FROM at_hospital.staff_position stpos WHERE LOWER(stpos.staff_position_name) = 'physician'),   --staff_position_id
	    NOW() 																													 	 	 --last_update
        )) AS staff_to_add (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
WHERE (UPPER(staff_to_add.first_name), UPPER(staff_to_add.last_name), UPPER(staff_to_add.email))  NOT IN (SELECT UPPER (sta.first_name), UPPER(sta.last_name), UPPER(sta.email)   			-- check new staff by first_name, last_name, email in the staff table
											   														      FROM at_hospital.staff sta);
COMMIT;


--staff 3
INSERT INTO at_hospital.staff (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'gastroenterology'),    			 --department_id,
		'Dirk', 'Kuyt', '+45 55 18 18 18', 'dirk.kuyt@at_hospital.com',												 				 --first_name, last_name, phone, email, 
        (SELECT stpos.staff_position_id FROM at_hospital.staff_position stpos WHERE LOWER(stpos.staff_position_name) = 'therapist'),   --staff_position_id
	    NOW() 																													 	 	 --last_update
        )) AS staff_to_add (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
WHERE (UPPER(staff_to_add.first_name), UPPER(staff_to_add.last_name), UPPER(staff_to_add.email))  NOT IN (SELECT UPPER (sta.first_name), UPPER(sta.last_name), UPPER(sta.email)   			-- check new staff by first_name, last_name, email in the staff table
											   														      FROM at_hospital.staff sta);
COMMIT;

--staff 4
INSERT INTO at_hospital.staff (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'ophthalmology'),    			 --department_id,
		'Carles', 'Puyol', '+45 55 05 05 05', 'carles.puyol@at_hospital.com',												 			 --first_name, last_name, phone, email, 
        (SELECT stpos.staff_position_id FROM at_hospital.staff_position stpos WHERE LOWER(stpos.staff_position_name) = 'physician'),   --staff_position_id
	    NOW() 																													 	 	 --last_update
        )) AS staff_to_add (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
WHERE (UPPER(staff_to_add.first_name), UPPER(staff_to_add.last_name), UPPER(staff_to_add.email))  NOT IN (SELECT UPPER (sta.first_name), UPPER(sta.last_name), UPPER(sta.email)   			-- check new staff by first_name, last_name, email in the staff table
											   														      FROM at_hospital.staff sta);
COMMIT;

--staff 5
INSERT INTO at_hospital.staff (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'neurology'),    			 			   --department_id,
		'Novak', 'Djokovic', '+45 55 01 01 01', 'novak.djokovic@at_hospital.com',												 				   --first_name, last_name, phone, email, 
        (SELECT stpos.staff_position_id FROM at_hospital.staff_position stpos WHERE LOWER(stpos.staff_position_name) = 'physician assistant'),   --staff_position_id
	    NOW() 																													 	 	           --last_update
        )) AS staff_to_add (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
WHERE (UPPER(staff_to_add.first_name), UPPER(staff_to_add.last_name), UPPER(staff_to_add.email))  NOT IN (SELECT UPPER (sta.first_name), UPPER(sta.last_name), UPPER(sta.email)   			-- check new staff by first_name, last_name, email in the staff table
											   														      FROM at_hospital.staff sta);
COMMIT;

--staff 6
INSERT INTO at_hospital.staff (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'endocrinology'),    			 --department_id,
		'Xabi', 'Alonso', '+45 55 14 14 14', 'xabi.alonso@at_hospital.com',												 			 --first_name, last_name, phone, email, 
        (SELECT stpos.staff_position_id FROM at_hospital.staff_position stpos WHERE LOWER(stpos.staff_position_name) = 'physician'),   --staff_position_id
	    NOW() 																													 	 	 --last_update
        )) AS staff_to_add (department_id, first_name, last_name, phone, email, staff_position_id, last_update)
WHERE (UPPER(staff_to_add.first_name), UPPER(staff_to_add.last_name), UPPER(staff_to_add.email))  NOT IN (SELECT UPPER (sta.first_name), UPPER(sta.last_name), UPPER(sta.email)   			-- check new staff by first_name, last_name, email in the staff table
											   														      FROM at_hospital.staff sta);
COMMIT;


--department_head
INSERT INTO at_hospital.department_head (department_id, staff_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'dental'),    			 			   								    					   --department_id,
        (SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),    --staff_id
	    NOW() 																														 	 	           												   --last_update
        )) AS department_head_to_add (department_id, staff_id, last_update)
WHERE ((department_head_to_add.department_id), (department_head_to_add.staff_id))  NOT IN (SELECT (deph.department_id), (deph.staff_id)
											   											   FROM at_hospital.department_head deph);  																   --check new department head by department_id, staff_id, email in the department_head table
COMMIT;



--department_head 2
INSERT INTO at_hospital.department_head (department_id, staff_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'oncology'),    			 			   								    					   --department_id,
        (SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),    --staff_id
	    NOW() 																														 	 	           												   --last_update
        )) AS department_head_to_add (department_id, staff_id, last_update)
WHERE ((department_head_to_add.department_id), (department_head_to_add.staff_id))  NOT IN (SELECT (deph.department_id), (deph.staff_id)
											   											   FROM at_hospital.department_head deph); 																   --check new department head by department_id, staff_id, email in the department_head table
COMMIT;


--department_head 3
INSERT INTO at_hospital.department_head (department_id, staff_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'gastroenterology'),    			 			   								      --department_id,
        (SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   --staff_id
	    NOW() 																														 	 	           									  --last_update
        )) AS department_head_to_add (department_id, staff_id, last_update)
WHERE ((department_head_to_add.department_id), (department_head_to_add.staff_id))  NOT IN (SELECT (deph.department_id), (deph.staff_id)
											   											   FROM at_hospital.department_head deph); 													  --check new department head by department_id, staff_id, email in the department_head table
COMMIT;


--department_head 4
INSERT INTO at_hospital.department_head (department_id, staff_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'ophthalmology'),    			 			   								    		--department_id,
        (SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'carles' AND LOWER(sta.last_name) = 'puyol' AND LOWER(sta.email) = 'carles.puyol@at_hospital.com'),   --staff_id
	    NOW() 																														 	 	           											--last_update
        )) AS department_head_to_add (department_id, staff_id, last_update)
WHERE ((department_head_to_add.department_id), (department_head_to_add.staff_id))  NOT IN (SELECT (deph.department_id), (deph.staff_id) 														--check new department head by department_id, staff_id, email in the department_head table
											   											   FROM at_hospital.department_head deph);
COMMIT;


--department_head 5
INSERT INTO at_hospital.department_head (department_id, staff_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'neurology'),    			 			   								    				--department_id,
        (SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'novak' AND LOWER(sta.last_name) = 'djokovic' AND LOWER(sta.email) = 'novak.djokovic@at_hospital.com'),   --staff_id
	    NOW() 																														 	 	           												--last_update
        )) AS department_head_to_add (department_id, staff_id, last_update)
WHERE ((department_head_to_add.department_id), (department_head_to_add.staff_id))  NOT IN (SELECT (deph.department_id), (deph.staff_id)
											   											   FROM at_hospital.department_head deph); 																--check new department head by department_id, staff_id, email in the department_head table
COMMIT;


--department_head 6
INSERT INTO at_hospital.department_head (department_id, staff_id, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'endocrinology'),    			 			   								    		    --department_id,
        (SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'xabi' AND LOWER(sta.last_name) = 'alonso' AND LOWER(sta.email) = 'xabi.alonso@at_hospital.com'),         --staff_id
	    NOW() 																														 	 	           												--last_update
        )) AS department_head_to_add (department_id, staff_id, last_update)
WHERE ((department_head_to_add.department_id), (department_head_to_add.staff_id))  NOT IN (SELECT (deph.department_id), (deph.staff_id)
											   											   FROM at_hospital.department_head deph); 																--check new department head by department_id, staff_id, email in the department_head table
COMMIT;



--hospital_procedure
INSERT INTO at_hospital.hospital_procedure(department_id, procedure_name, procedure_cost, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'dental'),    --department_id,
       'Endodontics - Root Canal Treatment', 50, NOW()) 															 --procedure_name, procedure_cost, last_update 
		) AS hospital_procedure_to_add (department_id, procedure_name, procedure_cost, last_update)
WHERE UPPER (hospital_procedure_to_add.procedure_name) NOT IN (SELECT UPPER(hosp.procedure_name) 					 --check new procedure_name by procedure_name in the procedure table in UPPER CASE
											   					FROM at_hospital.hospital_procedure hosp);
COMMIT;


--hospital_procedure 2
INSERT INTO at_hospital.hospital_procedure(department_id, procedure_name, procedure_cost, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'oncology'),    --department_id,
       'Diagnosis and Treatment', 70, NOW()) 															               --procedure_name, procedure_cost, last_update 
		) AS hospital_procedure_to_add (department_id, procedure_name, procedure_cost, last_update)
WHERE UPPER (hospital_procedure_to_add.procedure_name) NOT IN (SELECT UPPER(hosp.procedure_name) 					   --check new procedure_name by procedure_name in the procedure table in UPPER CASE
											   				   FROM at_hospital.hospital_procedure hosp);
COMMIT;


--hospital_procedure 3
INSERT INTO at_hospital.hospital_procedure(department_id, procedure_name, procedure_cost, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'gastroenterology'),    --department_id,
       'Endoscopic Procedures', 90, NOW()) 															                           --procedure_name, procedure_cost, last_update 
		) AS hospital_procedure_to_add (department_id, procedure_name, procedure_cost, last_update)
WHERE UPPER (hospital_procedure_to_add.procedure_name) NOT IN (SELECT UPPER(hosp.procedure_name) 							   --check new procedure_name by procedure_name in the procedure table in UPPER CASE
											   					FROM at_hospital.hospital_procedure hosp);
COMMIT;

--hospital_procedure 4
INSERT INTO at_hospital.hospital_procedure(department_id, procedure_name, procedure_cost, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'ophthalmology'),    --department_id,
       'Simple & Complicated Ophthalmic Procedures', 40, NOW()) 															--procedure_name, procedure_cost, last_update 
		) AS hospital_procedure_to_add (department_id, procedure_name, procedure_cost, last_update)
WHERE UPPER (hospital_procedure_to_add.procedure_name) NOT IN (SELECT UPPER(hosp.procedure_name) 							--check new procedure_name by procedure_name in the procedure table in UPPER CASE
											   				   FROM at_hospital.hospital_procedure hosp);
COMMIT;


--hospital_procedure 5
INSERT INTO at_hospital.hospital_procedure(department_id, procedure_name, procedure_cost, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'neurology'),    --department_id,
       'Paediatric Neurology', 50, NOW()) 															                    --procedure_name, procedure_cost, last_update 
		) AS hospital_procedure_to_add (department_id, procedure_name, procedure_cost, last_update)
WHERE UPPER (hospital_procedure_to_add.procedure_name) NOT IN (SELECT UPPER(hosp.procedure_name) 						--check new procedure_name by procedure_name in the procedure table in UPPER CASE
											   				   FROM at_hospital.hospital_procedure hosp);
COMMIT;

--hospital_procedure 6
INSERT INTO at_hospital.hospital_procedure(department_id, procedure_name, procedure_cost, last_update)
SELECT * FROM (
VALUES ((SELECT dep.department_id FROM at_hospital.department dep WHERE LOWER(dep.department_name) = 'endocrinology'),    --department_id,
       'Diabetes Care', 80, NOW()) 															                                --procedure_name, procedure_cost, last_update 
		) AS hospital_procedure_to_add (department_id, procedure_name, procedure_cost, last_update)
WHERE UPPER (hospital_procedure_to_add.procedure_name) NOT IN (SELECT UPPER(hosp.procedure_name) 							--check new procedure_name by procedure_name in the procedure table in UPPER CASE
											   					FROM at_hospital.hospital_procedure hosp);
COMMIT;


--insert patient
INSERT INTO at_hospital.patient (first_name, last_name, phone, email, insurance_number, last_update)
SELECT * FROM (
VALUES ('Rafael', 'Nadal', '+34 777 77 77 77', 'rafael.nadal@tennis.com', 123456789101, NOW()),
	   ('Tom', 'Cruise', '+1 55 22 23 44', 'tom.cruise@movie.com', 444333222111, NOW()),
	   ('Stefanos', 'Tsitsipas', '+30 11 99 99 00', 'stefanos.tsitsipas@tennis.com', 999888777666, NOW()),
       ('Francesco', 'Totti', '+39 10 10 01 10', 'francesco.totti@football.com', 101111010101, NOW()),
       ('Arjen', 'Robben', '+31 33 12 56 88', 'arjen.robben@football.com', 111777888999, NOW()),
       ('Lewis', 'Hamilton', '+44 44 44 44 44', 'lewis.hamilton@f1.com', 444444444444, NOW()),
       ('Daniel', 'Ricciardo', '+61 33 33 33 33', 'daniel.ricciardo@f1.com', 333333333333, NOW()),
       ('Tom', 'Hanks', '+1 11 11 11 11', 'tom.hanks@movie.com', 111111111111, NOW()),
       ('Jackie', 'Chan', '+86 90 99 99 99', 'jackie.chan@movie.com', 999999999999, NOW()),
       ('Harry', 'Potter', '+44 77 55 88 35', 'harry.potter@movie.com', 222222222222, NOW())
			  ) AS patient_to_add (first_name, last_name, phone, email, insurance_number, last_update)
WHERE (UPPER (patient_to_add.first_name), UPPER (patient_to_add.last_name), UPPER (patient_to_add.email))  NOT IN (SELECT UPPER(pat.first_name),UPPER(pat.last_name), UPPER(pat.email)   -- check new patient by first_name, last_name, email in the patient table in UPPER CASE
											   																	   FROM at_hospital.patient pat);
COMMIT;

--patient_visit 1
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'xabi' AND LOWER(sta.last_name) = 'alonso' AND LOWER(sta.email) = 'xabi.alonso@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'rafael' AND LOWER(pta.last_name) = 'nadal' AND LOWER(pta.email) = 'rafael.nadal@tennis.com'),    --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 501 AND 
	            LOWER(rotyp.room_type_name) = 'suite'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diabetes care') , 							  					  --hospital_procedure_id
		(TIMESTAMP '2023-01-10 09:10:30.450'),			          --start_date_time
		(TIMESTAMP '2023-01-10 09:10:30.450' + INTERVAL '1 day'), --end_date_time, start_date_time plus 1 day
		NOW()													  --last_update												 	 	           												   			  
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit 2 
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'xabi' AND LOWER(sta.last_name) = 'alonso' AND LOWER(sta.email) = 'xabi.alonso@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'cruise' AND LOWER(pta.email) = 'tom.cruise@movie.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 502 AND 
	            LOWER(rotyp.room_type_name) = 'suite'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diabetes care') , 							 					   --hospital_procedure_id
		(TIMESTAMP '2022-12-05 10:09:30.450'),					  --start_date_time 
		(TIMESTAMP '2022-12-05 10:08:30.450' + INTERVAL '1 day'), --end_date_time, start_date_time plus 1 day
		NOW()													  --last_update												 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit 3
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),        --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'stefanos' AND LOWER(pta.last_name) = 'tsitsipas' AND LOWER(pta.email) = 'stefanos.tsitsipas@tennis.com'),     --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 101 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 	--hospital_procedure_id
		(NOW()-INTERVAL '45 days'),					     --start_date_time 
		((NOW()-INTERVAL '45 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus 2 days
		NOW()											 --last_update														 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 4
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'francesco' AND LOWER(pta.last_name) = 'totti' AND LOWER(pta.email) = 'francesco.totti@football.com'),    --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 102 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endodontics - root canal treatment') , 		--hospital_procedure_id
		(NOW()-INTERVAL '30 days'),					     --start_date_time
		((NOW()-INTERVAL '30 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus 3 days
		NOW()											 --last_update
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 5
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'arjen' AND LOWER(pta.last_name) = 'robben' AND LOWER(pta.email) = 'arjen.robben@football.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 201 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '50 days'),						 --start_date_time
		((NOW()-INTERVAL '50 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus 2 days
		NOW()											 --last_update																						 	 	           												             
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 6
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'lewis' AND LOWER(pta.last_name) = 'hamilton' AND LOWER(pta.email) = 'lewis.hamilton@f1.com'),            --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 202 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 						--hospital_procedure_id
		(NOW()-INTERVAL '45 days'),						 --start_date_time
		((NOW()-INTERVAL '45 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus 3 days
		NOW()		 									 --last_update																							 	 	           												             
        )) AS patient_visit_to_add ;
 COMMIT;



--patient_visit for 7
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'daniel' AND LOWER(pta.last_name) = 'ricciardo' AND LOWER(pta.email) = 'daniel.ricciardo@f1.com'),        --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 301 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  				  --hospital_procedure_id
		(NOW()-INTERVAL '55 days'),						 --start_date_time
		((NOW()-INTERVAL '55 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus 
		NOW()																									 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 8
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),     --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'hanks' AND LOWER(pta.email) = 'tom.hanks@movie.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 302 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '55 days'),						 --start_date_time
		((NOW()-INTERVAL '55 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus 2 days
		NOW()										     --last_update																				 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 9
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'jackie' AND LOWER(pta.last_name) = 'chan' AND LOWER(pta.email) = 'jackie.chan@movie.com'),   --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 401 AND 
	            LOWER(rotyp.room_type_name) = 'premium deluxe'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							   --hospital_procedure_id
		(NOW()-INTERVAL '50 days'),							--start_date_time
		((NOW()-INTERVAL '50 days') + INTERVAL '1 day'), 	--end_date_time, start_date_time plus 1 day 
		NOW()											    --last_update																		 	 	           												             
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 10
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'carles' AND LOWER(sta.last_name) = 'puyol' AND LOWER(sta.email) = 'carles.puyol@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'harry' AND LOWER(pta.last_name) = 'potter' AND LOWER(pta.email) = 'harry.potter@movie.com'),       --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 402 AND 
	            LOWER(rotyp.room_type_name) = 'premium deluxe'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='simple & complicated ophthalmic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '20 days'),							--start_date_time
		((NOW()-INTERVAL '20 days') + INTERVAL '3 day'),    --end_date_time, start_date_time plus 3 days
		NOW()												--last_update																			 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 11
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'novak' AND LOWER(sta.last_name) = 'djokovic' AND LOWER(sta.email) = 'novak.djokovic@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'rafael' AND LOWER(pta.last_name) = 'nadal' AND LOWER(pta.email) = 'rafael.nadal@tennis.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 101 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='paediatric neurology') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '57 days'),						 --start_date_time
		((NOW()-INTERVAL '57 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus 3 days
		NOW()			                                 --last_update																								 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 12
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'francesco' AND LOWER(pta.last_name) = 'totti' AND LOWER(pta.email) = 'francesco.totti@football.com'),    --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 102 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '24 days'), 					  --start_date_time
		((NOW()-INTERVAL '24 days') + INTERVAL '2 day'),  --end_date_time, start_date_time plus interval 2 days
		NOW()											  --last_update															 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 13
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'), --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'lewis' AND LOWER(pta.last_name) = 'hamilton' AND LOWER(pta.email) = 'lewis.hamilton@f1.com'),          --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 201 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '20 days'),						 --start_date_time, 
		((NOW()-INTERVAL '20 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus 3 days
		NOW()										     --last_update															 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 14
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'cruise' AND LOWER(pta.email) = 'tom.cruise@movie.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 202 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '30 days'),						 --start_date_time
		((NOW()-INTERVAL '30 days') + INTERVAL '1 day'), --end_date_time, start_date_time plus 1 day 
		NOW()										     --last_update																		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 15
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'novak' AND LOWER(sta.last_name) = 'djokovic' AND LOWER(sta.email) = 'novak.djokovic@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'jackie' AND LOWER(pta.last_name) = 'chan' AND LOWER(pta.email) = 'jackie.chan@movie.com'),            --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 301 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='paediatric neurology') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '35 days'),						 --start_date_time
		((NOW()-INTERVAL '35 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus 2 days
		NOW()											 --last_update														 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;



--patient_visit for 16
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'), --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'harry' AND LOWER(pta.last_name) = 'potter' AND LOWER(pta.email) = 'harry.potter@movie.com'),           --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 302 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '10 days'), 					 --start_date_time
		((NOW()-INTERVAL '10 days') + INTERVAL '1 day'), --end_date_time, start_date_time plus interval 1 day
		NOW()											 --last_update																	 		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 17
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   				--staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'stefanos' AND LOWER(pta.last_name) = 'tsitsipas' AND LOWER(pta.email) = 'stefanos.tsitsipas@tennis.com'),  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 401 AND 
	            LOWER(rotyp.room_type_name) = 'premium deluxe'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '15 days'),					 --start_date_time, 
		((NOW()-INTERVAL '15') + INTERVAL '3 day'),  --end_date_time, start_date_time plus interval 3 days
		NOW()										 --last_update																		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 18
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'arjen' AND LOWER(pta.last_name) = 'robben' AND LOWER(pta.email) = 'arjen.robben@football.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 402 AND 
	            LOWER(rotyp.room_type_name) = 'premium deluxe'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '2 days'),						 --start_date_time, 
		((NOW()-INTERVAL '2 days') + INTERVAL '2 day'),  --end_date_time, start_date_time plus 2 days
		NOW()									  	     --last_update																 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 19
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'daniel' AND LOWER(pta.last_name) = 'ricciardo' AND LOWER(pta.email) = 'daniel.ricciardo@f1.com'),        --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 501 AND 
	            LOWER(rotyp.room_type_name) = 'suite'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '7 days'), 						 --start_date_time
		((NOW()-INTERVAL '7 days') + INTERVAL '2 day'),  --end_date_time, start_date_time plus interval 2 days
		NOW()										     --last_update											 		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 20
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'hanks' AND LOWER(pta.email) = 'tom.hanks@movie.com'),         		  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 502 AND 
	            LOWER(rotyp.room_type_name) = 'suite'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '15 days'),						 --start_date_time, 
		((NOW()-INTERVAL '15 days') + INTERVAL '4 day'), --end_date_time, start_date_time plus 4 days
		NOW()											 --last_update																			 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 21
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   	 --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'rafael' AND LOWER(pta.last_name) = 'nadal' AND LOWER(pta.email) = 'rafael.nadal@tennis.com'),   --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number = 101 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '27 days'),						  --start_date_time, 
		((NOW()-INTERVAL '27 days') + INTERVAL '2 day'),  --end_date_time, start_date_time plus interval 2 days
		NOW()											  --last_update																 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 22
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'cruise' AND LOWER(pta.email) = 'tom.cruise@movie.com'),         		  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 102 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '8 days'),							--start_date_time, 
		((NOW()-INTERVAL '8 days') + INTERVAL '2 day'),     --end_date_time, start_date_time plus 2 days
		NOW()											    --last_update																						 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 23
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'jackie' AND LOWER(pta.last_name) = 'chan' AND LOWER(pta.email) = 'jackie.chan@movie.com'),         	  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 201 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '15 days'), 					 --start_date_time
		((NOW()-INTERVAL '15 days') + INTERVAL '1 day'), --end_date_time, start_date_time plus interval 1 day
		NOW()											 --last_update																	 		 	 	           												             
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 24
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'harry' AND LOWER(pta.last_name) = 'potter' AND LOWER(pta.email) = 'harry.potter@movie.com'),         	  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 202 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '10 days'),						 --start_date_time, 
		((NOW()-INTERVAL '10 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus 2 days
		NOW()											 --last_update																			 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 25
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'cruise' AND LOWER(pta.email) = 'tom.cruise@movie.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number = 301 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '13 days'),						 --start_date_time, 
		((NOW()-INTERVAL '13 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus interval 2 days
		NOW()											 --last_update															 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 26
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'lewis' AND LOWER(pta.last_name) = 'hamilton' AND LOWER(pta.email) = 'lewis.hamilton@f1.com'),           --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 302 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '9 days'), 						--start_date_time
		((NOW()-INTERVAL '9 days') + INTERVAL '1 day'), --end_date_time, start_date_time plus interval 1 day
		NOW()									        --last_update														 		 	 	           												             
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 27
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   		--staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'daniel' AND LOWER(pta.last_name) = 'ricciardo' AND LOWER(pta.email) = 'daniel.ricciardo@f1.com'),  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number = 401 AND 
	            LOWER(rotyp.room_type_name) = 'premium deluxe'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '5 days'),						 --start_date_time, 
		((NOW()-INTERVAL '5 days') + INTERVAL '3 day'),  --end_date_time, start_date_time plus interval 3 days
		NOW()											 --last_update																			 	 	           												             
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 28
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'hanks' AND LOWER(pta.email) = 'tom.hanks@movie.com'),         		  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 402 AND 
	            LOWER(rotyp.room_type_name) = 'premium deluxe'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '18 days'),	 					 --start_date_time
		((NOW()-INTERVAL '18 days') + INTERVAL '1 day'), --end_date_time, start_date_time plus interval 1 day
		NOW()											 --last_update																 		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 29
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   				--staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'francesco' AND LOWER(pta.last_name) = 'totti' AND LOWER(pta.email) = 'francesco.totti@football.com'),      --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number = 501 AND 
	            LOWER(rotyp.room_type_name) = 'suite'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '14 days'),						 --start_date_time, 
		((NOW()-INTERVAL '14 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus interval 2 days
		NOW()										   	 --last_update															 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 30
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),     --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'stefanos' AND LOWER(pta.last_name) = 'tsitsipas' AND LOWER(pta.email) = 'stefanos.tsitsipas@tennis.com'),  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 502 AND 
	            LOWER(rotyp.room_type_name) = 'suite'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '40 days'),						 --start_date_time, 
		((NOW()-INTERVAL '40 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus 3 days
		NOW()											 --last_update															 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 31
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'arjen' AND LOWER(pta.last_name) = 'robben' AND LOWER(pta.email) = 'arjen.robben@football.com'),         --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 101 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment'), 							  --hospital_procedure_id
		(NOW()-INTERVAL '45 days'), 					 --start_date_time
		((NOW()-INTERVAL '45 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus interval 2 days
		NOW()										     --last_update											 		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 32
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   		--staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'daniel' AND LOWER(pta.last_name) = 'ricciardo' AND LOWER(pta.email) = 'daniel.ricciardo@f1.com'),  --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number = 102 AND 
	            LOWER(rotyp.room_type_name) = 'twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '38 days'),						 --start_date_time, 
		((NOW()-INTERVAL '38 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus interval 2 days
		NOW()											 --last_update														 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 33
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),  --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'rafael' AND LOWER(pta.last_name) = 'nadal' AND LOWER(pta.email) = 'rafael.nadal@tennis.com'),           --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 201 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '41 days'),						 --start_date_time, 
		((NOW()-INTERVAL '41 days') + INTERVAL '1 day'), --end_date_time, start_date_time plus 1 day
		NOW()											 --last_update													 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 34
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'asset' AND LOWER(sta.last_name) = 'temirkhan' AND LOWER(sta.email) = 'asset.temirkhan@at_hospital.com'), --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'lewis' AND LOWER(pta.last_name) = 'hamilton' AND LOWER(pta.email) = 'lewis.hamilton@f1.com'),          --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 202 AND 
	            LOWER(rotyp.room_type_name) = 'premium twin sharing room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) = 'endodontics - root canal treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '39 days'), 					 --start_date_time
		((NOW()-INTERVAL '39 days') + INTERVAL '2 day'), --end_date_time, start_date_time plus interval 2 days
		NOW()										     --last_update											 		 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--patient_visit for 35
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dirk' AND LOWER(sta.last_name) = 'kuyt' AND LOWER(sta.email) = 'dirk.kuyt@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'tom' AND LOWER(pta.last_name) = 'hanks' AND LOWER(pta.email) = 'tom.hanks@movie.com'),       --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number = 301 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='endoscopic procedures') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '44 days'),						 --start_date_time, 
		((NOW()-INTERVAL '44 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus interval 3 days
		NOW()											 --last_update													 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;

--patient_visit for 36
INSERT INTO at_hospital.patient_visit(staff_id, patient_id, room_id, hospital_procedure_id, start_date_time, end_date_time, last_update)
SELECT * FROM (
VALUES ((SELECT sta.staff_id FROM at_hospital.staff sta WHERE LOWER(sta.first_name) = 'dennis' AND LOWER(sta.last_name) = 'bergkamp' AND LOWER(sta.email) = 'dennis.bergkamp@at_hospital.com'),   --staff_id
		(SELECT pta.patient_id FROM at_hospital.patient pta WHERE LOWER(pta.first_name) = 'francesco' AND LOWER(pta.last_name) = 'totti' AND LOWER(pta.email) = 'francesco.totti@football.com'),    --patient_id
	     (SELECT roo.room_id 
	      FROM at_hospital.room roo, 
	           at_hospital.room_type rotyp 
	      WHERE roo.room_type_id = rotyp.room_type_id AND 
	     	    roo.room_number= 302 AND 
	            LOWER(rotyp.room_type_name) = 'deluxe room'),  --room_id
		(SELECT hospr.hospital_procedure_id FROM at_hospital.hospital_procedure hospr WHERE LOWER(hospr.procedure_name) ='diagnosis and treatment') , 							  --hospital_procedure_id
		(NOW()-INTERVAL '49 days'),						 --start_date_time, 
		((NOW()-INTERVAL '49 days') + INTERVAL '3 day'), --end_date_time, start_date_time plus 3 days
		NOW()											 --last_update												 	 	           												              
        )) AS patient_visit_to_add ;
 COMMIT;


--2. Write a query to identify doctors with insufficient workload (less than 5 patients a month for the past few months)

SELECT DATE(DATE_TRUNC('month',patvi.start_date_time)) as month,
	   COUNT(*) as number_of_visits,
	   sta.full_name AS doctor_full_name
FROM at_hospital.staff sta,
	 at_hospital.patient_visit patvi
WHERE sta.staff_id = patvi.staff_id AND
	  patvi.start_date_time >= (DATE_TRUNC('month', NOW()) - INTERVAL '2 month')  --two months ago
GROUP BY DATE(DATE_TRUNC('month',patvi.start_date_time)),sta.staff_id
HAVING COUNT(*) < 5
ORDER BY month, number_of_visits;


--3. Please pay attention that your code must be reusable

/*
--select institution with city, country, address
SELECT cou.country_name AS country,
 	   cit.city_name AS city,
 	   ins.institution_name AS institution_name,
 	   addr.address || ' ' || addr.building  AS address
FROM at_hospital.institution ins,
 	 at_hospital.country cou,
 	 at_hospital.city cit,
 	 at_hospital.address addr
WHERE ins.city_id = cit.city_id AND
 	  cit.country_id =cou.country_id AND
 	  addr.institution_id = ins.institution_id;
 

--select patient visits, procedures, room, start,end day
SELECT pat.full_name AS patient_full_name,
	   hospr.procedure_name,
	   roo.room_number,
	   rotyp.room_type_name,
	   DATE(vis.start_date_time) as start_day,
	   DATE(vis.end_date_time) as end_day
FROM at_hospital.patient_visit vis,
	 at_hospital.patient pat,
	 at_hospital.hospital_procedure hospr,
	 at_hospital.room roo,
	 at_hospital.room_type rotyp
WHERE pat.patient_id = vis.patient_id AND
	  hospr.hospital_procedure_id = vis.hospital_procedure_id AND
	  vis.room_id = roo.room_id AND
	  rotyp.room_type_id = roo.room_type_id;
	  

--select staff position department
SELECT sta.full_name AS staff_full_name,
	   stpos.staff_position_name AS staff_position,
	   dep.department_name AS  staff_department
FROM at_hospital.staff sta,
     at_hospital.staff_position stpos,
     at_hospital.department dep
WHERE sta.staff_position_id = stpos.staff_position_id AND 
	  sta.department_id = dep.department_id;

--select head of department	 	 
SELECT sta.full_name AS head_of_department,
       dep.department_name AS department
FROM at_hospital.department_head dephe,
	 at_hospital.staff sta,
	 at_hospital.department dep
WHERE dephe.staff_id = sta.staff_id AND
 	  dephe.department_id = dep.department_id;

	 
-- select of all tables
SELECT * FROM at_hospital.patient_visit;
SELECT * FROM at_hospital.patient;
SELECT * FROM at_hospital.hospital_procedure;
SELECT * FROM at_hospital.country;
SELECT * FROM at_hospital.city;
SELECT * FROM at_hospital.institution;
SELECT * FROM at_hospital.address;
SELECT * FROM at_hospital.room_type;
SELECT * FROM at_hospital.room;
SELECT * FROM at_hospital.department;
SELECT * FROM at_hospital.staff;
SELECT * FROM at_hospital.staff_position;
SELECT * FROM at_hospital.department_head;
*/







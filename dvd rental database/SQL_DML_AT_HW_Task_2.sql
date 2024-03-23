-- Homework Assignment SQL Foundation – DML

--Task 2
-- 2.1. Create table ‘table_to_delete’ and fill it with the following query:

CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x; -- generate_series() creates 10^7 rows of sequential numbers from 1 to  10000000 (10^7);

--table created in 17,428 millisecond = 17.438 seconds


-- 2.2. Lookup how much space this table consumes with the following query

SELECT *, pg_size_pretty(total_bytes) AS total, 
pg_size_pretty(index_bytes) AS INDEX,
pg_size_pretty(toast_bytes) AS toast,
pg_size_pretty(table_bytes) AS TABLE
FROM ( SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes
FROM (SELECT c.oid,nspname AS table_schema, 
relname AS TABLE_NAME,
c.reltuples AS row_estimate,
pg_total_relation_size(c.oid) AS total_bytes,
pg_indexes_size(c.oid) AS index_bytes,
pg_total_relation_size(reltoastrelid) AS toast_bytes
FROM pg_class c
LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE relkind = 'r'
) a
) a
WHERE table_name LIKE '%table_to_delete%';

-- table_to_delete size 574 MB


-- 2.3. Issue the following DELETE operation on ‘table_to_delete’:

DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all ROWS


-- a. Note how much time it takes to perform this DELETE statement;
EXPLAIN (ANALYZE, TIMING) 
DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0; -- removes 1/3 of all ROWS

--to find seconds in millisecond need to divide the time value by 1000, 1 millisecond = 0.001 seconds  
--data deleted in 15,744 millisecond = 15.744 seconds

-- b. Lookup how much space this table consumes after previous DELETE;

--after delete operation table_to_delete space size did not change 

SELECT pg_table_size ('table_to_delete')/1024/1024 as mb;

--table_to_delete size 574 MB



-- c. Perform the following command (if you're using DBeaver, press Ctrl+Shift+O to observe server output (VACUUM results)):

VACUUM FULL VERBOSE table_to_delete; 

--VACUUM results Ctrl+Shift+O
---vacuuming "public.table_to_delete"
--"public.table_to_delete": found 0 removable, 6666667 nonremovable row versions in 73530 pages


-- d. Check space consumption of the table once again and make conclusions;

--after deleting rows in table the related space is not released to system and table size did not change
--after VACUUM FULL operation is executed release space changed to new and table size changed

SELECT pg_table_size ('table_to_delete')/1024/1024 as mb;

--table_to_delete size 382 MB

-- e. Recreate ‘table_to_delete’ table;

-- 2.4. Issue the following TRUNCATE operation:

TRUNCATE table_to_delete;

-- a. Note how much time it takes to perform this TRUNCATE statement.
 
--after execute TRUNCATE command, duration (ms) was 1030 millisecond = 1.03 seconds 

-- for check duration of TRUNCATE statement I open in DBeaver menu Window -> Show View -> Query Manager then check duration (ms) in this menu after execute TRUNCATE statement
-- also tried use Ctrl + Shift + E, but it is not work for TRUNCATE and DELETE commands, also tried EXPLAIN (ANALYZE, TIMING) TRUNCATE table_to_delete but it is not work for TRUNCATE, after decided use Query Manager and check duration (ms) there after execute statement     


-- b. Compare with previous results and make conclusion.

/*by DELETE statement we can DELETE all rows or by using a WHERE clause DELETE rows matching the criteria. 
if we made mistake we can reverting changes by ROLLBACK, or storing changes by COMMIT. 
DELETE command works slower (executed time is high) than the TRUNCATE.
after deleting rows in table the related space is not released to system and table size did not change, for release space changes need to use VACUUM FULL operation. to run VACUUM FULL command need to turn on autocommit.
*/


/*by TRUNCATE statement we can DELETE only all records. 
if we made mistake we can reverting changes by ROLLBACK, or storing changes by COMMIT.  
TRUNCATE command works faster (executed time is low) than the DELETE because TRUNCATE does not scan every row before removing it. It means that when we use TRUNCATE, it does not have to write the details of operation to the transaction log but when we use DELETE, it does write the log of the transaction which takes additional time.
after TRUNCATE reclaims disk space immediately, rather than requiring a subsequent VACUUM FULL operation.
*/
-- c. Check space consumption of the table once again and make conclusions

SELECT pg_table_size ('table_to_delete')/1024/1024 as mb;

--table_to_delete size 0 MB

-- 2.5. Hand over your investigation's results to your trainer. The results must include:

-- a. Space consumption of ‘table_to_delete’ table before and after each operation;

--2.2. cheking space table_to_delete - before - 574 MB || after - 574 MB
--2.3.b. deletion table_to_delete -    before - 574 MB || after - 574 MB 
--2.3.d. after VACUUM FULL operation - before - 574 MB || after - 382 MB 
--2.4.c. after TRUNCATE operation -    before - 574 MB || after - 0 MB


-- b. Duration of each operation (DELETE, TRUNCATE)

--DELETE execution time - 15,744 millisecond = 15.744 seconds
--TRUNCATE execution time - 1030 millisecond = 1.03 seconds
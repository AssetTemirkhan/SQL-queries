
--Creating a table for importing test data from the 'Audience data' file
CREATE TABLE audience_table (
						    date DATE,
						    user_id TEXT,
						    view_adverts INTEGER
						    );
					
COMMIT;

SELECT * 
FROM audience_table;


--1.In the 'Audience data' tab, there is information about users who visited our application in November. What is the MAU of the product?
SELECT DATE_TRUNC('month', a.date) AS month_1,
	   COUNT(DISTINCT a.user_id) AS unique_users_MAU
FROM audience_table a
GROUP BY DATE_TRUNC('month', a.date)
ORDER BY month_1;

/*
month_1                      |unique_users_mau|
-----------------------------+----------------+
2023-11-01 00:00:00.000 +0600|            7639|
*/

--2.Using the 'Audience data' tab, calculate what the DAU (Daily Active Users) will be
SELECT AVG(unique_users) AS dau
FROM (SELECT DATE_TRUNC('day', a.date) AS day_1,
	   		  COUNT(DISTINCT a.user_id) AS unique_users
	  FROM audience_table a
	  GROUP BY DATE_TRUNC('day', a.date)
      ORDER BY day_1) day_unique_users;
     
/*
dau                 |
--------------------+
560.4666666666666667|
*/
     
--3.Using the 'Audience data' tab, calculate the retention rate for the first day among users who joined the product on November 1st
SELECT count(a.user_id) AS nov_1_users  --Users who joined the product on November 1st
FROM audience_table a
WHERE a.date = '2023-11-01'
GROUP BY a.date;

/*
 nov_1_users|
-----------+
        623|
 */


SELECT count(a2.user_id) AS nov_2_users  --Users who joined the product on November 2nd
FROM audience_table a2
WHERE a2.user_id  IN (SELECT a.user_id AS nov_1_users
					  FROM audience_table a
					  WHERE a.date = '2023-11-01')  -- Users who joined the product on November 1st
AND a2.date = '2023-11-02';

/*
nov_2_users|
-----------+
        166|
 */


SELECT nov_2_users,  								   -- Users who joined the product on November 2nd
       nov_1_users,  								   -- Users who joined the product on November 1st
       (nov_2_users * 1.0) / nov_1_users AS retention  -- Retention of users who joined the product on November 1st
FROM 
    (SELECT COUNT(a.user_id) AS nov_1_users
     FROM audience_table a
     WHERE date = '2023-11-01') AS a1,          	   -- Users who joined the product on November 1st
    (SELECT COUNT(a2.user_id) AS nov_2_users           -- Users who joined the product on November 2nd
     FROM audience_table a2
     WHERE a2.user_id  IN (SELECT a.user_id AS nov_1_users
						   FROM audience_table a
						   WHERE a.date = '2023-11-01')
	 AND a2.date = '2023-11-02') AS a2;

/*
 nov_2_users|nov_1_users|retention            |
-----------+-----------+----------------------+
        166|        623|0.26645264847512038523|
 */	
	
	
--4. In the 'Audience data' tab, there is information about how many advertisements each user viewed (view_adverts). Calculate the user conversion rate for viewing advertisements in November? (in users)

--Calculation of user conversion 	
--SELECT (unique_ad_view_user * 1.0) / unique_user AS conversation_rate
SELECT ROUND(((unique_ad_view_user * 1.0) / unique_user) * 100, 1) AS conversation_rate
FROM (SELECT COUNT(DISTINCT (a.user_id)) AS unique_user --Number of unique users
     FROM audience_table a) AS a1,
     
     (SELECT COUNT(DISTINCT (a2.user_id)) AS unique_ad_view_user
      FROM audience_table a2
      WHERE a2.view_adverts >= 1   -- Users who viewed at least one advertisement
      ) AS a2
/*
conversation_rate|
-----------------+
             46.3|
 */
      
      
--5. Using the information from the 'Audience data' tab, calculate the average number of advertisements viewed per user in November
--SELECT (total_ad_views * 1.0) / unique_user AS ad_per_user
SELECT ROUND(((total_ad_views * 1.0) / unique_user),1) AS ad_per_user
FROM (SELECT COUNT(DISTINCT (a.user_id)) AS unique_user --Number of unique users
     FROM audience_table a) AS a1,
     
     (SELECT SUM(a2.view_adverts) AS total_ad_views  --Total number of advertisements viewed
      FROM audience_table a2
      ) AS a2
/*
ad_per_user|
-----------+
        2.9|
 */
      
/*
6. We conducted a survey among 2000 users. Among them, 500 are 'detractors', 1200 are 'promoters', and 300 are 'passives'. Calculate what NPS will be.

In the given scenario:

Total Users: 2000
Detractors (Critics): 500
Promoters (Supporters): 1200
Passives (Neutral): 300

To calculate the Net Promoter Score (NPS), need to subtract the percentage of detractors from the percentage of promoters.

NPS = Percentage of Promoters - Percentage of Detractors

First, calculate the percentages:

Percentage of Promoters = (Number of Promoters / Total Users) * 100
Percentage of Detractors = (Number of Detractors / Total Users) * 100

Percentage of Promoters = (1200 / 2000) * 100 = 60%
Percentage of Detractors = (500 / 2000) * 100 = 25%

Now, subtract the percentage of detractors from the percentage of promoters:

NPS = 60% - 25% = 35%

So, the Net Promoter Score (NPS) is 35%.

*/

      
--7. Based on the data in the 'Audience data' tab, write an SQL query that outputs the total number of unique users in this table for the period from 2023-11-07 to 2023-11-15
SELECT COUNT(DISTINCT a.user_id) AS unique_users
FROM audience_table a
WHERE a.date BETWEEN '2023-11-07' AND '2023-11-15';

/*
unique_users|
------------+
        3199|
 */

--8. Determine the user who viewed the highest number of advertisements throughout the entire period
SELECT a.user_id, SUM(a.view_adverts) AS total_views
FROM audience_table a
GROUP BY a.user_id
ORDER BY total_views DESC
LIMIT 1;

/*
user_id                             |total_views|
------------------------------------+-----------+
3c2d27c0-4fd6-11eb-b89f-2ffb31b67dd6|        354|
 */

--9. Determine the day with the highest average number of advertisements viewed per user, considering only days with more than 500 unique users
SELECT date, 
       AVG(view_adverts) AS avg_adv_per_user
FROM audience_table a_avg
WHERE a_avg.date IN (SELECT a.date --Days with more than 500 unique users
					 FROM audience_table a
					 GROUP BY a.date
					 HAVING COUNT(DISTINCT a.user_id) > 500
					)
GROUP BY a_avg.date
ORDER BY avg_adv_per_user DESC 
LIMIT 1;

/*
date      |avg_adv_per_user  |
----------+------------------+
2023-11-21|1.4823348694316436|
 */

--10.Write a query returning the LT (length of time a user spends on the site) for each user. Sort the LT in descending order
SELECT a.user_id,
	   MIN(a.date) AS first_date, --user first date
	   MAX(a.date) AS last_date,  --user last date
	   MAX(a.date) - MIN(a.date)  AS user_lt --user LT (The duration of a user's presence on the site)
FROM audience_table a
GROUP BY user_id
ORDER BY user_lt DESC;

/*
user_id                             |first_date|last_date |user_lt|
------------------------------------+----------+----------+-------+
f7c16bf0-448d-11ee-9152-5d2cf8d23c8d|2023-11-01|2023-11-30|     29|
28234cd0-52be-11ee-8438-dfcf34dc079c|2023-11-01|2023-11-30|     29|
cbb2af70-a51a-11eb-bc9a-9b8287359b8f|2023-11-01|2023-11-30|     29|
fb0db6c0-eed8-11ed-b021-df7a31580d1c|2023-11-01|2023-11-30|     29|
c44efdd0-2bdd-11eb-a6a8-374e84e5cb57|2023-11-01|2023-11-30|     29|
...
 */

--11.For each user, calculate the average number of advertisements viewed per day, and then find out who has the highest average among those who were active on at least 5 different days
WITH user_activity AS (--who was active on at least 5 different days
					   SELECT a.user_id,
					          COUNT(DISTINCT a.date) AS active_days,
					          SUM(a.view_adverts) AS total_adv
					   FROM audience_table a
					   GROUP BY a.user_id
					   HAVING COUNT(DISTINCT a.date) >=5
					   )
SELECT ua.user_id,
       ua.total_adv/ua.active_days AS avg_adv_per_day   --The average number of advertisements viewed per day
FROM user_activity ua
ORDER BY avg_adv_per_day DESC
LIMIT 1;

/*
user_id                             |avg_adv_per_day|
------------------------------------+---------------+
11f58880-8453-11ee-afb3-7bd5493ebb29|             37|
 */


--Mathematics/Statistics

--Creating a table for importing test data 'Listers' from the file 'Data for Entrance Tasks
CREATE TABLE listers (
						user_id INTEGER,
						date DATE,
						cnt_adverts INTEGER,
						age INTEGER,
						cnt_contacts INTEGER,
						revenue INTEGER
					);
COMMIT;



SELECT *
FROM listers;


--12. Calculate the average income per user based on the dataset with listers.

SELECT AVG(total_sum)
FROM (SELECT l.user_id,
	   SUM(l.revenue) AS total_sum
	   FROM listers l
	   GROUP BY l.user_id) AS l1;

/*
avg                 |
--------------------+
156.4838709677419355|
 */
	  
--13.Calculate the median age of users based on the dataset with listers    
/*
Algorithm for calculating the median:
1.Arrange the elements in the list in ascending order.
2.Count the number of elements in the list.
3.Number the elements in the list.
3.1. If the number of elements in the list is odd, find the number in the middle.
3.2. If the number of elements is even, find the two numbers in the middle, add them together, and divide the result by two.
*/


	  
WITH sorted_data AS (   -- 1. Arrange the elements in the list in ascending order
  SELECT l.age
  FROM listers l
  ORDER BY l.age
),
count_data AS (         --2. Count the number of elements in the list
  SELECT COUNT(*) AS total_count
  FROM sorted_data
),
median_values AS (      --3. Number the elements in the list
  SELECT 
    age,
    ROW_NUMBER() OVER (ORDER BY age) AS row_num,
    (SELECT total_count FROM count_data) AS total_count
  FROM sorted_data
)

SELECT 
age, 
row_num, 
total_count,
 CASE
    WHEN total_count % 2 <> 0 THEN (SELECT age FROM median_values WHERE row_num = CEIL(total_count / 2.0))  --3.1. If the number of elements in the list is odd, find the number in the middle
    ELSE ((SELECT age FROM median_values WHERE row_num = total_count / 2) +
          (SELECT age FROM median_values WHERE row_num = total_count / 2 + 1)) / 2.0      					--3.2. If the number of elements is even, find the two numbers in the middle, add them together, and divide the result by two
  END AS median
  
FROM median_values
WHERE 
  CASE
    WHEN total_count % 2 <> 0 THEN row_num = CEIL(total_count / 2.0)  --The CEIL function rounds a number up to the nearest integer. For example, the CEIL(79.5) function will return the value 80
    ELSE row_num IN (total_count / 2, total_count / 2 + 1)
  END;

/*
age|row_num|total_count|median             |
---+-------+-----------+-------------------+
 28|     79|        158|28.0000000000000000|
 28|     80|        158|28.0000000000000000|
 */
 
--13.2. The 0.5 percentile is equal to the median
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY l.age) AS median_age
FROM listers l;

/*
median_age|
----------+
      28.0|
 */

--14.Based on the data provided in the listers, calculate the Pearson correlation coefficient between the following variables: age and cnt_contacts - to understand if there is a relationship between the age of the user and the number of contacts.

SELECT CORR(age::numeric, cnt_contacts::numeric) AS correlation_coefficient
FROM listers;

/*
correlation_coefficient|
-----------------------+
   -0.07010295473330305|
*/
/*The Pearson correlation coefficient between the variables 'age' and 'cnt_contacts', calculated from the provided data, is approximately -0.070. 
This value is close to zero, indicating a very weak negative correlation between the user's age and the number of contacts. 
In other words, there is no clear linear relationship between these two variables based on the provided data.
*/

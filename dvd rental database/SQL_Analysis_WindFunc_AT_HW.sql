--SQL for Analysis – Windows Functions

/* Task 1
Build the query to generate a report about the most significant customers (which have maximum sales) through various sales channels.
The 5 largest customers are required for each channel.
Column sales_percentage shows percentage of customer’s sales within channel sales 
*/


SELECT 
       sal_channel.channel_desc,
       sal_channel.cust_last_name,
       sal_channel.cust_first_name,
       sal_channel.amount_sold,
       sal_channel.sales_percentage
FROM (
	SELECT cha.channel_desc,
	       cus.cust_last_name,
	       cus.cust_first_name, 
		   SUM(sal.amount_sold) amount_sold,
		   TRIM(LEADING '0' FROM CAST(ROUND(SUM(sal.amount_sold) / SUM (SUM(sal.amount_sold)) OVER (PARTITION BY sal.channel_id)*100, 5) AS TEXT)) ||' %' as sales_percentage,    	--calculate sales percentage by sum total amount for amount_sold devided to channel_sales, multiplied to 100 for find percentage, use round to display 5 digits after 0, used trip to make formatting like in example 
		   ROW_NUMBER() OVER (PARTITION BY sal.channel_id ORDER BY SUM(sal.amount_sold) DESC) as row_num					  		    											--use row_number to assign number to each row of total sum amount of customer by channel
	FROM sh.sales sal,
		 sh.channels cha,
		 sh.customers cus
	WHERE cha.channel_id = sal.channel_id AND 
		  cus.cust_id = sal.cust_id 
	GROUP BY sal.channel_id, sal.cust_id, cha.channel_id, cus.cust_id ) AS sal_channel
WHERE sal_channel.row_num <= 5   --select the first 5 largest amount 	 
ORDER BY sal_channel.amount_sold DESC; 



/* Task 2
Compose query to retrieve data for report with sales totals for all products in Photo category in Asia (use data for 2000 year). Calculate report total (YEAR_SUM).
*/

SELECT prod.prod_name AS product_name,
	   SUM(CASE WHEN tim.calendar_quarter_number = 1 THEN sal.amount_sold ELSE 0 END) AS q1,    	    --total sum of sales amount_sold for specific quarter_number 
	   SUM(CASE WHEN tim.calendar_quarter_number = 2 THEN sal.amount_sold ELSE 0 END) AS q2,
	   SUM(CASE WHEN tim.calendar_quarter_number = 3 THEN sal.amount_sold ELSE 0 END) AS q3,
	   SUM(CASE WHEN tim.calendar_quarter_number = 4 THEN sal.amount_sold ELSE 0 END) AS q4,
	   SUM(sal.amount_sold) AS year_sum 																--total sum of sales amount_sold for selected year 
FROM sh.sales sal,
 	 sh.products prod,
	 sh.times tim,
	 sh.customers cus,
	 sh.countries cou
WHERE sal.prod_id = prod.prod_id AND
	  sal.time_id = tim.time_id AND 
	  sal.cust_id = cus.cust_id AND
	  cus.country_id = cou.country_id AND
	  LOWER(prod.prod_category) = LOWER ('Photo') AND   			--select Photo category 
	  LOWER(cou.country_region) = LOWER('Asia') AND					--select Asia country region
	  EXTRACT (YEAR FROM sal.time_id) = 2000            			--select year
GROUP BY prod.prod_id
ORDER BY prod.prod_name;



/* Task 3
Build the query to generate a report about customers who were included into TOP 300 (based on the amount of sales) in 1998, 1999 and 2001. This 
report should separate clients by sales channels, and, at the same time, channels should be calculated independently (i.e. only purchases made on 
selected channel are relevant
*/

SELECT ranked_sales.channel_desc,       				--select customers amount_sold by separate channels	
	   ranked_sales.cust_id,
	   ranked_sales.cust_last_name,
	   ranked_sales.cust_first_name, 
	   SUM(ranked_sales.amount_sold) AS amount_sold 	--sum amount_sold
FROM (
	SELECT cha.channel_id, 
		   cha.channel_desc,
		   cus.cust_id,
		   cus.cust_last_name,
		   cus.cust_first_name,
		   SUM(sal.amount_sold) AS amount_sold,
		   RANK() OVER (PARTITION BY sal.channel_id, EXTRACT(YEAR FROM sal.time_id) ORDER BY SUM(sal.amount_sold) DESC) AS sales_rank  --rank sales by total amount in year by channel
	FROM sh.sales sal,
		 sh.channels cha, 
		 sh.customers cus 
	WHERE sal.channel_id = cha.channel_id AND
		  sal.cust_id = cus.cust_id AND 
		  EXTRACT (YEAR FROM sal.time_id) IN (1998, 1999, 2001) 							 --select sales for years
	GROUP BY sal.channel_id, EXTRACT(YEAR FROM sal.time_id), cha.channel_id, cha.channel_desc, cus.cust_id, cus.cust_first_name, cus.cust_last_name 
	) AS ranked_sales
WHERE ranked_sales.sales_rank <= 300  								--select TOP 300 customers by amount of sales in 1998,1999,2001
GROUP BY ranked_sales.channel_id, ranked_sales.channel_desc, ranked_sales.cust_id, ranked_sales.cust_first_name, ranked_sales.cust_last_name
HAVING COUNT(ranked_sales.cust_id) = 3  								-- count cust_id to find customers who were in top 300 3 times (in 1998, 1999, 2001)  
ORDER BY amount_sold DESC, ranked_sales.cust_id ASC;   



/* Task 4
Build the query to generate the report about sales in America and Europe:
Conditions:
• TIMES.CALENDAR_MONTH_DESC: 2000-01, 2000-02, 2000-03
• COUNTRIES.COUNTRY_REGION: Europe, Americas.
*/

 
SELECT tim.calendar_month_desc,
	   prod.prod_category,
	   ROUND (SUM(CASE WHEN LOWER(cou.country_region) = LOWER('Americas') THEN sal.amount_sold ELSE 0 END)) AS "Americas SALES",  --used case to calculate data for specific country region, use round for round data like in example 
	   ROUND (SUM(CASE WHEN LOWER(cou.country_region) = LOWER('Europe') THEN sal.amount_sold ELSE 0 END)) AS "Europe SALES"
FROM sh.times tim,
	 sh.products prod,
	 sh.sales sal,
	 sh.customers cus,
	 sh.countries cou
WHERE 
	 tim.time_id = sal.time_id AND
	 prod.prod_id = sal.prod_id AND
	 sal.cust_id = cus.cust_id AND
	 cus.country_id = cou.country_id AND
	 tim.calendar_month_desc IN ('2000-01', '2000-02', '2000-03') AND         --select calendar_month_desc period
	 LOWER(cou.country_region) IN (LOWER('Europe'), LOWER('Americas'))		  --select specific country_region
GROUP BY tim.calendar_month_id,  tim.calendar_month_desc, prod.prod_category_id, prod.prod_category 
ORDER BY tim.calendar_month_desc ASC, prod.prod_category ASC;


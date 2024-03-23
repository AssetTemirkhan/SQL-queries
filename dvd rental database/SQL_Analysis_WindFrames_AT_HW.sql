
--Homework Assignment
--SQL for Analysis – Window Frames


/* TASK 1
 Analyze annual sales by channels and regions. Build the query to generate the same report:
Conditions:
• country_region: 'Americas', 'Asia', 'Europe'
• calendar_year: 1999, 2000, 2001
• ordering: country_region ASC, calendar_year
ASC, channel_desc ASC
Columns description:
AMOUNT_SOLD – amount sales for channel
% BY CHANNELS – percentage of sales for the 
channel (e.g. 100% - total sales for Americas in 
1999, 63.64% - percentage of sales for the channel 
“Direct Sales”)
% PREVIOUS PERIOD – the same value as in the % 
BY CHANNELS column, but for the previous year
% DIFF – difference between % BY CHANNELS and 
% PREVIOUS PERIOD

 */


WITH sales_by_region_year AS (  --first CTE calculate amount by country region, channel and year 
SELECT cou.country_region,
	   tim.calendar_year,
       cha.channel_desc,
       SUM(sal.amount_sold) AS amount_sold,
       ROUND((SUM(sal.amount_sold) / SUM(SUM(sal.amount_sold)) OVER (PARTITION BY cou.country_region, tim.calendar_year ORDER BY tim.calendar_year  
								   	     				             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) * 100), 2) AS by_channels        --calculate percentage of sales by channel in year over all rows in partition, using partition by country_region, calendar_year sorts the data by calendar_year, calculate amount of sale by channel devided to total amount of sales by year, multiplied to 100 to find percent, used round to have 2 digits after amount       
								   	 
FROM sh.sales sal,
	 sh.customers cus,
	 sh.countries cou,
	 sh.times tim,
	 sh.channels cha
WHERE sal.cust_id = cus.cust_id AND
	  cus.country_id = cou.country_id AND
	  sal.time_id = tim.time_id AND
	  sal.channel_id = cha.channel_id AND
	  cou.country_region IN ('Americas', 'Asia', 'Europe') AND     --select country regions
	  tim.calendar_year IN (1998, 1999, 2000, 2001)				   --select calendar year,(select 1998 year to calculate previous data for 1999)
GROUP BY cou.country_region_id, cou.country_region, tim.calendar_year_id,  tim.calendar_year, cha.channel_id,  cha.channel_desc),
								
						
prev_year_sales AS ( --second CTE calculate amount of previous_period and find difference between by_channels and previous_period 
SELECT country_region, 
	   calendar_year,
	   channel_desc, 
	   amount_sold,
	   by_channels, 
	   ROUND ((FIRST_VALUE (by_channels) OVER (PARTITION BY country_region, channel_desc ORDER BY calendar_year  
	   	     				        		   ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)), 2) AS previous_period,   				--used first value to obtain the value for the first row within each partition, used window frame to define the current row and previous row based on the order of calendar_year column, used round to have 2 digits after amount
	   by_channels - ROUND ((FIRST_VALUE (by_channels) OVER (PARTITION BY country_region, channel_desc ORDER BY calendar_year  
	   	     				        		                 ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)), 2) AS diff                 --find difference by minus between by_channels and previous_period 
FROM sales_by_region_year)

--select for final result set
SELECT country_region,          
	   calendar_year,
	   channel_desc,
	   TO_CHAR(amount_sold, 'FM999,999,999') || ' $' AS amount_sold, 	--used to_char to make result as in example with $ value to result
	   by_channels || ' %'::TEXT AS "% BY CHANNELS",  					--convert to text to add % value to result
	   previous_period || ' %'::TEXT AS "% PREVIOUS PERIOD",
	   diff ||' %'::TEXT AS "% DIFF"  
FROM prev_year_sales
WHERE calendar_year IN (1999, 2000, 2001)                       		--select calendar year for get final result 
ORDER BY country_region ASC, calendar_year ASC, channel_desc ASC;




/*
TASK 2
Build the query to generate a sales report for the 49th, 50th and 51st weeks of 1999. Add column CUM_SUM for accumulated amounts within 
weeks. For each day, display the average sales for the previous, current and next days (centered moving average, CENTERED_3_DAY_AVG column). 
For Monday, calculate average weekend sales + Monday + Tuesday. For Friday, calculate the average sales for Thursday + Friday + weekends
*/



SELECT calendar_week_number,
	   time_id,
	   day_name,
	   ROUND (sales,2)::TEXT AS sales,        					--convert to text to make result as in example
	   ROUND(cum_sum,2)::TEXT AS cum_sum,
	   ROUND(centered_3_day_avg,2)::TEXT AS centered_3_day_avg
	   
FROM 
	(SELECT 
	tim.calendar_week_number,
	tim.time_id,
	tim.day_name,
	SUM(sal.amount_sold) AS sales,
	SUM(SUM(sal.amount_sold)) OVER (PARTITION BY tim.calendar_week_number ORDER BY tim.time_id		  --used partition by calendar_week_number to calculate accumulate sum for each value in this column in order of time_id
		   						  	RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum,    --used range to define the window to accumulate sum that should be calculate, it is include all rows from start of the partition up to and current row
	CASE WHEN LOWER(tim.day_name) = LOWER ('Monday') THEN AVG(SUM(sal.amount_sold)) OVER (ORDER BY tim.time_id  													 --used case to calculate average amount for Monday, Friday and other days 
																				    	  RANGE BETWEEN INTERVAL '2' DAY PRECEDING AND INTERVAL '1' DAY FOLLOWING)   --used range to calculate average for weekend sales + Monday + Tuesday
		 WHEN LOWER(tim.day_name) = LOWER ('Friday') THEN AVG(SUM(sal.amount_sold)) OVER (ORDER BY tim.time_id  													 --calculate average amount for Friday 
																				    	  RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND INTERVAL '2' DAY FOLLOWING)	 --used range to calculate average for Thursday + Friday + weekends
		 ELSE AVG(SUM(sal.amount_sold)) OVER (ORDER BY tim.time_id 																									 --calculate average amount for other days 
										   	  RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND INTERVAL '1' DAY FOLLOWING)												 --calculate the average sales for the previous, current and next days
	END AS centered_3_day_avg 
	FROM 
	    sh.sales sal,
	    sh.times tim 
	WHERE sal.time_id = tim.time_id AND
	tim.calendar_week_number IN (48,49,50,51,52) AND --select sales for the 48, 49, 50, 51, 52 weeks, (select 48, 52 weeks to calculate data for 49 and 51 weeks) 
	tim.calendar_year IN (1999)                      --select year
	GROUP BY tim.calendar_week_number, tim.time_id, tim.day_name) AS sales_by_days
WHERE calendar_week_number IN (49,50,51)             --select sales for the 49, 50 and 51 for final result set
ORDER BY time_id ASC, calendar_week_number ASC;



/*
TASK 3
Prepare 3 examples of using window functions with a frame clause (RANGE, ROWS, and GROUPS modes)
Explain why you used a particular type of frame in each example. It can be one query or 3 separate queries
*/

--finding sales amount of total sales for poduct categories photo and electronics for 1999, 2000, 2001 years using ROWS, RANGE, and GROUPS modes

SELECT prod.prod_category,
	   tim.calendar_year,
 	   SUM(sal.amount_sold) AS total_sales,
 	   SUM(SUM(sal.amount_sold)) OVER (PARTITION BY prod.prod_category ORDER BY tim.calendar_year    							   	 --used partition to calculate sales amount of each prod category order by year
	   							  	   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sales_rows, 					   	 --used rows to calculate cumulative sales amount of each product category by year including all rows from start of partition up to and including current row
	   
 	   LAST_VALUE(SUM(sal.amount_sold)) OVER (PARTITION BY prod.prod_category ORDER BY tim.calendar_year  						  	 --used partition to calculate sales of each prod category order by year
 	   										  RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_year_sales_range,	 --in range include all rows in patition, used LAST_VALUE to have last value row of amount sold sales
       
 	   SUM(SUM(sal.amount_sold)) OVER (PARTITION BY prod.prod_category ORDER BY tim.calendar_year 								  	 --used partition to calculate sales of each prod category order by year
 	   								   GROUPS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS total_sales_group			   	 --used group include all rows in patition to calculate the total sales for each category by year 

FROM sh.sales sal,
	 sh.products prod,
	 sh.times tim
WHERE sal.prod_id = prod.prod_id AND
	  sal.time_id = tim.time_id AND
	  LOWER(prod.prod_category) IN (LOWER('Photo'), LOWER('Electronics')) AND   					--select poduct categories
	  tim.calendar_year IN (1999, 2000, 2001) 														--select year
GROUP BY prod.prod_category, prod.prod_category_id, tim.calendar_year, tim.calendar_year_id
ORDER BY prod.prod_category,  tim.calendar_year;

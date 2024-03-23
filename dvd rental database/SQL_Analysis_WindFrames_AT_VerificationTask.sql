/*
Verification Task
SQL for Analysis – Windows Frames

TASK
Build the query to generate sales report for 1999 and 2000 in the context of quarters and product categories. In the report you should analyze the sales of 
products from the categories 'Electronics', 'Hardware' and 'Software/Other', through the channels 'Partners' and 'Internet':
CALENDAR_YEAR – calendar year
CALENDAR_QUARTER_DESC – quarter
PROD_CATEGORY – product category
SALES$ - sum of sales (amount_sold) for product 
category and quarter
DIFF_PERCENT - the column contains information 
about how much a percentage of sales 
increased/decreased to the first quarter of the year. 
For the first quarter the column value is ‘N/A’
CUM_SUM$ - the cumulative sum of sales by 
quarters

*/

SELECT calendar_year,
       calendar_quarter_desc,
       prod_category,
       total_sales_amount AS sales$,
	   CASE  																								   								--used case to find difference with the first quarter of the year with each quarter
		   WHEN  total_sales_amount/first_quarter_amount = 1 THEN 'N/A'::TEXT                                         						--compare total sales amount with first quarter if result 1 then in result set will be 'N/A' 
	   	   ELSE ROUND(((total_sales_amount/first_quarter_amount)* 100) - ((total_sales_amount/total_sales_amount)* 100), 2) || '%'::TEXT  	--devided each quarter amount with the first quarter amount of the year and multiplied to 100 to find difference in percent between quarters, then result minus with current quarter total sales amount data to find difference between two data, used round to have 2 digits after 0, and use concatination with '%' to have result as in example  
	   END AS diff_percent,
       SUM(total_sales_amount) OVER (PARTITION BY calendar_year ORDER BY calendar_quarter_desc 
       						  	     RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sum$  					 					--sum total amount of sales by calendar year and calendar_quarter_desc

FROM (       
	SELECT tim.calendar_year,
		   tim.calendar_quarter_desc,
		   prod.prod_category,
		   SUM(sal.amount_sold) AS total_sales_amount,
		   FIRST_VALUE (SUM(sal.amount_sold)) OVER (PARTITION BY calendar_year, prod_category ORDER BY calendar_quarter_desc
       								  				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS first_quarter_amount      --used FIRST_VALUE to have first value of calendar_quarter_desc of each year
	FROM sh.sales sal,
	     sh.times tim,
	     sh.products prod,
	     sh.channels cha     
	WHERE sal.time_id = tim.time_id AND
		  sal.prod_id = prod.prod_id AND
		  sal.channel_id = cha.channel_id AND
		  LOWER(prod.prod_category) IN (LOWER('Electronics'), LOWER('Hardware'),LOWER('Software/Other')) AND     --select products categories
		  LOWER(cha.channel_desc) IN (LOWER('Partners'), LOWER('Internet')) AND                                  --select channels
		  tim.calendar_year IN (1999, 2000)                                                                      --select year 
	GROUP BY tim.calendar_year_id, tim.calendar_year, tim.calendar_quarter_desc, tim.calendar_quarter_id, prod.prod_category, prod.prod_category_id
		) AS prod_sales_by_quarter
ORDER BY calendar_quarter_desc ASC, total_sales_amount DESC;
	
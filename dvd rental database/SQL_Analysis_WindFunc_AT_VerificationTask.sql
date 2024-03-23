/*
Verification Task
SQL for Analysis – Windows FUNCTIONS
*/


/* Task 1
Build the query to generate a report about regions with the maximum number of products sold (quantity_sold) for each channel for the entire
period.
CHANNEL_DESC – channel
COUNTRY_REGION – region with maximum number of products sold
SALES – number of products sold (quantity_sold)
SALES % - percentage of maximum sales in this region (SALES column) of total sales per channel
*/
 
	    
SELECT rank_sales.channel_desc,
	   rank_sales.country_region,
	   ROUND(rank_sales.sales,2)::TEXT AS sales,						
 	   rank_sales.sales_percentage::TEXT || '%' "SALES %"
FROM (
	SELECT cha.channel_desc, 
		   cou.country_region,	  
		   COUNT(sal.quantity_sold)  AS sales,             																						--count number of products quantity_sold
		   RANK() OVER (PARTITION BY sal.channel_id ORDER BY COUNT(sal.quantity_sold) DESC) AS sales_rank, 										--rank number of quantity_sold by channel in descending order
		   ROUND ((COUNT(sal.quantity_sold)/SUM(COUNT(sal.quantity_sold)) OVER (PARTITION BY sal.channel_id)*100),2) AS sales_percentage  		--calculate percentage of maximum sales in region with total sales per channel
	FROM sh.sales sal,
		 sh.customers cus,
		 sh.countries cou,
		 sh.channels cha
	WHERE 
		 sal.cust_id = cus.cust_id AND
		 cus.country_id = cou.country_id AND
		 sal.channel_id =cha.channel_id 
	GROUP BY cha.channel_id, cha.channel_desc, cou.country_region_id, cou.country_region, sal.channel_id 
	) AS rank_sales
WHERE sales_rank = 1    		--select regions with maximum number of products sold
ORDER BY rank_sales.sales DESC;


/* Task 2
2. Define subcategories of products (prod_subcategory) for which sales for 1998-2001 have always been higher (sum(amount_sold)) compared to
the previous year. The final dataset must include only one column (prod_subcategory).
*/


SELECT prod_subcategory_sales.prod_subcategory
FROM (
	SELECT prod.prod_subcategory,
		   EXTRACT(year FROM sal.time_id) AS YEAR,   					--extract year from sales time_id to compare data for each year
		   SUM(sal.amount_sold) AS sales_amount,
		   LAG(SUM(sal.amount_sold),1,0) OVER (PARTITION BY prod.prod_subcategory ORDER BY EXTRACT(year FROM sal.time_id)) AS prev_year_sales_amount,  		--use LAG function to compare data with previos year, LAG(SUM(sal.amount_sold),1,0) used 1 - to offset 1 year, 0 - to make 0 by default if there is no data for previos year(1998) 
		   CASE 
			   WHEN SUM(sal.amount_sold) >= LAG(SUM(sal.amount_sold),1) OVER (PARTITION BY prod.prod_subcategory ORDER BY EXTRACT(year FROM sal.time_id))   --LAG(SUM(sal.amount_sold),1,0) used 1 - to offset 1 year, use NULL as default to not calculate data for 1998 year, because there is no data for previous year for 1998
			   THEN 1 
			   ELSE 0 
		   END AS is_higher       										--use case to compare data with previous year 1 - sales is higher than in previous year, 0 - sales is not higher than in previous year
	FROM sh.sales sal,
	 	 sh.products prod
	WHERE sal.prod_id = prod.prod_id AND
		  EXTRACT(year FROM sal.time_id) BETWEEN 1998 AND 2001 			--select data for 1998-2001
	GROUP BY prod.prod_subcategory, EXTRACT(year FROM sal.time_id)  	--used group by prod_subcategory because there are different prod_subcategory_id for some prod_subcategory (like Accessories)
) AS prod_subcategory_sales
GROUP BY prod_subcategory_sales.prod_subcategory
HAVING SUM(prod_subcategory_sales.is_higher) >= 3; 					 	--sum is_higher, if sum is equal to 3 it is mean that sales for current year have always been higher than previous year

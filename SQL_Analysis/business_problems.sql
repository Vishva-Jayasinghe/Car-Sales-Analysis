DROP TABLE IF EXISTS car_data;
CREATE TABLE car_data (
car_id	VARCHAR(50),
order_date DATE,
customer_name VARCHAR(60),
gender VARCHAR(10),
annual_income FLOAT,
dealer_name VARCHAR(50),
company VARCHAR(20),
model VARCHAR(50),
engine VARCHAR(50),
transmission VARCHAR(50),
color VARCHAR(20),
price  FLOAT,
dealer_no VARCHAR(30),
body_style VARCHAR(20),
phone VARCHAR(20),
dealer_region VARCHAR(50)
);

SELECT * FROM car_data
-- year vise sales
SELECT 
	   EXTRACT(YEAR FROM order_date) AS year,
	   company AS company,
	   SUM(price) AS total_sales
FROM car_data
GROUP BY 1,2
ORDER BY 1;

--  Monthly sales
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   EXTRACT(MONTH FROM order_date) AS month,
	   company AS company,
	   SUM(price) AS total_sales
FROM car_data
GROUP BY 1,2,3
ORDER BY 1,2;

 
-- show the best month of each year each company
SELECT company,
	   total_sales,
	   year,
	   month
FROM (
SELECT 
    company,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(price) AS total_sales,
    
    DENSE_RANK() OVER (
        PARTITION BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
        ORDER BY SUM(price) DESC
    ) AS rank_in_month

FROM car_data
GROUP BY company, year, month
ORDER BY year, month
)t
WHERE rank_in_month =1;

--. Top 3 Companies Per Month
SELECT company,
	   year,
	   month,
	   sales,
	   rank
FROM(
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   EXTRACT(MONTH FROM order_date) AS month,
	   company AS company,
	   SUM(price) AS sales,
	   DENSE_RANK() OVER(PARTITION BY EXTRACT(YEAR FROM order_date),EXTRACT(MONTH FROM order_date )ORDER BY SUM(price) DESC) AS rank
FROM car_data
GROUP BY 1,2,3
)t
WHERE rank <=3;

--Running Total Sales by Company
SELECT company,
	   year,
	   month,
	   sales,
	    SUM(sales) OVER (
        PARTITION BY company, year
        ORDER BY year, month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM (

SELECT 
    company,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(price) AS sales
FROM car_data
GROUP BY company, year, month
ORDER BY company, year, month
)t
ORDER BY company,year,month


--Rank customers based on total spending.
SELECT DISTINCT(customer_name) AS customer,
	   SUM(price) AS sales,
	   DENSE_RANK() OVER(ORDER BY SUM(price) DESC) AS rank
FROM car_data
GROUP BY 1
ORDER BY 3 ASC;

--Find customers who purchased more than once and their order count and rank the top 10
SELECT * FROM (
SELECT DISTINCT(customer_name) AS customer,
	   COUNT(DISTINCT car_id) AS No_of_cars,
	   DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT car_id) DESC) AS rank
FROM car_data
GROUP BY 1
HAVING COUNT(DISTINCT car_id) > 1
ORDER BY 3 DESC)
WHERE rank <=10

--Find the top-selling car model in each dealer region in each  year.
SELECT year,
	   reigon, 
	   model,
	   no_of_cars
FROM (
SELECT DISTINCT(dealer_region) AS reigon,
	   EXTRACT(YEAR FROM order_date) AS year,
	   model,
	   COUNT(car_id) AS no_of_cars,
	   DENSE_RANK() OVER(PARTITION BY dealer_region,EXTRACT(YEAR FROM order_date) ORDER BY COUNT(car_id) DESC ) AS rank
FROM car_data
GROUP BY 1,2,3
)t
WHERE rank=1
ORDER BY 1,2


--Rank dealers based on total revenue within each region in each year, month
SELECT year,
	   month,
	   region,
	   dealer,
	   sales
	   
FROM(
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   EXTRACT(MONTH FROM order_date) AS month,
	   dealer_region AS region,
	   dealer_name AS dealer,
	   SUM(price) AS sales,
	   DENSE_RANK() OVER(PARTITION BY EXTRACT(YEAR FROM order_date),EXTRACT(MONTH FROM order_date) ORDER BY SUM(price) DESC) AS rank
FROM car_data
GROUP BY 1,2,3,4
ORDER BY 1,2,3
)t
WHERE rank = 1

--Show each car sale and how much its price differs from company average price
WITH company_details AS (
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   company AS company,
	   SUM(price) AS current_sales
FROM car_data
GROUP BY 1,2
ORDER BY 1,2
)
SELECT year,
	   company,
	   current_sales,
	   AVG(current_sales) OVER(PARTITION BY company) AS avg_sales,
	   current_sales - AVG(current_sales) OVER (PARTITION BY company) AS price_diff,
	   CASE WHEN  AVG(current_sales) OVER(PARTITION BY company) > current_sales THEN 'Below avg'
	   		WHEN  AVG(current_sales) OVER(PARTITION BY company) < current_sales THEN 'Above avg'
			ELSE 'no change'
		END AS compare_to_avg
FROM company_details
ORDER BY 1,2

--Compare average spending between male and female customers in each year , month
WITH genderwise_spending AS (
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   EXTRACT(MONTH FROM order_date) AS month,
	   gender AS gender,
	   ROUND(AVG(price)::numeric ,3) AS avg_spending
FROM car_data
GROUP BY 1,2,3
ORDER BY 1,2,3
)
SELECT year,
	   month,
	   MAX(CASE WHEN gender='Male' THEN avg_spending END) AS male_avg,
	   MAX(CASE WHEN gender='Female' THEN avg_spending END) AS female_avg,
	   MAX(CASE WHEN gender='Male' THEN avg_spending END) - MAX(CASE WHEN gender='Female' THEN avg_spending END)
				AS difference
FROM genderwise_spending
GROUP BY 1,2

--compare customers whose total spending is above overall average spending of each dealer
WITH customer_data AS (
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   dealer_name AS dealer,
	   customer_name AS customer,
	   SUM(price) AS total_spending
FROM car_data 

GROUP BY 1,2,3
ORDER BY 1,2,3
), 
comparison_to_avg AS (
SELECT year,
	   dealer,
	   customer,
	   total_spending,
	   ROUND(AVG(total_spending) OVER(PARTITION BY year,dealer ORDER BY dealer)::numeric,3) AS avg_spending,
	   CASE WHEN total_spending - ROUND(AVG(total_spending) OVER(PARTITION BY year,dealer ORDER BY dealer)::numeric,3) >0
	   	    THEN 'Above the avg'
			WHEN total_spending - ROUND(AVG(total_spending) OVER(PARTITION BY year,dealer ORDER BY dealer)::numeric,3) <0
			THEN 'Below the avg'
			ELSE 'No difference'
	  END AS comparison
FROM customer_data
)
--customers segmentation
SELECT * FROM comparison_to_avg
WHERE comparison ='No difference'

SELECT * FROM comparison_to_avg
WHERE comparison ='Above the avg'

SELECT * FROM comparison_to_avg
WHERE comparison ='Below the avg'


--Identify the first customer and details in each year
SELECT *
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        customer_name AS customer,
        gender,
        annual_income AS income,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY EXTRACT(YEAR FROM order_date)
            ORDER BY order_date
        ) AS rank
    FROM car_data
) t
WHERE rank = 1
ORDER BY year;

--Calculate what % of total revenue each company contributes for each dealer in each year
--find the  best contributor company for each company each year
WITH cte AS (
SELECT EXTRACT(YEAR FROM order_date) AS year,
	   dealer_name AS dealer,
	   company AS company,
	   SUM(price) AS sales
FROM car_data
GROUP BY 1,2,3
ORDER BY 1,2,3
),
contribution_table AS (
SELECT year,
	   dealer,
	   company,
	   sales,
	   CONCAT(ROUND(sales::numeric/SUM(sales) OVER(PARTITION BY year,dealer, dealer)::numeric * 100 ,2),'%') AS contribution

FROM cte
),
--best contributor company
year_details AS (
SELECT year,
	   dealer,
	   company,
	   sales,
	   contribution,
	   DENSE_RANK() OVER(PARTITION BY year,dealer ORDER by contribution DESC) as rank
FROM contribution_table
)
SELECT year,
	   dealer,
	   company,
	   sales,
	   contribution
FROM year_details 
WHERE rank =1

---Find the most common combination of:

--engine
--transmission
--body_style
-- in each year
SELECT year,
	   engine,
	   transmission,
	   body_style,
	   total_items
FROM (
SELECT 
	EXTRACT(YEAR FROM order_date) AS year,
    engine,
    transmission,
    body_style,
    COUNT(*) AS total_items,
	DENSE_RANK() OVER(PARTITION BY EXTRACT(YEAR FROM order_date) ORDER BY COUNT(*) DESC) AS rank
FROM car_data
GROUP BY EXTRACT(YEAR FROM order_date),engine, transmission, body_style
ORDER BY EXTRACT(YEAR FROM order_date),total_items DESC
) t
WHERE rank =1



--Segment customers into income groups and calculate:

--avg spending 
--total purchases
--preferred car type
WITH cte AS (
SELECT  customer_name AS customer,
	    price,
		body_style,		
		CASE 
		    WHEN annual_income < 50000 THEN 'Low Income'
		    WHEN annual_income BETWEEN 50000 AND 100000 THEN 'Middle Income'
		    ELSE 'High Income'
		END AS income_group
FROM car_data
)
SELECT 
    income_group,
    COUNT(*) AS total_purchases,
    ROUND(AVG(price)::numeric,2) AS avg_spending,
    
    -- most common car type
    MODE() WITHIN GROUP (ORDER BY body_style) AS preferred_body_style

FROM cte
GROUP BY income_group
ORDER BY avg_spending DESC;










# 🚗 Car Sales SQL Analytics Project

## 📌 Overview

This project demonstrates advanced SQL analysis using a car sales
dataset.\
It covers real-world business problems using: - Window Functions - CTEs
(Common Table Expressions) - Subqueries

------------------------------------------------------------------------

## 🗂️ Table Schema

``` sql
DROP TABLE IF EXISTS car_data;
CREATE TABLE car_data (
    car_id VARCHAR(50),
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
    price FLOAT,
    dealer_no VARCHAR(30),
    body_style VARCHAR(20),
    phone VARCHAR(20),
    dealer_region VARCHAR(50)
);
```

------------------------------------------------------------------------

# 📊 Business Problems & SQL Solutions

## 1️⃣ Year-wise Sales

**Problem:** Analyze total sales per company each year.

``` sql
SELECT EXTRACT(YEAR FROM order_date) AS year,
       company,
       SUM(price) AS total_sales
FROM car_data
GROUP BY 1,2
ORDER BY 1;
```

------------------------------------------------------------------------

## 2️⃣ Monthly Sales Trend

**Problem:** Track monthly sales performance.

``` sql
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       company,
       SUM(price) AS total_sales
FROM car_data
GROUP BY 1,2,3
ORDER BY 1,2;
```

------------------------------------------------------------------------

## 3️⃣ Best Performing Company Each Month

**Problem:** Identify top company per month.

``` sql
SELECT *
FROM (
    SELECT company,
           EXTRACT(YEAR FROM order_date) AS year,
           EXTRACT(MONTH FROM order_date) AS month,
           SUM(price) AS total_sales,
           DENSE_RANK() OVER (
               PARTITION BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
               ORDER BY SUM(price) DESC
           ) AS rank
    FROM car_data
    GROUP BY company, year, month
) t
WHERE rank = 1;
```

------------------------------------------------------------------------

## 4️⃣ Top 3 Companies Per Month

**Problem:** Find top 3 companies monthly.

``` sql
SELECT *
FROM (
    SELECT EXTRACT(YEAR FROM order_date) AS year,
           EXTRACT(MONTH FROM order_date) AS month,
           company,
           SUM(price) AS sales,
           DENSE_RANK() OVER (
               PARTITION BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
               ORDER BY SUM(price) DESC
           ) AS rank
    FROM car_data
    GROUP BY 1,2,3
) t
WHERE rank <= 3;
```

------------------------------------------------------------------------

## 5️⃣ Running Total Sales by Company

**Problem:** Track cumulative sales.

``` sql
SELECT company, year, month, sales,
       SUM(sales) OVER (
           PARTITION BY company, year
           ORDER BY month
       ) AS running_total
FROM (
    SELECT company,
           EXTRACT(YEAR FROM order_date) AS year,
           EXTRACT(MONTH FROM order_date) AS month,
           SUM(price) AS sales
    FROM car_data
    GROUP BY company, year, month
) t;
```

------------------------------------------------------------------------

## 6️⃣ Customer Spending Rank

**Problem:** Rank customers by total spending.

``` sql
SELECT customer_name,
       SUM(price) AS sales,
       DENSE_RANK() OVER(ORDER BY SUM(price) DESC) AS rank
FROM car_data
GROUP BY customer_name;
```

------------------------------------------------------------------------

## 7️⃣ Repeat Customers

**Problem:** Identify repeat buyers.

``` sql
SELECT *
FROM (
    SELECT customer_name,
           COUNT(DISTINCT car_id) AS cars,
           DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
    FROM car_data
    GROUP BY customer_name
    HAVING COUNT(*) > 1
) t
WHERE rank <= 10;
```

------------------------------------------------------------------------

## 8️⃣ Top Model per Region per Year

``` sql
SELECT *
FROM (
    SELECT dealer_region,
           EXTRACT(YEAR FROM order_date) AS year,
           model,
           COUNT(*) AS total,
           DENSE_RANK() OVER (
               PARTITION BY dealer_region, EXTRACT(YEAR FROM order_date)
               ORDER BY COUNT(*) DESC
           ) AS rank
    FROM car_data
    GROUP BY 1,2,3
) t
WHERE rank = 1;
```

------------------------------------------------------------------------

## 9️⃣ Dealer Performance Ranking

``` sql
SELECT *
FROM (
    SELECT EXTRACT(YEAR FROM order_date) AS year,
           EXTRACT(MONTH FROM order_date) AS month,
           dealer_region,
           dealer_name,
           SUM(price) AS sales,
           DENSE_RANK() OVER (
               PARTITION BY year, month
               ORDER BY SUM(price) DESC
           ) AS rank
    FROM car_data
    GROUP BY 1,2,3,4
) t
WHERE rank = 1;
```

------------------------------------------------------------------------

## 🔟 Price vs Company Average

``` sql
WITH cte AS (
    SELECT company,
           SUM(price) AS sales
    FROM car_data
    GROUP BY company
)
SELECT *,
       AVG(sales) OVER() AS avg_sales,
       sales - AVG(sales) OVER() AS diff
FROM cte;
```

------------------------------------------------------------------------

## 1️⃣1️⃣ Gender Spending Comparison

``` sql
SELECT gender,
       AVG(price) AS avg_spending
FROM car_data
GROUP BY gender;
```

------------------------------------------------------------------------

## 1️⃣2️⃣ Above Average Customers

``` sql
SELECT customer_name
FROM car_data
GROUP BY customer_name
HAVING SUM(price) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(price) AS total
        FROM car_data
        GROUP BY customer_name
    ) t
);
```

------------------------------------------------------------------------

## 1️⃣3️⃣ First Customer Each Year

``` sql
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY EXTRACT(YEAR FROM order_date)
               ORDER BY order_date
           ) AS rank
    FROM car_data
) t
WHERE rank = 1;
```

------------------------------------------------------------------------

## 1️⃣4️⃣ Revenue Contribution %

``` sql
SELECT company,
       SUM(price),
       SUM(price)*100.0 / SUM(SUM(price)) OVER() AS pct
FROM car_data
GROUP BY company;
```

------------------------------------------------------------------------

## 1️⃣5️⃣ Most Popular Car Combination

``` sql
SELECT *
FROM (
    SELECT engine, transmission, body_style,
           COUNT(*) AS total,
           DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
    FROM car_data
    GROUP BY 1,2,3
) t
WHERE rank = 1;
```

------------------------------------------------------------------------

## 🎯 Conclusion

This project demonstrates real-world SQL analytics used in: - Business
Intelligence - Data Warehousing - Dashboard Development

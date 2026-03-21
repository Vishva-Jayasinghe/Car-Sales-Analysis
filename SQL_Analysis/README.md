
[Professional_Car_Sales_README.md](https://github.com/user-attachments/files/26157171/Professional_Car_Sales_README.md)
# 🚗 Car Sales Analytics Project (SQL)

## 📌 Project Overview

This project analyzes a **car sales dataset** using advanced SQL
techniques such as: - Window Functions - Common Table Expressions
(CTEs) - Subqueries

The goal is to solve real-world business problems and generate insights
for BI dashboards.

------------------------------------------------------------------------

## 🗂️ Dataset Schema

``` sql
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

## 📊 Business Problems & SQL Solutions

### 1. Year-wise Sales

``` sql
SELECT EXTRACT(YEAR FROM order_date) AS year,
       company,
       SUM(price) AS total_sales
FROM car_data
GROUP BY 1,2;
```

### 2. Monthly Sales Trend

``` sql
SELECT EXTRACT(YEAR FROM order_date),
       EXTRACT(MONTH FROM order_date),
       company,
       SUM(price)
FROM car_data
GROUP BY 1,2,3;
```

### 3. Best Company per Month

``` sql
DENSE_RANK() OVER (PARTITION BY year, month ORDER BY SUM(price) DESC)
```

### 4. Top 3 Companies Per Month

``` sql
WHERE rank <= 3
```

### 5. Running Total Sales

``` sql
SUM(sales) OVER (PARTITION BY company ORDER BY month)
```

### 6. Customer Ranking

``` sql
DENSE_RANK() OVER (ORDER BY SUM(price) DESC)
```

### 7. Repeat Customers

``` sql
HAVING COUNT(*) > 1
```

### 8. Top Model per Region

``` sql
PARTITION BY dealer_region
```

### 9. Dealer Ranking

``` sql
DENSE_RANK() OVER (PARTITION BY year, month ORDER BY SUM(price) DESC)
```

### 10. Sales vs Average

``` sql
AVG(sales) OVER (PARTITION BY company)
```

### 11. Gender Spending

Compare male vs female spending patterns.

### 12. Above/Below Avg Customers

Segment customers by spending.

### 13. First Customer per Year

``` sql
ROW_NUMBER() OVER (PARTITION BY year ORDER BY order_date)
```

### 14. Revenue Contribution

``` sql
sales / SUM(sales) OVER()
```

### 15. Popular Car Combination

Most common engine, transmission, body style.

### 16. Income Segmentation

``` sql
CASE WHEN annual_income < 50000 THEN 'Low'
```

------------------------------------------------------------------------

## 🧠 Key Insights

-   Sales trends over time
-   Top companies and dealers
-   Customer segmentation
-   Popular products

------------------------------------------------------------------------

## ⚙️ Tools

-   PostgreSQL
-   SQL
-   Power BI

------------------------------------------------------------------------

## 🚀 How to Run

1.  Create table
2.  Insert data
3.  Run queries
4.  Visualize results

------------------------------------------------------------------------

## 📌 Conclusion

Demonstrates strong SQL skills for real-world analytics.

USE `2nd_project`;

CREATE TABLE customer_data (
`Customer ID` VARCHAR(50),
`Age` VARCHAR(50),
`Gender` VARCHAR(20),
`Purchase Amount(USD)` VARCHAR(20),
`Location` VARCHAR(100),
`Size` VARCHAR(20),
`Color` VARCHAR(50),
`Season` VARCHAR(30),
`Review Rating` VARCHAR(50),
`Subscription Status` VARCHAR(30),
`Discount Applied` VARCHAR(20),
`Previous purchases` VARCHAR(50),
`Payment method` VARCHAR(50),
`Frequency of Purchases` VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/londi/Downloads/archive (11)/customer_data.csv'
INTO TABLE customer_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(`Customer ID`, `Age`, `Gender`, `Purchase Amount(USD)`, `Location`,
`Size`, `Color`, `Season`, `Review Rating`, `Subscription Status`,
`Discount Applied`, `Previous purchases`, `Payment method`,
`Frequency of Purchases`);

CREATE TABLE order_data (
`Order ID` VARCHAR(50),
`Order Date` VARCHAR(50),
`Ship Mode` VARCHAR(50),
`Segment` VARCHAR(50),
`Category` VARCHAR(50),
`Sub Category` VARCHAR(50),
`Product ID` VARCHAR(50),
`Cost Price` DECIMAL(10,2),
`List Price` DECIMAL(10,2),
`Quantity` INT,
`Discount Percent` DECIMAL(5,2),
`Customer ID` VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/londi/Downloads/archive (11)/order_data.csv'
INTO TABLE order_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(`Order ID`, `Order Date`, `Ship Mode`, `Segment`, `Category`,
`Sub Category`, `Product ID`, `Cost Price`, `List Price`, `Quantity`,
`Discount Percent`, `Customer ID`);

SELECT * FROM customer_data;
DESCRIBE customer_data;

SELECT `Customer ID`, COUNT(*) AS duplicate_count
FROM customer_data
GROUP BY `Customer ID`
HAVING COUNT(*) > 1;

SELECT *
FROM customer_data
WHERE `Purchase Amount(USD)` IS NULL
   OR TRIM(`Purchase Amount(USD)`) = '';

SELECT DISTINCT Age FROM customer_data;
SELECT DISTINCT Gender FROM customer_data;
SELECT DISTINCT Season FROM customer_data;
SELECT DISTINCT Location FROM customer_data;
SELECT DISTINCT Color FROM customer_data;
SELECT DISTINCT Size FROM customer_data;
SELECT DISTINCT `Subscription Status` FROM customer_data;
SELECT DISTINCT `Discount Applied` FROM customer_data;
SELECT DISTINCT `Payment method` FROM customer_data;
SELECT DISTINCT `Previous purchases` FROM customer_data;
SELECT DISTINCT `Frequency of Purchases` FROM customer_data;
SELECT DISTINCT `Review Rating` FROM customer_data;

CREATE TABLE customer_data_backup AS
SELECT * FROM customer_data;

CREATE TABLE customer_data_unique AS
SELECT DISTINCT *
FROM customer_data;

SELECT COUNT(*) AS old_rows FROM customer_data;

SELECT COUNT(*) AS unique_rows FROM customer_data_unique;

DROP TABLE customer_data;

RENAME TABLE customer_data_unique TO customer_data;

SELECT `Customer ID`, COUNT(*) AS duplicate_count
FROM customer_data
GROUP BY `Customer ID`
HAVING COUNT(*) > 1;

UPDATE customer_data
SET Size = 'Unknown'
WHERE Size IS NULL OR TRIM(Size) = '';

UPDATE customer_data
SET `Discount Applied` = 'Unknown'
WHERE `Discount Applied` IS NULL OR TRIM(`Discount Applied`) = '';

UPDATE customer_data
SET `Frequency of Purchases` = 'Fortnightly'
WHERE `Frequency of Purchases` = 'Bi-weekly';

SELECT COUNT(DISTINCT `Customer ID`) AS total_customers
FROM customer_data;

SELECT
    CASE
        WHEN Age BETWEEN 0 AND 17 THEN '0-17'
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 59 THEN '45-59'
        WHEN Age BETWEEN 60 AND 74 THEN '60-74'
        WHEN Age >= 75 THEN '75+'
    END AS age_group,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers
FROM customer_data
WHERE Age IS NOT NULL
GROUP BY age_group
ORDER BY number_of_customers DESC;

SELECT
    Gender,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers,
    ROUND(SUM(`Purchase Amount(USD)`), 2) AS total_purchase,
    ROUND(AVG(`Purchase Amount(USD)`), 2) AS average_purchase
FROM customer_data
GROUP BY Gender
ORDER BY number_of_customers DESC;

SELECT
    Season,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers,
    ROUND(SUM(`Purchase Amount(USD)`), 2) AS total_purchase
FROM customer_data
GROUP BY Season
ORDER BY number_of_customers DESC;

SELECT ROUND(AVG(`Review Rating`), 2) AS average_rating
FROM customer_data;

SELECT Color, COUNT(DISTINCT `Customer ID`) AS number_of_customers
FROM customer_data
GROUP BY Color
ORDER BY number_of_customers DESC;

SELECT Size, COUNT(DISTINCT `Customer ID`) AS number_of_customers
FROM customer_data
GROUP BY Size
ORDER BY number_of_customers DESC;

SELECT
    `Subscription Status`,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers,
    ROUND(COUNT(DISTINCT `Customer ID`) * 100.0 /
          (SELECT COUNT(DISTINCT `Customer ID`) FROM customer_data), 2) AS percentage
FROM customer_data
GROUP BY `Subscription Status`
ORDER BY number_of_customers DESC;

SELECT
    `Discount Applied`,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers,
    ROUND(COUNT(DISTINCT `Customer ID`) * 100.0 /
          (SELECT COUNT(DISTINCT `Customer ID`) FROM customer_data), 2) AS percentage
FROM customer_data
GROUP BY `Discount Applied`
ORDER BY number_of_customers DESC;

SELECT
    `Payment method`,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers,
    ROUND(SUM(`Purchase Amount(USD)`), 2) AS total_purchase
FROM customer_data
GROUP BY `Payment method`
ORDER BY number_of_customers DESC;

SELECT
    Location,
    Gender,
    COUNT(DISTINCT `Customer ID`) AS number_of_customers
FROM customer_data
GROUP BY Location, Gender
ORDER BY Location, number_of_customers DESC;

SELECT
    `Customer ID` AS Customer_ID,
    `Purchase Amount(USD)` AS Purchase_Amount,
    CASE
        WHEN `Purchase Amount(USD)` >= 100 THEN 'High'
        WHEN `Purchase Amount(USD)` >= 50 THEN 'Medium'
        ELSE 'Low'
    END AS Spending_Category
FROM customer_data;

SELECT
    `Customer ID` AS Customer_ID,
    `Purchase Amount(USD)` AS Purchase_Amount,
    RANK() OVER (ORDER BY `Purchase Amount(USD)` DESC) AS Purchase_Rank
FROM customer_data;

WITH Customer_Average AS (
    SELECT AVG(`Purchase Amount(USD)`) AS Average_Purchase
    FROM customer_data
    WHERE `Purchase Amount(USD)` IS NOT NULL
)
SELECT
    c.`Customer ID` AS Customer_ID,
    c.`Purchase Amount(USD)` AS Purchase_Amount,
    CASE
        WHEN c.`Purchase Amount(USD)` > a.Average_Purchase THEN 'Above Average'
        WHEN c.`Purchase Amount(USD)` < a.Average_Purchase THEN 'Below Average'
        ELSE 'Average'
    END AS Purchase_Level
FROM customer_data AS c
CROSS JOIN Customer_Average AS a
WHERE c.`Purchase Amount(USD)` IS NOT NULL
ORDER BY c.`Purchase Amount(USD)` DESC;

DROP FUNCTION IF EXISTS Get_Age_Group;
DELIMITER $$
CREATE FUNCTION Get_Age_Group(age INT)
RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN age IS NULL THEN 'No Data'
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 24 THEN '18-24 Young Adults'
        WHEN age BETWEEN 25 AND 34 THEN '25-34 Early Career'
        WHEN age BETWEEN 35 AND 54 THEN '35-54 Established Adults'
        WHEN age BETWEEN 55 AND 70 THEN '55-70 Seniors'
        WHEN age >= 71 THEN '71+'
    END;
END$$
DELIMITER ;

SELECT
    `Customer ID` AS Customer_ID,
    Age,
    Get_Age_Group(Age) AS Age_Group,
    `Purchase Amount(USD)` AS Purchase_Amount
FROM customer_data
ORDER BY Age ASC;

DROP PROCEDURE IF EXISTS Customer_Summary;
DELIMITER $$
CREATE PROCEDURE Customer_Summary()
BEGIN
    SELECT
        `Customer ID` AS Customer_ID,
        Age,
        Gender,
        `Purchase Amount(USD)` AS Purchase_Amount,
        `Previous Purchases` AS Previous_Purchases,
        `Frequency of Purchases` AS Purchase_Frequency,
        `Subscription Status` AS Subscription_Status
    FROM customer_data
    ORDER BY `Purchase Amount(USD)` DESC;
END$$
DELIMITER ;

CALL Customer_Summary();

SELECT * FROM order_data;
DESCRIBE order_data;

SELECT `Order ID`, COUNT(*) AS duplicate_count
FROM order_data
GROUP BY `Order ID`
HAVING COUNT(*) > 1;

SELECT `Product ID`, COUNT(*) AS occurrence_count
FROM order_data
GROUP BY `Product ID`
HAVING COUNT(*) > 1;

SELECT DISTINCT `Order Date` FROM order_data;
SELECT DISTINCT `Ship Mode` FROM order_data;
SELECT DISTINCT Segment FROM order_data;
SELECT DISTINCT Category FROM order_data;
SELECT DISTINCT `Sub Category` FROM order_data;
SELECT DISTINCT `Cost Price` FROM order_data;
SELECT DISTINCT `List Price` FROM order_data;
SELECT DISTINCT Quantity FROM order_data;
SELECT DISTINCT `Discount Percent` FROM order_data;

UPDATE order_data
SET `Ship Mode` = 'Unknown'
WHERE `Ship Mode` IS NULL OR TRIM(`Ship Mode`) = '';

UPDATE order_data
SET `Ship Mode` = 'Unknown'
WHERE `Ship Mode` = 'Not Available';

SELECT
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(`List Price` * Quantity), 2) AS total_sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS total_profit
FROM order_data;

SELECT
    SUBSTRING(`Order Date`, 7, 4) AS order_year,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM(`Cost Price` * Quantity), 2) AS total_cost,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY SUBSTRING(`Order Date`, 7, 4)
ORDER BY order_year;

SELECT
    SUBSTRING(`Order Date`, 7, 4) AS order_year,
    SUBSTRING(`Order Date`, 4, 2) AS order_month,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY SUBSTRING(`Order Date`, 7, 4), SUBSTRING(`Order Date`, 4, 2)
ORDER BY order_year, order_month;

SELECT
    Category,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY Category
ORDER BY sales_revenue DESC;

SELECT
    `Sub Category`,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY `Sub Category`
ORDER BY sales_revenue DESC;

SELECT
    `Customer ID` AS Customer_ID,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY `Customer ID`
ORDER BY sales_revenue DESC;

SELECT
    Segment,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY Segment
ORDER BY sales_revenue DESC;

SELECT
    `Ship Mode`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY `Ship Mode`
ORDER BY sales_revenue DESC;

SELECT
    `Product ID` AS Product_ID,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY `Product ID`
ORDER BY sales_revenue DESC
LIMIT 10;

SELECT
    `Discount Percent`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Quantity) AS total_quantity,
    ROUND(SUM(`List Price` * Quantity), 2) AS sales_revenue,
    ROUND(SUM((`List Price` - `Cost Price`) * Quantity), 2) AS profit
FROM order_data
GROUP BY `Discount Percent`
ORDER BY `Discount Percent`;

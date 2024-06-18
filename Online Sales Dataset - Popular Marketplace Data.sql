USE `online sales dataset - popular marketplace data`;
SHOW TABLES;
SHOW COLUMNS FROM  `online sales data`;
-- add new column date_sale and insert from column date converted from TEXT to DATE  
ALTER TABLE `online sales data` ADD COLUMN date_sale DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE `online sales data` 
SET date_sale = `Date`;
SHOW COLUMNS FROM `online sales data`;
ALTER TABLE `online sales data` DROP COLUMN Date;
SHOW COLUMNS FROM  `online sales data`; -- there is new column date_sale with  datype DATE

-- add date_month column
ALTER TABLE `online sales data` ADD COLUMN date_month TEXT;
UPDATE `online sales data` 
SET date_month = DATE_FORMAT(date_sale, '%M');
SET SQL_SAFE_UPDATES = 1;
SHOW COLUMNS FROM  `online sales data`;

-- Exploratory Data Analysis
SELECT *  FROM `online sales data` LIMIT 5;
-- number of records
SELECT COUNT(*) FROM `online sales data`;
-- are there dublications
SELECT COUNT(*)
FROM 
(
  SELECT `Transaction ID`,
  COUNT(*) AS records
  FROM `online sales data`
  GROUP BY `Transaction ID`
) a
WHERE records > 1; -- there are no dublications

-- is there any null
select count(`Transaction ID`) from `online sales data`
where `Transaction ID` is null;
select count(Date) from `online sales data`
where Date is null;
select count(`Product Category`) from `online sales data`
where `Product Category` is null;
select count(`Product Name`) from `online sales data`
where `Product Name` is null;
select count(`Units Sold`) from `online sales data`
where `Units Sold` is null;
select count(`Unit Price`) from `online sales data`
where `Unit Price` is null;
select count(`Total Revenue`) from `online sales data`
where `Total Revenue` is null;
select count(Region) from `online sales data`
where Region is null;
select count(`Payment Method`) from `online sales data`
where `Payment Method` is null; -- there is no null

-- unique values
SELECT DISTINCT `Product Category`
FROM `online sales data`;

 SELECT DISTINCT `Product Name`
 FROM `online sales data`;
 
 SELECT DISTINCT `Payment Method`
 FROM `online sales data`;
 
 SELECT DISTINCT Region
 FROM `online sales data`;
 -- time period
SELECT 
MIN(date_sale)AS the_first_date,
MAX(date_sale) AS the_last_date
FROM `online sales data`;

-- 1. Analyze sales trends over time to identify seasonal patterns
WITH product_sales AS (
SELECT 
date_month,
`Product Category`,
ROUND(SUM(`Total Revenue`),2) AS total_revenue, 
SUM(`Units Sold`) AS total_units_sold
FROM 
`online sales data`
GROUP BY 
date_month, `Product Category`
), 
ranked_products AS (
SELECT 
date_month,
`Product Category`,
total_units_sold,
total_revenue,
ROW_NUMBER() OVER (PARTITION BY date_month ORDER BY total_units_sold DESC) AS ranking
FROM 
product_sales
)
SELECT 
date_month,
`Product Category`,
total_units_sold,
total_revenue
FROM 
ranked_products
WHERE 
ranking = 1;

-- FOR MOST MONTHS, THE BEST-SELLING PRODUCT CATEGORY IS 'Clothing', WITH THE EXCEPTION OF MONTHS: 'January', 'March', WHERE 'Sports' IS THE BEST-SELLER

-- 2. Explore the popularity of different product categories across regions.
SELECT 
-- the most total units sold 
Region,
ROUND(SUM(`Total Revenue`),2) AS total_revenue, 
SUM(`Units Sold`) AS total_units_sold
FROM `online sales data`
GROUP BY Region
ORDER BY total_units_sold DESC;
-- the most total revenue
SELECT 
Region,
ROUND(SUM(`Total Revenue`),2) AS total_revenue, 
SUM(`Units Sold`) AS total_units_sold
FROM `online sales data`
GROUP BY Region
ORDER BY  total_revenue DESC;

WITH a AS (
SELECT 
Region, 
`Product Category`,
ROUND(SUM(`Total Revenue`), 2) AS total_revenue, 
SUM(`Units Sold`) AS total_units_sold
FROM 
`online sales data`
GROUP BY 
Region, `Product Category`
), 
region_ranking AS (
SELECT 
Region, 
`Product Category`,
total_revenue, 
total_units_sold,
ROW_NUMBER() OVER (PARTITION BY Region ORDER BY total_units_sold DESC) AS ranking
FROM a
)
SELECT 
Region, 
`Product Category`,
total_revenue, 
total_units_sold
FROM 
region_ranking
WHERE 
ranking = 1;

-- 3. Investigate the impact of payment methods on sales volume or revenue.

SELECT 
`Payment Method`,
ROUND(SUM(`Total Revenue`), 2) AS total_revenue, 
SUM(`Units Sold`) AS total_units_sold
FROM `online sales data`
GROUP BY `Payment Method`
ORDER BY total_revenue DESC ; 

-- Credit card has the most impact on revenue and sales volume 
-- 4. Identify top-selling products within each category
SELECT 
`Product Category`, 
`Product Name`, 
total_revenue, 
total_units_sold 
FROM (
SELECT 
`Product Category`,
`Product Name`,
ROUND(SUM(`Total Revenue`), 2) AS total_revenue, 
SUM(`Units Sold`) AS total_units_sold,
ROW_NUMBER() OVER(PARTITION BY `Product Category` ORDER BY SUM(`Units Sold`) DESC) AS ranking
FROM 
`online sales data`
GROUP BY 
`Product Category`, `Product Name`
) x
WHERE 
ranking = 1;
 -- 5. Evaluate the performance of specific products or categories in different regions to tailor marketing campaigns accordingly.   
SELECT 
Region,
`Product Category`,
`Product Name`,
SUM(`Units Sold`) AS total_units_sold,
ROUND(SUM(`Total Revenue`), 2) AS total_revenue
FROM 
`online sales data`
GROUP BY 
Region, `Product Category`, `Product Name`
ORDER BY 
Region, `Product Category`, total_units_sold DESC;




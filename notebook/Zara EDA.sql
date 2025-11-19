CREATE DATABASE Zara;

USE zara;

CREATE TABLE zara_inventory(
	product_id INT PRIMARY KEY,
    product_category VARCHAR(20),
    seasonal VARCHAR(10),
    brand VARCHAR(10),
    item_name VARCHAR(70),
    price DOUBLE(10,2),
    currency VARCHAR(5),
    item_category VARCHAR(20),
    section VARCHAR(15),
    material VARCHAR(15),
    origin VARCHAR(20)
    );
    
CREATE TABLE zara_sales_data(
	sale_id VARCHAR(10) PRIMARY KEY,
    product_id INT,
    branch_id VARCHAR(20),
    quantity INT,
    sale_date DATE,
    promotion VARCHAR(10),
    total_price DOUBLE(10,2),
    discount DOUBLE(10,2),
    payment_method VARCHAR(20),
    channel VARCHAR(20),
    season VARCHAR(15)
		-- CONSTRAINT fk_inventory_product
        -- FOREIGN KEY (product_id) REFERENCES zara_sales_data(product_id)
    );


CREATE TABLE zara_branch(
	branch_id VARCHAR(20) PRIMARY KEY,
    country_code VARCHAR(10),
    city_code VARCHAR(10),
    country VARCHAR(20),
    city VARCHAR(20)
);

-- assign foreign keys.
ALTER TABLE zara_sales_data
ADD CONSTRAINT fk_inventory_product
FOREIGN KEY (product_id) REFERENCES zara_inventory(product_id),
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id) REFERENCES zara_branch(branch_id);

SELECT * FROM zara_branch;

SELECT * FROM zara_sales_data;

SELECT * FROM zara_inventory;

-- EDA
-- 1. Total Revenue
SELECT SUM(total_price) FROM zara_sales_data AS total_revenue;

-- 2.	Revenue ranked categorised -cities and countries
SELECT b.country,
	SUM(total_price) as revenue_country
    FROM zara_sales_data s
    JOIN zara_branch b ON s.branch_id = b.branch_id
    GROUP BY b.country
    ORDER BY revenue_country DESC;

-- 2.	Online vs instore shopping across countries and cities
SELECT b.country, COUNT(s.channel) AS shop_sales,
	ROUND ((COUNT(s.channel)* 100) /
	(SELECT COUNT(sale_id) FROM zara_sales_data),1) AS sales_percentage
	FROM zara_sales_data s
	JOIN zara_branch b ON s.branch_id = b.branch_id 
	WHERE channel = 'instore'
	GROUP BY b.country, s.channel
	ORDER BY shop_sales DESC;

-- 3.	Most popular paying methods per country 
SELECT b.country, s.payment_method as payments,
COUNT(*) AS total_payments
FROM zara_sales_data s
JOIN zara_branch b ON s.branch_id = b.branch_id
GROUP BY b.country, s.payment_method
ORDER BY b.country, total_payments DESC;

/* SELECT i.item_category,s.season,
		COUNT(s.sale_id) AS total_sales,
		ROW_NUMBER()OVER (PARTITION BY s.season ORDER BY COUNT(sale_id)
		DESC) AS rn
	FROM zara_sales_data s
	JOIN zara_inventory i ON i.product_id = s.product_id
	GROUP BY i.item_category, s.season;
*/

-- 4.	Most sold item per season
SELECT item_category,season,total_sales
FROM
	(SELECT i.item_category, 
			s.season, 
            COUNT(s.sale_id) AS total_sales,
			ROW_NUMBER()OVER 
            (PARTITION BY s.season ORDER BY COUNT(s.sale_id)DESC)AS rn
    FROM zara_sales_data s
	JOIN zara_inventory i ON i.product_id = s.product_id
	GROUP BY i.item_category,s.season
	) sub
	WHERE rn = 1;


-- 5.	Most popular country of origin of the products
SELECT origin, COUNT(*) as country_origin
	FROM zara_inventory
    GROUP BY origin
    ORDER BY country_origin DESC;

-- 6.	Woman vs Man shopping
SELECT section, COUNT(*) as sales
FROM zara_inventory
GROUP BY section
ORDER BY sales DESC;

-- 7.	Top 5/10 sold products – brought the most revenue
SELECT item_category,item_name, most_sold
FROM(
	SELECT i.item_category,item_name,SUM(s.total_price) AS most_sold,
			ROW_NUMBER() OVER (PARTITION BY i.item_category 
					ORDER BY SUM(s.total_price)DESC) AS rn
	FROM zara_inventory i
    JOIN zara_sales_data s ON i.product_id = s.product_id
    GROUP BY i.item_category,item_name
)ranked
WHERE rn <3
ORDER BY most_sold DESC;

-- top 5 sold item category
SELECT item_category, total_orders
FROM(
	SELECT i.item_category,SUM(s.quantity) AS total_orders,
		ROW_NUMBER() OVER (ORDER BY SUM(s.quantity)DESC) AS rn
	FROM zara_inventory i
    JOIN zara_sales_data s ON i.product_id = s.product_id
    GROUP BY i.item_category
    )
ranked
where rn < 6
ORDER BY total_orders DESC;

	











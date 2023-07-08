/*
Amazon_Sales_Data exploration.
Dataset used from Kaggle (https://www.kaggle.com/datasets/karkavelrajaj/amazon-sales-dataset)

SQL skills used - select, group by, order by, limit, top, case, aggregate functions.
*/

----------------------------------------------------------------------------------------------------
/* What are the top 5 products with the highest ratings? */

SELECT product_name, rating 
FROM amazon 
ORDER BY rating DESC 
LIMIT 5

-----------------------------------------------------------------------------------------------------  
/* Which category has the highest average discount percentage? */

SELECT category, AVG(discount_percentage) AS avg_discount_percentage 
FROM amazon 
GROUP BY category 
ORDER BY avg_discount_percentage DESC 
LIMIT 1

-----------------------------------------------------------------------------------------------------
/* How many reviews are there for each product? */

SELECT product_id, COUNT(review_id) AS review_count 
FROM amazon 
GROUP BY product_id

----------------------------------------------------------------------------------------------------- 
/* What is the average length of the review content for each product category? */

SELECT category, AVG(LENGTH(review_content)) AS avg_review_content 
FROM amazon 
GROUP BY category

-----------------------------------------------------------------------------------------------------   
/* What is the average rating count for products in each category? */

SELECT category, AVG(rating_count) AS avg_rating_count 
FROM amazon 
GROUP BY category

-----------------------------------------------------------------------------------------------------   
/* Which product has the highest percentage of discount? */

SELECT product_name, discount_percentage
FROM amazon 
ORDER BY discount_percentage DESC 
LIMIT 1

-----------------------------------------------------------------------------------------------------   
/* How many products have a rating above 4 and at least 100 rating counts? */

SELECT COUNT(*) AS Product_Count 
FROM amazon 
WHERE rating > 4.0 AND rating_count >= 100

-----------------------------------------------------------------------------------------------------   
/* What are the top 5 most reviewed products? */

SELECT product_name, COUNT(review_id) AS review_count 
FROM amazon 
GROUP BY product_name 
ORDER BY review_count DESC 
LIMIT 5

----------------------------------------------------------------------------------------------------- 
/* What is the average discount percentage for products with different rating ranges (e.g., 4-4.5, 4.5-5)? */

SELECT
    CASE
        WHEN rating >= 4 AND rating < 4.5 THEN '4-4.5' 
        WHEN rating >= 4.5 AND rating <= 5 THEN '4.5-5'
    END AS rating_range,
   AVG(discount_percentage) AS avg_discount_percentage 
FROM amazon 
GROUP BY rating_range

-----------------------------------------------------------------------------------------------------   
/* How many products have both a review title and a review content? */
SELECT COUNT(DISTINCT product_id) AS products 
FROM amazon 
WHERE review_title IS NOT NULL AND review_content IS NOT NULL

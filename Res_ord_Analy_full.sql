/* repeated customer sale percentage in total AMOUNT */


WITH rc AS (
  SELECT 
    orders.customer_name,
    orders.restaurant_id,
    restaurants.restaurant_name,
    COUNT(orders.customer_name) AS repeat_time,
    SUM(orders.order_amount) AS total_amoun
  FROM orders
  INNER JOIN restaurants 
    ON orders.restaurant_id = restaurants.restaurant_id
  GROUP BY orders.customer_name, orders.restaurant_id, restaurants.restaurant_name
  HAVING COUNT(orders.customer_name) > 1
),

nc AS (
  SELECT 
    orders.restaurant_id,
    restaurants.restaurant_name,
    SUM(orders.order_amount) AS total_amount
  FROM orders
  INNER JOIN restaurants 
    ON orders.restaurant_id = restaurants.restaurant_id
  GROUP BY orders.restaurant_id, restaurants.restaurant_name
)

SELECT 
  DISTINCT rc.restaurant_name,
  (rc.total_amoun * 100.0) / NULLIF(nc.total_amount, 0) AS repeat_custamt_in_totalamount
FROM rc
INNER JOIN nc 
  ON rc.restaurant_id = nc.restaurant_id
ORDER BY repeat_custamt_in_totalamount DESC;





/* 5 RESTAURANTS HAVING LESS EFFICIENCY SCORE */

select * from (

select
restaurants.restaurant_name,
(avg(orders.delivery_time_taken))/(avg(orders.customer_rating_food) + avg(orders.customer_rating_delivery)) as efficiency_score
from
restaurants 
inner join 
orders on 
restaurants.restaurant_id = orders.restaurant_id
group by 1 
order by (avg(orders.delivery_time_taken))/(avg(orders.customer_rating_food) + avg(orders.customer_rating_delivery)) asc)b
limit 5;


/* Most Loyal Customer having ordered items more than 3 times */


WITH order10 AS (
  SELECT 
    r.restaurant_name,
    r.cuisine,
    o.customer_name,
    AVG(o.customer_rating_food) AS avg_customer_rating_food,
    SUM(o.order_amount) AS total_amount,
    COUNT(o.customer_name) AS order_count
  FROM orders o
  INNER JOIN restaurants r ON r.restaurant_id = o.restaurant_id
  WHERE o.customer_rating_food > 3
  GROUP BY 
    r.restaurant_name,
    r.cuisine,
    o.customer_name
  HAVING COUNT(o.customer_name) >= 3
)

SELECT * 
FROM order10;


/* restaurant having good cuiseines and good food rating,delivery rating  */

WITH cte1 AS (
    SELECT DISTINCT
        restaurants.restaurant_name,
        restaurants.cuisine
    FROM orders 
    LEFT JOIN restaurants ON orders.restaurant_id = restaurants.restaurant_id
    WHERE orders.customer_rating_food >= 4 
        AND orders.customer_rating_delivery >= 4
)

SELECT * FROM cte1;


/*SALES IN a DAY  */

SELECT 
  COALESCE(restaurants.cuisine, 'Total') AS Cuisine,
  SUM(CASE WHEN HOUR(orders.order_time) = 11 THEN 1 ELSE 0 END) AS Morning,
  SUM(CASE WHEN HOUR(orders.order_time) = 12 THEN 1 ELSE 0 END) AS Mid_day,
  SUM(CASE WHEN HOUR(orders.order_time) BETWEEN 13 AND 15 THEN 1 ELSE 0 END) AS Afternoon,
  SUM(CASE WHEN HOUR(orders.order_time) BETWEEN 16 AND 18 THEN 1 ELSE 0 END) AS Evening,
  SUM(CASE WHEN HOUR(orders.order_time) BETWEEN 19 AND 21 THEN 1 ELSE 0 END) AS Night,
  SUM(CASE WHEN HOUR(orders.order_time) BETWEEN 22 AND 23 THEN 1 ELSE 0 END) AS Late_Night
FROM restaurants
RIGHT JOIN orders ON restaurants.restaurant_id = orders.restaurant_id
GROUP BY restaurants.cuisine WITH ROLLUP;


/* REPEATED CUSTOMERS AMOUNT IN TOTAL SALES*/


with  rc as (
select 
customer_name,
restaurant_id,
restaurant_name,
count(1) as repeat_time,
sum(order_amount) as total_amount
from
orders
group by 1,2,3
having  count(1)> 1
)

,nc as (

select 
restaurant_id,
restaurant_name,
sum(order_amount) as total_amounts
from
orders
group by 1,2

)


select 
rc.customer_name,
rc.restaurant_id,
rc.restaurant_name,
(rc.total_amount * 100) /nc.total_amounts as repeat_customer_perc_in_sales
from  
rc 
inner join
nc 
on 
rc.restaurant_id = nc.restaurant_id ;

/* WHICH ZONE IS THE MOST PROFITABLE AND HIGHER ORDER RECEIVING AND GIVE THE RESTAURANTS IN THAT ZONE */


SELECT r.restaurant_name 
FROM restaurants r
WHERE r.zone IN (
    SELECT sub.zone
    FROM (
        SELECT restaurants.zone
        FROM restaurants 
        RIGHT JOIN orders ON restaurants.restaurant_id = orders.restaurant_id
        GROUP BY restaurants.zone
        ORDER BY SUM(orders.order_amount) DESC
        limit 1
    ) sub
);


/* restaurants with variance of rating > 2 */

wITH HighVarianceRestaurants AS (
    SELECT 
        restaurant_id,
        VARIANCE(customer_rating_food) AS rating_variance
    FROM orders
    GROUP BY restaurant_id
    HAVING VARIANCE(customer_rating_food) > 2
)
SELECT 
   distinct r.restaurant_name,
    r.zone,
    hv.rating_variance
FROM HighVarianceRestaurants hv
JOIN restaurants r ON hv.restaurant_id = r.restaurant_id
JOIN orders o ON r.restaurant_id = o.restaurant_id
ORDER BY hv.rating_variance;


/* Restautants and Order_Count in Zone*/

WITH zone_demand AS (
  SELECT 
    r.zone, 
    r.cuisine, 
    COUNT(o.order_id) AS order_count
  FROM orders o
  left join  restaurants r ON o.restaurant_id = r.restaurant_id
  GROUP BY r.zone, r.cuisine
),
zone_competition AS (      
  SELECT 
    zone, 
    cuisine, 
    COUNT(*) AS num_restaurants
  FROM restaurants
  GROUP BY zone, cuisine
),
zone_analysis AS (
  SELECT 
    d.zone,
    d.cuisine,
    d.order_count,
    c.num_restaurants
  FROM zone_demand d
  JOIN zone_competition c 
  ON d.zone = c.zone AND d.cuisine = c.cuisine
)
SELECT  * from zone_analysis
order by d.order_count desc;

/* RESTAURANTS HAVING HIGH DELIVERY TIME */


SELECT 
  r.restaurant_id,
  r.restaurant_name,
  AVG(o.delivery_time_taken) AS avg_delivery_time
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY 
  r.restaurant_id,
  r.restaurant_name
HAVING AVG(o.delivery_time_taken) >30 
ORDER BY avg_delivery_time DESC;


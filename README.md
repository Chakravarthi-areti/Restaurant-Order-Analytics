# Restaurant-Order-Analytics

![TITLE IMAGE](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*2gu6C44mv7JlantW3iKfyQ.png)


# PROBLEM STATEMENT 

•A few restaurants reviewed their sales and discovered a decline. To gain deeper insights, 
they approached an Analytics Firm and explained their problem.

•The company assigned the task to a skilled data analyst to identify the reasons behind the decline in sales.


# DATA MODEL 

![DATA MODEL](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*gZFiKcxNi_0CK9EytXhLXg.png)



Now we will Analyze the data and find the insights from it using MYSQL workbench


# 1.Repeated customer sales percentage in total amount

**MYSQL QUERY**


```sql

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
```

OUTPUT :

![REPEATED CUSTOMER SALES%](https://miro.medium.com/v2/resize:fit:720/format:webp/1*Ctv1Hh5SV7SAhz0Iek7qUg.png)



# 2.Restaurant With Less Efficiency Score

**MYSQL QUERY**

```sql 

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

```

OUTPUT :

![RESTAURANT_LESS_EFFICIENCY SCORE](https://miro.medium.com/v2/resize:fit:640/format:webp/1*M39FKaGmR4JqSBHQpzr0kQ.png)



# 3.Most Loyal Customers

**MYSQL QUERY**

```sql 

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

```

OUTPUT :

![MOST LOYAL CUSTOMERS](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*V-6EIuDkDELKeAFrtYgEjw.png)


# 4.Restaurants having good cuisines and good food rating, delivery rating

**MYSQL QUERY**

```sql 

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
```

OUTPUT :

![](https://miro.medium.com/v2/resize:fit:562/format:webp/1*890ZnirR7Q3SfEY5yq2-MA.png)



# 5.SALES WITH RESPECT TO A DAY 

**MYSQL QUERY**

```sql 


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

```

OUTPUT : 

![SALES IN A DAY](https://miro.medium.com/v2/resize:fit:720/format:webp/1*FCbjRqo6mo2UdXhReCX8PQ.png)



# 6.RESTAURANTS IN HIGHLY PROFITABLE ZONE 

**MYSQL QUERY**

```sql 


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

```

OUTPUT :

![RESTAURANT IN HIGLY PROFIT ZONE](https://miro.medium.com/v2/resize:fit:346/format:webp/1*zsluasN6bntZJyngo3Aghg.png)



# 7.RESTAURANTS WITH VARIANCE IN THE RATING 

**MYSQL QUERY**

```sql

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

```

OUTPUT :

![RESTAURANT WITH VARIANCE](https://miro.medium.com/v2/resize:fit:640/format:webp/1*IcEofNSiG48cAHf9W3fSqw.png)


# 8.RESTAURANTS AND THEIR ORDER COUNT 

**MYSQL QUERY**

```sql 

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

```

OUTPUT :

![RESTAURANTS_ORDER_COUNT](https://miro.medium.com/v2/resize:fit:640/format:webp/1*sAcwpz1qV4sgHA11wlP6TA.png)



# 9.RESTAURANTS WITH HIGH DELIVERY TIME 

**MYSQL QUERY** 


```sql 


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


```

OUTPUT :

![DELIVERY>30](https://miro.medium.com/v2/resize:fit:640/format:webp/1*IJ2czBlv2QgN9upnCCaiXw.png)





# From all the above Observations We can Say that :

•Restaurants should improve their order delivery time so that customers get satisfied over delivery

•Restaurants should focus on AfterNoon and Night sales to attract more customers

•Should Maintain their food Taste consistently so that the Loyal customer will definitely increases

•Chew Restaurant ,Ruchi Restaurant and AMN Restaurant should focus of food rating



# Suggestion For a New Restaurant



There is Higher Chance to increase the sales if we Open a South Indian restaurant in zone D


## Click the below image for Project Presentation 

[![Click the image for Project Presentation](https://github.com/Chakravarthi-areti/Restaurant-Order-Analytics_Using_MYSQL/blob/main/Restaurant_ord_pre_scrsht.png)](https://www.linkedin.com/feed/update/urn:li:activity:7300382982920359937/)















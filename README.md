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



# Restaurant With Less Efficiency Score

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











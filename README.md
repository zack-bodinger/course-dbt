# Analytics engineering with dbt

Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

## License

Apache 2.0

## Week 4 Project

**Question 1a:** How are our users moving through the product funnel?


```sql
SELECT * FROM snapshots.daily_funnel_stats_snapshot
```
**Answer:**
It seems as though over 80% of sessions that contain a page view end up adding a product to their cart; however, only 62% end up actually checking out. 

**Question 1b:** Which steps in the funnel have largest drop off points?

**Answer:**
Based on the above, it seems that our biggest drop off is from users viewing a page to actually adding something to their cart during a session. Both drop-offs are worth trying to minimize, but this presents a big opportunity. 

**Question 2:**
If your organization is using dbt, what are 1-2 things you might do differently / recommend to your organization based on learning from this course?

**Answer:**
I think I may build out some more elaborate and thorough testing, as well as try to up my macro game now that I've practiced both a little more thoroughly :)

**Question 3:**
How would you go about setting up a production/scheduled dbt run of your project in an ideal state?

**Answer:**
- First, I would run dbt snapshot to populate my snapshots with new information
- Then, I would run dbt run across all models on a nightly basis, presuming daily updates on orders were good enough for my team. 
- If they needed more urgent runs, I could use tags to run certain models more frequently. 
- Then I would run dbt test across all models to address any errors and hook this up to Slack

---

## Week 3 Project

**Question 1:** What is our overall conversion rate
```sql
--overall conversion rate is # sessions with checkout / # sessions total
SELECT
  ROUND(COUNT(DISTINCT CASE 
                  WHEN is_checkout THEN session_id
                  ELSE NULL
                  END)::numeric / COUNT(DISTINCT session_id) * 100, 2) AS conversion_rate
FROM dbt_zack_b.fact_sessions
```
**Answer:** 62.46% 
| valid_at_timestamp_utc | prct_sessions_with_page_view | prct_sessions_with_add_to_cart | prct_sessions_with_checkout |
| -------------- | ------------------ | ----------| ----------|
| 2022-04-04T16:35:54.018381Z | 100.00 | 80.80 | 62.46 | 

---

**Question 2:** What is our product conversion rate
```sql
--product conversion rate is # sessions with checkout / # sessions total by product
SELECT
  product_id,
  name,
  ROUND(COUNT(DISTINCT CASE 
                  WHEN is_checkout THEN session_id
                  ELSE NULL
                  END)::numeric / COUNT(DISTINCT session_id) * 100, 2) AS conversion_rate
FROM dbt_zack_b.fact_sessions
GROUP BY 1,2
ORDER BY 3 DESC
```

| product_id | name | conversion_rate |
| -------------- | ------------------ | ----------| 
| fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80 | String of pearls | 60.94 | 
| 74aeb414-e3dd-4e8a-beef-0fa45225214d | Arrow Head | 55.56 | 
| c17e63f7-0d28-4a95-8248-b01ea354840e | Cactus | 54.55 | 
| b66a7143-c18a-43bb-b5dc-06bb5d1d3160 | ZZ Plant | 53.97 | 
| 689fb64e-a4a2-45c5-b9f2-480c2155624d | Bamboo | 53.73 | 
| 579f4cd0-1f45-49d2-af55-9ab2b72c3b35 | Rubber Plant | 51.85 | 
| be49171b-9f72-4fc9-bf7a-9a52e259836b | Monstera | 51.02 | 
| b86ae24b-6f59-47e8-8adc-b17d88cbd367 | Calathea Makoyana | 50.94 | 
| e706ab70-b396-4d30-a6b2-a1ccf3625b52 | Fiddle Leaf Fig | 50 | 
| 5ceddd13-cf00-481f-9285-8340ab95d06d | Majesty Palm | 49.25 | 
| 615695d3-8ffd-4850-bcf7-944cf6d3685b | Aloe Vera | 49.23 | 
| 35550082-a52d-4301-8f06-05b30f6f3616 | Devil's Ivy | 48.89 | 
| 55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3 | Philodendron | 48.39 | 
| a88a23ef-679c-4743-b151-dc7722040d8c | Jade Plant | 47.83 | 
| 64d39754-03e4-4fa0-b1ea-5f4293315f67 | Spider Plant | 47.46 | 
| 5b50b820-1d0a-4231-9422-75e7f6b0cecf | Pilea Peperomioides | 47.46 | 
| 37e0062f-bd15-4c3e-b272-558a86d90598 | Dragon Tree | 46.77 | 
| d3e228db-8ca5-42ad-bb0a-2148e876cc59 | Money Tree | 46.43 | 
| c7050c3b-a898-424d-8d98-ab0aaad7bef4 | Orchid | 45.33 | 
| 05df0866-1a66-41d8-9ed7-e2bbcddd6a3d | Bird of Paradise | 45 | 
| 843b6553-dc6a-4fc4-bceb-02cd39af0168 | Ficus | 42.65 | 
| bb19d194-e1bd-4358-819e-cd1f1b401c0c | Birds Nest Fern | 42.31 | 
| 80eda933-749d-4fc6-91d5-613d29eb126f | Pink Anthurium | 41.89 | 
| e2e78dfc-f25c-4fec-a002-8e280d61a2f2 | Boston Fern | 41.27 | 
| 6f3a3072-a24d-4d11-9cef-25b0b5f8a4af | Alocasia Polly | 41.18 | 
| e5ee99b6-519f-4218-8b41-62f48f59f700 | Peace Lily | 40.91 | 
| e18f33a6-b89a-4fbc-82ad-ccba5bb261cc | Ponytail Palm | 40 | 
| e8b6528e-a830-4d03-a027-473b411c7f02 | Snake Plant | 39.73 | 
| 58b575f2-2192-4a53-9d21-df9a0c14fc25 | Angel Wings Begonia | 39.34 | 
| 4cda01b9-62e2-46c5-830f-b7f262a58fb1 | Pothos | 34.43 | 

---
**Question 3:** Why might certain products be converting at higher/lower rates than others? Note: we don't actually have data to properly dig into this, but we can make some hypotheses. 
- Price
- Lifespan of the plant (shown on page)
- Photo of the plant (shown on page)
- Reviews
- Climate/Upkeep requirements indicated on the page

---

## Week 2 Project

**Question 1:** What is our user repeat rate?
```sql
-- Start with a breakdown of unique purchases per user
WITH purchases_per_user AS (
SELECT 
  user_id
  , COUNT(DISTINCT order_id) AS purchase_count
  FROM dbt_zack_b.cln_orders
  GROUP BY 1
)

-- Don't forget to cast to numeric so quotient is a decimal and not an integer!
SELECT 
  ROUND(COUNT(DISTINCT CASE 
                  WHEN purchase_count > 1
                  THEN user_id
                  ELSE NULL
                  END)::numeric / COUNT(*) * 100, 2) AS repeat_user_rate
  FROM purchases_per_user
```
**Answer:** 79.84% 

---

**Question 2:** Examination of repeat purchasers
```sql
-- Start with a list of repeat purchasers
-- Start with a summary of user account ages in months
WITH users_age_summary AS (
  SELECT
    users.user_id
    , users.created_at
    FROM dbt_zack_b.cln_users AS users
), order_quantities_summary AS (
--Look at quantities per order
  SELECT
    order_id
    , SUM(quantity) AS order_quantity
    FROM dbt_zack_b.cln_order_items
    GROUP BY 1
), users_first_order_summary AS (
-- Look at stats related to a user's first purchase
  SELECT
    user_id
    , order_id
    , has_promo_code
    , order_total
    , created_at
    , is_repeat_purchaser
    FROM (SELECT
            orders.user_id
            , orders.order_id
            , orders.promo_id IS NOT NULL AS has_promo_code
            , orders.order_total
            , orders.created_at
            , COUNT(orders.order_id) OVER (PARTITION BY orders.user_id) > 1 AS is_repeat_purchaser
            , ROW_NUMBER() OVER (PARTITION BY orders.user_id ORDER BY orders.created_at) AS order_order
            FROM dbt_zack_b.cln_orders AS orders) user_orders
    WHERE order_order = 1
)
--Combine the three!
SELECT 
  users_first_order_summary.is_repeat_purchaser
  , ROUND(AVG(users_first_order_summary.order_total)::numeric, 2) AS avg_first_order_total
  , ROUND(AVG(users_first_order_summary.has_promo_code::integer) * 100, 2)  AS avg_has_promo_code_first_prct
  , ROUND(AVG(ROUND((EXTRACT(EPOCH FROM users_first_order_summary.created_at - users_age_summary.created_at)/60/60/24/12)::numeric, 2))::numeric, 2) AS avg_account_age_first_order_months
  , ROUND(AVG(order_quantities_summary.order_quantity)::numeric, 2) AS avg_first_order_quantity
  FROM users_first_order_summary
  INNER JOIN users_age_summary
  ON users_first_order_summary.user_id = users_age_summary.user_id
  INNER JOIN order_quantities_summary
  ON users_first_order_summary.order_id = order_quantities_summary.order_id
  GROUP BY is_repeat_purchaser
```

**Results:**
| is_repeat_purchaser | avg_first_order_total | avg_has_promo_code_first_prct | avg_account_age_first_order_months | avg_first_order_quantity |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| false | 274.48 | 4.00 | 18.50 | 5.68 |
| true | 232.91 | 13.13 | 18.25 | 5.75 |

---

**Question 2B:** What are good indicators of a user who will likely purchase again? 

**Answer:** It seems like at a cursory examination, applying a promo code on a first purchase is a decent indicator that someone will purchase again. 

---

**Question 2C:** What about indicators of users who are likely NOT to purchase again? 

**Answer:** Again, very cursorily, it seems that users who spent > $270 on average on an initial purchase are less likely to have a secondary purchase

---

**Question 2D:** If you had more data, what features would you want to look into to answer this question?

**Answer:** 
- Where users came to our site from
- User demographics (sex, ethnicity, age, job) 
- Category of products purchased in initial order (houseplant vs. flower vs. gardening tools, etc.)
- Device used to place order (mobile vs. pc)
- Climate of the user address and trying to tie that with plant types purchased
- Climate segmented by time of year (avg. temp/rainfall/humidity) vs. types of plants purchased and their corresponding growth requirements if outdoor plants
- Mapping time of year purchased with holidays to see if most of our one-off purchasers were around holidays

---

**Question 3:** Explain the marts models you added. Why did you organize the models in the way you did?

**Answer:** I added an intermediate `user_addresses` model since this was a common join I was doing for the later marts. Otherwise, the marts I made were the ones suggested, with some additional summary fields/aggregations added in ways that might be helpful.

---

**Question 4:** What assumptions did you make about each model?

**Answer:** I made the following assumptions:
- All users in events and orders were in the users model
- All products in the events and order_items were in the products model
- All promos in orders were in the promos model
- All addresses in orders and users were in the addresses model
- Zipcode should always be 5 digits long
- All monetary amounts, quantities and discounts were never negative
- Email should conform to a pattern that is *@*.*
- Phone number should conform to a pattern that is ###-###-####
- Shipping_service and tracking_id should not be null if order status is 'shipped' or 'delivered'
- Delivered_at should not be null if order status is 'delivered'
- Order_id should not be null in events of type 'checkout' or 'package_shipped'
- Product_id should not be null in events of type 'add_to_cart' or 'page_view'
- Primary keys should be unique within tables (address_id in addresses, user_id in users, event_id in events, promo_id in promos, product_id in products)

---

**Question 5:** Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?

**Answer:** 
- Data cleaned: since zipcode was stored as a number, I left-padded it with zeros to 5 characters long after converting it to a string.
- Incorrect assumption: estimated_delivery_at would not be null when orders.status was either 'shipped' or 'delivered'... This proved not to be the case and so I removed the test rather than try to clean the null fields

---

**Question 6:** Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.

**Answer:** As the lecture notes suggested, I would configure dbt to run tests at regular cadences depending on the frequency with which the underlying models were expected to be updated. From there, I would configure it to send out slack alerts if any tests produced errors. 

---

## Week 1 Project

---

**Question 1:** How many users do we have?
```sql
SELECT
    COUNT(DISTINCT user_id)
    FROM dbt_zack_b.cln_users
```
**Answer:** 130

---

**Question 2:** How many orders do we receive per hour?
```sql
-- Start with an hourly breakdown of # hours created
WITH orders_per_hour AS (
SELECT 
  DATE_TRUNC('hour', created_at) AS hour_order_created_at
  , COUNT(DISTINCT order_id) AS count_orders
  FROM dbt_zack_b.cln_orders
  GROUP BY 1
)

SELECT 
  ROUND(AVG(count_orders), 2) AS avg_hours_per_hour
  FROM orders_per_hour
```
**Answer:** 7.52

---

**Question 3:** On average, how long does an order take from being placed to being delivered?
```sql
-- Start with a breakdown of seconds to deliver an order
WITH time_to_place_orders AS (
SELECT 
  EXTRACT(EPOCH FROM delivered_at - created_at) AS seconds_to_deliver
  FROM dbt_zack_b.cln_orders
)

SELECT 
  ROUND((AVG(seconds_to_deliver) / 60 / 60)::numeric, 2) AS avg_hours_to_deliver
  FROM time_to_place_orders
```
**Answer:** 93.4 Hours

---

**Question 4:** How many users have only made one purchase? Two purchases? Three+ purchases?
```sql
-- Start with a breakdown of orders placed per user
WITH orders_per_user AS (
SELECT 
  user_id,
  COUNT(DISTINCT order_id) AS count_orders
  FROM dbt_zack_b.cln_orders
  GROUP BY user_id
)

SELECT 
  CASE
    WHEN count_orders < 3
    THEN count_orders::text
    ELSE '3+'
  END AS count_orders_group,
  COUNT(DISTINCT user_id) AS count_users
  FROM orders_per_user
  GROUP BY 1
```
**Answer:**
| count_orders_group | count_users |
| ----------- | ----------- |
| 1 | 25 |
| 2 | 28 |
| 3+ | 71 |

---

**Question 5:** On average, how many unique sessions do we have per hour?
```sql
-- Start with a breakdown of unique sessions per hour
WITH sessions_per_hour AS (
SELECT 
  DATE_TRUNC('hour', created_at) AS hour_created_at,
  COUNT(DISTINCT session_id) AS count_sessions
  FROM dbt_zack_b.cln_events
  GROUP BY 1
)

SELECT 
  ROUND(AVG(count_sessions), 2)
  FROM sessions_per_hour
```
**Answer:** 16.33
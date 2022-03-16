Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

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
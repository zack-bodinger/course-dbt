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
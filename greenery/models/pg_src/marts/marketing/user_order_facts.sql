{{
  config(
    materialized='table'
  )
}}

SELECT
    users.first_name
    , users.last_name
    , users.email
    , users.phone_number
    , users.created_at AS user_created_at
    , users.updated_at
    , users.address_id
    , users.address
    , users.zipcode
    , users.state
    , users.country
    , STRING_AGG(CASE WHEN orders.status = 'preparing' THEN order_id ELSE NULL END, ', ') AS unshipped_orders
    , STRING_AGG(CASE WHEN orders.status = 'shipped' THEN order_id ELSE NULL END, ', ') AS undelivered_orders
    , ROUND(AVG(orders.order_total)::numeric, 2) AS avg_order_total
    , COUNT(DISTINCT order_id) AS count_orders
FROM {{ ref('user_addresses') }} users
LEFT JOIN {{ ref('cln_orders') }} orders
  ON users.user_id = orders.user_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11
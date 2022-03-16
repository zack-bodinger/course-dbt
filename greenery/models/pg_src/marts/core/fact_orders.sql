{{
  config(
    materialized='table'
  )
}}

SELECT
    orders.order_id
    , orders.user_id
    , orders.promo_id
    , orders.address_id
    , orders.created_at AS order_created_at
    , orders.order_cost
    , orders.shipping_cost
    , orders.order_total
    , orders.tracking_id
    , orders.shipping_service
    , orders.estimated_delivery_at
    , orders.delivered_at
    , ROUND(EXTRACT(EPOCH FROM (orders.delivered_at - orders.created_at))::numeric / 60 / 60, 2) AS hours_to_deliver
    , ROUND(EXTRACT(EPOCH FROM (orders.delivered_at - orders.estimated_delivery_at))::numeric / 60 / 60, 2) AS hours_delivered_later_than_expected
    , orders.status AS order_status
    , promos.discount
    , promos.status AS promo_status
    , users.first_name
    , users.last_name
    , users.email
    , users.phone_number
    , users.created_at AS user_created_at
    , users.updated_at
    , users.address
    , users.zipcode
    , users.state
    , users.country
FROM {{ ref('cln_orders') }} orders
LEFT JOIN {{ ref('cln_promos') }} promos
  ON orders.promo_id = promos.promo_id
LEFT JOIN {{ ref('user_addresses') }} users
  ON orders.user_id = users.user_id
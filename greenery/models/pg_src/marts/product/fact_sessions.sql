{{
  config(
    materialized='table'
  )
}}

SELECT
    events.session_id
    , events.user_id
    , COALESCE(events.product_id, order_items.product_id) AS product_id
    , products.name
    , products.price
    , products.inventory
    , {{has_column_values(ref('cln_events'),'event_type')}}
FROM {{ ref('cln_events') }} events
LEFT JOIN {{ ref('cln_order_items') }} order_items
    ON events.order_id = order_items.order_id
LEFT JOIN {{ ref('cln_products') }} products
    ON COALESCE(events.product_id, order_items.product_id) = products.product_id
{{ dbt_utils.group_by(n=6) }}
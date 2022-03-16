{{
  config(
    materialized='table'
  )
}}

SELECT
    events.event_id
    , events.session_id
    , events.user_id
    , events.page_url
    , events.created_at AS event_created_at
    , events.product_id
    , products.name
    , products.price
    , products.inventory
    , users.first_name
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
FROM {{ ref('cln_events') }} events
INNER JOIN {{ ref('user_addresses') }} users
    ON events.user_id = users.user_id
INNER JOIN {{ ref('cln_products') }} products
    ON events.product_id = products.product_id
WHERE events.event_type = 'page_view'
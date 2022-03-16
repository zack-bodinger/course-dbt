{{
  config(
    materialized='view'
  )
}}

SELECT
    users.user_id
    , users.first_name
    , users.last_name
    , users.email
    , users.phone_number
    , users.created_at
    , users.updated_at
    , users.address_id
    , addresses.address
    , addresses.zipcode
    , addresses.state
    , addresses.country
FROM {{ ref('cln_users') }} users
LEFT JOIN {{ ref('cln_addresses') }} addresses
  ON users.address_id = addresses.address_id
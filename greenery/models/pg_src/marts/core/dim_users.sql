{{
  config(
    materialized='table'
  )
}}

SELECT
    first_name
    , last_name
    , first_name || ' ' || last_name AS full_name
    , email
    , phone_number
    , created_at AS user_created_at
    , updated_at
    , address_id
    , address
    , zipcode
    , state
    , country
FROM {{ ref('user_addresses') }}
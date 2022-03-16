
WITH source AS (
    SELECT *
        FROM {{ source('pg', 'addresses') }}
)

SELECT 
    address_id
    , address
    , LPAD(zipcode::text, 5, '0') AS zipcode
    , state
    , country
FROM source
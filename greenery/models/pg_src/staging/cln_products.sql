
WITH source AS (
    SELECT *
        FROM {{ source('pg', 'products') }}
)

SELECT 
    product_id
    , name
    , price
    , inventory
FROM source
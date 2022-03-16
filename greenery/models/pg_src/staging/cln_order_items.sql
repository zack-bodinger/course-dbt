
WITH source AS (
    SELECT *
        FROM {{ source('pg', 'order_items') }}
)

SELECT 
    order_id
    , product_id
    , quantity
FROM source
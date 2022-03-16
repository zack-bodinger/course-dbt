
WITH source AS (
    SELECT *
        FROM {{ source('pg', 'promos') }}
)

SELECT 
    promo_id
    , discount
    , status
FROM source
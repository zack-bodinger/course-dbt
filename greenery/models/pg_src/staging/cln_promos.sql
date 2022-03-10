SELECT 
    promo_id
    , discount
    , status
FROM {{ source('pg', 'promos') }}
SELECT 
    order_id
    , product_id
    , quantity
FROM {{ source('pg', 'order_items') }}
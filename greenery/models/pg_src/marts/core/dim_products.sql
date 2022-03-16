WITH day_series AS (
  --start with a table of one row per product per day, up to the last day of events listed
  SELECT 
    DATE_TRUNC('day', (SELECT MAX(DATE_TRUNC('day',created_at)) FROM {{ ref( 'cln_events' ) }})) - (interval '1' day * series.num) AS start_day
    , product_id
  FROM generate_series(0,36500) AS series(num)
  CROSS JOIN {{ ref( 'cln_products' ) }}
), product_start_days AS (
  --find the first day a product has an event listed as a proxy for when it was first offered
  SELECT
    events.product_id
    , MIN(DATE_TRUNC('day', events.created_at)) AS first_day
  FROM {{ ref( 'cln_events' ) }} AS events
  GROUP BY 1
), quantity_per_day AS (
  --find the total amount of each product ordered each day
  SELECT
    order_items.product_id
    , DATE_TRUNC('day', orders.created_at) AS day_ordered
    , product_start_days.first_day
    , SUM(order_items.quantity) AS quantity_ordered_per_day
  FROM {{ ref( 'cln_order_items' ) }} AS order_items
  INNER JOIN {{ ref( 'cln_orders' ) }} AS orders
  ON order_items.order_id = orders.order_id
  INNER JOIN product_start_days
  ON order_items.product_id = product_start_days.product_id
  GROUP BY 1, 2, 3
), quantity_per_day_including_empty AS (
  --include days where a product wasn't ordered as a 0 quantity
  --be sure to only look at days on or after a product was first listed
  SELECT 
    quantity_per_day.product_id
    , quantity_per_day.first_day
    , day_series.start_day
    , COALESCE(quantity_per_day.quantity_ordered_per_day, 0) AS quantity_ordered_per_day
  FROM day_series
  LEFT JOIN quantity_per_day
  ON day_series.product_id = quantity_per_day.product_id
  AND day_series.start_day = quantity_per_day.day_ordered
  AND day_series.start_day >= quantity_per_day.first_day 
), avg_quantity_per_day AS (
  --find average quantity sold per day
  SELECT 
    product_id
    , first_day AS first_event_day
    , SUM(quantity_ordered_per_day) AS total_sold
    , ROUND(AVG(quantity_ordered_per_day), 1) AS avg_ordered_per_day
  FROM quantity_per_day_including_empty
  GROUP BY 1, 2
)

SELECT
    products.product_id
    , products.name
    , products.price
    , products.inventory
    , avg_quantity_per_day.avg_ordered_per_day
    , avg_quantity_per_day.total_sold
    , avg_quantity_per_day.first_event_day
FROM {{ ref( 'cln_products' ) }} AS products
INNER JOIN avg_quantity_per_day
ON products.product_id = avg_quantity_per_day.product_id
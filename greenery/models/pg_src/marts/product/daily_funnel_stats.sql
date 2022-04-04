{{
  config(
    materialized='table'
  )
}}

SELECT
    CURRENT_TIMESTAMP AS valid_at_timestamp_utc
    , ROUND(COUNT(DISTINCT CASE 
                        WHEN is_page_view OR is_add_to_cart OR is_checkout 
                        THEN session_id 
                        ELSE NULL 
                    END)::numeric / COUNT(DISTINCT session_id)::numeric * 100, 2) AS prct_sessions_with_page_view
    , ROUND(COUNT(DISTINCT CASE 
                        WHEN is_add_to_cart OR is_checkout 
                        THEN session_id 
                        ELSE NULL 
                    END)::numeric / COUNT(DISTINCT session_id)::numeric * 100, 2) AS prct_sessions_with_add_to_cart
    , ROUND(COUNT(DISTINCT CASE 
                        WHEN is_checkout 
                        THEN session_id 
                        ELSE NULL 
                    END)::numeric / COUNT(DISTINCT session_id)::numeric * 100, 2) AS prct_sessions_with_checkout
FROM {{ ref('fact_sessions') }} events
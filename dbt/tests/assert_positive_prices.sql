SELECT *
FROM {{ ref('stg_order_items') }}

WHERE price < 0
   OR freight_value < 0
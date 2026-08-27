SELECT
    order_id,
    COUNT(*) AS item_count,
    COUNT(DISTINCT product_id) AS unique_product_count,
    COUNT(DISTINCT seller_id) AS seller_count,
    SUM(price) AS product_value,
    SUM(freight_value) AS freight_value,
    SUM(price + freight_value) AS gross_order_value
FROM {{ ref('stg_order_items') }}
GROUP BY order_id
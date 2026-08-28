WITH source_ AS (

    SELECT *
    FROM {{ source('raw', 'order_items') }}

),

cleaned AS (

    SELECT
        TRIM(order_id) AS order_id,
        order_item_id,
        TRIM(product_id) AS product_id,
        TRIM(seller_id) AS seller_id,

        CAST(shipping_limit_date AS TIMESTAMP_NTZ) AS shipping_limit_date,
        CAST(price AS DECIMAL(10,2)) AS price,
        CAST(freight_value AS DECIMAL(10,2)) AS freight_value

    FROM source_

),

final AS (

    SELECT
        *,

        price + freight_value AS total_item_cost,

        freight_value / NULLIF(price, 0) AS freight_to_price_ratio

    FROM cleaned

)

SELECT *
FROM final
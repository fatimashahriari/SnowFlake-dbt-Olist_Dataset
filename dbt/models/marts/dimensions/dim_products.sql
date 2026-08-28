WITH products AS (

    SELECT *
    FROM {{ ref('stg_products') }}

),

categories AS (

    SELECT *
    FROM {{ ref('stg_products_category_name') }}

),

final AS (

    SELECT
        p.product_id,

        p.product_category_name,
        c.product_category_name_english,

        p.product_name_length,
        p.product_description_length,
        p.photo_count,

        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,

        p.product_volume_cm3,
        p.product_weight_category

    FROM products p

    LEFT JOIN categories c
        ON p.product_category_name = c.product_category_name

)

SELECT *
FROM final
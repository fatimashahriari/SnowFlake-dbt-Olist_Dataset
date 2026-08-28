WITH cleaned AS (

    SELECT
        TRIM(product_id) AS product_id,
        LOWER(TRIM(product_category_name)) AS product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty AS photo_count,

        CAST(product_weight_g AS INTEGER) AS product_weight_g,
        CAST(product_length_cm AS INTEGER) AS product_length_cm,
        CAST(product_height_cm AS INTEGER) AS product_height_cm,
        CAST(product_width_cm AS INTEGER) AS product_width_cm

    FROM {{ source('raw', 'products') }}

),

final AS (

    SELECT
        *,

        product_length_cm
            * product_height_cm
            * product_width_cm
            AS product_volume_cm3,

        CASE
            WHEN product_weight_g IS NULL
                THEN NULL
            WHEN product_weight_g < {{ var('light_weight') }}
                THEN 'light'
            WHEN product_weight_g < {{ var('heavy_weight') }}
                THEN 'medium'
            ELSE 'heavy'
        END AS product_weight_category

    FROM cleaned

)

SELECT *
FROM final
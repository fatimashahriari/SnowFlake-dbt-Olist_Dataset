SELECT
    LOWER(TRIM(product_category_name))
        AS product_category_name,

    INITCAP(
        REPLACE(
            TRIM(product_category_name_english),
            '_',
            ' '
        )
    ) AS product_category_name_english

FROM {{ source('raw', 'products_category_name') }}
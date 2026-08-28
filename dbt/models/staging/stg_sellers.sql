WITH source_ AS (
    SELECT *
    FROM {{ source('raw', 'sellers') }}
),

cleaned AS (
    SELECT
        TRIM(seller_id) AS seller_id,
        seller_zip_code_prefix,
        UPPER(TRIM(seller_city)) AS seller_city,
        UPPER(TRIM(seller_state)) AS seller_state
    FROM source_
)

SELECT *
FROM cleaned
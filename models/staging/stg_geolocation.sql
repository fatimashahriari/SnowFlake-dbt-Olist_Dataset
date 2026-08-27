WITH source_ AS (
    SELECT *
    FROM {{source('raw','geolocation')}}
),
cleaned AS (
    SELECT 
        zip_code_prefi,
        CAST(lat AS DECIMAL(10,8)) AS lat,
        CAST(lng AS DECIMAL(11,8)) AS lng,
        LOWER(TRIM(city)) AS city,
        UPPER(TRIM(state)) AS state_
    FROM source_
)
SELECT *
FROM cleaned
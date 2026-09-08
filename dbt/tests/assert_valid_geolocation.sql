SELECT *
FROM {{ ref('stg_geolocation') }}

WHERE lat NOT BETWEEN -90 AND 90
   OR lng NOT BETWEEN -180 AND 180
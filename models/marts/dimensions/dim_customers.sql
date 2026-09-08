WITH customers AS (

    SELECT *
    FROM {{ ref('stg_customers') }}

),

final AS (

    SELECT
        customer_unique_id,

        MAX(customer_city) AS customer_city,
        MAX(customer_state) AS customer_state,
        MAX(customer_zip_code_prefix) AS customer_zip_code_prefix

    FROM customers

    GROUP BY customer_unique_id

)

SELECT *
FROM final
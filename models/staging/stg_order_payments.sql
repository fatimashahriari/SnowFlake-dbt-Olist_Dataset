WITH source_ AS (
    SELECT *
    FROM {{source('raw','order_payments')}}
),
cleaned AS (
    SELECT 
        TRIM(order_id) AS order_id,
        CAST(payment_sequential AS INTEGER) AS payment_sequential,
        LOWER(TRIM(payment_type)) AS payment_type,
        CAST(payment_installments AS INTEGER) AS payment_installments,
        CAST(payment_value AS DECIMAL(10,2)) AS payment_value
    FROM source_
),
final AS (
    SELECT *,
        CASE
            WHEN payment_installments > 1 
            THEN TRUE
            ELSE FALSE
        END AS used_installments
    FROM cleaned
)
SELECT *
FROM final
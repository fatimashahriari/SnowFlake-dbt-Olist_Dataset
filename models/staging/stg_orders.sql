WITH source_ AS (

    SELECT *
    FROM {{ source('raw', 'orders') }}

),

cleaned AS (

    SELECT
        TRIM(order_id) AS order_id,
        TRIM(customer_id) AS customer_id,
        LOWER(TRIM(order_status)) AS order_status,

        CAST(order_purchase_timestamp AS TIMESTAMP_NTZ) AS order_purchase_timestamp,
        CAST(order_approved_at AS TIMESTAMP_NTZ) AS order_approved_at,
        CAST(order_delivered_carrier_date AS TIMESTAMP_NTZ) AS order_delivered_carrier_date,
        CAST(order_delivered_customer_date AS TIMESTAMP_NTZ) AS order_delivered_customer_date,
        CAST(order_estimated_delivery_date AS TIMESTAMP_NTZ) AS order_estimated_delivery_date,

        DATEDIFF(
            'day',
            order_purchase_timestamp,
            order_delivered_customer_date
        ) AS delivery_days,

        DATEDIFF(
            'hour',
            order_purchase_timestamp,
            order_approved_at
        ) AS approval_hours,

        DATEDIFF(
            'day',
            order_approved_at,
            order_delivered_carrier_date
        ) AS carrier_processing_days,

        GREATEST(
            DATEDIFF(
                'day',
                order_estimated_delivery_date,
                order_delivered_customer_date
            ),
            0
        ) AS delivery_delay_days,

        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date
                THEN TRUE
            ELSE FALSE
        END AS delivered_on_time,

        DAYOFWEEK(order_purchase_timestamp) AS purchase_day_of_week,
        HOUR(order_purchase_timestamp) AS purchase_hour

    FROM source_

)

SELECT *
FROM cleaned
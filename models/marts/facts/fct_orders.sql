{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge'
    )
}}

WITH orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

customers AS (

    SELECT *
    FROM {{ ref('stg_customers') }}

),

items AS (

    SELECT *
    FROM {{ ref('int_order_items_aggregated') }}

),

payments AS (

    SELECT *
    FROM {{ ref('int_order_payments_aggregated') }}

),

reviews AS (

    SELECT *
    FROM {{ ref('int_reviews_aggregated') }}

),

final AS (

    SELECT

        -- Keys
        o.order_id,
        o.customer_id,
        c.customer_unique_id,

        -- Order information
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        -- Item metrics
        COALESCE(i.item_count, 0) AS item_count,
        COALESCE(i.unique_product_count, 0) AS unique_product_count,
        COALESCE(i.seller_count, 0) AS seller_count,

        COALESCE(i.product_value, 0) AS product_value,
        COALESCE(i.freight_value, 0) AS freight_value,
        COALESCE(i.gross_order_value, 0) AS gross_order_value,

        -- Payment metrics
        COALESCE(p.payment_count, 0) AS payment_count,
        COALESCE(p.total_payment_value, 0) AS total_payment_value,
        COALESCE(p.max_installments, 0) AS max_installments,

        -- Review metrics
        r.avg_review_score,
        COALESCE(r.review_count, 0) AS review_count,

        -- Delivery metrics from staging
        o.delivery_days,
        o.approval_hours,
        o.carrier_processing_days,
        o.delivery_delay_days,
        o.delivered_on_time,

        -- Time dimensions
        o.purchase_day_of_week,
        o.purchase_hour

    FROM orders o

    LEFT JOIN customers c
        ON o.customer_id = c.customer_id

    LEFT JOIN items i
        ON o.order_id = i.order_id

    LEFT JOIN payments p
        ON o.order_id = p.order_id

    LEFT JOIN reviews r
        ON o.order_id = r.order_id

)

SELECT *
FROM final
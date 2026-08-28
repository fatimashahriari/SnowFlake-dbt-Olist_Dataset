-- ============================================================
-- OLIST DBT PROJECT - SNOWFLAKE RAW SETUP
-- ============================================================
-- Creates:
--   1. Database
--   2. Warehouse
--   3. Schemas
--   4. Internal stage
--   5. RAW tables
--   6. Loads CSV files from stage
-- ============================================================


-- ============================================================
-- 1. DATABASE AND WAREHOUSE
-- ============================================================

CREATE DATABASE IF NOT EXISTS DBT_PROJECT;

CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;


-- ============================================================
-- 2. SCHEMAS
-- ============================================================

CREATE SCHEMA IF NOT EXISTS DBT_PROJECT.RAW;
CREATE SCHEMA IF NOT EXISTS DBT_PROJECT.STAGING;
CREATE SCHEMA IF NOT EXISTS DBT_PROJECT.MARTS;


-- ============================================================
-- 3. STAGE
-- ============================================================

CREATE STAGE IF NOT EXISTS DBT_PROJECT.PUBLIC.MY_STAGE;


-- ============================================================
-- 4. SET SESSION CONTEXT
-- ============================================================

USE WAREHOUSE COMPUTE_WH;
USE DATABASE DBT_PROJECT;
USE SCHEMA RAW;


-- ============================================================
-- 5. OPTIONAL CHECKS
-- ============================================================

SHOW SCHEMAS IN DATABASE DBT_PROJECT;
SHOW STAGES IN SCHEMA DBT_PROJECT.PUBLIC;


-- ============================================================
-- 6. CUSTOMERS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.CUSTOMERS (
    customer_id STRING NOT NULL,
    customer_unique_id STRING NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city STRING,
    customer_state STRING
);

COPY INTO DBT_PROJECT.RAW.CUSTOMERS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_customers_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
);

SELECT *
FROM DBT_PROJECT.RAW.CUSTOMERS
LIMIT 10;


-- ============================================================
-- 7. GEOLOCATION
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.GEOLOCATION (
    zip_code_prefi INTEGER,
    lat DECIMAL(10,8),
    lng DECIMAL(11,8),
    city STRING(80),
    state STRING(3),

    CONSTRAINT chk_lat
        CHECK (lat BETWEEN -90 AND 90),

    CONSTRAINT chk_lng
        CHECK (lng BETWEEN -180 AND 180)
);

COPY INTO DBT_PROJECT.RAW.GEOLOCATION
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_geolocation_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
);

SELECT *
FROM DBT_PROJECT.RAW.GEOLOCATION
LIMIT 10;


-- ============================================================
-- 8. ORDER ITEMS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.ORDER_ITEMS (
    order_id STRING,
    order_item_id INTEGER,
    product_id STRING,
    seller_id STRING,
    shipping_limit_date TIMESTAMP_NTZ,
    price NUMBER(10,2),
    freight_value NUMBER(10,2)
);

COPY INTO DBT_PROJECT.RAW.ORDER_ITEMS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_order_items_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
);

SELECT *
FROM DBT_PROJECT.RAW.ORDER_ITEMS
LIMIT 10;


-- ============================================================
-- 9. ORDER PAYMENTS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.ORDER_PAYMENTS (
    order_id STRING,
    payment_sequential INTEGER,
    payment_type STRING(20),
    payment_installments INTEGER,
    payment_value DECIMAL(10,2),

    CONSTRAINT chk_payment_type
        CHECK (
            payment_type IN (
                'boleto',
                'debit_card',
                'not_defined',
                'credit_card',
                'voucher'
            )
        )
);

COPY INTO DBT_PROJECT.RAW.ORDER_PAYMENTS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_order_payments_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
);

SELECT *
FROM DBT_PROJECT.RAW.ORDER_PAYMENTS
LIMIT 10;


-- ============================================================
-- 10. ORDER REVIEWS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.ORDER_REVIEWS (
    review_id STRING NOT NULL,
    order_id STRING,
    review_score INTEGER,
    review_comment_title STRING,
    review_comment_message STRING,
    review_creation_date TIMESTAMP_NTZ,
    review_answer_timestamp TIMESTAMP_NTZ
);

COPY INTO DBT_PROJECT.RAW.ORDER_REVIEWS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_order_reviews_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
);

SELECT *
FROM DBT_PROJECT.RAW.ORDER_REVIEWS
LIMIT 10;


-- ============================================================
-- 11. ORDERS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.ORDERS (
    order_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    order_status STRING,
    order_purchase_timestamp TIMESTAMP_NTZ,
    order_approved_at TIMESTAMP_NTZ,
    order_delivered_carrier_date TIMESTAMP_NTZ,
    order_delivered_customer_date TIMESTAMP_NTZ,
    order_estimated_delivery_date TIMESTAMP_NTZ,

    CONSTRAINT chk_order_status
        CHECK (
            order_status IN (
                'created',
                'delivered',
                'approved',
                'invoiced',
                'shipped',
                'processing',
                'canceled',
                'unavailable'
            )
        )
);

COPY INTO DBT_PROJECT.RAW.ORDERS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_orders_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
);

SELECT *
FROM DBT_PROJECT.RAW.ORDERS
LIMIT 10;


-- ============================================================
-- 12. PRODUCTS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.PRODUCTS (
    product_id STRING,
    product_category_name STRING,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

COPY INTO DBT_PROJECT.RAW.PRODUCTS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_products_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
);

SELECT *
FROM DBT_PROJECT.RAW.PRODUCTS
LIMIT 10;


-- ============================================================
-- 13. SELLERS
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.SELLERS (
    seller_id STRING NOT NULL,
    seller_zip_code_prefix INTEGER,
    seller_city STRING,
    seller_state STRING(3)
);

COPY INTO DBT_PROJECT.RAW.SELLERS
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/olist_sellers_dataset.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
);

SELECT *
FROM DBT_PROJECT.RAW.SELLERS
LIMIT 10;


-- ============================================================
-- 14. PRODUCT CATEGORY TRANSLATION
-- ============================================================

CREATE OR REPLACE TABLE DBT_PROJECT.RAW.PRODUCTS_CATEGORY_NAME (
    product_category_name STRING,
    product_category_name_english STRING
);

COPY INTO DBT_PROJECT.RAW.PRODUCTS_CATEGORY_NAME
FROM @DBT_PROJECT.PUBLIC.MY_STAGE/product_category_name_translation.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
);

SELECT *
FROM DBT_PROJECT.RAW.PRODUCTS_CATEGORY_NAME
LIMIT 10;


-- ============================================================
-- 15. FINAL VALIDATION
-- ============================================================

SHOW TABLES IN SCHEMA DBT_PROJECT.RAW;

SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count
FROM DBT_PROJECT.RAW.CUSTOMERS

UNION ALL

SELECT 'GEOLOCATION', COUNT(*)
FROM DBT_PROJECT.RAW.GEOLOCATION

UNION ALL

SELECT 'ORDER_ITEMS', COUNT(*)
FROM DBT_PROJECT.RAW.ORDER_ITEMS

UNION ALL

SELECT 'ORDER_PAYMENTS', COUNT(*)
FROM DBT_PROJECT.RAW.ORDER_PAYMENTS

UNION ALL

SELECT 'ORDER_REVIEWS', COUNT(*)
FROM DBT_PROJECT.RAW.ORDER_REVIEWS

UNION ALL

SELECT 'ORDERS', COUNT(*)
FROM DBT_PROJECT.RAW.ORDERS

UNION ALL

SELECT 'PRODUCTS', COUNT(*)
FROM DBT_PROJECT.RAW.PRODUCTS

UNION ALL

SELECT 'SELLERS', COUNT(*)
FROM DBT_PROJECT.RAW.SELLERS

UNION ALL

SELECT 'PRODUCTS_CATEGORY_NAME', COUNT(*)
FROM DBT_PROJECT.RAW.PRODUCTS_CATEGORY_NAME

ORDER BY table_name;

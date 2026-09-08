WITH source_ AS (
    SELECT *
    FROM {{source('raw','order_reviews')}}
),
cleaned AS (
    SELECT 
        TRIM(review_id) AS review_id,	
        TRIM(order_id) AS order_id,
        review_score,
        NULLIF(review_comment_title,'') AS review_comment_title,
        NULLIF(review_comment_message,'') AS review_comment_message,
        CAST(review_creation_date AS TIMESTAMP_NTZ) AS review_creation_date,
        CAST(review_answer_timestamp AS TIMESTAMP_NTZ) AS review_answer_timestamp
    FROM source_
)
SELECT *
FROM cleaned
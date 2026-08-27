SELECT *
FROM {{ ref('int_order_reviews_aggregated') }}
WHERE avg_review_score NOT BETWEEN 1 AND 5
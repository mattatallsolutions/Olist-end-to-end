-- Delivery impact on review scores (on-time vs late)
-- Grain: 1 row per delivery_status bucket

DROP TABLE IF EXISTS mart.delivery_review_impact;

CREATE TABLE mart.delivery_review_impact AS
WITH base AS (
  SELECT
    o.order_id,
    o.is_on_time,
    r.review_score
  FROM dw.fact_orders o
  LEFT JOIN stg.reviews r
    ON o.order_id = r.order_id
  WHERE o.is_on_time IS NOT NULL
    AND r.review_score IS NOT NULL
)
SELECT
  CASE WHEN is_on_time = 1 THEN 'On-time' ELSE 'Late' END AS delivery_status,
  COUNT(*) AS reviewed_orders,
  AVG(review_score) AS avg_review_score
FROM base
GROUP BY 1
ORDER BY 1;

-- Seller delay ranking
-- Shows sellers with the worst on-time delivery performance

DROP TABLE IF EXISTS mart.seller_delay_ranking;

CREATE TABLE mart.seller_delay_ranking AS
SELECT
  oi.seller_id,
  COUNT(DISTINCT o.order_id) AS total_orders,
  AVG(o.is_on_time) AS on_time_rate,
  (1 - AVG(o.is_on_time)) AS late_rate
FROM dw.fact_order_items oi
JOIN dw.fact_orders o
  ON oi.order_id = o.order_id
WHERE o.is_on_time IS NOT NULL
GROUP BY 1
HAVING COUNT(DISTINCT o.order_id) >= 50
ORDER BY late_rate DESC;

-- Customer cohort retention by month since first purchase
-- Cohort = month of customer's first purchase
-- Retention month = months since cohort month

DROP TABLE IF EXISTS mart.customer_cohort_retention;

CREATE TABLE mart.customer_cohort_retention AS
WITH customer_orders AS (
  SELECT
    c.customer_unique_id,
    CAST(o.order_purchase_ts AS DATE) AS purchase_date
  FROM stg.orders o
  JOIN stg.customers c
    ON o.customer_id = c.customer_id
  WHERE o.order_purchase_ts IS NOT NULL
),
first_purchase AS (
  SELECT
    customer_unique_id,
    DATE_TRUNC('month', MIN(purchase_date)) AS cohort_month
  FROM customer_orders
  GROUP BY 1
),
orders_with_cohort AS (
  SELECT
    co.customer_unique_id,
    fp.cohort_month,
    DATE_TRUNC('month', co.purchase_date) AS order_month
  FROM customer_orders co
  JOIN first_purchase fp
    USING (customer_unique_id)
),
retention_months AS (
  SELECT
    cohort_month,
    DATE_DIFF('month', cohort_month, order_month) AS month_number,
    COUNT(DISTINCT customer_unique_id) AS customers
  FROM orders_with_cohort
  GROUP BY 1,2
),
cohort_sizes AS (
  SELECT
    cohort_month,
    customers AS cohort_size
  FROM retention_months
  WHERE month_number = 0
)
SELECT
  r.cohort_month,
  r.month_number,
  r.customers,
  cs.cohort_size,
  (r.customers * 1.0) / cs.cohort_size AS retention_rate
FROM retention_months r
JOIN cohort_sizes cs
  USING (cohort_month)
WHERE r.month_number BETWEEN 0 AND 6
ORDER BY 1,2;

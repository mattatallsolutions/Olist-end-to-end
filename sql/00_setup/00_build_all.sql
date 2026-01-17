PRAGMA threads=4;

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS mart;

DROP TABLE IF EXISTS raw.orders;
CREATE TABLE raw.orders AS SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');

DROP TABLE IF EXISTS raw.order_items;
CREATE TABLE raw.order_items AS SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');

DROP TABLE IF EXISTS raw.payments;
CREATE TABLE raw.payments AS SELECT * FROM read_csv_auto('data/olist_order_payments_dataset.csv');

DROP TABLE IF EXISTS raw.reviews;
CREATE TABLE raw.reviews AS SELECT * FROM read_csv_auto('data/olist_order_reviews_dataset.csv');

DROP TABLE IF EXISTS raw.customers;
CREATE TABLE raw.customers AS SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');

DROP TABLE IF EXISTS raw.sellers;
CREATE TABLE raw.sellers AS SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');

DROP TABLE IF EXISTS raw.products;
CREATE TABLE raw.products AS SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');

DROP TABLE IF EXISTS raw.geolocation;
CREATE TABLE raw.geolocation AS SELECT * FROM read_csv_auto('data/olist_geolocation_dataset.csv');

DROP TABLE IF EXISTS raw.category_translation;
CREATE TABLE raw.category_translation AS SELECT * FROM read_csv_auto('data/product_category_name_translation.csv');

-- STAGING (clean types)
DROP TABLE IF EXISTS stg.orders;
CREATE TABLE stg.orders AS
SELECT
  order_id,
    customer_id,
      order_status,
        CAST(order_purchase_timestamp AS TIMESTAMP)     AS order_purchase_ts,
          CAST(order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_ts,
            CAST(order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_ts
            FROM raw.orders;

            DROP TABLE IF EXISTS stg.order_items;
            CREATE TABLE stg.order_items AS
            SELECT
              order_id,
                order_item_id,
                  product_id,
                    seller_id,
                      CAST(price AS DOUBLE) AS price,
                        CAST(freight_value AS DOUBLE) AS freight_value,
                          (CAST(price AS DOUBLE) + CAST(freight_value AS DOUBLE)) AS item_total
                          FROM raw.order_items;

                          DROP TABLE IF EXISTS stg.payments;
                          CREATE TABLE stg.payments AS
                          SELECT
                            order_id,
                              payment_sequential,
                                payment_type,
                                  CAST(payment_installments AS INTEGER) AS payment_installments,
                                    CAST(payment_value AS DOUBLE) AS payment_value
                                    FROM raw.payments;

                                    DROP TABLE IF EXISTS stg.reviews;
                                    CREATE TABLE stg.reviews AS
                                    SELECT
                                      review_id,
                                        order_id,
                                          CAST(review_score AS INTEGER) AS review_score,
                                            CAST(review_creation_date AS TIMESTAMP) AS review_creation_ts
                                            FROM raw.reviews;

                                            DROP TABLE IF EXISTS stg.customers;
                                            CREATE TABLE stg.customers AS
                                            SELECT
                                              customer_id,
                                                customer_unique_id,
                                                  LOWER(TRIM(customer_city)) AS customer_city,
                                                    UPPER(TRIM(customer_state)) AS customer_state
                                                    FROM raw.customers;

                                                    DROP TABLE IF EXISTS stg.sellers;
                                                    CREATE TABLE stg.sellers AS
                                                    SELECT
                                                      seller_id,
                                                        LOWER(TRIM(seller_city)) AS seller_city,
                                                          UPPER(TRIM(seller_state)) AS seller_state
                                                          FROM raw.sellers;

                                                          DROP TABLE IF EXISTS stg.category_translation;
                                                          CREATE TABLE stg.category_translation AS
                                                          SELECT product_category_name, product_category_name_english
                                                          FROM raw.category_translation;

                                                          DROP TABLE IF EXISTS stg.products;
                                                          CREATE TABLE stg.products AS
                                                          SELECT
                                                            product_id,
                                                              product_category_name
                                                              FROM raw.products;

                                                              -- WAREHOUSE (star-ish)
                                                              DROP TABLE IF EXISTS dw.dim_products;
                                                              CREATE TABLE dw.dim_products AS
                                                              SELECT
                                                                p.product_id,
                                                                  COALESCE(t.product_category_name_english, 'unknown') AS category_english
                                                                  FROM stg.products p
                                                                  LEFT JOIN stg.category_translation t
                                                                    ON p.product_category_name = t.product_category_name;

                                                                    DROP TABLE IF EXISTS dw.fact_orders;
                                                                    CREATE TABLE dw.fact_orders AS
                                                                    SELECT
                                                                      order_id,
                                                                        customer_id,
                                                                          CAST(order_purchase_ts AS DATE) AS purchase_date,
                                                                            order_status,
                                                                              order_purchase_ts,
                                                                                order_delivered_customer_ts,
                                                                                  order_estimated_delivery_ts,
                                                                                    CASE
                                                                                        WHEN order_delivered_customer_ts IS NULL OR order_estimated_delivery_ts IS NULL THEN NULL
                                                                                            WHEN order_delivered_customer_ts <= order_estimated_delivery_ts THEN 1
                                                                                                ELSE 0
                                                                                                  END AS is_on_time
                                                                                                  FROM stg.orders;

                                                                                                  DROP TABLE IF EXISTS dw.fact_order_items;
                                                                                                  CREATE TABLE dw.fact_order_items AS
                                                                                                  SELECT
                                                                                                    order_id,
                                                                                                      order_item_id,
                                                                                                        product_id,
                                                                                                          seller_id,
                                                                                                            price,
                                                                                                              freight_value,
                                                                                                                item_total
                                                                                                                FROM stg.order_items;

                                                                                                                -- MART
                                                                                                                DROP TABLE IF EXISTS mart.kpi_daily;
                                                                                                                CREATE TABLE mart.kpi_daily AS
                                                                                                                WITH revenue_daily AS (
                                                                                                                  SELECT
                                                                                                                      o.purchase_date AS date,
                                                                                                                          SUM(i.item_total) AS revenue,
                                                                                                                              COUNT(DISTINCT o.order_id) AS orders,
                                                                                                                                  AVG(o.is_on_time) AS on_time_rate
                                                                                                                                    FROM dw.fact_orders o
                                                                                                                                      JOIN dw.fact_order_items i ON o.order_id = i.order_id
                                                                                                                                        GROUP BY 1
                                                                                                                                        ),
                                                                                                                                        review_daily AS (
                                                                                                                                          SELECT
                                                                                                                                              CAST(review_creation_ts AS DATE) AS date,
                                                                                                                                                  AVG(review_score) AS avg_review_score
                                                                                                                                                    FROM stg.reviews
                                                                                                                                                      GROUP BY 1
                                                                                                                                                      )
                                                                                                                                                      SELECT
                                                                                                                                                        r.date,
                                                                                                                                                          r.revenue,
                                                                                                                                                            r.orders,
                                                                                                                                                              r.on_time_rate,
                                                                                                                                                                v.avg_review_score
                                                                                                                                                                FROM revenue_daily r
                                                                                                                                                                LEFT JOIN review_daily v USING (date);
                                                                                                                                                                
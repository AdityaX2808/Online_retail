-- Load new sales records from source into staging, avoiding duplicates
INSERT INTO wh_stage.stg_fact_sales (
    invoice_no,
    stock_code,
    customer_id,
    quantity,
    unit_price,
    etl_insert_ts,
    etl_update_ts
)
SELECT DISTINCT
    s.invoiceno,
    s.stockcode,
    s.customerid,
    s.quantity::integer,
    s.unitprice::numeric(10,2),
    now() AS etl_insert_ts,
    now() AS etl_update_ts
FROM wh_source.online_retail_raw s
WHERE s.customerid IS NOT NULL
  AND s.invoiceno IS NOT NULL
  AND s.stockcode IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM wh_stage.stg_fact_sales stg
      WHERE stg.invoice_no = s.invoiceno
        AND stg.stock_code = s.stockcode
        AND stg.customer_id = s.customerid
  );

-- Incremental insert from staging to core fact table avoiding duplicates
INSERT INTO wh_core.fact_sales (
    invoice_no,
    customer_key,
    product_ket,
    quantity,
    unit_price,
    total_amount,
    country
)
SELECT
    stg.invoice_no,
    c.customer_key,
    p.product_key,
    stg.quantity,
    stg.unit_price,
    (stg.quantity * stg.unit_price) AS total_amount,
    c.country
FROM wh_stage.stg_fact_sales stg
JOIN wh_core.dim_customer c ON c.customer_id = stg.customer_id AND c.current_flag = TRUE
JOIN wh_core.dim_product p ON p.stock_code = stg.stock_code AND p.current_flag = TRUE
LEFT JOIN wh_core.fact_sales f ON
    f.invoice_no = stg.invoice_no
    AND f.customer_key = c.customer_key
    AND f.product_ket = p.product_key
WHERE f.invoice_no IS NULL;

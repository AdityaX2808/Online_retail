-- Incrementally load new products into staging
INSERT INTO wh_stage.stg_product (stock_code, description, etl_insert_ts, etl_update_ts)
SELECT DISTINCT
    stockcode,
    description,
    now() AS etl_insert_ts,
    now() AS etl_update_ts
FROM wh_source.online_retail_raw s
WHERE NOT EXISTS (
    SELECT 1 FROM wh_stage.stg_product t
    WHERE t.stock_code = s.stockcode
)
on conflict (stock_code) do nothing;

-- Incrementally load new products into core dimension table (with SCD type 2 fields)
INSERT INTO wh_core.dim_product (stock_code, description, start_date, end_date, current_flag)
SELECT
    s.stock_code,
    s.description,
    now() AS start_date,
    NULL AS end_date,
    TRUE AS current_flag
FROM wh_stage.stg_product s
WHERE NOT EXISTS (
    SELECT 1 FROM wh_core.dim_product d
    WHERE d.stock_code = s.stock_code
      AND d.current_flag = TRUE
);

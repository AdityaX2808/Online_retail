-- Monthly sales summary: total sales amount and quantity by year-month
CREATE OR REPLACE VIEW wh_reports.monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', f.invoice_date) AS month,
    SUM(f.total_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM wh_core.fact_sales f
GROUP BY month
ORDER BY month;

-- Top customers by total sales amount
CREATE OR REPLACE VIEW wh_reports.top_customers AS
SELECT
    c.customer_id,
    SUM(f.total_amount) AS total_sales
FROM wh_core.fact_sales f
JOIN wh_core.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.customer_id
ORDER BY total_sales DESC;

-- Sales by region (assuming region info in wh_core.dim_customer country field)
CREATE OR REPLACE VIEW wh_reports.sales_by_region AS
SELECT
    c.country AS region,
    SUM(f.total_amount) AS total_sales,
    COUNT(DISTINCT f.invoice_no) AS num_invoices
FROM wh_core.fact_sales f
JOIN wh_core.dim_customer c ON f.customer_key = c.customer_key
GROUP BY region
ORDER BY total_sales DESC;

-- Product category performance (assuming category info in wh_core.dim_product table)
CREATE OR REPLACE VIEW wh_reports.product_category_performance AS
SELECT
    p.stock_code, 
    SUM(f.total_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM wh_core.fact_sales f
JOIN wh_core.dim_product p ON f.product_ket = p.product_key
GROUP BY p.stock_code
ORDER BY total_sales DESC;


SELECT * FROM wh_reports.monthly_sales_summary;
SELECT * FROM wh_reports.top_customers;
SELECT * FROM wh_reports.sales_by_region;
SELECT * FROM wh_reports.product_category_performance;


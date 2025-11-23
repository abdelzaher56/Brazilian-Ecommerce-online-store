/*
===============================================================================
DDL SCRIPT: CREATE GOLD VIEWS
===============================================================================
Script Purpose:
    This script creates views for the gold layer in the data warehouse.
    The gold layer represents the final dimension and fact tables (star schema).

    Each view performs transformations and combines data from the silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers (one row per customer)
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_sk,
    customer_id           AS customer_bk,
    customer_zipcode      AS customer_zipcode,
    customer_city         AS customer_city,
    customer_state        AS customer_state
FROM silver.customer;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products (one row per product)
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_sk, -- Surrogate key
    product_id           AS product_bk,
    product_category     AS product_category,
    product_weight_g     AS product_weight_g,
    product_length_cm    AS product_length_cm,
    product_height_cm    AS product_height_cm,
    product_width_cm     AS product_width_cm
FROM silver.product;
GO

-- ==============================
-- Data preview: products dimension
-- ==============================
SELECT * FROM gold.dim_products;
GO

-- =============================================================================
-- Create Dimension: gold.dim_payment (unique payment types)
-- =============================================================================
IF OBJECT_ID('gold.dim_payment', 'V') IS NOT NULL
    DROP VIEW gold.dim_payment;
GO

CREATE VIEW gold.dim_payment AS
SELECT
    ROW_NUMBER() OVER (ORDER BY payment_type) AS payment_sk, -- Surrogate key
    payment_type AS payment_type
FROM (
    SELECT DISTINCT payment_type
    FROM silver.payment
) t;
GO

-- =============================================================================
-- Create Dimension: gold.dim_order_info (order + item linkage)
-- =============================================================================
IF OBJECT_ID('gold.dim_order_info', 'V') IS NOT NULL
    DROP VIEW gold.dim_order_info;
GO

CREATE VIEW gold.dim_order_info AS
SELECT
    ROW_NUMBER() OVER (ORDER BY o.order_id) AS order_sk,
    o.order_id           AS order_bk,
    i.product_id         AS product_id,
    o.order_status       AS order_status,
    i.seller_id          AS seller_id
FROM silver.orders AS o
LEFT JOIN silver.order_item AS i
    ON o.order_id = i.order_id;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales (full denormalized sales fact)
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    dor.order_sk                 AS order_fk,
    dc.customer_sk               AS customer_fk,
    dp.product_sk                AS product_fk,
    dpy.payment_sk               AS payment_fk,

    o.order_purchase_time        AS order_purchase_time,
    o.order_delivered_time       AS order_delivered_time,
    oi.price                     AS price,
    oi.shipping_charges          AS shipping_charges
FROM silver.orders AS o
LEFT JOIN silver.order_item AS oi
    ON o.order_id = oi.order_id
LEFT JOIN silver.payment AS p
    ON o.order_id = p.order_id
LEFT JOIN gold.dim_order_info AS dor
    ON o.order_id = dor.order_bk
LEFT JOIN gold.dim_customers AS dc
    ON o.customer_id = dc.customer_bk
LEFT JOIN gold.dim_products AS dp
    ON oi.product_id = dp.product_bk
LEFT JOIN gold.dim_payment AS dpy
    ON p.payment_type = dpy.payment_type;
GO

-- =============================
-- Data Exploration: Views and Counting Uniqueness
-- =============================

-- Preview all sales facts
SELECT * FROM gold.fact_sales;
GO

-- Find products with duplicate foreign keys
SELECT COUNT(product_fk) AS product_count, product_fk
FROM gold.fact_sales
GROUP BY product_fk
HAVING COUNT(product_fk) > 1;
GO

-- Find orders with duplicate foreign keys
SELECT COUNT(order_fk) AS order_count, order_fk
FROM gold.fact_sales
GROUP BY order_fk
HAVING COUNT(order_fk) > 1;
GO

-- Get facts with product category when product_fk is 2
SELECT f.*, p.product_category
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_fk = p.product_sk
WHERE product_fk = 2;
GO

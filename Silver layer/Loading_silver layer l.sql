-- ============================================================================
-- DATA LOADING: BRONZE TO SILVER LAYER
-- ============================================================================
-- This script loads dimension and fact tables from the bronze layer into the
-- corresponding silver layer tables, performing lookups, cleansing, and standardization
-- during the insert process.
-- ============================================================================

-- =============================
-- Load customer dimension
-- =============================
PRINT '>> Truncating Table: silver.customer';
TRUNCATE TABLE silver.customer;

PRINT '>> Inserting Data Into: silver.customer';
INSERT INTO silver.customer (
    customer_id,
    customer_zipcode,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_zipcode,
    TRIM(customer_city) AS customer_city,
    CASE customer_state
        WHEN 'AC' THEN 'Acre'
        WHEN 'AL' THEN 'Alagoas'
        WHEN 'AM' THEN 'Amazonas'
        WHEN 'AP' THEN 'Amapa'
        WHEN 'BA' THEN 'Bahia'
        WHEN 'CE' THEN 'Ceara'
        WHEN 'DF' THEN 'Distrito Federal'
        WHEN 'ES' THEN 'Espirito Santo'
        WHEN 'GO' THEN 'Goias'
        WHEN 'MA' THEN 'Maranhao'
        WHEN 'MG' THEN 'Minas Gerais'
        WHEN 'MS' THEN 'Mato Grosso do Sul'
        WHEN 'MT' THEN 'Mato Grosso'
        WHEN 'PA' THEN 'Para'
        WHEN 'PB' THEN 'Paraiba'
        WHEN 'PE' THEN 'Pernambuco'
        WHEN 'PI' THEN 'Piaui'
        WHEN 'PR' THEN 'Parana'
        WHEN 'RJ' THEN 'Rio de Janeiro'
        WHEN 'RN' THEN 'Rio Grande do Norte'
        WHEN 'RO' THEN 'Rondonia'
        WHEN 'RR' THEN 'Roraima'
        WHEN 'RS' THEN 'Rio Grande do Sul'
        WHEN 'SC' THEN 'Santa Catarina'
        WHEN 'SE' THEN 'Sergipe'
        WHEN 'SP' THEN 'Sao Paulo'
        WHEN 'TO' THEN 'Tocantins'
        ELSE customer_state
    END AS customer_state
FROM bronze.customer;

-- =============================
-- Load order item fact table
-- =============================
PRINT '>> Truncating Table: silver.order_item';
TRUNCATE TABLE silver.order_item;

PRINT '>> Inserting Data Into: silver.order_item';
INSERT INTO silver.order_item (
    order_id,
    product_id,
    seller_id,
    price,
    shipping_charges
)
SELECT
    order_id,
    product_id,
    seller_id,
    price,
    shipping_charges
FROM bronze.order_item;

-- =============================
-- Load orders fact table
-- =============================
PRINT '>> Truncating Table: silver.orders';
TRUNCATE TABLE silver.orders;

PRINT '>> Inserting Data Into: silver.orders';
INSERT INTO silver.orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_time,
    order_approved_at,
    order_delivered_time,
    order_estimated_delivery_date
)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_time,
    order_approved_at,
    order_delivered_time,
    order_estimated_delivery_date
FROM bronze.orders;

-- =============================
-- Load payment fact table, cleansing type column
-- =============================
PRINT '>> Truncating Table: silver.payment';
TRUNCATE TABLE silver.payment;

PRINT '>> Inserting Data Into: silver.payment';
INSERT INTO silver.payment (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    payment_value
FROM bronze.payment;

-- =============================
-- Load product dimension, fill missing category
-- =============================
PRINT '>> Truncating Table: silver.product';
TRUNCATE TABLE silver.product;

PRINT '>> Inserting Data Into: silver.product';
INSERT INTO silver.product (
    product_id,
    product_category,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT DISTINCT
    product_id,
    CASE 
        WHEN product_category IS NULL THEN 'unknown'
        ELSE product_category
    END AS product_category,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM bronze.product;

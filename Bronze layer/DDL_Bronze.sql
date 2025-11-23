/*
===============================================================================
DDL SCRIPT: CREATE BRONZE TABLES
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' tables.
===============================================================================
*/

IF OBJECT_ID('bronze.customer', 'U') IS NOT NULL
    DROP TABLE bronze.customer;
GO

CREATE TABLE bronze.customer (
    customer_id       NVARCHAR(50),
    customer_zipcode  INT,
    customer_city     NVARCHAR(255),
    customer_state    NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
    DROP TABLE bronze.orders;
GO

CREATE TABLE bronze.orders (
    order_id                    NVARCHAR(50),
    customer_id                 NVARCHAR(50),
    order_status                NVARCHAR(50),
    order_purchase_time         DATETIME,
    order_approved_at           DATETIME,
    order_delivered_time        DATETIME,
    order_estimated_delivery_date DATE
);
GO

IF OBJECT_ID('bronze.product', 'U') IS NOT NULL
    DROP TABLE bronze.product;
GO

CREATE TABLE bronze.product (
    product_id        NVARCHAR(50),
    product_category  NVARCHAR(50),
    product_weight_g  FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm  FLOAT
);
GO

IF OBJECT_ID('bronze.order_item', 'U') IS NOT NULL
    DROP TABLE bronze.order_item;
GO

CREATE TABLE bronze.order_item (
    order_id           NVARCHAR(50),
    product_id         NVARCHAR(50),
    seller_id          NVARCHAR(50),
    price              FLOAT,
    shipping_charges   FLOAT
);
GO

IF OBJECT_ID('silver.payment', 'U') IS NOT NULL
    DROP TABLE silver.payment;
GO

CREATE TABLE silver.payment (
    order_id            NVARCHAR(50),
    payment_sequential  INT,
    payment_type        NVARCHAR(50),
    payment_installments INT,
    payment_value       FLOAT
);
GO

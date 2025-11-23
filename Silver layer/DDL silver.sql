/*
===============================================================================
DDL SCRIPT: CREATE SILVER TABLES
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' tables.
===============================================================================
*/

IF OBJECT_ID('silver.customer', 'U') IS NOT NULL
    DROP TABLE silver.customer;
GO

CREATE TABLE silver.customer (
    customer_id        nvarchar(50),
    customer_zipcode   int,
    customer_city      nvarchar(255),
    customer_state     nvarchar(50)
);
GO

IF OBJECT_ID('silver.orders', 'U') IS NOT NULL
    DROP TABLE silver.orders;
GO

CREATE TABLE silver.orders (
    prd_id                     nvarchar(50),
    customer_id                nvarchar(50),
    order_status               nvarchar(50),
    order_purchase_time        datetime,
    order_approved_at          datetime,
    order_delivered_time       datetime,
    order_estimated_delivery_date date
);
GO

IF OBJECT_ID('silver.product', 'U') IS NOT NULL
    DROP TABLE silver.product;
GO

CREATE TABLE silver.product (
    product_id         nvarchar(50),
    product_category   nvarchar(50),
    product_weight_g   float,
    product_length_cm  float,
    product_height_cm  float,
    product_width_cm   float
);
GO

IF OBJECT_ID('silver.order_item', 'U') IS NOT NULL
    DROP TABLE silver.order_item;
GO

CREATE TABLE silver.order_item (
    order_id           nvarchar(50),
    product_id         nvarchar(50),
    seller_id          nvarchar(50),
    price              float,
    shipping_charges   float
);
GO

IF OBJECT_ID('silver.payment', 'U') IS NOT NULL
    DROP TABLE silver.payment;
GO

CREATE TABLE silver.payment (
    order_id             nvarchar(50),
    payment_sequential   int,
    payment_type         nvarchar(50),
    payment_installments int,
    payment_value        float
);
GO

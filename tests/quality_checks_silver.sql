/*
==========================================================
Quality Check on the SILVER data (AFTER CLEANING)
==========================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks before loading into GOLD layer.
============================================================================================================
*/

-- =========================================
-- CHECKING TABLE: silver.crm_cust_info
-- =========================================

-- Check for NULLs or duplicates in PRIMARY KEY
-- > Expectation: No Result
SELECT 
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- > Expectation: No Result
SELECT 
    cst_firstname 
FROM silver.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

SELECT 
    cst_lastname  
FROM silver.crm_cust_info 
WHERE cst_firstname != TRIM(cst_lastname );

-- Check consistency and standarization in low cardinality columns
SELECT 
    DISTINCT cst_gndr 
FROM silver.crm_cust_info;
SELECT 
    DISTINCT cst_marital_status  
FROM silver.crm_cust_info;

-- See the final cleaned data
SELECT * FROM silver.crm_cust_info LIMIT 100;

-- =========================================
-- CHECKING TABLE: silver.crm_cust_info
-- =========================================

-- Check for NULLs or duplicates in PRIMARY KEY
-- > Expectation: No Result
SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- > Expectation: No Result
SELECT 
    prd_nm 
FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative numbers
-- > Expectation: No Result
SELECT *
FROM silver.crm_prd_info 
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Check consistency and standarization in low cardinality columns
SELECT 
    DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Check for invalid date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt ;

-- See the final cleaned data
SELECT * FROM silver.crm_prd_info LIMIT 100;


-- =========================================
-- CHECKING TABLE: silver.crm_sales_details
-- =========================================


-- Check for invalid date orders
SELECT 
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;

-- Check data consistency: Bewteen Sales, Quantity and Price
-- > Sales = Quantity * Price
-- > Values must not be NULL, zero or negative

SELECT DISTINCT
    sls_sales ,
    sls_quantity ,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity ;

SELECT * FROM silver.crm_sales_details LIMIT 100;

-- =========================================
-- CHECKING TABLE: silver.erp_cust_az12 
-- =========================================

-- Check for NULLs or duplicates in primary key
SELECT 
    cid,
    COUNT(*)
FROM silver.erp_cust_az12 
GROUP BY cid
HAVING cid IS NULL OR COUNT(*) > 1;

-- Identify out-of-range dates
SELECT bdate
FROM silver.erp_cust_az12 
WHERE bdate < '1926-01-01' OR bdate > CURRENT_DATE
ORDER BY bdate DESC;

-- Check consistency within low cardinality column
SELECT DISTINCT
    gen,
    length(gen)
FROM silver.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12 LIMIT 100;


-- =========================================
-- CHECKING TABLE: silver.erp_loc_a101
-- =========================================


-- Check for NULLs or duplicates in primary key
SELECT 
    cid,
    COUNT(*)
FROM silver.erp_loc_a101
GROUP BY cid
HAVING cid IS NULL OR COUNT(*) > 1;

SELECT * 
FROM silver.erp_loc_a101
WHERE cid LIKE 'AW-%';


-- Check date standardization and consistency within low cardinality column
SELECT DISTINCT
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101 LIMIT 100;

SELECT * FROM silver.erp_px_cat_g1v2;

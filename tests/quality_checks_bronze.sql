/*
==========================================================
Quality Check on the BRONZE raw data (BEFORE CLEANING)
==========================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'bronze' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and ships.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Bronze Layer.
    - Investigate and resolve any discrepancies found during the checks before loading into SILVER layer.
============================================================================================================
*/

-- =========================================
-- CHECKING TABLE: bronze.crm_cust_info
-- =========================================

-- Check for NULLs or duplicates in PRIMARY KEY
-- > Expectation: No Result
SELECT 
	cst_id,
	COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- > Expectation: No Result
SELECT 
    cst_firstname 
FROM bronze.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

-- Check consistency and standarization in low cardinality columns
SELECT 
    DISTINCT cst_gndr 
FROM bronze.crm_cust_info;
SELECT 
    DISTINCT cst_marital_status  
FROM bronze.crm_cust_info;



-- =========================================
-- CHECKING TABLE: bronze.crm_prd_info
-- =========================================

-- Check for NULLs or duplicates in PRIMARY KEY
-- > Expectation: No Result
SELECT 
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- > Expectation: No Result
SELECT 
    prd_nm 
FROM bronze.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative numbers
-- > Expectation: No Result
SELECT *
FROM bronze.crm_prd_info 
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Check consistency and standarization in low cardinality columns
SELECT 
    DISTINCT prd_line 
FROM bronze.crm_prd_info;

-- Check for invalid date ships
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt ;

-- =========================================
-- CHECKING TABLE: bronze.crm_cust_info
-- =========================================

SELECT * FROM bronze.crm_sales_details;

-- Check for NULLs or duplicates in PRIMARY KEY
-- > Expectation: No Result
SELECT 
    sls_ord_num ,
    COUNT(*)
FROM bronze.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL;



-- =========================================
-- CHECKING TABLE: bronze.crm_sales_details
-- =========================================

-- Check for invalid dates
SELECT 
    NULLIF(sls_due_dt , 0)
FROM bronze.crm_sales_details 
WHERE sls_due_dt <= 0 
    OR LENGTH(CAST(sls_due_dt AS TEXT)) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101;


-- Check for invalid date orders
SELECT 
    *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;

-- Check data consistency: Bewteen Sales, Quantity and Price
-- > Sales = Quantity * Price
-- > Values must not be NULL, zero or negative

SELECT DISTINCT
    sls_sales ,
    sls_quantity ,
    sls_price 
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity ;


-- =========================================
-- CHECKING TABLE: bronze.erp_cust_az12
-- =========================================

SELECT * FROM bronze.erp_cust_az12 LIMIT 100;
SELECT cst_key FROM silver.crm_cust_info;

-- Check for NULLs or duplicates in primary key
SELECT 
    cid,
    COUNT(*)
FROM bronze.erp_cust_az12 
GROUP BY cid
HAVING cid IS NULL OR COUNT(*) > 1;

-- Identify out-of-range dates
SELECT bdate
FROM bronze.erp_cust_az12 
WHERE bdate < '1926-01-01' OR bdate > CURRENT_DATE
ORDER BY bdate DESC;

-- Check consistency within low cardinality column
SELECT DISTINCT
    gen,
    length(gen)
FROM bronze.erp_cust_az12;


-- =========================================
-- CHECKING TABLE: bronze.erp_loc_a101
-- =========================================

SELECT * FROM bronze.erp_loc_a101 LIMIT 1000;
SELECT cst_key FROM silver.crm_cust_info;

-- Check for NULLs or duplicates in primary key
SELECT 
    cid,
    COUNT(*)
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING cid IS NULL OR COUNT(*) > 1;

SELECT * 
FROM bronze.erp_loc_a101
WHERE cid NOT LIKE 'AW-%';


-- Check date standardization and consistency within low cardinality column
SELECT DISTINCT
    cntry 
FROM bronze.erp_loc_a101
ORDER BY cntry;

-- =========================================
-- CHECKING TABLE: bronze.erp_px_cat_g1v2
-- =========================================

SELECT * FROM bronze.erp_px_cat_g1v2;

-- Check NULLs and duplicates for PK

SELECT 
    id,
    COUNT(*)
FROM bronze.erp_px_cat_g1v2 
GROUP BY id
HAVING id IS NULL OR COUNT(*) > 1;


SELECT id FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (
SELECT DISTINCT
    prd_cat_id  
FROM silver.crm_prd_info );

SELECT prd_cat_id FROM silver.crm_prd_info 
WHERE prd_cat_id NOT IN (
    SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2
);

-- Check for unwanted spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat);

-- Data standardization and consistency
SELECT 
    DISTINCT(cat)
FROM bronze.erp_px_cat_g1v2;

SELECT 
    DISTINCT(subcat)
FROM bronze.erp_px_cat_g1v2;

SELECT 
    DISTINCT(maintenance)
FROM bronze.erp_px_cat_g1v2;

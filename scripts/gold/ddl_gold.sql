/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key, -- Surrogate Key
    cci.cst_id AS customer_id,
    cci.cst_key AS customer_number,
    cci.cst_firstname AS first_name,
    cci.cst_lastname AS last_name,
    ela.cntry AS country,
    cci.cst_marital_status AS marital_status,
    CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr -- CRM is the primary source for gender info
         ELSE COALESCE(eca.gen, 'n/a') -- Fallback to ERP data
    END AS gender,
    eca.bdate AS birthdate,
    cci.cst_create_date AS create_date
FROM silver.crm_cust_info cci 
LEFT JOIN silver.erp_cust_az12 eca 
    ON cci.cst_key = eca.cid 
LEFT JOIN silver.erp_loc_a101 ela 
    ON cci.cst_key = ela.cid ;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE OR REPLACE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt , cpi.prd_key ) AS product_key, -- Surrogate Key
    cpi.prd_id AS product_id,
    cpi.prd_key AS product_number,
    cpi.prd_nm AS product_name,
    cpi.prd_cat_id AS category_id,
     epcgv.cat AS category,
    epcgv.subcat AS subcategory,
    epcgv.maintenance,
    cpi.prd_cost AS cost,
    cpi.prd_line AS product_line,
    cpi.prd_start_dt AS start_date  
FROM silver.crm_prd_info cpi 
LEFT JOIN silver.erp_px_cat_g1v2 epcgv 
    ON cpi.prd_cat_id = epcgv.id 
WHERE cpi.prd_end_dt IS NULL -- Filter out all historical data
;

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT 
    csd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key ,
    csd.sls_order_dt AS order_date,
    csd.sls_ship_dt AS shipping_date,
    csd.sls_due_dt AS due_date,
    csd.sls_sales AS sales_amount,
    csd.sls_quantity AS quantity,
    csd.sls_price  AS price
FROM silver.crm_sales_details csd 
LEFT JOIN gold.dim_products dp 
    ON csd.sls_prd_key = dp.product_number 
LEFT JOIN gold.dim_customers dc 
    ON csd.sls_cust_id = dc.customer_id ;






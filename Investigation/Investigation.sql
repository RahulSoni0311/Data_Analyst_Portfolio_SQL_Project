/*
===============================================================================
Investigation Queries
===============================================================================
Purpose:
    Contains queries used to investigate data issues, understand data patterns,
    and identify the transformations and business rules required before
    loading data into the Silver and Gold layers.

    These queries are used for data exploration, investigation, and development.
===============================================================================
*/


-- ============================================================================
-- CRM: Customer Information
-- ============================================================================

-- Review customer records
-- Inspect the structure, values, and overall content of customer data

SELECT *
FROM bronze.crm_cust_info;


-- Investigate a specific customer

SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;


-- Identify duplicate customer records
-- Check which record should be retained based on the latest creation date

SELECT
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last > 1;


-- ============================================================================
-- CRM: Product Information
-- ============================================================================

-- Check product and category relationships
-- Split the product key to identify the category and product key

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (
    SELECT DISTINCT id
    FROM bronze.erp_px_cat_g1v2
);


-- Check product cost values
-- Identify zero-cost products and review their usage in sales

SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    prd_cost,
    NULLIF(prd_cost, 0) AS standardized_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7) IN (
    SELECT sls_prd_key
    FROM bronze.crm_sales_details
);


-- Check product date history
-- Compare each product version with the next start date

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN (
    'AC-HE-HL-U509-R',
    'AC-HE-HL-U509'
);


-- ============================================================================
-- CRM: Sales Details
-- ============================================================================

-- Review sales records

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;


-- Check sales with invalid values

SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales <= 0;


-- Check sales and price calculations
-- Compare original values with possible corrected values

SELECT
    DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,

    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 THEN NULL
        WHEN sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details

WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0

ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;


-- ============================================================================
-- ERP: Customer Information
-- ============================================================================

-- Check customer ID format
-- Review the NAS prefix before standardizing the ID

SELECT
    cid,
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS standardized_cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;


-- Check gender values
-- Review the values before standardizing gender

SELECT
    DISTINCT
    gen,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
        ELSE 'N/A'
    END AS standardized_gender
FROM bronze.erp_cust_az12;


-- ============================================================================
-- ERP: Location
-- ============================================================================

-- Check customer ID format
-- Review the ID before removing hyphens

SELECT
    cid,
    REPLACE(cid, '-', '') AS standardized_cid,
    cntry
FROM bronze.erp_loc_a101;


-- Check country values
-- Review the values before standardizing country names

SELECT DISTINCT
    cntry,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS standardized_country
FROM bronze.erp_loc_a101
ORDER BY cntry;


-- ============================================================================
-- ERP: Product Category
-- ============================================================================

-- Review product category data

SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


-- ============================================================================
-- GOLD: Customer Information
-- ============================================================================

-- Investigate CRM and ERP gender combinations
-- Compare gender values from both sources before applying the integration rule

SELECT 
    ci.cst_gndr,
    ca.gen,
    COUNT(*) AS records
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
GROUP BY 
    ci.cst_gndr,
    ca.gen
ORDER BY 
    ci.cst_gndr,
    ca.gen;
    


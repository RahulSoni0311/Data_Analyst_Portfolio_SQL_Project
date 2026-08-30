
/*
===============================================================================
Script: Load Silver Layer
===============================================================================
Purpose:
    Transform, clean, standardize, and load data from the Bronze layer
    into the Silver layer.

    The transformations include:
        - Removing unwanted spaces
        - Standardizing categorical values
        - Handling NULL and invalid values
        - Removing duplicate customer records
        - Converting date formats
        - Deriving category and product keys
        - Correcting invalid sales and price values
        - Standardizing customer and country identifiers
===============================================================================
*/


USE silver;


-- ============================================================================
-- CRM: Customer Information
-- ============================================================================

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'N/A'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        ELSE 'N/A'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;


-- ============================================================================
-- CRM: Product Information
-- ============================================================================

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    -- Derive category ID from the original product key
    REPLACE(
        SUBSTRING(prd_key, 1, 5),
        '-',
        '_'
    ) AS cat_id,
    -- Extract product key
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    -- Replace NULL product costs with zero
    IFNULL(prd_cost, 0) AS prd_cost,
    -- Standardize product line values
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,
    -- Convert product start date to DATE
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    -- Set the end date to one day before the next version starts
    CAST(
        LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY
        AS DATE
    ) AS prd_end_dt

FROM bronze.crm_prd_info;


-- ============================================================================
-- CRM: Sales Details
-- ============================================================================

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    -- Convert order date from YYYYMMDD format
    CASE
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR),'%Y%m%d')
    END AS sls_order_dt,
    -- Convert ship date from YYYYMMDD format
    CASE
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR),'%Y%m%d')
    END AS sls_ship_dt,
    -- Convert due date from YYYYMMDD format
    CASE
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR),'%Y%m%d')
    END AS sls_due_dt,
    -- Correct invalid sales values
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 THEN NULL
        WHEN sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    -- Calculate price when the original value is invalid
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;


-- ============================================================================
-- ERP: Customer Information
-- ============================================================================

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    -- Remove NAS prefix from customer ID
    CASE
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    -- Remove future birth dates
    CASE WHEN bdate > NOW() THEN NULL
        ELSE bdate
    END AS bdate,
    -- Standardize gender values
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'Female')
            THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'Male')
            THEN 'Male'
        ELSE 'N/A'
    END AS gen

FROM bronze.erp_cust_az12;


-- ============================================================================
-- ERP: Location
-- ============================================================================

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    -- Remove hyphens from customer ID
    REPLACE(cid, '-', '') AS cid,
    -- Standardize country values
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;


-- ============================================================================
-- ERP: Product Category
-- ============================================================================

INSERT INTO silver.erp_px_cat_g1v2 (
    cat,
    subcat,
    maintenance
)
SELECT
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


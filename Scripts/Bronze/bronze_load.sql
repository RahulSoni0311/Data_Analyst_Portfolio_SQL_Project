
/*
===============================================================================
Script: Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
    This script loads data into the 'bronze' database from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `LOAD DATA INFILE` command to load data from csv files to bronze tables.

Parameters:
    None. 
      This script does not accept any parameters or return any values.

===============================================================================
*/

USE bronze;


-- =====================================================================
-- Initializing Time
-- =====================================================================

SET @batch_start_time = NOW();


-- =====================================================================
-- Loading Bronze Layer 
-- =====================================================================

SELECT '============================================' AS '';
SELECT 'Loading Bronze Layer' AS '';
SELECT '============================================' AS '';


-- =====================================================================
-- Loading CRM Tables
-- =====================================================================

SELECT '============================================' AS '';
SELECT 'Loading CRM Tables' AS '';
SELECT '============================================' AS '';


-- =====================================================================
-- CRM: Customer Information
-- =====================================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.crm_cust_info' AS '';

TRUNCATE TABLE bronze.crm_cust_info;

SELECT '>> Inserting Data into: bronze.crm_cust_info' AS '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS '';

SELECT '>> ------------------' AS '';


-- =====================================================================
-- CRM: Product Information 
-- =====================================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.crm_prd_info' AS '';

TRUNCATE TABLE bronze.crm_prd_info;

SELECT '>> Inserting Data into: bronze.crm_prd_info' AS '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS '';

SELECT '>> ------------------' AS '';



-- =====================================================================
-- CRM: Sales Details
-- =====================================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.crm_sales_details' AS '';

TRUNCATE TABLE bronze.crm_sales_details;

SELECT '>> Inserting Data into: bronze.crm_sales_details' AS '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'

IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS '';

SELECT '>> ------------------' AS '';


-- =====================================================================
-- Loading ERP Tables
-- =====================================================================

SELECT '============================================' AS '';
SELECT 'Loading ERP Tables' AS '';
SELECT '============================================' AS '';

-- =====================================================================
-- ERP: Customer
-- =====================================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.erp_cust_az12' AS '';

TRUNCATE TABLE bronze.erp_cust_az12;

SELECT '>> Inserting Data into: bronze.erp_cust_az12' AS '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql-data-warehouse-project-main/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS '';

SELECT '>> ------------------' AS '';


-- =====================================================================
-- ERP: Location
-- =====================================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.erp_loc_a101' AS '';

TRUNCATE TABLE bronze.erp_loc_a101;

SELECT '>> Inserting Data into: bronze.erp_loc_a101' AS '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql-data-warehouse-project-main/datasets/source_erp/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS '';

SELECT '>> ------------------' AS '';


-- =====================================================================
-- ERP: Product Category
-- =====================================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2' AS '';

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT '>> Inserting Data into: bronze.erp_px_cat_g1v2' AS '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql-data-warehouse-project-main/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT('Load Duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS '';

SELECT '>> ------------------' AS '';



-- =====================================================================
-- Bronze Load Completed 
-- =====================================================================

SET @batch_end_time = NOW();


SELECT '==========================================' AS '';
SELECT 'Loading Bronze Layer is Completed' AS '';
SELECT CONCAT(
    '   - Total Load Duration: ',
    TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time),
    ' seconds'
) AS '';
SELECT '==========================================' AS '';

SELECT COUNT(*) FROM bronze.crm_cust_info;



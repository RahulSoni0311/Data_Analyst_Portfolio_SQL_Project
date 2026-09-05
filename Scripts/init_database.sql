/*
===============================================================================
Create Databases
===============================================================================
Script Purpose:
    This script creates the three databases used in the Data Warehouse:
    'bronze', 'silver', and 'gold'.

    The Bronze layer stores raw source data.
    The Silver layer stores cleaned and transformed data.
    The Gold layer stores business-ready data for reporting and analytics.
    
    IF NOT EXISTS ensures that existing databases are not deleted.

===============================================================================
*/

-- Create Bronze Layer database
CREATE DATABASE IF NOT EXISTS bronze;

-- Create Silver Layer database
CREATE DATABASE IF NOT EXISTS silver;

-- Create Gold Layer database
CREATE DATABASE IF NOT EXISTS gold;

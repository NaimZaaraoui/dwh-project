/*
=============================================================
Create Database and Schemas
=============================================================

 Script Purpose:
    This script creates a new database named 'medallion_dwh' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    To be able to DROP the database if exists, connect to the default 'postgres' database in psql then
    run the DROP command
    Running it will drop the entire 'medallion_dwh' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
 */
 
-- \c postgres in psql
 -- Drop the database if already exists
 -- DROP DATABASE IF EXISTS medallion_dwh

-- Create the dedicated Data Warehouse Database
CREATE DATABASE medallion_dwh;

-- Create Isolated Medallion Layer Schemas
DROP SCHEMA IF EXISTS gold CASCADE;
DROP SCHEMA IF EXISTS silver CASCADE;
DROP SCHEMA IF EXISTS bronze CASCADE;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

Add Schema Documentation Metadata (Visible inside DBeaver)
COMMENT ON SCHEMA bronze IS 'Bronze Layer: Raw data';
COMMENT ON SCHEMA silver IS 'Silver Layer: Cleaned, standardized data';
COMMENT ON SCHEMA gold IS 'Gold Layer: Business-ready data';

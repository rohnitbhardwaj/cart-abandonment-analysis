
/*
PROJECT: E-COMMERCE FUNNEL ANALYSIS
PURPOSE:
Creates the ECommerce database and store schema, creates the required
tables, and loads website session, pageview, and order data from CSV files.
*/

-- ==============================================
-- CREATE DATABASE AND SCHEMA
-- ==============================================

USE master;
GO

IF DB_ID('ECommerce') IS NULL
    CREATE DATABASE ECommerce;
GO

USE ECommerce;
GO

IF SCHEMA_ID('store') IS NULL
    EXEC('CREATE SCHEMA store');
GO


-- ==============================================
-- CREATE TABLES AND LOAD CSV DATA
-- ==============================================


-- ------------------------
-- TABLE: Website_Sessions
-- ------------------------

-- Recreate table if it already exists.
IF OBJECT_ID('store.website_sessions','U') IS NOT NULL
    DROP TABLE store.website_sessions;
GO

-- Define website session structure.
CREATE TABLE store.website_sessions (
    website_session_id    INT PRIMARY KEY,
    created_at            DATETIME2,
    user_id               INT,
    is_repeat_session     TINYINT,
    utm_source            VARCHAR(50),
    utm_campaign          VARCHAR(50),
    utm_content           VARCHAR(50),
    device_type           VARCHAR(50),
    http_referer          VARCHAR(100)
);
GO

-- Import session data from CSV.
BULK INSERT store.website_sessions
FROM 'C:\data\website_sessions.csv' -- Update this path to the folder where you saved the CSV files
WITH (
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    FIRSTROW = 2
);


-- ------------------------
-- TABLE: Website_Pageviews
-- ------------------------

-- Recreate table if it already exists.
IF OBJECT_ID('store.website_pageviews','U') IS NOT NULL
    DROP TABLE store.website_pageviews;
GO

-- Define website pageview structure.
CREATE TABLE store.website_pageviews (
    website_pageview_id    INT PRIMARY KEY,
    created_at             DATETIME2,
    website_session_id     INT,
    pageview_url           VARCHAR(50)
);
GO

-- Import pageview data from CSV.
BULK INSERT store.website_pageviews
FROM 'C:\data\website_pageviews.csv' -- Update this path to the folder where you saved the CSV files
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

-- Speed up session-based lookups and joins.
CREATE INDEX ix_pageviews_session
ON store.website_pageviews (website_session_id);


-- ------------------------
-- TABLE: Orders
-- ------------------------

-- Recreate table if it already exists.
IF OBJECT_ID('store.orders','U') IS NOT NULL
    DROP TABLE store.orders;
GO

-- Define order structure.
CREATE TABLE store.orders (
    order_id              INT PRIMARY KEY,
    created_at            DATETIME2,
    website_session_id    INT,
    user_id               INT,
    primary_product_id    INT,
    items_purchased       INT,
    price_usd             DECIMAL(10,2),
    cogs_usd              DECIMAL(10,2)
);
GO

-- Import order data from CSV.
BULK INSERT store.orders
FROM 'C:\Users\samsung\Downloads\Maven+Fuzzy+Factory\orders.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
x`
OJO en vez de crear las secuencias puedo setear la columna como un autoincremental:

CREATE TABLE MiTabla (
    ID int PRIMARY KEY IDENTITY(1,1),
    Nombre varchar(50),
    Edad int
);
IDENTITY(1,1): Esto define la columna ID como una columna de identidad. El primer 1 indica el valor inicial, y el segundo 1 indica el incremento. 
Esto significa que la primera fila insertada tendrá un ID de 1, la segunda fila tendrá un ID de 2, y así sucesivamente.


-- After modeling, let's create our stg tables:
CREATE DATABASE [Real_Estate]
GO

USE [Real_Estate]
GO

CREATE SCHEMA [raw];
GO

CREATE SCHEMA [stg];
GO

--Create tables:

-- dim_home_type:----------------------------------------------------------------------------------------------------

CREATE SEQUENCE ptype_id
START WITH  500	
INCREMENT BY 1
MINVALUE  500; 

CREATE TABLE [stg].[dim_home_type] (
  [type_id] INT NOT NULL PRIMARY KEY DEFAULT NEXT VALUE FOR ptype_id,
  [home_type] VARCHAR(100));

INSERT INTO [stg].[dim_home_type] ([home_type])
SELECT DISTINCT	homeType FROM [raw].raw_listing;

-- Testing:
SELECT * FROM [stg].[dim_home_type]
GO

-- dim_province:-----------------------------------------------------------------------------------------------------

CREATE SEQUENCE pprovince_id
START WITH  77	
INCREMENT BY 1
MINVALUE  77;

CREATE TABLE [stg].[dim_province] (
  [province_id] INT NOT NULL PRIMARY KEY DEFAULT NEXT VALUE FOR pprovince_id,
  [province] VARCHAR(100));

 INSERT INTO [stg].[dim_province] ([province])
SELECT DISTINCT	state FROM [raw].raw_listing;

-- Testing:
SELECT * FROM [stg].[dim_province]
GO

-- dim_city:-----------------------------------------------------------------------------------------------------

CREATE SEQUENCE pcity_id
START WITH  50	
INCREMENT BY 1
MINVALUE  50;

CREATE TABLE [stg].[dim_city] (
  [city_id] INT NOT NULL PRIMARY KEY DEFAULT NEXT VALUE FOR pcity_id,
  [city] VARCHAR(100));

INSERT INTO [stg].[dim_city] (city)
SELECT DISTINCT	city FROM [raw].raw_listing;

--Testing
SELECT * FROM [stg].[dim_city]
GO

-- dim_location:-----------------------------------------------------------------------------------------------------

CREATE SEQUENCE ploc_id
START WITH  1000	
INCREMENT BY 1
MINVALUE  1000;

CREATE TABLE [stg].[dim_location] (
  [location_id] INT PRIMARY KEY DEFAULT NEXT VALUE FOR ploc_id,
  [city_id] INT,
  [province_id] INT,
  [address] VARCHAR(100),
  [unit] VARCHAR(100),
  [zip_code] VARCHAR(50),
  [latitude] FLOAT,
  [longitude] FLOAT);

INSERT INTO [stg].[dim_location] ([city_id], [province_id], [address], [unit], [zip_code], [latitude], [longitude])
SELECT 
c.city_id, p.province_id, r.streetAddress as address, r.unit, r.zipcode as zip_code, r.latitude, r.longitude
FROM [raw].raw_listing r
LEFT JOIN [stg].[dim_city] c on r.city=c.city
LEFT JOIN [stg].[dim_province] p on r.state=p.province;

-- Testing
SELECT * FROM [stg].[dim_location]
GO


-- dim_property_status:-----------------------------------------------------------------------------------------------------

CREATE SEQUENCE pstatus_id
START WITH  1	
INCREMENT BY 1
MINVALUE  1 ;

CREATE TABLE [stg].[dim_property_status] (
  [status_id] INT PRIMARY KEY DEFAULT NEXT VALUE FOR pstatus_id,
  [status] VARCHAR(100 ));

INSERT INTO [stg].[dim_property_status] ([status])
SELECT DISTINCT	status FROM [raw].raw_listing;

--Testing:
SELECT * FROM [stg].[dim_property_status]
GO

-- fact_listing

CREATE TABLE [stg].[fact_listing] (
  [pid] INT PRIMARY KEY,
  [url] VARCHAR(500),
  [status_id] INT,
  [type_id] INT,
  [location_id] INT,
  [price] FLOAT,
  [bathrooms] FLOAT,
  [bedrooms] INT,
  [area] FLOAT,
  [lot_area] FLOAT,
  [lot_area_unit] VARCHAR(50),
  [listing_date] DATE,);

INSERT INTO [stg].[fact_listing] ([pid], [url], [status_id], [type_id], [location_id], [price], [bathrooms], [bedrooms], [area], [lot_area], [lot_area_unit], [listing_date])
SELECT 
r.zpid as pid,
r.detailURL as url,
s.status_id,
t.type_id,
l.location_id,
r.price,
r.bathrooms,
r.bedrooms,
r.livingArea as area,
r.lotAreaValue as lot_area,
r.lotAreaUnit as lot_area_unit,
r.listingdate
FROM
[raw].raw_listing r
LEFT JOIN [stg].dim_property_status s ON s.status = r.status
LEFT JOIN [stg].dim_home_type t on t.home_type = r.homeType
LEFT JOIN [stg].dim_location l on l.address = r.streetAddress

--Testing:

SELECT * FROM [stg].[fact_listing]
GO

-- dim_date:-----------------------------------------------------------------------------------------------------

CREATE TABLE stg.dim_date (
    date DATE PRIMARY KEY,
    year INT,
    month_name NVARCHAR(20),
    month_number INT,
    quarter INT,
    day_of_week NVARCHAR(10),
    day_of_week_number INT,
    day_type NVARCHAR(10)
);

INSERT INTO [stg].[dim_date] (date, year, month_name, month_number, quarter, day_of_week, day_of_week_number, day_type)
SELECT
    DISTINCT listing_date AS date,
    YEAR(listing_date) AS year,
    DATENAME(MONTH, listing_date) AS month_name,
    MONTH(listing_date) AS month_number,
    DATEPART(QUARTER, listing_date) AS quarter,
    DATENAME(WEEKDAY, listing_date) AS day_of_week,
    DATEPART(WEEKDAY, listing_date) - 1 AS day_of_week_number, -- Ajust for 0=Sunday, 1=Monday
    CASE 
        WHEN DATEPART(WEEKDAY, listing_date) IN (1, 7) THEN 'Weekend' -- 1=Sunday, 7=Saturday en SQL Server
        ELSE 'Weekday'
    END AS day_type
FROM [stg].[fact_listing]
ORDER BY month_number ASC, day_of_week_number ASC;

--Testing
SELECT * FROM [stg].[dim_date]
GO






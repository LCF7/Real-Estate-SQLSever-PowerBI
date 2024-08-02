CREATE TABLE [dim_home_type] (
  [type_id] INT,
  [home_type] VARCHAR(100)
);

CREATE TABLE [dim_province] (
  [province_id] INT,
  [province] VARCHAR(100)
);

CREATE TABLE [dim_city] (
  [city_id] INT,
  [city] VARCHAR(100)
);

CREATE TABLE [dim_location] (
  [location_id] INT,
  [city_id] INT,
  [province_id] INT,
  [address] VARCHAR(250),
  [unit] VARCHAR(50),
  [zip_code] INT,
  [latitude] FLOAT,
  [longitude] FLOAT 
);

CREATE TABLE [dim_date] (
  [date] DATE,
  [day_of_week] VARCHAR(50),
  [day_of_week_num] INT,
  [day_type] VARCHAR(50),
  [month_name] VARCHAR(50),
  [month_num] INT,
  [quarter] VARCHAR(50),
  [year] INT
);

CREATE TABLE [dim_property_status] (
  [status_id] INT,
  [status] VARCHAR(100)
);

CREATE TABLE [fact_listing] (
  [pid] INT,
  [url] VARCHAR(250),
  [status_id] INT,
  [type_id] INT,
  [location_id] INT,
  [price] FLOAT,
  [bathrooms] INT,
  [bedrooms] INT,
  [area] FLOAT,
  [lot_area] FLOAT,
  [lot_area_unit] VARCHAR(50),
  [listing_date] DATE
 
);


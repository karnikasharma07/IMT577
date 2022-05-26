-- CREATING VIEWS
CREATE OR REPLACE SECURE VIEW View_Dim_Store --CREATED AND CHECKED
    AS
    SELECT 
        DimStoreID,
        DimLocationID, 
        SourceStoreID, 
        StoreNumber, 
        StoreManager
    FROM Dim_Store
    
CREATE OR REPLACE SECURE VIEW View_Dim_Reseller --CREATED AND CHECKED
    AS
    SELECT 
        DimResellerID,
        DimLocationID, 
        ResellerID, 
        ResellerName, 
        ContactName, 
        PhoneNumber, 
        Email
    FROM Dim_Reseller

CREATE OR REPLACE SECURE VIEW View_Dim_Customer --created and checked
    AS
    SELECT  
        DimCustomerID,  
        DimLocationID,  
        CustomerID,     
        CustomerFullName,       
        CustomerFirstName,     
        CustomerLastName,      
        CustomerGender,        
        CustomerEmailaddress,    
        CustomerPhoneNumber     
    FROM Dim_Customer

CREATE OR REPLACE SECURE VIEW View_Dim_Location --CREATED AND CHECKED
    AS
    SELECT
        DimLocationID,
        LocationID,
        Address, 
        City, 
        PostalCode, 
        Region, 
        Country
    FROM Dim_Location

CREATE OR REPLACE SECURE VIEW View_Dim_Channel --CREATED AND CHECKED
    AS
    SELECT  
            DimChannelID, 
            ChannelID, 
            ChannelCategoryID, 
            ChannelName, 
            ChannelCategory
    FROM Dim_Channel

CREATE OR REPLACE SECURE VIEW View_Dim_Product --CREATED AND CHECKED
    AS
    SELECT
          DimProductID,
          ProductID, 
          ProductTypeID, 
          ProductCategoryID, 
          ProductName, 
          ProductType, 
          ProductCategory, 
          ProductRetailPrice, 
          ProductWholesalePrice, 
          ProductCost, 
          ProductRetailProfit, 
          ProductWholesaleUnitProfit, 
          ProductProfitMarginUnitPercent
    FROM Dim_Product

CREATE OR REPLACE SECURE VIEW VIEW_DIM_DATE --CREATED AND CHECKED
    AS
    SELECT 
          DATE_PKEY,
          DATE,
          FULL_DATE_DESC,
          DAY_NUM_IN_WEEK,
          DAY_NUM_IN_MONTH,
          DAY_NUM_IN_YEAR,
          DAY_NAME,
          DAY_ABBREV,
          WEEKDAY_IND,
          US_HOLIDAY_IND,
          _HOLIDAY_IND,
          MONTH_END_IND,
          WEEK_BEGIN_DATE_NKEY,
          WEEK_BEGIN_DATE,
          WEEK_END_DATE_NKEY,
          WEEK_END_DATE,
          WEEK_NUM_IN_YEAR,
          MONTH_NAME,
          MONTH_ABBREV,
          MONTH_NUM_IN_YEAR,
          YEARMONTH,
          QUARTER,
          YEARQUARTER,
          YEAR,
          FISCAL_WEEK_NUM,
          FISCAL_MONTH_NUM,
          FISCAL_YEARMONTH,
          FISCAL_QUARTER,
          FISCAL_YEARQUARTER,
          FISCAL_HALFYEAR,
          FISCAL_YEAR,
          SQL_TIMESTAMP,
          CURRENT_ROW_IND,
          EFFECTIVE_DATE,
          EXPIRATION_DATE
      FROM DIM_DATE

CREATE OR REPLACE SECURE VIEW View_Fact_SalesActual -- CREATED AND CHECKED
    AS
    SELECT
          DimProductID,
          DimStoreID,
          DimResellerID,
          DimCustomerID,
          DimChannelID,
          DimSaleDateID,
          DimLocationID,
          SourceSalesHeaderID,
          SourceSalesDetailID,
          SaleAmount,
          SaleQuantity,
          SaleUnitPrice,
          SaleExtendedCost,
          SaleTotalProfit
    FROM Fact_SalesActual

CREATE OR REPLACE SECURE VIEW View_Fact_SRCSalesTarget -- created and checked
    AS
    SELECT 
          DimStoreID,
          DimResellerID,
          DimChannelID,
          DimTargetDateID,
          SalestargetAmount
    FROM Fact_SRCSalestarget
   
CREATE OR REPLACE SECURE VIEW View_Fact_ProductSalesTarget -- CREATED AND CHECKED
    AS
    SELECT
          DimProductID,
          DimTargetDateID,
          ProductTargetSalesQuantity
    FROM Fact_ProductSalesTarget
    
-- Creating views for the questions
--View for StoreLocation to understand regions with more than one store
CREATE OR REPLACE SECURE VIEW View_StoreLocation 
    AS
    SELECT 
          dl.Region, count(*) AS "StoreCount" --ds.StoreNumber, ds.SourceStoreID,
    FROM 
          DIM_STORE AS ds, 
          DIM_LOCATION AS dl
    WHERE 
          dl.DimLocationID = ds.DimLocationID
    GROUP BY dl.Region;
    
--View for store channel sales targets  
CREATE OR REPLACE SECURE VIEW View_StoreChannelSalesTarget 
    AS
    SELECT
          ds.StoreNumber, dc.ChannelID, dc.ChannelName, dd.YEAR, SUM(fsst.SalesTargetAmount) AS "StoreSalesTarget"
    FROM
        FACT_SRCSALESTARGET fsst,
        DIM_STORE ds, 
        DIM_CHANNEL dc,
        DIM_DATE dd
    WHERE
        fsst.DimStoreID = ds.DimStoreID
        AND fsst.DimChannelID = dc.DimChannelID  
        AND ds.StoreNumber IN ('5', '8')
        AND fsst.DimTargetDateID = dd.DATE_PKEY 
    GROUP BY ds.StoreNumber, dc.ChannelID , dc.ChannelName, dd.YEAR;
 
 ---View for product sales targets
CREATE OR REPLACE SECURE VIEW View_StoreProductSalesTarget
    AS
    SELECT 
          dp.ProductID, dp.ProductName, dp.ProductCategory, SUM(fpst.ProductTargetSalesQuantity) AS "TotalStoreProductSalesTarget", dd.YEAR
    FROM 
        FACT_PRODUCTSALESTARGET fpst,
        DIM_PRODUCT dp,
        DIM_DATE dd
    WHERE 
        dp.DimProductID = fpst.DimProductID 
        AND dd.DATE_PKEY = fpst.DimTargetDateID 
    GROUP BY dp.ProductID, dp.ProductName, dp.ProductCategory, dd.YEAR; 

-- View for Sales Data Aggregate  
CREATE OR REPLACE SECURE VIEW View_StoreSalesDataAggregate
    AS
    SELECT
          SUM(fsa.SaleQuantity) AS TotalSaleQuantity, SUM(fsa.SaleAmount) AS TotalSaleAmount, 
          SUM(fsa.SaleExtendedCost) AS "TotalSaleExtendedCost", SUM(fsa.SaleTotalProfit) AS "TotalSaleProfit", ds.StoreNumber, dd.YEAR,
          dp.ProductID, dp.ProductName, dp.ProductCategoryID, dp.ProductCategory, dc.ChannelID, dc.ChannelName           
    FROM 
        FACT_SALESACTUAL fsa, DIM_STORE ds, DIM_DATE dd, DIM_PRODUCT dp, DIM_CHANNEL dc
    WHERE 
         fsa.DimStoreID = ds.DimStoreID 
         AND fsa.DimSaleDateID = dd.DATE_PKEY 
         AND dp.DimProductID = fsa.DimProductID 
         AND dc.DimChannelID = fsa.DimChannelID 
         AND ds.StoreNumber IN ('5', '8')
    GROUP BY  ds.StoreNumber, dd.YEAR,
          dp.ProductID, dp.ProductName, dp.ProductCategoryID, dp.ProductCategory, dc.ChannelID, dc.ChannelName;
          
-- View for product sales aggregate by day of week for stores 5 and 8   
CREATE OR REPLACE SECURE VIEW View_ProductSalesAggregateByDayOfWeek
    AS
    SELECT
    dp.ProductID, dp.ProductName, dp.ProductCategoryID, dp.ProductCategory, ds.StoreNumber, dc.ChannelID, dc.ChannelName,
    dd.DAY_NUM_IN_WEEK, dd.DAY_NAME, SUM(fsa.SaleAmount) AS "SaleTotalAmount",  
    SUM(fsa.SaleQuantity) AS "SaleTotalQuantity", SUM(fsa.SaleExtendedCost) AS "SaleTotalExtendedCost", 
    SUM(fsa.SaleTotalProfit) AS "SaleTotalProfit"
    FROM 
        DIM_PRODUCT dp, DIM_STORE ds, DIM_CHANNEL dc, DIM_DATE dd, FACT_SALESACTUAL fsa
    WHERE 
        fsa.DimStoreID = ds.DimStoreID 
        AND fsa.DimSaleDateID = dd.DATE_PKEY 
        AND dp.DimProductID = fsa.DimProductID 
        AND dc.DimChannelID = fsa.DimChannelID 
        AND ds.StoreNumber IN ('5', '8')
    GROUP BY dp.ProductID, dp.ProductName, dp.ProductCategoryID, dp.ProductCategory, ds.StoreNumber, dc.ChannelID, dc.ChannelName,
    dd.DAY_NUM_IN_WEEK, dd.DAY_NAME;

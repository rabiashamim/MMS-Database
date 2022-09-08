/****** Object:  Procedure [dbo].[ValidateMarginalPriceData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 
CREATE PROCEDURE [dbo].[ValidateMarginalPriceData](			 
			@Year int,
			@Month int,						 
			@SoFileMasterId decimal(18,0)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY
/*
SELECT [MtMarginalPrice_Id]
      ,[MtSOFileMaster_Id]
      ,[MtMarginalPrice_Date]
      ,[MtMarginalPrice_Hour]
      ,[MtMarginalPrice_Price]
      ,[MtMarginalPrice_CreatedBy]
      ,[MtMarginalPrice_CreatedOn]
      ,[MtMarginalPrice_ModifiedBy]
      ,[MtMarginalPrice_ModifiedOn]
      ,[MtMarginalPrice_IsDeleted]
      ,[BmeStatementData_NtdcDateTime]
  FROM [MtMarginalPrice]
*/
DECLARE @COUNT_MP INT=0;
DECLARE @COUNT_NULL_DATE INT=0;
DECLARE @COUNT_NULL_HOUR INT=0;
DECLARE @COUNT_NULL_PRICE INT=0;
--1.3.4. Duplicate hour in Marginal Price data
DECLARE @COUNT_DUPLICATE_HOUR INT=0;
--1.3.5. Hour is missing in Marginal Price Data
DECLARE @COUNT_MISSING_HOUR INT=0;

        select @COUNT_MP = COUNT(1), 
        @COUNT_NULL_DATE=SUM(CASE WHEN C.MtMarginalPrice_Date is null THEN 1 ELSE 0 END),
        @COUNT_NULL_HOUR=SUM(CASE WHEN C.MtMarginalPrice_Hour is null THEN 1 ELSE 0 END),
@COUNT_NULL_PRICE=SUM(CASE WHEN C.MtMarginalPrice_Price is null THEN 1 ELSE 0 END)
FROM [MtMarginalPrice] C WHERE C.MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtMarginalPrice_IsDeleted,0)=0 ;


WITH MP_CTE
AS
(
select c.MtMarginalPrice_Date, c.MtMarginalPrice_Hour
from MtMarginalPrice C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtMarginalPrice_IsDeleted,0)=0 
)
SELECT @COUNT_DUPLICATE_HOUR = COUNT(1)
FROM
( select C.MtMarginalPrice_Date, C.MtMarginalPrice_Hour from MP_CTE C
 GROUP BY C.MtMarginalPrice_Date, C.MtMarginalPrice_Hour
 HAVING COUNT(1)>1) C;

--------------------------------------------
DROP TABLE if EXISTS #TempRows
Declare --@startTime as DATETIME,
--@Year as int=2022,
--@Month as int=11,
@INC_Hour as int=1;
Declare @startTime as DATETIME=DATETIMEFROMPARTS(@Year,@Month,1,0,0,0,0);
Declare @endTime as DATETIME=DATEADD(HOUR,-1,  DATEADD(MONTH,1,@startTime));
--Declare @startTime as DATETIME=DATETIMEFROMPARTS(@Year,@Month,26,0,0,0,0);
--Declare @endTime as DATETIME=DATEADD(HOUR,-1,  DATEADD(Day,2,@startTime));
;with ROWCTE as  
   (  
      SELECT @startTime as dateTimeHour   
		UNION ALL  
      SELECT DATEADD(HOUR, @INC_Hour, dateTimeHour) 
  FROM  ROWCTE  
  WHERE dateTimeHour < @endTime
    )  
 
SELECT * 
INTO #TempRows
FROM ROWCTE
OPTION(MAXRECURSION 0); --There is no way to perform a recursion more than 32767 

WITH MP_CTE
AS
(
select c.MtMarginalPrice_Id,c.MtMarginalPrice_Date, c.MtMarginalPrice_Hour
from MtMarginalPrice C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtMarginalPrice_IsDeleted,0)=0 
)
SELECT @COUNT_MISSING_HOUR =COUNT(1)
FROM #TempRows T 
WHERE Not Exists(select 1 FROM MP_CTE MP where DATEPART(YEAR,T.dateTimeHour)= DATEPART(YEAR, MP.MtMarginalPrice_Date) AND DATEPART(MONTH,T.dateTimeHour)= DATEPART(MONTH, MP.MtMarginalPrice_Date) AND DATEPART(DAY,T.dateTimeHour)= DATEPART(DAY, MP.MtMarginalPrice_Date) AND DATEPART(HOUR,T.dateTimeHour)=MP.MtMarginalPrice_Hour)
and DATEPART(YEAR,T.dateTimeHour)=@Year AND DATEPART(MONTH,T.dateTimeHour)=@Month;

------------------------------------
--SELECT @COUNT_MP as COUNT_MP,
--@COUNT_NULL_DATE as COUNT_NULL_DATE,
--@COUNT_NULL_HOUR as COUNT_NULL_HOUR,
--@COUNT_NULL_PRICE as COUNT_NULL_PRICE,
--@COUNT_DUPLICATE_HOUR as COUNT_DUPLICATE_HOUR,
--@COUNT_MISSING_HOUR as COUNT_MISSING_HOUR;

DECLARE @logMessage_duplicate_hour VARCHAR(MAX),
@logMessage_missing_hour VARCHAR(MAX);

DECLARE @MARGINAL_PRICE_LIST VARCHAR(MAX);

IF(@COUNT_DUPLICATE_HOUR > 0)
BEGIN
SET @MARGINAL_PRICE_LIST=null;

WITH MP_CTE
AS
(
select c.MtMarginalPrice_Date, c.MtMarginalPrice_Hour
from MtMarginalPrice C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtMarginalPrice_IsDeleted,0)=0 
)
 SELECT 
	@MARGINAL_PRICE_LIST = ISNULL(@MARGINAL_PRICE_LIST + ', ', '') + CAST(C.MtMarginalPrice_Date AS NVARCHAR(MAX))+ ' ' +CAST(C.MtMarginalPrice_Hour AS NVARCHAR(MAX)) 
    from MP_CTE C
 GROUP BY C.MtMarginalPrice_Date, C.MtMarginalPrice_Hour
 HAVING COUNT(1)>1;

	SET @logMessage_duplicate_hour ='Missing Total - ' +  CAST(@COUNT_DUPLICATE_HOUR AS NVARCHAR(MAX)) + ': Duplicate hour in Marginal Price Data: '+ @MARGINAL_PRICE_LIST ;
END

IF(@COUNT_MISSING_HOUR > 0)
BEGIN
SET @MARGINAL_PRICE_LIST=null;
WITH MP_CTE
AS
(
select c.MtMarginalPrice_Id,c.MtMarginalPrice_Date, c.MtMarginalPrice_Hour
from MtMarginalPrice C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtMarginalPrice_IsDeleted,0)=0 
)
SELECT 
	@MARGINAL_PRICE_LIST = ISNULL(@MARGINAL_PRICE_LIST + ', ', '') + CAST(T.dateTimeHour AS NVARCHAR(MAX))
FROM #TempRows T 
WHERE Not Exists(select 1 FROM MP_CTE MP where DATEPART(YEAR,T.dateTimeHour)= DATEPART(YEAR, MP.MtMarginalPrice_Date) AND DATEPART(MONTH,T.dateTimeHour)= DATEPART(MONTH, MP.MtMarginalPrice_Date) AND DATEPART(DAY,T.dateTimeHour)= DATEPART(DAY, MP.MtMarginalPrice_Date) AND DATEPART(HOUR,T.dateTimeHour)=MP.MtMarginalPrice_Hour)
and DATEPART(YEAR,T.dateTimeHour)=@Year AND DATEPART(MONTH,T.dateTimeHour)=@Month;

	SET @logMessage_missing_hour ='Missing Total - ' +  CAST(@COUNT_MISSING_HOUR AS NVARCHAR(MAX)) + ': Hour is missing in Marginal Price Data: '+ @MARGINAL_PRICE_LIST ;
END

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_duplicate_hour AS [LOG_MESSAGE], CASE WHEN @logMessage_duplicate_hour IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_duplicate_hour IS NOT NULL
UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_hour AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_hour IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_missing_hour IS NOT NULL


 END TRY
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END

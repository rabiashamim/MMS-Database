/****** Object:  Procedure [dbo].[ValidateAvailibilityData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: June 27, 2022 
-- ALTER date: July 05, 2022   
-- Description: 
--              
-- ============================================= 
-- exec [dbo].[ValidateAvailibilityData] 2021,9,85
CREATE PROCEDURE [dbo].[ValidateAvailibilityData](			 
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
SELECT TOP (1000) [MtAvailibilityData_Id]
      ,[MtSOFileMaster_Id]
      ,[MtGenerationUnit_Id]
      ,[MtAvailibilityData_Date]
      ,[MtAvailibilityData_Hour]
      ,[MtAvailibilityData_AvailableCapacityASC]
      ,[MtAvailibilityData_ActualCapacity]
      ,[MtAvailibilityData_CreatedBy]
      ,[MtAvailibilityData_CreatedOn]
      ,[MtAvailibilityData_ModifiedBy]
      ,[MtAvailibilityData_ModifiedOn]
      ,[MtAvailibilityData_IsDeleted]
  FROM [MtAvailibilityData]
*/
DECLARE @COUNT_AVAILIBILITY INT=0;
DECLARE @COUNT_NULL_DATE INT=0;
DECLARE @COUNT_NULL_HOUR INT=0;
DECLARE @COUNT_NULL_AVAILABLE_CAPACITY_ASC INT=0;
DECLARE @COUNT_NULL_ACTUAL_CAPACITY INT=0;
--1.3.4. Duplicate hour in Marginal Price data
DECLARE @COUNT_DUPLICATE_HOUR INT=0;
--1.3.1. Available Capacity data for any Generation Unit is missing
DECLARE @COUNT_GU_MISSING_HOURS INT=0;

        select @COUNT_AVAILIBILITY = COUNT(1), 
        @COUNT_NULL_DATE=SUM(CASE WHEN C.MtAvailibilityData_Date is null THEN 1 ELSE 0 END),
        @COUNT_NULL_HOUR=SUM(CASE WHEN C.MtAvailibilityData_Hour is null THEN 1 ELSE 0 END),
@COUNT_NULL_AVAILABLE_CAPACITY_ASC=SUM(CASE WHEN C.MtAvailibilityData_AvailableCapacityASC is null THEN 1 ELSE 0 END),
@COUNT_NULL_ACTUAL_CAPACITY=SUM(CASE WHEN C.MtAvailibilityData_ActualCapacity is null THEN 1 ELSE 0 END)
FROM [MtAvailibilityData] C WHERE C.MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtAvailibilityData_IsDeleted,0)=0 ;


WITH Availibility_CTE
AS
(
select c.MtGenerationUnit_Id, c.MtAvailibilityData_Date, c.MtAvailibilityData_Hour
from MtAvailibilityData C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtAvailibilityData_IsDeleted,0)=0
GROUP BY c.MtGenerationUnit_Id, c.MtAvailibilityData_Date, c.MtAvailibilityData_Hour
 HAVING COUNT(1)>1  
)
SELECT @COUNT_DUPLICATE_HOUR = COUNT(1)
FROM Availibility_CTE C;

--------------------------------------------
DROP TABLE if EXISTS #TempRows
Declare --@startTime as DATETIME,
--@Year as int=2022,
--@Month as int=11,
@INC_Hour as int=1;
Declare @startTime as DATETIME=DATETIMEFROMPARTS(@Year,@Month,1,0,0,0,0);
Declare @endTime as DATETIME=DATEADD(HOUR,-1,  DATEADD(MONTH,1,@startTime));
--Declare @startTime as DATETIME=DATETIMEFROMPARTS(@Year,@Month,26,1,0,0,0);
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

DECLARE @TEMP_HOURS INT =0;
SELECT @TEMP_HOURS=COUNT(1) FROM #TempRows;

SELECT distinct c.MtGenerationUnit_Id
into #TempMissingGuHours
FROM
(SELECT c.MtGenerationUnit_Id, COUNT(1) as [NO_HOURS_PER_GU]
FROM MtAvailibilityData C
WHERE DATEPART(YEAR,C.MtAvailibilityData_Date)=@Year AND DATEPART(MONTH,C.MtAvailibilityData_Date)=@Month and C.MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtAvailibilityData_IsDeleted,0)=0 
GROUP by c.MtGenerationUnit_Id
HAVING COUNT(1)<@TEMP_HOURS) as C;

DECLARE @COUNT_MISSING_GU_DATA INT =0;
SELECT  GU.MtGenerationUnit_SOUnitId
into #TempMissingGU
FROM [MtGenerator] G INNER join MtGenerationUnit GU 
on G.MtGenerator_Id=GU.MtGenerator_Id
where ISNULL(g.isDeleted,0)=0 and ISNULL( g.MtGenerator_IsDisabled,0)=0 and ISNULL( GU.isDeleted,0)=0 and GU.MtGenerationUnit_SOUnitId not in
(SELECT c.MtGenerationUnit_Id
FROM MtAvailibilityData C
WHERE DATEPART(YEAR,C.MtAvailibilityData_Date)=@Year AND DATEPART(MONTH,C.MtAvailibilityData_Date)=@Month and C.MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtAvailibilityData_IsDeleted,0)=0 
) ;

set @COUNT_MISSING_GU_DATA=(select count(*) from #TempMissingGuHours) + (select count(*) from #TempMissingGU) ;
------------------------------------

--SELECT @COUNT_AVAILIBILITY as COUNT_AVAILIBILITY,
--@COUNT_NULL_DATE as COUNT_NULL_DATE,
--@COUNT_NULL_HOUR as COUNT_NULL_HOUR,
--@COUNT_NULL_AVAILABLE_CAPACITY_ASC as COUNT_NULL_AVAILABLE_CAPACITY_ASC,
--@COUNT_NULL_ACTUAL_CAPACITY as COUNT_NULL_ACTUAL_CAPACITY,
--@COUNT_GU_MISSING_HOURS as COUNT_GU_MISSING_HOURS;

DECLARE @logMessage_missing_hours VARCHAR(MAX),
@logMessage_duplicate VARCHAR(MAX),
@logMessage_missing_avail_cap VARCHAR(MAX);

DECLARE @GU_LIST  VARCHAR(MAX);

IF(@COUNT_MISSING_GU_DATA > 0)
BEGIN
SET @GU_LIST=null;
SELECT @GU_LIST = ISNULL(@GU_LIST + ', ', '') + CAST(c.MtGenerationUnit_Id AS NVARCHAR(MAX))
 from (
        select * FROM #TempMissingGuHours
        UNION
        select * from #TempMissingGU
    ) as c; 
;
-----------------------------------
	SET @logMessage_missing_hours = 'Missing Total - ' +  CAST(@COUNT_MISSING_GU_DATA AS NVARCHAR(MAX)) + ': Available Capacity for these Generation Unit is missing for particular hour: ' + @GU_LIST ;
END
IF(@COUNT_DUPLICATE_HOUR > 0)
BEGIN
SET @GU_LIST=null;
WITH Availibility_CTE
AS
(
select c.MtGenerationUnit_Id, c.MtAvailibilityData_Date, c.MtAvailibilityData_Hour
from MtAvailibilityData C 
WHERE  C.MtSOFileMaster_Id = @SoFileMasterId AND ISNULL(C.MtAvailibilityData_IsDeleted,0)=0
GROUP BY c.MtGenerationUnit_Id, c.MtAvailibilityData_Date, c.MtAvailibilityData_Hour
 HAVING COUNT(1)>1  
)
SELECT 
		@GU_LIST = ISNULL(@GU_LIST + ', ', '') + CAST(c.MtGenerationUnit_Id AS NVARCHAR(MAX))
FROM Availibility_CTE C;

	SET @logMessage_duplicate = 'Missing Total - ' +  CAST(@COUNT_DUPLICATE_HOUR AS NVARCHAR(MAX)) + ': Duplicate hour in Availability Data for these Generation Units: ' +  @GU_LIST ;
END

IF(@COUNT_NULL_AVAILABLE_CAPACITY_ASC > 0 OR @COUNT_NULL_ACTUAL_CAPACITY > 0)
BEGIN
SET @GU_LIST=null;
SELECT 
	@GU_LIST = ISNULL(@GU_LIST + ', ', '') + CAST(c.MtGenerationUnit_Id AS NVARCHAR(MAX))

FROM [MtAvailibilityData] C WHERE C.MtSOFileMaster_Id=@SoFileMasterId AND ISNULL(C.MtAvailibilityData_IsDeleted,0)=0
 AND (C.MtAvailibilityData_AvailableCapacityASC is null OR C.MtAvailibilityData_ActualCapacity is null);

	SET @logMessage_missing_avail_cap = 'Missing Total - ' +  CAST(@COUNT_NULL_AVAILABLE_CAPACITY_ASC AS NVARCHAR(MAX)) + ': Available Capacity data for these Generation Units is missing: ' + @GU_LIST ;
END

SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_hours AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_hours IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_missing_hours IS NOT NULL

UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_duplicate AS [LOG_MESSAGE], CASE WHEN @logMessage_duplicate IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_duplicate IS NOT NULL

UNION
SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME], @logMessage_missing_avail_cap AS [LOG_MESSAGE], CASE WHEN @logMessage_missing_avail_cap IS NOT NULL THEN 'Warning' ELSE 'Success' END AS [ERROR_LEVEL]
WHERE @logMessage_missing_avail_cap IS NOT NULL


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

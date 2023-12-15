/****** Object:  Procedure [dbo].[CriticalHoursCapacity_Read]    Committed by VersionSQL https://www.versionsql.com ******/

  
  
/********************************************************/  
-- =============================================                        
-- Author: Ammama Gill                                   
-- CREATE date:  14/12/2022                                         
-- ALTER date:                                           
-- Reviewer:                                          
-- Description: Additional Validations for Critical hours.                                     
-- =============================================                                           
-- =============================================                   
  --[CriticalHoursCapacity_Read] 760,1,10
  
CREATE PROCEDURE dbo.CriticalHoursCapacity_Read @pMtSOFileMaster_Id DECIMAL(18, 0)  
, @pPageNumber INT  
, @pPageSize INT  
, @pCriticalHour INT = NULL  
, @pDate nvarchar(64) = NULL  
, @pHour INT = NULL  
, @pSoUnitId INT = NULL  
, @pCapacity DECIMAL(18, 0) = NULL  
, @pIsValid BIT = NULL  
, @pSoUnitName VARCHAR(MAX) = NULL  
  
AS  
BEGIN
 
 BEGIN TRY  
  DECLARE @vStatus VARCHAR(5);
SELECT
	@vStatus = LuStatus_Code
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pMtSOFileMaster_Id;

IF @vStatus = 'UPL'
BEGIN

SELECT
	mchci.MtCriticalHoursCapacity_Id
   ,ROW_NUMBER() OVER (ORDER BY mchci.MtCriticalHoursCapacity_IsValid, mchci.MtCriticalHoursCapacity_Date ASC, mchci.MtCriticalHoursCapacity_Hour, mchci.MtCriticalHoursCapacity_SOUnitId, MtCriticalHoursCapacity_RowNumber) AS MtCriticalHoursCapacity_RowNumber_new
	--  ,mchci.MtCriticalHoursCapacity_RowNumber AS MtCriticalHoursCapacity_RowNumber_new            
   ,mchci.MtCriticalHoursCapacity_CriticalHour AS [Critical Hour]
   ,mchci.MtCriticalHoursCapacity_Date AS [Date]
   ,mchci.MtCriticalHoursCapacity_Hour AS [Hour]
   ,mchci.MtCriticalHoursCapacity_SOUnitId AS [Generator Unit ID]
   ,(SELECT
		TOP 1
			(mgu.MtGenerationUnit_UnitName)
		FROM MtGenerationUnit mgu
		WHERE CAST(mgu.MtGenerationUnit_SOUnitId AS NVARCHAR(MAX)) = NULLIF(mchci.MtCriticalHoursCapacity_SOUnitId, '')
		AND ISNULL(mgu.isDeleted, 0) = 0
		AND ISNULL(mgu.MtGenerationUnit_IsDeleted, 0) = 0)
	AS [Generator Unit Name]
   ,mchci.MtCriticalHoursCapacity_Capacity AS [Capacity]
   ,mchci.MtCriticalHoursCapacity_IsValid AS [IsValid]
   ,mchci.MtCriticalHoursCapacity_Message AS [Reason] INTO #tempCriticalHoursCap_Int
FROM MtCriticalHoursCapacity_Interface mchci
WHERE mchci.MtSOFileMaster_Id = @pMtSOFileMaster_Id
AND mchci.MtCriticalHoursCapacity_IsDeleted = 0
AND (@pDate IS NULL
OR CASE
	WHEN ISDATE(mchci.MtCriticalHoursCapacity_Date) = 0 THEN mchci.MtCriticalHoursCapacity_Date
	ELSE cast (CONVERT(DATE, mchci.MtCriticalHoursCapacity_Date, 101) as varchar(64))
END = CASE
	WHEN ISDATE(CAST(@pDate AS NVARCHAR)) = 1 THEN cast (CONVERT(DATE, @pDate, 101) as varchar(64))
	ELSE @pDate
END)
AND (@pCriticalHour IS NULL
OR mchci.MtCriticalHoursCapacity_CriticalHour = @pCriticalHour)
AND (@pHour IS NULL
OR mchci.MtCriticalHoursCapacity_Hour = @pHour)
AND (@pSoUnitId IS NULL
OR mchci.MtCriticalHoursCapacity_SOUnitId = @pSoUnitId)
AND (@pCapacity IS NULL
OR mchci.MtCriticalHoursCapacity_Capacity = @pCapacity)
AND (@pIsValid IS NULL
OR mchci.MtCriticalHoursCapacity_IsValid = @pIsValid)
AND (@pSoUnitName IS NULL
OR (SELECT
		mgu.MtGenerationUnit_UnitName
	FROM MtGenerationUnit mgu
	WHERE mgu.MtGenerationUnit_SOUnitId = mchci.MtCriticalHoursCapacity_SOUnitId
	AND ISNULL(mgu.isDeleted, 0) = 0
	AND ISNULL(mgu.MtGenerationUnit_IsDeleted, 0) = 0)
LIKE '%' + @pSoUnitName + '%')

-- ORDER BY [Generator Unit ID];            

SELECT
	*
FROM #tempCriticalHoursCap_Int TC
WHERE (MtCriticalHoursCapacity_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)
AND MtCriticalHoursCapacity_RowNumber_new <= (@pPageNumber * @pPageSize))
ORDER BY MtCriticalHoursCapacity_RowNumber_new ASC

SELECT
	COUNT(1) AS FilteredRows
FROM #tempCriticalHoursCap_Int TC;

END
ELSE
BEGIN

SELECT
	mchc.MtCriticalHoursCapacity_Id
   ,ROW_NUMBER() OVER (ORDER BY mchc.MtCriticalHoursCapacity_Date ASC, mchc.MtCriticalHoursCapacity_Hour, MtCriticalHoursCapacity_SOUnitId) AS MtCriticalHoursCapacity_RowNumber_new
   ,mchc.MtCriticalHoursCapacity_CriticalHour AS [Critical Hour]
   ,mchc.MtCriticalHoursCapacity_Date AS [Date]
   ,mchc.MtCriticalHoursCapacity_Hour AS [Hour]
   ,mchc.MtCriticalHoursCapacity_SOUnitId AS [Generator Unit ID]
   ,(SELECT
		TOP 1
			(mgu.MtGenerationUnit_UnitName)
		FROM MtGenerationUnit mgu
		WHERE mgu.MtGenerationUnit_SOUnitId = mchc.MtCriticalHoursCapacity_SOUnitId
		AND ISNULL(mgu.isDeleted, 0) = 0
		AND ISNULL(mgu.MtGenerationUnit_IsDeleted, 0) = 0)
	AS [Generator Unit Name]
   ,mchc.MtCriticalHoursCapacity_Capacity AS [Capacity] INTO #tempCriticalHoursCap
FROM MtCriticalHoursCapacity mchc

WHERE mchc.MtSOFileMaster_Id = @pMtSOFileMaster_Id
AND mchc.MtCriticalHoursCapacity_IsDeleted = 0
AND (@pDate IS NULL
OR CONVERT(VARCHAR(10), mchc.MtCriticalHoursCapacity_Date, 101) = @pDate)
AND (@pCriticalHour IS NULL
OR mchc.MtCriticalHoursCapacity_CriticalHour = @pCriticalHour)
AND (@pHour IS NULL
OR mchc.MtCriticalHoursCapacity_Hour = @pHour)
AND (@pSoUnitId IS NULL
OR mchc.MtCriticalHoursCapacity_SOUnitId = @pSoUnitId)
AND (@pCapacity IS NULL
OR mchc.MtCriticalHoursCapacity_Capacity = @pCapacity)
AND (@pSoUnitName IS NULL
OR (SELECT
		mgu.MtGenerationUnit_UnitName
	FROM MtGenerationUnit mgu
	WHERE mgu.MtGenerationUnit_SOUnitId = mchc.MtCriticalHoursCapacity_SOUnitId
	AND ISNULL(mgu.isDeleted, 0) = 0
	AND ISNULL(mgu.MtGenerationUnit_IsDeleted, 0) = 0)
LIKE '%' + @pSoUnitName + '%')
ORDER BY [Generator Unit ID], [Critical Hour];

SELECT
	*
FROM #tempCriticalHoursCap TC
WHERE (MtCriticalHoursCapacity_RowNumber_new > ((@pPageNumber - 1) * @pPageSize)
AND MtCriticalHoursCapacity_RowNumber_new <= (@pPageNumber * @pPageSize))
ORDER BY MtCriticalHoursCapacity_RowNumber_new ASC

SELECT
	COUNT(1) AS FilteredRows
FROM #tempCriticalHoursCap TC;

END

DROP TABLE IF EXISTS #tempCriticalHoursCap_Int;
DROP TABLE IF EXISTS #tempCriticalHoursCap;


END TRY
BEGIN CATCH
SELECT
	ERROR_NUMBER() AS ErrorNumber
   ,ERROR_STATE() AS ErrorState
   ,ERROR_SEVERITY() AS ErrorSeverity
   ,ERROR_PROCEDURE() AS ErrorProcedure
   ,ERROR_LINE() AS ErrorLine
   ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH

END

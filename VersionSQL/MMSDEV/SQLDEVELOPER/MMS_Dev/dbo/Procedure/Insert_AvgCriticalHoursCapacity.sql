/****** Object:  Procedure [dbo].[Insert_AvgCriticalHoursCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================                
-- Author: Aymen Khalid                  
-- CREATE date:  19/12/2022                                 
-- ALTER date:                                   
-- Reviewer:                                  
-- Description: Insert Average Critical Hours Capacity data.                               
-- =============================================                                   
-- =============================================           
    
CREATE PROCEDURE dbo.Insert_AvgCriticalHoursCapacity   
@pFileMasterId DECIMAL(18, 0),    
@pUserId INT,    
@pIsUseForSettlement BIT,   
@pTblAVGCriticalHoursCapacity [dbo].[MtAvgCriticalHoursCapacity_UDT] READONLY    
AS    
BEGIN
    
 BEGIN TRY      
  
  -----------------------------  
declare @version int=0;
SELECT
	@version = MtSOFileMaster_Version
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId

DECLARE @vMonthId_Current VARCHAR(MAX);      
	SELECT      
	 @vMonthId_Current = LuAccountingMonth_Id      
	FROM MtSOFileMaster      
	WHERE MtSOFileMaster_Id = @pFileMasterId 

DECLARE @pSOFileTemplate INT = 0;
SELECT
	@pSOFileTemplate = LuSOFileTemplate_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId

DECLARE @tempname NVARCHAR(MAX) = NULL;
SELECT
	@tempname = LuSOFileTemplate_Name
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pSOFileTemplate

---------------------------------  
DECLARE @vMtAVGCriticalHoursCapacity_Id INT = 0;
SELECT
	@vMtAVGCriticalHoursCapacity_Id = MAX(ISNULL(@vMtAVGCriticalHoursCapacity_Id, 0))
FROM MtAvgCriticalHoursCapacity;

INSERT INTO [dbo].[MtAvgCriticalHoursCapacity] ([MtSOFileMaster_Id]
, [MtAvgCriticalHoursCapacity_RowNumber]
, [MtAvgCriticalHoursCapacity_SOUnitId]
, [MtAvgCriticalHoursCapacity_AVGCapacity]
, [MtAvgCriticalHoursCapacity_IsValid]
, [MtAvgCriticalHoursCapacity_Message]
, [MtAvgCriticalHoursCapacity_CreatedBy]
, [MtAvgCriticalHoursCapacity_CreatedOn])
	SELECT
		@pFileMasterId
	   ,ROW_NUMBER() OVER (ORDER BY CAST(AvgCriticalHoursCapacity_SOUnitId AS INT)) AS AvgCriticalHoursCapacity_SOUnitId
	   ,AvgCriticalHoursCapacity_SOUnitId
	   ,AvgCriticalHoursCapacity_AVGCapacity
	   ,1
	   ,''
	   ,@pUserId
	   ,GETDATE()
	FROM @pTblAVGCriticalHoursCapacity

--DECLARE @output VARCHAR(MAX);
--DECLARE @pSettlementPeriodId VARCHAR(20);
--SET @pSettlementPeriodId = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
--SET @output = @tempname + 'submitted for approval. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)

--EXEC [dbo].[SystemLogs] @user = @pUserId
--					   ,@moduleName = 'Data Management'
--					   ,@CrudOperationName = 'Create'
--					   ,@logMessage = @output
-------------------------
UPDATE MtSOFileMaster
SET LuStatus_Code = 'DRAF'
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement
WHERE MtSOFileMaster_Id = @pFileMasterId;
------------------------
--SET @output = 'Use for Settlement Enabled for Dataset: ' + @tempname + '. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)

--EXEC [dbo].[SystemLogs] @user = @pUserId
--					   ,@moduleName = 'Data Management'
--					   ,@CrudOperationName = 'Update'
--					   ,@logMessage = @output

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

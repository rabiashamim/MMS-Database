/****** Object:  Procedure [dbo].[Insert_ASCIncreasedGenerationV2]    Committed by VersionSQL https://www.versionsql.com ******/

    
CREATE   PROCEDURE dbo.Insert_ASCIncreasedGenerationV2    
 @fileMasterId decimal(18,0),    
 @UserId Int  
 , @pIsUseForSettlement BIT 
      
AS    
BEGIN
SET NOCOUNT ON;
    
 declare @vMtAscIG_Id Decimal(18,0);

SELECT
	@vMtAscIG_Id = ISNULL(MAX(MtAscIG_Id), 0) + 1
FROM MtAscIG

INSERT INTO [dbo].MtAscIG (MtAscIG_Id
, MtSOFileMaster_Id
, MtGenerationUnit_Id
, MtAscIG_Date
, MtAscIG_Hour
, MtAscIG_VariableCost
, MtAscIG_CreatedBy
, MtAscIG_CreatedOn
, MtAscIG_IsDeleted
, EnergyProduceIfNoAncillaryServices
, Reason
, MTAscIG_NtdcDateTime
, MtAscIG_RowNumber)
	SELECT
		@vMtAscIG_Id + ROW_NUMBER() OVER (ORDER BY MtAscIG_Date) AS num_row
	   ,MtSOFileMaster_Id
	   ,MtGenerationUnit_Id
	   ,MtAscIG_Date
	   ,MtAscIG_Hour
	   ,MtAscIG_VariableCost
	   ,@UserId
	   ,GETUTCDATE()
	   ,0
	   ,CASE
			WHEN EnergyProduceIfNoAncillaryServices = '' THEN '0'
			ELSE EnergyProduceIfNoAncillaryServices
		END
	   ,Reason
	   ,MTAscIG_NtdcDateTime
	   ,MtAscIG_RowNumber
	FROM [MtAscIG_Interface]
	WHERE MtSOFileMaster_Id = @fileMasterId


DECLARE @version INT = 0;
SELECT
	@version = MtSOFileMaster_Version
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId

DECLARE @period INT = 0;
SELECT
	@period = LuAccountingMonth_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId

DECLARE @pSOFileTemplate INT = 0;
SELECT
	@pSOFileTemplate = LuSOFileTemplate_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId

DECLARE @tempname NVARCHAR(MAX) = NULL;
SELECT
	@tempname = LuSOFileTemplate_Name
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pSOFileTemplate

--DECLARE @output VARCHAR(MAX);
--DECLARE @pSettlementPeriodId VARCHAR(20);
--SET @pSettlementPeriodId = [dbo].[GetSettlementMonthYear](@period)
--SET @output = @tempname + 'submitted for approval. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ',Version:' + CONVERT(VARCHAR(MAX), @version)

--EXEC [dbo].[SystemLogs] @user = @UserId
--					   ,@moduleName = 'Data Management'
--					   ,@CrudOperationName = 'Create'
--					   ,@logMessage = @output

---------isusefor settlement update flag
UPDATE MtSOFileMaster
SET LuStatus_Code = 'DRAF'
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement
WHERE MtSOFileMaster_Id = @fileMasterId;

------------logs------    
--SET @output = 'Use for Settlement Enabled for Dataset: ' + @tempname + '. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ',Version:' + CONVERT(VARCHAR(MAX), @version)

--EXEC [dbo].[SystemLogs] @user = @UserId
--					   ,@moduleName = 'Data Management'
--					   ,@CrudOperationName = 'Update'
--					   ,@logMessage = @output



--select * from [MtAvailibilityData_Interface] WHERE MtSOFileMaster_Id=295    
--select *  from [MtAvailibilityData] WHERE MtSOFileMaster_Id=295    

END

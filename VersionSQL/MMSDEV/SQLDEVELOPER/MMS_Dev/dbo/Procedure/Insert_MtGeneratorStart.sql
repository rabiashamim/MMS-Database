/****** Object:  Procedure [dbo].[Insert_MtGeneratorStart]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE TYPE [dbo].[GeneratorStartUDT] AS TABLE(  
      
--    [Date] date,  
-- [GeneratorUnitId] decimal(18,0),  
-- [NoOfStarts] decimal(18,2),  
-- [UnitCost] decimal(18,2) ,  
-- [CostDetermined] VARCHAR(MAX),  
-- [ValidationStatus] VARCHAR(MAX),   
-- [Reason] VARCHAR(MAX)   
--)  
--GO  
  
  
CREATE PROCEDURE dbo.Insert_MtGeneratorStart  
 @fileMasterId decimal(18,0),  
 @UserId Int  
   , @tblGeneratorStart [dbo].[GeneratorStartUDT] READONLY
   ,@pIsUseForSettlement bit
   
AS  
BEGIN
SET NOCOUNT ON;
  
 declare @vMtGeneratorStart_Id Decimal(18,0);

SELECT
	@vMtGeneratorStart_Id = ISNULL(MAX(MtGeneratorStart_Id), 0)
FROM MtGeneratorStart

DECLARE @vMonthId_Current VARCHAR(MAX);
SELECT
	@vMonthId_Current = LuAccountingMonth_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId

DECLARE @version INT = 0;
SELECT
	@version = MtSOFileMaster_Version
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

INSERT INTO MtGeneratorStart (MtGeneratorStart_Id
, MtSOFileMaster_Id
, MtGenerationUnit_Id
, MtGeneratorStart_Date
, MtGeneratorStart_NoOfStarts
, MtGeneratorStart_UnitCost
, MtGeneratorStart_CostDetermined
, MtGeneratorStart_CreatedBy
, MtGeneratorStart_CreatedOn
, MtGeneratorStart_IsDeleted)
	SELECT
		@vMtGeneratorStart_Id + ROW_NUMBER() OVER (ORDER BY [GeneratorUnitId]) AS num_row
	   ,@fileMasterId
	   ,[GeneratorUnitId]
	   ,[Date]
	   ,[NoOfStarts]
	   ,[UnitCost]
	   ,[CostDetermined]
	   ,@UserId
	   ,GETUTCDATE()
	   ,0
	FROM @tblGeneratorStart

UPDATE MtSOFileMaster
SET LuStatus_Code = 'DRAF'
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement
WHERE MtSOFileMaster_Id = @fileMasterId;


DECLARE @output VARCHAR(MAX);
DECLARE @period VARCHAR(20);
SET @period = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
SET @output = +@tempname + ' submitted for approval. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)

EXEC [dbo].[SystemLogs] @user = @UserId
					   ,@moduleName = 'Data Management'
					   ,@CrudOperationName = 'Create'
					   ,@logMessage = @output


----------------------
SET @output = 'Use for Settlement Enabled for Dataset: ' + @tempname + '. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ',Version:' + CONVERT(VARCHAR(MAX), @version)

EXEC [dbo].[SystemLogs] @user = @UserId
					   ,@moduleName = 'Data Management'
					   ,@CrudOperationName = 'Update'
					   ,@logMessage = @output
END

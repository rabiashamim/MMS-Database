/****** Object:  Procedure [dbo].[Insert_ASCReducedGenerationV2]    Committed by VersionSQL https://www.versionsql.com ******/

      
CREATE   PROCEDURE dbo.Insert_ASCReducedGenerationV2      
 @fileMasterId decimal(18,0),      
 @UserId Int ,
 @pIsUseForSettlement bit
        
AS      
BEGIN      
    SET NOCOUNT ON;      
 declare @vMtAscRG_Id Decimal(18,0);      
  declare @version int=0; 
  declare @tempname NVARCHAR(MAX)=NULL;
  DECLARE @vMtSecurityCoverMP_Id INT = 0;
  DECLARE @pSOFileTemplate INT = 0; 

 SELECT @vMtAscRG_Id=ISNUll(MAX(MtAscRG_Id),0)+1 FROM MtAscRG    
 
 SELECT
	@version = MtSOFileMaster_Version
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId

SELECT
	@pSOFileTemplate = LuSOFileTemplate_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId 

SELECT
	@tempname = LuSOFileTemplate_Name
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pSOFileTemplate

DECLARE @vMonthId_Current VARCHAR(MAX);
SELECT
	@vMonthId_Current = LuAccountingMonth_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @fileMasterId
    
INSERT INTO [dbo].MtAscRG      
(    
 MtAscRG_Id  
,MtSOFileMaster_Id  
,MtGenerationUnit_Id  
,MtAscRG_Date  
,MtAscRG_Hour  
,MtAscRG_ExpectedEnergy  
,MtAscRG_VariableCost  
,MtAscRG_CreatedBy  
,MtAscRG_CreatedOn  
,MtAscRG_IsDeleted  
,GenerationUnitTypeARE  
,MTAscRG_NtdcDateTime  
,MtAscRG_RowNumber   
)    
 SELECT       
 @vMtAscRG_Id +ROW_NUMBER() OVER(order by MtAscRG_Date) AS num_row       
,MtSOFileMaster_Id  
,MtGenerationUnit_Id  
,MtAscRG_Date  
,MtAscRG_Hour  
,CASE WHEN MtAscRG_ExpectedEnergy='' THEN '0' ELSE MtAscRG_ExpectedEnergy END  
,MtAscRG_VariableCost  
,@UserId  
,GETUTCDATE()    
,0  
,GenerationUnitTypeARE  
,MTAscRG_NtdcDateTime  
,MtAscRG_RowNumber   
FROM       
[MtAscRG_Interface]        
WHERE       
MtSOFileMaster_Id=@fileMasterId      

--DECLARE @output VARCHAR(MAX);
--DECLARE @period VARCHAR(20);
--SET @period = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
--SET @output = +@tempname+' submitted for approval. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)

--EXEC [dbo].[SystemLogs] @user = @UserId
--					   ,@moduleName = 'Data Management'
--					   ,@CrudOperationName = 'Create'
--					   ,@logMessage = @output

-------------settlement update flag

UPDATE MtSOFileMaster
SET LuStatus_Code = 'DRAF'
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement
WHERE MtSOFileMaster_Id = @fileMasterId;

------------------------ logs--------------         
--SET @output = 'Use for Settlement Enabled for Dataset: ' +@tempname+'. Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ',Version:' + CONVERT(VARCHAR(MAX), @version)

--EXEC [dbo].[SystemLogs] @user = @UserId
--					   ,@moduleName = 'Data Management'
--					   ,@CrudOperationName = 'Update'
--					   ,@logMessage = @output
       
END 

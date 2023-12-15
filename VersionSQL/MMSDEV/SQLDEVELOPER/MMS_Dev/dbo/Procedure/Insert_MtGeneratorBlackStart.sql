/****** Object:  Procedure [dbo].[Insert_MtGeneratorBlackStart]    Committed by VersionSQL https://www.versionsql.com ******/

--CREATE  TYPE [dbo].[GeneratorBlackStartUDT] AS TABLE(  
      
--    [Date] date,  
-- [GeneratorUnitId] decimal(18,0),  
-- [CapabilityCharges] decimal(18,2),  
-- [Remarks] VARCHAR(MAX),   
-- [ValidationStatus] VARCHAR(MAX),   
-- [Reason] VARCHAR(MAX)   
--)  
--GO  
  
  
CREATE PROCEDURE dbo.Insert_MtGeneratorBlackStart  
 @fileMasterId decimal(18,0),  
 @UserId Int  
, @tblGeneratorBlackStart [dbo].[GeneratorBlackStartUDT] READONLY
, @pIsUseForSettlement bit
   
AS  
BEGIN  
    SET NOCOUNT ON;  
 declare @vMtGeneratorBlackStart_Id Decimal(18,0);  
  
 SELECT @vMtGeneratorBlackStart_Id=ISNUll(MAX(MtGeneratorBS_Id),0) FROM MtGeneratorBS    
   
     declare @version int=0;  
   select @version=MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId   
  
    declare @pSOFileTemplate int=0;  
    select @pSOFileTemplate=LuSOFileTemplate_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId   
  
  DECLARE @vMonthId_Current VARCHAR(MAX);      
	SELECT      
	 @vMonthId_Current = LuAccountingMonth_Id      
	FROM MtSOFileMaster      
	WHERE MtSOFileMaster_Id = @fileMasterId 
   declare @tempname NVARCHAR(MAX)=NULL;  
    SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate  
    
    INSERT INTO MtGeneratorBS  
 (  
  MtGeneratorBS_Id       
 ,MtSOFileMaster_Id  
 ,MtGenerationUnit_Id  
 ,MtGeneratorBS_Date  
 ,MtGeneratorBS_BSCharges  
 ,MtGeneratorBS_CreatedBy  
 ,MtGeneratorBS_CreatedOn  
 ,MtGeneratorBS_BSRemarks  
 ,MtGeneratorBS_IsDeleted  
 )  
    SELECT   
  @vMtGeneratorBlackStart_Id +ROW_NUMBER() OVER(order by [GeneratorUnitId]) AS num_row   
  ,@fileMasterId  
  ,[GeneratorUnitId]  
  ,[Date]  
  ,[CapabilityCharges]  
  ,@UserId  
  ,GETUTCDATE()  
  ,[Remarks]  
  ,0  
 FROM @tblGeneratorBlackStart  
  
  ------------------------
    
   declare @output VARCHAR(max);
   DECLARE @pSettlementPeriodId VARCHAR(20);
   SET @pSettlementPeriodId = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
   SET @output= @tempname+'submitted for approval. Settlement Period:' +convert(varchar(max),@pSettlementPeriodId) +' ,Version:' + convert(varchar(max),@version)   
  
    EXEC [dbo].[SystemLogs]   
    @user=@UserId,  
     @moduleName='Data Management',    
     @CrudOperationName='Create',    
     @logMessage=@output 

---------------------------
  UPDATE MtSOFileMaster  
  SET LuStatus_Code = 'DRAF'  
     ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement  
  WHERE MtSOFileMaster_Id = @fileMasterId;  
    
 ------------------------------ 
    SET @output = 'Use for Settlement Enabled for Dataset: ' + @tempname + '. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ' ,Version:' + CONVERT(VARCHAR(MAX), @version)

EXEC [dbo].[SystemLogs] @user = @UserId
					   ,@moduleName = 'Data Management'
					   ,@CrudOperationName = 'Update'
					   ,@logMessage = @output 
END  
  

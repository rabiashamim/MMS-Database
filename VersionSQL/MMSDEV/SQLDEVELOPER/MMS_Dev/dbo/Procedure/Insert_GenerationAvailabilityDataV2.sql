/****** Object:  Procedure [dbo].[Insert_GenerationAvailabilityDataV2]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
CREATE   PROCEDURE dbo.Insert_GenerationAvailabilityDataV2      
 @fileMasterId decimal(18,0),      
 @UserId Int 
 ,@pIsUseForSettlement bit
        
AS      
BEGIN      
    SET NOCOUNT ON;      
 declare @vMtAvailabilityData_Id Decimal(18,0);      
      
 SELECT @vMtAvailabilityData_Id=ISNUll(MAX(MtAvailibilityData_Id),0)+1 FROM MtAvailibilityData        
       
      
  INSERT INTO [dbo].MtAvailibilityData      
           (MtAvailibilityData_Id      
     ,MtAvailibilityData_RowNumber       
           ,[MtSOFileMaster_Id]      
           ,MtAvailibilityData_Date      
           ,[MtAvailibilityData_Hour]      
     ,MtGenerationUnit_Id      
           ,[MtAvailibilityData_AvailableCapacityASC]      
     ,[MtAvailibilityData_ActualCapacity]      
           ,MtAvailibilityData_CreatedBy      
           ,MtAvailibilityData_CreatedOn      
           ,MtAvailibilityData_IsDeleted  
     ,MtAvailibilityData_SyncStatus  
     ,MtAvailibilityData_GeneratingCapacity)      
         
    SELECT       
  @vMtAvailabilityData_Id +ROW_NUMBER() OVER(order by MtAvailibilityData_Date) AS num_row ,      
  MtAvailibilityData_RowNumber,      
  MtSOFileMaster_Id,      
  CAST(MtAvailibilityData_Date AS DATE),      
  MtAvailibilityData_Hour,      
  MtGenerationUnit_Id,      
  CAST(MtAvailibilityData_AvailableCapacityASC AS DECIMAL(18,3)) * 1000,  -- converting MW to kW    
  CAST(MtAvailibilityData_ActualCapacity AS DECIMAL(18,3)) * 1000      
     ,@UserId      
  ,GETUTCDATE()      
  ,0  
  ,MtAvailibilityData_SyncStatus  
  ,MtAvailibilityData_GeneratingCapacity  
 FROM       
  [MtAvailibilityData_Interface]      
 WHERE       
 MtSOFileMaster_Id=@fileMasterId      
      
      
  declare @version int=0;  
   select @version=MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId  
  
    declare @vMonthId_Current int=0;  
    select @vMonthId_Current =LuAccountingMonth_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId  
  
    declare @pSOFileTemplate int=0;  
    select @pSOFileTemplate=LuSOFileTemplate_Id from MtSOFileMaster where MtSOFileMaster_Id=@fileMasterId  
  
    declare @tempname NVARCHAR(MAX)=NULL;  
    SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate  
  
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
      
 --select * from [MtAvailibilityData_Interface] WHERE MtSOFileMaster_Id=295      
 --select *  from [MtAvailibilityData] WHERE MtSOFileMaster_Id=295      
       
END     
    

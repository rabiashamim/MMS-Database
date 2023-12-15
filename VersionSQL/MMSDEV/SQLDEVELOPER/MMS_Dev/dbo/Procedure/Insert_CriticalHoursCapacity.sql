/****** Object:  Procedure [dbo].[Insert_CriticalHoursCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

/******************************************************************/  
-- =============================================                    
-- Author: Ammama Gill                               
-- CREATE date:  14/12/2022                                     
-- ALTER date:                                       
-- Reviewer:                                      
-- Description: Insert Critical Hours Capacity data into the interface table and validate the inserted data.                                   
-- =============================================                                       
-- =============================================               
  
  
CREATE PROCEDURE dbo.Insert_CriticalHoursCapacity  
@pFileMasterId DECIMAL(18, 0)  
, @pUserId INT  
, @pIsUseForSettlement BIT  
  
AS  
BEGIN  
  
 BEGIN TRY  
 --------------------------------------------------  
    declare @version int=0;  
   select @version=MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@pFileMasterId   
  
    declare @pSOFileTemplate int=0;  
    select @pSOFileTemplate=LuSOFileTemplate_Id from MtSOFileMaster where MtSOFileMaster_Id=@pFileMasterId  
    declare @period int=0;  
    --select @period =LuAccountingMonth_Id from MtSOFileMaster where MtSOFileMaster_Id=@pFileMasterId and LuSOFileTemplate_Id=@pSOFileTemplate
  
  DECLARE @vMonthId_Current VARCHAR(MAX);      
	SELECT      
	 @vMonthId_Current = LuAccountingMonth_Id      
	FROM MtSOFileMaster      
	WHERE MtSOFileMaster_Id = @pFileMasterId 
   declare @tempname NVARCHAR(MAX)=NULL;  
    SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate  
-------------------------------------------------------------  
  DECLARE @vMtCriticalHoursCapacity_Id INT = 0;  
  SELECT  
   @vMtCriticalHoursCapacity_Id = MAX(ISNULL(mchc.MtCriticalHoursCapacity_Id, 0))  
  FROM MtCriticalHoursCapacity mchc;  
  
  INSERT INTO MtCriticalHoursCapacity (MtSOFileMaster_Id,  
  MtCriticalHoursCapacity_RowNumber,  
  MtCriticalHoursCapacity_CriticalHour,  
  MtCriticalHoursCapacity_Date,  
  MtCriticalHoursCapacity_Hour,  
  MtCriticalHoursCapacity_SOUnitId,  
  MtCriticalHoursCapacity_Capacity,  
  MtCriticalHoursCapacity_CreatedBy,  
  MtCriticalHoursCapacity_CreatedOn)  
   SELECT  
    mchci.MtSOFileMaster_Id  
      ,@vMtCriticalHoursCapacity_Id + ROW_NUMBER() OVER (ORDER BY mchci.MtCriticalHoursCapacity_SOUnitId, MtCriticalHoursCapacity_CriticalHour) AS MtCriticalHoursCapacity_RowNumber  
      ,mchci.MtCriticalHoursCapacity_CriticalHour  
      ,mchci.MtCriticalHoursCapacity_Date  
      ,mchci.MtCriticalHoursCapacity_Hour  
      ,mchci.MtCriticalHoursCapacity_SOUnitId  
      ,mchci.MtCriticalHoursCapacity_Capacity  
      ,@pUserId  
      ,GETDATE()  
   FROM MtCriticalHoursCapacity_Interface mchci  
   WHERE mchci.MtSOFileMaster_Id = @pFileMasterId  
  
  
   declare @output VARCHAR(max);
   DECLARE @pSettlementPeriodId VARCHAR(20);
   SET @pSettlementPeriodId = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
   SET @output= @tempname+'submitted for approval. Settlement Period:' +convert(varchar(max),@pSettlementPeriodId) +',Version:' + convert(varchar(max),@version)   
  
  --  EXEC [dbo].[SystemLogs]   
  --  @user=@pUserId,  
  --   @moduleName='Data Management',    
  --   @CrudOperationName='Create',    
  --   @logMessage=@output   
  
  UPDATE MtSOFileMaster  
  SET LuStatus_Code = 'DRAF'  
     ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement  
  WHERE MtSOFileMaster_Id = @pFileMasterId;  
  
  DELETE FROM MtCriticalHoursCapacity_Interface  
  WHERE MtSOFileMaster_Id = @pFileMasterId;  

  --------------------------
--  SET @output = 'Use for Settlement Enabled for Dataset: ' + @tempname + '. Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementPeriodId) + ',Version:' + CONVERT(VARCHAR(MAX), @version)

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

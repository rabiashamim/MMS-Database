/****** Object:  Procedure [dbo].[SofileMaster_Insert]    Committed by VersionSQL https://www.versionsql.com ******/

            
CREATE   PROCEDURE dbo.SofileMaster_Insert              
 @pSettlementPeriod INT              
,@pDescription NVARCHAR(MAX)     =null         
,@pSOFileTemplate INT              
,@pFilename NVARCHAR(max)=null              
,@pPath NVARCHAR(MAX)=null       
,@pUserId INT 
,@MtSOFileMaster_Id Decimal(18,0)=null out
AS              
BEGIN           
      
 BEGIN TRY          
         
      
--Declare @MtSOFileMaster_Id int ;      
SELECT  @MtSOFileMaster_Id =IsNull(MAX( [MtSOFileMaster_Id] ) + 1,1) from MtSOFileMaster       
      
DECLARE @vLuDataConfiguration_Id INT;      
SELECT @vLuDataConfiguration_Id=LuDataConfiguration_Id FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@pSOFileTemplate      
      
      
INSERT INTO MtSOFileMaster(              
 MtSOFileMaster_Id              
 ,LuSOFileTemplate_Id              
 ,LuAccountingMonth_Id              
 ,MtSOFileMaster_FileName              
 ,MtSOFileMaster_FilePath,              
 MtSOFileMaster_IsUseForSettlement,              
 LuStatus_Code,              
 MtSOFileMaster_Version,              
 MtSOFileMaster_Description,              
 MtSOFileMaster_CreatedBy,              
 MtSOFileMaster_CreatedOn,        
 MtSOFileMaster_ApprovalStatus,      
 LuDataConfiguration_Id      
 )              
VALUES(               
 @MtSOFileMaster_Id              
,@pSOFileTemplate              
,@pSettlementPeriod              
,@pFilename              
,@pPath              
,0              
,case WHEN @vLuDataConfiguration_Id = 2 then 'GENE' ELSE 'UPL' END              
,(              
    select (ISNULL(max(MtSOFileMaster_Version),0)+1)              
    from MtSOFileMaster               
    where LuSOFileTemplate_Id=@pSOFileTemplate               
    and LuAccountingMonth_Id=@pSettlementPeriod               
    and isnull(MtSOFileMaster_IsDeleted,0)=0               
    and LuStatus_Code='APPR')              
,@pDescription,1,GETDATE()        
,'Draft'        
,@vLuDataConfiguration_Id      
)      
      
      
              
SELECT @MtSOFileMaster_Id               
-------------------------------------------------------------------------      
--      
-------------------------------------------------------------------------      
DECLARE @vYear INT,@vMonth INT,  
@vFromDate Date, @vToDate Date  
SELECT       
 @vYear=LuAccountingMonth_Year , @vMonth=LuAccountingMonth_Month       
 ,@vFromDate=LuAccountingMonth_FromDate, @vToDate=LuAccountingMonth_ToDate  
FROM       
 LuAccountingMonth       
WHERE       
 LuAccountingMonth_Id=@pSettlementPeriod      
 AND LuAccountingMonth_IsDeleted=0      
      
-------------------------------------------------------------------------      
--      
-------------------------------------------------------------------------      
IF EXISTS(SELECT 1 FROM LuSOFileTemplate WHERE LuSOFileTemplate_Id = @pSOFileTemplate AND LuDataConfiguration_Id=2)      
BEGIN      
 IF @pSOFileTemplate=9      
 BEGIN      
  EXEC [dbo].[ContractReg_GenerateCapacityProfile] @vFromDate,@vToDate,@MtSOFileMaster_Id,@pUserId      
 END      
 IF @pSOFileTemplate=8      
  EXEC [dbo].[ContractReg_GenerateEnergyProfile]   @vYear,@vMonth,@MtSOFileMaster_Id,@pUserId      
 END      
      
       
declare @LuSOFileTemplate_Id int;      
SELECT @LuSOFileTemplate_Id=LuSOFileTemplate_Id  FROM MtSOFileMaster where MtSOFileMaster_Id= @MtSOFileMaster_Id      
      
 Declare @version int;      
select @version =MtSOFileMaster_Version from MtSOFileMaster where MtSOFileMaster_Id=@MtSOFileMaster_Id      
  DECLARE @pSettlementProcessId1 VARCHAR(20);    
declare @tempname NVARCHAR(MAX)=NULL;      
SELECT @tempname=LuSOFileTemplate_Name FROM LuSOFileTemplate WHERE  LuSOFileTemplate_Id=@LuSOFileTemplate_Id      
 declare @output VARCHAR(max);      
    set @pSettlementProcessId1 = [dbo].[GetSettlementMonthYear] (@pSettlementPeriod)    
   SET @output=@tempname+' sheet uploaded. Settlement Period:' +convert(varchar(max),@pSettlementProcessId1) +' ,Version:' + convert(varchar(max),@version)+ ', File Master Id: ' +CONVERT(VARCHAR(MAX), @MtSOFileMaster_Id)      
        
    EXEC [dbo].[SystemLogs]       
    @user=@pUserId,      
     @moduleName='Data Management',        
     @CrudOperationName='Create',        
     @logMessage=@output    
     
 END TRY          
    BEGIN CATCH          
        SELECT ERROR_NUMBER() AS ErrorNumber,          
               ERROR_STATE() AS ErrorState,          
               ERROR_SEVERITY() AS ErrorSeverity,          
               ERROR_PROCEDURE() AS ErrorProcedure,          
               ERROR_LINE() AS ErrorLine,          
               ERROR_MESSAGE() AS ErrorMessage;          
    END CATCH;          
END 

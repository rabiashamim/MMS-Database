/****** Object:  Procedure [dbo].[WF_InsertHistory_data_interface]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
CREATE   procedure dbo.WF_InsertHistory_data_interface                                      
    @RuModuleId int,                                      
    @ProcessId as decimal(18, 0),                                      
    @Process_Template_Id int,                                      
    @level_id int,                                      
    @WF_status char(4),                                      
    @comments nvarchar(256) = null,                                      
    @To_resource decimal(18, 0) = null,                                      
    @Last_level_WF_status char(4) = null,                                      
    @user_id decimal(18, 0) =0 ,          
 @interface_chain_count int          
as             

          
Declare            
 @WorkFlowHeader_id int,            
 @RuModulesProcessID int,            
 @NotificationSubject nvarchar(256),            
 @process_name varchar(256),        
 @RuNotificationSetup_EmailSubject varchar(max),                                                            
 @RuNotificationSetup_EmailBody varchar(max)      
    
     
    
            
            
 select @RuModulesProcessID= RuModulesProcess_Id,@process_name= RuModulesProcess_Name from RuModulesProcess where RuModules_Id=@RuModuleId and RuModulesProcess_ProcessTemplateId=@Process_Template_Id and ISNULL(RuModulesProcess_IsDeleted,0)=0;            



          
select @WorkFlowHeader_id=RuWorkFlowHeader_id from RuWorkFlow_header where RuModulesProcess_Id=@RuModulesProcessID          
    
    
   if @RuModuleId=3      
   begin       
    select  @process_name=LuSOFileTemplate_Name      
 from MtSOFileMaster mt_p                                                                           
  inner join LuSOFileTemplate SPD                                                        
        on SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id                                     
where IsNull(MtSOFileMaster_IsDeleted, 0) = 0                                                        
      and mt_p.MtSOFileMaster_Id = @ProcessId           
      
   end    
    
    
        
Declare @subject as nvarchar(max)              
declare @subject_query as nvarchar(max)        
DECLARE @where AS VARCHAR(MAX)              
        
SELECT              
 @where = RuModulesProcessDetails_ColumnName              
FROM RuModulesProcessDetails              
WHERE RuModulesProcess_Id = @RuModulesProcessID       
and isnull(RuModulesProcessDetails_IsDeleted,0)=0   
AND ISNULL(RuModulesProcessDetails_IsWhere, 0) = 1            
        
select  @subject=STRING_AGG( CONCAT('cast(',RuModulesProcessDetails_ColumnName,' as NVARCHAR(MAX))' ),'+''|''+')   
from RuModulesProcessDetails where RuModulesProcess_Id=@RuModulesProcessID and RuModulesProcessDetails_IsSubject=1   
and isnull(RuModulesProcessDetails_IsDeleted,0)=0   
set @subject=''+@subject+''              
select @RuNotificationSetup_EmailSubject= CONCAT(''''+RuNotificationSetup_EmailSubject+ ''' ' , ' +', @subject)              
FROM RuNotificationSetup              
WHERE RuNotificationSetup_CategoryKey = 'Submitted'          
        
        
select @subject_query=Concat('select @Result=',@RuNotificationSetup_EmailSubject, +' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@ProcessId)            
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcessID               
            
DECLARE @outCount1 nvarchar(max)              
DECLARE @parameters NVARCHAR(255) = '@Result nvarchar(max) OUTPUT'               
EXEC sp_executeSQL @subject_query, @parameters, @Result = @outCount1 OUTPUT;              
              
set @NotificationSubject=@outCount1        
        
                
DECLARE           
  @authorized_approver DECIMAL(18, 0)                  
    ,@max_sequence_id INT                  
    ,@max_level_id INT                  
    ,@module_id INT                       
    ,@initiator DECIMAL(18, 0)                  
              
SELECT                  
 @authorized_approver = AspNetUsers_UserId                  
FROM RuWorkFlow_detail_Interface                  
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
AND mtProcess_ID = @ProcessId                  
AND RuWorkFlow_detail_gen_level = @level_id                  
AND ISNULL(is_deleted, 0) = 0                
                  
IF @authorized_approver != @user_id                  
 AND @WF_status != 'WFRR'                  
 AND @Last_level_WF_status != 'WFRA'                  
BEGIN                  
SELECT                  
 -1 AS error_Code                  
   ,'User is not authorized for this level approval, Please check WF Hierarchy defined or contact administrator.' AS error_description                  
RETURN                  
END                  
                  
SELECT                  
 @initiator = AspNetUsers_UserId                  
FROM RuWorkFlow_detail_Interface                  
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
AND RuWorkFlow_detail_gen_level = 1               
AND mtProcess_ID = @ProcessId                  
AND ISNULL(is_deleted, 0) = 0                  
                 
                  
DECLARE @sequence_id INT                  
SET @sequence_id = 0                  
SET @sequence_id = ISNULL((SELECT                  
  MAX(MtWFHistory_SequenceID)                  
 FROM MtWFHistory                  
 WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
 AND MtWFHistory_Process_id = @ProcessId)                  
,                  
0                  
) + 1                  

  
INSERT INTO MtWFHistory                  
 SELECT                  
  @WorkFlowHeader_id                  
    ,@ProcessId                  
    ,ISNULL(NULLIF(@process_name, ''), @ProcessId)                  
    ,@level_id                  
    ,@sequence_id                  
    ,GETDATE()                  
    , /*@WF_status_name*/                  
  @WF_status                  
    ,@user_id                  
    ,CASE                  
   WHEN @WF_status IN ('WFRI', 'WFRA') THEN @To_resource                  
   ELSE CASE                  
     WHEN @interface_chain_count > 1 AND                  
      @WF_status NOT IN ('WFRJ', 'WFAJ') THEN AspNetUsers_UserId                  
     WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN @initiator                  
     ELSE NULL                  
    END                  
  END                  
    ,@comments                  
    ,0                  
    ,CASE                  
   WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1                  
   ELSE 0                  
  END                  
    ,@NotificationSubject                  
    ,@user_id                  
    ,GETDATE()                  
    ,NULL                  
    ,NULL                  
    ,CASE                  
   WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1                  
   ELSE 0                  
  END                  
    ,                  
  --/*                                              
  CASE                  
   WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1                  
   ELSE 0                  
  END                  
    ,       --*/                                                 
  --1                                  
  0                  
 FROM RuWorkFlow_detail_Interface                  
 WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
 AND mtProcess_ID = @ProcessId                  
 AND ISNULL(is_deleted, 0) = 0                  
 AND RuWorkFlow_detail_gen_level =                
 CASE                  
  WHEN (               
   @WF_status = 'WFSM' AND                  
   @level_id != @interface_chain_count                  
   ) OR                  
   (                  
   @WF_status = 'WFAP' AND                  
   @level_id < @interface_chain_count                  
   ) -- in('WFSM','WFAP')                                                                                        
  THEN @level_id + 1                  
  ELSE @level_id                  
 END                  
DECLARE @MtWFHistory_ToResource DECIMAL(18, 0)                  
SELECT                  
 @MtWFHistory_ToResource = MtWFHistory_ToResource                  
FROM MtWFHistory                  
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
AND MtWFHistory_Process_id = @ProcessId                  
AND MtWFHistory_SequenceID = @sequence_id                  
                  
UPDATE RuWorkFlow_detail_Interface                  
SET is_locked = 1                  
WHERE AspNetUsers_UserId = @MtWFHistory_ToResource                
AND ISNULL(is_deleted, 0) = 0                  
                  
--Set Approval status ='InProcess' when process is submitted and not fully approved                                                                                                       
--Get contract activity ID to mark if the final decission i.e. approve or reject is done                                      
DECLARE @MtContractRegistrationActivity_Id DECIMAL(18, 0)                  
                  
SELECT TOP 1                  
 @MtContractRegistrationActivity_Id = MtContractRegistrationActivity_Id                  
FROM MtContractRegistrationActivities                  
WHERE MtContractRegistration_Id = @ProcessId                  
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0                  
ORDER BY MtContractRegistrationActivity_Id DESC                  
               
          
UPDATE MtWFHistory                  
SET MtWFHistory_ProcessRejected =                  
CASE                  
 WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1                  
 ELSE 0                  
END                  
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
AND MtWFHistory_Process_id = @ProcessId                  
                
                    
IF @level_id = @interface_chain_count                
 AND @WF_status IN ('WFSM', 'WFAP')                  
BEGIN                  
UPDATE MtWFHistory                  
SET MtWFHistory_ProcessFinalApproval = 1                  
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
AND MtWFHistory_Process_id = @ProcessId                  
                  
UPDATE MtWFHistory                  
SET MtWFHistory_ToResource = @initiator                  
   , --null                                                                              
 notify_flag = 1                  
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id                  
AND MtWFHistory_Process_id = @ProcessId                  
AND MtWFHistory_SequenceID = @sequence_id                  
                   
  /*                
             
 if (@module_id between 1 and 12) or @module_id between 27 and 30            
BEGIN            
select @module_name=RuModules_Name from RuModules where RuModules_Id=4            
END            
else if (@module_id between 13 and 18) or @module_id=20            
BEGIN            
select @module_name=RuModules_Name from RuModules where RuModules_Id=1            
END            
            
else if @module_id =19            
BEGIN            
select @module_name=RuModules_Name from RuModules where RuModules_Id=3            
END            
else if @module_id between 21 and 26            
BEGIN            
select @module_name=RuModules_Name from RuModules where RuModules_Id=14            
END           
*/          
DECLARE @period INT = 0;             
DECLARE @vMtStatementProcess_ID int=0;            
select @vMtStatementProcess_ID =MtStatementProcess_ID from MtStatementProcess where  SrProcessDef_ID = @ProcessId                    
            
SELECT                      
 @period = LuAccountingMonth_Id_Current                      
FROM MtStatementProcess                      
WHERE MtStatementProcess_ID = @vMtStatementProcess_ID                      
DECLARE @period1 VARCHAR(20);                      
DECLARE @output VARCHAR(MAX);                      
SET @period1 = [dbo].[GetSettlementMonthYear](@period)                      
SET @output = 'Process Submitted for Approval: ' + @process_name + ' Settlement Period:' + CONVERT(VARCHAR(MAX), @period1) + ', File Master Id: ' +CONVERT(VARCHAR(MAX), @ProcessId)                      
EXEC [dbo].[SystemLogs] @moduleName = @process_name--@module_name                    
        ,@CrudOperationName = 'Update'                      
        ,@logMessage = @output                      
         ,@user=@user_id                      
                          
                  
                  
END                  
                  
SELECT                  
 1 error_code                  
   ,CASE                  
  WHEN @WF_status = 'WFSM' THEN 'Process Submitted Successfully.'                  
  WHEN @WF_status = 'WFAP' THEN 'Process Approved Successfully.'                  
  WHEN @WF_status = 'WFRJ' THEN 'Process Rejected Successfully.'                  
  WHEN @WF_status = 'WFRR' THEN 'Information Request Response Submitted Successfully.'                  
  WHEN @WF_status = 'WFRI' THEN 'Request Information Submitted Successfully.'                  
  WHEN @WF_status = 'WFRA' THEN 'Process Re-Assigned Successfully.'                  
  WHEN @WF_status = 'WFAJ' THEN 'Application Rejected Successfully.'                  
 END  

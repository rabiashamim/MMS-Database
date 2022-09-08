/****** Object:  Procedure [dbo].[WF_Getnotification_body]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure WF_Getnotification_body                             
@RuWorkFlowHeader_id int,
@ProcessId INT,      
@user_id INT,
@action varchar(4)
as


 declare @module_id int ,
 @initiator varchar(256),
 @approver varchar(256),
 @RuNotificationSetup_ID int,
 @NotificationBody varchar(max),
 @ProcessName varchar(256)
 
 declare                                
  @MtStatementProcess_ExecutionFinishDate datetime                                        
 ,@SettlementPeriod varchar(20)                             
                              
 select 
   @ProcessName = CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name),  
   @SettlementPeriod=LuAccountingMonth_MonthName                                                      
  ,@MtStatementProcess_ExecutionFinishDate=MtStatementProcess_ExecutionFinishDate                                                 
from MtStatementProcess mt_p  
    inner join LuAccountingMonth lu_acm  
        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id_Current  
    inner join SrProcessDef SPD  
        on SPD.SrProcessDef_ID = mt_p.SrProcessDef_ID  
    inner join SrStatementDef SSD  
        on SPD.SrStatementDef_ID = SSD.SrStatementDef_ID  
where IsNull(MtStatementProcess_IsDeleted, 0) = 0  
      and mt_p.MtStatementProcess_ID = @ProcessId  


 select @module_id=RuModules_id from RuWorkFlow_header where RuWorkFlowHeader_id=@RuWorkFlowHeader_id   
 
SELECT @approver=    
       [dbo].[FN_WF_SENDER_NAME](@ProcessId,@user_id) 
SELECT @initiator=    
       [DBO].[FN_WF_Init_NAME_EMAIL](@ProcessId) 
	 
select @initiator=substring(@initiator,1,charindex('¼',@initiator)-1)
if @action in ('WFSM','WFAP')
begin 
select @RuNotificationSetup_ID=RuNotificationSetup_ID 
from RuNotificationSetup where RuModules_id=@module_id   --RuWorkFlowHeader_id=@RuWorkFlowHeader_id                           
 and RuNotificationSetup_CategoryKey=  'process_approval_notification'   
end
if @action ='WFRJ'
begin 
select @RuNotificationSetup_ID=RuNotificationSetup_ID 
from RuNotificationSetup where RuModules_id=@module_id   --RuWorkFlowHeader_id=@RuWorkFlowHeader_id                           
 and RuNotificationSetup_CategoryKey=  'process_rejection_notification'   
end 

 select @NotificationBody=RuNotificationSetup_EmailBody--replac											e(RuNotificationSetup_EmailBody,'@approver_name',@approver_name)                                       
from  RuNotificationSetup                                       
where RuNotificationSetup_ID=@RuNotificationSetup_ID             
          
          
select  @NotificationBody = replace(replace(replace(replace(replace(@NotificationBody,'@approver_name',@initiator)          
         ,'@ProcessName',@ProcessName)              
            ,'@ProcessId',@ProcessId)            
            ,'@SettlementPeriod',@SettlementPeriod)            
            ,'@MtStatementProcess_ExecutionFinishDate',Format(@MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy hh:mm tt'))
			--,'@sender_name',@approver)

select @NotificationBody NotificationBody

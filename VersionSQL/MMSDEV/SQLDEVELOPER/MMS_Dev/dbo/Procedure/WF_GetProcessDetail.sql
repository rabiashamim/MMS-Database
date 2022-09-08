/****** Object:  Procedure [dbo].[WF_GetProcessDetail]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
        
          
            
CREATE procedure WF_GetProcessDetail                        
@RuWorkFlowHeader_id int,                            
@MtWFHistory_Process_id decimal(18,0) ,                              
@MtWFHistory_LevelID int,                            
@user_id  decimal(18,0),                          
@MtWFHistory_id varchar(32),                    
@status varchar(32)                    
as   
update MtWFHistory
set notify_flag=0 
 where  RuWorkFlowHeader_id=@RuWorkFlowHeader_id                               
 and MtWFHistory_Process_id=@MtWFHistory_Process_id                    
 and MtWFHistory_id=@MtWFHistory_id   
create table #WF_history                            
(RuWorkFlowHeader_id int,                            
 From_resource varchar(128),                            
 To_resource varchar(128),                            
 MtWFHistory_Process_id decimal(18,0) ,                              
 MtWFHistory_Process_name varchar(256),                            
 MtWFHistory_NotificationSubject varchar(256),                            
 MtWFHistory_ActionDate datetime,                            
 MtWFHistory_LevelID int,                            
 MtWFHistory_SequenceID int,                            
 [Status] varchar(32),                            
 SettlementPeriod varchar(20),                            
 MtStatementProcess_ExecutionFinishDate datetime,                            
 NotificationBody varchar(max),                            
 MtWFHistory_Action char(4),                  
 MtWFHistory_comments varchar(512) ,
 notify_flag int
 )                 
               
 if @status='OPEN' and exists(Select 1 from MtWFHistory               
 where MtWFHistory_id=@MtWFHistory_id and (MtWFHistory_ProcessRejected=1 or MtWFHistory_ProcessFinalApproval=1) )              
 begin               
 set @status='CLOSED'              
 end              
                            
 declare @module_id int                            
                            
 select @module_id=RuModules_id from RuWorkFlow_header where RuWorkFlowHeader_id=@RuWorkFlowHeader_id                            
                            
 declare                              
  @MtStatementProcess_ExecutionFinishDate datetime                                      
 ,@SettlementPeriod varchar(20)                             
 ,@NotificationBody  varchar(max)                              
 ,@RuNotificationSetup_ID int                            
                            
 select                            
   @SettlementPeriod=LuAccountingMonth_MonthName                                                    
  ,@MtStatementProcess_ExecutionFinishDate=MtStatementProcess_ExecutionFinishDate                                               
from MtStatementProcess  mt_p                                            
inner join LuAccountingMonth lu_acm on lu_acm.LuAccountingMonth_Id=mt_p.LuAccountingMonth_Id_Current                                             
where IsNull(MtStatementProcess_IsDeleted,0)=0 and mt_p.MtStatementProcess_ID=@MtWFHistory_Process_id                             
                           
insert into #WF_history                            
(RuWorkFlowHeader_id ,From_resource,To_resource, MtWFHistory_Process_id,MtWFHistory_Process_name ,MtWFHistory_NotificationSubject ,                            
 MtWFHistory_ActionDate ,MtWFHistory_LevelID ,MtWFHistory_SequenceID,[Status],SettlementPeriod ,MtStatementProcess_ExecutionFinishDate,MtWFHistory_Action                   
 ,MtWFHistory_comments,notify_flag                  
 )                            
select h.RuWorkFlowHeader_id,MtWFHistory_FromResource,MtWFHistory_ToResource,h.MtWFHistory_Process_id,h.MtWFHistory_Process_name,                          
 h.MtWFHistory_NotificationSubject,h.MtWFHistory_ActionDate,h.MtWFHistory_LevelID,h.MtWFHistory_SequenceID,                              
 @status [STATUS],@SettlementPeriod,@MtStatementProcess_ExecutionFinishDate,MtWFHistory_Action ,MtWFHistory_comments  ,notify_flag                           
 from MtWFHistory h                     
 where  h.RuWorkFlowHeader_id=@RuWorkFlowHeader_id                               
 and h.MtWFHistory_Process_id=@MtWFHistory_Process_id                    
 and h.MtWFHistory_id=@MtWFHistory_id                    
                         
 update w                            
 set  To_resource=u.FirstName+' '+u.LastName+' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'                             
 from #WF_history w inner join AspNetUsers u on w.To_resource=u.UserId                       
    left join Lu_Department d          
on u.Lu_Department_Id=d.Lu_Department_Id          
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                          
                        
--Update From resource from previous action step                            
                    
 update w                            
 set  From_resource=u.FirstName+' '+u.LastName+' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'                               
 from #WF_history w inner join AspNetUsers u on w.From_resource=u.UserId          
  left join Lu_Department d          
on u.Lu_Department_Id=d.Lu_Department_Id          
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id          
                            
 declare @approver_name varchar(128)                  
 select @approver_name=TO_resource,@status=[Status] from #WF_history                         
                    
 select @RuNotificationSetup_ID=RuNotificationSetup_ID from RuNotificationSetup where RuModules_id=@module_id   --RuWorkFlowHeader_id=@RuWorkFlowHeader_id                         
 and RuNotificationSetup_CategoryKey=  'process_approval'                        
                
 --and RuNotificationSetup_CategoryKey=case when isnull(@MtWFHistory_LevelID,0)=1 and @status='CLOSED' then  'Process_Submitted' else 'process_approval' end                          
--and RuNotificationSetup_CategoryKey=case when isnull(@MtWFHistory_LevelID,0)=1 then  'Process_Submitted' else 'process_approval' end                                  
        
 select @NotificationBody=RuNotificationSetup_EmailBody--replace(RuNotificationSetup_EmailBody,'@approver_name',@approver_name)                                     
from  RuNotificationSetup                                     
where RuNotificationSetup_ID=@RuNotificationSetup_ID           
        
        
 update #WF_history        
 set NotificationBody = replace(replace(replace(replace(replace(@NotificationBody,'@approver_name',@approver_name)        
         ,'@ProcessName',MtWFHistory_Process_name)            
            ,'@ProcessId',MtWFHistory_Process_id)          
            ,'@SettlementPeriod',SettlementPeriod)          
            ,'@MtStatementProcess_ExecutionFinishDate',Format(MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy hh:mm tt'))          
            --replace(RuNotificationSetup_EmailBody,'@approver_name',@approver_name),                         
   update #WF_history                            
 set  To_resource=replace(To_resource,'( - )','') ,From_resource=replace(From_resource,'( - )','')               
    
                                    
select @module_id module_id,@MtWFHistory_id MtWFHistory_id,* from #WF_history                            
                            
select                             
 RuWorkFlowHeader_id                            
,MtWFHistory_Process_id                            
,MtWFHistory_Process_name                            
,MtWFHistory_LevelID                            
,MtWFHistory_ActionDate                            
,LuStatus_Name--MtWFHistory_Action                            
,MtWFHistory_FromResource                            
,u.FirstName+' '+u.LastName+' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'     FromResource_name                          
,MtWFHistory_ToResource                           
,u.FirstName+' '+u.LastName ToResource_name                          
,MtWFHistory_comments                           
,MtWFHistory_SequenceID                    
,MtWFHistory_id                    
into #resources                          
from MtWFHistory w                            
inner join [LuStatus] s on w.MtWFHistory_Action=s.LuStatus_Code                          
inner join AspNetUsers u on w.MtWFHistory_FromResource=u.UserId          
 left join Lu_Department d          
on u.Lu_Department_Id=d.Lu_Department_Id          
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id          
where RuWorkFlowHeader_id=@RuWorkFlowHeader_id                             
  and MtWFHistory_Process_id=@MtWFHistory_Process_id                           
                
 update w                            
 set  ToResource_name= u.FirstName+' '+u.LastName +' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'               
 from #resources w inner join AspNetUsers u on w.MtWFHistory_ToResource=u.UserId             
 left join Lu_Department d          
on u.Lu_Department_Id=d.Lu_Department_Id          
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id       
    
 update w                            
 set  ToResource_name=replace(ToResource_name,'( - )','')              
 from #resources w     
  
 update w                            
 set  FromResource_name=replace(FromResource_name,'( - )','')              
 from #resources w                         
                          
 update w                            
 set  ToResource_name= ''                      
 from #resources w where w.MtWFHistory_ToResource is null                      
                           
 select * from #resources order by MtWFHistory_SequenceID 

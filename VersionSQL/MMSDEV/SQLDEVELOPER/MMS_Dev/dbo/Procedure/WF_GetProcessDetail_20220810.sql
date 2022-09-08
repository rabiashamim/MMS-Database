/****** Object:  Procedure [dbo].[WF_GetProcessDetail_20220810]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure WF_GetProcessDetail_20220810      
@RuWorkFlowHeader_id int,        
@MtWFHistory_Process_id decimal(18,0) ,          
@MtWFHistory_LevelID int,        
@user_id  decimal(18,0) --,        
--@status varchar(32)        
as        
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
 NotificationBody varchar(256),        
 MtWFHistory_Action char(4)        
 )        
        
 declare @module_id int        
        
 select @module_id=RuModules_id from RuWorkFlow_header where RuWorkFlowHeader_id=@RuWorkFlowHeader_id        
        
 declare          
  @MtStatementProcess_ExecutionFinishDate datetime                  
 ,@SettlementPeriod varchar(20)         
 ,@NotificationBody  varchar(256)          
 ,@RuNotificationSetup_ID int        
        
 select        
   @SettlementPeriod=LuAccountingMonth_MonthName                                
  ,@MtStatementProcess_ExecutionFinishDate=MtStatementProcess_ExecutionFinishDate                           
from MtStatementProcess  mt_p                        
inner join LuAccountingMonth lu_acm on lu_acm.LuAccountingMonth_Id=mt_p.LuAccountingMonth_Id_Current                         
where IsNull(MtStatementProcess_IsDeleted,0)=0 and mt_p.MtStatementProcess_ID=@MtWFHistory_Process_id         
    
          
 --Get max sequence ID of the action where logged in user is stamped        
 ;with cte as(        
 select  RuWorkFlowHeader_id,MtWFHistory_Process_id,max(MtWFHistory_SequenceID)MtWFHistory_SequenceID,max(MtWFHistory_ActionDate)MtWFHistory_ActionDate        
 ,@user_id login_user        
 from MtWFHistory        
 where (MtWFHistory_ToResource=@user_id or MtWFHistory_FromResource=@user_id)         
 and RuWorkFlowHeader_id=@RuWorkFlowHeader_id         
 and MtWFHistory_Process_id=@MtWFHistory_Process_id        
 group by RuWorkFlowHeader_id,MtWFHistory_Process_id        
 )        
insert into #WF_history        
(RuWorkFlowHeader_id , MtWFHistory_Process_id,MtWFHistory_Process_name /*, To_resource*/,MtWFHistory_NotificationSubject ,        
 MtWFHistory_ActionDate ,MtWFHistory_LevelID ,MtWFHistory_SequenceID,[Status],SettlementPeriod ,MtStatementProcess_ExecutionFinishDate,MtWFHistory_Action        
 )        
select distinct c.RuWorkFlowHeader_id,c.MtWFHistory_Process_id,h.MtWFHistory_Process_name/*,u.FirstName+' '+u.LastName as TO_resource*/,          
 h.MtWFHistory_NotificationSubject,c.MtWFHistory_ActionDate,h.MtWFHistory_LevelID,h.MtWFHistory_SequenceID,          
 case when c.login_user=h.MtWFHistory_ToResource then 'OPEN' else 'CLOSED' end [STATUS],@SettlementPeriod,@MtStatementProcess_ExecutionFinishDate,MtWFHistory_Action          
 from MtWFHistory h inner join cte c on c.RuWorkFlowHeader_id=h.RuWorkFlowHeader_id and c.MtWFHistory_Process_id=h.MtWFHistory_Process_id          
 and c.MtWFHistory_SequenceID=h.MtWFHistory_SequenceID          
  --inner join AspNetUsers u on h.MtWFHistory_ToResource=u.UserId          
 where /*h.MtWFHistory_ProcessRejected!=1          
  and*/ h.RuWorkFlowHeader_id=@RuWorkFlowHeader_id           
 and h.MtWFHistory_Process_id=@MtWFHistory_Process_id           
     
    
  update w        
 set  To_resource=h.MtWFHistory_ToResource        
 from #WF_history w inner join MtWFHistory h on w.RuWorkFlowHeader_id=h.RuWorkFlowHeader_id        
           and w.MtWFHistory_Process_id=h.MtWFHistory_Process_id        
           and h.MtWFHistory_SequenceID=w.MtWFHistory_SequenceID     
    
      update w        
 set  To_resource=u.FirstName+' '+u.LastName        
 from #WF_history w inner join AspNetUsers u on w.To_resource=u.UserId   
        
    
--Update From resource from previous action step        
 update w        
 set  From_resource=h.MtWFHistory_FromResource        
 from #WF_history w inner join MtWFHistory h on w.RuWorkFlowHeader_id=h.RuWorkFlowHeader_id        
           and w.MtWFHistory_Process_id=h.MtWFHistory_Process_id        
           and h.MtWFHistory_SequenceID=case when MtWFHistory_ProcessRejected=1 then w.MtWFHistory_SequenceID else w.MtWFHistory_SequenceID-1 END        
 /*where h.MtWFHistory_ProcessRejected!=1  */      
--For level 1 from resource should be picked directly        
 update w        
 set  From_resource=MtWFHistory_FromResource        
 from #WF_history w inner join MtWFHistory h on w.RuWorkFlowHeader_id=h.RuWorkFlowHeader_id        
           and w.MtWFHistory_Process_id=h.MtWFHistory_Process_id        
           and h.MtWFHistory_SequenceID=w.MtWFHistory_SequenceID         
 where h.MtWFHistory_ProcessRejected!=1 and h.MtWFHistory_SequenceID=1        
        
 update w        
 set  From_resource=u.FirstName+' '+u.LastName        
 from #WF_history w inner join AspNetUsers u on w.From_resource=u.UserId        
        
 declare @approver_name varchar(128) ,@status char(4)       
 select @approver_name=TO_resource,@status=[Status] from #WF_history        
        
 select @RuNotificationSetup_ID=RuNotificationSetup_ID from RuNotificationSetup where RuWorkFlowHeader_id=@RuWorkFlowHeader_id       
 and RuNotificationSetup_CategoryKey=case when isnull(@MtWFHistory_LevelID,0)=1 and @status='CLOSED' then  'Process_Submitted' else 'process_approval' end        
--and RuNotificationSetup_CategoryKey=case when isnull(@MtWFHistory_LevelID,0)=1 then  'Process_Submitted' else 'process_approval' end                
           
 select @NotificationBody=replace(RuNotificationSetup_EmailBody,'@approver_name',@approver_name)                   
from  RuNotificationSetup                   
where RuNotificationSetup_ID=@RuNotificationSetup_ID            
        
update #WF_history        
set NotificationBody=@NotificationBody        
        
select @module_id module_id,* from #WF_history        
        
select         
 RuWorkFlowHeader_id        
,MtWFHistory_Process_id        
,MtWFHistory_Process_name        
,MtWFHistory_LevelID        
,MtWFHistory_ActionDate        
,LuStatus_Name--MtWFHistory_Action        
,MtWFHistory_FromResource        
,u.FirstName+' '+u.LastName FromResource_name      
,MtWFHistory_ToResource       
,u.FirstName+' '+u.LastName ToResource_name      
,MtWFHistory_comments       
,MtWFHistory_SequenceID      
into #resources      
from MtWFHistory w        
inner join [LuStatus] s on w.MtWFHistory_Action=s.LuStatus_Code      
inner join AspNetUsers u on w.MtWFHistory_FromResource=u.UserId        
where RuWorkFlowHeader_id=@RuWorkFlowHeader_id         
  and MtWFHistory_Process_id=@MtWFHistory_Process_id       
      
 update w        
 set  ToResource_name= u.FirstName+' '+u.LastName       
 from #resources w inner join AspNetUsers u on w.MtWFHistory_ToResource=u.UserId       
  
      
 update w        
 set  ToResource_name= ''  
 from #resources w where w.MtWFHistory_ToResource is null  
       
 select * from #resources

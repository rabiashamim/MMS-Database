/****** Object:  Procedure [dbo].[WF_GetMyWorkList_data]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
      
  --[dbo].[WF_GetMyWorkList_data] 0,1      
CREATE procedure [dbo].[WF_GetMyWorkList_data]              
    @status int = null,                  
    @user_id decimal(18, 0)                  
as                  
              
create table #WF_history                  
(                  
    RuWorkFlowHeader_id int,                  
    From_resource varchar(512),                  
    To_resource varchar(512),                  
    MtWFHistory_Process_id decimal(18, 0),                  
    MtWFHistory_Process_name varchar(256),                  
    MtWFHistory_NotificationSubject varchar(256),                  
    MtWFHistory_ActionDate datetime,                  
    MtWFHistory_LevelID int,                  
    MtWFHistory_SequenceID int,                  
    [Status] varchar(32) ,              
 MtWFHistory_id int,              
 Resource_action varchar(32),              
 is_initiator int  ,          
 MtWFHistory_ProcessFinalApproval int,          
MtWFHistory_ProcessRejected int ,    
notify_flag int    
)                  
    select * into #MtWFHistory_data from MtWFHistory where MtWFHistory_ToResource=@user_id or MtWFHistory_FromResource=@user_id              
--STEP 1----get max sequence_id where user is tagged as reciever of the approval process            
;with cte_to                  
as (select RuWorkFlowHeader_id,                  
           MtWFHistory_Process_id,                  
           max(MtWFHistory_SequenceID) MtWFHistory_SequenceID,                  
           max(MtWFHistory_ActionDate) MtWFHistory_ActionDate,                  
           @user_id login_user ,              
     'TO_resource' Resource_action              
    from #MtWFHistory_data                  
    where MtWFHistory_ToResource = @user_id                   
    group by RuWorkFlowHeader_id,                  
             MtWFHistory_Process_id                  
   )               
   select * into #to_resource from cte_to         
--STEP 2----get max sequence_id of the process where logged in user id is the sender    
; with cte_from                  
as (select h.RuWorkFlowHeader_id,                  
           h.MtWFHistory_Process_id,                  
           max(h.MtWFHistory_SequenceID) MtWFHistory_SequenceID,                  
           max(h.MtWFHistory_ActionDate) MtWFHistory_ActionDate,                  
           @user_id login_user,              
     'FROM_resource' Resource_action                  
    from #MtWFHistory_data  h left join  #to_resource c on c.RuWorkFlowHeader_id=h.RuWorkFlowHeader_id and c.MtWFHistory_Process_id=h.MtWFHistory_Process_id               
    where MtWFHistory_FromResource = @user_id               
 and c.MtWFHistory_Process_id is null              
    group by h.RuWorkFlowHeader_id,                  
             h.MtWFHistory_Process_id                  
   )                   
   select * into #from_resource from cte_from     
       
insert into #WF_history                  
(                  
    RuWorkFlowHeader_id,                  
    MtWFHistory_Process_id,                  
    MtWFHistory_Process_name,                    
    MtWFHistory_NotificationSubject,                  
    MtWFHistory_ActionDate,                  
    MtWFHistory_LevelID,                  
    MtWFHistory_SequenceID,                  
    [Status] ,              
 MtWFHistory_id,              
 Resource_action,              
 is_initiator ,          
 MtWFHistory_ProcessFinalApproval,          
MtWFHistory_ProcessRejected,    
notify_flag    
           
)              
select distinct                  
    c.RuWorkFlowHeader_id,                  
    c.MtWFHistory_Process_id,         
    h.MtWFHistory_Process_name,                   
    h.MtWFHistory_NotificationSubject,                  
    c.MtWFHistory_ActionDate,                  
    h.MtWFHistory_LevelID,                  
    h.MtWFHistory_SequenceID,                  
    'CLOSED',              
 h.MtWFHistory_id,              
 c.Resource_action,              
 is_initiator ,          
 MtWFHistory_ProcessFinalApproval,          
MtWFHistory_ProcessRejected ,    
notify_flag    
from #MtWFHistory_data h                  
    inner join #to_resource c                  
            on c.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id                  
           and c.MtWFHistory_Process_id = h.MtWFHistory_Process_id                  
          and c.MtWFHistory_SequenceID = h.MtWFHistory_SequenceID                  
--where h.MtWFHistory_ProcessRejected != 1               
              
insert into #WF_history                  
(             
    RuWorkFlowHeader_id,                  
    MtWFHistory_Process_id,                  
    MtWFHistory_Process_name,                    
    MtWFHistory_NotificationSubject,                  
    MtWFHistory_ActionDate,                  
    MtWFHistory_LevelID,                  
    MtWFHistory_SequenceID,                  
    [Status] ,              
 MtWFHistory_id,              
 Resource_action,              
 is_initiator ,          
 MtWFHistory_ProcessFinalApproval,          
MtWFHistory_ProcessRejected,    
notify_flag    
)              
select distinct                  
    c.RuWorkFlowHeader_id,                  
    c.MtWFHistory_Process_id,                  
    h.MtWFHistory_Process_name,                   
    h.MtWFHistory_NotificationSubject,                  
    c.MtWFHistory_ActionDate,                  
    h.MtWFHistory_LevelID,                  
    h.MtWFHistory_SequenceID,                  
    'CLOSED',              
 h.MtWFHistory_id,              
 c.Resource_action              
 ,is_initiator ,          
 MtWFHistory_ProcessFinalApproval,          
MtWFHistory_ProcessRejected,    
notify_flag     
from #MtWFHistory_data h                  
    inner join #from_resource c                  
            on c.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id                  
           and c.MtWFHistory_Process_id = h.MtWFHistory_Process_id                  
           and c.MtWFHistory_SequenceID = h.MtWFHistory_SequenceID                  
--where h.MtWFHistory_ProcessRejected != 1     
    
    
/*Get max sequence id of the process in approval*/    
--  ;with cte_max                 
--as (    
select RuWorkFlowHeader_id,                  
           MtWFHistory_Process_id,                  
           max(MtWFHistory_SequenceID) MtWFHistory_SequenceID     
     into #cte_max    
    from #MtWFHistory_data                    
    group by RuWorkFlowHeader_id,                  
             MtWFHistory_Process_id                  
   --)      

update h              
set [Status]=case when h.Resource_action='TO_resource' and isnull(is_initiator,0)!=1           
and MtWFHistory_ProcessFinalApproval!=1 --and MtWFHistory_ProcessRejected!=1          
then 'OPEN' else [Status] end        
,notify_flag=h.notify_flag  
from #WF_history h inner join #cte_max c on h.RuWorkFlowHeader_id=c.RuWorkFlowHeader_id              
            and h.MtWFHistory_Process_id=c.MtWFHistory_Process_id              
            and h.MtWFHistory_SequenceID=c.MtWFHistory_SequenceID                        
     
 update w                    
 set  To_resource=h.MtWFHistory_ToResource,From_resource=  h.MtWFHistory_FromResource                  
 from #WF_history w inner join #MtWFHistory_data h on w.RuWorkFlowHeader_id=h.RuWorkFlowHeader_id                    
           and w.MtWFHistory_Process_id=h.MtWFHistory_Process_id                    
           and h.MtWFHistory_SequenceID=w.MtWFHistory_SequenceID              
     and w.MtWFHistory_id=h.MtWFHistory_id              
                
      update w                    
 set  To_resource=u.FirstName+' '+u.LastName                    
 from #WF_history w inner join AspNetUsers u on w.To_resource=u.UserId                    
                    
update w                  
set From_resource = u.FirstName +' '+ u.LastName  +' ('+Lu_Designation_Name+' - '+Lu_Department_Name+')'                
from #WF_history w                  
    inner join AspNetUsers u                  
        on w.From_resource = u.UserId       
  inner join Lu_Department d      
on u.Lu_Department_Id=d.Lu_Department_Id      
inner join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id      
        
       
                  
              
select *,      
case when MtWFHistory_ProcessRejected=1 then 'Rejected'  
     when MtWFHistory_ProcessFinalApproval=1 then 'Approved'  
  else 'In-Process'  
end AS ApprovalStatus

from #WF_history h                 
where [status] = case               
                     when @status = 1 then                  
                         'OPEN'                  
                     when @status = 2 then                  
                         'CLOSED'                  
                     else                  
                         [status]                  
                 end                
order by [status] desc,MtWFHistory_ActionDate desc 

/****** Object:  Procedure [dbo].[WF_GetMyWorkList_data_draft]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure WF_GetMyWorkList_data_draft
  @status int = null,    
    @user_id decimal(18, 0)    
as    

create table #WF_history    
(    
    RuWorkFlowHeader_id int,    
    From_resource varchar(128),    
    To_resource varchar(128),    
    MtWFHistory_Process_id decimal(18, 0),    
    MtWFHistory_Process_name varchar(256),    
    MtWFHistory_NotificationSubject varchar(256),    
    MtWFHistory_ActionDate datetime,    
    MtWFHistory_LevelID int,    
    MtWFHistory_SequenceID int,    
    [Status] varchar(32) ,
	MtWFHistory_id int,
	Resource_action varchar(32),
	is_initiator int
)    
    select * into #MtWFHistory_data from MtWFHistory where MtWFHistory_ToResource=@user_id or MtWFHistory_FromResource=@user_id
   
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
	is_initiator
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
	is_initiator
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
	is_initiator
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
	,is_initiator
from #MtWFHistory_data h    
    inner join #from_resource c    
            on c.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id    
           and c.MtWFHistory_Process_id = h.MtWFHistory_Process_id    
           and c.MtWFHistory_SequenceID = h.MtWFHistory_SequenceID    
--where h.MtWFHistory_ProcessRejected != 1  

;with cte_max   
as (select RuWorkFlowHeader_id,    
           MtWFHistory_Process_id,    
           max(MtWFHistory_SequenceID) MtWFHistory_SequenceID 
    from #MtWFHistory_data      
    group by RuWorkFlowHeader_id,    
             MtWFHistory_Process_id    
   ) 
update h
set [Status]=case when h.Resource_action='TO_resource' and isnull(is_initiator,0)!=1 then 'OPEN' else [Status] end
from #WF_history h inner join cte_max c on h.RuWorkFlowHeader_id=c.RuWorkFlowHeader_id
											 and h.MtWFHistory_Process_id=c.MtWFHistory_Process_id
											 and h.MtWFHistory_SequenceID=c.MtWFHistory_SequenceID

select * from #WF_history

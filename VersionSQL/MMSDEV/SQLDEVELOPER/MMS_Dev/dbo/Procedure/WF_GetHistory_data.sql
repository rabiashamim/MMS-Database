/****** Object:  Procedure [dbo].[WF_GetHistory_data]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE procedure WF_GetHistory_data --1  
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
    [Status] varchar(32)
)

--Get max sequence ID of the action where logged in user is stamped  
;
with cte
as (select RuWorkFlowHeader_id,
           MtWFHistory_Process_id,
           max(MtWFHistory_SequenceID) MtWFHistory_SequenceID,
           max(MtWFHistory_ActionDate) MtWFHistory_ActionDate,
           @user_id login_user
    from MtWFHistory
    where MtWFHistory_ToResource = @user_id
          or MtWFHistory_FromResource = @user_id
    group by RuWorkFlowHeader_id,
             MtWFHistory_Process_id
   )
insert into #WF_history
(
    RuWorkFlowHeader_id,
    MtWFHistory_Process_id,
    MtWFHistory_Process_name,
    To_resource,
    MtWFHistory_NotificationSubject,
    MtWFHistory_ActionDate,
    MtWFHistory_LevelID,
    MtWFHistory_SequenceID,
    [Status]
)
select distinct
    c.RuWorkFlowHeader_id,
    c.MtWFHistory_Process_id,
    h.MtWFHistory_Process_name,
    u.FirstName + ' ' + u.LastName as TO_resource,
    h.MtWFHistory_NotificationSubject,
    c.MtWFHistory_ActionDate,
    h.MtWFHistory_LevelID,
    h.MtWFHistory_SequenceID,
    case
        when c.login_user = h.MtWFHistory_ToResource then
            'OPEN'
        else
            'CLOSED'
    end [STATUS]
from MtWFHistory h
    inner join cte c
        on c.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id
           and c.MtWFHistory_Process_id = h.MtWFHistory_Process_id
           and c.MtWFHistory_SequenceID = h.MtWFHistory_SequenceID
    inner join AspNetUsers u
        on h.MtWFHistory_ToResource = u.UserId
where h.MtWFHistory_ProcessRejected != 1


--Update From resource from previous action step  
update w
set From_resource = h.MtWFHistory_FromResource
from #WF_history w
    inner join MtWFHistory h
        on w.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id
           and w.MtWFHistory_Process_id = h.MtWFHistory_Process_id
           and h.MtWFHistory_SequenceID = w.MtWFHistory_SequenceID - 1
where h.MtWFHistory_ProcessRejected != 1
--For level 1 from resource should be picked directly  
update w
set From_resource = MtWFHistory_FromResource
from #WF_history w
    inner join MtWFHistory h
        on w.RuWorkFlowHeader_id = h.RuWorkFlowHeader_id
           and w.MtWFHistory_Process_id = h.MtWFHistory_Process_id
           and h.MtWFHistory_SequenceID = w.MtWFHistory_SequenceID
where h.MtWFHistory_ProcessRejected != 1
      and h.MtWFHistory_SequenceID = 1

update w
set From_resource = u.FirstName + ' ' + u.LastName
from #WF_history w
    inner join AspNetUsers u
        on w.From_resource = u.UserId



select *
from #WF_history

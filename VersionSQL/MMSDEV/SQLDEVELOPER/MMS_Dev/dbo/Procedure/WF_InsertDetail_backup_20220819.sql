/****** Object:  Procedure [dbo].[WF_InsertDetail_backup_20220819]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
      
CREATE procedure [dbo].[WF_InsertDetail_backup_20220819]      
    @RuWorkFlowHeader_id int,      
    @action_flag int, --1=insert ,2=update,3=delete            
    @level_id int,      
    @level_description varchar(256) = null,      
    @level_user_id decimal(18, 0) = null,      
    @Designation decimal(18, 0) = null,      
    @user_id decimal(18, 0)      
as      
      
/*delete levels for which action flag=3 i.e. delete that level*/      
if @action_flag = 3      
begin      
      
    delete from RuWorkFlow_detail      
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
          and RuWorkFlow_detail_levelId = @level_id      
      
    /*update level hierarchy on any level deletion*/      
    ;      
    with cte      
    as (select row_number() over (partition by 1 order by RuWorkFlow_detail_levelId asc) new_level,      
               *      
        from RuWorkFlow_detail      
        where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
       )      
    update d      
    set RuWorkFlow_detail_levelId = new_level      
    from RuWorkFlow_detail d      
        inner join cte c      
            on d.RuWorkFlowHeader_id = c.RuWorkFlowHeader_id      
               and d.RuWorkFlow_detail_levelId = c.RuWorkFlow_detail_levelId      
    where d.RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
     
end      
      
if @action_flag = 2      
BEGIN     
if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and AspNetUsers_UserId=@level_user_id and RuWorkFlow_detail_levelId!=@level_id)  
begin   
select -1 error_code,'Employee Already exists in Workflow hierarchy '  
return  
end   
--If resource in any level is updated then update him in his open processes  
select MtWFHistory_Process_id,      
       RuWorkFlowHeader_id,      
       max(MtWFHistory_SequenceID) MtWFHistory_SequenceID  
into #temp_resource_to      
from   MtWFHistory    
where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
group by RuWorkFlowHeader_id,      
         MtWFHistory_Process_id     
  
 alter table #temp_resource_to      
    add max_level_id int,      
        MtWFHistory_ToResource decimal(512);      
     
    update t      
    set max_level_id = h.MtWFHistory_LevelID,      
        MtWFHistory_ToResource = h.MtWFHistory_ToResource       
    from MtWFHistory h      
        inner join #temp_resource_to t      
            on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id      
               and h.MtWFHistory_Process_id = t.MtWFHistory_Process_id      
               and t.MtWFHistory_SequenceID = h.MtWFHistory_SequenceID         
      
update h  
set MtWFHistory_ToResource=@level_user_id  
from MtWFHistory h inner join #temp_resource_to r  
on h.RuWorkFlowHeader_id=r.RuWorkFlowHeader_id  
and h.MtWFHistory_Process_id=r.MtWFHistory_Process_id  
and h.MtWFHistory_SequenceID=r.MtWFHistory_SequenceID  
where max_level_id=@level_id-1  
  
 update RuWorkFlow_detail      
    set RuWorkFlow_detail_levelId = @level_id,      
        AspNetUsers_UserId = @level_user_id,      
        Lu_Designation_Id = @Designation,      
        RuWorkFlow_detail_description = @level_description,      
        RuWorkFlow_detail_ModifiedBy = @user_id,      
        RuWorkFlow_detail_ModifiedOn = getdate()      
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
          and RuWorkFlow_detail_levelId = @level_id      
      
    --update to resource here in history table           
    --get max sequence id of the required level to update the resource          
;      
    with update_To      
    as (Select max(MtWFHistory_SequenceID) MtWFHistory_SequenceID,      
               MtWFHistory_Process_name,      
               RuWorkFlowHeader_id,      
               MtWFHistory_Process_id      
        from MtWFHistory h      
        where MtWFHistory_ProcessFinalApproval != 1      
              and MtWFHistory_ProcessRejected != 1      
              and MtWFHistory_LevelID = @level_id      
        group by MtWFHistory_Process_name,      
                 RuWorkFlowHeader_id,      
                 MtWFHistory_Process_id      
       )      
    update h      
    set MtWFHistory_ToResource = @level_user_id      
    from MtWFHistory h      
        inner join update_To t      
            on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id      
               and h.MtWFHistory_Process_id = t.MtWFHistory_Process_id      
               and h.MtWFHistory_SequenceID = t.MtWFHistory_SequenceID      
               and h.MtWFHistory_LevelID = @level_id      
               and h.MtWFHistory_ToResource != @level_user_id      
               and h.MtWFHistory_Action not in ( 'WFRI', 'WFRA', 'WFRR' )      
      
END      
      
If @action_flag = 1      
BEGIN  
if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and AspNetUsers_UserId=@level_user_id and RuWorkFlow_detail_levelId!=@level_id)  
begin   
select -1 error_code,'Employee Already exists in Workflow hierarchy '  
return  
end   
  
    insert into RuWorkFlow_detail      
    (      
        RuWorkFlowHeader_id,      
        RuWorkFlow_detail_levelId,      
        RuWorkFlow_detail_description,      
        AspNetUsers_UserId,      
        Lu_Designation_Id,      
        RuWorkFlow_detail_CreatedBy,      
        RuWorkFlow_detail_CreatedOn      
    )      
    select @RuWorkFlowHeader_id,      
           @level_id,      
           @level_description,      
           @level_user_id,      
           @Designation,      
     @user_id,      
           getdate()      
      
END      
      
--/*          
/*Approved and rejected processes should be removed from interface table*/      
delete from RuWorkFlow_detail_Interface      
where RuProcess_ID in (      
                          select distinct      
                              MtWFHistory_Process_id      
                          from MtWFHistory      
                          where MtWFHistory_ProcessFinalApproval = 1      
                                or MtWFHistory_ProcessRejected = 1      
                      )      
--*/          
/*get all processes having chain count different from the current chain and reject them by system*/      
declare @chain_count int      
select @chain_count = count(*)      
from RuWorkFlow_detail      
where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
      
--get all in approval processes chain count from interface           
select RuProcess_ID,      
       RuWorkFlowHeader_id,      
       count(RuWorkFlow_detail_levelId) RuWorkFlow_detail_levelId  
into #temp      
from RuWorkFlow_detail_Interface      
where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
group by RuProcess_ID,      
         RuWorkFlowHeader_id      
      
delete from #temp      
where RuWorkFlow_detail_levelId = @chain_count      
      
if exists (Select 1 from #temp)      
begin      
    alter table #temp      
    add sequence_id int,      
        max_level_id int,      
        process_name nvarchar(512);      
    with cte      
    as (Select max(MtWFHistory_SequenceID) MtWFHistory_SequenceID,      
               MtWFHistory_Process_name,      
               t.RuWorkFlowHeader_id,      
               t.RuProcess_ID      
        from MtWFHistory h      
            inner join #temp t      
                on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id      
                   and h.MtWFHistory_Process_id = t.RuProcess_ID      
        group by t.RuWorkFlowHeader_id,      
                 t.RuProcess_ID,      
                 MtWFHistory_Process_name      
       )      
    update t      
 set sequence_id = MtWFHistory_SequenceID,      
        process_name = MtWFHistory_Process_name      
    from #temp t      
        inner join cte c      
            on t.RuWorkFlowHeader_id = c.RuWorkFlowHeader_id      
               and t.RuProcess_ID = c.RuProcess_ID      
    update t      
    set max_level_id = MtWFHistory_LevelID      
    from MtWFHistory h      
        inner join #temp t      
            on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id      
               and h.MtWFHistory_Process_id = t.RuProcess_ID      
               and t.sequence_id = MtWFHistory_SequenceID      
      
    if exists      
    (      
        Select 1      
        from MtWFHistory h      
            inner join #temp t      
                on h.MtWFHistory_Process_id = t.RuProcess_ID      
                   and h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id      
        where h.RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
              and h.MtWFHistory_ProcessFinalApproval != 1      
              and h.MtWFHistory_ProcessRejected != 1      
    )      
    begin      
        insert into MtWFHistory      
  (    
 RuWorkFlowHeader_id    
,MtWFHistory_Process_id    
,MtWFHistory_Process_name    
,MtWFHistory_LevelID    
,MtWFHistory_SequenceID    
,MtWFHistory_ActionDate    
,MtWFHistory_Action    
,MtWFHistory_FromResource    
,MtWFHistory_ToResource    
,MtWFHistory_comments    
,MtWFHistory_ProcessFinalApproval    
,MtWFHistory_ProcessRejected    
,MtWFHistory_NotificationSubject    
,MtWFHistory_CreatedBy    
,MtWFHistory_CreatedOn    
,MtWFHistory_ModifiedBy    
,MtWFHistory_ModifiedOn    
,is_initiator)    
        select @RuWorkFlowHeader_id,      
               RuProcess_ID,      
               process_name,      
               max_level_id,      
               sequence_id + 1,      
               getdate(),      
               'WFRJ',      
               1,      
               null,--1,      
               'Rejected by System',      
               0,      
               1,      
               'Rejected by System',      
               1,      
               getdate(),      
               null,      
               null,    
      0    
        from #temp      
      
        update h      
        set MtWFHistory_ProcessRejected = 1      
        from MtWFHistory h      
            inner join #temp t      
                on h.RuWorkFlowHeader_id = t.RuWorkFlowHeader_id      
                   and h.MtWFHistory_Process_id = t.RuProcess_ID      
        where h.RuWorkFlowHeader_id = @RuWorkFlowHeader_id     
    
          update MtStatementProcess                        
        set MtStatementProcess_ApprovalStatus = 'Draft'                        
  from MtStatementProcess h      
            inner join #temp t      
            on h.MtStatementProcess_ID = t.RuProcess_ID      
        where t.RuWorkFlowHeader_id = @RuWorkFlowHeader_id     
    
    
      
        select 1 error_code,      
               'Work Flow chain is modified,In-Approval Processes will be rejected by system. Please proceed accordingly.'      
      
      
    end      
      
end     
  
  
  
  
      
      
      
      
      

﻿/****** Object:  Procedure [dbo].[WF_InsertHistory_data_backup_20220819]    Committed by VersionSQL https://www.versionsql.com ******/

        
        
          
CREATE procedure WF_InsertHistory_data_backup_20220819                       
    @WorkFlowHeader_id int,                        
    @ProcessId as decimal(18, 0),                        
    @process_name nvarchar(256),                        
    @level_id int,                        
    @WF_status char(4),                        
    @comments nvarchar(256)=null,                        
    @NotificationSubject nvarchar(256),                        
    @To_resource decimal(18, 0) = null,                        
    @Last_level_WF_status char(4) = null,                        
    @user_id decimal(18, 0)                        
as                        
if @WF_status = 'WFRR'                        
   or @Last_level_WF_status in ( 'WFRR', 'WFRA' )                        
begin                        
    set @level_id = isnull(@level_id, 0)                        
end                        
else                        
begin                        
    set @level_id = isnull(@level_id, 0) + 1                        
end                        
                   
delete from RuWorkFlow_detail_Interface                        
where RuProcess_ID in (                        
                          select distinct                        
                              MtWFHistory_Process_id                        
                          from MtWFHistory                        
                          where MtWFHistory_ProcessFinalApproval = 1                        
                                or MtWFHistory_ProcessRejected = 1                        
                      )                
                   
             
     
declare @chain_count int,                        
        @interface_chain_count int,                        
        @authorized_approver decimal(18, 0),                        
        @max_sequence_id int,                        
        @max_level_id int,                        
        @module_id int,                        
        @module_name varchar(128) ,                  
        @initiator decimal(18, 0)                  
                  
                    
 select @initiator = AspNetUsers_UserId                  
from RuWorkFlow_detail                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id  and RuWorkFlow_detail_levelId=1                  
                        
select @module_id = RuModules_id                        
from RuWorkFlow_header                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
select @module_name = RuModules_Name                        
from RuModules                        
where RuModules_id = @module_id                        
                        
                        
select @authorized_approver = AspNetUsers_UserId                        
from RuWorkFlow_detail                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
      and RuWorkFlow_detail_levelId = @level_id                 
if @authorized_approver != @user_id and  @WF_status != 'WFRR'  and  @Last_level_WF_status !='WFRA'                    
begin                        
    select -1 as error_Code,                        
           'User is not authorized for this level approval, Please check WF Hierarchy defined or contact administrator.' as error_description                        
    return                        
end                        
                    
                     
if @level_id = 1   and isnull(@Last_level_WF_status,'')!='WFSM'                       
begin                        
delete from RuWorkFlow_detail_Interface where RuWorkFlowHeader_id = @WorkFlowHeader_id   and RuProcess_ID=@ProcessId                       
    insert into RuWorkFlow_detail_Interface                        
    (                    
        RuWorkFlow_detail_id,                        
        RuWorkFlowHeader_id,                        
        RuProcess_ID,                        
        RuWorkFlow_detail_levelId,                        
        RuWorkFlow_detail_description,                        
        AspNetUsers_UserId,                        
        Lu_Designation_Id,                        
        RuWorkFlow_detail_CreatedBy,                        
        RuWorkFlow_detail_CreatedOn                        
    )                        
    select RuWorkFlow_detail_id,                        
           RuWorkFlowHeader_id,                        
           @ProcessId,                        
           RuWorkFlow_detail_levelId,                        
           RuWorkFlow_detail_description,                        
           AspNetUsers_UserId,                        
           Lu_Designation_Id,                        
           @user_id,             
           getdate()                        
    from RuWorkFlow_detail                        
    where RuWorkFlowHeader_id = @WorkFlowHeader_id                   
                 
                
end                        
select @chain_count = count(*)                
from RuWorkFlow_detail                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
select @interface_chain_count = count(*)                        
from RuWorkFlow_detail_Interface                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
      and RuProcess_ID = @ProcessId                      
                   
                        
                    
                        
                        
                        
declare @WF_status_name varchar(64)                        
select @WF_status_name = LuStatus_Name                        
from [LuStatus]                        
where LuStatus_Code = @WF_status                        
                        
declare @sequence_id int                        
set @sequence_id = 0                        
set @sequence_id = isnull(                        
                   (                        
                       Select max(MtWFHistory_SequenceID)                        
                       from MtWFHistory                        
                       where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
                             and MtWFHistory_Process_id = @ProcessId                        
                   ),                        
                   0                        
                         ) + 1                        
                        
                        
                        
if @level_id > 1                        
begin                        
                    
                    
    if @chain_count != @interface_chain_count                        
    begin                        
        --reject if process is in-approval                                 
        if exists                        
        (                        
            Select 1                        
            from MtWFHistory                        
            where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
                and MtWFHistory_Process_id = @ProcessId                        
                  and MtWFHistory_ProcessFinalApproval != 1                        
                  and MtWFHistory_ProcessRejected != 1                        
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
            select @WorkFlowHeader_id,                        
                   @ProcessId,                        
                   @process_name,                        
                   @level_id - 1,                        
                   @sequence_id,                        
                   getdate(),                        
                   'WFRJ',                        
                   1,                        
                   @initiator,                        
                   'Rejected by System',                        
                   0,                        
                   1,                        
                   'Rejected by System',                        
                   @user_id,                        
                   getdate(),                        
                   null,                        
                   null,              
       1              
        end                        
                        
        select -1 error_code,                        
               'Work Flow chain is modified,Process will be rejected by system. Please proceed accordingly.'                        
        return                        
    end                        
end            
         
            
insert into MtWFHistory                        
select @WorkFlowHeader_id,                        
       @ProcessId,                        
       @process_name,                
       @level_id,                        
       @sequence_id,                        
       getdate(), /*@WF_status_name*/                        
       @WF_status,                        
       @user_id,                        
       case                        
           when @WF_status in ( 'WFRI', 'WFRA' ) then                        
               @To_resource                        
           else                        
               case                        
                   when @chain_count > 1                        
                        and @WF_status not in ( 'WFRJ' ) then                        
                       AspNetUsers_UserId                  
      when @WF_status = 'WFRJ' then                   
      @initiator                  
         else                        
          null                        
        end                        
       end,                        
       @comments,                        
       0,               
       case                        
           when @WF_status = 'WFRJ' then                        
               1                        
           else                        
               0                        
       end,                        
       @NotificationSubject,                        
       @user_id,                        
       getdate(),                        
       null,                        
       null ,              
    case when @WF_status = 'WFRJ' then                   
      1                  
                   else                        
                       0                        
               end               
from RuWorkFlow_detail                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
      and RuWorkFlow_detail_levelId = /*case                        
                                          when @chain_count > 1         
                                               --and @WF_status  in('WFSM','WFAP','WFRJ') OR(@WF_status='WFRA' and isnull(@Last_level_WF_status,'')!='WFRR')      
              and @WF_status  in('WFSM','WFAP') or (@WF_status='WFRJ' and isnull(@Last_level_WF_status,'')not in ('WFSM','WFRR'))    
     OR(@WF_status='WFRA' and isnull(@Last_level_WF_status,'')not in ('WFSM','WFRR'))*/                
     case when @WF_status  in('WFSM','WFAP')  
              then      
                                              @level_id + 1                        
                                          else                        
                                              @level_id                        
                                      end                        
                        
--Set Approval status ='InProcess' when process is submitted and not fully approved                              
if @level_id < @chain_count                        
   and @WF_status in ( 'WFSM' )                        
BEGIN                        
    if @module_name = 'BME'                        
    begin                        
        update MtStatementProcess                        
        set MtStatementProcess_ApprovalStatus = 'InProcess'                        
        where MtStatementProcess_ID = @ProcessId                        
    end                        
END                        
                        
update MtWFHistory                        
set MtWFHistory_ProcessRejected = case                        
                                 when @WF_status = 'WFRJ' then                        
                                          1                        
                                      else                        
                                          0                    
                                  end                        
where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
      and MtWFHistory_Process_id = @ProcessId        
         
if @WF_status='WFRJ'      
begin       
        update MtStatementProcess                        
        set MtStatementProcess_ApprovalStatus = 'Draft'                        
        where MtStatementProcess_ID = @ProcessId        
end      
      
                       
if @level_id = @chain_count                        
 and @WF_status in ( 'WFSM', 'WFAP' )                        
begin                        
    update MtWFHistory                        
    set MtWFHistory_ProcessFinalApproval = 1                        
    where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
          and MtWFHistory_Process_id = @ProcessId                 
                    
update MtWFHistory                        
    set MtWFHistory_ToResource=null                        
    where RuWorkFlowHeader_id = @WorkFlowHeader_id                        
          and MtWFHistory_Process_id = @ProcessId                 
    and MtWFHistory_SequenceID=@sequence_id                
                        
                        
    if @module_name = 'BME'                      
    begin                        
        update MtStatementProcess                        
        set MtStatementProcess_ApprovalStatus = 'Approved'         
  ,MtStatementProcess_Status='Completed'        
        where MtStatementProcess_ID = @ProcessId                        
    end                        
                        
                        
end                        
              
select 1 error_code,                   
      case when @WF_status='WFSM' then  'Process Submitted Successfully.'              
     when @WF_status='WFAP' then  'Process Approved Successfully.'              
     when @WF_status='WFRJ' then  'Process Rejected Successfully.'              
     when @WF_status='WFRR' then  'Information Request Response Submitted Successfully.'              
     when @WF_status='WFRI' then  'Request Information Submitted Successfully.'              
     when @WF_status='WFRA' then  'Process Re-Assigned Successfully.'              
   end 

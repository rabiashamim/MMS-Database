/****** Object:  Procedure [dbo].[WF_InsertDetail]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
              
                        
                                
                                
CREATE procedure [dbo].[WF_InsertDetail]                                
    @RuWorkFlowHeader_id int,                                
    @action_flag int, --1=insert ,2=update,3=delete                                      
    @level_id int,                                
    @level_description varchar(256) = null,                                
    @level_user_id decimal(18, 0) = null,                                
    @Designation decimal(18, 0) = null,                                
    @user_id decimal(18, 0) ,                      
    @old_level_id int=null,                  
    @old_level_user_id decimal(18, 0) = null                  
as                                
                             
if @action_flag in (2,3)                          
begin                           
                             
;with cte as(                          
select RuWorkFlowHeader_id,MtWFHistory_Process_id,max(MtWFHistory_SequenceID)MtWFHistory_SequenceID                            
from MtWFHistory where RuWorkFlowHeader_id=@RuWorkFlowHeader_id    
and  isnull(MtWFHistory_ProcessFinalApproval,0)!=1 and isnull(MtWFHistory_ProcessRejected,0)!=1   
group by RuWorkFlowHeader_id,MtWFHistory_Process_id                          
)                          
select h.MtWFHistory_Process_id into #detail from MtWFHistory h inner join cte c on h.RuWorkFlowHeader_id=c.RuWorkFlowHeader_id and h.MtWFHistory_Process_id=c.MtWFHistory_Process_id                           
and h.MtWFHistory_SequenceID=c.MtWFHistory_SequenceID                          
where (MtWFHistory_ToResource=@old_level_user_id   or (MtWFHistory_Action='WFRI' and MtWFHistory_FromResource=@old_level_user_id))                
          
        
                          
--if exists(select 1 from #detail)   and ( @old_level_id!= @level_id or    @old_level_user_id !=@level_user_id)                  
--begin                             
--select -1 error_code,'In-Approval processes exists aginst this level.'  error_description                          
--return                            
--end                             
                          
end                          
                          
if @action_flag in (1,2)                           
begin                           
                          
if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and AspNetUsers_UserId=@level_user_id and RuWorkFlow_detail_levelId!=@old_level_id)                            
begin                             
select -1 error_code,'Employee Already exists in Workflow hierarchy. '                            
return                            
end                             
                       
                          
end                          
                          
/*delete levels for which action flag=3 i.e. delete that level*/                                
if @action_flag = 3                                
begin         
        
if exists(select 1 from #detail)          
begin                             
select -1 error_code,'In-Approval processes exists aginst this level.'  error_description                          
return                            
end           
                                
    delete from RuWorkFlow_detail                                
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id                                
          and RuWorkFlow_detail_levelId = @old_level_id                                
                                
  select 1 error_code,'Hierarchy Level Deleted successfully.'                                
                               
end                
                                
if @action_flag = 2                                
BEGIN                        
        
if exists(select 1 from #detail)   and ( @old_level_id!= @level_id or    @old_level_user_id !=@level_user_id)                  
begin                             
select -1 error_code,'In-Approval processes exists aginst this level.'  error_description                          
return                            
end           
        
        
        
                    
if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and RuWorkFlow_detail_levelId=@level_id and @old_level_id!=@level_id)                           
begin                             
select -1 error_code,'Level Already exists in Workflow hierarchy.Please change Sequence #.'                            
return                            
end                       
                  
                    
                    
 update RuWorkFlow_detail                                
    set RuWorkFlow_detail_levelId = @level_id,                                
        AspNetUsers_UserId = @level_user_id,                                
        Lu_Designation_Id = @Designation,                                
        RuWorkFlow_detail_description = @level_description,                                
        RuWorkFlow_detail_ModifiedBy = @user_id,                                
        RuWorkFlow_detail_ModifiedOn = getdate()                                
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id               
          and RuWorkFlow_detail_levelId = @old_level_id                                
                                
                          
select 1 error_code,'Hierarchy Level Updated successfully.'                            
                             
                                
END                                
                                
If @action_flag = 1                        
BEGIN                            
 if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and RuWorkFlow_detail_levelId=@level_id)                   
begin                             
select -1 error_code,'Level Already exists in Workflow hierarchy.Please change Sequence #.'                            
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
          
select 1 error_code,'Hierarchy Level Added successfully.'                         
                                
END                                
                                
--/*                                    
/*Approved and rejected processes should be removed from interface table*/                                
/*delete from RuWorkFlow_detail_Interface  */               
update RuWorkFlow_detail_Interface               
set is_deleted=1              
where RuProcess_ID in (                             
                          select distinct                                
                              MtWFHistory_Process_id                     
                          from MtWFHistory                                
                          where MtWFHistory_ProcessFinalApproval = 1                                
                                or MtWFHistory_ProcessRejected = 1                                
                      )                                
--*/              

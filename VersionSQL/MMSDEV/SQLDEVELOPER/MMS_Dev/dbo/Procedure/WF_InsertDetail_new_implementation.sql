/****** Object:  Procedure [dbo].[WF_InsertDetail_new_implementation]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
      
create procedure [dbo].[WF_InsertDetail_new_implementation]      
    @RuWorkFlowHeader_id int,      
    @action_flag int, --1=insert ,2=update,3=delete            
    @level_id int,      
    @level_description varchar(256) = null,      
    @level_user_id decimal(18, 0) = null,      
    @Designation decimal(18, 0) = null,      
    @user_id decimal(18, 0)      
as      
   
if @action_flag in (2,3)
begin 
   
;with cte as(
select RuWorkFlowHeader_id,MtWFHistory_Process_id,max(MtWFHistory_SequenceID)MtWFHistory_SequenceID  
from MtWFHistory where RuWorkFlowHeader_id=@RuWorkFlowHeader_id
group by RuWorkFlowHeader_id,MtWFHistory_Process_id
)
select h.MtWFHistory_Process_id into #detail from MtWFHistory h inner join cte c on h.RuWorkFlowHeader_id=c.RuWorkFlowHeader_id and h.MtWFHistory_Process_id=c.MtWFHistory_Process_id 
and h.MtWFHistory_SequenceID=c.MtWFHistory_SequenceID
where MtWFHistory_ToResource=@level_user_id

if exists(select 1 from #detail)
begin   
select -1 error_code,'In-Approval processes exists aginst this level.'  error_description
return  
end   

end

if @action_flag in (1,2) 
begin 

if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and AspNetUsers_UserId=@level_user_id and RuWorkFlow_detail_levelId!=@level_id)  
begin   
select -1 error_code,'Employee Already exists in Workflow hierarchy. '  
return  
end   

if exists(select 1 from RuWorkFlow_detail where RuWorkFlowHeader_id=@RuWorkFlowHeader_id and RuWorkFlow_detail_levelId=@level_id and AspNetUsers_UserId!=@level_user_id)  
begin   
select -1 error_code,'Level Already exists in Workflow hierarchy.Please change Sequence #.'  
return  
end   



end

/*delete levels for which action flag=3 i.e. delete that level*/      
if @action_flag = 3      
begin      
      
    delete from RuWorkFlow_detail      
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
          and RuWorkFlow_detail_levelId = @level_id      
      
    
     
end      
      
if @action_flag = 2      
BEGIN
 
 update RuWorkFlow_detail      
    set RuWorkFlow_detail_levelId = @level_id,      
        AspNetUsers_UserId = @level_user_id,      
        Lu_Designation_Id = @Designation,      
        RuWorkFlow_detail_description = @level_description,      
        RuWorkFlow_detail_ModifiedBy = @user_id,      
        RuWorkFlow_detail_ModifiedOn = getdate()      
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
          and RuWorkFlow_detail_levelId = @level_id      
      
     
      
END      
      
If @action_flag = 1      
BEGIN  
 
  
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

  
  
  
  
      
      
      
      
      

/****** Object:  Procedure [dbo].[WF_Get_submission_authorization]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
    
CREATE procedure WF_Get_submission_authorization      
    @ProcessId as decimal(18, 0),      
    @RuModules_Id int,      
    @user_id decimal(18, 0)      
as      
set @RuModules_Id=4--need to remove when process level WF will be implemented
declare @RuWorkFlowHeader_id int,      
        @authorized_user int      
set @authorized_user = 0      
select @RuWorkFlowHeader_id = RuWorkFlowHeader_id      
from RuWorkFlow_header      
where RuModules_id = @RuModules_id      
      
      
if exists      
(      
    select 1      
    from MtWFHistory      
    where MtWFHistory_ProcessFinalApproval != 1      
          and MtWFHistory_ProcessRejected != 1     
    and MtWFHistory_Process_id=@ProcessId    
)      
begin      
    set @authorized_user = 2      
end    
  
       
  
  
  
  
     
if exists      
(      
    select 1      
    from RuWorkFlow_detail      
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id      
          and AspNetUsers_UserId = @user_id      
          and RuWorkFlow_detail_levelId = (Select min(RuWorkFlow_detail_levelId) RuWorkFlow_detail_levelId   
            from RuWorkFlow_detail   
            where RuWorkFlowHeader_id = @RuWorkFlowHeader_id   
            )  
)      
   and @authorized_user != 2      
BEGIN      
    set @authorized_user = 1      
END      
      
      
select @authorized_user authorized_user    
    

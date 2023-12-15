/****** Object:  Procedure [dbo].[WF_Get_submission_authorization]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure dbo.WF_Get_submission_authorization                        
@ProcessId as decimal(18, 0),                        
@Process_Template_Id INT,               
@RuModules_Id int,    
@user_id decimal(18, 0)     
         
as                        
--set @RuModulesProcess_Id=4--need to remove when process level WF will be implemented         
declare @RuModulesProcess_Id int    
select @RuModulesProcess_Id=RuModulesProcess_Id from RuModulesProcess where RuModulesProcess_ProcessTemplateId=@Process_Template_Id and RuModules_Id=@RuModules_Id     
    
declare @RuWorkFlowHeader_id int,                        
        @authorized_user int                        
set @authorized_user = 0                        
select @RuWorkFlowHeader_id = RuWorkFlowHeader_id                        
from RuWorkFlow_header                        
where RuModulesProcess_Id = @RuModulesProcess_Id               
and ISNULL(RuWorkFlowHeader_isDeleted,0)=0          
                        
                        
if exists                        
(                        
    select 1                        
    from MtWFHistory                        
    where MtWFHistory_ProcessFinalApproval != 1                        
          and MtWFHistory_ProcessRejected != 1                       
    and MtWFHistory_Process_id=@ProcessId             
 AND RuWorkFlowHeader_id=@RuWorkFlowHeader_id            
           
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
   and ISNULL(RuWorkFlow_detail_isDeleted,0)=0          
            )
   and ISNULL(RuWorkFlow_detail_isDeleted,0)=0 
)                        
   and @authorized_user != 2                        
BEGIN                        
    set @authorized_user = 1                        
END                        
                        
                        
select @authorized_user authorized_user   
  
  

/****** Object:  Procedure [dbo].[WF_GetWorkflowHeaderDetails]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE procedure WF_GetWorkflowHeaderDetails 
@RuWorkFlowHeader_id int = null --if id not given then show data in list only ,if header id is given then show detail data as well        
as  
BEGIN  
    select RuWorkFlowHeader_id,  
           RuWorkFlowHeader_name,  
           RuWorkFlowHeader_description,  
           RuModules_id  
    from RuWorkFlow_header  
    where RuWorkFlowHeader_id = @RuWorkFlowHeader_id  
END

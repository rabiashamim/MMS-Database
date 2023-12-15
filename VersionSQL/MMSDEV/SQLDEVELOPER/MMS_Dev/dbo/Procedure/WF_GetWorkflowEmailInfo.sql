/****** Object:  Procedure [dbo].[WF_GetWorkflowEmailInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.WF_GetWorkflowEmailInfo      
 -- Add the parameters for the stored procedure here      
 (@ProcessId INT,          
  @user_id INT ,    
  @WorkFlowHeader_id int    
 )      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
 DECLARE @module_id int  ,@LuSOFileTemplate_Url VARCHAR(150)  ,@RuModulesProcess_Id INT 
SELECT @RuModulesProcess_Id=RuModulesProcess_Id FROM RuWorkFlow_header rwfh  WHERE RuWorkFlowHeader_id=@WorkFlowHeader_id  
SELECT @module_id=RuModules_Id FROM RuModulesProcess  WHERE RuModulesProcess_Id=@RuModulesProcess_Id
IF @module_id=3  
BEGIN   
  
SELECT @LuSOFileTemplate_Url=LuSOFileTemplate_Url  
from MtSOFileMaster mt_p                            
  inner join LuSOFileTemplate SPD                          
        on SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id       
where IsNull(MtSOFileMaster_IsDeleted, 0) = 0                          
AND mt_p.MtSOFileMaster_Id=@ProcessId  
  
END  
  
    
 SELECT         
       [dbo].[FN_WF_SENDER_NAME](@ProcessId,@user_id,@WorkFlowHeader_id) LastSender, DBO.FN_WF_Init_NAME_EMAIL(@ProcessId,@WorkFlowHeader_id) Initiator   ,@LuSOFileTemplate_Url LuSOFileTemplate_Url   
      
      
END

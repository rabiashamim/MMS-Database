/****** Object:  Procedure [dbo].[WF_InsertDetail]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
  
    
-- =============================================      
-- Author: ALi| Alina    
-- CREATE date: 26 jan 2023    
-- ALTER date: J26 jan 2023       
-- Description:     
-- updated : soft delete functionality added    
-- =============================================                                     
    
CREATE PROCEDURE dbo.WF_InsertDetail   
@RuWorkFlowHeader_id INT,    
@action_flag INT, --1=insert ,2=update,3=delete                                              
@level_id INT,    
@level_description VARCHAR(256) = NULL,    
@level_user_id DECIMAL(18, 0) = NULL,    
@Designation DECIMAL(18, 0) = NULL,    
@user_id DECIMAL(18, 0),    
@old_level_id INT = NULL,    
@old_level_user_id DECIMAL(18, 0) = NULL    
AS    
    
 IF @action_flag IN (2, 3)    
 BEGIN    
    
  ;    
  WITH cte    
  AS    
  (SELECT    
    RuWorkFlowHeader_id    
      ,MtWFHistory_Process_id    
      ,MAX(MtWFHistory_SequenceID) MtWFHistory_SequenceID    
   FROM MtWFHistory    
   WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id    
   AND ISNULL(MtWFHistory_ProcessFinalApproval, 0) != 1    
   AND ISNULL(MtWFHistory_ProcessRejected, 0) != 1    
   GROUP BY RuWorkFlowHeader_id    
     ,MtWFHistory_Process_id)    
  SELECT    
   h.MtWFHistory_Process_id INTO #detail    
  FROM MtWFHistory h    
  INNER JOIN cte c    
   ON h.RuWorkFlowHeader_id = c.RuWorkFlowHeader_id    
    AND h.MtWFHistory_Process_id = c.MtWFHistory_Process_id    
    AND h.MtWFHistory_SequenceID = c.MtWFHistory_SequenceID    
  WHERE (MtWFHistory_ToResource = @old_level_user_id    
  OR (MtWFHistory_Action = 'WFRI'    
  AND MtWFHistory_FromResource = @old_level_user_id))    
                                      
    
 END    
    
 IF @action_flag IN (1, 2)    
 BEGIN    
    
  IF EXISTS (SELECT    
     1    
    FROM RuWorkFlow_detail    
    WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id    
    AND AspNetUsers_UserId = @level_user_id    
    AND RuWorkFlow_detail_levelId != @old_level_id    
    AND ISNULL(RuWorkFlow_detail_isDeleted,0) = 0)    
  BEGIN    
   SELECT    
    -1 error_code    
      ,'Employee Already exists in Workflow hierarchy. '    
   RETURN    
  END    
    
    
 END    
    
 /*delete levels for which action flag=3 i.e. delete that level*/    
 IF @action_flag = 3    
 BEGIN    
    
  IF EXISTS (SELECT    
     1    
    FROM #detail)    
  BEGIN    
   SELECT    
    -1 error_code    
      ,'In-Approval processes exists aginst this level.' error_description    
   RETURN    
  END    
  UPDATE RuWorkFlow_detail    
  SET RuWorkFlow_detail_isDeleted = 1    
  WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id    
  AND RuWorkFlow_detail_levelId = @old_level_id    
  AND ISNULL(RuWorkFlow_detail_isDeleted,0)=0    
  --delete from RuWorkFlow_detail                                        
  --where RuWorkFlowHeader_id = @RuWorkFlowHeader_id            
  --      and RuWorkFlow_detail_levelId = @old_level_id                                        
    
  SELECT    
   1 error_code    
     ,'Hierarchy Level Deleted successfully.'    
    
 END    
    
 IF @action_flag = 2    
 BEGIN    
    
  IF EXISTS (SELECT    
     1    
    FROM #detail)    
   AND (@old_level_id != @level_id    
   OR @old_level_user_id != @level_user_id)    
  BEGIN    
   SELECT    
    -1 error_code    
      ,'In-Approval processes exists aginst this level.' error_description    
   RETURN    
  END    
    
    
    
    
  IF EXISTS (SELECT    
     1    
    FROM RuWorkFlow_detail    
    WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id    
    AND RuWorkFlow_detail_levelId = @level_id    
    AND @old_level_id != @level_id    
    AND ISNULL(RuWorkFlow_detail_isDeleted ,0)= 0)    
  BEGIN    
   SELECT    
    -1 error_code    
      ,'Level Already exists in Workflow hierarchy.'    
   RETURN    
  END    
    
    
    
  UPDATE RuWorkFlow_detail    
  SET RuWorkFlow_detail_levelId = @level_id    
     ,AspNetUsers_UserId = @level_user_id    
     ,Lu_Designation_Id = @Designation    
     ,RuWorkFlow_detail_description = @level_description    
     ,RuWorkFlow_detail_ModifiedBy = @user_id    
     ,RuWorkFlow_detail_ModifiedOn = GETDATE()    
  WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id    
  AND RuWorkFlow_detail_levelId = @old_level_id    
  AND ISNULL(RuWorkFlow_detail_isDeleted,0)=0    
    
  SELECT    
   1 error_code    
     ,'Hierarchy Level Updated successfully.'    
    
    
 END    
    
 IF @action_flag = 1    
 BEGIN    
  IF EXISTS (SELECT    
     1    
    FROM RuWorkFlow_detail    
    WHERE RuWorkFlowHeader_id = @RuWorkFlowHeader_id    
    AND RuWorkFlow_detail_levelId = @level_id    
    AND ISNULL(RuWorkFlow_detail_isDeleted ,0)= 0)    
  BEGIN    
   SELECT    
    -1 error_code    
      ,'Level Already exists in Workflow hierarchy.'    
   RETURN    
  END    
    
  INSERT INTO RuWorkFlow_detail (RuWorkFlowHeader_id,    
  RuWorkFlow_detail_levelId,    
  RuWorkFlow_detail_description,    
  AspNetUsers_UserId,    
  Lu_Designation_Id,    
  RuWorkFlow_detail_CreatedBy,    
  RuWorkFlow_detail_CreatedOn,    
  RuWorkFlow_detail_isDeleted)    
   SELECT    
    @RuWorkFlowHeader_id    
      ,@level_id    
      ,@level_description    
      ,@level_user_id    
      ,@Designation    
      ,@user_id    
      ,GETDATE()    
      ,0    
    
  SELECT    
   1 error_code    
     ,'Hierarchy Level Added successfully.'    
    
 END    
    
 --/*                                            
 /*Approved and rejected processes should be removed from interface table*/    
 /*delete from RuWorkFlow_detail_Interface  */    
 UPDATE RuWorkFlow_detail_Interface    
 SET is_deleted = 1    
 WHERE mtProcess_ID IN (SELECT DISTINCT    
   MtWFHistory_Process_id    
  FROM MtWFHistory    
  WHERE (MtWFHistory_ProcessFinalApproval = 1    
      
  OR MtWFHistory_ProcessRejected = 1) AND  is_deleted=0)    
--*/   
  

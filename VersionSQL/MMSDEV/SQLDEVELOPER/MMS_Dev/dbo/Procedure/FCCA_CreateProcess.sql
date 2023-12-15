/****** Object:  Procedure [dbo].[FCCA_CreateProcess]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================          
-- Author:  Ammama Gill        
-- CREATE date: 04 May 2023        
-- ALTER date:         
-- Description:         
-- =================================================================================       
CREATE   Procedure dbo.FCCA_CreateProcess (@pPartyRegistration_Id DECIMAL(18, 0), @pUserId INT)  
AS  
BEGIN  
  
 /*****************************************************************************************        
          Insert INTO MtFCCAMaster       
          *****************************************************************************************/  
  
 IF NOT EXISTS (SELECT TOP 1  
    1  
   FROM MtFCCAMaster mf  
   WHERE mf.MtPartyRegisteration_Id = @pPartyRegistration_Id  
   AND mf.MtFCCAMaster_IsDeleted = 0)  
 BEGIN  
  INSERT INTO MtFCCAMaster (MtPartyRegisteration_Id, MtFCCAMaster_Status, MtFCCAMaster_ApprovalStatus, MtFCCAMaster_CreatedBy, MtFCCAMaster_CreatedOn)  
   VALUES (@pPartyRegistration_Id, 'New', 'Draft', @pUserId, GETDATE());  
  
  DECLARE @vFCDMasterId DECIMAL(18, 0) = scope_identity();  
  
  /***************************************************************************      
      Logs section      
    ****************************************************************************/  
  
  DECLARE @output VARCHAR(MAX);  
  SET @output = 'New Process Created: ' + CAST(@vFCDMasterId AS VARCHAR(10)) + ' with name ' + (SELECT  
    MtPartyRegisteration_Name  
   FROM MtPartyRegisteration  
   WHERE MtPartyRegisteration_Id = @pPartyRegistration_Id)  
  + '.';  
  
  EXEC [dbo].[SystemLogs] @user = @pUserId  
          ,@moduleName = 'Firm Capacity Certificate Administration'  
          ,@CrudOperationName = 'Create'  
          ,@logMessage = @output  
  
 /***************************************************************************      
     Logs section      
    ****************************************************************************/  
 END  
  
END

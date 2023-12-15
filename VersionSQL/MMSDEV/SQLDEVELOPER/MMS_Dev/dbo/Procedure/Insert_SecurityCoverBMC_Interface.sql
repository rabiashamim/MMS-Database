/****** Object:  Procedure [dbo].[Insert_SecurityCoverBMC_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================                
-- Author: Ammama Gill                           
-- CREATE date:  14/12/2022                                 
-- ALTER date:                                   
-- Reviewer:                                  
-- Description: Insert Critical Hours Capacity data into the interface table and validate the inserted data.                               
-- =============================================                                   
-- =============================================           
    
CREATE PROCEDURE dbo.Insert_SecurityCoverBMC_Interface  
@pFileMasterId DECIMAL(18, 0),    
@pUserId INT,    
@pTblSecurityCover [dbo].[MtBmcSecurityCover_UDT_Interface] READONLY    
AS    
BEGIN    
 BEGIN TRY    
  
  
INSERT INTO [dbo].[MtSecurityCoverMP_Interface]  
           ([MtSOFileMaster_Id]  
           ,[MtSecurityCoverMP_RowNumber]  
           ,[MtPartyRegisteration_Id]  
           ,[MtSecurityCoverMP_RequiredSecurityCover]  
           ,[MtSecurityCoverMP_SubmittedSecurityCover]  
           ,[MtSecurityCoverMP_IsValid]  
           ,[MtSecurityCoverMP_Message]  
           ,[MtSecurityCoverMP_CreatedBy]  
           ,[MtSecurityCoverMP_CreatedOn])  
  
        SELECT    
    @pFileMasterId    
      ,ROW_NUMBER() OVER (ORDER BY MtPartyRegisteration_Id ) AS CriticalHoursCapacity_CriticalHour    
      ,MtPartyRegisteration_Id    
      ,MtBmcSecurityCover_RequiredSecurityCover 
      ,MtBmcSecurityCover_SubmittedSecurityCover
      ,1    
      ,''    
      ,@pUserId    
      ,GETDATE()    
   FROM @pTblSecurityCover    
  
  EXEC SecurityCoverBMC_Validations @pFileMasterId    
             ,@pUserId;    
    
 END TRY    
 BEGIN CATCH    
    
  SELECT    
   ERROR_NUMBER() AS ErrorNumber    
     ,ERROR_STATE() AS ErrorState    
     ,ERROR_SEVERITY() AS ErrorSeverity    
     ,ERROR_PROCEDURE() AS ErrorProcedure    
     ,ERROR_LINE() AS ErrorLine    
     ,ERROR_MESSAGE() AS ErrorMessage;    
 END CATCH    
    
END

/****** Object:  Procedure [dbo].[fcca_RollbackCancelNonLegacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================          
-- Author:  Ammama Gill        
-- CREATE date: 3 July 2023        
-- ALTER date:         
-- Description:         
-- =================================================================================        
--[fcca_RollbackCancelNonLegacy]      
  
  
CREATE PROCEDURE dbo.fcca_RollbackCancelNonLegacy (@pGeneratorDetailsId DECIMAL(18, 0), @pUserId INT = NULL)  
AS  
BEGIN  
  
 DECLARE @vFromCertificate VARCHAR(20)  
     ,@vToCertificate VARCHAR(20)  
 SELECT  
  @vFromCertificate = MtFCCAGeneratorDetails_FromCertificate  
    ,@vToCertificate = MtFCCAGeneratorDetails_ToCertificate  
 FROM MtFCCAGeneratorDetailsHistory  
 WHERE MtFCCAGeneratorDetailsHistory_Id = @pGeneratorDetailsId  
  
 UPDATE FCCD  
 SET MtFCCDetails_IsCancelled = 0  
 FROM MtFCCDetails FCCD  
 WHERE MtFCCDetails_CertificateId BETWEEN @vFromCertificate AND @vToCertificate  
  
 UPDATE MtFCCAGeneratorDetailsHistory  
 SET MtFCCAGeneratorDetails_Isdeleted = 1  
 WHERE MtFCCAGeneratorDetailsHistory_Id = @pGeneratorDetailsId  
  
 /***************************************************************************          
            Logs section          
          ****************************************************************************/  
  
 DECLARE @vGeneratorId DECIMAL(18, 0);  
 SELECT  
  @vGeneratorId = MtGenerator_Id  
 FROM MtFCCDetails fccd  
 INNER JOIN MtFCCMaster fcc  
  ON fccd.MtFCCMaster_Id = fcc.MtFCCMaster_Id  
 WHERE MtFCCDetails_CertificateId = @vFromCertificate  
  
 DECLARE @output VARCHAR(MAX);  
 SET @output = 'Certificate Cancellation rolled back: ' + CAST(@vGeneratorId AS VARCHAR(10)) + ' with name ' + (SELECT  
   MtGenerator_Name  
  FROM MtGenerator  
  WHERE MtGenerator_Id = @vGeneratorId)  
 + '.';  
 SET @pUserId = ISNULL(@pUserId, 0);-- until latest front end code is not deployed, this check is necessary - to avoid exceptions and let the code flow be normal.    
 EXEC [dbo].[SystemLogs] @user = @pUserId  
         ,@moduleName = 'Firm Capacity Certificate Administration'  
         ,@CrudOperationName = 'Update'  
         ,@logMessage = @output  
  
/***************************************************************************          
    Logs section          
   ****************************************************************************/  
  
END

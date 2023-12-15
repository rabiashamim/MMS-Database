/****** Object:  Procedure [dbo].[Insert_SecurityCoverBMC]    Committed by VersionSQL https://www.versionsql.com ******/

            
/******************************************************************/            
-- =============================================                              
-- Author: Sadaf Malik                                       
-- CREATE date:  3/1/2023                                               
-- ALTER date:                                                 
-- Reviewer:                                                
-- Description: Insert Security Cover data into original table                                             
-- =============================================                                                 
-- =============================================                         
            
   -- dbo.Insert_SecurityCoverBMC 1,1,1        
CREATE   PROCEDURE dbo.Insert_SecurityCoverBMC            
@pFileMasterId DECIMAL(18, 0)            
, @pUserId INT            
, @pIsUseForSettlement BIT            
            
AS            
BEGIN
      
            
            
 BEGIN TRY            
  DECLARE @vMtSecurityCoverMP_Id INT = 0;
  DECLARE @pSOFileTemplate INT = 0;    
  DECLARE @tempname NVARCHAR(MAX) = NULL;       
  declare @version int=0;

SELECT
	@version = MtSOFileMaster_Version
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId

SELECT
	@pSOFileTemplate = LuSOFileTemplate_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId 

SELECT
	@tempname = LuSOFileTemplate_Name
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pSOFileTemplate

SELECT
	@vMtSecurityCoverMP_Id = MAX(ISNULL(mchc.MtSecurityCoverMP_Id, 0))
FROM MtSecurityCoverMP mchc;

INSERT INTO [dbo].[MtSecurityCoverMP] ([MtSOFileMaster_Id]
, [MtSecurityCoverMP_RowNumber]
, [MtPartyRegisteration_Id]
, [MtSecurityCoverMP_RequiredSecurityCover]
, [MtSecurityCoverMP_SubmittedSecurityCover]
, [MtSecurityCoverMP_CreatedBy]
, [MtSecurityCoverMP_CreatedOn])
	SELECT
		mchci.MtSOFileMaster_Id
	   ,@vMtSecurityCoverMP_Id + ROW_NUMBER() OVER (ORDER BY mchci.MtPartyRegisteration_Id)
	   ,mchci.MtPartyRegisteration_Id
	   ,FLOOR(mchci.MtSecurityCoverMP_RequiredSecurityCover)
	   ,FLOOR(mchci.MtSecurityCoverMP_SubmittedSecurityCover)
	   ,@pUserId
	   ,GETDATE()
	FROM MtSecurityCoverMP_Interface mchci
	WHERE mchci.MtSOFileMaster_Id = @pFileMasterId




UPDATE MtSOFileMaster
SET LuStatus_Code = 'DRAF'
   ,MtSOFileMaster_IsUseForSettlement = @pIsUseForSettlement
WHERE MtSOFileMaster_Id = @pFileMasterId;



DELETE FROM MtSecurityCoverMP_Interface
WHERE MtSOFileMaster_Id = @pFileMasterId;

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

/****** Object:  Procedure [dbo].[FCCA_Rollback]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ammama Gill    
-- CREATE date: 08 May 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
--FCCA_Rollback 15  
CREATE   Procedure dbo.FCCA_Rollback (@pFCCAMasterId DECIMAL(18, 0),
@pUserId INT = NULL)
AS
BEGIN


	/*****************************************************************************************    
    Insert blocked bit - set it to 0   
    *****************************************************************************************/
	UPDATE FCCD
	SET MtFCCDetails_Status = 0
	FROM MtFCCDetails FCCD
	INNER JOIN MtFCCMaster FCC
		ON FCCD.MtFCCMaster_Id = FCC.MtFCCMaster_Id
	INNER JOIN MtFCCAGenerator FCCAG
		ON FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
	WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId


	/*****************************************************************************************    
    update KE Share - set it to null.  
    *****************************************************************************************/
	UPDATE FCCA
	SET FCCA.MtFCCAMaster_KEShare = NULL
	FROM MtFCCAMaster FCCA
	WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

	/*****************************************************************************************    
   delete from fccaassignmentdetails    
   *****************************************************************************************/
	DELETE FROM MtFCCAAssigmentDetails
	WHERE MtFCCADetails_Id IN (SELECT
				FCCAD.MtFCCADetails_Id
			FROM MtFCCADetails FCCAD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCAD.MtFCCAGenerator_Id = FCCAG.MtFCCAGenerator_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId)

	/*****************************************************************************************    
    delete from FCCADetails Table   
    *****************************************************************************************/

	DELETE FROM MtFCCADetails
	WHERE MtFCCAGenerator_Id IN (SELECT
				FCCAG.MtFCCAGenerator_Id
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId);

	/*****************************************************************************************    
   delete from fccaGeneratordetails    
   *****************************************************************************************/

	DELETE FROM MtFCCAGeneratorDetails
	WHERE MtFCCAGenerator_Id IN (SELECT
				MtFCCAGenerator_Id
			FROM MtFCCAGenerator fccag
			WHERE MtFCCAMaster_Id = @pFCCAMasterId)

	/*****************************************************************************************    
    delete from fccaGenerator    
    *****************************************************************************************/

	DELETE FROM MtFCCAGenerator
	WHERE MtFCCAMaster_Id = @pFCCAMasterId;



	/*****************************************************************************************    
    Update execution status in FCCA Master    
    *****************************************************************************************/


	UPDATE MtFCCAMaster
	SET MtFCCAMaster_Status = 'Reverted'
	   ,MtFCCAMaster_ApprovalStatus = 'Draft'
	WHERE MtFCCAMaster_Id = @pFCCAMasterId

	/***************************************************************************    
   Logs section    
   ****************************************************************************/
	DECLARE @output VARCHAR(MAX) = '';
	SET @output = 'Process Rolled back: ' + CAST(@pFCCAMasterId AS VARCHAR(10)) + ': ' + (SELECT
			ISNULL(MtPartyRegisteration_Name, '')
		FROM MtFCCAMaster fcca
		INNER JOIN MtPartyRegisteration pr
			ON fcca.MtPartyRegisteration_Id = pr.MtPartyRegisteration_Id
		WHERE MtFCCAMaster_Id = @pFCCAMasterId);

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Certificate Administration'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output

/***************************************************************************    
 Logs section    
****************************************************************************/


END

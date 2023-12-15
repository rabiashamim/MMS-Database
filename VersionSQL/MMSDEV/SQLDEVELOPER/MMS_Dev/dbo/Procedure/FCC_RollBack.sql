/****** Object:  Procedure [dbo].[FCC_RollBack]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ali Imran    
-- CREATE date: 15 March 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
CREATE   Procedure dbo.FCC_RollBack @pMtFCCMaster_Id DECIMAL(18, 0) = 0
, @pUserId INT
AS
BEGIN
	UPDATE MtFCCMaster
	SET MtFCCMaster_IsDeleted = 1
	WHERE MtFCCMaster_Id = @pMtFCCMaster_Id
	UPDATE MtFCCDetails
	SET MtFCCDetails_IsDeleted = 1
	WHERE MtFCCMaster_Id = @pMtFCCMaster_Id

	DELETE FROM MtFCDProcessSteps
	WHERE MtFCDMaster_Id = @pMtFCCMaster_Id
		AND SrFCDProcessDef_Id = 2

	UPDATE MtFCCMaster
	SET LuStatus_Code = 'Reverted'
	   ,MtFCCMaster_ApprovalCode = 'Draft'
	WHERE MtFCCMaster_Id = @pMtFCCMaster_Id



	EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCCMaster_Id
									  ,@pStepNo = 1
									  ,@pStatus = 4
									  ,@pMessage = 'Firm Capacity Certificates Process is rollbacked.'
									  ,@pUserId = @pUserId
									  ,@pSrFCDProcessDef_Id = 2

	/***************************************************************************  
       Logs section  
     ****************************************************************************/

	DECLARE @output VARCHAR(MAX);
	SET @output = 'Process execution rolled back: ' + CAST(@pMtFCCMaster_Id AS VARCHAR(10)) + '. Period: ' + (SELECT
			LuAccountingMonth_MonthName
		FROM MtFCDMaster fcd
		INNER JOIN LuAccountingMonth AM
			ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
		INNER JOIN MtFCCMaster fcc
			ON fcc.MtFCDMaster_Id = fcd.MtFCDMaster_Id
		WHERE MtFCCMaster_Id = @pMtFCCMaster_Id)

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Certificates'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output

/***************************************************************************  
 Logs section  
****************************************************************************/

END

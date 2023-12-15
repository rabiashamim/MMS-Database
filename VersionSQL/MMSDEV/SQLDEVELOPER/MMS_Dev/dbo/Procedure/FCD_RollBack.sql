/****** Object:  Procedure [dbo].[FCD_RollBack]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ali Imran    
-- CREATE date: 15 March 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
CREATE   Procedure dbo.FCD_RollBack @pMtFCDMaster_Id DECIMAL(18, 0)
, @pUserId INT
AS
BEGIN

	DELETE FROM [dbo].[MtFCDHourlyData]
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
	---DELETE FROM [dbo].[MtFCDGenerators] WHERE  MtFCDMaster_Id=@pMtFCDMaster_Id    
	UPDATE [dbo].[MtFCDGenerators]
	SET MtFCDGenerators_EAFactor = NULL
	   ,MtFCDGenerators_TotalGeneration = NULL
	   ,MtFCDGenerators_EnergyGeneratedDuringCurtailment = NULL
	   ,MtFCDGenerators_SoForecastDuringCurtailment = NULL
	   ,MtFCDGenerators_CountNonExistenceHours = NULL
	   ,MtFCDGenerators_EnergyEstimated = NULL
	   ,MtFCDGenerators_InitialFirmCapacity = NULL

	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id


	DELETE FROM [dbo].[MtFCDGenerationCurtailmentForecastHourlyData]
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id

	DELETE FROM MtFCDProcessSteps
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		AND SrFCDProcessDef_Id = 1

	UPDATE MtFCDMaster
	SET MtFCDMaster_ProcessStatus = 'Reverted'
	   ,MtFCDMaster_ApprovalStatus = 'Draft'
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id



	EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
									  ,@pStepNo = 1
									  ,@pStatus = 4
									  ,@pMessage = 'Firm Capacity Determination Process is rollbacked.'
									  ,@pUserId = @pUserId
									  ,@pSrFCDProcessDef_Id = 1

	/***************************************************************************  
      Logs section  
    ****************************************************************************/

	DECLARE @output VARCHAR(MAX);
	SET @output = 'Process execution rolled back: ' + CAST(@pMtFCDMaster_Id AS VARCHAR(10)) + '. Period: ' + (SELECT
			LuAccountingMonth_MonthName
		FROM MtFCDMaster fcd
		INNER JOIN LuAccountingMonth AM
			ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Determination'
						   ,@CrudOperationName = 'Update'
						   ,@logMessage = @output

/***************************************************************************  
 Logs section  
****************************************************************************/

END

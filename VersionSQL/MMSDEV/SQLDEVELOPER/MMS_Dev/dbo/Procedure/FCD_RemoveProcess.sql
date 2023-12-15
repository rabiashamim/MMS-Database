/****** Object:  Procedure [dbo].[FCD_RemoveProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   Procedure dbo.FCD_RemoveProcess @pMtFCDMaster_Id INT,
@pUserId INT
AS
BEGIN
	UPDATE [dbo].[MtFCDMaster]
	SET MtFCDMaster_IsDeleted = 1
	   ,MtFCDMaster_ModifiedOn = GETDATE()
	   ,MtFCDMaster_ModifiedBy = @pUserId
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id

	DELETE FROM MtFCDGenerationCurtailmentForecastHourlyData
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id;

	UPDATE MtFCDGenerators
	SET MtFCDGenerators_IsDeleted = 1
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id;

	DELETE FROM MtFCDHourlyData
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id;

	/***************************************************************************  
    Logs section  
    ****************************************************************************/

	DECLARE @output VARCHAR(MAX);
	SET @output = 'Process Removed: ' + CAST(@pMtFCDMaster_Id AS VARCHAR(10)) + ' Process ID with name :' + (SELECT
			CASE
				WHEN MtFCDMaster_Type = 1 THEN 'All Generators without determined Firm Capacity.'
				WHEN MtFCDMaster_Type = 2 THEN 'All Generators with expired Firm Capacity Certificates.'
				WHEN MtFCDMaster_Type = 3 THEN 'Manual Selection of Generators.'
				ELSE ''
			END
		FROM MtFCDMaster
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)
	+ ' Period :' + (SELECT
			LuAccountingMonth_MonthName
		FROM MtFCDMaster fcd
		INNER JOIN LuAccountingMonth AM
			ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)

	EXEC [dbo].[SystemLogs] @user = @pUserId
						   ,@moduleName = 'Firm Capacity Determination'
						   ,@CrudOperationName = 'Delete'
						   ,@logMessage = @output

	SELECT
		'Data removed successfully' AS response;
END

/****** Object:  Procedure [dbo].[BMCClearData]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================    
-- Author: Ali Imran | AMMAMA GIll    
-- CREATE date: 22 Dec 2022    
-- ALTER date:        
-- Description:                   
--==========================================================================================    
CREATE PROCEDURE dbo.BMCClearData @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

	DECLARE @vProcessDefId INT;
	SELECT
		@vProcessDefId = msp.SrProcessDef_ID
	FROM MtStatementProcess msp
	WHERE msp.MtStatementProcess_ID = @pStatementProcessId;

	DELETE FROM MtStatementProcessSteps
	WHERE MtStatementProcess_ID = @pStatementProcessId;

	IF @vProcessDefId IN (14, 15, 20, 21, 23)
	BEGIN


		DELETE FROM [dbo].[BMCAllocationFactors]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM [dbo].[BMCVariablesData]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM [dbo].[BMCAvailableCapacityGUHourly]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM [dbo].[BMCAvailableCapacityGU]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM [dbo].[BMCAvailableCapacityGen]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM [dbo].[BMCMPData]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM [dbo].[BMCActualEnergyCriticalHourly]
		WHERE MtStatementProcess_ID = @pStatementProcessId
		DELETE FROM BMCMPGenCreditedCapacity
		WHERE MtStatementProcess_ID = @pStatementProcessId

		IF @vProcessDefId = 23 -- BMC EYSS
		BEGIN
			DELETE FROM BMCEYSSAdjustmentMPData
			WHERE MtStatementProcess_ID = @pStatementProcessId;
		END
	END
	ELSE
	IF @vProcessDefId IN (16, 22) -- delete from security cover table  
	BEGIN

		DELETE FROM BMCPYSSMPData
		WHERE MtStatementProcess_ID = @pStatementProcessId;
	END





END

/****** Object:  Procedure [dbo].[BMCPYSSStep2Perform_obselete]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran | AMMAMA GILL
-- CREATE date: 04 JAN 2023
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE PROCEDURE dbo.BMCPYSSStep2Perform_obselete @pStatementProcessId DECIMAL(18, 0)

AS
BEGIN

	/*==========================================================================================
	Fetch BMC final statement ID
	==========================================================================================*/

	DECLARE @vBMCFinalStatementId DECIMAL(18, 0);
	SELECT
		@vBMCFinalStatementId = [dbo].[GetBMCStatementProcessID](@pStatementProcessId);

	--msp.MtStatementProcess_ID
	--      FROM MtStatementProcess msp
	--      WHERE msp.SrProcessDef_ID = 15
	--      AND msp.MtStatementProcess_IsDeleted = 0
	--  --  AND msp.MtStatementProcess_ApprovalStatus = 'Approved'
	--      AND LuAccountingMonth_Id_Current = (SELECT
	--              msp.LuAccountingMonth_Id_Current
	--          FROM MtStatementProcess msp
	--          WHERE msp.MtStatementProcess_ID = @pStatementProcessId
	--          AND msp.MtStatementProcess_IsDeleted = 0)

	/*==========================================================================================
	step2 
	==========================================================================================*/

	DECLARE @vTotalCapacityAvailableRevised [DECIMAL](38, 13);

	SELECT
		@vTotalCapacityAvailableRevised = ABS(SUM(ISNULL([BMCPYSSMPData_CapacityAvailableRevised], 0)))
	FROM [dbo].[BMCPYSSMPData] RMP
	WHERE RMP.MtStatementProcess_ID = @pStatementProcessId

	IF (@vTotalCapacityAvailableRevised <= 0)
	BEGIN
		RETURN;  -- add logs no need to move further.
	END


	/*==========================================================================================
	 step 2 Capacity_Balance_Positive < Capacity_Balance_Negative
	==========================================================================================*/


	UPDATE RMP
	SET RMP.BMCPYSSMPData_CapacitySoldRevised =
		CASE
			WHEN BMCMPData_CapacityBalance >= 0 THEN MP.BMCMPData_CapacitySold
			ELSE RMP.BMCPYSSMPData_CapacitySoldRevised
		END

	   ,RMP.BMCPYSSMPData_CapacityPurchasedRevised =
		CASE
			WHEN BMCMPData_CapacityBalance < 0 AND
				RMP.BMCPYSSMPData_SubmittedSecurityCover >= RMP.BMCPYSSMPData_RequiredSecurityCover THEN (MP.BMCMPData_CapacityBalance * VD.BMCVariablesData_CapacityBalancePositiveSum) / (VD.BMCVariablesData_CapacityBalanceNegativeSum - @vTotalCapacityAvailableRevised)
			ELSE RMP.BMCPYSSMPData_CapacityPurchasedRevised
		END
	FROM BMCMPData MP
	JOIN [dbo].[BMCPYSSMPData] RMP
		ON RMP.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
	JOIN dbo.BMCVariablesData VD
		ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND VD.BMCVariablesData_CapacityBalancePositiveSum < VD.BMCVariablesData_CapacityBalanceNegativeSum



	/*==========================================================================================
	step 2 Capacity_Balance_Positive >= Capacity_Balance_Negative
	==========================================================================================*/

	UPDATE RMP
	SET RMP.BMCPYSSMPData_CapacityPurchasedRevised =
		CASE
			WHEN BMCMPData_CapacityBalance < 0 AND
				RMP.BMCPYSSMPData_SubmittedSecurityCover >= RMP.BMCPYSSMPData_RequiredSecurityCover THEN MP.BMCMPData_CapacityPurchased
			ELSE RMP.BMCPYSSMPData_CapacityPurchasedRevised
		END

	   ,RMP.BMCPYSSMPData_CapacitySoldRevised =
		CASE
			WHEN BMCMPData_CapacityBalance >= 0 THEN (MP.BMCMPData_CapacityBalance * (VD.BMCVariablesData_CapacityBalanceNegativeSum - @vTotalCapacityAvailableRevised)) / VD.BMCVariablesData_CapacityBalancePositiveSum
			ELSE RMP.BMCPYSSMPData_CapacitySoldRevised
		END

	FROM BMCMPData MP
	JOIN [dbo].[BMCPYSSMPData] RMP
		ON RMP.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
	JOIN dbo.BMCVariablesData VD
		ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND VD.BMCVariablesData_CapacityBalancePositiveSum >= VD.BMCVariablesData_CapacityBalanceNegativeSum

/*==========================================================================================

==========================================================================================*/
END

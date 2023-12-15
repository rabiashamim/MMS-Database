/****** Object:  Procedure [dbo].[BMCPYSSStep2Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: AMMAMA GILL
-- CREATE date: 26 JAN 2023
-- ALTER date:    
-- Description:               
--==========================================================================================

--DECLARE @pStatementProcessId DECIMAL(18, 0) = 292

-- final ID = 276

CREATE PROCEDURE dbo.BMCPYSSStep2Perform @pStatementProcessId DECIMAL(18, 0)

AS
BEGIN

	DECLARE @vBMCFinalStatementId DECIMAL(18, 0);
	SELECT
		@vBMCFinalStatementId = [dbo].[GetBMCStatementProcessID](@pStatementProcessId);

	--DECLARE @vfinalId DECIMAL(18, 0) = 276;

	DECLARE @vTotalCapacityAvailableRevised [DECIMAL](20, 10);

	SELECT
		@vTotalCapacityAvailableRevised = ABS(SUM(ISNULL([BMCPYSSMPData_CapacityAvailableRevised], 0)))
	FROM [dbo].[BMCPYSSMPData] RMP
	WHERE RMP.MtStatementProcess_ID = @pStatementProcessId;
	--	SET @vTotalCapacityAvailableRevised = 223441.0894440000000;

	IF EXISTS (SELECT TOP 1
				1
			FROM BMCVariablesData bd
			WHERE bd.MtStatementProcess_ID = @vBMCFinalStatementId
			AND bd.BMCVariablesData_CapacityBalancePositiveSum >= bd.BMCVariablesData_CapacityBalanceNegativeSum)
	BEGIN

		/*=========================================================================================
		step 1a Capacity_Balance_Positive >= Capacity_Balance_Negative. Calculate Additional_Capacity_Available_Share_Reduction_MP and Capacity Purchased Revised
		==========================================================================================*/
		UPDATE RMP
		SET BMCPYSSMPData_CapacityPurchasedRevised =
			CASE
				WHEN MP.BMCMPData_CapacityBalance < 0 THEN RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC
			END
		   ,BMCPYSSMPData_AddlCapacityAvailableShareReduction =
			CASE
				WHEN MP.BMCMPData_CapacityBalance >= 0 THEN CAST((CAST(MP.BMCMPData_CapacityBalance AS DECIMAL(25, 13)) * @vTotalCapacityAvailableRevised) AS DECIMAL(25, 13)) / VD.BMCVariablesData_CapacityBalancePositiveSum
			END
		FROM BMCMPData MP

		INNER JOIN BMCPYSSMPData RMP
			ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
		INNER JOIN BMCVariablesData VD
			ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
		WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
		AND VD.BMCVariablesData_CapacityBalancePositiveSum >= VD.BMCVariablesData_CapacityBalanceNegativeSum
		AND RMP.MtStatementProcess_ID = @pStatementProcessId
		AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID;
		/*==========================================================================================
		step 1b Capacity_Balance_Positive >= Capacity_Balance_Negative. Calculate Revised_Capacity_Sold
		==========================================================================================*/
		UPDATE RMP
		SET RMP.BMCPYSSMPData_CapacitySoldRevised =
		ABS(MP.BMCMPData_CapacitySold) - ABS(RMP.BMCPYSSMPData_AddlCapacityAvailableShareReduction)
		FROM BMCMPData MP

		INNER JOIN BMCPYSSMPData RMP
			ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
		INNER JOIN BMCVariablesData VD
			ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
		WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
		AND RMP.MtStatementProcess_ID = @pStatementProcessId
		AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
		AND VD.BMCVariablesData_CapacityBalancePositiveSum >= VD.BMCVariablesData_CapacityBalanceNegativeSum
		AND MP.BMCMPData_CapacityBalance >= 0;
		RETURN;
	END

	/*==========================================================================================
	step 2 Capacity_Balance_Positive < Capacity_Balance_Negative. Calculate Capacity Purchased Revised
	==========================================================================================*/
	UPDATE RMP
	SET RMP.BMCPYSSMPData_CapacityPurchasedRevised =
	RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC
	FROM BMCMPData MP
	INNER JOIN BMCPYSSMPData RMP
		ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
	INNER JOIN BMCVariablesData VD
		ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND RMP.MtStatementProcess_ID = @pStatementProcessId
	AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	AND VD.BMCVariablesData_CapacityBalancePositiveSum < VD.BMCVariablesData_CapacityBalanceNegativeSum
	AND MP.BMCMPData_CapacityBalance < 0
	AND RMP.BMCPYSSMPData_RequiredSecurityCover > RMP.BMCPYSSMPData_SubmittedSecurityCover;

	/*==========================================================================================
	step 3 Calculate sum of Negative Capacity balance
	==========================================================================================*/

	DECLARE @vCapacityBalanceNegative DECIMAL(38, 13);
	SELECT
		@vCapacityBalanceNegative = ABS(SUM(MP.BMCMPData_CapacityBalance))
	FROM BMCPYSSMPData RMP
	INNER JOIN BMCMPData MP
		ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
	INNER JOIN BMCVariablesData VD
		ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	WHERE RMP.MtStatementProcess_ID = @pStatementProcessId
	AND MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	AND VD.BMCVariablesData_CapacityBalancePositiveSum < VD.BMCVariablesData_CapacityBalanceNegativeSum
	AND MP.BMCMPData_CapacityBalance < 0
	AND RMP.BMCPYSSMPData_RequiredSecurityCover <= RMP.BMCPYSSMPData_SubmittedSecurityCover;

	-- Hard coded value to verify results.
	--SET @vCapacityBalanceNegative = 7166070;
	/*==========================================================================================
		step 2b i Additional Capacity available Share MP
		==========================================================================================*/
	UPDATE RMP
	SET BMCPYSSMPData_CapacityAvailableRevisedShare = CAST((CAST(MP.BMCMPData_CapacityBalance AS DECIMAL(25, 13)) * @vTotalCapacityAvailableRevised) AS DECIMAL(25, 13)) / @vCapacityBalanceNegative
	FROM BMCPYSSMPData RMP
	INNER JOIN BMCMPData MP
		ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
	INNER JOIN BMCVariablesData VD
		ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND RMP.MtStatementProcess_ID = @pStatementProcessId
	AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	AND MP.BMCMPData_CapacityBalance < 0
	AND RMP.BMCPYSSMPData_RequiredSecurityCover <= RMP.BMCPYSSMPData_SubmittedSecurityCover
	AND VD.BMCVariablesData_CapacityBalancePositiveSum < VD.BMCVariablesData_CapacityBalanceNegativeSum


	/*==========================================================================================
	step 2b ii calculate Capacity Purchased Revised
	==========================================================================================*/
	UPDATE RMP
	SET RMP.BMCPYSSMPData_CapacityPurchasedRevised = RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC + ISNULL(RMP.BMCPYSSMPData_CapacityAvailableRevisedShare, 0)
	FROM BMCPYSSMPData RMP
	INNER JOIN BMCMPData MP
		ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
	INNER JOIN BMCVariablesData VD
		ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND RMP.MtStatementProcess_ID = @pStatementProcessId
	AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
	AND MP.BMCMPData_CapacityBalance < 0
	AND RMP.BMCPYSSMPData_RequiredSecurityCover <= RMP.BMCPYSSMPData_SubmittedSecurityCover
	AND VD.BMCVariablesData_CapacityBalancePositiveSum < VD.BMCVariablesData_CapacityBalanceNegativeSum;


	/*==========================================================================================
	step 2b iii calculate Additional Capacity not required by MP (Excess capacity). The excess capacity should be 
	less than or equal to the capacity balance of MP. Otherwise capacity not required by MPs should be pro rated and subtracted from the capacity sold.
	==========================================================================================*/


	UPDATE RMP
	SET RMP.BMCPYSSMPData_ExcessCapacityNotRequired = ABS(RMP.BMCPYSSMPData_CapacityPurchasedRevised) - ABS(MP.BMCMPData_CapacityBalance)
	FROM BMCPYSSMPData RMP
	INNER JOIN BMCMPData MP
		ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND RMP.MtStatementProcess_ID = @pStatementProcessId
	AND RMP.BMCPYSSMPData_CapacityPurchasedRevised > MP.BMCMPData_CapacityBalance;

	DECLARE @vCapNotRequiredByMPs DECIMAL(38, 13) = 0;

	SELECT
		@vCapNotRequiredByMPs = SUM(RMP.BMCPYSSMPData_ExcessCapacityNotRequired)
	FROM BMCPYSSMPData RMP
	WHERE RMP.MtStatementProcess_ID = @pStatementProcessId
	AND RMP.BMCPYSSMPData_ExcessCapacityNotRequired > 0;

	IF ISNULL(@vCapNotRequiredByMPs, 0) = 0
	BEGIN
		UPDATE RMP
		SET BMCPYSSMPData_CapacitySoldRevised = MP.BMCMPData_CapacitySold
		FROM BMCPYSSMPData RMP
		INNER JOIN BMCMPData MP
			ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
		WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
		AND RMP.MtStatementProcess_ID = @pStatementProcessId
		AND MP.BMCMPData_CapacityBalance > 0
	END

	ELSE
	BEGIN
		UPDATE RMP
		SET BMCPYSSMPData_ExcessCapacityNotRequiredShare = CAST((CAST(MP.BMCMPData_CapacityBalance AS DECIMAL(25, 13)) * CAST(RMP.BMCPYSSMPData_ExcessCapacityNotRequired AS DECIMAL(20, 10))) AS DECIMAL(25, 13)) / VD.BMCVariablesData_CapacityBalancePositiveSum
		FROM BMCPYSSMPData RMP
		INNER JOIN BMCMPData MP
			ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
		INNER JOIN BMCVariablesData VD
			ON VD.MtStatementProcess_ID = MP.MtStatementProcess_ID
		WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
		AND RMP.MtStatementProcess_ID = @pStatementProcessId
		AND VD.MtStatementProcess_ID = MP.MtStatementProcess_ID



		UPDATE RMP
		SET BMCPYSSMPData_CapacitySoldRevised = MP.BMCMPData_CapacityBalance - RMP.BMCPYSSMPData_ExcessCapacityNotRequiredShare
		FROM BMCPYSSMPData RMP
		INNER JOIN BMCMPData MP
			ON MP.MtPartyRegisteration_Id = RMP.MtPartyRegisteration_Id
		WHERE RMP.MtStatementProcess_ID = @pStatementProcessId
		AND MP.MtStatementProcess_ID = @vBMCFinalStatementId
	END


END

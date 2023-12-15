/****** Object:  Procedure [dbo].[BMCEYSSStep13Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: AMMAMA GILL
-- CREATE date: 22 FEB 2023
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE PROCEDURE dbo.BMCEYSSStep13Perform @pStatementProcessId DECIMAL(18, 0)

AS
BEGIN

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM BMCEYSSAdjustmentMPData bm
			WHERE bm.MtStatementProcess_ID = @pStatementProcessId)
	BEGIN

		/*==========================================================================================  
	    Fetch last BMC statement ID  
	    ==========================================================================================*/
		DECLARE @vLatestStatementId DECIMAL(18, 0)
			   ,@vProcessDefId DECIMAL(18, 0);

		SELECT
			@vLatestStatementId = MAX(msp.MtStatementProcess_ID)
		   ,@vProcessDefId = MAX(msp.SrProcessDef_ID)
		FROM MtStatementProcess msp
		WHERE msp.SrProcessDef_ID IN (22,23)
		AND msp.LuAccountingMonth_Id_Current = (SELECT
				MSP.LuAccountingMonth_Id_Current
			FROM MtStatementProcess MSP
			WHERE MSP.MtStatementProcess_ID = @pStatementProcessId)
		AND ISNULL(msp.MtStatementProcess_IsDeleted, 0) = 0
		AND msp.MtStatementProcess_ID <> @pStatementProcessId
		AND ISNULL(msp.MtStatementProcess_IsDeleted, 0) = 0

		/*==========================================================================================  
	    Fetch payables/receivables from last executed FSS/ESS
	    ==========================================================================================*/

		CREATE TABLE #PreviousStatementData (
			PreviousStatement_Id DECIMAL(18, 0)
		   ,MtPartyRegistration_Id DECIMAL(18, 0)
		   ,AmountPayable DECIMAL(38, 13)
		   ,AmountReceivable DECIMAL(38, 13)
		)

		IF @vProcessDefId = 22
		BEGIN
			INSERT INTO #PreviousStatementData
				SELECT
					RMP.MtStatementProcess_ID
				   ,RMP.MtPartyRegisteration_Id
				   ,RMP.BMCPYSSMPData_AmountPayableRevised
				   ,RMP.BMCPYSSMPData_AmountReceivableRevised

				FROM BMCPYSSMPData RMP
				WHERE RMP.MtStatementProcess_ID = @vLatestStatementId
		END

		ELSE
		IF @vProcessDefId = 23
		BEGIN
			INSERT INTO #PreviousStatementData
				SELECT
					MP.MtStatementProcess_ID
				   ,MP.MtPartyRegisteration_Id
				   ,MP.BMCMPData_AmountPayable
				   ,MP.BMCMPData_AmountReceivable
				FROM BMCMPData MP
				WHERE MP.MtStatementProcess_ID = @vLatestStatementId
		END

		IF EXISTS (SELECT TOP 1
					1
				FROM #PreviousStatementData history)
		BEGIN

			INSERT INTO BMCEYSSAdjustmentMPData (MtStatementProcess_ID,
			MtPartyRegisteration_Id,
			MtStatementProcess_ID_Reference)
				SELECT
					@pStatementProcessId
				   ,psd.MtPartyRegistration_Id
				   ,psd.PreviousStatement_Id
				FROM #PreviousStatementData psd

			/*==========================================================================================  
			Calculate ESS adjustment MP wise: Net Amount Payable
			==========================================================================================*/
			UPDATE EYSS
			SET BMCEYSSAdjustmentMPData_NetAmountPayable =
			ISNULL(RMP.BMCMPData_AmountPayable, 0) - ISNULL(MP.AmountPayable, 0)
			FROM BMCMPData RMP
			INNER JOIN #PreviousStatementData MP
				ON MP.MtPartyRegistration_Id = RMP.MtPartyRegisteration_Id
			INNER JOIN BMCEYSSAdjustmentMPData EYSS
				ON EYSS.MtPartyRegisteration_Id = MP.MtPartyRegistration_Id
			WHERE RMP.MtStatementProcess_ID = @pStatementProcessId
			AND EYSS.MtStatementProcess_ID = @pStatementProcessId

			/*==========================================================================================  
			Calculate ESS adjustment MP wise: Net Amount Receivable
			==========================================================================================*/
			UPDATE EYSS
			SET BMCEYSSAdjustmentMPData_NetAmountReceivable =
			ISNULL(RMP.BMCMPData_AmountReceivable, 0) - ISNULL(MP.AmountReceivable, 0)
			FROM BMCMPData RMP
			INNER JOIN #PreviousStatementData MP
				ON MP.MtPartyRegistration_Id = RMP.MtPartyRegisteration_Id
			INNER JOIN BMCEYSSAdjustmentMPData EYSS
				ON EYSS.MtPartyRegisteration_Id = MP.MtPartyRegistration_Id
			WHERE RMP.MtStatementProcess_ID = @pStatementProcessId
			AND EYSS.MtStatementProcess_ID = @pStatementProcessId


			/*==========================================================================================  
			Calculate ESS adjustment MP wise 
			==========================================================================================*/

			UPDATE EYSS
			SET BMCEYSSAdjustmentMPData_NetAdjustments = EYSS.BMCEYSSAdjustmentMPData_NetAmountPayable - EYSS.BMCEYSSAdjustmentMPData_NetAmountReceivable
			FROM BMCEYSSAdjustmentMPData EYSS
			WHERE EYSS.MtStatementProcess_ID = @pStatementProcessId

		END
	END


END

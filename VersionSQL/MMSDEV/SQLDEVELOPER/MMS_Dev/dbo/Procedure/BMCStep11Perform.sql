/****** Object:  Procedure [dbo].[BMCStep11Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran| AMMAMA Gill
-- CREATE date: 28 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE PROCEDURE dbo.BMCStep11Perform @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN



	/*==========================================================================================
	Step 11. Capacity sold and purchased determined MP wise
	==========================================================================================*/

	UPDATE b
	SET b.BMCMPData_CapacitySold =
		--CASE
		--    WHEN bd.BMCVariablesData_CapacityBalancePositiveSum <= bd.BMCVariablesData_CapacityBalanceNegativeSum AND b.BMCMPData_CapacityBalance >0  THEN 
		--         b.BMCMPData_CapacityBalance 
		-- WHEN bd.BMCVariablesData_CapacityBalancePositiveSum > bd.BMCVariablesData_CapacityBalanceNegativeSum AND b.BMCMPData_CapacityBalance >0  THEN 
		--         (b.BMCMPData_CapacityBalance*BMCVariablesData_CapacityBalanceNegativeSum)/BMCVariablesData_CapacityBalancePositiveSum	 
		--ELSE 0 

		--END 
		CASE
			WHEN bd.BMCVariablesData_CapacityBalancePositiveSum <= bd.BMCVariablesData_CapacityBalanceNegativeSum AND
				b.BMCMPData_CapacityBalance > 0 THEN b.BMCMPData_CapacityBalance
			WHEN bd.BMCVariablesData_CapacityBalancePositiveSum > bd.BMCVariablesData_CapacityBalanceNegativeSum AND
				b.BMCMPData_CapacityBalance > 0 THEN CAST(CAST(b.BMCMPData_CapacityBalance AS DECIMAL(25, 13)) * (CAST(BMCVariablesData_CapacityBalanceNegativeSum AS DECIMAL(20, 10))) AS DECIMAL(25, 13)) / BMCVariablesData_CapacityBalancePositiveSum
			ELSE 0

		END
	   ,b.BMCMPData_CapacityPurchased =

		--CASE
		--       WHEN bd.BMCVariablesData_CapacityBalancePositiveSum <= bd.BMCVariablesData_CapacityBalanceNegativeSum AND b.BMCMPData_CapacityBalance <0  THEN 
		--            (b.BMCMPData_CapacityBalance*BMCVariablesData_CapacityBalancePositiveSum)/BMCVariablesData_CapacityBalanceNegativeSum
		--    WHEN bd.BMCVariablesData_CapacityBalancePositiveSum > bd.BMCVariablesData_CapacityBalanceNegativeSum AND b.BMCMPData_CapacityBalance <0  THEN 
		--            b.BMCMPData_CapacityBalance ELSE 0 

		--   END
		CASE
			WHEN bd.BMCVariablesData_CapacityBalancePositiveSum <= bd.BMCVariablesData_CapacityBalanceNegativeSum AND
				b.BMCMPData_CapacityBalance < 0 THEN CAST(CAST(b.BMCMPData_CapacityBalance AS DECIMAL(25, 13)) *
				CAST(BMCVariablesData_CapacityBalancePositiveSum AS DECIMAL(20, 10)) AS DECIMAL(25, 13)) / BMCVariablesData_CapacityBalanceNegativeSum
			WHEN bd.BMCVariablesData_CapacityBalancePositiveSum > bd.BMCVariablesData_CapacityBalanceNegativeSum AND
				b.BMCMPData_CapacityBalance < 0 THEN b.BMCMPData_CapacityBalance
			ELSE 0

		END
	FROM BMCMPData b
	JOIN BMCVariablesData bd
		ON b.MtStatementProcess_ID = bd.MtStatementProcess_ID
	WHERE b.MtStatementProcess_ID = @pStatementProcessId

END

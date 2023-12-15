/****** Object:  Procedure [dbo].[BMCStep9Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran| AMMAMA Gill
-- CREATE date: 28 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE   PROCEDURE dbo.BMCStep9Perform @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

/*==========================================================================================
step 9 A Calculate BMCMPData_CapacityBalance
==========================================================================================*/


	UPDATE BMCMPData
	SET BMCMPData_CapacityBalance = BMCMPData_AllocatedCapacity - BMCMPData_CapacityRequirement
	WHERE MtStatementProcess_ID = @pStatementProcessId


/*==========================================================================================
Calculate Capacity Balance Positive and Negative
Calculate EDL
==========================================================================================*/

;
WITH cte_CapacityBalanceData
AS
(SELECT
		SUM(CASE
			WHEN BMCMPData_CapacityBalance >= 0 THEN BMCMPData_CapacityBalance
			ELSE 0
		END) AS Positive
	   ,SUM(CASE
			WHEN BMCMPData_CapacityBalance < 0 THEN BMCMPData_CapacityBalance
			ELSE 0
		END) AS Negative
	   ,MAX(BMD.MtStatementProcess_ID) AS MtStatementProcess_ID
	FROM BMCMPData BMD
	WHERE MtStatementProcess_ID = @pStatementProcessId)


UPDATE BMCVariablesData
SET BMCVariablesData_CapacityBalanceNegativeSum = ABS(CBD.Negative)
   ,BMCVariablesData_CapacityBalancePositiveSum = CBD.Positive
   ,BMCVariablesData_EfficientDemandLevel_EDL = ABS(CBD.Negative) * ((1 + (bd.BMCVariablesData_EfficientlevelReserve/100)) / (1 + (bd.BMCVariablesData_ReserveMargin/100)))
FROM BMCVariablesData bd
JOIN cte_CapacityBalanceData CBD
	ON bd.MtStatementProcess_ID = CBD.MtStatementProcess_ID
WHERE bd.MtStatementProcess_ID=@pStatementProcessId
END

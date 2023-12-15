/****** Object:  Procedure [dbo].[BMCStep10Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran| AMMAMA Gill
-- CREATE date: 28 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE   PROCEDURE dbo.BMCStep10Perform @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN


/*==========================================================================================
Step 10. Calculate variables : SLOPE , C_Constant , UnitaryCostCapacity , Point_D_Qty
==========================================================================================*/

UPDATE BMCVariablesData
SET 
	BMCVariablesData_Slope = (BMCVariablesData_UnitaryCostCapacity / NULLIF((BMCVariablesData_CapacityBalanceNegativeSum - BMCVariablesData_EfficientDemandLevel_EDL),0))
WHERE 
	MtStatementProcess_ID = @pStatementProcessId;
/*==========================================================================================*/
UPDATE BMCVariablesData
SET 
   BMCVariablesData_C_Constant = BMCVariablesData_UnitaryCostCapacity - ISNULL(BMCVariablesData_EfficientDemandLevel_EDL *(BMCVariablesData_Slope)	,0)
WHERE 
	MtStatementProcess_ID = @pStatementProcessId;
/*==========================================================================================*/
UPDATE BMCVariablesData
SET 
   BMCVariablesData_Point_D_Qty = ISNULL(((0.8 * BMCVariablesData_UnitaryCostCapacity) - BMCVariablesData_C_Constant) / BMCVariablesData_Slope,0)
WHERE 
	MtStatementProcess_ID = @pStatementProcessId;


/*==========================================================================================
Step 10. Calculate Capacity Price
==========================================================================================*/
UPDATE bd
SET BMCVariablesData_CapacityPrice=
	CASE
		WHEN bd.BMCVariablesData_CapacityBalancePositiveSum <= bd.BMCVariablesData_CapacityBalanceNegativeSum THEN 2 * bd.BMCVariablesData_UnitaryCostCapacity
		ELSE CASE
				WHEN bd.BMCVariablesData_CapacityBalancePositiveSum >= bd.BMCVariablesData_Point_D_Qty THEN 0.8 * bd.BMCVariablesData_UnitaryCostCapacity
				ELSE CASE
						WHEN bd.BMCVariablesData_CapacityBalancePositiveSum > bd.BMCVariablesData_CapacityBalanceNegativeSum AND
							bd.BMCVariablesData_CapacityBalancePositiveSum < bd.BMCVariablesData_Point_D_Qty THEN (bd.BMCVariablesData_CapacityBalancePositiveSum * bd.BMCVariablesData_Slope) + bd.BMCVariablesData_C_Constant
					END
			END
	END

FROM BMCVariablesData bd
WHERE bd.MtStatementProcess_ID = @pStatementProcessId
END

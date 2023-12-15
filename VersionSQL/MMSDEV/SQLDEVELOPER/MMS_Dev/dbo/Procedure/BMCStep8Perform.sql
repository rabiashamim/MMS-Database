/****** Object:  Procedure [dbo].[BMCStep8Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran| AMMAMA Gill
-- CREATE date: 28 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE   PROCEDURE dbo.BMCStep8Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN


CREATE TABLE #tempCalculations (
Avg_ActualE  DECIMAL(25,13),
Cal_ReserveMargin  DECIMAL(25,13),
Actual_E DECIMAL(25,13),
MtPartyRegisteration_Id DECIMAL(18,0)
)


/*==========================================================================================
step 8 : calculate CapacityRequirmentMP
==========================================================================================*/

;WITH CTE_CapacityRequirement
AS
(SELECT
		CH.MtPartyRegisteration_Id
		,SUM(CH.BMCActualEnergyCriticalHourly_ActualEnergy) AS  Actual_E
	   --,(SUM(CH.BMCActualEnergyCriticalHourly_ActualEnergy) / 50) * (1 + MAX(VD.[BMCVariablesData_ReserveMargin])) AS CapacityRequirmentMP

	FROM 
		[dbo].[BMCActualEnergyCriticalHourly] CH
	JOIN 
		BMCVariablesData VD ON CH.MtStatementProcess_ID = VD.MtStatementProcess_ID
	WHERE CH.MtStatementProcess_ID = @pStatementProcessId
	GROUP BY CH.MtPartyRegisteration_Id)


INSERT INTO #tempCalculations
SELECT 
 CAST(((Actual_E/50)/1000) AS DECIMAL(38,13)) AS Avg_ActualE 
 , CAST((1 + CAST(VD.[BMCVariablesData_ReserveMargin]/100 AS DECIMAL(38,13))) AS DECIMAL(38,13))  AS Cal_ReserveMargin
 , Actual_E AS C
 ,MP.MtPartyRegisteration_Id AS D

FROM 
	CTE_CapacityRequirement CH
JOIN BMCMPData MP ON MP.MtPartyRegisteration_Id = CH.MtPartyRegisteration_Id
JOIN BMCVariablesData VD ON MP.MtStatementProcess_ID = VD.MtStatementProcess_ID
WHERE 
	MP.MtStatementProcess_ID = @pStatementProcessId


UPDATE 
	MP
SET 
	MP.BMCMPData_CapacityRequirement =  TC.Avg_ActualE * TC.Cal_ReserveMargin
    ,MP.BMCMPData_Actual_E=TC.Actual_E/1000
FROM 
	#tempCalculations TC
JOIN BMCMPData MP ON MP.MtPartyRegisteration_Id = TC.MtPartyRegisteration_Id
JOIN BMCVariablesData VD ON MP.MtStatementProcess_ID = VD.MtStatementProcess_ID
WHERE 
	MP.MtStatementProcess_ID = @pStatementProcessId


END

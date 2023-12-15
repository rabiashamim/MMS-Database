/****** Object:  Procedure [dbo].[BMCStep3and4Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran
-- CREATE date: 21 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE PROCEDURE dbo.BMCStep3and4Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

/*==========================================================================================
fetch k.E value and  TotalAvailableCapacityAvg
==========================================================================================*/
DECLARE @vKEShare DECIMAL(18, 8)
SELECT
	@vKEShare = BMCVariablesData_KEShare_MW
FROM BMCVariablesData
WHERE MtStatementProcess_ID = @pStatementProcessId

DECLARE @vTotalAvailableCapacityAvg DECIMAL(18, 8)
SELECT
	@vTotalAvailableCapacityAvg = SUM(BMCAvailableCapacityGen_AvailableCapacityAvg)
FROM [dbo].[BMCAvailableCapacityGen]
WHERE MtStatementProcess_ID = @pStatementProcessId




/*==========================================================================================
Prorate KE_Share for each generator
==========================================================================================*/

--SELECT BMCAvailableCapacityGen_AvailableCapacityAvg-((BMCAvailableCapacityGen_AvailableCapacityAvg*@vKEShare*1000)/27462514) FROM [dbo].[BMCAvailableCapacityGen] WHERE MtStatementProcess_ID=241

UPDATE ACG
SET ACG.BMCAvailableCapacityGen_AvailableCapacityKE =
(cast(ACG.BMCAvailableCapacityGen_AvailableCapacityAvg * @vKEShare AS DECIMAL(25,13)) /@vTotalAvailableCapacityAvg
)
FROM [dbo].[BMCAvailableCapacityGen] ACG
WHERE MtStatementProcess_ID = @pStatementProcessId




END

/****** Object:  Procedure [dbo].[BMCStep5Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran
-- CREATE date: 21 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE   PROCEDURE dbo.BMCStep5Perform 

@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

/*==========================================================================================
Calculate and update AvailableCapacityAfterKE
==========================================================================================*/

UPDATE ACG
SET ACG.BMCAvailableCapacityGen_AvailableCapacityAfterKE =
ACG.BMCAvailableCapacityGen_AvailableCapacityAvg - BMCAvailableCapacityGen_AvailableCapacityKE
FROM [dbo].[BMCAvailableCapacityGen] ACG
WHERE MtStatementProcess_ID = @pStatementProcessId




END

/****** Object:  Procedure [dbo].[BMCStep6and7Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran
-- CREATE date: 21 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE PROCEDURE dbo.BMCStep6and7Perform --241
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

	/*==========================================================================================
	Calculate @vTotalAvailableCapacityAfterKE
	==========================================================================================*/

	DECLARE @vTotalAvailableCapacityAfterKE DECIMAL(25, 13)
	        ,@vTotalAvailableCapacityWithKE DECIMAL(25, 13)
		   ,@vTotalAvailableCapacityKE DECIMAL(25, 13)
	SELECT
		@vTotalAvailableCapacityAfterKE = SUM(BMCAvailableCapacityGen_AvailableCapacityAfterKE)
	   ,@vTotalAvailableCapacityKE = SUM(BMCAvailableCapacityGen_AvailableCapacityKE)
	   ,@vTotalAvailableCapacityWithKE = SUM(BMCAvailableCapacityGen_AvailableCapacityAvg)
	FROM [dbo].[BMCAvailableCapacityGen]
	WHERE MtStatementProcess_ID = @pStatementProcessId


	/*==========================================================================================
	Calculate Credited Capacity Generator wise.
	==========================================================================================*/
	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[BMCMPGenCreditedCapacity] WHERE MtStatementProcess_ID=@pStatementProcessId)
	BEGIN
	INSERT INTO [dbo].[BMCMPGenCreditedCapacity](
			[MtPartyRegisteration_Id]
           ,[BMCMPGenCreditedCapacity_CreditedCapacity]
           ,MtGenerator_Id
           ,[MtStatementProcess_ID])

SELECT
	AF.MtPartyRegisteration_Id

   ,CASE
	--	WHEN AF.MtPartyRegisteration_Id = 12 THEN BMCAvailableCapacityGen_AvailableCapacityKE
	--	ELSE ((@vTotalAvailableCapacityAfterKE * CG.BMCAvailableCapacityGen_AvailableCapacityAvg) / @vTotalAvailableCapacityWithKE)
	--		* (AF.BMCAllocationFactors_AllocationFactor / 100)
	--END AS CapacityValue
	WHEN AF.MtPartyRegisteration_Id = 12 THEN BMCAvailableCapacityGen_AvailableCapacityKE
		--ELSE cast(@vTotalAvailableCapacityAfterKE * (CG.BMCAvailableCapacityGen_AvailableCapacityAvg / @vTotalAvailableCapacityWithKE) AS DECIMAL(25,13))
		ELSE BMCAvailableCapacityGen_AvailableCapacityAfterKE
			* (cast(
			AF.BMCAllocationFactors_AllocationFactor / 100 AS DECIMAL(5,3)))
	END AS CapacityValue
   ,CG.MtGenerator_Id
   ,@pStatementProcessId
FROM [dbo].[BMCAvailableCapacityGen] CG
JOIN BMCAllocationFactors AF
	ON AF.MtStatementProcess_ID = CG.MtStatementProcess_ID
	JOIN MtPartyRegisteration P
			ON AF.MtPartyRegisteration_Id = P.MtPartyRegisteration_Id
WHERE CG.MtStatementProcess_ID = @pStatementProcessId
		--AND P.LuStatus_Code_Approval = 'AAPR'
		AND P.LuStatus_Code_Applicant = 'AACT'
		AND ISNULL(P.isDeleted, 0) = 0	
	END
	


	/*==========================================================================================
	Calculate Credited Capacity to each MP SOLR (DISCOs)
	==========================================================================================*/

	IF NOT EXISTS ( SELECT TOP 1
		1
	FROM [dbo].[BMCMPData]
	WHERE MtStatementProcess_ID = @pStatementProcessId)
BEGIN
	INSERT INTO [dbo].[BMCMPData] (
	  [MtPartyRegisteration_Id]
	, [BMCMPData_AllocatedCapacity]
	, [MtStatementProcess_ID])
	SELECT 
	MtPartyRegisteration_Id
	,SUM([BMCMPGenCreditedCapacity_CreditedCapacity]) 
	,@pStatementProcessId
	FROM [dbo].[BMCMPGenCreditedCapacity] 
	WHERE [MtStatementProcess_ID]= @pStatementProcessId
	GROUP BY MtPartyRegisteration_Id
	
		--SELECT
		--	AF.MtPartyRegisteration_Id
		--	--,@vTotalAvailableCapacityAfterKE * (BMCAllocationFactors_AllocationFactor/100)
		--   ,CASE
		--		WHEN AF.MtPartyRegisteration_Id = 12 THEN @vTotalAvailableCapacityKE
		--		ELSE @vTotalAvailableCapacityAfterKE * (BMCAllocationFactors_AllocationFactor / 100)
		--	END
		--   ,MtStatementProcess_ID

		--FROM BMCAllocationFactors AF
		--JOIN MtPartyRegisteration P
		--	ON AF.MtPartyRegisteration_Id = P.MtPartyRegisteration_Id
		--WHERE MtStatementProcess_ID = @pStatementProcessId
		--AND P.LuStatus_Code_Approval = 'AAPR'
		--AND P.LuStatus_Code_Applicant = 'AACT'
		--AND ISNULL(P.isDeleted, 0) = 0

END

END

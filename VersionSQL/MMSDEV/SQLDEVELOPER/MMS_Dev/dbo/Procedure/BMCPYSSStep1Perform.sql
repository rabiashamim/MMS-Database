/****** Object:  Procedure [dbo].[BMCPYSSStep1Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================  
-- Author: Ali Imran | AMMAMA GILL  
-- CREATE date: 04 JAN 2023  
-- ALTER date:      
-- Description:                 
--==========================================================================================  
CREATE PROCEDURE dbo.BMCPYSSStep1Perform @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

	/*==========================================================================================  
    Fetch BMC final statement ID  
    ==========================================================================================*/

	DECLARE @vBMCFinalStatementId DECIMAL(18, 0);
	SELECT
		@vBMCFinalStatementId = [dbo].[GetBMCStatementProcessID](@pStatementProcessId);


	/*==========================================================================================  
	 Insert [BMCPYSSMPData]  
	 ==========================================================================================*/
	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [dbo].[BMCPYSSMPData]
			WHERE MtStatementProcess_ID = @pStatementProcessId)--@pStatementProcessId  
	BEGIN


		INSERT INTO [dbo].[BMCPYSSMPData] ([MtPartyRegisteration_Id]
		, [MtStatementProcess_ID])

			SELECT

				MtPartyRegisteration_Id
			   ,@pStatementProcessId
			FROM BMCMPData b
			WHERE b.MtStatementProcess_ID = @vBMCFinalStatementId



	END

	/*==========================================================================================  
  Fetch Security Cover Data  
  ==========================================================================================*/

	UPDATE MP
	SET MP.BMCPYSSMPData_RequiredSecurityCover = SC.MtSecurityCoverMP_RequiredSecurityCover
	   ,MP.BMCPYSSMPData_SubmittedSecurityCover = SC.MtSecurityCoverMP_SubmittedSecurityCover

	FROM MtSecurityCoverMP SC
	JOIN [BMCPYSSMPData] MP
		ON MP.MtPartyRegisteration_Id = SC.MtPartyRegisteration_Id
	WHERE SC.MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 12)
	AND MP.MtStatementProcess_ID = @pStatementProcessId


	/*==========================================================================================  
   Calulate Capacity Purchased Revised  = Preliminary Capacity Allocated
   ==========================================================================================*/
	UPDATE RMP
	SET RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC =
	(RMP.[BMCPYSSMPData_SubmittedSecurityCover] * MP.BMCMPData_CapacityPurchased)
	/ RMP.[BMCPYSSMPData_RequiredSecurityCover]

	FROM BMCMPData MP
	JOIN [dbo].[BMCPYSSMPData] RMP
		ON RMP.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	-- need to confirm from MOD- Zeeshan 
	--AND RMP.[BMCPYSSMPData_SubmittedSecurityCover] < RMP.[BMCPYSSMPData_RequiredSecurityCover]


	/*==========================================================================================  
    Calculate Revised available capacity  
    ==========================================================================================*/


	UPDATE RMP
	SET RMP.[BMCPYSSMPData_CapacityAvailableRevised] =
	BMCMPData_CapacityPurchased - BMCPYSSMPData_PreliminaryCapacityAllocatedSC

	FROM BMCMPData MP
	JOIN [dbo].[BMCPYSSMPData] RMP
		ON RMP.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
	AND RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC IS NOT NULL
-- need to confirm from MOD- Zeeshan 
--AND RMP.[BMCPYSSMPData_SubmittedSecurityCover] < RMP.[BMCPYSSMPData_RequiredSecurityCover]




----------------- STEP 1 End ----------------



--	/*==========================================================================================  
--    Insert [BMCPYSSMPData]  
--    ==========================================================================================*/
--	IF NOT EXISTS (SELECT TOP 1
--				1
--			FROM [dbo].[BMCPYSSMPData]
--			WHERE MtStatementProcess_ID = @pStatementProcessId)--@pStatementProcessId  
--	BEGIN


--		INSERT INTO [dbo].[BMCPYSSMPData] ([MtPartyRegisteration_Id]
--		, [MtStatementProcess_ID])

--			SELECT

--				MtPartyRegisteration_Id
--			   ,@pStatementProcessId
--			FROM BMCMPData b
--			WHERE b.MtStatementProcess_ID = @vBMCFinalStatementId

--	END

--	/*==========================================================================================  
--    Fetch Security Cover Data  
--    ==========================================================================================*/

--	UPDATE MP
--	SET MP.BMCPYSSMPData_RequiredSecurityCover = MtSecurityCoverMP_RequiredSecurityCover
--	   ,MP.BMCPYSSMPData_SubmittedSecurityCover = MtSecurityCoverMP_SubmittedSecurityCover

--	FROM MtSecurityCoverMP SC
--	JOIN [BMCPYSSMPData] MP
--		ON MP.MtPartyRegisteration_Id = SC.MtPartyRegisteration_Id
--	WHERE MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 12)
--	AND MP.MtStatementProcess_ID = @pStatementProcessId

--	/*==========================================================================================  
--    Calulate Capacity Purchased Revised  
--    ==========================================================================================*/
--	UPDATE RMP
--	SET RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC =
--	([BMCPYSSMPData_SubmittedSecurityCover] * BMCMPData_CapacityPurchased) / [BMCPYSSMPData_RequiredSecurityCover]

--	FROM BMCMPData MP
--	JOIN [dbo].[BMCPYSSMPData] RMP
--		ON RMP.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
--	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
----	AND RMP.[BMCPYSSMPData_SubmittedSecurityCover] < RMP.[BMCPYSSMPData_RequiredSecurityCover]


--	/*==========================================================================================  
--    Calculate Revised available capacity  
--    ==========================================================================================*/


--	UPDATE RMP
--	SET RMP.[BMCPYSSMPData_CapacityAvailableRevised] =
--	BMCMPData_CapacityPurchased - BMCPYSSMPData_PreliminaryCapacityAllocatedSC

--	FROM BMCMPData MP
--	JOIN [dbo].[BMCPYSSMPData] RMP
--		ON RMP.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
--	WHERE MP.MtStatementProcess_ID = @vBMCFinalStatementId
--	AND RMP.BMCPYSSMPData_PreliminaryCapacityAllocatedSC IS NOT NULL
--	--AND RMP.[BMCPYSSMPData_SubmittedSecurityCover] < RMP.[BMCPYSSMPData_RequiredSecurityCover]


END

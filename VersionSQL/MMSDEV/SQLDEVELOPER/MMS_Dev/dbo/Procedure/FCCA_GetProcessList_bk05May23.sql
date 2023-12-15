/****** Object:  Procedure [dbo].[FCCA_GetProcessList_bk05May23]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================    
-- Author:  Ammama Gill  
-- CREATE date: 11 Apr 2023  
-- ALTER date:   
-- Description:   
-- =================================================================================   

CREATE   PROCEDURE dbo.FCCA_GetProcessList_bk05May23 (@pFCCMasterId DECIMAL(18, 0) = NULL)
AS
BEGIN

	;
	WITH cte_CertCount
	AS
	(SELECT
			FCCD.MtFCCMaster_Id
		   ,CASE
				WHEN FCCD.MtFCCDetails_Status = 1 THEN COUNT(FCCD.MtFCCDetails_Id)
				ELSE 0
			END
			AS Blocked
		   ,CASE
				WHEN FCCD.MtFCCDetails_Status = 0 THEN COUNT(FCCD.MtFCCDetails_Id)
				ELSE 0
			END AS Available

		   ,CASE
				WHEN FCCD.MtFCCDetails_IsCancelled = 1 THEN COUNT(FCCD.MtFCCDetails_Id)
				ELSE 0
			END
			AS Cancelled

		FROM MtFCCMaster FCCM
		INNER JOIN MtFCCDetails FCCD
			ON FCCM.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
		GROUP BY FCCD.MtFCCMaster_Id
				,FCCD.MtFCCDetails_Status
				,FCCD.MtFCCDetails_IsCancelled)



	SELECT DISTINCT
		ROW_NUMBER() OVER (ORDER BY FCDG.MtGenerator_Id) AS ID
	   ,CC.MtFCCMaster_Id AS FCCMasterID
	   ,GP.MtGenerator_Name AS GeneratorName
	   ,GP.MtPartyRegisteration_Name AS PartyName
	   ,FCT.LuFirmCapacityType_Name AS FCCType
	   ,FCCM.MtFCCMaster_InitialFirmCapacity AS IFC
	   ,FCCM.MtFCCMaster_TotalCertificates AS TotalCertificates
	   ,CC.Available AS Available
	   ,CC.Blocked AS Blocked
	   ,CC.Cancelled AS Cancelled
	   ,FCCM.MtFCCMaster_IssuanceDate AS IssuanceDate
	   ,FCCM.MtFCCMaster_ExpiryDate AS ExpiryDate
	FROM vw_GeneratorParties GP
	INNER JOIN MtFCCMaster FCCM
		ON GP.MtGenerator_Id = FCCM.MtGenerator_Id
	INNER JOIN LuFirmCapacityType FCT
		ON FCCM.LuFirmCapacityType_Id = FCT.LuFirmCapacityType_Id
	INNER JOIN MtFCDGenerators FCDG
		ON FCCM.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
	INNER JOIN cte_CertCount CC
		ON FCCM.MtFCCMaster_Id = CC.MtFCCMaster_Id
	WHERE ISNULL(FCDG.MtFCDGenerators_IsDeleted, 0) = 0
	AND ISNULL(FCCM.MtFCCMaster_IsDeleted, 0) = 0
	AND CC.MtFCCMaster_Id = ISNULL(@pFCCMasterId, CC.MtFCCMaster_Id)
END

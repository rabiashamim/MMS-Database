/****** Object:  Procedure [dbo].[FCCA_GetGeneratorHistory]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Ammama Gill      
-- CREATE date: 05 June 2023      
-- ALTER date:       
-- Description:       
-- =================================================================================      
-- [FCCA_GetGeneratorHistory] 20    
CREATE PROCEDURE dbo.FCCA_GetGeneratorHistory (@pFCCAMasterId DECIMAL(18, 0))
AS
BEGIN

	SELECT DISTINCT
		MtFCCAGeneratorDetailsHistory_Id AS GeneratorDetailsId
	   ,AG.Generator_Id AS MtGenerator_Id
	   ,AG.Generator_Name AS MtGenerator_Name
	   ,FCCAGD.MtFCCAGeneratorDetails_RangeCapacity AS Capacity
	   ,FCCAGD.MtFCCAGeneratorDetails_RangeTotalCertificates AS TotalCertificates
	   ,FCCAGD.MtFCCAGeneratorDetails_FromCertificate AS MtFCCADetails_FromCertificate
	   ,FCCAGD.MtFCCAGeneratorDetails_ToCertificate AS MtFCCADetails_ToCertificate
	   ,MtFCCAGeneratorDetails_CancelledDate AS CancelledDate
	FROM MtFCCAGeneratorDetailsHistory FCCAGD
	LEFT JOIN MtFCCAGeneratorHistory FCCAGH
		ON FCCAGD.MtFCCAGenerator_Id = FCCAGH.MtFCCAGenerator_Id
	LEFT JOIN vw_ActiveGenerator AG
		ON AG.Generator_Id = FCCAGH.MtGenerator_Id
	WHERE MtFCCAMaster_Id = @pFCCAMasterId
	AND ISNULL(MtFCCAGeneratorDetails_IsCancelled, 0) = 1
	AND MtFCCAGenerator_IsDeleted = 0
	AND ISNULL(MtFCCAGeneratorDetails_Isdeleted, 0) = 0


	UNION

	SELECT
		MtFCCAGeneratorDetailsHistory_Id AS GeneratorDetailsId
	   ,G.MtGenerator_Id AS MtGenerator_Id
	   ,(SELECT TOP 1
				Generator_Name
			FROM vw_ActiveGenerator VG
			WHERE VG.Generator_Id = G.MtGenerator_Id)
		AS MtGenerator_Name
	   ,H.MtFCCAGeneratorDetails_RangeCapacity AS Capacity
	   ,H.MtFCCAGeneratorDetails_RangeTotalCertificates AS TotalCertificates
	   ,H.MtFCCAGeneratorDetails_FromCertificate AS MtFCCADetails_FromCertificate
	   ,H.MtFCCAGeneratorDetails_ToCertificate AS MtFCCADetails_ToCertificate
	   ,H.MtFCCAGeneratorDetails_CancelledDate AS CancelledDate
	FROM MtFCCAGeneratorDetailsHistory H
	JOIN MtFCCAGenerator G
		ON H.MtFCCAGenerator_Id = G.MtFCCAGenerator_Id
	WHERE G.MtFCCAMaster_Id = @pFCCAMasterId
	AND MtFCCAGenerator_IsDeleted = 0
	AND ISNULL(MtFCCAGeneratorDetails_Isdeleted, 0) = 0
	ORDER BY MtFCCAGeneratorDetails_CancelledDate DESC



END

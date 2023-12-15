/****** Object:  Procedure [dbo].[FCCA_GetProcessList_bk16June]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ================================================================================      
-- Author:  Ammama Gill    
-- CREATE date: 11 Apr 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
--[dbo].[FCCA_GetProcessList]3  
CREATE   PROCEDURE dbo.FCCA_GetProcessList_bk16June (@pFCCMasterId DECIMAL(18, 0) = NULL)
AS
BEGIN
	;
	WITH cte_CertificateCount
	AS
	(SELECT
			t.MtFCCAMaster_Id
		   ,MAX(Available) AS Available
		   ,MAX(Blocked) AS Blocked
		   ,MAX(Cancelled) AS Cancelled
		FROM (SELECT
				FCCA.MtFCCAMaster_Id
			   ,ISNULL(CASE
					WHEN FCCD.MtFCCDetails_IsCancelled = 0 AND
						FCCD.MtFCCDetails_Status = 0 THEN COUNT(FCCD.MtFCCDetails_Status)
				END, 0) AS Available

			   ,ISNULL(CASE
					WHEN FCCD.MtFCCDetails_IsCancelled = 0 AND
						FCCD.MtFCCDetails_Status = 1 THEN COUNT(FCCD.MtFCCDetails_Status)
				END, 0) AS Blocked
			   ,ISNULL(CASE
					WHEN FCCD.MtFCCDetails_IsCancelled = 1 THEN COUNT(FCCD.MtFCCDetails_IsCancelled)
				END, 0) AS Cancelled
			FROM MtFCCAGenerator FCCAG
			INNER JOIN MtFCCAMaster FCCA
				ON FCCAG.MtFCCAMaster_Id = FCCA.MtFCCAMaster_Id
			INNER JOIN MtFCCMaster FCC
				ON FCCAG.MtGenerator_Id = FCC.MtGenerator_Id
			INNER JOIN MtFCCDetails FCCD
				ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
			WHERE FCCA.MtFCCAMaster_IsDeleted = 0
			AND FCCAG.MtFCCAGenerator_IsDeleted = 0
			AND FCCD.MtFCCDetails_IsDeleted = 0
			AND (
			@pFCCMasterId IS NULL
			OR FCCA.MtFCCAMaster_Id = @pFCCMasterId
			)
			GROUP BY FCCA.MtFCCAMaster_Id
					,FCCD.MtFCCDetails_IsCancelled
					,FCCD.MtFCCDetails_Status) t
		GROUP BY MtFCCAMaster_Id)




	SELECT DISTINCT
		FCCA.MtFCCAMaster_Id AS FCCAMasterId
	   ,(SELECT
				mpr.MtPartyRegisteration_Name
			FROM MtPartyRegisteration mpr
			WHERE mpr.MtPartyRegisteration_Id = FCCA.MtPartyRegisteration_Id)
		AS PartyName
	   ,TG.TotalGenerators AS TotalGenerators
	   ,TC.TotalCertificates AS TotalCertificates
	   ,CC.Available AS Available
	   ,CC.Blocked AS Blocked
	   ,CC.Cancelled AS Cancelled
	   ,FCCA.MtFCCAMaster_ApprovalStatus AS ApprovalStatus
	   ,FCCA.MtFCCAMaster_Status AS Status
	   ,FCCA.MtFCCAMaster_CreatedOn AS CreatedDate
	   ,FCCA.MtFCCAMaster_ModifiedOn AS ExecutionDate
	FROM MtFCCAMaster FCCA
	--INNER JOIN vw_GeneratorParties GP
	--	ON FCCA.MtPartyRegisteration_Id = GP.MtPartyRegisteration_Id
	LEFT JOIN MtFCCAGenerator FCCAG
		ON FCCA.MtFCCAMaster_Id = FCCAG.MtFCCAMaster_Id
	--AND FCCAG.MtGenerator_Id = GP.MtGenerator_Id
	LEFT JOIN cte_CertificateCount CC
		ON FCCA.MtFCCAMaster_Id = CC.MtFCCAMaster_Id
	LEFT JOIN (SELECT
			FCCAG.MtFCCAMaster_Id
		   ,COUNT(FCCAG.MtGenerator_Id) AS TotalGenerators
		FROM MtFCCAGenerator FCCAG
		WHERE FCCAG.MtFCCAGenerator_IsDeleted = 0
		GROUP BY FCCAG.MtFCCAMaster_Id) AS TG
		ON FCCA.MtFCCAMaster_Id = TG.MtFCCAMaster_Id
	LEFT JOIN (SELECT
			FCCAG.MtFCCAMaster_Id
		   ,COUNT(FCCD.MtFCCDetails_CertificateId) AS TotalCertificates

		FROM MtFCCAGenerator FCCAG
		INNER JOIN MtFCCAMaster FCCA
			ON FCCAG.MtFCCAMaster_Id = FCCA.MtFCCAMaster_Id
		INNER JOIN MtFCCMaster FCC
			ON FCCAG.MtGenerator_Id = FCC.MtGenerator_Id
		INNER JOIN MtFCCDetails FCCD
			ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
		WHERE FCCA.MtFCCAMaster_IsDeleted = 0
		AND FCCAG.MtFCCAGenerator_IsDeleted = 0
		AND FCCD.MtFCCDetails_IsDeleted = 0
		GROUP BY FCCAG.MtFCCAMaster_Id) AS TC
		ON FCCA.MtFCCAMaster_Id = TC.MtFCCAMaster_Id
	WHERE ISNULL(FCCA.MtFCCAMaster_IsDeleted, 0) = 0
	AND ISNULL(FCCAG.MtFCCAGenerator_IsDeleted, 0) = 0
	--AND FCCA.MtFCCAMaster_Id=@pFCCMasterId  
	AND (
	@pFCCMasterId IS NULL
	OR FCCA.MtFCCAMaster_Id = @pFCCMasterId
	)

	--Ammama: Can be changed to this subquery if req  
	-- SELECT  
	-- FCCAG.MtFCCAMaster_Id  
	--   ,SUM(FCC.MtFCCMaster_TotalCertificates) AS TotalCertificates  
	--FROM MtFCCAGenerator FCCAG  
	--INNER JOIN MtFCCAMaster FCCA  
	-- ON FCCAG.MtFCCAMaster_Id = FCCA.MtFCCAMaster_Id  
	--INNER JOIN MtFCCMaster FCC  
	-- ON FCCAG.MtFCCMaster_Id = FCC.MtFCCMaster_Id  
	--WHERE FCCA.MtFCCAMaster_IsDeleted = 0  
	--AND FCCAG.MtFCCAGenerator_IsDeleted = 0  
	--AND FCC.MtFCCMaster_IsDeleted = 0  
	--GROUP BY FCCAG.MtFCCAMaster_Id  

	/*********************************************************************  
	Check Modification ReAssign flow  
	*********************************************************************/

	IF (@pFCCMasterId IS NOT NULL)
	BEGIN


		DECLARE @KEShare DECIMAL(25, 13);
		DECLARE @IsModifyReassign BIT;

		SELECT TOP 1
			@KEShare = rrv.RuReferenceValue_Value
		FROM SrReferenceType srt
		INNER JOIN RuReferenceValue rrv
			ON srt.SrReferenceType_Id = rrv.SrReferenceType_Id
		WHERE srt.SrReferenceType_Name = 'KE Share'
		AND ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
		AND ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0
		ORDER BY rrv.RuReferenceValue_EffectiveTo DESC;

		SELECT
			@IsModifyReassign = COUNT(1)
		FROM MtFCCAGeneratorHistory
		WHERE MtFCCAMaster_Id = @pFCCMasterId;

		SELECT
			CASE
				WHEN
					@IsModifyReassign > 0 AND
					MtFCCAMaster_ApprovalStatus <> 'Approved' THEN 1
				ELSE 0
			END AS IsModifyReassign
		   ,@KEShare AS KEShare

		FROM MtFCCAMaster
		WHERE MtFCCAMaster_Id = @pFCCMasterId


	END
END

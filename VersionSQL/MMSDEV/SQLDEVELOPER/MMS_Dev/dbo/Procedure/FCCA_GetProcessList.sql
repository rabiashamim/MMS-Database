/****** Object:  Procedure [dbo].[FCCA_GetProcessList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.FCCA_GetProcessList (@pFCCMasterId DECIMAL(18, 0) = NULL, @pFCCAMasterId DECIMAL(18, 0) = NULL)
AS
BEGIN




	DROP TABLE IF EXISTS #FCCGenCount

	SELECT
		FCCA.MtFCCAMaster_Id
	   ,FCCAG.MtGenerator_Id
	   ,(SELECT
				COUNT(MtFCCDetails_CertificateId)
			FROM MtFCCMaster FCC
			INNER JOIN MtFCCDetails FCCD
				ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
			WHERE FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			AND FCC.MtFCCMaster_IsDeleted = 0
			AND FCCD.MtFCCDetails_IsDeleted = 0)
		AS GenTotal
	   ,(SELECT
				COUNT(MtFCCDetails_CertificateId)
			FROM MtFCCMaster FCC
			INNER JOIN MtFCCDetails FCCD
				ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
			WHERE FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			AND FCC.MtFCCMaster_IsDeleted = 0
			AND FCCD.MtFCCDetails_IsDeleted = 0
			AND MtFCCDetails_IsCancelled = 1)
		AS GenCancelled

	   ,(SELECT
				COUNT(MtFCCDetails_CertificateId)
			FROM MtFCCMaster FCC
			INNER JOIN MtFCCDetails FCCD
				ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
			WHERE FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			AND FCC.MtFCCMaster_IsDeleted = 0
			AND FCCD.MtFCCDetails_IsDeleted = 0
			AND MtFCCDetails_Status = 1
			AND MtFCCDetails_IsCancelled = 0)
		AS GenBlocked
	   ,(SELECT
				COUNT(MtFCCDetails_CertificateId)
			FROM MtFCCMaster FCC
			INNER JOIN MtFCCDetails FCCD
				ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
			WHERE FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			AND FCC.MtFCCMaster_IsDeleted = 0
			AND FCCD.MtFCCDetails_IsDeleted = 0
			AND MtFCCDetails_Status = 0
			AND MtFCCDetails_IsCancelled = 0)
		AS GenAvailable
	   ,(SELECT
				(SELECT
						COUNT(MtFCCDetails_CertificateId)
					FROM MtFCCMaster FCC
					INNER JOIN MtFCCDetails FCCD
						ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
					WHERE FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
					AND FCC.MtFCCMaster_IsDeleted = 0
					AND FCCD.MtFCCDetails_IsDeleted = 0
					AND MtFCCDetails_ToBeCanceledFlag = 1)
				- (SELECT
						COUNT(MtFCCDetails_CertificateId)
					FROM MtFCCMaster FCC
					INNER JOIN MtFCCDetails FCCD
						ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
					WHERE FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
					AND FCC.MtFCCMaster_IsDeleted = 0
					AND FCCD.MtFCCDetails_IsDeleted = 0
					AND MtFCCDetails_IsCancelled = 1))
		AS GenToBeCancelled INTO #FCCGenCount
	FROM MtFCCAGenerator FCCAG
	INNER JOIN MtFCCAMaster FCCA
		ON FCCA.MtFCCAMaster_Id = FCCAG.MtFCCAMaster_Id
	INNER JOIN MtPartyRegisteration PR
		ON PR.MtPartyRegisteration_Id = FCCA.MtPartyRegisteration_Id
	WHERE MtFCCAMaster_IsDeleted = 0
	AND MtFCCAGenerator_IsDeleted = 0
	AND ISNULL(isDeleted, 0) = 0

	;
	WITH cte_TotalGens
	AS
	(SELECT
			MtFCCAMaster_Id
		   ,COUNT(MtGenerator_Id) AS TotalGens
		FROM MtFCCAGenerator
		GROUP BY MtFCCAMaster_Id)


	SELECT

		FCCA.MtFCCAMaster_Id AS FCCAMasterId
	   ,FCCA.MtPartyRegisteration_Id AS PartyId
	   ,PR.MtPartyRegisteration_Name AS PartyName
	   ,TG.TotalGens AS TotalGenerators
	   ,FCCA.MtFCCAMaster_ApprovalStatus AS ApprovalStatus
	   ,FCCA.MtFCCAMaster_Status AS Status
	   ,FCCA.MtFCCAMaster_CreatedOn AS CreatedDate
	   ,FCCA.MtFCCAMaster_ModifiedOn AS ExecutionDate
	   ,SUM(GC.GenAvailable) AS Available
	   ,SUM(GC.GenBlocked) AS Blocked
	   ,SUM(GC.GenCancelled) AS Cancelled
	   ,SUM(GC.GenTotal) AS TotalCertificates
	   ,CASE
			WHEN SUM(GC.GenToBeCancelled) > 0 THEN SUM(GC.GenToBeCancelled)
			ELSE 0
		END AS ToBeCancelled
	FROM MtFCCAMaster FCCA

	LEFT JOIN #FCCGenCount GC
		ON GC.MtFCCAMaster_Id = FCCA.MtFCCAMaster_Id
	INNER JOIN MtPartyRegisteration PR
		ON PR.MtPartyRegisteration_Id = FCCA.MtPartyRegisteration_Id
	LEFT JOIN cte_TotalGens TG
		ON TG.MtFCCAMaster_Id = FCCA.MtFCCAMaster_Id
	WHERE @pFCCAMasterId IS NULL
	OR FCCA.MtFCCAMaster_Id = @pFCCAMasterId
	GROUP BY FCCA.MtFCCAMaster_Id
			,FCCA.MtPartyRegisteration_Id
			,PR.MtPartyRegisteration_Name
			,TG.TotalGens
			,FCCA.MtFCCAMaster_ApprovalStatus
			,FCCA.MtFCCAMaster_Status
			,FCCA.MtFCCAMaster_CreatedOn
			,FCCA.MtFCCAMaster_ModifiedOn



	--DROP TABLE IF EXISTS #FCCAGeneratorCount  
	--SELECT  
	-- M.MtFCCAMaster_Id  
	--   ,M.MtPartyRegisteration_Id  
	--   ,MP.MtPartyRegisteration_Name  
	--   ,COUNT(G.MtGenerator_Id) AS GeneratorCount  
	--   ,M.MtFCCAMaster_ApprovalStatus  
	--   ,M.MtFCCAMaster_Status  
	--   ,M.MtFCCAMaster_CreatedOn  
	--   ,M.MtFCCAMaster_ModifiedOn INTO #FCCAGeneratorCount  
	--FROM MtFCCAMaster M  
	--LEFT JOIN MtFCCAGenerator G  
	-- ON M.MtFCCAMaster_Id = G.MtFCCAMaster_Id  
	--JOIN MtPartyRegisteration MP  
	-- ON MP.MtPartyRegisteration_Id = M.MtPartyRegisteration_Id  
	--WHERE M.MtFCCAMaster_IsDeleted = 0  
	--AND ISNULL(G.MtFCCAGenerator_IsDeleted, 0) = 0  
	--AND MP.isDeleted = 0  
	--GROUP BY M.MtFCCAMaster_Id  
	--  ,M.MtPartyRegisteration_Id  
	--  ,MP.MtPartyRegisteration_Name  
	--  ,M.MtFCCAMaster_ApprovalStatus  
	--  ,M.MtFCCAMaster_Status  
	--  ,M.MtFCCAMaster_CreatedOn  
	--  ,M.MtFCCAMaster_ModifiedOn  


	--SELECT  
	-- GC.MtFCCAMaster_Id AS FCCAMasterId  
	--   ,GC.MtPartyRegisteration_Id AS PartyId  
	--   ,GC.MtPartyRegisteration_Name AS PartyName  
	--   ,GC.GeneratorCount AS TotalGenerators  
	--   ,(SELECT  
	--   COUNT(1)  
	--  FROM MtFCCDetails  
	--  WHERE MtFCCDetails_OwnerPartyId = GC.MtPartyRegisteration_Id  
	--  AND MtFCCDetails_IsDeleted = 0  
	--  AND MtFCCDetails_IsCancelled = 0)  
	-- AS TotalCertificates  

	--   ,(SELECT  
	--   COUNT(1)  
	--  FROM MtFCCDetails  
	--  WHERE MtFCCDetails_OwnerPartyId = GC.MtPartyRegisteration_Id  
	--  AND MtFCCDetails_IsDeleted = 0  
	--  AND MtFCCDetails_IsCancelled = 0  
	--  AND MtFCCDetails_Status = 0)  
	-- AS Available  
	--   ,(SELECT  
	--   COUNT(1)  
	--  FROM MtFCCDetails  
	--  WHERE MtFCCDetails_OwnerPartyId = GC.MtPartyRegisteration_Id  
	--  AND MtFCCDetails_IsDeleted = 0  
	--  AND MtFCCDetails_IsCancelled = 0  
	--  AND MtFCCDetails_Status = 1)  
	-- AS Blocked  
	--   ,(SELECT  
	--   COUNT(1)  
	--  FROM MtFCCDetails  
	--  WHERE MtFCCDetails_OwnerPartyId = GC.MtPartyRegisteration_Id  
	--  AND MtFCCDetails_IsDeleted = 0  
	--  AND MtFCCDetails_IsCancelled = 1)  
	-- AS Cancelled  
	--   ,MtFCCAMaster_ApprovalStatus AS ApprovalStatus  
	--   ,MtFCCAMaster_Status AS Status  
	--   ,MtFCCAMaster_CreatedOn AS CreatedDate  
	--   ,MtFCCAMaster_ModifiedOn AS ExecutionDate  
	--FROM #FCCAGeneratorCount GC  
	--WHERE @pFCCAMasterId IS NULL  
	--OR GC.MtFCCAMaster_Id = @pFCCAMasterId  



	/*********************************************************************        
          Check Modification ReAssign flow        
          *********************************************************************/

	IF (@pFCCAMasterId IS NOT NULL)
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
		WHERE MtFCCAMaster_Id = @pFCCAMasterId;

		SELECT
			CASE
				WHEN
					@IsModifyReassign > 0 AND
					MtFCCAMaster_ApprovalStatus <> 'Approved' THEN 1
				ELSE 0
			END AS IsModifyReassign
		   ,@KEShare AS KEShare

		FROM MtFCCAMaster
		WHERE MtFCCAMaster_Id = @pFCCAMasterId


	END
END

/****** Object:  Procedure [dbo].[FCCA_GetGeneratorsDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- FCCA_GetGeneratorsDetails 31,1                  
--select * from MtFCCAMaster                  
CREATE PROCEDURE dbo.FCCA_GetGeneratorsDetails @pMtFCCAMaster_Id DECIMAL(18, 0),
@pUserId INT
AS
BEGIN


	DECLARE @Status AS VARCHAR(15)
	SELECT
		@Status = MtFCCAMaster_Status
	FROM MtFCCAMaster
	WHERE MtFCCAMaster_Id = @pMtFCCAMaster_Id;

	IF @Status IN ('New', 'Reverted', 'Modified', 'Interrupted')--(@Status='New' or @Status='Reverted' or @Status='Modified' or 'Interrupted')                    
	BEGIN
		;
		WITH cte_LatestFCC
		AS
		(SELECT
				ROW_NUMBER() OVER (PARTITION BY FCC.MtGenerator_Id ORDER BY FCC.MtFCCMaster_Id DESC) AS row_number
			   ,FCC.MtGenerator_Id
			   ,GP.MtGenerator_Name
			   ,FCC.MtFCCMaster_Id
			   ,ROUND(FCDG.MtFCDGenerators_InitialFirmCapacity, 1) AS MtFCDGenerators_InitialFirmCapacity
			FROM MtFCCMaster FCC
			INNER JOIN MtFCDGenerators FCDG
				ON FCC.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
				AND FCC.MtGenerator_Id = FCDG.MtGenerator_Id
			INNER JOIN vw_GeneratorParties GP
				ON GP.MtPartyRegisteration_Id = FCC.MtPartyRegistration_Id
				AND GP.MtGenerator_Id = FCC.MtGenerator_Id
			INNER JOIN MtFCCAMaster fcca
				ON fcca.MtPartyRegisteration_Id = FCC.MtPartyRegistration_Id

			WHERE fcca.MtFCCAMaster_Id = @pMtFCCAMaster_Id
			AND FCC.MtFCCMaster_TotalCertificates IS NOT NULL
			AND FCDG.MtFCDGenerators_InitialFirmCapacity IS NOT NULL
			AND FCC.MtFCCMaster_IsDeleted = 0
			AND FCDG.MtFCDGenerators_IsDeleted = 0
			AND fcca.MtFCCAMaster_IsDeleted = 0
			AND FCC.MtFCCMaster_ApprovalCode = 'Approved')

		SELECT
			@pMtFCCAMaster_Id
		   ,cte.MtFCCMaster_Id
		   ,cte.MtGenerator_Id
		   ,cte.MtGenerator_Name AS MtGenerator_Name
		   ,ROUND(cte.MtFCDGenerators_InitialFirmCapacity, 1) AS MtFCCMaster_InitialFirmCapacity
		   ,t.MtFCCMaster_Start AS MtFCCMaster_Start
		   ,t.MtFCCMaster_End
		   ,t.MtFCCMaster_FccCount
		   ,ToBeCancelecount
		   ,ToBeCanceledate
		   ,CASE
				WHEN ToBeCancelecount > 0 THEN 1
				ELSE 0
			END AS CotnractsToBeRevised
		FROM cte_LatestFCC cte

		INNER JOIN (SELECT
				MtGenerator_Id
			   ,MIN(MtFCCDetails_CertificateId) AS MtFCCMaster_Start
			   ,MAX(MtFCCDetails_CertificateId) AS MtFCCMaster_End
			   ,COUNT(1) AS MtFCCMaster_FccCount
			   ,SUM(MtFCCDetails_ToBeCanceledFlag) ToBeCancelecount
			   ,MAX(MtFCCDetails_ToBeCanceledDate) ToBeCanceledate
			FROM MtFCCDetails fccD
			INNER JOIN MtFCCMaster fccM
				ON fccM.MtFCCMaster_Id = fccD.MtFCCMaster_Id
			WHERE ISNULL(MtFCCDetails_IsDeleted, 0) = 0
			AND ISNULL(MtFCCMaster_IsDeleted, 0) = 0
			AND ISNULL(MtFCCDetails_IsCancelled, 0) = 0
			GROUP BY fccM.MtGenerator_Id) AS t
			ON t.MtGenerator_Id = cte.MtGenerator_Id
		--AND t.MtFCCMaster_Id = cte.MtFCCMaster_Id            

		WHERE row_number = 1
		ORDER BY MtGenerator_Id ASC

	END

	ELSE
	BEGIN

		DROP TABLE IF EXISTS #GeneratorView

		;
		WITH cte_LatestFCC
		AS
		(SELECT
			DISTINCT
				FCCAG.MtFCCAMaster_Id
			   ,FCCAG.MtGenerator_Id AS MtGenerator_Id
			   ,FCCAG.MtFCCAGenerator_Id
			   ,(SELECT
						MtGenerator_Name
					FROM MtGenerator G
					WHERE G.MtGenerator_Id = FCCAG.MtGenerator_Id)
				AS MtGenerator_Name
				--,FCCAG.MtFCCMaster_Id
			   ,(SELECT TOP 1
						MtFCCMaster_Id
					FROM MtFCCMaster fccm
					WHERE fccm.MtGenerator_Id = FCC.MtGenerator_Id
					ORDER BY fccm.MtFCCMaster_Id DESC)
				AS MtFCCMaster_Id
			   ,MtFCCAGenerator_KEShare KEShare
			   ,FCCAG.MtFCCAGenerator_WithoutKE WithoutKE
			FROM MtFCCAMaster FCCA
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCA.MtFCCAMaster_Id = FCCAG.MtFCCAMaster_Id
			INNER JOIN MtFCCMaster FCC
				ON FCC.MtGenerator_Id = FCCAG.MtGenerator_Id
			INNER JOIN MtFCDGenerators FCDG
				ON FCDG.MtGenerator_Id = FCCAG.MtGenerator_Id
			INNER JOIN vw_GeneratorParties GP
				ON GP.MtPartyRegisteration_Id = FCCA.MtPartyRegisteration_Id
				AND GP.MtGenerator_Id = FCC.MtGenerator_Id
			WHERE FCCA.MtFCCAMaster_Id = @pMtFCCAMaster_Id
			AND ISNULL(MtFCCAGenerator_IsDeleted, 0) = 0
			AND ISNULL(MtFCCAMaster_IsDeleted, 0) = 0
			AND ISNULL(MtFCCMaster_IsDeleted, 0) = 0
			AND ISNULL(MtFCDGenerators_IsDeleted, 0) = 0
		--GROUP BY FCCAG.MtGenerator_Id        
		)

		SELECT
			LFCC.MtGenerator_Name
		   ,LFCC.MtGenerator_Id
		   ,ROUND(FCDG.MtFCDGenerators_InitialFirmCapacity, 1) AS MtFCCMaster_InitialFirmCapacity
		   ,(SELECT
					COUNT(1)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0)
			AS MtFCCMaster_FccCount
			,(SELECT
					COUNT(1)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0
				and MtFCCDetails_IsCancelled=1)
			AS MtFCCMaster_FccCancelledCount
			,(SELECT
					COUNT(1)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0
				and MtFCCDetails_IsCancelled=0
				and MtFCCDetails_Status=1)
			AS MtFCCMaster_FccBlockedCount
			,(SELECT
					COUNT(1)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0
				and MtFCCDetails_IsCancelled=0
				and MtFCCDetails_Status=0)
			AS MtFCCMaster_FccAvailableCount
		   ,(SELECT
					MIN(MtFCCDetails_CertificateId)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0)
			AS MtFCCMaster_Start
		   ,(SELECT
					MAX(MtFCCDetails_CertificateId)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0)
			AS MtFCCMaster_End
		   ,ROUND(KEShare, 1) AS MtFCCAGenerator_KEShare
		   ,ROUND(WithoutKE, 1) AS MtFCCAGenerator_WithoutKE
		   ,(SELECT
					(SELECT
							COUNT(MtFCCDetails_ToBeCanceledFlag)
						FROM MtFCCDetails FCCD
						INNER JOIN MtFCCMaster FCCL
							ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
						WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
						AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
						AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0
						AND ISNULL(MtFCCDetails_ToBeCanceledFlag, 0) = 1)

					- (SELECT
							COUNT(MtFCCDetails_IsCancelled)
						FROM MtFCCDetails FCCD
						INNER JOIN MtFCCMaster FCCL
							ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
						WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
						AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
						AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0
						AND ISNULL(MtFCCDetails_IsCancelled, 0) = 1))
			AS ToBeCancelecount
		   ,(SELECT
					MAX(MtFCCDetails_ToBeCanceledDate)
				FROM MtFCCDetails FCCD
				INNER JOIN MtFCCMaster FCCL
					ON FCCD.MtFCCMaster_Id = FCCL.MtFCCMaster_Id
				WHERE FCCL.MtGenerator_Id = LFCC.MtGenerator_Id
				AND ISNULL(FCCD.MtFCCDetails_IsDeleted, 0) = 0
				AND ISNULL(FCCL.MtFCCMaster_IsDeleted, 0) = 0)
			AS ToBeCanceledate INTO #GeneratorView
		FROM cte_LatestFCC LFCC
		INNER JOIN MtFCCMaster FCC
			ON LFCC.MtFCCMaster_Id = FCC.MtFCCMaster_Id
		INNER JOIN MtFCDGenerators FCDG
			ON FCC.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
				AND FCC.MtGenerator_Id = FCDG.MtGenerator_Id

		WHERE ISNULL(MtFCCMaster_IsDeleted, 0) = 0
		AND ISNULL(MtFCDGenerators_IsDeleted, 0) = 0

		SELECT
			*
		   ,CASE
				WHEN ToBeCancelecount > 0 THEN 1
				ELSE 0
			END AS CotnractsToBeRevised
		FROM #GeneratorView





	END
END

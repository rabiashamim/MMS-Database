/****** Object:  Procedure [dbo].[FCCA_Execution_bk2905]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ================================================================================    
-- Author:  Ammama Gill  
-- CREATE date: 04 May 2023  
-- ALTER date:   
-- Description:   
-- =================================================================================   
--[FCCA_Execution] 17,1
CREATE PROCEDURE dbo.FCCA_Execution_bk2905 (@pFCCAMasterId DECIMAL(18, 0), @pUserId INT)
AS
BEGIN

	BEGIN TRY


		/*****************************************************************************************  
	    Check if any FCC exists against the said party
	    *****************************************************************************************/
		DECLARE @vFCCGeneratorsCount INT = 0
			   ,@vPartyName VARCHAR(MAX) = '';
		SELECT
			@vFCCGeneratorsCount = COUNT(DISTINCT
			GP.MtGenerator_Id)
		FROM vw_GeneratorParties GP
		INNER JOIN MtFCCMaster FCC
			ON GP.MtGenerator_Id = FCC.MtGenerator_Id
		WHERE GP.MtPartyRegisteration_Id = (SELECT
				FCCA.MtPartyRegisteration_Id
			FROM MtFCCAMaster FCCA
			WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)
		AND ISNULL(FCC.MtFCCMaster_IsDeleted, 0) = 0
		AND FCC.MtFCCMaster_ApprovalCode = 'Approved'

		IF @vFCCGeneratorsCount = 0
		BEGIN
			SELECT
				@vPartyName = GP.MtPartyRegisteration_Name
			FROM vw_GeneratorParties GP
			WHERE GP.MtPartyRegisteration_Id = (SELECT
					FCCA.MtPartyRegisteration_Id
				FROM MtFCCAMaster FCCA
				WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)

			RAISERROR ('No FCC exists against the generators of party %s', 16, -1, @vPartyName);
			RETURN;
		END


		/*****************************************************************************************  
	    Get KE Share 
	    *****************************************************************************************/
		DECLARE @KEShare DECIMAL(25, 13);

		IF EXISTS (SELECT TOP 1
					1
				FROM MtFCCAMaster mf
				WHERE mf.MtFCCAMaster_Id = @pFCCAMasterId)
		BEGIN


			SELECT TOP 1
				@KEShare = rrv.RuReferenceValue_Value
			FROM SrReferenceType srt
			INNER JOIN RuReferenceValue rrv
				ON srt.SrReferenceType_Id = rrv.SrReferenceType_Id
			WHERE srt.SrReferenceType_Name = 'KE Share'
			AND ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
			AND ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0
			ORDER BY rrv.RuReferenceValue_EffectiveTo DESC;

			IF @KEShare = NULL
			BEGIN
				RAISERROR ('KE Share value is missing. FCCA cannot be executed.', 16, -1);
				RETURN;
			END


			UPDATE FCCA
			SET MtFCCAMaster_KEShare = @KEShare
			   ,MtFCCAMaster_ModifiedOn = GETDATE()
			   ,MtFCCAMaster_ModifiedBy = @pUserId
			   ,MtFCCAMaster_Status = 'Inprocess'
			FROM MtFCCAMaster FCCA
			WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId
		END


		/*****************************************************************************************  
		Insert INTO FCCAGenerators  
		*****************************************************************************************/
		IF NOT EXISTS (SELECT TOP 1
					1
				FROM MtFCCAGenerator mf
				WHERE mf.MtFCCAMaster_Id = @pFCCAMasterId)
		BEGIN
			;
			WITH cte_LatestFCC
			AS
			(SELECT
					ROW_NUMBER() OVER (PARTITION BY FCC.MtGenerator_Id ORDER BY FCC.MtFCCMaster_Id DESC) AS row_number
				   ,FCC.MtGenerator_Id
				   ,FCC.MtFCCMaster_Id
				   ,FCDG.MtFCDGenerators_InitialFirmCapacity
				FROM MtFCCMaster FCC
				INNER JOIN MtFCDGenerators FCDG
					ON FCC.MtFCDMaster_Id = FCDG.MtFCDMaster_Id
					AND FCC.MtGenerator_Id = FCDG.MtGenerator_Id
				WHERE FCC.MtFCCMaster_TotalCertificates IS NOT NULL
				AND FCDG.MtFCDGenerators_InitialFirmCapacity IS NOT NULL
				AND FCC.MtFCCMaster_IsDeleted = 0
				AND FCDG.MtFCDGenerators_IsDeleted = 0
				AND FCC.MtFCCMaster_ApprovalCode = 'Approved')


			INSERT INTO MtFCCAGenerator (MtFCCAMaster_Id, MtFCCMaster_Id, MtGenerator_Id, MtFCCAGenerator_IFC, MtFCCAGenerator_CreatedBy, MtFCCAGenerator_CreatedOn)
				SELECT
					@pFCCAMasterId
				   ,MtFCCMaster_Id
				   ,MtGenerator_Id
				   ,MtFCDGenerators_InitialFirmCapacity
				   ,@pUserId
				   ,GETDATE()
				FROM cte_LatestFCC
				WHERE row_number = 1


			/*****************************************************************************************  
	Update FCCA Generators - calculate KE Share and the leftover Capacity for DISCOs
	*****************************************************************************************/
			DECLARE @TotalCapacity DECIMAL(25, 13);
			SELECT
				@TotalCapacity = SUM(FCCAG.MtFCCAGenerator_IFC)
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			AND ISNULL(MtFCCAGenerator_IsDeleted, 0) = 0;

			IF @TotalCapacity < @KEShare
			BEGIN
				--- Rollback existing process.
				EXEC FCCA_Rollback @pFCCAMasterId
								  ,@pUserId

				--- Update execution status to 'Interrupted'
				UPDATE FCCA
				SET MtFCCAMaster_ModifiedOn = GETDATE()
				   ,MtFCCAMaster_ModifiedBy = @pUserId
				   ,MtFCCAMaster_Status = 'Interrupted'
				FROM MtFCCAMaster FCCA
				WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

				--- Raise error.

				RAISERROR ('Total Capacity of system cannot be less than KE Share.', 16, -1);
				RETURN;

			END

			UPDATE FCCAG
			SET MtFCCAGenerator_KEShare = (FCCAG.MtFCCAGenerator_IFC / @TotalCapacity) * @KEShare
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId;

			UPDATE FCCAG
			SET FCCAG.MtFCCAGenerator_WithoutKE = FCCAG.MtFCCAGenerator_IFC - FCCAG.MtFCCAGenerator_KEShare
			FROM MtFCCAGenerator FCCAG
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId


			IF NOT EXISTS (SELECT
					TOP 1
						1
					FROM MtContractRegistration CR
					WHERE CR.MtContractRegistration_SellerId = (SELECT
							FCCA.MtPartyRegisteration_Id
						FROM MtFCCAMaster FCCA
						WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)
					AND CR.MtContractRegistration_Status = 'CATV'
					AND ISNULL(CR.MtContractRegistration_IsDeleted, 0) = 0)
			BEGIN

				--- Rollback existing process.

				EXEC FCCA_Rollback @pFCCAMasterId
								  ,@pUserId;
				--- Update execution status to 'Interrupted'
				UPDATE FCCA
				SET MtFCCAMaster_ModifiedOn = GETDATE()
				   ,MtFCCAMaster_ModifiedBy = @pUserId
				   ,MtFCCAMaster_Status = 'Interrupted'
				FROM MtFCCAMaster FCCA
				WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId

				--- Raise error.

				RAISERROR ('No active contracts for this MP exist.', 16, -1);
				RETURN;

			END

			/*****************************************************************************************  
			Insert INTO FCCADetails  
			*****************************************************************************************/


			INSERT INTO MtFCCADetails (MtPartyRegistration_BuyerId, MtContractRegistration_Id, MtFCCAGenerator_Id, MtFCCADetails_AllocationFactor, MtFCCADetails_CreatedBy, MtFCCADetails_CreatedOn)
				SELECT
					CR.MtContractRegistration_BuyerId
				   ,CR.MtContractRegistration_Id
				   ,FCCAG.MtFCCAGenerator_Id
				   ,LAF.LuAllocationFactors_Factor
				   ,@pUserId
				   ,GETDATE()
				FROM MtContractRegistration CR
				INNER JOIN MtPartyRegisteration PR
					ON CR.MtContractRegistration_BuyerId = PR.MtPartyRegisteration_Id
				INNER JOIN LuAllocationFactors LAF
					ON PR.MtPartyRegisteration_Id = LAF.MtPartyRegisteration_Id
				INNER JOIN vw_GeneratorParties GP
					ON GP.MtPartyRegisteration_Id = CR.MtContractRegistration_SellerId
				INNER JOIN MtFCCAGenerator FCCAG
					ON GP.MtGenerator_Id = FCCAG.MtGenerator_Id
				WHERE CR.MtContractRegistration_SellerId = (SELECT
						FCCA.MtPartyRegisteration_Id
					FROM MtFCCAMaster FCCA
					WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId)
				AND ISNULL(PR.isDeleted, 0) = 0
				AND ISNULL(CR.MtContractRegistration_IsDeleted, 0) = 0
				AND FCCAG.MtFCCAGenerator_IsDeleted = 0
				AND CR.MtContractRegistration_Status = 'CATV';


			/*****************************************************************************************  
			Prorate associated capacity to calculate individual disco capacity share / generator  
			*****************************************************************************************/


			DECLARE @vKEMPId INT;
			SET @vKEMPId = 12;

			UPDATE FCCAD
			SET MtFCCADetails_AssociatedCapacity =
			CASE
				WHEN FCCAD.MtPartyRegistration_BuyerId <> @vKEMPId THEN FCCAG.MtFCCAGenerator_WithoutKE * (FCCAD.MtFCCADetails_AllocationFactor / 100)
				ELSE FCCAG.MtFCCAGenerator_KEShare
			END
			FROM MtFCCADetails FCCAD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCAG.MtFCCAGenerator_Id = FCCAD.MtFCCAGenerator_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			AND FCCAG.MtFCCAGenerator_IsDeleted = 0
			AND FCCAD.MtFCCADetails_IsDeleted = 0


			/*****************************************************************************************  
			Assign KE Range first. 
			*****************************************************************************************/

			DROP TABLE IF EXISTS #CertificateDetails
			SELECT
				ROW_NUMBER() OVER (PARTITION BY FCCAG.MtFCCMaster_Id ORDER BY FCCD.MtFCCDetails_CertificateId ASC) AS row_number
			   ,FCCAG.MtFCCMaster_Id
			   ,FCCD.MtFCCDetails_Id
			   ,FCCD.MtFCCDetails_CertificateId INTO #CertificateDetails
			FROM MtFCCDetails FCCD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCD.MtFCCMaster_Id = FCCAG.MtFCCMaster_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId

			;
			WITH cte_CertificateRange
			AS
			(SELECT
					FCCAG.MtFCCAGenerator_Id
				   ,MIN(cd.MtFCCDetails_CertificateId) AS FromCertificate
				   ,MAX(cd.MtFCCDetails_CertificateId) AS ToCertificate
				FROM #CertificateDetails cd
				INNER JOIN MtFCCAGenerator FCCAG
					ON cd.MtFCCMaster_Id = FCCAG.MtFCCMaster_Id
				WHERE row_number IN (1, ROUND(FCCAG.MtFCCAGenerator_KEShare, 1) * 10)
				AND FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
				GROUP BY FCCAG.MtFCCAGenerator_Id)


			UPDATE FCCAD
			SET FCCAD.MtFCCADetails_FromCertificate = CR.FromCertificate
			   ,FCCAD.MtFCCADetails_ToCertificate = CR.ToCertificate
			FROM MtFCCADetails FCCAD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCAD.MtFCCAGenerator_Id = FCCAG.MtFCCAGenerator_Id
			INNER JOIN cte_CertificateRange CR
				ON FCCAD.MtFCCAGenerator_Id = CR.MtFCCAGenerator_Id
			WHERE FCCAD.MtPartyRegistration_BuyerId = @vKEMPId



			/*****************************************************************************************  
			block ids assigned to KE 
			*****************************************************************************************/

			UPDATE FCCD
			SET MtFCCDetails_Status = 1
			FROM #CertificateDetails cd
			INNER JOIN MtFCCAGenerator FCCAG
				ON cd.MtFCCMaster_Id = FCCAG.MtFCCMaster_Id
			INNER JOIN MtFCCDetails FCCD
				ON cd.MtFCCDetails_Id = FCCD.MtFCCDetails_Id
			WHERE cd.row_number BETWEEN 1 AND ROUND(FCCAG.MtFCCAGenerator_KEShare, 1) * 10
			AND FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			/*****************************************************************************************  
			Get the remaining Certificates and assign range to the rest of the Buyer MPs
			*****************************************************************************************/

			DROP TABLE IF EXISTS #CertificateDetailsWithoutKE
			SELECT
				ROW_NUMBER() OVER (PARTITION BY FCCAG.MtFCCMaster_Id ORDER BY FCCD.MtFCCDetails_CertificateId ASC) AS row_number
			   ,FCCAG.MtFCCMaster_Id
			   ,FCCD.MtFCCDetails_Id
			   ,FCCD.MtFCCDetails_CertificateId INTO #CertificateDetailsWithoutKE
			FROM MtFCCDetails FCCD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCD.MtFCCMaster_Id = FCCAG.MtFCCMaster_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
			AND FCCD.MtFCCDetails_Status = 0
			;
			WITH cte_CertificateRangeWithoutKE
			AS
			(SELECT
					FCCAG.MtFCCAGenerator_Id
				   ,MIN(cd.MtFCCDetails_CertificateId) AS FromCertificate
				   ,MAX(cd.MtFCCDetails_CertificateId) AS ToCertificate
				FROM #CertificateDetailsWithoutKE cd
				INNER JOIN MtFCCAGenerator FCCAG
					ON cd.MtFCCMaster_Id = FCCAG.MtFCCMaster_Id
				WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId
				GROUP BY FCCAG.MtFCCAGenerator_Id)


			UPDATE FCCAD
			SET FCCAD.MtFCCADetails_FromCertificate = CR.FromCertificate
			   ,FCCAD.MtFCCADetails_ToCertificate = CR.ToCertificate
			FROM MtFCCADetails FCCAD
			INNER JOIN MtFCCAGenerator FCCAG
				ON FCCAD.MtFCCAGenerator_Id = FCCAG.MtFCCAGenerator_Id
			INNER JOIN cte_CertificateRangeWithoutKE CR
				ON FCCAD.MtFCCAGenerator_Id = CR.MtFCCAGenerator_Id
			WHERE FCCAD.MtPartyRegistration_BuyerId <> @vKEMPId

			/*****************************************************************************************  
			block ids assigned to the rest of the DISCOs 
			*****************************************************************************************/

			UPDATE FCCD
			SET MtFCCDetails_Status = 1
			FROM #CertificateDetailsWithoutKE cd
			INNER JOIN MtFCCAGenerator FCCAG
				ON cd.MtFCCMaster_Id = FCCAG.MtFCCMaster_Id
			INNER JOIN MtFCCDetails FCCD
				ON cd.MtFCCDetails_Id = FCCD.MtFCCDetails_Id
			WHERE FCCAG.MtFCCAMaster_Id = @pFCCAMasterId;



		END

		UPDATE FCCA
		SET MtFCCAMaster_ModifiedOn = GETDATE()
		   ,MtFCCAMaster_ModifiedBy = @pUserId
		   ,MtFCCAMaster_Status = 'Executed'
		FROM MtFCCAMaster FCCA
		WHERE FCCA.MtFCCAMaster_Id = @pFCCAMasterId
	END TRY

	BEGIN CATCH
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();
		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH
END

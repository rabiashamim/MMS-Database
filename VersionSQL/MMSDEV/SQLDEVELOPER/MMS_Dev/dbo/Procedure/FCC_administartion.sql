/****** Object:  Procedure [dbo].[FCC_administartion]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Rabia Shamim
-- CREATE date: 9 May 2023      
-- ALTER date:       
-- Description:       
-- ================================================================================= 

CREATE PROCEDURE dbo.FCC_administartion @pUserId INT
, @pMtFCCMaster_Id DECIMAL(18, 0)
AS
BEGIN

	BEGIN TRY


		/*****************************************************************************************  
		/*Get reference ID and check if any number of certificate needs to be canceled*/
		  *****************************************************************************************/
		DECLARE @vMtFCCMaster_RefernceId DECIMAL(18, 9)
			   ,@vGeneratorId DECIMAL(18, 0);
		SELECT
			@vGeneratorId = MtGenerator_Id
		FROM MtFCCMaster
		WHERE MtFCCMaster_Id = @pMtFCCMaster_Id

		SELECT
			@vMtFCCMaster_RefernceId = MAX(MtFCCMaster_Id)
		FROM MtFCCMaster
		WHERE MtGenerator_Id = @vGeneratorId
		AND MtFCCMaster_Id < (SELECT
				MAX(MtFCCMaster_Id)
			FROM MtFCCMaster
			WHERE MtGenerator_Id = @vGeneratorId
			AND ISNULL(MtFCCMaster_IsDeleted, 0) = 0)
		AND ISNULL(MtFCCMaster_IsDeleted, 0) = 0

		/*****************************************************************************************      
		Upadte certificates that needs to be canceled
		*****************************************************************************************/

		DECLARE @NewFCC_count INT
			   ,@PreviousFCC_count INT
			   ,@DiffFCC_count INT

		SELECT
			@PreviousFCC_count = MtFCCMaster_TotalCertificates
		FROM MtFCCMaster
		WHERE MtFCCMaster_Id = @vMtFCCMaster_RefernceId

		SELECT
			@NewFCC_count = MtFCCMaster_TotalCertificates
		FROM MtFCCMaster
		WHERE MtFCCMaster_Id = @pMtFCCMaster_Id

		--set  @NewFCC_count=6
		--set @PreviousFCC_count=10

		IF @NewFCC_count < @PreviousFCC_count
		BEGIN
			SET @DiffFCC_count = @PreviousFCC_count - @NewFCC_count



			UPDATE MtFCCDetails
			SET MtFCCDetails_ToBeCanceledFlag = 1
			   ,MtFCCDetails_ToBeCanceledDate = DATEADD(MONTH, 3, getdate())
			   ,MtFCCDetails_ModifiedBy = @pUserId
			   ,MtFCCDetails_Modifiedon = getdate()
			WHERE MtFCCDetails_CertificateId IN (SELECT TOP (@DiffFCC_count)
					MtFCCDetails_CertificateId
				FROM MtFCCDetails fccd
				INNER JOIN MtFCCMaster fcc
					ON fccd.MtFCCMaster_Id = fcc.MtFCCMaster_Id
				WHERE MtGenerator_Id = @vGeneratorId
				AND MtFCCDetails_IsDeleted = 0
				AND MtFCCMaster_IsDeleted = 0
				ORDER BY MtFCCDetails_CertificateId DESC)

			--- This code is to check if the generator is involved in any assignments. If no, we cancel certificates automatically in case of revised IFC - Ammama
			DECLARE @vCountBlockedGenCerts INT = 0
			SELECT
				@vCountBlockedGenCerts = COUNT(MtFCCDetails_CertificateId)
			FROM MtFCCMaster fcc
			INNER JOIN MtFCCDetails fccd
				ON fcc.MtFCCMaster_Id = fccd.MtFCCMaster_Id
			WHERE MtGenerator_Id = @vGeneratorId
			AND MtFCCDetails_IsDeleted = 0
			AND MtFCCMaster_IsDeleted = 0
			AND MtFCCDetails_Status = 1

			IF @vCountBlockedGenCerts = 0
			BEGIN
				UPDATE fccd
				SET fccd.MtFCCDetails_IsCancelled = 1
				FROM MtFCCMaster fcc
				INNER JOIN MtFCCDetails fccd
					ON fcc.MtFCCMaster_Id = fccd.MtFCCMaster_Id

				WHERE MtGenerator_Id = @vGeneratorId
				AND MtFCCDetails_IsDeleted = 0
				AND MtFCCMaster_IsDeleted = 0
				AND ISNULL(MtFCCDetails_ToBeCanceledFlag, 0) = 1
			END

		END

	END TRY
	BEGIN CATCH
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();


		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH

END

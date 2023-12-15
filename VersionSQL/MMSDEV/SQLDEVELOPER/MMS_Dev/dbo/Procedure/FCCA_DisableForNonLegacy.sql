/****** Object:  Procedure [dbo].[FCCA_DisableForNonLegacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================          
-- Author:  Ammama Gill        
-- CREATE date: 13 Jun 2023        
-- ALTER date:         
-- Description:         
-- =================================================================================        
--[FCCA_DisableForNonLegacy]      
CREATE   Procedure dbo.FCCA_DisableForNonLegacy (@pMtContractCertificates_Id DECIMAL(18, 0), @pUserId INT = NULL)
AS
BEGIN
	BEGIN TRY

		/******************************************************************************************************************        
	          *******************************************************************************************************************/
		DECLARE @vFromCertificate VARCHAR(20)
			   ,@vToCertificate VARCHAR(20)
			   ,@vContractId DECIMAL(18, 0)
			   ,@vBuyerPartyId DECIMAL(18, 0)
			   ,@vSellerPartyId DECIMAL(18, 0)
			   ,@vSellerCategoryId DECIMAL(18, 0);

		SELECT
			@vFromCertificate = MtContractCertificates_FromCertificate
		   ,@vToCertificate = MtContractCertificates_ToCertificate
		   ,@vContractId = CC.MtContractRegistration_Id
		   ,@vBuyerPartyId = CR.MtContractRegistration_BuyerId
		   ,@vSellerPartyId = CR.MtContractRegistration_SellerId
		   ,@vSellerCategoryId = CR.MtContractRegistration_SellerCategoryId
		FROM MtContractCertificates CC
		INNER JOIN MtContractRegistration CR
			ON CC.MtContractRegistration_Id = CR.MtContractRegistration_Id
		WHERE MtContractCertificates_Id = @pMtContractCertificates_Id
		AND CR.MtContractRegistration_IsDeleted = 0

		/******************************************************************************************************************        
	          *******************************************************************************************************************/
		DROP TABLE IF EXISTS #Certificates
		SELECT
			* INTO #Certificates
		FROM MtFCCDetails
		WHERE MtFCCDetails_CertificateId BETWEEN @vFromCertificate AND @vToCertificate
		AND MtFCCDetails_IsCancelled = 0
		AND MtFCCDetails_IsDeleted = 0

		IF EXISTS (SELECT TOP 1
					1
				FROM #Certificates
				WHERE MtFCCDetails_OwnerPartyId <> @vBuyerPartyId)
		BEGIN
			RAISERROR ('One or more Certificate(s) is(are) not in your ownership.', 16, -1);
			RETURN;
		END

		DECLARE @vIsBlocked BIT = 1;
		/******************************************************************************************************************        
	          Certificate is unBlocked if the new owner is generator.       
	          *******************************************************************************************************************/
		IF EXISTS (SELECT
				TOP 1
					1
				FROM MtPartyCategory MPC
				WHERE MPC.MtPartyCategory_Id = @vSellerCategoryId
				AND SrCategory_Code IN ('GEN', 'EGEN'))
		BEGIN
			SET @vIsBlocked = 0
		END
		/******************************************************************************************************************        
	             Change the ownership of the certificates.      
	             *******************************************************************************************************************/
		UPDATE MtFCCDetails
		SET MtFCCDetails_OwnerPartyId = @vSellerPartyId
		   ,MtFCCDetails_Status = @vIsBlocked
		WHERE MtFCCDetails_CertificateId BETWEEN @vFromCertificate AND @vToCertificate
		AND MtFCCDetails_IsDeleted = 0
		AND MtFCCDetails_IsCancelled = 0

		/******************************************************************************************************************        
	          *******************************************************************************************************************/
		UPDATE MtContractCertificates
		SET MtContractCertificates_IsDisabled = 1
		   ,MtContractCertificates_DisabledDate = GETDATE()
		WHERE MtContractCertificates_Id = @pMtContractCertificates_Id;

		/***************************************************************************      
	             Logs section          
	           ****************************************************************************/

		DECLARE @vGeneratorId DECIMAL(18, 0);
		SELECT
			@vGeneratorId = MtGenerator_Id
		FROM MtFCCDetails fccd
		INNER JOIN MtFCCMaster fcc
			ON fccd.MtFCCMaster_Id = fcc.MtFCCMaster_Id
		WHERE MtFCCDetails_CertificateId = @vFromCertificate

		DECLARE @output VARCHAR(MAX);
		SET @output = 'Certificate Assignment rolled back: ' + CAST(@vGeneratorId AS VARCHAR(10)) + ' with name ' + (SELECT
				MtGenerator_Name
			FROM MtGenerator
			WHERE MtGenerator_Id = @vGeneratorId)
		+ '.';
		SET @pUserId = ISNULL(@pUserId, 0); -- until latest front end code is not deployed, this check is necessary - to avoid exceptions and let the code flow be normal.    
		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Certificate Administration'
							   ,@CrudOperationName = 'Update'
							   ,@logMessage = @output

		/***************************************************************************          
	        Logs section          
	       ****************************************************************************/

		--EXECUTE FCCA_ModifyReAssignForNonLegacy @vMtFCCAMaster_Id      
		--            ,0      

		RETURN 1;

	/******************************************************************************************************************        
          *******************************************************************************************************************/

	END TRY
	BEGIN CATCH
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();
		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH
END

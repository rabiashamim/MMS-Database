/****** Object:  Procedure [dbo].[Insert_ContractCertificates]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ammama Gill | ALI IMRAN   
-- CREATE date: 20 June 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================    
--   
CREATE PROCEDURE dbo.Insert_ContractCertificates @pMtContractRegistration_Id DECIMAL(18, 0)
, @pFromCertificate VARCHAR(20)
, @pToCertificate VARCHAR(20)
,@pGeneratorId DECIMAL(18,0)
, @pUserId INT

AS
BEGIN
	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [dbo].[MtContractCertificates]
			WHERE MtContractCertificates_IsDeleted = 0
			AND MtContractCertificates_IsDisabled = 0
			AND MtContractCertificates_FromCertificate = @pFromCertificate
			AND MtContractCertificates_ToCertificate = @pToCertificate)
	BEGIN

		/**************************************************************************************************  
	    Fetch Certificate Generator Party Id  
	    ***************************************************************************************************/
		DECLARE @vPartyId DECIMAL(18, 0)
		SELECT
			@vPartyId = G.MtPartyRegisteration_Id
		FROM MtFCCDetails D
		JOIN MtFCCMaster M
			ON D.MtFCCMaster_Id = M.MtFCCMaster_Id
		JOIN vw_GeneratorParties G
			ON G.MtGenerator_Id = M.MtGenerator_Id
		WHERE MtFCCDetails_CertificateId = @pFromCertificate

		/**************************************************************************************************  
	    Insert  
	    ***************************************************************************************************/


		;
		WITH cte_Certificates
		AS
		(SELECT
				ROW_NUMBER() OVER (ORDER BY MtFCCDetails_CertificateId ASC) AS rowNumber
			   ,MtFCCDetails_CertificateId
			FROM MtFCCDetails
			WHERE MtFCCDetails_CertificateId BETWEEN @pFromCertificate AND @pToCertificate
			AND MtFCCDetails_IsDeleted = 0)


		INSERT INTO [dbo].[MtContractCertificates] ([MtContractRegistration_Id]
		, GeneratorParty_Id
		, [MtContractCertificates_Generator_Id]
		, [MtContractCertificates_FromCertificate]
		, [MtContractCertificates_ToCertificate]
		, MtContractCertificates_AssociatedCapacity
		, [MtContractCertificates_CreatedBy])
			SELECT
				@pMtContractRegistration_Id
			   ,@vPartyId
			   ,@pGeneratorId
			   ,@pFromCertificate
			   ,@pToCertificate
			   ,CAST(MAX(rowNumber) AS DECIMAL(18, 2)) / 10
			   ,@pUserId
			FROM cte_Certificates

	END
END

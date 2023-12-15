/****** Object:  Procedure [dbo].[BilateralContract_GetAvailableCertificateRanges]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================                      
-- Author:  Ammama Gill | Ali Imran                
-- CREATE date: 07 June, 2023                    
-- ALTER date:                     
-- Description:                     
-- =================================================================================                     
--[BilateralContract_GetAvailableCertificateRanges] 167,null,22               


CREATE   PROCEDUREdbo.BilateralContract_GetAvailableCertificateRanges (@pGeneratorId DECIMAL(18, 0), @pBilateralContractId DECIMAL(18, 0) = NULL, @pFCCAMasterId DECIMAL(18, 0) = NULL)
AS
BEGIN

	IF ISNULL(@pFCCAMasterId, 0) <> 0
	BEGIN
		DECLARE @vSellerPartyId DECIMAL(18, 0)
		SELECT
			@vSellerPartyId = MtPartyRegisteration_Id
		FROM MtFCCAMaster FCCA
		WHERE MtFCCAMaster_Id = @pFCCAMasterId

		DROP TABLE IF EXISTS #GenCertificates1
		SELECT
			DENSE_RANK() OVER (ORDER BY t.MtFCCDetails_IsCancelled, t.RowNum_WOC - t.RowNum_WC) AS partition_seqnum
		   ,* INTO #GenCertificates1
		FROM (SELECT
				ROW_NUMBER() OVER (ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WOC
			   ,ROW_NUMBER() OVER (PARTITION BY FCCD.MtFCCDetails_IsCancelled, FCCD.MtFCCDetails_Status ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WC
			   ,MtFCCDetails_CertificateId
			   ,MtFCCDetails_IsCancelled
			   ,MtGenerator_Id
			   ,FCCD.MtFCCDetails_Status
			   ,MtFCCDetails_OwnerPartyId
			FROM MtFCCMaster FCC
			INNER JOIN MtFCCDetails FCCD
				ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
			WHERE MtGenerator_Id = @pGeneratorId) t
		ORDER BY MtFCCDetails_CertificateId ASC


		SELECT
		DISTINCT
			partition_seqnum AS PartitionSequence
		   ,MtGenerator_Id AS GeneratorId
		   ,concat_WS(' to ', MIN(MtFCCDetails_CertificateId), MAX(MtFCCDetails_CertificateId)) AS certificateRange
		FROM #GenCertificates1
		WHERE ISNULL(MtFCCDetails_IsCancelled, 0) = 0
		AND ISNULL(MtFCCDetails_Status, 0) = 0
		AND MtFCCDetails_OwnerPartyId = @vSellerPartyId
		GROUP BY MtGenerator_Id
				,partition_seqnum
		ORDER BY partition_seqnum
		;
	END

	ELSE
	IF ISNULL(@pBilateralContractId, 0) <> 0
	BEGIN
		DECLARE @vSrCategory_Code VARCHAR(4);

		SELECT
			@vSrCategory_Code = SrCategory_Code
		FROM MtContractRegistration CR
		INNER JOIN MtPartyCategory PC
			ON CR.MtContractRegistration_SellerCategoryId = PC.MtPartyCategory_Id
		WHERE CR.MtContractRegistration_Id = @pBilateralContractId;

		IF @vSrCategory_Code in ( 'GEN', 'EGEN')
		BEGIN

			DROP TABLE IF EXISTS #GenCertificates
			SELECT
				DENSE_RANK() OVER (ORDER BY t.MtFCCDetails_IsCancelled, t.RowNum_WOC - t.RowNum_WC) AS partition_seqnum
			   ,* INTO #GenCertificates
			FROM (SELECT
					ROW_NUMBER() OVER (ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WOC
				   ,ROW_NUMBER() OVER (PARTITION BY FCCD.MtFCCDetails_IsCancelled, FCCD.MtFCCDetails_Status ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WC
				   ,MtFCCDetails_CertificateId
				   ,MtFCCDetails_IsCancelled
				   ,MtGenerator_Id
				   ,FCCD.MtFCCDetails_Status
				   ,MtFCCDetails_OwnerPartyId
				FROM MtFCCMaster FCC
				INNER JOIN MtFCCDetails FCCD
					ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
				WHERE MtGenerator_Id = @pGeneratorId) t
			ORDER BY MtFCCDetails_CertificateId ASC


			SELECT
			DISTINCT
				partition_seqnum AS PartitionSequence
			   ,MtGenerator_Id AS GeneratorId
			   ,concat_WS(' to ', MIN(MtFCCDetails_CertificateId), MAX(MtFCCDetails_CertificateId)) AS certificateRange
			FROM #GenCertificates
			WHERE ISNULL(MtFCCDetails_IsCancelled, 0) = 0
			AND ISNULL(MtFCCDetails_Status, 0) = 0
			GROUP BY MtGenerator_Id
					,partition_seqnum
			ORDER BY partition_seqnum
			;

		END

		ELSE
		BEGIN

			DECLARE @vSellerId DECIMAL(18, 0);
			SELECT
				@vSellerId = MtContractRegistration_SellerId
			FROM MtContractRegistration CR
			WHERE MtContractRegistration_Id = @pBilateralContractId;



			DROP TABLE IF EXISTS #OwnerCertificates
			SELECT
				DENSE_RANK() OVER (ORDER BY t.MtFCCDetails_OwnerPartyId, t.RowNum_WOC - t.RowNum_WC) AS partition_seqnum
			   ,* INTO #OwnerCertificates
			FROM (SELECT
					ROW_NUMBER() OVER (ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WOC
				   ,ROW_NUMBER() OVER (PARTITION BY FCCD.MtFCCDetails_OwnerPartyId ORDER BY FCCD.MtFCCDetails_CertificateId) AS RowNum_WC
				   ,MtFCCDetails_CertificateId
				   ,MtGenerator_Id
				   ,FCCD.MtFCCDetails_OwnerPartyId
				FROM MtFCCMaster FCC
				INNER JOIN MtFCCDetails FCCD
					ON FCC.MtFCCMaster_Id = FCCD.MtFCCMaster_Id
				WHERE MtGenerator_Id = @pGeneratorId) t
			ORDER BY MtFCCDetails_CertificateId ASC


			SELECT
			DISTINCT
				partition_seqnum AS PartitionSequence
			   ,MtGenerator_Id AS GeneratorId
			   ,concat_WS(' to ', MIN(MtFCCDetails_CertificateId), MAX(MtFCCDetails_CertificateId)) AS certificateRange
			FROM #OwnerCertificates
			WHERE MtFCCDetails_OwnerPartyId = @vSellerId
			GROUP BY MtGenerator_Id
					,partition_seqnum
			ORDER BY partition_seqnum
			;

		END

	END
END

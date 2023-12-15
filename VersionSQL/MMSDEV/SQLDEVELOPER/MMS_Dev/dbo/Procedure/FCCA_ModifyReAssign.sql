/****** Object:  Procedure [dbo].[FCCA_ModifyReAssign]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- ================================================================================        
-- Author:  Sadaf Malik     
-- CREATE date: 08 May 2023      
-- ALTER date:       
-- Description:       
-- =================================================================================       
--FCCA_Rollback 10    
CREATE   PROCEDUREdbo.FCCA_ModifyReAssign (@pFCCAMasterId DECIMAL(18, 0),
@pUserId INT)
AS
BEGIN

	-- Get seller ID. Check if seller id is legacy
	DECLARE @vIsLegacyParty BIT = 0;
	SELECT
		@vIsLegacyParty =
		CASE
			WHEN MtPartyRegisteration_Id = 1 THEN 1
			ELSE 0
		END
	FROM MtFCCAMaster FCCA
	WHERE MtFCCAMaster_Id = @pFCCAMasterId
	/*****************************************************************************************      
       FCCA Generator Backup    
       *****************************************************************************************/
	IF @vIsLegacyParty = 1
	BEGIN

		INSERT INTO [dbo].[MtFCCAGeneratorHistory] ([MtFCCAGenerator_Id]
		, [MtFCCAMaster_Id]
		, [MtFCCMaster_Id]
		, [MtGenerator_Id]
		, [MtFCCAGenerator_IFC]
		, [MtFCCAGenerator_KEShare]
		, [MtFCCAGenerator_WithoutKE]
		, [MtFCCAGenerator_CreatedBy]
		, [MtFCCAGenerator_CreatedOn]
		, [MtFCCAGenerator_ModifiedBy]
		, [MtFCCAGenerator_ModifiedOn]
		, [MtFCCAGenerator_IsDeleted]
		, [MtFCCAGeneratorHistory_CreatedDate])
			SELECT
				[MtFCCAGenerator_Id]
			   ,[MtFCCAMaster_Id]
			   ,[MtFCCMaster_Id]
			   ,[MtGenerator_Id]
			   ,[MtFCCAGenerator_IFC]
			   ,[MtFCCAGenerator_KEShare]
			   ,[MtFCCAGenerator_WithoutKE]
			   ,[MtFCCAGenerator_CreatedBy]
			   ,[MtFCCAGenerator_CreatedOn]
			   ,[MtFCCAGenerator_ModifiedBy]
			   ,[MtFCCAGenerator_ModifiedOn]
			   ,[MtFCCAGenerator_IsDeleted]
			   ,GetDate()
			FROM [dbo].[MtFCCAGenerator]
			WHERE MtFCCAMaster_Id = @pFCCAMasterId


		/*****************************************************************************************      
	       FCCA Detail Backup    
	       *****************************************************************************************/

		INSERT INTO [dbo].[MtFCCADetailsHistory] ([MtFCCADetails_Id]
		, [MtContractRegistration_Id]
		, [MtPartyRegistration_BuyerId]
		, [MtFCCAGenerator_Id]
		, [MtFCCADetails_AllocationFactor]
		, [MtFCCADetails_AssociatedCapacity]
		, [MtFCCADetails_CreatedBy]
		, [MtFCCADetails_CreatedOn]
		, [MtFCCADetails_ModifiedBy]
		, [MtFCCADetails_ModifiedOn]
		, [MtFCCADetails_IsDeleted]
		, [MtFCCADetailsHistory_CreatedDate])

			SELECT
				[MtFCCADetails_Id]
			   ,[MtContractRegistration_Id]
			   ,[MtPartyRegistration_BuyerId]
			   ,[MtFCCAGenerator_Id]
			   ,[MtFCCADetails_AllocationFactor]
			   ,[MtFCCADetails_AssociatedCapacity]
			   ,[MtFCCADetails_CreatedBy]
			   ,[MtFCCADetails_CreatedOn]
			   ,[MtFCCADetails_ModifiedBy]
			   ,[MtFCCADetails_ModifiedOn]
			   ,[MtFCCADetails_IsDeleted]
			   ,GetDate()
			FROM [dbo].[MtFCCADetails]
			WHERE [MtFCCAGenerator_Id] IN (SELECT
					[MtFCCAGenerator_Id]
				FROM [dbo].[MtFCCAGenerator]
				WHERE MtFCCAMaster_Id = @pFCCAMasterId)


		/*****************************************************************************************      
	        FCCA Generator details Backup    
	        *****************************************************************************************/
		INSERT INTO MtFCCAGeneratorDetailsHistory (MtFCCAGeneratorDetails_Id,
		[MtFCCAGenerator_Id],
		MtFCCAGeneratorDetails_FromCertificate,
		MtFCCAGeneratorDetails_ToCertificate,
		MtFCCAGeneratorDetails_RangeCapacity,
		MtFCCAGeneratorDetails_RangeTotalCertificates,
		MtFCCAGeneratorDetails_IsCancelled,
		MtFCCAGeneratorDetails_CancelledDate,
		MtFCCAGeneratorDetails_CreatedBy,
		MtFCCAGeneratorDetails_CreatedOn)

			SELECT
				MtFCCAGeneratorDetails_Id
			   ,[MtFCCAGenerator_Id]
			   ,MtFCCAGeneratorDetails_FromCertificate
			   ,MtFCCAGeneratorDetails_ToCertificate
			   ,MtFCCAGeneratorDetails_RangeCapacity
			   ,MtFCCAGeneratorDetails_RangeTotalCertificates
			   ,MtFCCAGeneratorDetails_IsCancelled
			   ,MtFCCAGeneratorDetails_CancelledDate
			   ,@pUserId
			   ,GETDATE()


			FROM MtFCCAGeneratorDetails
			WHERE MtFCCAGeneratorDetails_Id IN (SELECT
					fccagd.MtFCCAGeneratorDetails_Id
				FROM MtFCCAGenerator fccag
				INNER JOIN MtFCCAGeneratorDetails fccagd
					ON fccag.MtFCCAGenerator_Id = fccagd.MtFCCAGenerator_Id
				WHERE fccag.MtFCCAMaster_Id = @pFCCAMasterId)


		/*****************************************************************************************      
	        FCCA Detail assignment Backup    
	        *****************************************************************************************/

		INSERT INTO MtFCCAAssigmentDetailsHistory ([MtFCCAAssigmentDetails_Id],
		[MtFCCADetails_Id],
		[MtFCCAAssigmentDetails_FromCertificate],
		[MtFCCAAssigmentDetails_ToCertificate],
		[MtFCCAAssigmentDetails_CreatedBy]
		, MtFCCAAssigmentDetails_CreatedOn
		, MtFCCAAssigmentDetails_IsDeleted)

			SELECT
				MtFCCAAssigmentDetails_Id
			   ,MtFCCADetails_Id
			   ,MtFCCAAssigmentDetails_FromCertificate
			   ,MtFCCAAssigmentDetails_ToCertificate
			   ,MtFCCAAssigmentDetails_CreatedBy
			   ,MtFCCAAssigmentDetails_CreatedOn
			   ,MtFCCAAssigmentDetails_IsDeleted
			FROM MtFCCAAssigmentDetails
			WHERE MtFCCAAssigmentDetails_Id IN (SELECT
					fccaad.MtFCCAAssigmentDetails_Id
				FROM MtFCCAMaster FCCA
				INNER JOIN MtFCCAGenerator fccag
					ON FCCA.MtFCCAMaster_Id = fccag.MtFCCAMaster_Id
				INNER JOIN MtFCCADetails fccad
					ON fccad.MtFCCAGenerator_Id = fccag.MtFCCAGenerator_Id
				INNER JOIN MtFCCAAssigmentDetails fccaad
					ON fccad.MtFCCADetails_Id = fccaad.MtFCCADetails_Id
				WHERE fccag.MtFCCAMaster_Id = @pFCCAMasterId)




		/*****************************************************************************************      
	       Update execution status in FCCA Master      
	       *****************************************************************************************/


		EXEC [dbo].[FCCA_Rollback] @pFCCAMasterId = @pFCCAMasterId
								  ,@pUserId = @pUserId



		UPDATE MtFCCAMaster
		SET MtFCCAMaster_Status = 'Modified'
		   ,MtFCCAMaster_ApprovalStatus = 'Draft'
		WHERE MtFCCAMaster_Id = @pFCCAMasterId
	END
	ELSE
	BEGIN
		UPDATE MtFCCAMaster
		SET MtFCCAMaster_Status = 'Executed'
		   ,MtFCCAMaster_ApprovalStatus = 'Draft'
		WHERE MtFCCAMaster_Id = @pFCCAMasterId
	END

END

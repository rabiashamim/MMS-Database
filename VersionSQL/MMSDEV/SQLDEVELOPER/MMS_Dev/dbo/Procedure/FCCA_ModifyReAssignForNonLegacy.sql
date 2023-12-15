/****** Object:  Procedure [dbo].[FCCA_ModifyReAssignForNonLegacy]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ali Imran  
-- CREATE date: 16 Jun 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
--FCCA_Rollback 10  
CREATE   PROCEDUREdbo.FCCA_ModifyReAssignForNonLegacy (@pFCCAMasterId DECIMAL(18, 0),
@pUserId INT)
AS
BEGIN

	/*****************************************************************************************    
    FCCA Generator Backup  
    *****************************************************************************************/


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
		   ,GETDATE()
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
		   ,GETDATE()
		FROM [dbo].[MtFCCADetails]
		WHERE [MtFCCAGenerator_Id] IN (SELECT
				[MtFCCAGenerator_Id]
			FROM [dbo].[MtFCCAGenerator]
			WHERE MtFCCAMaster_Id = @pFCCAMasterId)





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






END

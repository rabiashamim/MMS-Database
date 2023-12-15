/****** Object:  Procedure [dbo].[ADD_MtFCCAAssigmentDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Ali Imran   
-- CREATE date: 13 june 2023     
-- ALTER date:       
-- Description:       
-- =================================================================================     
CREATE   PROCEDUREdbo.ADD_MtFCCAAssigmentDetails @pMtFCCADetails_Id DECIMAL(18, 0)
, @pFromCertificate VARCHAR(15)
, @pToCertificate VARCHAR(15)
, @pOwnerId DECIMAL(18, 0)
, @pUserId DECIMAL(18, 0)
AS
BEGIN
	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [MtFCCAAssigmentDetails]
			WHERE MtFCCAAssigmentDetails_FromCertificate = @pFromCertificate
			AND MtFCCAAssigmentDetails_ToCertificate = @pToCertificate
			AND MtFCCAAssigmentDetails_OwnerPartyId = @pOwnerId
			AND MtFCCAAssigmentDetails_IsDeleted = 0
			AND MtFCCAAssigmentDetails_IsDisabled = 0)

	BEGIN
		INSERT INTO [dbo].[MtFCCAAssigmentDetails] (MtFCCADetails_Id
		, MtFCCAAssigmentDetails_FromCertificate
		, MtFCCAAssigmentDetails_ToCertificate
		, MtFCCAAssigmentDetails_OwnerPartyId
		, MtFCCAAssigmentDetails_CreatedBy)

			SELECT
				@pMtFCCADetails_Id
			   ,@pFromCertificate
			   ,@pToCertificate
			   ,@pOwnerId
			   ,@pUserId

	END
END

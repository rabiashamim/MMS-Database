/****** Object:  Procedure [dbo].[FCC_ChangeOwnerShip]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================    
-- Author:  Ammama Gill | ALI IMRAN 
-- CREATE date: 20 June 2023  
-- ALTER date:   
-- Description:   
-- =================================================================================  
-- 
CREATE   PROCEDURE FCC_ChangeOwnerShip @vOwnerPartyId DECIMAL(18, 0)
, @pFromCertificate VARCHAR(20)
, @pToCertificate VARCHAR(20)
, @pUserId INT

AS
BEGIN

	/******************************************************************************************************************  
 	-- 5 Mark Certificate Blocked  
 	*******************************************************************************************************************/

	UPDATE D
	SET MtFCCDetails_Status = 1
	   ,MtFCCDetails_OwnerPartyId = @vOwnerPartyId
	   ,MtFCCDetails_ModifiedBy = @pUserId
	   ,MtFCCDetails_ModifiedOn = GETDATE()
	FROM MtFCCDetails D

	WHERE ISNULL(D.MtFCCDetails_IsDeleted, 0) = 0
	AND D.MtFCCDetails_CertificateId BETWEEN @pFromCertificate AND @pToCertificate
	AND D.MtFCCDetails_OwnerPartyId != @vOwnerPartyId
	AND D.MtFCCDetails_IsCancelled=0

END

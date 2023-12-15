/****** Object:  Procedure [dbo].[FCCA_GetDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================    
-- Author:  Ammama Gill  
-- CREATE date: 12 Apr 2023  
-- ALTER date:   
-- Description:   
-- =================================================================================   

CREATE PROCEDURE dbo.FCCA_GetDetails (@pFCCMasterId DECIMAL(18, 0))
AS
BEGIN

	SELECT
		mf.MtFCCDetails_Id AS FCCDetailsId
		,mf.MtFCCDetails_CertificateId AS CertificateId
	   ,NULL AS Buyer
	   ,NULL AS ContractCode
	   ,NULL AS ContractExpiryDate
	   ,CASE
			WHEN mf.MtFCCDetails_IsCancelled = 0 THEN CASE
					WHEN mf.MtFCCDetails_Status = 0 THEN 'Available'
					ELSE 'Blocked'
				END
			ELSE 'Cancelled'
		END AS Status
	FROM MtFCCDetails mf
	WHERE mf.MtFCCMaster_Id = @pFCCMasterId
	ORDER BY CertificateId
END

/****** Object:  Procedure [dbo].[FCCA_GetMPGenList]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================    
-- Author:  Ammama Gill  
-- CREATE date: 04 May 2023  
-- ALTER date:   
-- Description:   
-- =================================================================================   
CREATE   PROCEDUREdbo.FCCA_GetMPGenList
AS
BEGIN

	SELECT
	DISTINCT
		vgp.MtPartyRegisteration_Id AS PartyID
	   ,vgp.MtPartyRegisteration_Name AS PartyName
	FROM vw_GeneratorParties vgp
	WHERE vgp.MtPartyRegisteration_Id NOT IN (SELECT
			mf.MtPartyRegisteration_Id
		FROM MtFCCAMaster mf
		WHERE mf.MtFCCAMaster_IsDeleted = 0)
		AND vgp.MtPartyRegisteration_Id=1
		ORDER BY PartyID ASC;

END

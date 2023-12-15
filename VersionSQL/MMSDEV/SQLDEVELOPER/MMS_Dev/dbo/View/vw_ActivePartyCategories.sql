/****** Object:  View [dbo].[vw_ActivePartyCategories]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author: Ammama Gill | Alina Javed
-- CREATE date: 18 May 2023
-- ALTER date:  
-- Description: 
--              
-- =============================================  

CREATE VIEW vw_ActivePartyCategories
AS


SELECT
	PC.MtPartyRegisteration_Id
   ,PC.MtPartyCategory_Id
   ,PC.SrCategory_Code
FROM MtPartyRegisteration PR
INNER JOIN MtPartyCategory PC
	ON PR.MtPartyRegisteration_Id = PC.MtPartyRegisteration_Id
INNER JOIN SrCategory SC
	ON PC.SrCategory_Code = SC.SrCategory_Code
WHERE ISNULL(PC.isDeleted, 0) = 0
AND ISNULL(PR.isDeleted, 0) = 0
AND PR.LuStatus_Code_Applicant = 'AACT'

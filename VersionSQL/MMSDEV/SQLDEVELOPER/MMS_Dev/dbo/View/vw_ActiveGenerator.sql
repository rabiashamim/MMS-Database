/****** Object:  View [dbo].[vw_ActiveGenerator]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.vw_ActiveGenerator
AS
SELECT
	G.MtGenerator_Id AS Generator_Id
	,G.MtGenerator_Name AS Generator_Name

FROM MtGenerator G
JOIN MtPartyCategory PC ON PC.MtPartyCategory_Id=G.MtPartyCategory_Id
JOIN MtPartyRegisteration P ON P.MtPartyRegisteration_Id=PC.MtPartyRegisteration_Id
WHERE ISNULL(G.isDeleted, 0) = 0
AND ISNULL(PC.isDeleted,0)=0
AND ISNULL(P.isDeleted,0)=0
AND P.LuStatus_Code_Applicant='AACT'

/****** Object:  View [dbo].[vw_GeneratorParties]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.vw_GeneratorParties
AS
SELECT DISTINCT
	MG.MtGenerator_Id
   ,MPC.MtPartyRegisteration_Id
   ,MPR.MtPartyRegisteration_Name
   ,MG.MtGenerator_Name
   ,MG.COD_Date
   ,MG.MtGenerator_EffectiveFrom
   ,MG.MtGenerator_EffectiveTo
FROM MtGenerator MG
INNER JOIN MtPartyCategory MPC
	ON MG.MtPartyCategory_Id = MPC.MtPartyCategory_Id
INNER JOIN MtPartyRegisteration MPR
	ON MPC.MtPartyRegisteration_Id = MPR.MtPartyRegisteration_Id
WHERE ISNULL(MG.MtGenerator_IsDeleted, 0) = 0
AND ISNULL(MG.isDeleted, 0) = 0
AND ISNULL(MPC.isDeleted, 0) = 0
AND ISNULL(MPR.isDeleted, 0) = 0
AND MPR.LuStatus_Code_Applicant='AACT'

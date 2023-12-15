/****** Object:  View [dbo].[vw_CdpGenerators]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.vw_CdpGenerators
AS

	

SELECT DISTINCT
	cdp.RuCDPDetail_CdpId
	,cdp.RuCDPDetail_Id
   ,g.MtGenerator_Name
   ,gU.MtGenerationUnit_UnitName
   ,g.MtGenerator_Id
   ,gu.MtGenerationUnit_Id
   ,gu.MtGenerationUnit_SOUnitId
   ,gu.[SrTechnologyType_Code]
   ,(SELECT SrFuelType_Name FROM SrFuelType WHERE SrFuelType_Code=gu.SrFuelType_Code) AS FuelName
   ,gu.MtGenerationUnit_InstalledCapacity_KW  [Gen Unit Installed Capacity]
   ,g.MtGenerator_TotalInstalledCapacity AS [Gen Installed Capacity]
   ,mcm.MtPartyCategory_Id
   ,cdp.IsBackfeedInclude
FROM MtGenerator g
INNER JOIN MtGenerationUnit gu
	ON gu.MtGenerator_Id = g.MtGenerator_Id
INNER JOIN MtConnectedMeter mcm
	ON mcm.MtConnectedMeter_UnitId = gu.MtGenerationUnit_Id
INNER JOIN RuCDPDetail cdp
	ON cdp.RuCDPDetail_Id = mcm.MtCDPDetail_Id
WHERE ISNULL(g.MtGenerator_IsDeleted, 0) = 0
AND ISNULL(gu.MtGenerationUnit_IsDeleted, 0) = 0
AND ISNULL(mcm.MtConnectedMeter_isDeleted, 0) = 0
AND ISNULL(g.isDeleted, 0) = 0
AND mcm.MtPartyCategory_Id NOT IN (SELECT MtPartyCategory_Id FROM MtPartyCategory MPC WHERE MPC.SrCategory_Code='BPC' AND ISNULL(MPC.isDeleted,0)=0);

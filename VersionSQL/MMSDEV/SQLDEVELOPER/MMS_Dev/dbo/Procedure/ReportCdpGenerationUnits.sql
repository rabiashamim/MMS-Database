/****** Object:  Procedure [dbo].[ReportCdpGenerationUnits]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   PROCEDURE dbo.ReportCdpGenerationUnits

AS BEGIN
SELECT DISTINCT
	MPR.MtPartyRegisteration_Id,
	MPR.MtPartyRegisteration_Name
,	cdp.RuCDPDetail_CdpId
   ,g.MtGenerator_Name
   ,gU.MtGenerationUnit_UnitName
   ,g.MtGenerator_Id
   ,gu.MtGenerationUnit_Id
   ,gu.MtGenerationUnit_SOUnitId
   --,gu.[SrTechnologyType_Code]
   ,(SELECT SrTechnologyType_Name FROM SrTechnologyType WHERE SrTechnologyType_Code=gu.SrTechnologyType_Code) AS TechnologyName
   ,(SELECT SrFuelType_Name FROM SrFuelType WHERE SrFuelType_Code=gu.SrFuelType_Code) AS FuelName
   ,gu.MtGenerationUnit_InstalledCapacity_KW  [Gen Unit Installed Capacity]
   ,g.MtGenerator_TotalInstalledCapacity AS [Gen Installed Capacity]
   ,mcm.MtPartyCategory_Id
   , case when cdp.IsBackfeedInclude=1 then 'Unit' else 'Line' end as [CDP Location]
FROM
MtPartyRegisteration MPR 
inner join MtPartyCategory MPC on MPC.MtPartyRegisteration_Id=MPR.MtPartyRegisteration_Id
inner join MtGenerator g on g.MtPartyCategory_Id=MPC.MtPartyCategory_Id
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
AND ISNULL(MPR.isDeleted,0)=0
AND ISNULL(MPC.isDeleted,0)=0
AND MPR.LuStatus_Code_Applicant='AACT'

order by MPR.MtPartyRegisteration_Id,cdp.RuCDPDetail_CdpId, g.MtGenerator_Id, gu.MtGenerationUnit_Id
END

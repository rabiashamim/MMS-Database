/****** Object:  View [dbo].[Bme_CdpGuParties]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 

CREATE VIEW  [dbo].[Bme_CdpGuParties]
AS

SELECT  distinct
	  MP.MtPartyRegisteration_Id
	  ,MP.MtPartyRegisteration_Name
	  ,MP.SrPartyType_Code
	  ,PC.MtPartyCategory_Id
	  ,PC.SrCategory_Code
	  ,Gu.[MtGenerationUnit_Id]
      ,Gu.[MtGenerator_Id]
      ,Gu.[SrTechnologyType_Code]
      ,Gu.[SrFuelType_Code]
      ,Gu.[MtGenerationUnit_UnitNumber]
      ,Gu.[MtGenerationUnit_InstalledCapacity_KW]
      ,Gu.[MtGenerationUnit_IsDisabled]
      ,Gu.[MtGenerationUnit_EffectiveFrom]
      ,Gu.[MtGenerationUnit_EffectiveTo]
      ,Gu.[MtGenerationUnit_UnitName]
      ,Gu.[MtGenerationUnit_SOUnitId]
      ,Gu.[MtGenerationUnit_IsEnergyImported]
	  ,cdp.RuCDPDetail_TaxZoneID
	  ,cdp.RuCDPDetail_CongestedZoneID
      ,cdp.MtCongestedZone_Name
	  ,cdp.RuCDPDetail_Id
	  ,cdp.RuCDPDetail_CdpId
	  ,cdp.FromPartyRegisteration_Id, cdp.FromPartyRegisteration_Name, cdp.FromPartyType_Code 
     ,cdp.FromPartyCategory_Code, cdp.ToPartyRegisteration_Id, cdp.ToPartyRegisteration_Name, cdp.ToPartyType_Code, cdp.ToPartyCategory_Code, cdp.RuCDPDetail_IsEnergyImported, ISNULL
                     ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties as BGU
                        WHERE   (BGU.MtGenerationUnit_Id in(select MtConnectedMeter_UnitId from MtConnectedMeter where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (BGU.SrTechnologyType_Code IN ('ARE', 'HYD'))), 0) AS IsARE, ISNULL
                      ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties AS BGU
                        WHERE   (BGU.MtGenerationUnit_Id in(select MtConnectedMeter_UnitId from MtConnectedMeter where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (BGU.SrTechnologyType_Code = 'THR')), 0) AS IsThermal
 ,ISNULL(MP.MtPartyRegisteration_IsPowerPool,0) AS IsPowerPool
                        ,CDP.RuCDPDetail_EffectiveFrom as CDP_EffectiveFrom,
                        CDP.RuCDPDetail_EffectiveTo as CDP_EffectiveTo
FROM MtPartyRegisteration MP
INNER JOIN MtPartyCategory PC ON MP.MtPartyRegisteration_Id=PC.MtPartyRegisteration_Id
INNER JOIN MtConnectedMeter MC ON MC.MtPartyCategory_Id = PC.MtPartyCategory_Id
INNER JOIN MtGenerator G ON G.MtPartyCategory_Id=PC.MtPartyCategory_Id
INNER JOIN MtGenerationUnit GU ON GU.MtGenerationUnit_Id=MC.MtConnectedMeter_UnitId and GU.MtGenerator_Id = G.MtGenerator_Id
--JOIN RuCDPDetail RU ON RU.RuCDPDetail_Id=MC.MtCDPDetail_Id
INNER JOIN dbo.Bme_CdpParties AS cdp ON MC.MtCDPDetail_Id = cdp.RuCDPDetail_Id
WHERE 
ISNULL(MP.isDeleted,0)=0
AND  ISNULL(PC.isDeleted,0)=0
AND  ISNULL(MC.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(G.isDeleted,0)=0
and ISNULL(GU.MtGenerationUnit_IsDisabled,0)=0
AND ISNULL(GU.isDeleted,0)=0
AND ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
--AND (MP.LuStatus_Code_Applicant<>'ATER'  and  MP.LuStatus_Code_Approval <> 'TERM' )
AND MC.MtConnectedMeter_UnitId IS NOT NULL AND cdp.RuCDPDetail_CongestedZoneID IS NOT NULL
AND  MP.LuStatus_Code_Applicant='AACT'
--AND SrPartyType_Code <> 'EP'

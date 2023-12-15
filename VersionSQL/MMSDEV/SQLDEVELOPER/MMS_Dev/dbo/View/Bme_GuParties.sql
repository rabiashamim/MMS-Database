/****** Object:  View [dbo].[Bme_GuParties]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 
CREATE   View   dbo.Bme_GuParties
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
	  ,GU.Lu_CapUnitGenVari_Id
	  ,RU.RuCDPDetail_TaxZoneID
	  ,RU.RuCDPDetail_CongestedZoneID
	  ,G.MtGenerator_Name
      ,ISNULL(MP.MtPartyRegisteration_IsPowerPool,0) AS IsPowerPool
      ,RU.RuCDPDetail_EffectiveFrom as CDP_EffectiveFrom,
       RU.RuCDPDetail_EffectiveTo as CDP_EffectiveTo
FROM MtPartyRegisteration MP
INNER JOIN MtPartyCategory PC ON MP.MtPartyRegisteration_Id=PC.MtPartyRegisteration_Id
INNER JOIN MtConnectedMeter MC ON MC.MtPartyCategory_Id = PC.MtPartyCategory_Id
INNER JOIN MtGenerator G ON G.MtPartyCategory_Id=PC.MtPartyCategory_Id
INNER JOIN MtGenerationUnit GU ON GU.MtGenerationUnit_Id=MC.MtConnectedMeter_UnitId and GU.MtGenerator_Id = G.MtGenerator_Id
INNER JOIN RuCDPDetail RU ON RU.RuCDPDetail_Id=MC.MtCDPDetail_Id
WHERE 
ISNULL(MP.isDeleted,0)=0
AND  ISNULL(PC.isDeleted,0)=0
AND  ISNULL(MC.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(G.isDeleted,0)=0
and ISNULL(GU.MtGenerationUnit_IsDisabled,0)=0
AND ISNULL(GU.isDeleted,0)=0
AND ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0
--AND (MP.LuStatus_Code_Applicant<>'ATER'  and  MP.LuStatus_Code_Approval <> 'TERM' )
AND MC.MtConnectedMeter_UnitId IS NOT NULL AND RU.RuCDPDetail_CongestedZoneID is not null
AND  MP.LuStatus_Code_Applicant='AACT'
--AND SrPartyType_Code <> 'EP'

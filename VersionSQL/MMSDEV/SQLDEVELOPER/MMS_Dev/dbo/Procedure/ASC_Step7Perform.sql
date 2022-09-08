/****** Object:  Procedure [dbo].[ASC_Step7Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure [dbo].[ASC_Step7Perform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
			)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY    
   IF EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataGuHourly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
   BEGIN
INSERT INTO [dbo].[AscStatementDataGuMonthly]	
    (       
        [AscStatementData_StatementProcessId] 
      ,[AscStatementData_Year]
      ,[AscStatementData_Month]
      
      ,[AscStatementData_GenerationUnit_Id]
      ,[AscStatementData_Generator_Id]
      ,[AscStatementData_TechnologyType_Code]
      ,[AscStatementData_FuelType_Code]
      ,[AscStatementData_UnitNumber]
      ,[AscStatementData_InstalledCapacity_KW]
      
      ,[AscStatementData_IsDisabled]
      ,[AscStatementData_EffectiveFrom]
      ,[AscStatementData_EffectiveTo]
      ,[AscStatementData_UnitName]
      ,[AscStatementData_SOUnitId]
      ,[AscStatementData_IsEnergyImported]
      ,[AscStatementData_PartyRegisteration_Id]
      ,[AscStatementData_PartyRegisteration_Name]
      ,[AscStatementData_PartyType_Code]
	  ,[AscStatementData_PartyCategory_Code]
      ,AscStatementData_MtPartyCategory_Id
	  ,AscStatementData_TaxZoneID
	  ,AscStatementData_CongestedZoneID
      ,AscStatementData_CongestedZone
      
    )
SELECT 
@StatementProcessId
,@Year as Year,
@Month as Month      
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
	  ,Gu.MtPartyRegisteration_Id
	  ,Gu.MtPartyRegisteration_Name
	  ,Gu.SrPartyType_Code
	  ,Gu.SrCategory_Code
	  ,GU.MtPartyCategory_Id
	  ,GU.RuCDPDetail_TaxZoneID
	  ,GU.RuCDPDetail_CongestedZoneID
      ,Gu.MtCongestedZone_Name

      from ASC_GuParties GU;
--WHERE 
--GU.[MtGenerationUnit_SOUnitId] in  (2002,10001,2001,11001,11002,9001,6001,6002,3001,3002,3003,3004);
/*
"//Sum of all 
SC_BSC = (NS * SC) + BSC"

*/
 --DECLARE @Year int=2021, @Month int=11;
Drop Table  IF ExistS #TempSC
Drop Table IF ExistS #TempBSC 
select MtGenerationUnit_Id,@Year as Year, @Month as Month, SUM(MtGeneratorStart_UnitCost * MtGeneratorStart_NoOfStarts) as SC 
,SUM(MtGeneratorStart_NoOfStarts) as NS
INTO #TempSC
from MtGeneratorStart 
where DATEPART(YEAR,MtGeneratorStart_Date)=@Year AND DATEPART(MONTH,MtGeneratorStart_Date)=@Month 
AND  MtSOFileMaster_Id =dbo.GetMtSoFileMasterId(@StatementProcessId, 4)--59
GROUP BY MtGenerationUnit_Id;

--select * from MtGeneratorBS where MtSOFileMaster_Id=57
select MtGenerationUnit_Id,@Year as Year,@Month as Month, SUM(MtGeneratorBS_BSCharges) as BSC 
INTO #TempBSC
from MtGeneratorBS 
where DATEPART(YEAR,MtGeneratorBS_Date)=@Year AND DATEPART(MONTH,MtGeneratorBS_Date)=@Month 
AND  MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@StatementProcessId, 7)--57
GROUP BY MtGenerationUnit_Id;


--select  ISNULL(TS.SC,0) as sc, ISNULL(TB.BSC,0) as BSC,* 
UPDATE AscStatementDataGuMonthly SET 
AscStatementData_GBS_BSC=ISNULL(TB.BSC,0),
AscStatementData_GS_NS=ISNULL(TS.NS,0),
AscStatementData_GS_SC=ISNULL(TS.SC,0),
AscStatementData_SC_BSC=ISNULL(TS.SC,0) + ISNULL(TB.BSC,0),
AscStatementData_MAC= ISNULL(AscStatementData_AC_Total,0) + ISNULL(TS.SC,0) + ISNULL(TB.BSC,0)
FROM  AscStatementDataGuMonthly GUM
LEFT JOIN #TempSC TS on  GUM.AscStatementData_Year=TS.Year and GUM.AscStatementData_Month=TS.Month 
and TS.MtGenerationUnit_Id=GUM.AscStatementData_SOUnitId
LEFT JOIN #TempBSC TB on  GUM.AscStatementData_Year=TB.Year and GUM.AscStatementData_Month=TB.Month 
and TB.MtGenerationUnit_Id=GUM.AscStatementData_SOUnitId

where AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId



 select GUM.AscStatementData_SOUnitId,GUM.AscStatementData_Year, GUM.AscStatementData_Month,
 GUM.AscStatementData_StatementProcessId,
       SUM([AscStatementData_SO_MP]) as [AscStatementData_SO_MP]
      ,SUM([AscStatementData_SO_AC]			) as[AscStatementData_SO_AC]
      ,SUM([AscStatementData_SO_AC_ASC]	   ) as [AscStatementData_SO_AC_ASC]
      ,SUM([AscStatementData_SO_MR_EP]	   ) as [AscStatementData_SO_MR_EP]
      ,SUM([AscStatementData_SO_MR_VC]	   ) as [AscStatementData_SO_MR_VC]
      
      ,SUM([AscStatementData_SO_RG_VC]	   ) as [AscStatementData_SO_RG_VC]
      ,SUM([AscStatementData_SO_RG_EG_ARE] ) as [AscStatementData_SO_RG_EG_ARE]
      ,SUM([AscStatementData_SO_IG_VC]	   ) as [AscStatementData_SO_IG_VC]
      ,SUM([AscStatementData_SO_IG_EPG]	   ) as [AscStatementData_SO_IG_EPG]
      ,SUM([AscStatementData_MR_EAG]	   ) as [AscStatementData_MR_EAG]
	  ,SUM([AscStatementData_MR_UPC]	   ) as [AscStatementData_MR_UPC]
      ,SUM([AscStatementData_MR_EPG]	   ) as [AscStatementData_MR_EPG]
      ,SUM([AscStatementData_MRC]		   ) as [AscStatementData_MRC]
      ,SUM([AscStatementData_RG_EAG]	   ) as [AscStatementData_RG_EAG]
      ,SUM([AscStatementData_AC_MOD]	   ) as [AscStatementData_AC_MOD]
      ,SUM([AscStatementData_RG_LOCC]	   ) as [AscStatementData_RG_LOCC]
      ,SUM([AscStatementData_IG_EAG]	   ) as [AscStatementData_IG_EAG]
      ,SUM([AscStatementData_IG_EPG]	   ) as [AscStatementData_IG_EPG]
      ,SUM([AscStatementData_IG_UPC]	   ) as [AscStatementData_IG_UPC]
      ,SUM([AscStatementData_RG_AC]	   ) as [AscStatementData_RG_AC]
	  ,SUM([AscStatementData_IG_AC]	   ) as [AscStatementData_IG_AC]
	  ,SUM([AscStatementData_AC_Total]	   ) as [AscStatementData_AC_Total]

      ,MAX(CAST(AscStatementData_IsIG AS INT)) AS AscStatementData_IsIG
	  ,MAX(CAST(AscStatementData_IsRG AS INT)) AS AscStatementData_IsRG
	  ,MAX(CAST(AscStatementData_IsGenMR AS INT)) AS AscStatementData_IsGenMR
	  ,MAX(CAST(AscStatementData_IsGenBS AS INT)) AS AscStatementData_IsGenBS
	  ,MAX(CAST(AscStatementData_IsGenS AS INT)) AS AscStatementData_IsGenS
 
INTO #TempGUH
from AscStatementDataGuHourly GUM
where GUM.AscStatementData_Year=@Year and GUM.AscStatementData_Month=@Month and GUM.AscStatementData_StatementProcessId=@StatementProcessId
GROUP BY  GUM.AscStatementData_SOUnitId,GUM.AscStatementData_Year, GUM.AscStatementData_Month,gum.AscStatementData_StatementProcessId;

--------------
UPDATE AscStatementDataGuMonthly
SET 
[AscStatementData_SO_AC]         =GH.[AscStatementData_SO_AC]
,[AscStatementData_SO_AC_ASC]	 =GH.[AscStatementData_SO_AC_ASC]
,[AscStatementData_SO_MR_EP]		 =GH.[AscStatementData_SO_MR_EP]
,[AscStatementData_SO_MR_VC]		 =GH.[AscStatementData_SO_MR_VC]

,[AscStatementData_SO_RG_VC]		 =GH.[AscStatementData_SO_RG_VC]
,[AscStatementData_SO_RG_EG_ARE]	 =GH.[AscStatementData_SO_RG_EG_ARE]
,[AscStatementData_SO_IG_VC]		 =GH.[AscStatementData_SO_IG_VC]
,[AscStatementData_SO_IG_EPG]	 =GH.[AscStatementData_SO_IG_EPG]
,[AscStatementData_MR_EAG]		 =GH.[AscStatementData_MR_EAG]
,[AscStatementData_MR_UPC] =	GH.[AscStatementData_MR_UPC]
,[AscStatementData_MR_EPG]		 =GH.[AscStatementData_MR_EPG]
,[AscStatementData_MRC]			 =GH.[AscStatementData_MRC]
,[AscStatementData_RG_EAG]		 =GH.[AscStatementData_RG_EAG]
,[AscStatementData_AC_MOD]		 =GH.[AscStatementData_AC_MOD]
,[AscStatementData_RG_LOCC]		 =GH.[AscStatementData_RG_LOCC]
,[AscStatementData_IG_EAG]		 =GH.[AscStatementData_IG_EAG]
,[AscStatementData_IG_EPG]		 =GH.[AscStatementData_IG_EPG]
,[AscStatementData_IG_UPC]		 =GH.[AscStatementData_IG_UPC]
,[AscStatementData_RG_AC]		 =GH.[AscStatementData_RG_AC]
,[AscStatementData_IG_AC]		 =GH.[AscStatementData_IG_AC]
,[AscStatementData_AC_Total]	 =GH.[AscStatementData_AC_Total]
	  ,AscStatementData_IsIG= CAST(GH.AscStatementData_IsIG AS BIT)
	  ,AscStatementData_IsRG=CAST(GH.AscStatementData_IsRG AS BIT)
	  ,AscStatementData_IsGenMR=CAST(GH.AscStatementData_IsGenMR AS BIT)
	  ,AscStatementData_IsGenBS=CAST(GH.AscStatementData_IsGenBS AS BIT)
	  ,AscStatementData_IsGenS=CAST(GH.AscStatementData_IsGenS AS BIT)
FROM #TempGUH GH 
JOIN AscStatementDataGuMonthly GM on 
GM.AscStatementData_SOUnitId=GH.AscStatementData_SOUnitId and GM.AscStatementData_Year=GH.AscStatementData_Year
 and GM.AscStatementData_Month=GH.AscStatementData_Month
  and GM.AscStatementData_StatementProcessId=GH.AscStatementData_StatementProcessId
  where GM.AscStatementData_Year=@Year and GM.AscStatementData_Month=@Month and GM.AscStatementData_StatementProcessId=@StatementProcessId;
  

SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END
 ELSE
 BEGIN
 SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END 
END TRY
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END

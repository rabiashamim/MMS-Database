/****** Object:  Procedure [dbo].[BME_Step2APerform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--  IMPORT and Export sum with Gen and Gen Unit wise
-- =============================================
-- [dbo].[BME_Step2APerform] 2022, 6, 18
CREATE   Procedure [dbo].[BME_Step2APerform](			 
			@Year INT,
			@Month INT
			,@StatementProcessId decimal(18,0)
)
AS
BEGIN

--DROP TABLE IF EXISTS #temp
--DROP TABLE IF EXISTS #tempA
--DROP TABLE IF EXISTS #temp2
--DROP TABLE IF EXISTS #temp3

	DROP TABLE IF EXISTS #tempCdpGen
	select DISTINCT cdp.RuCDPDetail_CdpId,
g.MtGenerator_Name 
,g.MtGenerator_Id
,gu.MtGenerationUnit_Id
,gu.MtGenerationUnit_SOUnitId
,gu.[SrTechnologyType_Code]
,gu.MtGenerationUnit_InstalledCapacity_KW
INTO #tempCdpGen
FROM MtGenerator g
inner join MtGenerationUnit gu on gu.MtGenerator_Id=g.MtGenerator_Id
inner JOIN MtConnectedMeter mcm on mcm.MtConnectedMeter_UnitId=gu.MtGenerationUnit_Id
inner join RuCDPDetail cdp on cdp.RuCDPDetail_Id=mcm.MtCDPDetail_Id
where isnull( g.MtGenerator_IsDeleted,0)=0
and isnull(gu.MtGenerationUnit_IsDeleted,0)=0
and isnull(mcm.MtConnectedMeter_isDeleted,0)=0
AND ISNULL(g.isDeleted,0)=0;

SET NOCOUNT ON;
    BEGIN TRY

     IF Not EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataHourly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN

insert into BmeStatementDataHourly (
         [BmeStatementData_StatementProcessId]
         ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour]
  
)
	select distinct 
	     @StatementProcessId
         ,[BmeStatementData_NtdcDateTime]
        ,[BmeStatementData_Year]
        ,[BmeStatementData_Month]
        ,[BmeStatementData_Day]
        ,[BmeStatementData_Hour] 


 from BmeStatementDataCdpHourly
	 WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId
END	



     IF Not EXISTS(SELECT TOP 1 BmeStatementData_Id FROM [dbo].[BmeStatementDataGenUnitHourly] 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN

	
	
INSERT INTO [dbo].[BmeStatementDataGenUnitHourly]
           ([BmeStatementData_NtdcDateTime]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_Day]
           ,[BmeStatementData_Hour]
           ,[BmeStatementData_MtGenerator_Id]
           ,[BmeStatementData_MtGeneratorUnit_Id]
		   ,BmeStatementData_SOUnitId
		   ,[SrTechnologyType_Code]
		   ,BmeStatementData_InstalledCapacity_KW
           ,[BmeStatementData_IsBackfeedInclude]
           ,[BmeStatementData_StatementProcessId])
    

SELECT DISTINCT BmeStatementData_NtdcDateTime
	,BmeStatementData_Year
	,BmeStatementData_Month
	,BmeStatementData_Day
	,BmeStatementData_Hour
	,MtGenerator_Id
	,MtGenerationUnit_Id
	,MtGenerationUnit_SOUnitId
	,[SrTechnologyType_Code]
	,MtGenerationUnit_InstalledCapacity_KW
     ,[IsBackfeedInclude]
    ,BmeStatementData_StatementProcessId
	from BmeStatementDataCdpHourly 
	JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId = BmeStatementDataCdpHourly.BmeStatementData_CdpId
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year
	and BmeStatementDataCdpHourly.BmeStatementData_Month=@month
	and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId


END


--DELETE FROM [dbo].[BmeStatementDataGenUnitHourly]  WHERE BmeStatementData_StatementProcessId=18

----------case 1
PRINT(GETUTCDATE())
 
	UPDATE [dbo].[BmeStatementDataGenUnitHourly]  
	set 
	BmeStatementData_GenerationUnitEnergy =IsNull(BmeStatementData_GenerationUnitEnergy,0)+CDp2.UnitGeneration
	,BmeStatementData_GenerationUnitWiseBackfeed =IsNull(BmeStatementData_GenerationUnitWiseBackfeed,0)+CDp2.UnitWiseBackFeed
	,[BmeStatementData_GenerationUnitEnergy_Metered] =IsNull([BmeStatementData_GenerationUnitEnergy_Metered],0)+CDp2.UnitGeneration_Metered
	,[BmeStatementData_GenerationUnitWiseBackfeed_Metered] =IsNull([BmeStatementData_GenerationUnitWiseBackfeed_Metered],0)+CDp2.UnitWiseBackFeed_Metered
FROM [BmeStatementDataGenUnitHourly] DHA
INNER JOIN(


	select BmeStatementData_NtdcDateTime,T.MtGenerator_Id,T.MtGenerationUnit_Id--,MtGenerationUnit_UnitName--,T.RuCDPDetail_CdpId
	, Sum(BmeStatementData_AdjustedEnergyImport) as UnitWiseBackFeed
	, Sum(BmeStatementData_AdjustedEnergyExport)  AS UnitGeneration
	, Sum(BmeStatementData_IncEnergyImport) as UnitWiseBackFeed_Metered
	, Sum(BmeStatementData_IncEnergyExport)  AS UnitGeneration_Metered
	from BmeStatementDataCdpHourly
	INNER JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementDataCdpHourly.BmeStatementData_CdpId
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month
	and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_FromPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_ToPartyCategory_Code IN ('DSP','TSP') 
	    AND IsBackfeedInclude=1
	GROUP by BmeStatementData_NtdcDateTime,T.MtGenerator_Id,T.MtGenerationUnit_Id--,MtGenerationUnit_UnitName--RuCDPDetail_CdpId
	
	  ) AS CDp2
	  ON
      DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
	  AND  DHA.BmeStatementData_MtGenerator_Id=CDP2.MtGenerator_Id
	  AND  DHA.BmeStatementData_MtGeneratorUnit_Id=CDP2.MtGenerationUnit_Id
      where 
	  DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId
    

PRINT(GETUTCDATE())

----------case 2

 
	UPDATE [dbo].[BmeStatementDataGenUnitHourly]  
	set 
	BmeStatementData_GenerationUnitEnergy =IsNull(BmeStatementData_GenerationUnitEnergy,0)+CDp2.UnitGeneration
	,BmeStatementData_GenerationUnitWiseBackfeed =IsNull(BmeStatementData_GenerationUnitWiseBackfeed,0)+CDp2.UnitWiseBackFeed
	,[BmeStatementData_GenerationUnitEnergy_Metered] =IsNull([BmeStatementData_GenerationUnitEnergy_Metered],0)+CDp2.UnitGeneration_Metered
	,[BmeStatementData_GenerationUnitWiseBackfeed_Metered] =IsNull([BmeStatementData_GenerationUnitWiseBackfeed_Metered],0)+CDp2.UnitWiseBackFeed_Metered

FROM [BmeStatementDataGenUnitHourly] DHA
INNER JOIN(


	select BmeStatementData_NtdcDateTime,T.MtGenerator_Id,T.MtGenerationUnit_Id
	, Sum(BmeStatementData_AdjustedEnergyImport) AS UnitGeneration
	, Sum(BmeStatementData_AdjustedEnergyExport) AS UnitWiseBackFeed
	, Sum(BmeStatementData_IncEnergyImport) AS UnitGeneration_Metered
	, Sum(BmeStatementData_IncEnergyExport) AS UnitWiseBackFeed_Metered
	from BmeStatementDataCdpHourly
	INNER JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementDataCdpHourly.BmeStatementData_CdpId
	where BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month
	and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId
	AND BmeStatementData_ToPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_FromPartyCategory_Code IN ('DSP','TSP') 
	    AND IsBackfeedInclude=1
	GROUP by BmeStatementData_NtdcDateTime,T.MtGenerator_Id,T.MtGenerationUnit_Id--,MtGenerationUnit_UnitName--RuCDPDetail_CdpId
	
	  ) AS CDp2
	  ON
      DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
	  AND  DHA.BmeStatementData_MtGenerator_Id=CDP2.MtGenerator_Id
	  AND  DHA.BmeStatementData_MtGeneratorUnit_Id=CDP2.MtGenerationUnit_Id
      where 
	  DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId 
    


PRINT(GETUTCDATE())

--------- Case 3

	UPDATE [dbo].[BmeStatementDataGenUnitHourly]  
	set 
	BmeStatementData_GenerationUnitEnergy =IsNull(BmeStatementData_GenerationUnitEnergy,0)+CDp2.UnitGeneration
	,BmeStatementData_GenerationUnitWiseBackfeed =IsNull(BmeStatementData_GenerationUnitWiseBackfeed,0)+CDp2.UnitWiseBackFeed
	,BmeStatementData_GenerationUnitEnergy_Metered =IsNull(BmeStatementData_GenerationUnitEnergy_Metered,0)+CDp2.UnitGeneration_Metered
	,BmeStatementData_GenerationUnitWiseBackfeed_Metered =IsNull(BmeStatementData_GenerationUnitWiseBackfeed_Metered,0)+CDp2.UnitWiseBackFeed_Metered
FROM [BmeStatementDataGenUnitHourly] DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,CDP.MtGenerator_Id,CDP.MtGenerationUnit_Id,
	   SUM(
	ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))
     END,0))AS UnitGeneration
 
 ,	   SUM(
	ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))>0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyExport,0)- ISNULL(BmeStatementData_AdjustedEnergyImport,0))
     END,0))AS UnitWiseBackFeed
,  SUM(
	ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_IncEnergyExport,0)- ISNULL(BmeStatementData_IncEnergyImport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_IncEnergyExport,0)- ISNULL(BmeStatementData_IncEnergyImport,0))
     END,0))AS UnitGeneration_Metered
 
 ,	   SUM(
	ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_IncEnergyExport,0)- ISNULL(BmeStatementData_IncEnergyImport,0))>0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_IncEnergyExport,0)- ISNULL(BmeStatementData_IncEnergyImport,0))
     END,0))AS UnitWiseBackFeed_Metered
 

	FROM BmeStatementDataHourly DH
	INNER JOIN (
	
	select BmeStatementData_NtdcDateTime,T.MtGenerator_Id,T.MtGenerationUnit_Id
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	
	, Sum(BmeStatementData_IncEnergyImport) as BmeStatementData_IncEnergyImport
	, Sum(BmeStatementData_IncEnergyExport) as BmeStatementData_IncEnergyExport	
	from BmeStatementDataCdpHourly 
    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
	where 
	 BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId 
	--BmeStatementDataCdpHourly.BmeStatementData_Year=2022 
	--and BmeStatementDataCdpHourly.BmeStatementData_Month=6 
	--and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=17
	--AND BmeStatementDataCdpHourly.BmeStatementData_Day=1
	--AND BmeStatementDataCdpHourly.BmeStatementData_Hour=1
	AND BmeStatementData_FromPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_ToPartyCategory_Code IN ('DSP','TSP') 
	    AND IsBackfeedInclude=0
	GROUP by BmeStatementData_NtdcDateTime	,T.MtGenerator_Id,MtGenerationUnit_Id


	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      WHERE
	  DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
	--    DH.BmeStatementData_Year=2022 
	--and DH.BmeStatementData_Month=6 
	--and DH.BmeStatementData_StatementProcessId=17
	--AND DH.BmeStatementData_Day=1
	--AND DH.BmeStatementData_Hour=1
GROUP BY  DH.BmeStatementData_NtdcDateTime, CDP.MtGenerator_Id,CDP.MtGenerationUnit_Id
	  ) AS CDp2
	  ON
      DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
	  AND  DHA.BmeStatementData_MtGenerator_Id=CDP2.MtGenerator_Id
	  AND  DHA.BmeStatementData_MtGeneratorUnit_Id=CDP2.MtGenerationUnit_Id
      where 
	  DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId ;
	--  	DHA.BmeStatementData_Year=2022 
	--and DHA.BmeStatementData_Month=6 
	--and DHA.BmeStatementData_StatementProcessId=17
	--AND DHA.BmeStatementData_Day=1
	--AND DHA.BmeStatementData_Hour=1


PRINT(GETUTCDATE())

--------- Case 4

	UPDATE [dbo].[BmeStatementDataGenUnitHourly]  
	set 
	BmeStatementData_GenerationUnitEnergy =IsNull(BmeStatementData_GenerationUnitEnergy,0)+CDp2.UnitGeneration
	,BmeStatementData_GenerationUnitWiseBackfeed =IsNull(BmeStatementData_GenerationUnitWiseBackfeed,0)+CDp2.UnitWiseBackFeed
	,BmeStatementData_GenerationUnitEnergy_Metered =IsNull(DHA.BmeStatementData_GenerationUnitEnergy_Metered,0)+CDp2.UnitGeneration_Mtered
	,BmeStatementData_GenerationUnitWiseBackfeed_Metered =IsNull(DHA.BmeStatementData_GenerationUnitWiseBackfeed_Metered,0)+CDp2.UnitWiseBackFeed_Metered
FROM [BmeStatementDataGenUnitHourly] DHA
INNER JOIN(
SELECT
       DH.BmeStatementData_NtdcDateTime,CDP.MtGenerator_Id,CDP.MtGenerationUnit_Id,
	   
   SUM(ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))
     END,0)) AS UnitGeneration
, SUM(ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))>0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_AdjustedEnergyImport,0)- ISNULL(BmeStatementData_AdjustedEnergyExport,0))
     END,0)) AS UnitWiseBackFeed

 ,  SUM(ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_IncEnergyImport,0)- ISNULL(BmeStatementData_IncEnergyExport,0))<0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_IncEnergyImport,0)- ISNULL(BmeStatementData_IncEnergyExport,0))
     END,0)) AS UnitGeneration_Mtered
, SUM(ISNULL(
	CASE WHEN (ISNULL(BmeStatementData_IncEnergyImport,0)- ISNULL(BmeStatementData_IncEnergyExport,0))>0
    THEN 0
    ELSE
     (ISNULL(BmeStatementData_IncEnergyImport,0)- ISNULL(BmeStatementData_IncEnergyExport,0))
     END,0)) AS UnitWiseBackFeed_Metered
	FROM BmeStatementDataHourly DH
	INNER JOIN (
	
	select BmeStatementData_NtdcDateTime,T.MtGenerator_Id,T.MtGenerationUnit_Id
	, Sum(BmeStatementData_AdjustedEnergyImport) as BmeStatementData_AdjustedEnergyImport
	, Sum(BmeStatementData_AdjustedEnergyExport) as BmeStatementData_AdjustedEnergyExport	 
	, Sum(BmeStatementData_IncEnergyImport) as BmeStatementData_IncEnergyImport
	, Sum(BmeStatementData_IncEnergyExport) as BmeStatementData_IncEnergyExport	 
	from BmeStatementDataCdpHourly 
    JOIN #tempCdpGen t ON t.RuCDPDetail_CdpId=BmeStatementData_CdpId
	where 
	 BmeStatementDataCdpHourly.BmeStatementData_Year=@Year and BmeStatementDataCdpHourly.BmeStatementData_Month=@Month and BmeStatementDataCdpHourly.BmeStatementData_StatementProcessId=@StatementProcessId 
	AND BmeStatementData_ToPartyCategory_Code NOT in ('TSP','DSP')	
    AND BmeStatementData_FromPartyCategory_Code IN ('DSP','TSP') 
	    AND IsBackfeedInclude=0
	GROUP by BmeStatementData_NtdcDateTime	,T.MtGenerator_Id,MtGenerationUnit_Id


	) as cdp on  DH.BmeStatementData_NtdcDateTime = cdp.BmeStatementData_NtdcDateTime
      WHERE
	  DH.BmeStatementData_Year=@Year and DH.BmeStatementData_Month=@Month and DH.BmeStatementData_StatementProcessId=@StatementProcessId 
	--    DH.BmeStatementData_Year=2022 
	--and DH.BmeStatementData_Month=6 
	--and DH.BmeStatementData_StatementProcessId=17
	--AND DH.BmeStatementData_Day=1
	--AND DH.BmeStatementData_Hour=1
GROUP BY  DH.BmeStatementData_NtdcDateTime, CDP.MtGenerator_Id,CDP.MtGenerationUnit_Id
	  ) AS CDp2
	  ON
      DHA.BmeStatementData_NtdcDateTime = cdp2.BmeStatementData_NtdcDateTime
	  AND  DHA.BmeStatementData_MtGenerator_Id=CDP2.MtGenerator_Id
	  AND  DHA.BmeStatementData_MtGeneratorUnit_Id=CDP2.MtGenerationUnit_Id
      where 
	  DHA.BmeStatementData_Year=@Year and DHA.BmeStatementData_Month=@Month and DHA.BmeStatementData_StatementProcessId=@StatementProcessId ;
	--  	DHA.BmeStatementData_Year=2022 
	--and DHA.BmeStatementData_Month=6 
	--and DHA.BmeStatementData_StatementProcessId=17
	--AND DHA.BmeStatementData_Day=1
	--AND DHA.BmeStatementData_Hour=1





	/*
	Generation unit energy and unit wise backfeed
	*/

PRINT(GETUTCDATE())	

SELECT GUH.BmeStatementData_NtdcDateTime, GUH.BmeStatementData_MtGenerator_Id,GUH.BmeStatementData_MtGeneratorUnit_Id,GUH.BmeStatementData_SOUnitId 
,GUH.BmeStatementData_GenerationUnitEnergy_Metered
,GUH.BmeStatementData_GenerationUnitEnergy 
, GUH.BmeStatementData_UnitWiseGeneration
, GUH.BmeStatementData_GenerationUnitWiseBackfeed
,GUH.BmeStatementData_UnitWiseGeneration_Metered
,GUH.BmeStatementData_GenerationUnitWiseBackfeed_Metered
,ISNULL(SOAvail.MtAvailibilityData_AvailableCapacityASC,0) AS MtAvailibilityData_AvailableCapacityASC
,GUH.[SrTechnologyType_Code]
,GUH.BmeStatementData_InstalledCapacity_KW
,GUH.BmeStatementData_IsBackfeedInclude
INTO #tempA
FROM  [dbo].[BmeStatementDataGenUnitHourly]   GUH

LEFT JOIN(

SELECT 
 DATEADD(HOUR,CAST(AD.MtAvailibilityData_Hour AS INT)+1,CAST(AD.MtAvailibilityData_Date AS datetime)) AS MtAvailibilityDataDateHour
 ,AD.MtAvailibilityData_AvailableCapacityASC 
 ,AD.MtGenerationUnit_Id 
 
 FROM MtAvailibilityData AD

 	 WHERE   MtSOFileMaster_Id=dbo.GetMtSoFileMasterId(@StatementProcessId, 2)	
		) SOAvail
ON SOAvail.MtAvailibilityDataDateHour= GUH.BmeStatementData_NtdcDateTime
AND SOAvail.MtGenerationUnit_Id=GUH.BmeStatementData_SOUnitId


where 
  GUH.BmeStatementData_Year=@Year and GUH.BmeStatementData_Month=@Month and GUH.BmeStatementData_StatementProcessId=@StatementProcessId 


/*******************************************************************************/
/*
Calculate available capacity ASC based on technology type
*/

PRINT(GETUTCDATE())
SELECT 
BmeStatementData_NtdcDateTime, BmeStatementData_MtGenerator_Id,BmeStatementData_MtGeneratorUnit_Id,
BmeStatementData_SOUnitId 
, cdp.RuCDPDetail_CdpId
,BmeStatementData_GenerationUnitEnergy 
, BmeStatementData_UnitWiseGeneration
, BmeStatementData_GenerationUnitWiseBackfeed
,BmeStatementData_GenerationUnitEnergy_Metered 
, BmeStatementData_UnitWiseGeneration_Metered
, BmeStatementData_GenerationUnitWiseBackfeed_Metered
,#tempA.[SrTechnologyType_Code]
,#tempA.BmeStatementData_InstalledCapacity_KW
,#tempA.BmeStatementData_IsBackfeedInclude
,MtAvailibilityData_AvailableCapacityASC
,CASE WHEN --#tempA.BmeStatementData_IsBackfeedInclude=0 AND
#tempA.SrTechnologyType_Code<>'ARE' then MtAvailibilityData_AvailableCapacityASC 
WHEN --#tempA.BmeStatementData_IsBackfeedInclude=0 AND 
#tempA.SrTechnologyType_Code='ARE' THEN BmeStatementData_InstalledCapacity_KW
ELSE 0 end AS MtAvailibilityData_CalculatedAvailableCapacityASC

INTO #temp
FROM #tempA
JOIN #tempCdpGen cdp ON #tempA.BmeStatementData_MtGeneratorUnit_Id= cdp.MtGenerationUnit_Id 
ORDER by 2


/*
Group By Generator and CdpId
*/
PRINT(GETUTCDATE())


SELECT BmeStatementData_NtdcDateTime,BmeStatementData_MtGenerator_Id 
,RuCDPDetail_CdpId
, SUM(ISNULL(MtAvailibilityData_CalculatedAvailableCapacityASC,0))  AS MtAvailibilityData_AvailableCapacityASCSum
, SUM(ISNULL(BmeStatementData_InstalledCapacity_KW,0))  AS BmeStatementData_InstalledCapacity_KWSUM
INTO #temp2
FROM #temp
GROUP BY BmeStatementData_NtdcDateTime,BmeStatementData_MtGenerator_Id,RuCDPDetail_CdpId

/*
Prorata (Calculation) of unit wise back feed and unit generation energy.
*/
PRINT(GETUTCDATE())


SELECT distinct #temp.BmeStatementData_NtdcDateTime,#temp.BmeStatementData_MtGenerator_Id
,#temp.BmeStatementData_MtGeneratorUnit_Id
,BmeStatementData_GenerationUnitEnergy
,BmeStatementData_GenerationUnitWiseBackfeed
,BmeStatementData_GenerationUnitEnergy_Metered
,BmeStatementData_GenerationUnitWiseBackfeed_Metered
,#temp.MtAvailibilityData_AvailableCapacityASC
,#temp.MtAvailibilityData_CalculatedAvailableCapacityASC
,#temp2.MtAvailibilityData_AvailableCapacityASCSum
,#temp.SrTechnologyType_Code
,#temp.BmeStatementData_InstalledCapacity_KW
,#temp2.BmeStatementData_InstalledCapacity_KWSUM
,#temp.BmeStatementData_IsBackfeedInclude
,CASE WHEN #temp2.MtAvailibilityData_AvailableCapacityASCSum >0
then
 (ISNULL(#temp.MtAvailibilityData_CalculatedAvailableCapacityASC,0)/ISNULL(#temp2.MtAvailibilityData_AvailableCapacityASCSum,0))
 ELSE
 0 END AS UnitGenRatio
 ,CASE WHEN #temp2.BmeStatementData_InstalledCapacity_KWSUM >0
then
 (ISNULL(#temp.BmeStatementData_InstalledCapacity_KW,0)/ISNULL(#temp2.BmeStatementData_InstalledCapacity_KWSUM,0))
 ELSE
 0 END AS UnitBackFeedGenRatio


,CASE WHEN #temp2.MtAvailibilityData_AvailableCapacityASCSum >0 
then
 (ISNULL(#temp.MtAvailibilityData_CalculatedAvailableCapacityASC,0)/ISNULL(#temp2.MtAvailibilityData_AvailableCapacityASCSum,0))*
 ISNULL(BmeStatementData_GenerationUnitEnergy,0)
 ELSE
 0 END AS UnitGeneration
 
 ,CASE WHEN #temp2.MtAvailibilityData_AvailableCapacityASCSum >0 
then
 (ISNULL(#temp.MtAvailibilityData_CalculatedAvailableCapacityASC,0)/ISNULL(#temp2.MtAvailibilityData_AvailableCapacityASCSum,0))*
 ISNULL(BmeStatementData_GenerationUnitEnergy_Metered,0)
 ELSE
 0 END AS UnitGeneration_Metered

,CASE WHEN #temp2.BmeStatementData_InstalledCapacity_KWSUM >0 
--AND #temp.BmeStatementData_IsBackfeedInclude=0
then
ABS( (ISNULL(#temp.BmeStatementData_InstalledCapacity_KW,0)/ISNULL(#temp2.BmeStatementData_InstalledCapacity_KWSUM,0))*
 ISNULL(BmeStatementData_GenerationUnitWiseBackfeed,0))
--WHEN #temp.BmeStatementData_IsBackfeedInclude=1 THEN ISNULL(BmeStatementData_GenerationUnitWiseBackfeed,0)
 ELSE
 0 END AS UnitWiseBackfeed

 ,CASE WHEN #temp2.BmeStatementData_InstalledCapacity_KWSUM >0 
--AND #temp.BmeStatementData_IsBackfeedInclude=0
then
ABS( (ISNULL(#temp.BmeStatementData_InstalledCapacity_KW,0)/ISNULL(#temp2.BmeStatementData_InstalledCapacity_KWSUM,0))*
 ISNULL(BmeStatementData_GenerationUnitWiseBackfeed_Metered,0))
 ELSE
 0 END AS UnitWiseBackfeed_Metered

INTO #temp3
FROM 
#temp 
JOIN
#temp2 ON   #temp.BmeStatementData_NtdcDateTime=#temp2.BmeStatementData_NtdcDateTime
AND #temp.BmeStatementData_MtGenerator_Id=#temp2.BmeStatementData_MtGenerator_Id
AND #temp.RuCDPDetail_CdpId=#temp2.RuCDPDetail_CdpId

/*
update Unit Wise Generation and BackFeed.
*/



UPDATE GUH
SET [BmeStatementData_UnitWiseGeneration]=t.UnitGeneration
,[BmeStatementData_UnitWiseGenerationBackFeed]=T.UnitWiseBackfeed
,[BmeStatementData_UnitWiseGeneration_Metered]=t.UnitGeneration_Metered
,[BmeStatementData_UnitWiseGenerationBackFeed_Metered]=T.UnitWiseBackfeed_Metered
FROM  [dbo].[BmeStatementDataGenUnitHourly]   GUH
JOIN #temp3 t ON GUH.BmeStatementData_NtdcDateTime=T.BmeStatementData_NtdcDateTime
AND GUH.BmeStatementData_MtGeneratorUnit_Id=T.BmeStatementData_MtGeneratorUnit_Id
WHERE
GUH.BmeStatementData_Year=@Year and GUH.BmeStatementData_Month=@Month and GUH.BmeStatementData_StatementProcessId=@StatementProcessId 

PRINT(GETUTCDATE())



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

/****** Object:  Procedure [dbo].[BME_GenerationEnergyInfo]    Committed by VersionSQL https://www.versionsql.com ******/

/* =============================================      
 Author:Ali Imran    
 CREATE date: August 1, 2022     
 ALTER date:     
 Description:    
 ============================================= */    
-- dbo.BME_GenerationEnergyInfo 39    
CREATE   PROCEDURE dbo.BME_GenerationEnergyInfo (    
    
 @StatementProcessId DECIMAL(18, 0))    
AS    
BEGIN    
    
 SELECT DISTINCT    
  cdp.RuCDPDetail_CdpId    
    ,g.MtGenerator_Name    
    ,g.MtGenerator_Id    
    ,gu.MtGenerationUnit_Id    
    ,gu.MtGenerationUnit_UnitName    
    ,gu.MtGenerationUnit_SOUnitId    
    ,gu.[SrTechnologyType_Code]    
    ,gu.MtGenerationUnit_InstalledCapacity_KW INTO #tempCdpGen    
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
 AND ISNULL(gu.isDeleted, 0) = 0    
    
    
 SELECT DISTINCT    
  MtGenerator_Id    
    ,MtGenerator_Name    
    , MtGenerationUnit_Id    
    , MtGenerationUnit_UnitName    
    INTO #tempCdpGen3    
 FROM #tempCdpGen    
    
 SELECT    
    
  BmeStatementData_MtGenerator_Id AS [Generator Id]    
    ,g.MtGenerator_Name AS  [Generator]    
    ,SUM(BmeStatementData_UnitWiseGeneration) AS [Unit Generation (kWh)]    
    ,SUM(BmeStatementData_UnitWiseGenerationBackFeed) AS [UnitWise Backfeed (kWh)]    
       ,SUM(BmeStatementData_UnitWiseGeneration_Metered) AS [Unit Generation Metered (kWh)]    
    ,SUM(t.BmeStatementData_UnitWiseGenerationBackFeed_Metered) AS [UnitWise Backfeed Metered (kWh)]    
    
 FROM [BmeStatementDataGenUnitHourly_SettlementProcess] t    
 JOIN #tempCdpGen3 g    
  ON t.BmeStatementData_MtGenerator_Id = g.MtGenerator_Id    
    AND t.BmeStatementData_MtGeneratorUnit_Id=g.MtGenerationUnit_Id    

   WHERE t.BmeStatementData_StatementProcessId=@StatementProcessId    
 GROUP BY BmeStatementData_MtGenerator_Id    
   ,MtGenerator_Name    
 ORDER BY MtGenerator_Name    
    
    
 SELECT     
     
      --[BmeStatementData_NtdcDateTime]    
  BmeStatementData_Month as [Month],    
  BmeStatementData_Day as [Day],    
  BmeStatementData_Hour as [Hour],    
    
       [BmeStatementData_MtGenerator_Id]    AS [Generator Id]    
        ,g.MtGenerator_Name AS  [Generator Name]    
      ,[BmeStatementData_MtGeneratorUnit_Id] AS [Generator Unit Id]    
      ,[BmeStatementData_SOUnitId] AS [SO Unit Id]    
   , g.MtGenerationUnit_UnitName as [Generation Unit Name]    
      ,[SrTechnologyType_Code] AS [Technology Code]    
      ,[BmeStatementData_InstalledCapacity_KW] AS [Installed Capacity (kW)]    
         
      ,[BmeStatementData_GenerationUnitEnergy] AS [Generation Unit Energy (kWh)]    
      ,[BmeStatementData_GenerationUnitWiseBackfeed] AS [Generation Unit Wise Backfeed (kWh)]    
      ,[BmeStatementData_GenerationUnitEnergy_Metered] AS [Generation Unit Energy Metered (kWh)]    
      ,[BmeStatementData_GenerationUnitWiseBackfeed_Metered] AS [Generation Unit Wise Backfeed Metered (kWh)]    
       
      ,[BmeStatementData_UnitWiseGeneration]    AS [Unit Wise Generation (kWh)]    
      ,[BmeStatementData_UnitWiseGenerationBackFeed]  AS [Unit Wise Generation BackFeed (kWh)]    
      ,[BmeStatementData_UnitWiseGeneration_Metered]  AS [Unit Wise Generation Metered (kWh)]    
      ,[BmeStatementData_UnitWiseGenerationBackFeed_Metered]AS [Unit Wise Generation BackFeedMetered (kWh)]    
      , case when [BmeStatementData_IsBackfeedInclude]=1 then 'Unit' else 'Line' end    AS [CDP Location]    
      
     
 FROM [BmeStatementDataGenUnitHourly_SettlementProcess] t    
  JOIN #tempCdpGen3 g    
  ON t.BmeStatementData_MtGenerator_Id = g.MtGenerator_Id    
  AND t.BmeStatementData_MtGeneratorUnit_Id=g.MtGenerationUnit_Id    
 WHERE BmeStatementData_StatementProcessId=@StatementProcessId    
 ORDER BY BmeStatementData_NtdcDateTime    
    
END  

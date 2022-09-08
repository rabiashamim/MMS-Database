/****** Object:  Procedure [dbo].[BME_GenerationEnergyInfo]    Committed by VersionSQL https://www.versionsql.com ******/

/* =============================================  
 Author:Ali Imran
 CREATE date: August 1, 2022 
 ALTER date: 
 Description:
 ============================================= */
-- [dbo].[BME_GenerationEnergyInfo] 2022,6,18
CREATE   Procedure [dbo].[BME_GenerationEnergyInfo] (

 @StatementProcessId DECIMAL(18, 0))
AS
BEGIN

	SELECT DISTINCT
		cdp.RuCDPDetail_CdpId
	   ,g.MtGenerator_Name
	   ,g.MtGenerator_Id
	   ,gu.MtGenerationUnit_Id
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
	   ,MtGenerator_Name INTO #tempCdpGen3
	FROM #tempCdpGen

	SELECT

		BmeStatementData_MtGenerator_Id AS [Generator Id]
	   ,g.MtGenerator_Name AS  [Generator]
	   ,SUM(BmeStatementData_UnitWiseGeneration) AS [Unit Generation]
	   ,SUM(BmeStatementData_UnitWiseGenerationBackFeed) AS [UnitWise Backfeed]
	      ,SUM(BmeStatementData_UnitWiseGeneration_Metered) AS [Unit Generation Metered]
	   ,SUM(t.BmeStatementData_UnitWiseGenerationBackFeed_Metered) AS [UnitWise Backfeed Metered]

	FROM [BmeStatementDataGenUnitHourly] t
	JOIN #tempCdpGen3 g
		ON t.BmeStatementData_MtGenerator_Id = g.MtGenerator_Id
	GROUP BY BmeStatementData_MtGenerator_Id
			,MtGenerator_Name
	ORDER BY MtGenerator_Name


	SELECT 
	
      --[BmeStatementData_NtdcDateTime]
		BmeStatementData_Month as [Month],
		BmeStatementData_Day as [Day],
		BmeStatementData_Hour as [Hour],

       [BmeStatementData_MtGenerator_Id]    AS [Generator Id]
      ,[BmeStatementData_MtGeneratorUnit_Id] AS [Generator Unit Id]
      ,[BmeStatementData_SOUnitId] AS [SO Unit Id]
      ,[SrTechnologyType_Code] AS [Technology Code]
      ,[BmeStatementData_InstalledCapacity_KW] AS [Installed Capacity]
     
      ,[BmeStatementData_GenerationUnitEnergy] AS [Generation Unit Energy]
      ,[BmeStatementData_GenerationUnitWiseBackfeed] AS [Generation Unit Wise Backfeed]
      ,[BmeStatementData_GenerationUnitEnergy_Metered] AS [Generation Unit Energy Metered]
      ,[BmeStatementData_GenerationUnitWiseBackfeed_Metered] AS [Generation Unit Wise Backfeed Metered]
   
      ,[BmeStatementData_UnitWiseGeneration]				AS [Unit Wise Generation]
      ,[BmeStatementData_UnitWiseGenerationBackFeed]		AS [Unit Wise Generation BackFeed]
      ,[BmeStatementData_UnitWiseGeneration_Metered]		AS [Unit Wise Generation Metered]
      ,[BmeStatementData_UnitWiseGenerationBackFeed_Metered]AS [Unit Wise Generation BackFeedMetered]
      ,[BmeStatementData_IsBackfeedInclude]					AS [Is Backfeed Include]
  
	
	FROM [BmeStatementDataGenUnitHourly] 
	WHERE BmeStatementData_StatementProcessId=@StatementProcessId
	ORDER BY BmeStatementData_NtdcDateTime

END

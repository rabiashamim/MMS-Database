/****** Object:  Procedure [dbo].[ReportMonthlyGenerationAndBackFeed]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 17 Aug 2022
--Comments : Aggregated Reports Summary
--======================================================================

-- dbo.ReportMonthlyGenerationAndBackFeed 51
CREATE PROCEDURE dbo.ReportMonthlyGenerationAndBackFeed
@pAggregatedStatementId INT=null

AS
BEGIN

Declare @pBmeSettlementProcessId as int;
set @pBmeSettlementProcessId=[dbo].[GetBMEtatementProcessIdFromASC](@pAggregatedStatementId);
/*
with cte_generation as (
select 
BmeStatementData_MtGenerator_Id ,
dbo.GetGeneratorName(BmeStatementData_MtGenerator_Id) as GeneratorName,
Sum([BmeStatementData_GenerationUnitEnergy_Metered]) AS GenerationEnergy,
Sum([BmeStatementData_GenerationUnitWiseBackfeed_Metered])  as BackFeed

 from [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess]  where BmeStatementData_StatementProcessId=@pBmeSettlementProcessId
group by BmeStatementData_MtGenerator_Id
)

select 
ROW_NUMBER() OVER(Order by GeneratorName) as [Sr],
BmeStatementData_MtGenerator_Id,
GeneratorName,
GenerationEnergy,
BackFeed
from cte_generation
order by GeneratorName
*/
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
	ROW_NUMBER() OVER(Order by t.BmeStatementData_MtGenerator_Id) as [Sr],
		BmeStatementData_MtGenerator_Id AS [BmeStatementData_MtGenerator_Id]
	   ,g.MtGenerator_Name AS  [GeneratorName]
      ,SUM(BmeStatementData_UnitWiseGeneration_Metered) AS [GenerationEnergy]
	   ,SUM(t.BmeStatementData_UnitWiseGenerationBackFeed_Metered) AS [BackFeed]

	FROM [BmeStatementDataGenUnitHourly_SettlementProcess] t
	JOIN #tempCdpGen3 g
		ON t.BmeStatementData_MtGenerator_Id = g.MtGenerator_Id
   WHERE t.BmeStatementData_StatementProcessId=@pBmeSettlementProcessId
	GROUP BY BmeStatementData_MtGenerator_Id
			,MtGenerator_Name
	ORDER BY t.BmeStatementData_MtGenerator_Id


END

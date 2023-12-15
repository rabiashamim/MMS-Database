/****** Object:  Procedure [dbo].[ReportHourlyCompensationAndAscillaryServices]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 25 Aug 2022
--Comments : ASC Reports Summary
--======================================================================

CREATE PROCEDURE dbo.ReportHourlyCompensationAndAscillaryServices
@pAggregatedStatementId INT=null

AS
BEGIN

Declare @pAscSettlementProcessId as int;
set @pAscSettlementProcessId= [dbo].[GetASCtatementProcessId] (@pAggregatedStatementId);

select 
	ROW_NUMBER() OVER (ORDER BY  GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,AscStatementData_SOUnitId) AS [Sr]
		,AscStatementData_Month AS [Month]
	   ,AscStatementData_Day AS [Day]
	   ,AscStatementData_Hour AS [Hour]
	   ,G.MtPartyRegisteration_Name AS [Generator Owner Party]
	   ,G.MtGenerator_Id AS [Generator ID]
	   ,G.MtGenerator_Name AS [Generator Name]
	   ,AscStatementData_SOUnitId AS [Generation Unit Id]
	   , AscStatementData_UnitName AS [Generation Unit Name]
	   ,GH.AscStatementData_CongestedZone AS [Congested Zone]
	   ,GH.AscStatementData_SO_MP AS [Marginal Price]
,AscStatementData_MR_EAG as [Actual Generation Mustrun(EAG)]
,AscStatementData_MR_EPG as [Potential Generation MustRun(EPG)]
,AscStatementData_SO_MR_VC as [Variable Cost MustRun(VC)]
,AscStatementData_MRC as [Must Run Compensation (MRC)]
,AscStatementData_RG_EAG as [Actual Generation RG(EAG)]
,AscStatementData_SO_AC as [Available Capacity (AC)]
,AscStatementData_SO_AC*0.95 as [Available Capacity * 0.95 (AC)]
,AscStatementData_RG_LOCC as [Lost Opportunity Cost Compensation (LOCC)]
,AscStatementData_SO_RG_VC as [Variable Cost RG(VC)]
,AscStatementData_RG_AC as [Reduced Generation Compensation]
,AscStatementData_IG_EAG as [Actual Generation IG(EAG)]
,AscStatementData_IG_EPG as [Potential Generation IG(EPG)]
,AscStatementData_IG_UPC as [Increased Generation Compensation (UPC)]
,AscStatementData_SO_IG_VC as [Variable Cost IG(VC)]
,AscStatementData_IG_AC as [Increased Generation Compensation]
,ISNULL(AscStatementData_MRC,0)+ISNULL(AscStatementData_IG_AC,0)+ISNULL(AscStatementData_RG_AC,0) as [Total Ancillary Services Compnesation (AC)]



	FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] GH
	JOIN [dbo].[ASC_GuParties] G
		ON GH.AscStatementData_SOUnitId = G.MtGenerationUnit_SOUnitId	
	WHERE GH.AscStatementData_StatementProcessId =@pAscSettlementProcessId

		and (ISNULL(AscStatementData_MRC,0)+ISNULL(AscStatementData_IG_AC,0)+ISNULL(AscStatementData_RG_AC,0) )>0
	ORDER BY  GH.AscStatementData_Month,GH.AscStatementData_Day,GH.AscStatementData_Hour,G.MtPartyRegisteration_Id,G.MtGenerator_Id,AscStatementData_SOUnitId


END

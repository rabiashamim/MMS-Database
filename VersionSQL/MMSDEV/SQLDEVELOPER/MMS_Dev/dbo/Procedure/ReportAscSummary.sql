/****** Object:  Procedure [dbo].[ReportAscSummary]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 25 Aug 2022
--Comments : ASC Reports Summary
--======================================================================
--  dbo.ReportAscSummary 240
CREATE PROCEDURE dbo.ReportAscSummary
@pAggregatedStatementId INT=null

AS
BEGIN

Declare @pSettlementProcessId as int;
set @pSettlementProcessId= [dbo].[GetASCtatementProcessId] (@pAggregatedStatementId);

DECLARE @BmeStatementProcessId decimal(18,0) = null;          
SET @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@pSettlementProcessId); 

/*

	with cte_ascSummation as (	
	SELECT 
		MZM.AscStatementData_Year
		,MZM.AscStatementData_Month 
		,SUM(MZM.AscStatementData_MRC) AS AscStatementData_MRC
		,SUM(MZM.AscStatementData_IG_AC) as AscStatementData_IG_AC
		,SUM(MZM.AscStatementData_RG_AC) as AscStatementData_RG_AC
	FROM
		[dbo].AscStatementDataMpZoneMonthly_SettlementProcess  MZM	
	WHERE MZM.AscStatementData_StatementProcessId = @pAscSettlementProcessId
	GROUP BY MZM.AscStatementData_Year, MZM.AscStatementData_Month
)

select 
ROW_NUMBER() OVER(Order by AscStatementData_Id) as [Sr],
MZM.AscStatementData_Month as [Month],
MZM.AscStatementData_PartyRegisteration_Id as [Party ID],
MZM.AscStatementData_PartyName as [Party Name],
MZM.AscStatementData_CongestedZone as [Congested Zone],
--MZM.AscStatementData_MRC as [Must Run Compensation],
--AscStatementData_IG_AC as [Increased Generation Compensation],
--AscStatementData_RG_AC as [Reduced Generation Compensation],
case when MZM.AscStatementData_PartyRegisteration_Id=1 then CTE.AscStatementData_MRC else null end as [Must Run Compensation]
,case when MZM.AscStatementData_PartyRegisteration_Id=1 then CTE.AscStatementData_IG_AC else null end as [Increased Generation Compensation]
,case when MZM.AscStatementData_PartyRegisteration_Id=1 then CTE.AscStatementData_RG_AC else null end as [Reduced Generation Compensation]
,AscStatementData_GS_SC as [Startup cost]
,MZM.AscStatementData_GBS_BSC as [Black start charges],
MZM.AscStatementData_ES as [Energy Withdrawal with Transmission Loss],

--MZM.AscStatementData_PAYABLE as [Payable],
--MZM.AscStatementData_RECEIVABLE  as [Receivable],

Case when AscStatementData_PartyRegisteration_Id=1 then NULL
ELSE Format(AscStatementData_SOLR_ETB_Legacy,'N') 
end as [Payable],

Case when AscStatementData_PartyRegisteration_Id=1 then null 
ELSE ISNULL(MZM.AscStatementData_RECEIVABLE,0)+ISNULL(AscStatementData_LegacyShareInReceiveable,0)
end  as [Receivable]


,Case when AscStatementData_PartyRegisteration_Id=1 then null else AscStatementData_ES end as [Energy Contracted with Legacy Generators],
AscStatementData_TP_SOLR as [Share in Payable to Legacy Generators],

Case when AscStatementData_PartyRegisteration_Id=1 then null else ISNULL(MZM.AscStatementData_TP_SOLR,0)-ISNULL(MZM.AscStatementData_RECEIVABLE,0) end as [Share in Receivables from Legacy Generators],
Case when AscStatementData_PartyRegisteration_Id=1 then null else ISNULL(MZM.AscStatementData_PAYABLE,0)+ISNULL(MZM.AscStatementData_TP_SOLR,0) end as [Total Payable],
Case when AscStatementData_PartyRegisteration_Id=1 then null else ISNULL(MZM.AscStatementData_RECEIVABLE,0)+ISNULL(MZM.AscStatementData_TP_SOLR,0)-ISNULL(MZM.AscStatementData_RECEIVABLE,0) end  as [Total Receivable]

from [dbo].AscStatementDataMpZoneMonthly_SettlementProcess MZM
	join cte_ascSummation CTE on CTE.AscStatementData_Year=MZM.AscStatementData_YEAR
	and CTE.AscStatementData_Month=MZM.AscStatementData_Month
where MZM.AscStatementData_StatementProcessId=@pAscSettlementProcessId


*/

 SELECT  BmeStatementData_Year
		,BmeStatementData_Month
         ,BmeStatementData_PartyRegisteration_Id
		,BmeStatementData_CongestedZoneID--, BmeStatementData_ES
		,SUM(BmeStatementData_EnergySuppliedActual)  as BmeStatementData_EnergySuppliedActual
INTO #EnergySuppliedActual
 FROM BmeStatementDataMpCategoryHourly_SettlementProcess 
 WHERE BmeStatementData_StatementProcessId=@BmeStatementProcessId
 GROUP BY 
  BmeStatementData_Year
		,BmeStatementData_Month
         ,BmeStatementData_PartyRegisteration_Id
		,BmeStatementData_CongestedZoneID--, BmeStatementData_ES



 /**taski id 3933 * date 27-sep-2023*/
 SELECT BmeStatementData_BuyerPartyRegisteration_Id, SUM(BmeStatementData_EnergyTradedBought) AS BmeStatementData_EnergyTradedBought
 INTO #BmeStatementData_EnergyTradedBought_MPWise
FROM BmeStatementDataMpContractHourly_SettlementProcess    
WHERE BmeStatementData_StatementProcessId=@BmeStatementProcessId
AND BmeStatementData_SellerPartyRegisteration_Id=1 -- only for leagacy
GROUP BY BmeStatementData_BuyerPartyRegisteration_Id;

	with cte_ascSummation as (	
	SELECT 
		MZM.AscStatementData_Year
		,MZM.AscStatementData_Month 
		,SUM(MZM.AscStatementData_MRC) AS AscStatementData_MRC
		,SUM(MZM.AscStatementData_IG_AC) as AscStatementData_IG_AC
		,SUM(MZM.AscStatementData_RG_AC) as AscStatementData_RG_AC
	FROM
		[dbo].AscStatementDataMpZoneMonthly_SettlementProcess  MZM	
	WHERE MZM.AscStatementData_StatementProcessId = @pSettlementProcessId
	GROUP BY MZM.AscStatementData_Year, MZM.AscStatementData_Month
)

select 
ROW_NUMBER() OVER(Order by AscStatementData_PartyRegisteration_Id) as [Sr],
MZM.AscStatementData_Month as [Month],
MZM.AscStatementData_PartyRegisteration_Id as [Party ID],
MZM.AscStatementData_PartyName as [Party Name],
MZM.AscStatementData_CongestedZone as [Congested Zone],
case when MZM.AscStatementData_PartyRegisteration_Id=1 then Format(CTE.AscStatementData_MRC,'N')  else null end as [Must Run Compensation]
,case when MZM.AscStatementData_PartyRegisteration_Id=1 then Format(CTE.AscStatementData_IG_AC,'N')  else null end as [Increased Generation Compensation]
,case when MZM.AscStatementData_PartyRegisteration_Id=1 then Format(CTE.AscStatementData_RG_AC,'N')  else null end as [Reduced Generation Compensation]
,Format(AscStatementData_GS_SC,'N')  as [Startup cost]
,Format(MZM.AscStatementData_GBS_BSC,'N')  as [Black start charges],
--Format(MZM.AscStatementData_ES,'N')  as [Energy Withdrawal with Transmission Loss (kWh)],
Format(ESA.BmeStatementData_EnergySuppliedActual,'N')  as [Energy Withdrawal with Transmission Loss],
Format(MZM.AscStatementData_PAYABLE,'N')  as [Payable],
Format(MZM.AscStatementData_RECEIVABLE,'N')  as [Receivable],
--Case when AscStatementData_PartyRegisteration_Id=1 then null else Format(AscStatementData_ES,'N')  end as [Energy Contracted with Legacy Generators (kWh)],
Case when AscStatementData_PartyRegisteration_Id=1 then null else Format(MPWISE.BmeStatementData_EnergyTradedBought,'N')  end as [Energy Contracted with Legacy Generators],

--Format(AscStatementData_TP_SOLR,'N')  as [Share in Payable to Legacy Generators (PKR)],
Format(AscStatementData_SOLR_ETB_Legacy,'N')  as [Share in Payable to Legacy Generators],

--Case when AscStatementData_PartyRegisteration_Id=1 then null else Format( ISNULL(MZM.AscStatementData_TP_SOLR,0)-ISNULL(MZM.AscStatementData_RECEIVABLE,0),'N')  
--end as [Share in Receivables from Legacy Generators (PKR)] ,

Case when AscStatementData_PartyRegisteration_Id=1 then null 
else AscStatementData_LegacyShareInReceiveable
end as [Share in Receivables from Legacy Generators] ,




Case when AscStatementData_PartyRegisteration_Id=1 then NULL
--else Format( ISNULL(MZM.AscStatementData_PAYABLE,0)+ISNULL(MZM.AscStatementData_TP_SOLR,0),'N') 
ELSE Format(AscStatementData_SOLR_ETB_Legacy,'N') 
end as [Total Payable],

Case when AscStatementData_PartyRegisteration_Id=1 then null 
--else Format( ISNULL(MZM.AscStatementData_RECEIVABLE,0)+ISNULL(MZM.AscStatementData_TP_SOLR,0)-ISNULL(MZM.AscStatementData_RECEIVABLE,0),'N') 
ELSE ISNULL(MZM.AscStatementData_RECEIVABLE,0)+ISNULL(AscStatementData_LegacyShareInReceiveable,0)
end  as [Total Receivable]

from [dbo].AscStatementDataMpZoneMonthly_SettlementProcess MZM
	join cte_ascSummation CTE on CTE.AscStatementData_Year=MZM.AscStatementData_YEAR
	and CTE.AscStatementData_Month=MZM.AscStatementData_Month
	JOIN #EnergySuppliedActual ESA ON ESA.BmeStatementData_Year=MZM.AscStatementData_Year
	AND ESA.BmeStatementData_Month=MZM.AscStatementData_Month
	AND ESA.BmeStatementData_PartyRegisteration_Id=MZM.AscStatementData_PartyRegisteration_Id
	AND ESA.BmeStatementData_CongestedZoneID=MZM.AscStatementData_CongestedZoneID
	LEFT JOIN #BmeStatementData_EnergyTradedBought_MPWise MPWISE ON MZM.AscStatementData_PartyRegisteration_Id=MPWISE.BmeStatementData_BuyerPartyRegisteration_Id 
where MZM.AscStatementData_StatementProcessId=@pSettlementProcessId
order by AscStatementData_PartyRegisteration_Id



END

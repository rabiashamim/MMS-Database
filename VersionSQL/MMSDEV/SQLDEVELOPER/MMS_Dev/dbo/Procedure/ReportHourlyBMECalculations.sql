/****** Object:  Procedure [dbo].[ReportHourlyBMECalculations]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 17 Aug 2022
--Comments : Aggregated Reports Summary
--======================================================================

--  dbo.ReportHourlyBMECalculations 19
CREATE PROCEDURE dbo.ReportHourlyBMECalculations
@pAggregatedStatementId INT=null,
@pPartyId INT=null

AS
BEGIN

Declare @pBmeSettlementProcessId as int;
set @pBmeSettlementProcessId=[dbo].[GetBMEtatementProcessIdFromASC](@pAggregatedStatementId);

select   ROW_NUMBER() OVER(Order by BmeStatementData_Month,BmeStatementData_PartyRegisteration_Id, BmeStatementData_Day, BmeStatementData_Hour) as [Sr],
BmeStatementData_Month as [Month],
BmeStatementData_Day as [Day],
BmeStatementData_Hour as [Hour],
BmeStatementData_PartyName as [MP Name],
BmeStatementData_PartyRegisteration_Id as [MP ID],
isNULL(BmeStatementData_ActualEnergy_Metered,0) as [Hourly Inc Metered Energy (Act_E) (kWh)],
isNULL(BmeStatementData_ActualEnergy,0) as [Hourly Adjusted Energy (Act_E) (kWh)],
isNULL(BmeStatementData_EnergySuppliedActual,0) as [Hourly  Energy Supplied (ES_A (kWh)],
isNULL(BmeStatementData_EnergySuppliedGenerated,0) as [Hourly  Generation (ES_G)],
isNULL(BmeStatementData_EnergySuppliedImported,0) as [Hourly Imported Energy (ES_I (kWh))] ,
isNULL(BmeStatementData_CAPLegacy,0) AS [CAP],
isNULL(BmeStatementData_EnergyTradedBought,0) AS [EnergyTradedBought],	
isNULL(BmeStatementData_EnergyTradedSold,0) AS [EnergyTradedSold],
isNULL(BmeStatementData_EnergyTraded,0) as [Hourly Contracted Energy (ET) (kWh)], 
isNULL(BmeStatementData_Imbalance,0) as [Energy Imbalance (kWh)],
isNULL(BmeStatementData_MarginalPrice,0) AS [Marginal Price],
isNULL(BmeStatementData_ImbalanceCharges,0) as [Imbalance Charges (PKR)]
from BmeStatementDataMpHourly_SettlementProcess
where BmeStatementData_StatementProcessId=@pBmeSettlementProcessId
AND
(@pPartyId is NULL or BmeStatementData_PartyRegisteration_Id=@pPartyId)
Order by BmeStatementData_Month, BmeStatementData_PartyRegisteration_Id, BmeStatementData_Day, BmeStatementData_Hour;

END

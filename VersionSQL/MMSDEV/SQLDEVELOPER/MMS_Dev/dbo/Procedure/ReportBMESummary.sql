/****** Object:  Procedure [dbo].[ReportBMESummary]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 17 Aug 2022
--Comments : Aggregated Reports Summary
--======================================================================

-- dbo.ReportBMESummary 19
CREATE PROCEDURE dbo.ReportBMESummary
@pAggregatedStatementId INT=null

AS
BEGIN

Declare @pBmeSettlementProcessId as int;
set @pBmeSettlementProcessId=[dbo].[GetBMEtatementProcessIdFromASC](@pAggregatedStatementId);

WITH CTE_tempStep10 as(
select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],
 MPM.BmeStatementData_Month as [Month],
MPM.BmeStatementData_PartyName as [MP Name],
MPM.BmeStatementData_PartyRegisteration_Id as [MP ID],
floor(isnull(
(select SUM(MPH.BmeStatementData_ActualEnergy_Metered) from BmeStatementDataMpHourly_SettlementProcess MPH where MPH.BmeStatementData_StatementProcessId=@pBmeSettlementProcessId and MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id and MPH.BmeStatementData_Month=MPM.BmeStatementData_Month
GROUP by MPH.BmeStatementData_PartyRegisteration_Id, MPH.BmeStatementData_Month
),0)) as [Actual Energy (kW)],

floor(isnull(
(select SUM(MPH.BmeStatementData_ActualEnergy) from BmeStatementDataMpHourly_SettlementProcess MPH where MPH.BmeStatementData_StatementProcessId=@pBmeSettlementProcessId and MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id and MPH.BmeStatementData_Month=MPM.BmeStatementData_Month
GROUP by MPH.BmeStatementData_PartyRegisteration_Id, MPH.BmeStatementData_Month
),0)) as [Adjusted Energy (kW)],


floor(isnull(
(select SUM(MPH.BmeStatementData_EnergySuppliedActual) from BmeStatementDataMpHourly_SettlementProcess MPH where MPH.BmeStatementData_StatementProcessId=@pBmeSettlementProcessId and MPH.BmeStatementData_PartyRegisteration_Id=MPM.BmeStatementData_PartyRegisteration_Id and MPH.BmeStatementData_Month=MPM.BmeStatementData_Month
GROUP by MPH.BmeStatementData_PartyRegisteration_Id, MPH.BmeStatementData_Month
),0)) as [Energy Supplied (kW)],




floor(isNull(MPM.BmeStatementData_SettlementOfLegacy ,0)) as [Settlement of Legacy (PKR)],
floor(isnull(MPM.BmeStatementData_ImbalanceCharges,0)) as [Imbalance Charges (PKR)],
floor(isnull(MPM.BmeStatementData_AmountPayableReceivable,0)) as [Amount Payable / Amount Receivable (PKR)]
 from BmeStatementDataMpMonthly_SettlementProcess MPM
where MPM.BmeStatementData_StatementProcessId=@pBmeSettlementProcessId
)
SELECT * from CTE_tempStep10
order by case when [Sr] is null then 1 else 0 end, [Sr];


END

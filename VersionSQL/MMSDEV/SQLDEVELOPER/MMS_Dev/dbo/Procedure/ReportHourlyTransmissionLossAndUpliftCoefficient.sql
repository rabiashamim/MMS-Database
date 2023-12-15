/****** Object:  Procedure [dbo].[ReportHourlyTransmissionLossAndUpliftCoefficient]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 25 Aug 2022
--Comments : Hourly Transmission Loss, Total Demand and Uplift Coefficient
--======================================================================

CREATE PROCEDURE dbo.ReportHourlyTransmissionLossAndUpliftCoefficient
@pAggregatedStatementId INT=null
AS
BEGIN

Declare @pBmeSettlementProcessId as int;
set @pBmeSettlementProcessId=[dbo].[GetBMEtatementProcessIdFromASC](@pAggregatedStatementId);

 select 
ROW_NUMBER() OVER(Order by BmeStatementData_Month,BmeStatementData_Day, BmeStatementData_Hour) as [Sr],
 BmeStatementData_Month,BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_UpliftTransmissionLosses, BmeStatementData_DemandedEnergy, BmeStatementData_TransmissionLosses from BmeStatementDataHourly_SettlementProcess
 where BmeStatementData_StatementProcessId=@pBmeSettlementProcessId
 order by BmeStatementData_Month,BmeStatementData_Day, BmeStatementData_Hour
END

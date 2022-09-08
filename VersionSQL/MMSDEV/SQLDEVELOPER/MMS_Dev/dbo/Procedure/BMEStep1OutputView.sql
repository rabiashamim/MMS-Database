/****** Object:  Procedure [dbo].[BMEStep1OutputView]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[BMEStep1OutputView]
@pSettlementProcessId int
AS
BEGIN

select top 10 @@rowcount as [Sr],BmeStatementData_NtdcDateTime as Date, 
BmeStatementData_CdpId as [Cdp_Id], BmeStatementData_AdjustedEnergyImport as [Energy_Import], BmeStatementData_IncEnergyExport as [Energy_Export], BmeStatementData_LineVoltage as [Line_Voltage], BmeStatementData_FromPartyRegisteration_Name as [Connected_From], BmeStatementData_ToPartyRegisteration_Name as [Connected_To]  from BmeStatementDataCdpHourly_SettlementProcess where BmeStatementData_SettlementProcessId=@pSettlementProcessId
END

/****** Object:  Procedure [dbo].[ReportAggregatedStatementSummary]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 17 Aug 2022
--Comments : Aggregated Reports Summary
--======================================================================

-- dbo.ReportAggregatedStatementSummary 27
CREATE PROCEDURE dbo.ReportAggregatedStatementSummary
@pAggregatedStatementId INT=null

AS
BEGIN

select 
distinct
ROW_NUMBER() OVER(Order by StatementDataAggregated_PartyRegisteration_Id) as [Sr]
,StatementDataAggregated_PartyRegisteration_Id as [Market Participant Id]
,StatementDataAggregated_PartyName as [Market Participant Name]
,ISNULL(StatementDataAggregated_BmeStatementData_AmountPayableReceivable,0) as [Balancing Mechanism For Energy Charges(BME)]
--,ISNULL( StatementDataAggregated_AscStatementData_PAYABLE,0) as [Anscillary Service Charge(Payable)]
--,ISNULL(StatementDataAggregated_AscStatementData_RECEIVABLE,0) as [Anscillary Service Charge(Receivable)]
,ISNULL(StatementDataAggregated_AscStatementData_PAYABLE,0)-
ISNULL( StatementDataAggregated_AscStatementData_RECEIVABLE,0) as [Ancillary Services Charges]
,ISNULL(StatementDataAggregated_NetAmount,0) as [Net Amount]
,'-' as [Market Operator Fee]
,'-' as [Other Charges Payable]
,'-' as [Adjustement from ESS]

from StatementDataAggregated 
where MtStatementProcess_ID=@pAggregatedStatementId
and isnull(StatementDataAggregated_IsDeleted,0)=0
and StatementDataAggregated_PartyRegisteration_Id<>1
END

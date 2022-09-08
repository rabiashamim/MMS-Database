/****** Object:  Procedure [dbo].[BMEImbalances]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[BMEImbalances]
@pSettlementProcessId int
AS
BEGIN

EXEC [dbo].[BMEImbalancesFinalOutputs] @pSettlementProcessId=@pSettlementProcessId;

DROP Table if EXISTS #TEMP

select BmeStatementData_Id as Id1, 
ROW_NUMBER() OVER(ORDER BY BmeStatementData_Id ASC) AS Id, BmeStatementData_Year ,	BmeStatementData_Month,	BmeStatementData_PartyRegisteration_Id as MPId,	BmeStatementData_PartyName as MPName,	--BmeStatementData_PartyCategory_Code,	
BmeStatementData_PartyType_Code,	BmeStatementData_ImbalanceCharges as BMECharges,	BmeStatementData_SettlementOfLegacy,	BmeStatementData_AmountPayableReceivable ,AncillaryServicePayableCharges,	AncillaryServiceReceivableCharges,	MOFee,	OtherChargesPaybale,	AdjustmentfromESS	,NetAmountPayableReceivable
into #temp
from [dbo].[BmeStatementDataFinalOutputs] where MtStatementProcess_ID=@pSettlementProcessId
 order by 1 ASC


 select	(select t1.Id from #temp t1 where t1.Id <> (select max(t2.Id) from #temp t2) and t1.Id1 =t.Id1) as Id,Id1,	BmeStatementData_Year,	BmeStatementData_Month,	MPId,	MPName,	--BmeStatementData_PartyCategory_Code,
 BmeStatementData_PartyType_Code,	BMECharges	,BmeStatementData_SettlementOfLegacy,	BmeStatementData_AmountPayableReceivable,	AncillaryServicePayableCharges,	AncillaryServiceReceivableCharges,	MOFee	,OtherChargesPaybale,	AdjustmentfromESS,	NetAmountPayableReceivable from #temp t

-- select * from #temp


--select BmeStatementData_Id as Id, BmeStatementData_Year ,	BmeStatementData_Month,	BmeStatementData_PartyRegisteration_Id as MPId,	BmeStatementData_PartyName as MPName,	BmeStatementData_PartyCategory_Code,	BmeStatementData_PartyType_Code,	BmeStatementData_ImbalanceCharges as BMECharges,	BmeStatementData_SettlementOfLegacy,	BmeStatementData_AmountPayableReceivable ,AncillaryServicePayableCharges,	AncillaryServiceReceivableCharges,	MOFee,	OtherChargesPaybale,	AdjustmentfromESS	,NetAmountPayableReceivable

--from [dbo].[BmeStatementDataFinalOutputs] where MtStatementProcess_ID=@pSettlementProcessId
-- order by 1 ASC

END

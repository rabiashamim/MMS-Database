/****** Object:  Procedure [dbo].[BMEImbalancesFinalOutputs]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[BMEImbalancesFinalOutputs]
@pSettlementProcessId int,
@pYear int=null,
@pMonth int=null
AS
BEGIN

select @pMonth=LuAccountingMonth_Month, @pYear=LuAccountingMonth_Year from LuAccountingMonth where LuAccountingMonth_Id in (
select LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pSettlementProcessId
)

     IF  EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataFinalOutputs 
     WHERE  [BmeStatementData_Year] = @pYear and [BmeStatementData_Month] = @pMonth)
    BEGIN
	DELETE from BmeStatementDataFinalOutputs where  [BmeStatementData_Year] = @pYear and [BmeStatementData_Month] = @pMonth;
	END

INSERT INTO [dbo].[BmeStatementDataFinalOutputs]
           ([MtStatementProcess_ID]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_PartyRegisteration_Id]
           ,[BmeStatementData_PartyName]
--           ,[BmeStatementData_PartyCategory_Code]
           ,[BmeStatementData_PartyType_Code]
           ,[BmeStatementData_ImbalanceCharges]
           ,[BmeStatementData_SettlementOfLegacy]
           ,[BmeStatementData_AmountPayableReceivable])

select @pSettlementProcessId	,BmeStatementData_Year,	BmeStatementData_Month,	BmeStatementData_PartyRegisteration_Id,	BmeStatementData_PartyName,	
--BmeStatementData_PartyCategory_Code,	
BmeStatementData_PartyType_Code,	BmeStatementData_ImbalanceCharges,	BmeStatementData_SettlementOfLegacy,	BmeStatementData_AmountPayableReceivable from BmeStatementDataMpMonthly where BmeStatementData_Year=@pYear and BmeStatementData_Month=@pMonth
and BmeStatementData_PartyRegisteration_Id not in (1206,1211);

INSERT INTO [dbo].[BmeStatementDataFinalOutputs]
           ([MtStatementProcess_ID],
		   [BmeStatementData_PartyName]
           ,[BmeStatementData_ImbalanceCharges]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           )
VALUES(@pSettlementProcessId,'Total',0.00,@pYear, @pMonth)


--select @pSettlementProcessId,'Total', 
--0
----sum([BmeStatementData_ImbalanceCharges])
--,@pYear, @pMonth from BmeStatementDataMpMonthly where BmeStatementData_Year=@pYear and BmeStatementData_Month=@pMonth
--and BmeStatementData_PartyRegisteration_Id not in (1206,1211);


END


--select BmeStatementData_PartyRegisteration_Id,BmeStatementData_PartyName,BmeStatementData_AmountPayableReceivable from BmeStatementDataMpMonthly

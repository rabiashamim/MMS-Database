/****** Object:  Procedure [dbo].[RollBacksettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[RollBacksettlementProcess]
	@Year int,
	@Month int,
    @StatementProcessId decimal(18,0)
AS
BEGIN
select 1;

DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId
--DELETE from MtSattlementProcessLogs where MtStatementProcess_ID=@psettlementProcessId
delete from [dbo].[BmeStatementDataFinalOutputs_SettlementProcess] where MtStatementProcess_ID=@StatementProcessId
	
    DELETE FROM BmeStatementDataMpCategoryMonthly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
	DELETE FROM BmeStatementDataMpCategoryHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM [BmeStatementDataMpMonthly_SettlementProcess] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataMpContractHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataCdpContractHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataMpHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataTspHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataGenUnitHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
	DELETE FROM BmeStatementDataCdpHourly_SettlementProcess WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataCdpOwnerParty_SettlementProcess WHERE  BmeStatementData_StatementProcessId=@StatementProcessId;
  

--DELETE FROM MtSattlementProcessLogs WHERE MtStatementProcess_ID = @psettlementProcessId;

	--INSERT INTO MtSattlementProcessLogs VALUES (@StatementProcessId, 'Rolled Back BME Process on ' +CONVERT(VARCHAR,GETDATE(),20), 1, GETDATE(), 1, GETDATE());


END

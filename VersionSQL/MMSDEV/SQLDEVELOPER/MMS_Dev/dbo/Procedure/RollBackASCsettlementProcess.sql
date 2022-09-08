/****** Object:  Procedure [dbo].[RollBackASCsettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[RollBackASCsettlementProcess] 
@Year int,
	@Month int,
    @StatementProcessId decimal(18,0)
AS
BEGIN
select 1;
DECLARE @BmeStatementProcessId DECIMAL(18,0) = NULL;
SELECT top 1 @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@StatementProcessId);

	DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId
    DELETE FROM [dbo].[AscStatementDataMpMonthly_SettlementProcess]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId= @StatementProcessId
    DELETE FROM [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId
	DELETE FROM [dbo].[AscStatementDataZoneMonthly_SettlementProcess]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId
	DELETE FROM [dbo].[AscStatementDataGenMonthly_SettlementProcess]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId
	DELETE FROM [dbo].[AscStatementDataGuMonthly_SettlementProcess]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId
    DELETE FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId
    DELETE FROM [dbo].[AscStatementDataCdpGuParty_SettlementProcess] WHERE AscStatementData_StatementProcessId= @StatementProcessId
	
	DELETE FROM BmeStatementDataMpCategoryHourly_SettlementProcess WHERE BmeStatementData_Month = @Month AND BmeStatementData_Year = @Year AND BmeStatementData_StatementProcessId = @BmeStatementProcessId;
	DELETE FROM BmeStatementDataMpCategoryMonthly_SettlementProcess WHERE BmeStatementData_Month = @Month AND BmeStatementData_Year = @Year AND BmeStatementData_StatementProcessId = @BmeStatementProcessId;


--DELETE FROM MtSattlementProcessLogs WHERE MtStatementProcess_ID = @psettlementProcessId;

--INSERT INTO MtSattlementProcessLogs VALUES (@StatementProcessId, 'Rolled Back ASC Process on ' +CONVERT(VARCHAR,GETDATE(),20), 1, GETDATE(), 1, GETDATE());

SELECT 1;

END

/****** Object:  Procedure [dbo].[RollBackASCsettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

    
CREATE PROCEDURE dbo.RollBackASCsettlementProcess     
@Year int,    
 @Month int,    
    @StatementProcessId decimal(18,0)    
AS    
BEGIN    
select 1;    
DECLARE @BmeStatementProcessId DECIMAL(18,0) = NULL;    
SELECT top 1 @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@StatementProcessId);    
    
 DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId    
    DELETE FROM [dbo].[AscStatementDataMpMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId= @StatementProcessId    
    DELETE FROM [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId    
 DELETE FROM [dbo].[AscStatementDataZoneMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId    
 DELETE FROM [dbo].[AscStatementDataGenMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month  and AscStatementData_StatementProcessId=@StatementProcessId    
 DELETE FROM [dbo].[AscStatementDataGuMonthly_SettlementProcess] WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId    
    DELETE FROM [dbo].[AscStatementDataGuHourly_SettlementProcess] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId    
    DELETE FROM [dbo].[AscStatementDataCdpGuParty_SettlementProcess] WHERE AscStatementData_StatementProcessId= @StatementProcessId    
     
 DELETE FROM BmeStatementDataMpCategoryHourly_SettlementProcess WHERE BmeStatementData_Month = @Month AND BmeStatementData_Year = @Year AND BmeStatementData_StatementProcessId = @BmeStatementProcessId;    
 DELETE FROM BmeStatementDataMpCategoryMonthly_SettlementProcess WHERE BmeStatementData_Month = @Month AND BmeStatementData_Year = @Year AND BmeStatementData_StatementProcessId = @BmeStatementProcessId;    
    
DECLARE @moduleid INT = 0;
SELECT
	@moduleid = SrProcessDef_ID
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @StatementProcessId
DECLARE @name NVARCHAR(MAX);
SELECT
	@name = CONCAT(SrProcessDef_Name, '-', SrStatementDef_Name)
FROM MtStatementProcess
INNER JOIN SrProcessDef
	ON SrProcessDef.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID
INNER JOIN SrStatementDef
	ON SrStatementDef.SrStatementDef_ID = SrProcessDef.SrStatementDef_ID
WHERE MtStatementProcess_ID = @StatementProcessId
AND SrProcessDef.SrProcessDef_ID = @moduleid
DECLARE @vMonthId_Current VARCHAR(MAX);
SELECT
	@vMonthId_Current = LuAccountingMonth_Id_Current
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @StatementProcessId

DECLARE @StatementProcessId1 VARCHAR(20);
SET @StatementProcessId1 = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
      
  declare @output VARCHAR(max);
SET @output = 'Process Execution Roll-Backed:' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @StatementProcessId1)
SELECT
	@output
EXEC [dbo].[SystemLogs] @moduleName = 'Settlements'
					   ,@CrudOperationName = 'Update'
					   ,@logMessage = @output
--DELETE FROM MtSattlementProcessLogs WHERE MtStatementProcess_ID = @psettlementProcessId;    
    
--INSERT INTO MtSattlementProcessLogs VALUES (@StatementProcessId, 'Rolled Back ASC Process on ' +CONVERT(VARCHAR,GETDATE(),20), 1, GETDATE(), 1, GETDATE());    
    
SELECT 1;    
    
END 

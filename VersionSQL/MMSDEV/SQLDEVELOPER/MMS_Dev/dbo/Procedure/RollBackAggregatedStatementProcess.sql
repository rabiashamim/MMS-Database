/****** Object:  Procedure [dbo].[RollBackAggregatedStatementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

    
--dbo.RollBackAggregatedStatementProcess  38    
CREATE PROCEDURE dbo.RollBackAggregatedStatementProcess    
@StatementProcessId INT,    
@Month INT = NULL,    
@Year INT = null    
AS    
BEGIN    
    
DELETE from  StatementDataAggregated where MtStatementProcess_ID=@StatementProcessId    
DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId    
    
    
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
    
select @@rowcount;    
--INSERT INTO MtSattlementProcessLogs VALUES (@StatementProcessId, 'Rolled Back Aggregated Statement Process Process on ' +CONVERT(VARCHAR,GETDATE(),20), 1, GETDATE(), 1, GETDATE());    
    
    
END 

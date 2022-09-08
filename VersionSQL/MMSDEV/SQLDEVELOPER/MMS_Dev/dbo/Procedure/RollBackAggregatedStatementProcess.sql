/****** Object:  Procedure [dbo].[RollBackAggregatedStatementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[RollBackAggregatedStatementProcess]  38
CREATE PROCEDURE [dbo].[RollBackAggregatedStatementProcess]
@StatementProcessId INT,
@Month INT = NULL,
@Year INT = null
AS
BEGIN

DELETE from  StatementDataAggregated where MtStatementProcess_ID=@StatementProcessId
DELETE from MtStatementProcessSteps where MtStatementProcess_ID=@StatementProcessId

select @@rowcount;
--INSERT INTO MtSattlementProcessLogs VALUES (@StatementProcessId, 'Rolled Back Aggregated Statement Process Process on ' +CONVERT(VARCHAR,GETDATE(),20), 1, GETDATE(), 1, GETDATE());


END

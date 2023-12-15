/****** Object:  Procedure [dbo].[EtlRollback]    Committed by VersionSQL https://www.versionsql.com ******/

      
--==========================================================================================      
-- Author: Ammama Gill      
-- CREATE date: 16 Jan 2023      
-- ALTER date:          
-- Description:                     
--==========================================================================================      
      
CREATE   PROCEDURE dbo.EtlRollback 
(
@StatementProcessId DECIMAL(18, 0),
@pUserId int=null
)      
AS      
BEGIN      
 SET NOCOUNT ON;       
      
 EXEC EtlClearData @StatementProcessId          
 SELECT      
  1;      
    
	--------------------
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
END 

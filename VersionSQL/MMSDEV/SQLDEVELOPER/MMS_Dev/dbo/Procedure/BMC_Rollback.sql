/****** Object:  Procedure [dbo].[BMC_Rollback]    Committed by VersionSQL https://www.versionsql.com ******/

              
--==========================================================================================              
-- Author: Ammama Gill| Alina              
-- CREATE date: 23 Dec 2022              
-- ALTER date:    09-Feb-2023              
-- Description:                             
--==========================================================================================              
             
CREATE PROCEDURE dbo.BMC_Rollback (@StatementProcessId DECIMAL(18, 0), @pUserId decimal(18,0) = NULL)       
AS              
BEGIN      
SET NOCOUNT ON;      
      
EXEC [BMCClearData] @StatementProcessId      
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
SET @output = 'Process Execution Roll-Backed:' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @StatementProcessId1) + ', SettlementProcessId: ' +CAST(@StatementProcessId AS VARCHAR(20))      
--SELECT      
-- @output      
EXEC [dbo].[SystemLogs] @user = @pUserId      
  ,@moduleName = 'Settlements'      
        ,@CrudOperationName = 'Update'      
        ,@logMessage = @output      
--BEGIN TRY              
-- SELECT 20;              
--END TRY              
      
--BEGIN CATCH              
-- DECLARE @vErrorMessage VARCHAR(MAX) = '';              
-- SELECT              
--  @vErrorMessage = 'BMC Process Rollback Error: ' + ERROR_MESSAGE();              
-- RAISERROR (@vErrorMessage, 16, -1);              
      
--END CATCH              
END

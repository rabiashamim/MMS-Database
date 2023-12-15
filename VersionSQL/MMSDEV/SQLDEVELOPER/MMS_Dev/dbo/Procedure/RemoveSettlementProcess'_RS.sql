/****** Object:  Procedure [dbo].[RemoveSettlementProcess'_RS]    Committed by VersionSQL https://www.versionsql.com ******/

create   PROCEDURE dbo.RemoveSettlementProcess'_RS          
@pSettlementProcessId Decimal(18,0)    
,@pUserId int =0  
AS          
BEGIN  
          
if exists (SELECT  
  1  
 FROM MtStatementProcess  
 WHERE MtStatementProcess_ID = @pSettlementProcessId  
 AND MtStatementProcess_ApprovalStatus != 'Draft')  
BEGIN  
SELECT  
 -1 error_code  
   ,'Process is in Approval, Can not be deleted'  
END  
ELSE  
BEGIN  
UPDATE MtStatementProcess  
SET MtStatementProcess_IsDeleted = 1  
WHERE MtStatementProcess_ID = @pSettlementProcessId  
SELECT  
 1 error_code  
   ,'Process deleted Successfully'  
  
DECLARE @name NVARCHAR(MAX);  
SELECT  
 @name = CONCAT(SrProcessDef_Name, '-', SrStatementDef_Name)  
FROM MtStatementProcess  
INNER JOIN SrProcessDef  
 ON SrProcessDef.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID  
INNER JOIN SrStatementDef  
 ON SrStatementDef.SrStatementDef_ID = SrProcessDef.SrStatementDef_ID  
WHERE MtStatementProcess_ID = @pSettlementProcessId  
DECLARE @pSettlementProcessId1 VARCHAR(20);  
DECLARE @output VARCHAR(MAX)  
    ,@vMonthId_Current VARCHAR(MAX);  
SELECT  
 @vMonthId_Current = LuAccountingMonth_Id_Current  
FROM MtStatementProcess  
WHERE MtStatementProcess_ID = @pSettlementProcessId  
SET @pSettlementProcessId1 = [dbo].[GetSettlementMonthYear](@vMonthId_Current)  
SET @output = 'Process removed ' + @name + ' ,Settlement Period:' + CONVERT(VARCHAR(MAX), @pSettlementProcessId1) + ', SettlementProcessId: ' +@pSettlementProcessId  
  print 'ok'
EXEC [dbo].[SystemLogs] @moduleName = 'Settlements'  
        ,@CrudOperationName = 'Delete'  
        ,@logMessage = @output  
        ,@user = @pUserId  
  
END  
END  

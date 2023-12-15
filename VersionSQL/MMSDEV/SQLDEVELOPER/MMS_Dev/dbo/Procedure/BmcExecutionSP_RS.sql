/****** Object:  Procedure [dbo].[BmcExecutionSP_RS]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================        
-- Author: Sadaf Malik| AMMAMA Gill| Alina Javed        
-- CREATE date: 28 Dec 2022        
-- ALTER date:            
-- Description:                       
--==========================================================================================         
-- [BmcExecutionSP] 133,'2022 - 2023',1              
CREATE    PROCEDURE dbo.BmcExecutionSP_RS @pStatementProcessId DECIMAL(18, 0),      
@pYear VARCHAR(40),      
@pUserId INT      
      
AS      
BEGIN  
  DECLARE @pCurrentSettlementPeriodId1 VARCHAR(20);    
 DECLARE @vProcessDefId INT;  
   Declare @output VARCHAR(max);  
    DECLARE @pCurrentSettlementPeriodId INT;  


  
SELECT  
 @vProcessDefId = msp.SrProcessDef_ID  
FROM MtStatementProcess msp  
WHERE msp.MtStatementProcess_ID = @pStatementProcessId;  


SELECT  
 @pCurrentSettlementPeriodId = LuAccountingMonth_Id_Current  
FROM MtStatementProcess  
WHERE MtStatementProcess_ID = @pStatementProcessId  
  
DECLARE @name NVARCHAR(MAX);  
SELECT  
 @name = CONCAT(SrProcessDef_Name, '-', SrStatementDef_Name)  
FROM MtStatementProcess  
INNER JOIN SrProcessDef  
 ON SrProcessDef.SrProcessDef_ID = MtStatementProcess.SrProcessDef_ID  
INNER JOIN SrStatementDef  
 ON SrStatementDef.SrStatementDef_ID = SrProcessDef.SrStatementDef_ID  
WHERE MtStatementProcess_ID = @pStatementProcessId  
AND SrProcessDef.SrProcessDef_ID = @vProcessDefId  

  
 BEGIN TRY      
      
   
  
/*==========================================================================================        
    Get Process Def Id        
    ==========================================================================================*/  
  
  
/*==========================================================================================        
   Update status        
   ==========================================================================================*/  
  
  
UPDATE MtStatementProcess  
SET MtStatementProcess_Status = 'InProcess'  
   ,MtStatementProcess_ExecutionStartDate = GETDATE()  
WHERE MtStatementProcess_ID = @pStatementProcessId;  
---------logs----------  
  
SET @pCurrentSettlementPeriodId1 = [dbo].[GetSettlementMonthYear](@pCurrentSettlementPeriodId)   
SET @output = 'Process Execution Started: ' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @pCurrentSettlementPeriodId1)  
--SELECT  
-- @output;  
EXEC [dbo].[SystemLogs] @user = @pUserId  
        ,@moduleName = 'Settlements'  
        ,@CrudOperationName = 'Update'  
        ,@logMessage = @output  
-----------------------------------------------------------  
DECLARE @vDescription VARCHAR(1000);  
DECLARE @vRuStepDefId INT;  
/*==========================================================================================        
   Step Clear Data         
   ==========================================================================================*/  
EXEC [BMCClearData] @pStatementProcessId  
  
  
IF @vProcessDefId IN (14, 15, 20, 21)  
BEGIN  
  
SET @vDescription = CONCAT('BMC Process execution for year ', @pYear, ' begins at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = 0  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
/*==========================================================================================        
   Step 0         
   ==========================================================================================*/  
  
  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 0  
  
  
EXEC [dbo].[BMC_Step0Perform] @pStatementProcessId  
         -- ,@pYear      
        ,@pUserId;  
  
  
  
SET @vDescription = CONCAT('Step # 0 - BMC completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
  
/*==========================================================================================        
   Step 1         
   ==========================================================================================*/  
SET @vDescription = CONCAT('Step # 1 - BMC Step 1 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 1  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
EXEC [BMCStep1Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 1 - BMC Step 1 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 1  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
/*==========================================================================================        
     Step 2          
     ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 2 - BMC Step 2 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 2  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = NULL  
  
  
EXEC [BMCStep2Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 2 - BMC Step 2 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 2  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
/*==========================================================================================        
     Step 3          
     ==========================================================================================*/  
  
  
SET @vDescription = CONCAT('Step # 3 - BMC Step 3 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 3  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
/*==========================================================================================        
     Step 4          
     ==========================================================================================*/  
  
  
SET @vDescription = CONCAT('Step # 4 - BMC Step 4 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 4  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep3and4Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 3 - BMC Step 3 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 3  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
SET @vDescription = CONCAT('Step # 4 - BMC Step 4 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 4  
--EXEC [dbo].[BMC_InsertLogs] @pStatementProcessId            
--         ,@vDescription          
--         ,@pUserId;            
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
/*==========================================================================================        
     Step 5           
     ==========================================================================================*/  
  
  
SET @vDescription = CONCAT('Step # 5 - BMC Step 5 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 5  
--EXEC [dbo].[BMC_InsertLogs] @pStatementProcessId            
--         ,@vDescription          
--         ,@pUserId;            
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep5Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 5 - BMC Step 5 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 5  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
/*==========================================================================================        
     Step 6           
     ==========================================================================================*/  
  
  
SET @vDescription = CONCAT('Step # 6 - BMC Step 6 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 6  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep6and7Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 6 - BMC Step 6 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 6  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
/*==========================================================================================        
   Step 7           
   ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 7 - BMC Step 7 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 7  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
-- Commented by Ammama| Ali. Fetch Actual E in step 0 no need to fetch again.          
--EXEC [BMCStep7Perform] @pStatementProcessId             
  
SET @vDescription = CONCAT('Step # 7 - BMC Step 7 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 7  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
  
  
/*==========================================================================================        
   Step 8          
   ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 8 - BMC Step 8 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 8  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep8Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 8 - BMC Step 8 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 8  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
/*==========================================================================================        
   Step 9          
   ==========================================================================================*/  
SET @vDescription = CONCAT('Step # 9 - BMC Step 9 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 9  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep9Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 9 - BMC Step 9 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 9  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
/*==========================================================================================        
   Step 10          
   ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 10 - BMC Step 10 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 10  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep10Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 10 - BMC Step 10 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 10  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
/*==========================================================================================        
   Step 11          
   ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 11 - BMC Step 11 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 11  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep11Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 11 - BMC Step 11 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 11  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
/*==========================================================================================        
   Step 12         
   ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 12 - BMC Step 12 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 12  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
EXEC [BMCStep12Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 12 - BMC Step 12 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 12  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
SET @vDescription = CONCAT('BMC Process completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = NULL  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
/*==========================================================================================        
   Process Completed          
   ==========================================================================================*/  
END  
ELSE  
IF @vProcessDefId IN (16, 22)  
BEGIN  
  
SET @vDescription = CONCAT('BMC-PYSS Process execution for year ', @pYear, ' begins at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = 0  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 0;  
  
EXEC [dbo].[BMC_PYSS_Step0Perform] @pStatementProcessId  
  
  
  
  
SET @vDescription = CONCAT('Step # 0 - BMC-PYSS completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1;  
  
SET @vDescription = CONCAT('Step # 1 - BMC-PYSS Step 1 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 1  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
EXEC [BMCPYSSStep1Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 1 - BMC-PYSS Step 1 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 1  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
/*==========================================================================================        
     Step 2          
     ==========================================================================================*/  
  
SET @vDescription = CONCAT('Step # 2 - BMC-PYSS Step 2 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 2  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = NULL  
  
  
EXEC [BMCPYSSStep2Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 2 - BMC-PYSS Step 2 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 2  
  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
  
/*==========================================================================================        
     Step 3          
     ==========================================================================================*/  
  
  
SET @vDescription = CONCAT('Step # 3 - BMC-PYSS Step 3 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 3  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
EXEC [BMCPYSSStep3Perform] @pStatementProcessId  
  
SET @vDescription = CONCAT('Step # 3 - BMC-PYSS Step 3 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
SELECT  
 @vRuStepDefId = RuStepDef_ID  
FROM RuStepDef  
WHERE SrProcessDef_ID = @vProcessDefId  
AND RuStepDef_BMEStepNo = 3  
  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
  
SET @vDescription = CONCAT('BMC-PYSS Process completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));  
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = NULL  
          ,@LogsMessage = @vDescription  
          ,@OutputMessage = 'Success'  
          ,@OutputStatus = 1  
END  
  
  
  
  
  
-- Set Execution status to 'Executed'            
UPDATE MtStatementProcess  
SET MtStatementProcess_Status = 'Executed'  
   ,MtStatementProcess_ExecutionFinishDate = GETDATE()  
WHERE MtStatementProcess_ID = @pStatementProcessId  
  
----------------------------------  
SET @pCurrentSettlementPeriodId1 = [dbo].[GetSettlementMonthYear](@pCurrentSettlementPeriodId)  
SET @output = 'Process Execution Completed: ' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @pCurrentSettlementPeriodId1)  
  print '@output'
  print @name
EXEC [dbo].[SystemLogs] @user = @pUserId  
        ,@moduleName = 'Settlements'  
        ,@CrudOperationName = 'Update'  
        ,@logMessage = @output  
SELECT  
 1 AS response  
END TRY  
BEGIN CATCH  
  
  
--interrupted state          
DECLARE @vErrorMessage VARCHAR(MAX) = '';  
SELECT  
 @vErrorMessage = ERROR_MESSAGE();  
  
--EXEC [dbo].[BMC_InsertLogs] @pStatementProcessId            
--         ,@vErrorMessage            
--         ,@pUserId            
--         ,'Error';            
EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId  
          ,@pRuStepDef_ID = @vRuStepDefId  
          ,@LogsMessage = @vErrorMessage  
          ,@OutputMessage = 'Error'  
          ,@OutputStatus = 0  
  
UPDATE MtStatementProcess  
SET MtStatementProcess_Status = 'Interrupted'  
   ,MtStatementProcess_ApprovalStatus = 'Draft'  
WHERE MtStatementProcess_ID = @pStatementProcessId  
  
----------------------------------  
SET @pCurrentSettlementPeriodId1 = [dbo].[GetSettlementMonthYear](@pCurrentSettlementPeriodId)  
SET @output = 'Process Execution Interrupted: ' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @pCurrentSettlementPeriodId1)  
SELECT  
 @output;  
EXEC [dbo].[SystemLogs] @user = @pUserId  
        ,@moduleName = 'Settlements'  
        ,@CrudOperationName = 'Update'  
        ,@logMessage = @output  
  
RAISERROR (@vErrorMessage, 16, -1);  
RETURN;  
  
END CATCH  
END  

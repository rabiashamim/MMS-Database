/****** Object:  Procedure [dbo].[CreateNewSettlementStatement]    Committed by VersionSQL https://www.versionsql.com ******/

      
--dbo.CreateNewSettlementStatement  @pProcessId= 19, @pSettlementPeriodId= 0, @pCurrentSettlementPeriodId=35, @pUserId=1, @pStatus='Draft', @pApprovalStatus='Draft'      
      
CREATE PROCEDURE dbo.CreateNewSettlementStatement          
@pProcessId decimal(18,0)   =null ,      
@pSettlementPeriodId decimal(18,0)=null, --For ESS Only      
@pCurrentSettlementPeriodId decimal(18,0)=null,      
@pUserId decimal(18,0)=null,      
@pStatus as Varchar(50)=null, --Draft      
@pApprovalStatus as Varchar(50)=null --Draft      
      
AS          
BEGIN  
        
      
  --set @pProcessId=1 --  PSS-BME      
      if(@pProcessId IN (19,23) and @pSettlementPeriodId=0)
	  BEGIN
	  SELECT  'Select Settlement Period to create EYSS.' AS response  
	  return;
	  END
 --------------------------  Check if Predecessor exists for Statement and Process      
  DECLARE @vStatementPredecessor as decimal(18,0)  
      
  DECLARE @vProcessPredecessor as decimal(18,0)  
      
  DECLARE @vStatementId as decimal(18,0)  
      
 DECLARE @vProcessTypeId Decimal(18,0)--Check if Statement=ESS for Current Settlement Period      
 Declare @vSrProcessDef_PreviousProcessPredecessorID as decimal(18,0)-- ASC-FSS is dependent on ASC-PSS      
      
      
 IF(@pProcessId=12)      
BEGIN  
      
DECLARE @vTempHoldPeriodID decimal(18,0) --temp      
SET @vTempHoldPeriodID = @pSettlementPeriodId  
SET @pSettlementPeriodId = @pCurrentSettlementPeriodId  
SET @pCurrentSettlementPeriodId = @vTempHoldPeriodID  
      
END  
  
SELECT  
 @vProcessTypeId = SDF.SrStatementDef_ID  
   ,@vStatementPredecessor = SDF.SrStatementDef_Predecessor_ID  
   ,@vProcessPredecessor = SPD.SrProcessDef_PredecessorID  
   ,@vSrProcessDef_PreviousProcessPredecessorID = SPD.SrProcessDef_PreviousProcessPredecessorID  
   ,@vStatementId=SPD.SrStatementDef_ID  
FROM SrStatementDef SDF  
INNER JOIN SrProcessDef SPD  
 ON SDF.SrStatementDef_ID = SPD.SrStatementDef_ID  
  AND SPD.SrProcessDef_ID = @pProcessId  
PRINT '@vSrProcessDef_PreviousProcessPredecessorID'  
PRINT @vSrProcessDef_PreviousProcessPredecessorID  
--*************** Statement Predecessor Missing *********************      
---------------------------- Statement Predecessor Check starts -------------      
IF (@vStatementPredecessor IS NOT NULL)  
BEGIN  
DECLARE @ApprovalStatus AS VARCHAR(50);  
DECLARE @vStatementPredecessorProcessesCount AS INT = NULL  
DECLARE @vTotalStatementPredecessorProcessesCount AS INT = NULL  
  
SELECT  
 SPD.SrProcessDef_ID AS SrProcessDef_ID INTO #StatementPredecessorProcesses  
FROM SrProcessDef SPD  
WHERE SPD.SrStatementDef_ID = @vStatementPredecessor  
  
SELECT  
 @vTotalStatementPredecessorProcessesCount = COUNT(1)  
FROM #StatementPredecessorProcesses  
  
SELECT  
 @vStatementPredecessorProcessesCount = COUNT(1)  
   ,@ApprovalStatus = MSP.MtStatementProcess_ApprovalStatus  
FROM MtStatementProcess MSP  
WHERE MSP.LuAccountingMonth_Id_Current = @pCurrentSettlementPeriodId  
AND MSP.SrProcessDef_ID IN (SELECT  
  SrProcessDef_ID  
 FROM #StatementPredecessorProcesses)  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0  
  
  
IF (@vStatementPredecessorProcessesCount <> @vTotalStatementPredecessorProcessesCount)  
BEGIN  
PRINT 'Some Predecessor Processes are missing'  
--         Select 'Some Predecessor Processes are missing. Please complete that before proceeding next' as response      
SELECT  
 CONCAT('Some Processes of ', SrStatementDef_Name, ' are missing for selected Settlement Period. Please complete that before preceding next') AS response  
FROM SrStatementDef  
WHERE SrStatementDef_ID = @vStatementPredecessor  
RETURN;  
END  
END  
---------------------------- Statement Predecessor Check ends -------------      
  
----------------- Process Predecessor Check Starts      
IF (@vProcessPredecessor IS NOT NULL)  
BEGIN  
DECLARE @vProcessPredecessorCheck AS INT  
DECLARE @vProcessApprovalStatus AS VARCHAR(50);  
  
SELECT  
 @vProcessPredecessorCheck = COUNT(1)  
FROM MtStatementProcess  
WHERE --LuAccountingMonth_Id_Current = @pCurrentSettlementPeriodId  
LuAccountingMonth_Id_Current = case WHEN @vStatementId in (3,8) then @pSettlementPeriodId  else @pCurrentSettlementPeriodId end --Condition for ESS  
AND SrProcessDef_ID = @vProcessPredecessor  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0  
  
SELECT  
 @vProcessApprovalStatus = MtStatementProcess_ApprovalStatus  
FROM MtStatementProcess  
WHERE --LuAccountingMonth_Id_Current = @pCurrentSettlementPeriodId  
LuAccountingMonth_Id_Current = case WHEN @vStatementId in (3,8,19,23) then @pSettlementPeriodId  else @pCurrentSettlementPeriodId end --Condition for ESS  
AND SrProcessDef_ID = @vProcessPredecessor  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0  
  
  
IF (@vProcessPredecessorCheck = 0)  
BEGIN  
  
SELECT  
 CONCAT('Please create ', SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name, ' Process First Before creating current process.') AS response  
FROM SrStatementDef SSD  
INNER JOIN SrProcessDef SPD  
 ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID  
WHERE SPD.SrProcessDef_ID = @vProcessPredecessor  
  
PRINT 'Please create Predecessors Processes First'  
--         Select '2' as response      
RETURN;  
  
END  
IF (@vProcessApprovalStatus <> 'Approved')  
BEGIN  
  
SELECT  
 CONCAT('Please approve ', SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name, ' Process First Before creating current process.') AS response  
FROM SrStatementDef SSD  
INNER JOIN SrProcessDef SPD  
 ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID  
WHERE SPD.SrProcessDef_ID = @vProcessPredecessor  
RETURN;  
END  
END  
----------------- Process Predecessor Check Ends      
  
----------------- Previous Process Predecessor Check Starts      
IF (@vSrProcessDef_PreviousProcessPredecessorID IS NOT NULL)  
BEGIN  
DECLARE @vSrProcessDef_PreviousProcessPredecessorIDCheck AS INT;  
DECLARE @vPreviousProcessPredecessorApprovalStatus AS VARCHAR(50);  
  
SELECT  
 @vSrProcessDef_PreviousProcessPredecessorIDCheck = COUNT(1)  
FROM MtStatementProcess  
WHERE LuAccountingMonth_Id_Current = @pCurrentSettlementPeriodId  
AND SrProcessDef_ID = @vSrProcessDef_PreviousProcessPredecessorID  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0  
  
SELECT  
 @vPreviousProcessPredecessorApprovalStatus = MtStatementProcess_ApprovalStatus  
FROM MtStatementProcess  
WHERE LuAccountingMonth_Id_Current = @pCurrentSettlementPeriodId  
AND SrProcessDef_ID = @vSrProcessDef_PreviousProcessPredecessorID  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0  
  
  
  
PRINT '@vSrProcessDef_PreviousProcessPredecessorIDCheck';  
PRINT @vSrProcessDef_PreviousProcessPredecessorIDCheck;  
IF (@vSrProcessDef_PreviousProcessPredecessorIDCheck = 0)  
BEGIN  
PRINT 'In IF Statement'  
SELECT  
 CONCAT('Please create ', SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name, ' Process First Before creating current process.') AS response  
FROM SrStatementDef SSD  
INNER JOIN SrProcessDef SPD  
 ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID  
WHERE SPD.SrProcessDef_ID = @vSrProcessDef_PreviousProcessPredecessorID  
  
PRINT 'Please create Predecessors Processes First'  
--         Select '2' as response      
PRINT 'Before return'  
RETURN;  
  
END  
  
IF (@vPreviousProcessPredecessorApprovalStatus <> 'Approved')  
BEGIN  
  
SELECT  
 CONCAT('Please approve ', SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name, ' Process First Before creating current process.') AS response  
FROM SrStatementDef SSD  
INNER JOIN SrProcessDef SPD  
 ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID  
WHERE SPD.SrProcessDef_ID = @vProcessPredecessor  
  
END  
END  
-----------------Previous Process Predecessor Check Ends      
  
-----------------Check if same statement is already created for same settlement Period starts      
IF (@pProcessId <> 7  
 AND @pProcessId <> 8  
 AND @pProcessId <> 9  
 AND @pProcessId <> 12)--Multiple ESS reports can be generated      
BEGIN  
DECLARE @vProcessAlreadyExistsCheck AS INT  
SELECT  
 @vProcessAlreadyExistsCheck = COUNT(1)  
FROM MtStatementProcess  
WHERE LuAccountingMonth_Id_Current = @pCurrentSettlementPeriodId  
AND SrProcessDef_ID = @pProcessId  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0  
IF (@vProcessAlreadyExistsCheck <> 0)  
BEGIN  
PRINT 'Settlement Statement for this month is already created'  
SELECT  
 '3' AS response  
RETURN;  
  
END  
END  
  
-----------------Check if same statement is already created for same settlement Period ends          
  
---------------------- In case of ESS of previous month, check if BME-FSS and ASC-FSS exist for previous month also      
IF (@pProcessId = 7  
 OR @pProcessId = 8  
 OR @pProcessId = 9)--Multiple ESS reports can be generated      
BEGIN  
DECLARE @vFSSAlreadyExists AS INT;  
SELECT  
 @vFSSAlreadyExists = COUNT(1)  
FROM MtStatementProcess  
WHERE LuAccountingMonth_Id_Current = @pSettlementPeriodId  
AND SrProcessDef_ID IN (4, 5)  
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0;  
IF (@vFSSAlreadyExists <> 2)  
BEGIN  
PRINT 'Please Generate BME-FSS and ASC-FSS of previous month before preceding next.'  
SELECT  
 'Please Generate BME-FSS and ASC-FSS of previous month before preceding next.' AS response  
RETURN;  
  
END  
  
END  
---------------------- In case of ESS of previous month, check if BME-FSS and ASC-FSS exist for previous month also ENDS      
  
  
------------------ Insert data to MtStatementProcess      
DECLARE @vMtStatementProcess_ID DECIMAL(18, 0);  
SELECT  
 @vMtStatementProcess_ID = MAX(ISNULL(MtStatementProcess_ID, 0)) + 1  
FROM MtStatementProcess  
  
  
IF (@pProcessId IN (7, 8, 9,19,23))  
BEGIN  
INSERT INTO [dbo].[MtStatementProcess] ([MtStatementProcess_ID]  
, [SrProcessDef_ID]  
, [LuAccountingMonth_Id]  
, [LuAccountingMonth_Id_Current]  
  
, [MtStatementProcess_ExecutionStartDate]  
, [MtStatementProcess_ExecutionFinishDate]  
, [MtStatementProcess_Status]  
, [MtStatementProcess_ApprovalStatus]  
, [MtStatementProcess_CreatedBy]  
, [MtStatementProcess_CreatedOn]  
, [MtStatementProcess_IsDeleted])  
 VALUES (ISNULL(@vMtStatementProcess_ID, 1), @pProcessId, NULLIF( @pCurrentSettlementPeriodId,0), CASE WHEN @vProcessTypeId in  (3,8) THEN @pSettlementPeriodId ELSE NULL END, DATEADD(HOUR, 5, GETUTCDATE()), NULL, @pStatus, @pApprovalStatus, @pUserId, DATEADD(HOUR, 5
, GETUTCDATE()), 0)  
END  
ELSE  
BEGIN  
INSERT INTO [dbo].[MtStatementProcess] ([MtStatementProcess_ID]  
, [SrProcessDef_ID]  
, [LuAccountingMonth_Id_Current]  
, [LuAccountingMonth_Id]  
, [MtStatementProcess_ExecutionStartDate]  
, [MtStatementProcess_ExecutionFinishDate]  
, [MtStatementProcess_Status]  
, [MtStatementProcess_ApprovalStatus]  
, [MtStatementProcess_CreatedBy]  
, [MtStatementProcess_CreatedOn]  
, [MtStatementProcess_IsDeleted])  
 VALUES (ISNULL(@vMtStatementProcess_ID, 1), @pProcessId,    
-- @pCurrentSettlementPeriodId,   
 case when @pCurrentSettlementPeriodId=0 or @pCurrentSettlementPeriodId=-1 then null else @pCurrentSettlementPeriodId end, -- case written for optional ETL-EYSS and BMC-EYSS  
 CASE WHEN @vProcessTypeId in (3,8,4,5,6,7,9,10) THEN @pSettlementPeriodId ELSE NULL END, DATEADD(HOUR, 5, GETUTCDATE()), NULL, @pStatus, @pApprovalStatus, @pUserId, DATEADD(HOUR, 5, GETUTCDATE()), 0)  
  
END  
  
CREATE TABLE #tempBmeVersions (  
 SOFileTemplateId INT  
   ,Version INT  
)  
  
IF (@pProcessId IN (2, 5, 7))  
BEGIN  
DECLARE @vBmeId AS DECIMAL(18, 0) = NULL  
SELECT  
 @vBmeId = [dbo].[GetBMEtatementProcessIdFromASC](@vMtStatementProcess_ID)  
  
--print 'Asc Id'+ cast(@vMtStatementProcess_ID as NVARCHAR(MAX))      
--print 'BME Id'+cast (@vBmeId as NVARCHAR(MAX))      
INSERT INTO #tempBmeVersions (SOFileTemplateId, Version)  
 SELECT  
  SOFileTemplateId  
    ,Version  
 FROM BMEInputsSOFilesVersions  
 WHERE SettlementProcessId = @vBmeId  
  
END  
--ELSE      
--BEGIN       
--  select 0 as SOFileTemplateId, 0 as Version into #tempBmeVersions         
  
--END      
  
  
------------------- PSS/FSS Save latest version of SO file template for BME Input Grid Started -----------------------      
INSERT INTO BMEInputsSOFilesVersions  
 SELECT  
  SP.MtStatementProcess_ID  
    ,PID.LuSOFileTemplate_Id  
    ,  
  --    MAX(FM.MtSOFileMaster_Version) AS MaxVersion       
  CASE  
   WHEN @pProcessId IN (2, 5, 7) AND  
    MIN(PID.LuSOFileTemplate_Id) = MIN(bme.SOFileTemplateId) THEN MAX(bme.Version)  
   ELSE MAX(FM.MtSOFileMaster_Version)  
  END AS MaxVersion  
    ,1  
    ,GETDATE()  
    ,1  
    ,GETDATE()  
    ,NULL  
 FROM RuProcessInputDef PID  
  
 JOIN MtStatementProcess SP  
  ON SP.SrProcessDef_ID = PID.SrProcessDef_ID  
   AND SP.MtStatementProcess_ID = @vMtStatementProcess_ID  
  
 LEFT JOIN MtSOFileMaster FM  
  ON FM.LuAccountingMonth_Id = SP.LuAccountingMonth_Id_Current  
   AND FM.LuSOFileTemplate_Id = PID.LuSOFileTemplate_Id  
   AND FM.LuStatus_Code = 'APPR'  
   AND ISNULL(FM.MtSOFileMaster_IsDeleted, 0) = 0  
   AND FM.MtSOFileMaster_IsUseForSettlement = 1  
  
 LEFT JOIN #tempBmeVersions bme  
  ON bme.SOFileTemplateId = PID.LuSOFileTemplate_Id  
  
 WHERE PID.LuSOFileTemplate_Id IS NOT NULL  
 AND PID.SrProcessDef_ID = @pProcessId  
 AND PID.LuSOFileTemplate_Id NOT IN (SELECT  
   SOFileTemplateId  
  FROM BMEInputsSOFilesVersions  
  WHERE SettlementProcessId = @vMtStatementProcess_ID)  
 GROUP BY PID.LuSOFileTemplate_Id  
   ,PID.RuProcessInputDef_ID  
   ,SP.MtStatementProcess_ID  
   ,SP.LuAccountingMonth_Id_Current  
 ORDER BY PID.LuSOFileTemplate_Id  
  
  
  
PRINT 'Record Inserted Successfully'  
SELECT  
 '1' AS response  
  
DECLARE @name NVARCHAR(max);  
select @name=CONCAT(SrProcessDef_Name,'-' ,SrStatementDef_Name)  from MtStatementProcess inner join   
SrProcessDef on SrProcessDef.SrProcessDef_ID=MtStatementProcess.SrProcessDef_ID  
inner join SrStatementDef on SrStatementDef.SrStatementDef_ID=SrProcessDef.SrStatementDef_ID  
where MtStatementProcess_ID=@vMtStatementProcess_ID and SrProcessDef.SrProcessDef_ID=@pProcessId  
--SELECT  
-- @tempname = RuModulesProcess_Name  
--FROM RuModulesProcess  
--WHERE RuModulesProcess_Id = @pProcessId  
  
DECLARE @pCurrentSettlementPeriodId1 VARCHAR(20);  
SET @pCurrentSettlementPeriodId1 = [dbo].[GetSettlementMonthYear](@pCurrentSettlementPeriodId)  
    
  declare @output VARCHAR(max);  
SET @output = 'New Process Created: ' + @name + ', Settlement Period:' + CONVERT(VARCHAR(MAX), @pCurrentSettlementPeriodId1) + ', SettlementProcessId: ' +cast (@vMtStatementProcess_ID AS VARCHAR(20))
SELECT  
 @output;  
EXEC [dbo].[SystemLogs] @user = @pUserId  
        ,@moduleName = 'Settlements'  
        ,@CrudOperationName = 'Create'  
        ,@logMessage = @output  
RETURN;  
  
  
  
END

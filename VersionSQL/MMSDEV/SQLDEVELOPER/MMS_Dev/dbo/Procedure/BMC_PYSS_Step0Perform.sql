/****** Object:  Procedure [dbo].[BMC_PYSS_Step0Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================            
-- Author:  Ammama Gill                              
-- CREATE date: Jan 04, 2023                               
-- ALTER date:                               
-- Reviewer:                              
-- Description: BMC PYSS Pre-execution Validations.                              
-- =============================================                               
-- =============================================                               
--  dbo.BMC_PYSS_Step0Perform 255    
  
CREATE PROCEDURE dbo.BMC_PYSS_Step0Perform (@pStatementProcessId DECIMAL(18, 0))  
AS  
BEGIN  
  
 CREATE TABLE #InvalidData (  
  LOG_MESSAGE VARCHAR(MAX)  
    ,ERROR_LEVEL VARCHAR(MAX)  
 )  
  
 DECLARE @vFinalStatementID DECIMAL(18, 0)  
     ,@vSecurityCoverFileId DECIMAL(18, 0);  
  
 SELECT  
  @vSecurityCoverFileId = dbo.GetMtSoFileMasterId(@pStatementProcessId, 12);  
  
 SELECT  
  @vFinalStatementID =  [dbo].[GetBMCStatementProcessID] (@pStatementProcessId);  
 -- msp.MtStatementProcess_ID  
 --FROM MtStatementProcess msp  
 --WHERE msp.SrProcessDef_ID = 15  
 --AND msp.MtStatementProcess_IsDeleted = 0  
 --AND msp.MtStatementProcess_ApprovalStatus = 'Approved'    
 --AND LuAccountingMonth_Id_Current = (SELECT  
 --  msp.LuAccountingMonth_Id_Current  
 -- FROM MtStatementProcess msp  
 -- WHERE msp.MtStatementProcess_ID = @pStatementProcessId  
 -- AND msp.MtStatementProcess_IsDeleted = 0)  
  
  
 DECLARE @vMissingMps VARCHAR(MAX) = '';  
 ;  
 WITH cte_MissingMPs  
 AS  
 (SELECT DISTINCT  
   b.MtPartyRegisteration_Id  
  FROM BMCMPData b  
  WHERE b.MtStatementProcess_ID = @vFinalStatementID  
  AND b.BMCMPData_CapacityBalance < 0  
  UNION ALL  
  SELECT DISTINCT  
   mscm.MtPartyRegisteration_Id  
  FROM MtSecurityCoverMP mscm  
  WHERE mscm.MtSOFileMaster_Id = @vSecurityCoverFileId)  
  
  
 SELECT  
  @vMissingMps = @vMissingMps + ',' + CAST(MtPartyRegisteration_Id AS VARCHAR(MAX))  
 FROM cte_MissingMPs  
 GROUP BY MtPartyRegisteration_Id  
 HAVING COUNT(1) <> 2;  
  
 IF @vMissingMps <> ''  
 BEGIN  
  INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)  
   VALUES ('Some MPs with negative imbalance are missing in the Security Cover sheet: ' + @vMissingMps, 'Warning');  
 END  
  
 DECLARE @vSecurityCoverValidations VARCHAR(MAX) = '';  
  
 SELECT  
  @vSecurityCoverValidations =  
  CASE  
   WHEN mscm.MtSecurityCoverMP_RequiredSecurityCover IS NULL THEN 'Required Security Cover column cannot be null. '  
   WHEN mscm.MtSecurityCoverMP_SubmittedSecurityCover IS NULL THEN @vSecurityCoverValidations + ' Submitted security cover column cannot be null. '  
   WHEN mscm.MtSecurityCoverMP_RequiredSecurityCover < 0 OR  
    mscm.MtSecurityCoverMP_SubmittedSecurityCover < 0 THEN @vSecurityCoverValidations + ' Required/Submitted security covers cannot be negative.'  
  END  
 FROM MtSecurityCoverMP mscm  
 WHERE mscm.MtSOFileMaster_Id = @vSecurityCoverFileId;  
  
 IF @vSecurityCoverValidations <> ''  
 BEGIN  
  INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)  
   VALUES (@vSecurityCoverValidations, 'Warning');  
 END  
  
 --SELECT  
 -- *  
 --FROM #InvalidData id;  
  
 IF EXISTS (SELECT  
   TOP 1  
    1  
   FROM #InvalidData id)  
 BEGIN  
  INSERT INTO MtSattlementProcessLogs (MtStatementProcess_ID  
  , MtSattlementProcessLog_Message  
  , MtSattlementProcessLog_ErrorLevel  
  , MtSattlementProcessLog_CreatedBy  
  , MtSattlementProcessLog_CreatedOn)  
   SELECT  
    @pStatementProcessId  
      ,id.LOG_MESSAGE  
      ,id.ERROR_LEVEL  
      ,1  
      ,GETDATE()  
   FROM #InvalidData id  
  
  RAISERROR ('BMC PYSS basic validations failure. Please refer to the previous logs for further details.', 16, -1);  
  RETURN;  
 END  
  
  
END

/****** Object:  Procedure [dbo].[WF_InsertHistory_data_20230302]    Committed by VersionSQL https://www.versionsql.com ******/

                  
                                
CREATE   PROCEDURE dbo.WF_InsertHistory_data_20230302                                
    @RuModuleId int,                                
    @ProcessId as decimal(18, 0),                   
    @MtWFHistory_Process_id as decimal(18, 0),                                    
    @level_id int,                                
    @WF_status char(4),                                
    @comments nvarchar(256) = null,                                
    @To_resource decimal(18, 0) = null,                                
    @Last_level_WF_status char(4) = null,  
    @user_id decimal(18, 0) =0                               
as                         
  
Declare  
 @WorkFlowHeader_id int,  
 @RuModulesProcessID int,  
    @NotificationSubject nvarchar(256),  
 @process_name varchar(256);  
  
  
 select @RuModulesProcessID= RuModulesProcess_Id,@process_name= RuModulesProcess_Name from RuModulesProcess where RuModules_Id=@RuModuleId and RuModulesProcess_ProcessTemplateId=@MtWFHistory_Process_id and ISNULL(RuModulesProcess_IsDeleted,0)=0;  
  
select @WorkFlowHeader_id=RuWorkFlowHeader_id from RuWorkFlow_header where RuModulesProcess_Id=@RuModulesProcessID  
  
if @WF_status = 'WFRR'                                
   or @Last_level_WF_status in ( 'WFRR', 'WFRA' )                                
begin            
SET @level_id = ISNULL(@level_id, 0)            
                                
end                                
else                                
begin            
SET @level_id = ISNULL(@level_id, 0) + 1            
                                
end            
                                
/*                                                                                                      
/*delete from RuWorkFlow_detail_Interface*/                                                                                        
update RuWorkFlow_detail_Interface                                                                                      
set is_deleted=1                                                                                      
where RuProcess_ID in (                                                                                                                  
                          select distinct                                                                                                                  
                              MtWFHistory_Process_id                                                                                                                  
                          from MtWFHistory                                                                                                                  
                          where (MtWFHistory_ProcessFinalApproval = 1                                                                                                                  
                                or MtWFHistory_ProcessRejected = 1 )                                            
        AND RuWorkFlowHeader_id=@WorkFlowHeader_id                                                                
                      )                                                             
*/                                
                                
if @level_id = 1                                
   and isnull(@WF_status, '') = 'WFSM' -- and isnull(@Last_level_WF_status,'')!='WFSM'                                                                                   
begin       
/*delete from RuWorkFlow_detail_Interface */            
UPDATE RuWorkFlow_detail_Interface            
SET is_deleted = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
            
INSERT INTO RuWorkFlow_detail_Interface (RuWorkFlow_detail_id,            
RuWorkFlowHeader_id,            
mtProcess_ID,            
RuWorkFlow_detail_levelId,            
RuWorkFlow_detail_description,            
AspNetUsers_UserId,            
Lu_Designation_Id,            
RuWorkFlow_detail_CreatedBy,            
RuWorkFlow_detail_CreatedOn,            
RuWorkFlow_detail_gen_level,            
is_locked,            
is_deleted)            
 SELECT            
  RuWorkFlow_detail_id            
    ,RuWorkFlowHeader_id            
    ,@ProcessId            
    ,RuWorkFlow_detail_levelId            
    ,RuWorkFlow_detail_description            
    ,AspNetUsers_UserId            
    ,Lu_Designation_Id            
    ,@user_id            
    ,GETDATE()            
    ,ROW_NUMBER() OVER (PARTITION BY RuWorkFlowHeader_id            
  ORDER BY RuWorkFlow_detail_levelId ASC            
  )            
    ,0            
    ,0            
 FROM RuWorkFlow_detail            
 WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id          
 AND ISNULL(RuWorkFlow_detail_isDeleted,0)=0      
            
END            
            
            
            
IF ISNULL(@WF_status, '') = 'WFAP' -- and isnull(@Last_level_WF_status,'')!='WFSM'                                                                                                                 
BEGIN            
DECLARE @RuWorkFlow_detail_gen_level INT            
    ,@RuWorkFlow_detail_levelId INT            
SELECT            
 @RuWorkFlow_detail_gen_level = RuWorkFlow_detail_gen_level            
   ,@RuWorkFlow_detail_levelId = RuWorkFlow_detail_levelId            
FROM RuWorkFlow_detail_Interface            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
AND is_locked = 1            
AND ISNULL(is_deleted, 0) = 0            
            
/*delete from RuWorkFlow_detail_Interface */            
UPDATE RuWorkFlow_detail_Interface            
SET is_deleted = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
AND RuWorkFlow_detail_gen_level > @RuWorkFlow_detail_gen_level            
            
UPDATE RuWorkFlow_detail_Interface            
SET is_locked = 0            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
AND ISNULL(is_deleted, 0) != 1            
            
INSERT INTO RuWorkFlow_detail_Interface (RuWorkFlow_detail_id,            
RuWorkFlowHeader_id,            
mtProcess_ID,            
RuWorkFlow_detail_levelId,            
RuWorkFlow_detail_description,            
AspNetUsers_UserId,            
Lu_Designation_Id,            
RuWorkFlow_detail_CreatedBy,            
RuWorkFlow_detail_CreatedOn,            
RuWorkFlow_detail_gen_level,            
is_locked,            
is_deleted)            
 SELECT            
  RuWorkFlow_detail_id            
    ,RuWorkFlowHeader_id            
    ,@ProcessId            
    ,RuWorkFlow_detail_levelId            
    ,RuWorkFlow_detail_description            
    ,AspNetUsers_UserId            
    ,Lu_Designation_Id            
    ,@user_id            
    ,GETDATE()            
    ,ROW_NUMBER() OVER (PARTITION BY RuWorkFlowHeader_id            
  ORDER BY RuWorkFlow_detail_levelId ASC            
  ) + @RuWorkFlow_detail_gen_level            
    ,0            
    ,0            
 FROM RuWorkFlow_detail            
 WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
 AND RuWorkFlow_detail_levelId > @RuWorkFlow_detail_levelId       
 and ISNULL(RuWorkFlow_detail_isDeleted,0)=0      
            
END            
            
            
            
DECLARE @authorized_approver DECIMAL(18, 0)            
    ,@max_sequence_id INT            
    ,@max_level_id INT            
    ,@module_id INT            
    ,@module_name VARCHAR(128)            
    ,@initiator DECIMAL(18, 0)            
    ,@chain_count INT            
    ,@interface_chain_count INT            
            
            
            
SELECT           @module_id = RuModulesProcess_Id        
FROM RuWorkFlow_header            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id        
and ISNULL(RuWorkFlowHeader_isDeleted,0)=0      
      
SELECT            
 @module_name = RuModulesProcess_Name            
FROM RuModulesProcess            
WHERE RuModulesProcess_Id = @module_id        
and ISNULL(RuModulesProcess_IsDeleted,0)=0      
            
            
SELECT            
 @authorized_approver = AspNetUsers_UserId            
FROM RuWorkFlow_detail_Interface            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
AND RuWorkFlow_detail_gen_level = @level_id            
AND ISNULL(is_deleted, 0) = 0            
            
IF @authorized_approver != @user_id            
 AND @WF_status != 'WFRR'            
 AND @Last_level_WF_status != 'WFRA'            
BEGIN            
SELECT            
 -1 AS error_Code            
   ,'User is not authorized for this level approval, Please check WF Hierarchy defined or contact administrator.' AS error_description            
RETURN            
END            
            
SELECT            
 @initiator = AspNetUsers_UserId            
FROM RuWorkFlow_detail_Interface            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND RuWorkFlow_detail_gen_level = 1            
AND mtProcess_ID = @ProcessId            
AND ISNULL(is_deleted, 0) = 0            
            
            
            
SELECT            
 @chain_count = COUNT(*)            
FROM RuWorkFlow_detail            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
SELECT            
 @interface_chain_count = COUNT(*)            
FROM RuWorkFlow_detail_Interface            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
AND ISNULL(is_deleted, 0) = 0            
            
            
            
            
            
            
DECLARE @WF_status_name VARCHAR(64)            
SELECT            
 @WF_status_name = LuStatus_Name            
FROM [LuStatus]            
WHERE LuStatus_Code = @WF_status            
            
DECLARE @sequence_id INT            
SET @sequence_id = 0            
SET @sequence_id = ISNULL((SELECT            
  MAX(MtWFHistory_SequenceID)            
 FROM MtWFHistory            
 WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
 AND MtWFHistory_Process_id = @ProcessId)            
,            
0            
) + 1            
            
            
INSERT INTO [dbo].[MtWFHistory]  
           ([RuWorkFlowHeader_id]  
           ,[MtWFHistory_Process_id]  
           ,[MtWFHistory_Process_name]  
           ,[MtWFHistory_LevelID]  
           ,[MtWFHistory_SequenceID]  
           ,[MtWFHistory_ActionDate]  
           ,[MtWFHistory_Action]  
           ,[MtWFHistory_FromResource]  
           ,[MtWFHistory_ToResource]  
           ,[MtWFHistory_comments]  
           ,[MtWFHistory_ProcessFinalApproval]  
           ,[MtWFHistory_ProcessRejected]  
           ,[MtWFHistory_NotificationSubject]  
           ,[MtWFHistory_CreatedBy]  
           ,[MtWFHistory_CreatedOn]  
           ,[MtWFHistory_ModifiedBy]  
           ,[MtWFHistory_ModifiedOn]  
           ,[is_initiator]  
           ,[notify_flag]  
           ,[is_read])  
  
 SELECT            
  @WorkFlowHeader_id            
    ,@ProcessId            
    ,ISNULL(NULLIF(@process_name, ''), @ProcessId)            
    ,@level_id            
    ,@sequence_id            
    ,GETDATE()            
    , /*@WF_status_name*/            
  @WF_status            
    ,@user_id            
    ,CASE            
   WHEN @WF_status IN ('WFRI', 'WFRA') THEN @To_resource            
   ELSE CASE            
     WHEN @interface_chain_count > 1 AND            
      @WF_status NOT IN ('WFRJ', 'WFAJ') THEN AspNetUsers_UserId            
     WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN @initiator            
     ELSE NULL            
    END            
  END            
    ,@comments            
    ,0            
    ,CASE            
   WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1            
   ELSE 0            
  END            
    ,@NotificationSubject            
    ,@user_id            
    ,GETDATE()            
    ,NULL            
    ,NULL            
    ,CASE            
   WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1            
   ELSE 0            
  END            
    ,            
  --/*                                        
  CASE            
   WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1            
   ELSE 0            
  END            
    ,       --*/                                           
  --1                                   
  0            
 FROM RuWorkFlow_detail_Interface            
 WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
 AND mtProcess_ID = @ProcessId            
 AND ISNULL(is_deleted, 0) = 0            
 AND RuWorkFlow_detail_gen_level = /*case                                                                                                                  
              when @chain_count > 1                                                                                                   
--and @WF_status  in('WFSM','WFAP','WFRJ') OR(@WF_status='WFRA' and isnull(@Last_level_WF_status,'')!='WFRR')                                                                          
  and @WF_status  in('WFSM','WFAP') or (@WF_status='WFRJ' and isnull(@Last_level_WF_status,'')not in ('WFSM','WFRR'))                                                                                              
   OR(@WF_status='WFRA' and isnull(@Last_level_WF_status,'')not in ('WFSM','WFRR'))*/            
 CASE            
  WHEN (         
   @WF_status = 'WFSM' AND            
   @level_id != @interface_chain_count            
   ) OR            
   (            
   @WF_status = 'WFAP' AND            
   @level_id < @interface_chain_count            
   ) -- in('WFSM','WFAP')                                                                                  
  THEN @level_id + 1            
  ELSE @level_id            
 END            
DECLARE @MtWFHistory_ToResource DECIMAL(18, 0)            
SELECT            
 @MtWFHistory_ToResource = MtWFHistory_ToResource            
FROM MtWFHistory            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND MtWFHistory_Process_id = @ProcessId            
AND MtWFHistory_SequenceID = @sequence_id            
            
UPDATE RuWorkFlow_detail_Interface            
SET is_locked = 1            
WHERE AspNetUsers_UserId = @MtWFHistory_ToResource          
AND ISNULL(is_deleted, 0) = 0            
            
--Set Approval status ='InProcess' when process is submitted and not fully approved                                                                                                 
--Get contract activity ID to mark if the final decission i.e. approve or reject is done                                
DECLARE @MtContractRegistrationActivity_Id DECIMAL(18, 0)            
            
SELECT TOP 1            
 @MtContractRegistrationActivity_Id = MtContractRegistrationActivity_Id            
FROM MtContractRegistrationActivities            
WHERE MtContractRegistration_Id = @ProcessId            
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0            
ORDER BY MtContractRegistrationActivity_Id DESC            
            
IF @level_id < @interface_chain_count            
 AND @WF_status IN ('WFSM')            
BEGIN            
--if @module_name = 'BME'                                                                    
IF (@module_id            
 BETWEEN 1 AND 12)            
 OR (@module_id = 27)            
 OR (@module_id = 28)            
 OR (@module_id = 29)            
 OR (@module_id = 30)        
 OR (@module_id = 31)        
BEGIN            
UPDATE MtStatementProcess            
SET MtStatementProcess_ApprovalStatus = 'InProcess'            
WHERE MtStatementProcess_ID = @ProcessId            
END            
IF @module_id = 19            
BEGIN            
UPDATE MtSOFileMaster            
SET MtSOFileMaster_ApprovalStatus = 'InProcess'            
   ,LuStatus_Code = 'SUBM'            
WHERE MtSOFileMaster_Id = @ProcessId            
END            
            
IF @module_id = 13            
BEGIN            
UPDATE MtPartyRegisteration            
SET LuStatus_Code_Approval = 'APRO'            
WHERE MtPartyRegisteration_Id = @ProcessId            
END            
IF @module_id BETWEEN 21 AND 26            
BEGIN            
UPDATE MtContractRegistration            
SET MtContractRegistration_ApprovalStatus =            
CASE            
 WHEN @module_id = 21 THEN 'CAIN'            
 WHEN @module_id = 22 THEN 'CAMI'            
 WHEN @module_id = 23 THEN 'CADI'            
 WHEN @module_id = 24 THEN 'CASI'            
 WHEN @module_id = 25 THEN 'CAWI'            
 WHEN @module_id = 26 THEN 'CATI'            
END            
WHERE MtContractRegistration_Id = @ProcessId            
AND ISNULL(MtContractRegistration_IsDeleted, 0) = 0            
END            
            
            
END            
            
UPDATE MtWFHistory            
SET MtWFHistory_ProcessRejected =            
CASE            
 WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1            
 ELSE 0            
END            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND MtWFHistory_Process_id = @ProcessId            
            
            
IF @module_id = 14            
BEGIN            
DECLARE @MtRegisterationActivity_Id DECIMAL(18, 0)            
SELECT TOP 1            
 @MtRegisterationActivity_Id = MtRegisterationActivity_Id            
FROM MtRegisterationActivities            
WHERE MtPartyRegisteration_Id = @ProcessId            
AND (            
MtRegisterationActivities_ACtion = 'MDRA'            
OR MtRegisterationActivities_ACtion = 'MPA'            
)            
ORDER BY MtRegisterationActivity_Id DESC            
            
END            
            
            
            
            
            
            
            
IF @WF_status IN ('WFRJ', 'WFAJ')            
BEGIN            
            
UPDATE RuWorkFlow_detail_Interface            
SET is_deleted = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
            
IF (@module_id            
 BETWEEN 1 AND 12)            
 OR (@module_id = 27)            
 OR (@module_id = 28)            
 OR (@module_id = 29)            
 OR (@module_id = 30)          
 OR (@module_id = 31)        
BEGIN            
UPDATE MtStatementProcess            
SET MtStatementProcess_ApprovalStatus = 'Draft'            
WHERE MtStatementProcess_ID = @ProcessId            
END            
            
IF @module_id = 19            
BEGIN            
UPDATE MtSOFileMaster            
SET MtSOFileMaster_ApprovalStatus = 'Draft'            
   ,LuStatus_Code = 'FREJ'            
WHERE MtSOFileMaster_Id = @ProcessId            
END            
            
IF @module_id = 14            
BEGIN            
UPDATE MtRegisterationActivities            
SET MtRegisterationActivities_ACtion = 'MDRA'            
WHERE MtRegisterationActivity_Id = @MtRegisterationActivity_Id            
END            
            
            
            
IF @module_id            
 BETWEEN 13 AND 18            
 OR @module_id = 20            
BEGIN            
UPDATE MtPartyRegisteration            
SET LuStatus_Code_Approval =            
 CASE            
  WHEN LuStatus_Code_Approval = 'APRO' THEN 'ADRF'            
  WHEN LuStatus_Code_Approval = 'MPA' THEN 'MDRA' --modified draft                                                        
  WHEN LuStatus_Code_Approval = 'PDER' THEN 'AAPR' --deregistration rejected                                                        
  WHEN LuStatus_Code_Approval = 'SPFA' THEN 'AAPR' --suspension rejected                                        
            
  --WHEN LuStatus_Code_Approval='WSPF' THEN  'AAPR' --suspension rejected                            
  WHEN LuStatus_Code_Approval IN ('TPA', 'WSPF', 'SMPA') THEN 'SAPP' --termination rejected /Withdraw suspension rejected/suspension modify rejected                                                  
  ELSE LuStatus_Code_Approval            
 END            
   ,LuStatus_Code_Applicant =            
 CASE            
  WHEN LuStatus_Code_Approval IN ('SPFA', 'PDER') THEN 'AACT' --suspension rejected                              
  ELSE LuStatus_Code_Applicant            
 END            
WHERE MtPartyRegisteration_Id = @ProcessId            
            
IF @WF_status = 'WFAJ'            
BEGIN            
UPDATE MtPartyRegisteration            
SET LuStatus_Code_Approval = 'AREJ'            
   ,LuStatus_Code_Applicant = 'REJ'            
WHERE MtPartyRegisteration_Id = @ProcessId            
END            
            
END            
/*                                                        
IF @module_id IN (16)                                                                
begin                                                           
update MtPartyRegisteration                                                               
set                                                               
LuStatus_Code_Approval = 'AAPR'  ,                                                          
LuStatus_Code_Applicant='AACT'                          
WHERE                                                                
MtPartyRegisteration_Id = @ProcessId                                                             
end      
*/            
IF @module_id = 15            
BEGIN            
INSERT INTO [dbo].[MtRegisterationActivities] ([MtRegisterationActivity_Id],            
[MtPartyRegisteration_Id],            
[MtRegisterationActivities_ACtion],            
[MtRegisterationActivities_OrderNo],            
[MtRegisterationActivities_OrderDate],            
[MtRegisterationActivities_ApplicationNo],            
[MtRegisterationActivities_ApplicationDate],            
[MtRegisterationActivities_Remarks],            
[MtRegisterationActivities_DateTime],            
[MtRegisterationActivities_CreatedBy],            
[MtRegisterationActivities_CreatedOn])            
 SELECT            
  (SELECT            
    ISNULL(MAX([MtRegisterationActivity_Id]) + 1, 1)            
   FROM MtRegisterationActivities)            
    ,MtPartyRegisteration_Id            
    ,'AAPR'            
    ,MtRegisterationActivities_OrderNo            
    ,[MtRegisterationActivities_OrderDate]            
    ,[MtRegisterationActivities_ApplicationNo]            
    ,[MtRegisterationActivities_ApplicationDate]            
    ,[MtRegisterationActivities_Remarks]            
  ,[MtRegisterationActivities_DateTime]            
    ,@user_id            
    ,GETUTCDATE()            
 FROM [dbo].[MtRegisterationActivities]            
 WHERE MtPartyRegisteration_Id = @ProcessId            
 AND MtRegisterationActivities_ACtion = 'PDER'            
            
            
END            
            
/*Contract Registration */            
IF @module_id            
 BETWEEN 21 AND 26            
BEGIN            
UPDATE MtContractRegistration            
SET MtContractRegistration_ApprovalStatus =            
CASE            
 WHEN MtContractRegistration_ApprovalStatus = 'CAIN' THEN 'CADR'            
 WHEN MtContractRegistration_ApprovalStatus = 'CAMI' THEN 'CAMD' --modified draft                                                        
 WHEN MtContractRegistration_ApprovalStatus = 'CADI' THEN 'CADD' --deregistration rejected                                                        
 WHEN MtContractRegistration_ApprovalStatus = 'CASI' THEN 'CASD' --suspension rejected                                        
            
 --WHEN LuStatus_Code_Approval='WSPF' THEN  'AAPR' --suspension rejected                                                
 WHEN MtContractRegistration_ApprovalStatus IN ('CATI', 'CAWI') THEN 'CASA' --termination rejected /Withdraw suspension rejected/suspension modify rejected                                                
 ELSE MtContractRegistration_ApprovalStatus            
END            
WHERE MtContractRegistration_Id = @ProcessId            
            
            
            
            
UPDATE MtContractRegistrationActivities            
SET MtContractRegistrationActivities_FinalDecision = 1            
   ,MtContractRegistrationActivities_ActivityDateTime = GETDATE()            
WHERE MtContractRegistrationActivity_Id = @MtContractRegistrationActivity_Id            
            
END            
            
            
            
END            
/*rejection ended*/            
IF @level_id = @interface_chain_count            
 AND @WF_status IN ('WFSM', 'WFAP')            
BEGIN            
UPDATE MtWFHistory            
SET MtWFHistory_ProcessFinalApproval = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND MtWFHistory_Process_id = @ProcessId            
            
UPDATE MtWFHistory            
SET MtWFHistory_ToResource = @initiator            
   , --null                                                                        
 notify_flag = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND MtWFHistory_Process_id = @ProcessId            
AND MtWFHistory_SequenceID = @sequence_id            
            
            
UPDATE RuWorkFlow_detail_Interface            
SET is_deleted = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
            
--if @module_name = 'BME'                                                                     
IF (@module_id            
 BETWEEN 1 AND 12)            
 OR (@module_id = 27)            
 OR (@module_id = 28)            
 OR (@module_id = 29)            
 OR (@module_id = 30)         
 OR (@module_id = 31)        
BEGIN            
UPDATE MtStatementProcess            
SET MtStatementProcess_ApprovalStatus = 'Approved'            
   ,MtStatementProcess_Status = 'Completed'            
WHERE MtStatementProcess_ID = @ProcessId            
END            
            
IF @module_id = 19            
BEGIN            
UPDATE MtSOFileMaster            
SET MtSOFileMaster_ApprovalStatus = 'Approved'            
   ,LuStatus_Code = 'APPR'            
WHERE MtSOFileMaster_Id = @ProcessId            
END            
            
IF @module_id = 14            
BEGIN            
UPDATE MtPartyCategory            
SET LuStatus_Code = 'AAPR'            
WHERE ISNULL(isDeleted, 0) = 0            
AND MtPartyRegisteration_Id = @ProcessId            
            
UPDATE MtRegisterationActivities            
SET MtRegisterationActivities_ACtion = 'MAPR'            
WHERE MtRegisterationActivity_Id = @MtRegisterationActivity_Id            
END            
            
            
            
            
            
IF @module_id            
 BETWEEN 13 AND 18            
 OR @module_id = 20            
BEGIN            
UPDATE MtPartyRegisteration            
SET LuStatus_Code_Approval =            
 CASE            
  WHEN LuStatus_Code_Approval IN ('ADRF', 'APRO', 'MPA', 'WSPF') THEN 'AAPR'            
  WHEN LuStatus_Code_Approval IN ('SPFA', 'SMPA') THEN 'SAPP' --suspension approval/suspension modification approval                                                    
  WHEN LuStatus_Code_Approval = 'PDER' THEN 'ADER'            
  WHEN LuStatus_Code_Approval = 'TPA' THEN 'TERM'            
  ELSE LuStatus_Code_Approval            
 END            
   ,LuStatus_Code_Applicant =            
 CASE            
  WHEN LuStatus_Code_Approval IN ('ADRF', 'APRO', 'MPA', 'WSPF') THEN 'AACT'            
  WHEN LuStatus_Code_Approval = 'SPFA' THEN 'ASUS'            
  WHEN LuStatus_Code_Approval = 'PDER' THEN 'DER'            
  WHEN LuStatus_Code_Approval = 'TPA' THEN 'ATER'            
  ELSE LuStatus_Code_Applicant            
 END            
WHERE MtPartyRegisteration_Id = @ProcessId            
            
            
IF @module_id = 15            
BEGIN            
UPDATE [dbo].[MtRegisterationActivities]            
SET [MtRegisterationActivities_ACtion] = 'ADER'            
   ,[MtRegisterationActivities_DateTime] = GETDATE()            
   ,[MtRegisterationActivities_ModifiedBy] = @user_id            
   ,[MtRegisterationActivities_ModifiedOn] = GETDATE()            
WHERE MtPartyRegisteration_Id = @ProcessId            
AND MtRegisterationActivities_ACtion = 'PDER'            
            
END            
            
            
            
IF @module_id IN (15, 18)            
BEGIN            
;            
WITH cte            
AS            
(SELECT            
  CM.MtConnectedMeter_Id            
 FROM MtPartyRegisteration PR            
 JOIN MtPartyCategory PC            
  ON PC.MtPartyRegisteration_Id = PR.MtPartyRegisteration_Id            
 JOIN MtConnectedMeter CM            
  ON CM.MtPartyCategory_Id = PC.MtPartyCategory_Id            
 WHERE ISNULL(CM.IsAssigned, 0) = 1            
 AND ISNULL(PC.isDeleted, 0) = 0            
 AND ISNULL(PR.isDeleted, 0) = 0            
 AND PR.MtPartyRegisteration_Id = @ProcessId)            
UPDATE m            
SET IsAssigned = 0            
   ,mtconnectedmeter_effectiveto = GETUTCDATE()            
FROM MtConnectedMeter m            
INNER JOIN cte c            
 ON m.MtConnectedMeter_Id = c.MtConnectedMeter_Id            
            
            
END            
            
            
            
            
            
END            
            
/*Contract Registration */            
IF @module_id            
 BETWEEN 21 AND 26            
BEGIN            
UPDATE MtContractRegistration            
SET MtContractRegistration_ApprovalStatus =            
 CASE            
  WHEN MtContractRegistration_ApprovalStatus IN ('CADR', 'CAIN') THEN 'CAAP'            
  WHEN MtContractRegistration_ApprovalStatus IN ('CADD', 'CADI') THEN 'CADA' --Deregistration                                                      
  WHEN MtContractRegistration_ApprovalStatus IN ('CAMD', 'CAMI') THEN 'CAMA' --Modification                                                        
  WHEN MtContractRegistration_ApprovalStatus IN ('CASD', 'CASI') THEN 'CASA' --suspension                                     
  WHEN MtContractRegistration_ApprovalStatus IN ('CAWD', 'CAWI') THEN 'CAWA' --Withdraw suspension                                    
  --WHEN LuStatus_Code_Approval='WSPF' THEN  'AAPR' --suspension rejected                                                
  WHEN MtContractRegistration_ApprovalStatus IN ('CATI', 'CATD') THEN 'CATA' --termination                        
  ELSE MtContractRegistration_ApprovalStatus            
 END            
   ,MtContractRegistration_Status =            
 CASE            
  WHEN MtContractRegistration_ApprovalStatus IN ('CADR', 'CAIN', 'CAMD', 'CAMI', 'CAWD', 'CAWI') THEN 'CATV'            
  WHEN MtContractRegistration_ApprovalStatus IN ('CADD', 'CADI') THEN 'CDRG' --Deregistration                                                                             
  WHEN MtContractRegistration_ApprovalStatus IN ('CASD', 'CASI') THEN 'CSUP' --suspension                                 
  WHEN MtContractRegistration_ApprovalStatus IN ('CATI', 'CATD') THEN 'CTRD' --termination rejected /Withdraw suspension rejected/suspension modify rejected                                                 
  ELSE MtContractRegistration_Status            
 END            
WHERE MtContractRegistration_Id = @ProcessId            
            
            
            
            
UPDATE MtContractRegistrationActivities            
SET MtContractRegistrationActivities_FinalDecision = 1            
,MtContractRegistrationActivities_ActivityDateTime = GETDATE()            
WHERE MtContractRegistrationActivity_Id = @MtContractRegistrationActivity_Id            
            
END            
    
 if (@module_id between 1 and 12) or @module_id between 27 and 30  
BEGIN  
select @module_name=RuModules_Name from RuModules where RuModules_Id=4  
END  
else if (@module_id between 13 and 18) or @module_id=20  
BEGIN  
select @module_name=RuModules_Name from RuModules where RuModules_Id=1  
END  
  
else if @module_id =19  
BEGIN  
select @module_name=RuModules_Name from RuModules where RuModules_Id=3  
END  
else if @module_id between 21 and 26  
BEGIN  
select @module_name=RuModules_Name from RuModules where RuModules_Id=14  
END  
DECLARE @period INT = 0;   
DECLARE @vMtStatementProcess_ID int=0;  
select @vMtStatementProcess_ID =MtStatementProcess_ID from MtStatementProcess where  SrProcessDef_ID = @ProcessId          
  
SELECT            
 @period = LuAccountingMonth_Id_Current            
FROM MtStatementProcess            
WHERE MtStatementProcess_ID = @vMtStatementProcess_ID            
DECLARE @period1 VARCHAR(20);            
DECLARE @output VARCHAR(MAX);            
SET @period1 = [dbo].[GetSettlementMonthYear](@period)            
SET @output = 'Process Submitted for Approval: ' + @process_name + ' Settlement Period:' + CONVERT(VARCHAR(MAX), @period1) + ', File Master Id: ' +CONVERT(VARCHAR(MAX), @ProcessId)            
EXEC [dbo].[SystemLogs] @moduleName = @module_name          
        ,@CrudOperationName = 'Update'            
        ,@logMessage = @output            
         ,@user=@user_id            
            
            
END            
            
SELECT            
 1 error_code            
   ,CASE            
  WHEN @WF_status = 'WFSM' THEN 'Process Submitted Successfully.'            
  WHEN @WF_status = 'WFAP' THEN 'Process Approved Successfully.'            
  WHEN @WF_status = 'WFRJ' THEN 'Process Rejected Successfully.'            
  WHEN @WF_status = 'WFRR' THEN 'Information Request Response Submitted Successfully.'            
  WHEN @WF_status = 'WFRI' THEN 'Request Information Submitted Successfully.'            
  WHEN @WF_status = 'WFRA' THEN 'Process Re-Assigned Successfully.'            
  WHEN @WF_status = 'WFAJ' THEN 'Application Rejected Successfully.'            
 END 

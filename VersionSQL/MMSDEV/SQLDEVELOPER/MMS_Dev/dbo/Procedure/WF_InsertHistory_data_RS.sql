/****** Object:  Procedure [dbo].[WF_InsertHistory_data_RS]    Committed by VersionSQL https://www.versionsql.com ******/

                                
CREATE   procedure dbo.WF_InsertHistory_data_RS                                
 @RuModuleId int,    
    @ProcessId as decimal(18, 0),       
 @Process_Template_Id int,                               
    @level_id int,                                
    @WF_status char(4),                                
    @comments nvarchar(256) = null,                                                         
    @To_resource decimal(18, 0) = null,                                
    @Last_level_WF_status char(4) = null,                                
    @user_id decimal(18, 0) =0                               
as        
  
declare @WorkFlowHeader_id int,    
  @process_name nvarchar(256),    
  @RuModulesProcessID int    
    
 select @RuModulesProcessID= RuModulesProcess_Id,@process_name= RuModulesProcess_Name from RuModulesProcess where RuModules_Id=@RuModuleId and RuModulesProcess_ProcessTemplateId=@Process_Template_Id and ISNULL(RuModulesProcess_IsDeleted,0)=0;      
    
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
    
                           
if @level_id = 1 and isnull(@WF_status, '') = 'WFSM' -- and isnull(@Last_level_WF_status,'')!='WFSM'                                                                                   
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
 AND RuWorkFlow_detail_isDeleted=0      
            
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
 and RuWorkFlow_detail_isDeleted=0      
            
END            
            
        
            
DECLARE @authorized_approver DECIMAL(18, 0)            
    ,@max_sequence_id INT            
    ,@max_level_id INT            
    --,@RuModuleId INT                
    ,@initiator DECIMAL(18, 0)                  
    ,@interface_chain_count INT            
    
--SELECT            
-- @RuModuleId = RuModulesProcess_Id            
--FROM RuWorkFlow_header            
--WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id        
--and RuWorkFlowHeader_isDeleted=0      
              
SELECT            
 @interface_chain_count = COUNT(*)            
FROM RuWorkFlow_detail_Interface            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
AND ISNULL(is_deleted, 0) = 0            
            
     /*WF Standard SP*/       
   create table #results(error_code int,error_description varchar(256))    
   insert into #results    
    exec WF_InsertHistory_data_interface     
  @RuModuleId ,    
        @ProcessId ,       
     @Process_Template_Id ,                               
        @level_id ,                                
        @WF_status ,                                
        @comments ,                                                         
        @To_resource ,                                
        @Last_level_WF_status ,                                
        @user_id,    
  @interface_chain_count            
   if exists(Select 1 from #results where   error_code=-1)    
   begin     
   select error_code,error_description from #results    
   return    
   end     
                                
DECLARE @MtContractRegistrationActivity_Id DECIMAL(18, 0)            
            
SELECT TOP 1            
 @MtContractRegistrationActivity_Id = MtContractRegistrationActivity_Id            
FROM MtContractRegistrationActivities            
WHERE MtContractRegistration_Id = @ProcessId            
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0            
ORDER BY MtContractRegistrationActivity_Id DESC            
        
     
  
  
IF @level_id < @interface_chain_count AND @WF_status IN ('WFSM')            
BEGIN            
/*BME*/    
if @RuModuleId=4--IF (@RuModuleId BETWEEN 1 AND 12) OR (@RuModuleId between 27 and 31)     
BEGIN    
  
UPDATE MtStatementProcess            
SET MtStatementProcess_ApprovalStatus = 'InProcess'            
WHERE MtStatementProcess_ID = @ProcessId            
END      
/*DATA MANAGEMENT*/    
IF @RuModuleId =3-- 19            
BEGIN            
UPDATE MtSOFileMaster            
SET MtSOFileMaster_ApprovalStatus = 'InProcess'            
   ,LuStatus_Code = 'SUBM'            
WHERE MtSOFileMaster_Id = @ProcessId            
END            
 /*Party Registration*/           
IF @RuModuleId =1-- 13            
BEGIN            
UPDATE MtPartyRegisteration            
SET LuStatus_Code_Approval = 'APRO'            
WHERE MtPartyRegisteration_Id = @ProcessId            
END      
 /*Contract Registration*/      
IF @RuModuleId=12-- BETWEEN 21 AND 26            
BEGIN            
UPDATE MtContractRegistration            
SET MtContractRegistration_ApprovalStatus =            
CASE            
 WHEN @RuModuleId = 21 THEN 'CAIN'            
 WHEN @RuModuleId = 22 THEN 'CAMI'            
 WHEN @RuModuleId = 23 THEN 'CADI'            
 WHEN @RuModuleId = 24 THEN 'CASI'            
 WHEN @RuModuleId = 25 THEN 'CAWI'            
 WHEN @RuModuleId = 26 THEN 'CATI'            
END            
WHERE MtContractRegistration_Id = @ProcessId            
AND ISNULL(MtContractRegistration_IsDeleted, 0) = 0            
END            
            
            
END            
    
            
IF @RuModuleId = 14            
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
            
IF (@RuModuleId BETWEEN 1 AND 12) or(@RuModuleId BETWEEN 27 AND 31)      
BEGIN            
UPDATE MtStatementProcess            
SET MtStatementProcess_ApprovalStatus = 'Draft'            
WHERE MtStatementProcess_ID = @ProcessId            
END            
            
IF @RuModuleId = 19            
BEGIN            
UPDATE MtSOFileMaster            
SET MtSOFileMaster_ApprovalStatus = 'Draft'            
   ,LuStatus_Code = 'FREJ'            
WHERE MtSOFileMaster_Id = @ProcessId            
END            
            
IF @RuModuleId = 14            
BEGIN            
UPDATE MtRegisterationActivities            
SET MtRegisterationActivities_ACtion = 'MDRA'            
WHERE MtRegisterationActivity_Id = @MtRegisterationActivity_Id            
END            
            
            
            
IF @RuModuleId            
 BETWEEN 13 AND 18            
 OR @RuModuleId = 20            
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
        
IF @RuModuleId = 15            
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
IF @RuModuleId            
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
    
            
UPDATE RuWorkFlow_detail_Interface            
SET is_deleted = 1            
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id            
AND mtProcess_ID = @ProcessId            
            
--if @module_name = 'BME'                                                                     
IF @RuModuleId=4--(@RuModuleId BETWEEN 1 AND 12) or   (@RuModuleId BETWEEN 27 AND 31)        
BEGIN            
UPDATE MtStatementProcess            
SET MtStatementProcess_ApprovalStatus = 'Approved'            
   ,MtStatementProcess_Status = 'Completed'            
WHERE MtStatementProcess_ID = @ProcessId            
END            
            
IF @RuModuleId = 19            
BEGIN            
UPDATE MtSOFileMaster            
SET MtSOFileMaster_ApprovalStatus = 'Approved'            
   ,LuStatus_Code = 'APPR'            
WHERE MtSOFileMaster_Id = @ProcessId            
END            
            
IF @RuModuleId = 14            
BEGIN            
UPDATE MtPartyCategory            
SET LuStatus_Code = 'AAPR'            
WHERE ISNULL(isDeleted, 0) = 0            
AND MtPartyRegisteration_Id = @ProcessId            
            
UPDATE MtRegisterationActivities            
SET MtRegisterationActivities_ACtion = 'MAPR'            
WHERE MtRegisterationActivity_Id = @MtRegisterationActivity_Id            
END            
            
            
            
            
            
IF @RuModuleId            
 BETWEEN 13 AND 18           
 OR @RuModuleId = 20            
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
            
            
IF @RuModuleId = 15            
BEGIN            
UPDATE [dbo].[MtRegisterationActivities]            
SET [MtRegisterationActivities_ACtion] = 'ADER'            
   ,[MtRegisterationActivities_DateTime] = GETDATE()            
   ,[MtRegisterationActivities_ModifiedBy] = @user_id            
   ,[MtRegisterationActivities_ModifiedOn] = GETDATE()            
WHERE MtPartyRegisteration_Id = @ProcessId            
AND MtRegisterationActivities_ACtion = 'PDER'            
            
END            
            
            
            
IF @RuModuleId IN (15, 18)            
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
IF @RuModuleId            
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

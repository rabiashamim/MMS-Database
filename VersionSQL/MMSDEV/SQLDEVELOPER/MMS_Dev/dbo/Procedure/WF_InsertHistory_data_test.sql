/****** Object:  Procedure [dbo].[WF_InsertHistory_data_test]    Committed by VersionSQL https://www.versionsql.com ******/

                            
CREATE   procedure dbo.WF_InsertHistory_data_test                            
    @WorkFlowHeader_id int,                            
    @ProcessId as decimal(18, 0),                            
    @process_name nvarchar(256)=null,                            
    @level_id int,                            
    @WF_status char(4),                            
    @comments nvarchar(256) = null,                            
    @NotificationSubject nvarchar(256),                            
    @To_resource decimal(18, 0) = null,                            
    @Last_level_WF_status char(4) = null,                            
    @user_id decimal(18, 0) =0 ,
	@interface_chain_count int
as                            
      
DECLARE 
	 @authorized_approver DECIMAL(18, 0)        
    ,@max_sequence_id INT        
    ,@max_level_id INT        
    ,@module_id INT             
    ,@initiator DECIMAL(18, 0)        
    
SELECT        
 @authorized_approver = AspNetUsers_UserId        
FROM RuWorkFlow_detail_Interface        
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id        
AND RuProcess_ID = @ProcessId        
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
AND RuProcess_ID = @ProcessId        
AND ISNULL(is_deleted, 0) = 0        
       
        
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
        
        
        
INSERT INTO MtWFHistory        
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
 AND RuProcess_ID = @ProcessId        
 AND ISNULL(is_deleted, 0) = 0        
 AND RuWorkFlow_detail_gen_level =       
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
        

UPDATE MtWFHistory        
SET MtWFHistory_ProcessRejected =        
CASE        
 WHEN @WF_status IN ('WFRJ', 'WFAJ') THEN 1        
 ELSE 0        
END        
WHERE RuWorkFlowHeader_id = @WorkFlowHeader_id        
AND MtWFHistory_Process_id = @ProcessId        
      
          
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
         
        
DECLARE @period INT = 0;        
SELECT        
 @period = LuAccountingMonth_Id_Current        
FROM MtStatementProcess        
WHERE SrProcessDef_ID = @ProcessId        
        
DECLARE @period1 VARCHAR(20);        
DECLARE @output VARCHAR(MAX);        
SET @period1 = [dbo].[GetSettlementMonthYear](@period)        
SET @output = 'Process Submitted for Approval: ' + @process_name + ' Settlement Period:' + CONVERT(VARCHAR(MAX), @period1)        
EXEC [dbo].[SystemLogs] @moduleName = 'Data Management'        
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

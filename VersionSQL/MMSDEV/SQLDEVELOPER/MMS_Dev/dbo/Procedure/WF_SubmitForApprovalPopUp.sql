/****** Object:  Procedure [dbo].[WF_SubmitForApprovalPopUp]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
--======================================================================                      
--Author  : Rabia Shamim              
--Reviewer : <>                      
--CreatedDate : 22 July 2022                      
--Comments :                       
--======================================================================                 
CREATE procedure WF_SubmitForApprovalPopUp  
    @ProcessId as decimal(18, 0),  
    @RuModules_Id int,  
    @level_id int = null  
as  
set @RuModules_Id=4 --need to remove once process level Wf is implemented
declare @MtStatementProcess_ExecutionFinishDate datetime,  
        @SettlementPeriod varchar(20),  
        @ProcessName nvarchar(256),  
        @RuWorkFlowHeader_id int,  
        @RuNotificationSetup_ID int,  
        @RuNotificationSetup_EmailSubject varchar(256),  
        @RuNotificationSetup_EmailBody varchar(256)  
  
/*Get process defination for notification popup to show up on submission of process*/  
select @ProcessName = CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name),  
       @SettlementPeriod = LuAccountingMonth_MonthName,  
       @MtStatementProcess_ExecutionFinishDate = MtStatementProcess_ExecutionFinishDate  
from MtStatementProcess mt_p  
    inner join LuAccountingMonth lu_acm  
        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id_Current  
    inner join SrProcessDef SPD  
        on SPD.SrProcessDef_ID = mt_p.SrProcessDef_ID  
    inner join SrStatementDef SSD  
        on SPD.SrStatementDef_ID = SSD.SrStatementDef_ID  
where IsNull(MtStatementProcess_IsDeleted, 0) = 0  
      and mt_p.MtStatementProcess_ID = @ProcessId  
  
select @RuWorkFlowHeader_id = RuWorkFlowHeader_id  
from RuWorkFlow_header  
where RuModules_id = @RuModules_id  
select @RuNotificationSetup_ID = RuNotificationSetup_ID  
from RuNotificationSetup  
where RuWorkFlowHeader_id = @RuWorkFlowHeader_id  
      and RuNotificationSetup_CategoryKey = case  
                                                when isnull(@level_id, 0) = 1 then  
                                                    'Process_Submitted'  
                                                else  
                                                    'process_approval'  
                                            end  
  
select @RuNotificationSetup_EmailSubject  
    = replace(  
                 replace(  
                            replace(RuNotificationSetup_EmailSubject, '@ProcessName', @ProcessName),  
                            '@Period',  
                            @SettlementPeriod  
                        ),  
                 '@Process_ID',  
                 @ProcessId  
             ),  
       @RuNotificationSetup_EmailBody = RuNotificationSetup_EmailBody --replace(RuNotificationSetup_EmailBody,'@approver_name',@approver_name)               
from RuNotificationSetup  
where RuNotificationSetup_ID = @RuNotificationSetup_ID  
  
select @RuWorkFlowHeader_id RuWorkFlowHeader_id,  
       @ProcessId ProcessId,  
       @ProcessName ProcessName,  
       @SettlementPeriod SettlementPeriod,  
       @MtStatementProcess_ExecutionFinishDate ExecutionDate,  
       @RuNotificationSetup_EmailSubject EmailSubject,  
       @RuNotificationSetup_EmailBody EmailBody  
  
--Approval Required for @ProcessName Settlement ID # @Process_ID Month @Period   
  

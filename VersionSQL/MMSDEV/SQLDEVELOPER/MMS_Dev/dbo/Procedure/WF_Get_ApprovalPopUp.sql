/****** Object:  Procedure [dbo].[WF_Get_ApprovalPopUp]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure dbo.WF_Get_ApprovalPopUp                                                                
    @ProcessId as decimal(18, 0),                                                                
    @Process_Template_Id INT=null, --@Process_Template_Id                        
    @RuModules_Id int,  --@RuModules_Id                
    @level_id int = null                  
as                                                                
       --Generic variables                                  
declare                                                                
        @ProcessName nvarchar(256),                                                                
        @RuWorkFlowHeader_id int,                                                              
        @RuNotificationSetup_EmailSubject varchar(max),                                                                
        @RuNotificationSetup_EmailBody varchar(max)    ,                                      
        @RuModulesProcess_Id varchar(20)                          
                        
                  
                  
SELECT                  
 @RuModulesProcess_Id = RuModulesProcess_Id                  
FROM RuModulesProcess                  
WHERE RuModulesProcess_ProcessTemplateId = @Process_Template_Id--@RuModules_Id                  
AND RuModules_Id = @RuModules_Id--@settlementid                  
        
SELECT                  
 @RuWorkFlowHeader_id = RuWorkFlowHeader_id                  
FROM RuWorkFlow_header                  
WHERE RuModulesProcess_Id = @RuModulesProcess_Id                    
        
--IF @RuModules_Id = 4                  
--BEGIN                  
                  
DECLARE @from_sql AS VARCHAR(MAX)                  
    ,@where_query AS VARCHAR(MAX);                  
DECLARE @query AS NVARCHAR(MAX)                  
DECLARE @sql_query AS NVARCHAR(MAX)                  
DECLARE @where AS VARCHAR(MAX)                  
Declare @subject as nvarchar(max)                  
declare @subject_query as nvarchar(max)                  
                
                
SELECT                  
 @ProcessName = RuModulesProcess_Name                  
FROM RuModulesProcess                  
WHERE RuModulesProcess_Id = @RuModulesProcess_Id               
        
                  
select  @subject=STRING_AGG( CONCAT('cast(',RuModulesProcessDetails_ColumnName,' as NVARCHAR(MAX))' ),'+'' | ''+')  from RuModulesProcessDetails      
where RuModulesProcess_Id=@RuModulesProcess_Id and RuModulesProcessDetails_IsSubject=1            
and isnull(RuModulesProcessDetails_IsDeleted,0)=0          
set @subject=''+@subject+''                  
select @RuNotificationSetup_EmailSubject= CONCAT(''''+RuNotificationSetup_EmailSubject+ ''' ' , ' +', @subject)                  
FROM RuNotificationSetup                  
WHERE RuNotificationSetup_CategoryKey = 'Submitted'                  
                     
SELECT                  
 @where = RuModulesProcessDetails_ColumnName                  
FROM RuModulesProcessDetails                  
WHERE RuModulesProcess_Id = @RuModulesProcess_Id                  
AND ISNULL(RuModulesProcessDetails_IsWhere, 0) = 1            
 and isnull(RuModulesProcessDetails_IsDeleted,0)=0          
                  
                  
select @subject_query=Concat('select @Result=',@RuNotificationSetup_EmailSubject, +' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@ProcessId)                
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcess_Id              
                     
             
DECLARE @outCount1 nvarchar(max)                  
DECLARE @parameters NVARCHAR(255) = '@Result nvarchar(max) OUTPUT'                   
EXEC sp_executeSQL @subject_query, @parameters, @Result = @outCount1 OUTPUT;                  
        
SELECT                  
 @RuNotificationSetup_EmailBody =  Concat('<tr><td colspan=2>',@ProcessName, ' ', RuNotificationSetup_EmailBody,'<br><br></td></tr>')    --CONCAT(@ProcessName, ' ', RuNotificationSetup_EmailBody)             
FROM RuNotificationSetup                  
WHERE RuNotificationSetup_CategoryKey = 'Submitted'                  
          
                SELECT                  
 @from_sql = STRING_AGG(CONCAT('<tr><td><b>', RuModulesProcessDetails_Label, ':</b></td><td>'' + isnull(cast(', ISNULL(RuModulesProcessDetails_ColumnName, ''), ' as NVARCHAR(MAX)),'''')+''</td></tr>'), '')                  
FROM RuModulesProcessDetails                  
WHERE RuModulesProcess_Id = @RuModulesProcess_Id   and isnull(RuModulesProcessDetails_IsDeleted,0)=0            
and isnull(RuModulesProcess_ShowOnScreen,0)=1         
     print @RuModulesProcess_Id
SET @from_sql = '''' + @from_sql + ''''                  
          
DECLARE @HTMLTable VARCHAR(MAX)                  
                  
DECLARE @tableValues as nvarchar(max)                  
            
select @query=Concat('select @Result=', @from_sql,' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@ProcessId)                  
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcess_Id                   
         print @query       
DECLARE @outCount NVARCHAR(MAX)                  
DECLARE @params NVARCHAR(255) = '@Result nvarchar(max) OUTPUT'                  
EXEC sp_executeSQL @query                  
      ,@params                  
      ,@Result = @outCount OUTPUT;                  
                  
DECLARE @EmailBody AS VARCHAR(MAX)                  
SET @EmailBody = '                  
<html>                  
</head>                  
<body>                  
<table>'                  
+                  
@RuNotificationSetup_EmailBody                  
+                  
@outCount                  
+                  
'</table></body></html>'                  
                  
                  
                  
                  
SELECT                  
 @RuWorkFlowHeader_id RuWorkFlowHeader_id                  
   ,@ProcessId ProcessId                  
   ,@outCount1 EmailSubject                  
   ,(@EmailBody) AS [EmailBody]                  
                
--END             
          
---------Below code to change          
/*                
                
                
declare @MtStatementProcess_ExecutionFinishDate datetime,                                                                
        @SettlementPeriod varchar(20),                                                                
        @ProcessName nvarchar(256),                                                                
        @RuWorkFlowHeader_id int,                                                                
        @RuNotificationSetup_ID int,                                                                
        @RuNotificationSetup_EmailSubject varchar(max),                                                                
        @RuNotificationSetup_EmailBody varchar(max)    ,                                      
        @RuModulesProcess_Id varchar(20),                           
                                  
  @MtPartyCategory_ApplicationDate DATETIME,                                                    
  @party_type VARCHAR(64),                                                    
  @ApplicationId VARCHAR(250),                                                    
  @Category VARCHAR(64),                                                    
  @Period VARCHAR(20),                                                    
  @upload_date  datetime ,                                                  
  @description varchar(max) ,                                          
  @MtRegisterationActivity_Id decimal(18,0),                                          
  @Modify_Application_Date DATE,                                          
  @Deregister_Application_Date DATE,                                          
  @Suspension_Application_Date DATE,                                          
  @withdraw_Suspension_Application_Date DATE,                                          
  @termination_Application_Date date ,   
  @modify_Suspension_Application_Date date ,                                    
  @Suspension_Modification_Application_No varchar(30),                           
                                    
                             
                                  
  ---Contract Registration Variables        
    @Contract_Type varchar(256),                                                    
    @Buyer_name_Category varchar(256),                                  
    @Seller_name_Category varchar(256),                                   
   @Contract_Registration_Date date,                                  
   @Application_Date date,                                  
   @ContractDuration varchar(56),                                 
   @Modify_Application_no varchar(256)  ,                              
   @Deregister_Application_no varchar(256),                              
   @Suspension_Application_no varchar(256),                              
   @withdraw_Suspension_Application_no varchar(256),                              
   @termination_Application_no varchar(256)                  
                
                  
IF  @RuModules_Id BETWEEN 1 AND 12  OR  @RuModules_Id = 27  or @RuModules_Id = 28 or @RuModules_Id = 29 or @RuModules_Id = 30                      
begin                        
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
                  
                  
select @RuNotificationSetup_EmailSubject = replace(replace(replace(ISNULL(RuNotificationSetup_EmailSubject,''), '@ProcessName', @ProcessName),                                                      
                 '@Period',@SettlementPeriod),                                                      
                 '@Process_ID', @ProcessId ),                                                      
      @RuNotificationSetup_EmailBody  = replace(replace(replace(replace(ISNULL(RuNotificationSetup_EmailBody,''), '@ProcessName', @ProcessName),                                                      
                    '@ProcessId', @ProcessId ),                                                      
                    '@SettlementPeriod', @SettlementPeriod ),                                                      
                    '@MtStatementProcess_ExecutionFinishDate', Format(ISNULL(@MtStatementProcess_ExecutionFinishDate,''), 'dd-MMM-yyyy hh:mm tt'))                                                      
                  
from RuNotificationSetup                                                      
where RuNotificationSetup_ID = @RuNotificationSetup_ID                                                      
                  
select @RuWorkFlowHeader_id RuWorkFlowHeader_id,    
       @ProcessId ProcessId,                                                      
       @ProcessName ProcessName,                                                   
       @SettlementPeriod SettlementPeriod,                                                      
       @MtStatementProcess_ExecutionFinishDate ExecutionDate,                                                      
       @RuNotificationSetup_EmailSubject EmailSubject,                                                      
       @RuNotificationSetup_EmailBody EmailBody                                                      
                  
end                          
                  
/*SO DATA MANAGEMENT*/                  
IF @RuModules_Id = 19                  
BEGIN                  
                  
                  
SELECT                  
 @ProcessName = LuSOFileTemplate_Name                  
   ,@Period = LuAccountingMonth_MonthName                  
 ,@upload_date = MtSOFileMaster_CreatedOn                  
   ,@description = MtSOFileMaster_Description                  
FROM MtSOFileMaster mt_p                  
INNER JOIN LuAccountingMonth lu_acm                  
 ON lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id                  
INNER JOIN LuSOFileTemplate SPD                  
 ON SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id                  
WHERE ISNULL(MtSOFileMaster_IsDeleted, 0) = 0                  
AND mt_p.MtSOFileMaster_Id = @ProcessId                  
                  
SELECT                  
 @RuNotificationSetup_EmailSubject = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(RuNotificationSetup_EmailSubject, ''), '@ProcessName', @ProcessName),                  
 '@Period', @Period),                  
 '@Process_ID', @ProcessId),                  
 '@upload_date', @upload_date)                  
   ,@RuNotificationSetup_EmailBody = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(RuNotificationSetup_EmailBody, ''), '@ProcessName', @ProcessName),                  
 '@ProcessId', @ProcessId),                  
 '@Period', @Period),                  
 '@upload_date', FORMAT(ISNULL(@upload_date, ''), 'dd-MMM-yyyy hh:mm tt')),                  
 '@description', ISNULL(@description, ''))                  
                  
                  
FROM RuNotificationSetup                  
WHERE RuNotificationSetup_ID = @RuNotificationSetup_ID                  
                  
SELECT                  
 @RuWorkFlowHeader_id RuWorkFlowHeader_id                  
   ,@ProcessId ProcessId                  
   , --file ID                                                     
 @ProcessName ProcessName                  
   ,  --Template name                                                    
 @Period file_Period                  
   ,  --month                                                    
 @upload_date ExecutionDate                  
   ,   --upload date                                                     
 @RuNotificationSetup_EmailSubject EmailSubject                  
   ,@RuNotificationSetup_EmailBody EmailBody                  
                  
                  
END                  
                  
/*Registration*/                  
IF @RuModulesProcess_Id BETWEEN 13 AND 18                  
 OR @RuModulesProcess_Id = 20                  
BEGIN                  
                  
SELECT                  
 @ProcessName = MtPartyRegisteration_Name                  
   ,@MtPartyCategory_ApplicationDate = MtPartyCategory_ApplicationDate                  
   ,@party_type = SrPartyType_Name                  
   ,@ApplicationId = MtPartyCategory_ApplicationId                  
   ,@Category = SrCategory_Name                  
FROM MtPartyRegisteration mpr                  
INNER JOIN SrPartyType spt                  
 ON mpr.SrPartyType_Code = spt.SrPartyType_Code                  
INNER JOIN MtPartyCategory mpc                  
 ON mpr.MtPartyRegisteration_Id = mpc.MtPartyRegisteration_Id                  
INNER JOIN SrCategory sc                  
 ON mpc.SrCategory_Code = sc.SrCategory_Code               
  AND mpr.MtPartyRegisteration_Id = @ProcessId                  
                  
                  
SELECT TOP 1                  
 @MtRegisterationActivity_Id = MtRegisterationActivity_Id                  
   ,@Suspension_Application_Date = MtRegisterationActivities_ApplicationDate                  
FROM MtRegisterationActivities                  
WHERE MtPartyRegisteration_Id = @ProcessId                  
AND MtRegisterationActivities_ACtion = 'SDRF'                  
                  
IF @RuModulesProcess_Id IN (16, 20)                  
BEGIN                  
SELECT TOP 1                  
 @Suspension_Application_Date = MtRegisterationActivities_ApplicationDate                  
FROM MtRegisterationActivities                  
WHERE MtRegisterationActivities_ACtion = 'SDRF'                  
AND MtPartyRegisteration_Id = @ProcessId                  
ORDER BY MtRegisterationActivity_Id DESC                  
END                  
IF @RuModulesProcess_Id = 14                  
BEGIN                  
SELECT TOP 1                  
 @Modify_Application_Date = MtRegisterationActivities_ApplicationDate                  
FROM MtRegisterationActivities                  
WHERE MtRegisterationActivities_ACtion IN ('MDRA', 'MPA')                  
AND MtPartyRegisteration_Id = @ProcessId                  
ORDER BY MtRegisterationActivity_Id DESC                  
END                  
                  
IF @RuModulesProcess_Id = 15                  
BEGIN                  
SELECT TOP 1                  
 @Deregister_Application_Date = MtRegisterationActivities_ApplicationDate                  
FROM MtRegisterationActivities                  
WHERE MtRegisterationActivities_ACtion IN ('IDER', 'ADER')                  
AND MtPartyRegisteration_Id = @ProcessId                  
ORDER BY MtRegisterationActivity_Id DESC                  
END                  
                  
IF @RuModulesProcess_Id = 17                  
BEGIN                  
SELECT TOP 1                  
 @withdraw_Suspension_Application_Date = MtRegisterationActivities_ApplicationDate                  
FROM MtRegisterationActivities                  
WHERE MtRegisterationActivities_ACtion IN ('WSPF')                  
AND ref_Id = @MtRegisterationActivity_Id                  
ORDER BY MtRegisterationActivity_Id DESC                  
                  
END                  
                  
IF @RuModulesProcess_Id = 18                  
BEGIN                  
SELECT TOP 1                  
 @termination_Application_Date = MtRegisterationActivities_ApplicationDate                  
FROM MtRegisterationActivities                  
WHERE MtRegisterationActivities_ACtion IN ('TERM', 'TPA', 'TEDR')                  
AND ref_Id = @MtRegisterationActivity_Id                  
ORDER BY MtRegisterationActivity_Id DESC                  
                  
END                  
                  
IF @RuModulesProcess_Id = 20                  
BEGIN                  
SELECT TOP 1                  
 @modify_Suspension_Application_Date = MtRegisterationActivities_ApplicationDate                  
   ,@Suspension_Modification_Application_No = MtRegisterationActivities_ApplicationNo                  
FROM MtRegisterationActivities                  
WHERE MtRegisterationActivities_ACtion IN ('SMDR', 'SMPA')                  
AND ref_Id = @MtRegisterationActivity_Id                  
ORDER BY MtRegisterationActivity_Id DESC                  
                  
END                  
                  
                  
                  
                  
                  
                  
SELECT                  
 @RuNotificationSetup_EmailSubject = REPLACE(REPLACE(ISNULL(RuNotificationSetup_EmailSubject, ''), '@ProcessName', @ProcessName),                  
 '@Process_ID', @ProcessId)                  
   ,@RuNotificationSetup_EmailBody = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(RuNotificationSetup_EmailBody, ''), '@ProcessName', @ProcessName)                  
                 
                  
                  
                  
 , '@ProcessId', @ProcessId)                  
 , '@Type', @party_type)                  
 , '@Application_Date', FORMAT(ISNULL(@MtPartyCategory_ApplicationDate, ''), 'dd-MMM-yyyy'))                  
 , '@Application_no', @ApplicationId)                  
 , '@Category', ISNULL(@Category, ''))                  
 , '@Modify_Application_Date', ISNULL(FORMAT(@Modify_Application_Date, 'dd-MMM-yyyy'), ''))                  
 , '@Deregister_Application_Date', ISNULL(FORMAT(@Deregister_Application_Date, 'dd-MMM-yyyy'), ''))                  
 , '@Suspension_Application_Date', ISNULL(FORMAT(@Suspension_Application_Date, 'dd-MMM-yyyy'), ''))                  
 , '@withdraw_Suspension_Application_Date', ISNULL(FORMAT(@withdraw_Suspension_Application_Date, 'dd-MMM-yyyy'), ''))                  
 , '@termination_Application_Date', ISNULL(FORMAT(@termination_Application_Date, 'dd-MMM-yyyy'), ''))                  
 , '@Suspension_Modification_Application_Date', ISNULL(FORMAT(@modify_Suspension_Application_Date, 'dd-MMM-yyyy'), ''))                  
 , '@Suspension_Modification_Application_No', ISNULL(@Suspension_Modification_Application_No, ''))                  
FROM RuNotificationSetup                  
WHERE RuNotificationSetup_ID = @RuNotificationSetup_ID                  
                  
SELECT                  
 @RuWorkFlowHeader_id RuWorkFlowHeader_id                  
   ,@ProcessId ProcessId                  
   ,@ProcessName ProcessName                  
   ,@RuNotificationSetup_EmailSubject EmailSubject                  
   ,@RuNotificationSetup_EmailBody EmailBody                  
   ,@party_type party_type                  
   ,@MtPartyCategory_ApplicationDate MtPartyCategory_ApplicationDate                  
   ,@ApplicationId ApplicationId                  
   ,@Category Category                  
                  
                  
END                  
/*Contract Registration*/                  
IF @RuModulesProcess_Id BETWEEN 21 AND 26                  
BEGIN                  
                  
                  
                  
                  
SELECT                  
 @Contract_Type = SrContractType_Name                  
   ,@Buyer_name_Category = ((SELECT                  
   MtPartyRegisteration_Name                  
  FROM MtPartyRegisteration                  
  WHERE MtPartyRegisteration_Id = MtContractRegistration_BuyerId)                  
 + '-' + (SELECT                  
   SrCategory_Name                  
  FROM MtPartyCategory PC                  
  INNER JOIN SrCategory C                  
   ON PC.SrCategory_Code = C.SrCategory_Code                  
  WHERE PC.MtPartyCategory_Id = MtContractRegistration_BuyerCategoryId)                  
 )                  
   ,@Seller_name_Category = ((SELECT                  
   MtPartyRegisteration_Name                  
  FROM MtPartyRegisteration                  
  WHERE MtPartyRegisteration_Id = MtContractRegistration_SellerId)                  
 + '-' + (SELECT                  
   SrCategory_Name                  
  FROM MtPartyCategory PC                  
  INNER JOIN SrCategory C                  
   ON PC.SrCategory_Code = C.SrCategory_Code                  
  WHERE PC.MtPartyCategory_Id = MtContractRegistration_SellerCategoryId)                  
 )                  
   ,@Contract_Registration_Date = MtContractRegistration_ContractDate                  
   ,@Application_Date = MtContractRegistration_ApplicationDate                  
   ,@ApplicationId = MtContractRegistration_ApplicationNubmer                  
   ,@ContractDuration = FORMAT(ISNULL(MtContractRegistration_EffectiveFrom, ''), 'dd-MMM-yyyy') + '-' + FORMAT(ISNULL(MtContractRegistration_EffectiveTo, ''), 'dd-MMM-yyyy')                  
                  
FROM MtContractRegistration mpr                  
INNER JOIN SrContractType CT                  
 ON mpr.SrContractType_Id = ct.SrContractType_Id                  
  AND mpr.MtContractRegistration_Id = @ProcessId          
                  
IF @RuModulesProcess_Id = 22                  
BEGIN                  
SELECT TOP 1                  
 @Modify_Application_Date = MtContractRegistrationActivities_ApplicationDate                  
   ,@Modify_Application_no = MtContractRegistrationActivities_ApplicationNo                  
FROM MtContractRegistrationActivities                  
WHERE MtContractRegistrationActivities_Action IN ('CAMD', 'CAMI')                  
AND MtContractRegistration_Id = @ProcessId                  
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0                  
ORDER BY MtContractRegistrationActivity_Id DESC                  
END                  
                  
IF @RuModulesProcess_Id = 23                  
BEGIN                  
SELECT TOP 1                  
 @Deregister_Application_Date = MtContractRegistrationActivities_ApplicationDate               
   ,@Deregister_Application_no = MtContractRegistrationActivities_ApplicationNo                  
FROM MtContractRegistrationActivities                  
WHERE MtContractRegistrationActivities_Action IN ('CADD', 'CADI')                  
AND MtContractRegistration_Id = @ProcessId                  
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0                  
ORDER BY MtContractRegistrationActivity_Id DESC                  
END                  
IF @RuModulesProcess_Id = 24                  
BEGIN                  
SELECT TOP 1                  
 @Suspension_Application_Date = MtContractRegistrationActivities_ApplicationDate                  
   ,@Suspension_Application_no = MtContractRegistrationActivities_ApplicationNo                  
FROM MtContractRegistrationActivities                  
WHERE MtContractRegistrationActivities_Action IN ('CASD', 'CASI')                  
AND MtContractRegistration_Id = @ProcessId                  
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0                  
ORDER BY MtContractRegistrationActivity_Id DESC                  
END                  
                  
IF @RuModulesProcess_Id = 25                  
BEGIN                  
SELECT TOP 1                  
 @withdraw_Suspension_Application_Date = MtContractRegistrationActivities_ApplicationDate                  
   ,@withdraw_Suspension_Application_no = MtContractRegistrationActivities_ApplicationNo                  
FROM MtContractRegistrationActivities                  
WHERE MtContractRegistrationActivities_Action IN ('CAWD', 'CAWI')                  
AND MtContractRegistration_Id = @ProcessId                  
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0                  
ORDER BY MtContractRegistrationActivity_Id DESC                  
END           
                  
IF @RuModulesProcess_Id = 26                  
BEGIN                  
SELECT TOP 1                  
 @termination_Application_Date = MtContractRegistrationActivities_ApplicationDate                  
   ,@termination_Application_no = MtContractRegistrationActivities_ApplicationNo                  
FROM MtContractRegistrationActivities                  
WHERE MtContractRegistrationActivities_Action IN ('CATD', 'CATI')                  
AND MtContractRegistration_Id = @ProcessId                  
AND ISNULL(MtContractRegistrationActivities_Deleted, 0) = 0                  
ORDER BY MtContractRegistrationActivity_Id DESC                  
END                  
                  
                  
                  
SELECT                  
 @RuNotificationSetup_EmailSubject = REPLACE(ISNULL(RuNotificationSetup_EmailSubject, ''), '@Process_ID', @ProcessId)                  
   ,@RuNotificationSetup_EmailBody = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(                  
 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(RuNotificationSetup_EmailBody, ''), '@Contract_Type', @Contract_Type)                  
 , '@Buyer_name_Category', @Buyer_name_Category)                  
 , '@Seller_name_Category', @Seller_name_Category)                  
 , '@Contract_Registration_Date', FORMAT(ISNULL(@Contract_Registration_Date, ''), 'dd-MMM-yyyy'))                  
 , '@Application_Date', FORMAT(ISNULL(@Application_Date, ''), 'dd-MMM-yyyy'))                  
 , '@Application_no', ISNULL(@ApplicationId, ''))                  
 , '@ContractDuration', @ContractDuration)                  
 , '@Modify_Application_Date', FORMAT(ISNULL(@Modify_Application_Date, ''), 'dd-MMM-yyyy'))                  
 , '@Modify_Application_no', ISNULL(@Modify_Application_no, ''))                  
 , '@Deregister_Application_Date', FORMAT(ISNULL(@Deregister_Application_Date, ''), 'dd-MMM-yyyy'))                  
 , '@Deregister_Application_no', ISNULL(@Deregister_Application_no, ''))                  
 , '@Suspension_Application_Date', FORMAT(ISNULL(@Suspension_Application_Date, ''), 'dd-MMM-yyyy'))                  
 , '@Suspension_Application_no', ISNULL(@Suspension_Application_no, ''))                  
 , '@withdraw_Suspension_Application_Date', FORMAT(ISNULL(@withdraw_Suspension_Application_Date, ''), 'dd-MMM-yyyy'))                  
 , '@withdraw_Suspension_Application_no', ISNULL(@withdraw_Suspension_Application_no, ''))                  
 , '@termination_Application_Date', FORMAT(ISNULL(@termination_Application_Date, ''), 'dd-MMM-yyyy'))                  
 , '@termination_Application_no', ISNULL(@termination_Application_no, ''))                  
                  
                  
FROM RuNotificationSetup                  
WHERE RuNotificationSetup_ID = @RuNotificationSetup_ID                  
                  
                  
                  
SELECT                  
 @RuWorkFlowHeader_id RuWorkFlowHeader_id                  
   ,@ProcessId ProcessId                  
   ,@RuNotificationSetup_EmailSubject EmailSubject                  
   ,@RuNotificationSetup_EmailBody EmailBody                  
                  
END                  
  */                
--Approval Required for @ProcessName Settlement ID # @Process_ID Month @Period 

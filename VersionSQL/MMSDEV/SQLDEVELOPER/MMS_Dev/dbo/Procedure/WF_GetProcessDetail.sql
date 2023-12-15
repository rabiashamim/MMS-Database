/****** Object:  Procedure [dbo].[WF_GetProcessDetail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   procedure dbo.WF_GetProcessDetail                                                                           
@RuWorkFlowHeader_id int,                                                                                        
@MtWFHistory_Process_id decimal(18,0) ,                                                                                          
@MtWFHistory_LevelID int,                                                                                        
@user_id  decimal(18,0),                                                                                      
@MtWFHistory_id varchar(32),                                                                                
@status varchar(32)                                                                                
as                                                        
                                                      
update MtWFHistory                                                            
set notify_flag=0                                                             
 where  RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                                                                           
 and MtWFHistory_Process_id=@MtWFHistory_Process_id                                                                                
 and MtWFHistory_id=@MtWFHistory_id                                           
                                           
 if @status='OPEN'                                          
 begin                                           
 update MtWFHistory                                                            
set is_read=1                                                             
 where  RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                                                                           
 and MtWFHistory_Process_id=@MtWFHistory_Process_id                                                                                
 and MtWFHistory_id=@MtWFHistory_id                                           
                                          
 end                                          
                                          
                                          
                                                       
CREATE table #WF_history                                                                                        
(RuWorkFlowHeader_id int,                                                                                        
 From_resource varchar(128),                                                                                        
 To_resource varchar(128),                                                                                        
 MtWFHistory_Process_id decimal(18,0) ,                                                                                          
 MtWFHistory_Process_name varchar(256),                                                                                        
 MtWFHistory_NotificationSubject varchar(256),                                                                                        
 MtWFHistory_ActionDate datetime,                                                                                        
 MtWFHistory_LevelID int,                                                                                        
 MtWFHistory_SequenceID int,                                                                                        
 [Status] varchar(32),                                                                                        
 SettlementPeriod varchar(20),                                                                                        
 MtStatementProcess_ExecutionFinishDate datetime,                                                                                        
 NotificationBody varchar(max),                                                                                        
 MtWFHistory_Action char(4),                                  
 MtWFHistory_comments varchar(512) ,                                             
 notify_flag int ,         
 is_read int                                          
 )                                                     
                       
 if @status='OPEN' and exists(Select 1 from MtWFHistory                                     
 where MtWFHistory_id=@MtWFHistory_id and (MtWFHistory_ProcessRejected=1 or MtWFHistory_ProcessFinalApproval=1) )                                                                          
 begin                                                
 set @status='CLOSED'                                                                          
 end                                                 
                                                                                        
 declare @module_id int,@RuModulesProcess_Name varchar(128) ,@RuModulesProcess_Id int ,@RuModulesProcess_ProcessTemplateId int                                                                                      
                                                                                        
                    
                    
select @RuModulesProcess_Id=RuModulesProcess_Id from RuWorkFlow_header where RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                              
 select @RuModulesProcess_ProcessTemplateId=RuModulesProcess_ProcessTemplateId,                    
  @module_id=RuModules_Id,                    
  @RuModulesProcess_Name=RuModulesProcess_Name                     
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcess_Id                                             
                                                                       
 declare                                                                                          
  @MtStatementProcess_ExecutionFinishDate datetime                                                                                                  
 ,@SettlementPeriod varchar(20)                                                  
 ,@LuSOFileTemplate_Url_type VARCHAR(150)                                                  
 ,@LuSOFileTemplate_Url_file VARCHAR(150)            
 ,@SrContractType_Id int           
 /*            
 ,@NotificationBody  varchar(max)                                                                                          
 ,@RuNotificationSetup_ID int ,                                                          
  @MtPartyCategory_ApplicationDate DATETIME,                                                            
  @party_type VARCHAR(64),                                                            
  @ApplicationId VARCHAR(250),                                                            
  @Category VARCHAR(64),                                                            
  @Period VARCHAR(20),                                                            
  @upload_date  datetime ,                                                          
  @description varchar(max) ,                                                    
  @LuSOFileTemplate_Url_type VARCHAR(150) ,                                                  
  @LuSOFileTemplate_Url_file VARCHAR(150) ,                                                
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
   @ContractDuration varchar(56),                                       @Modify_Application_no varchar(256)  ,                                        
   @Deregister_Application_no varchar(256),                                        
   @Suspension_Application_no varchar(256),                                        
   @withdraw_Suspension_Application_no varchar(256),                                        
   @termination_Application_no varchar(256),                                    
   @SrContractType_Id int                                    
  */                
  IF @module_id =3                                                
 BEGIN                                                          
 select                                                        
 @LuSOFileTemplate_Url_type=SUBSTRING(LuSOFileTemplate_Url, CHARINDEX('/', LuSOFileTemplate_Url)+1, CHARINDEX('?', LuSOFileTemplate_Url) - CHARINDEX('/', LuSOFileTemplate_Url)-1),                  
 @LuSOFileTemplate_Url_file=SUBSTRING(LuSOFileTemplate_Url, CHARINDEX('?', LuSOFileTemplate_Url)+1, CHARINDEX('=', LuSOFileTemplate_Url) - CHARINDEX('?', LuSOFileTemplate_Url)-1)                                                 
from MtSOFileMaster mt_p                                                                        
    inner join LuAccountingMonth lu_acm                                                                        
        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id                                                    
  inner join LuSOFileTemplate SPD                                                                        
        on SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id                                                     
where IsNull(MtSOFileMaster_IsDeleted, 0) = 0                                                                        
      and mt_p.MtSOFileMaster_Id = @MtWFHistory_Process_id                                                                                   
 end            
           
   IF @module_id =12                                                
 BEGIN           
   select                      
   @SrContractType_Id=mpr.SrContractType_Id                                    
                                               
FROM MtContractRegistration mpr inner join SrContractType CT                                                    
            on mpr.SrContractType_Id = ct.SrContractType_Id                                                                      
      and mpr.MtContractRegistration_Id = @MtWFHistory_Process_id              
   END             
                                        
                                        
   /*                                     
                                        
 IF @module_id=4--(@module_id BETWEEN 1 AND 12)  OR  (@module_id=27)  OR  (@module_id=28)  OR  (@module_id=29) OR  (@module_id=30) OR  (@module_id=31)                                                
 begin                                                          
 select                                                     
@SettlementPeriod=LuAccountingMonth_MonthName                                                                                                                
  ,@MtStatementProcess_ExecutionFinishDate=MtStatementProcess_ExecutionFinishDate                                                             
from MtStatementProcess  mt_p                                     
inner join LuAccountingMonth lu_acm on lu_acm.LuAccountingMonth_Id=mt_p.LuAccountingMonth_Id_Current                                              
where IsNull(MtStatementProcess_IsDeleted,0)=0 and mt_p.MtStatementProcess_ID=@MtWFHistory_Process_id                                                                                         
 end                                                            
IF @module_id =19                                                          
 BEGIN                                                          
 select                                                        
  /*@Period*/@SettlementPeriod = LuAccountingMonth_MonthName,                                                             
       /*@upload_date*/ @MtStatementProcess_ExecutionFinishDate= MtSOFileMaster_CreatedOn,                                                          
    @description=MtSOFileMaster_Description  ,                                          
 @LuSOFileTemplate_Url_type=SUBSTRING(LuSOFileTemplate_Url, CHARINDEX('/', LuSOFileTemplate_Url)+1, CHARINDEX('?', LuSOFileTemplate_Url) - CHARINDEX('/', LuSOFileTemplate_Url)-1),--LuSOFileTemplate_Url                                                    
 @LuSOFileTemplate_Url_file=SUBSTRING(LuSOFileTemplate_Url, CHARINDEX('?', LuSOFileTemplate_Url)+1, CHARINDEX('=', LuSOFileTemplate_Url) - CHARINDEX('?', LuSOFileTemplate_Url)-1)                                                   
from MtSOFileMaster mt_p                                                                        
    inner join LuAccountingMonth lu_acm                                                                        
 on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id                                                    
  inner join LuSOFileTemplate SPD                                                                        
        on SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id                                                     
where IsNull(MtSOFileMaster_IsDeleted, 0) = 0                                                                        
      and mt_p.MtSOFileMaster_Id = @MtWFHistory_Process_id                                                                                   
 end                                                           
                                                       
   IF @module_id BETWEEN 13 AND 18     or  @module_id=20                            
 BEGIN                                                          
 select /*@MtPartyCategory_ApplicationDate*/@MtStatementProcess_ExecutionFinishDate = MtPartyCategory_ApplicationDate,                                                            
    @party_type=SrPartyType_Name,                                                            
    @ApplicationId=MtPartyCategory_ApplicationId,                                                            
    @Category=SrCategory_Name                                                            
FROM MtPartyRegisteration mpr INNER JOIN                                                             
SrPartyType spt ON mpr.SrPartyType_Code = spt.SrPartyType_Code                                                            
INNER JOIN MtPartyCategory mpc ON mpr.MtPartyRegisteration_Id = mpc.MtPartyRegisteration_Id                                                            
INNER JOIN SrCategory sc ON mpc.SrCategory_Code = sc.SrCategory_Code                                                                      
where IsNull(mpr.isDeleted, 0) = 0                                                           
and mpr.MtPartyRegisteration_Id = @MtWFHistory_Process_id                                                    
                                                
SELECT  TOP 1                                                    
   @MtRegisterationActivity_Id = MtRegisterationActivity_Id,                                                
   @Suspension_Application_Date=MtRegisterationActivities_ApplicationDate                     
FROM                                                       
 MtRegisterationActivities                                                     
WHERE                                                     
     MtPartyRegisteration_Id=@MtWFHistory_Process_id                                                     
    and MtRegisterationActivities_ACtion = 'SDRF'                                                 
                                                
 IF @module_id  in (16,20)                                                
 BEGIN                                                
 SELECT TOP 1 @Suspension_Application_Date= MtRegisterationActivities_ApplicationDate                                                
FROM MtRegisterationActivities                                                         
WHERE                                                        
MtRegisterationActivities_ACtion = 'SDRF'                                           
AND MtPartyRegisteration_Id=@MtWFHistory_Process_id                                                      
order by MtRegisterationActivity_Id desc                                                 
 END                                                
 IF @module_id=14                                                
 BEGIN                                               
 SELECT TOP 1 @Modify_Application_Date= MtRegisterationActivities_ApplicationDate                                                
FROM MtRegisterationActivities                                                         
WHERE                                 
MtRegisterationActivities_ACtion in ('MDRA' ,'MPA')                                                     
AND MtPartyRegisteration_Id=@MtWFHistory_Process_id                                                      
order by MtRegisterationActivity_Id desc                                                 
 END                                                
                                                
  IF @module_id=15                                                
 BEGIN                                                
 SELECT TOP 1 @Deregister_Application_Date= MtRegisterationActivities_ApplicationDate                                                
FROM MtRegisterationActivities                                                         
WHERE                                                        
MtRegisterationActivities_ACtion in ('IDER' ,'ADER')                                                  
AND MtPartyRegisteration_Id=@MtWFHistory_Process_id                                                      
order by MtRegisterationActivity_Id desc                                                 
 END                                                
                    
   IF @module_id=17                                                
 BEGIN                                                
 SELECT TOP 1 @withdraw_Suspension_Application_Date= MtRegisterationActivities_ApplicationDate                                                
FROM MtRegisterationActivities                                                         
WHERE                                                        
MtRegisterationActivities_ACtion in ('WSPF')                                          
AND ref_Id=@MtRegisterationActivity_Id                                                      
order by MtRegisterationActivity_Id desc                                                 
                                                
 END                                                
                                                
   IF @module_id=18                                                
 BEGIN                                                
 SELECT TOP 1 @termination_Application_Date= MtRegisterationActivities_ApplicationDate                                                
FROM MtRegisterationActivities                                             
WHERE                                                        
MtRegisterationActivities_ACtion in ('TERM' ,'TPA','TEDR')                                                     
AND ref_Id=@MtRegisterationActivity_Id                                                      
order by MtRegisterationActivity_Id desc                                                 
                                                
 END      
                                              
     IF @module_id=20                                                    
  BEGIN                                                    
 SELECT TOP 1 @modify_Suspension_Application_Date= MtRegisterationActivities_ApplicationDate                                               
 ,@Suspension_Modification_Application_No =MtRegisterationActivities_ApplicationNo                                              
FROM MtRegisterationActivities                                                             
WHERE                                                            
MtRegisterationActivities_ACtion in ('SMDR','SMPA')                                                         
AND ref_Id=@MtRegisterationActivity_Id                              
order by MtRegisterationActivity_Id desc                                                     
                
 END                                                     
                                                
 END                                                           
/*Contract Registration*/                                              
 IF @module_id BETWEEN 21 AND 26                                            
 BEGIN                                                                   
select                                                                                  
     @Contract_Type = SrContractType_Name,                                                              
     @Buyer_name_Category=((select MtPartyRegisteration_Name                                              
       from MtPartyRegisteration  where MtPartyRegisteration_Id=MtContractRegistration_BuyerId)+'-'+                                            
       (select SrCategory_Name from MtPartyCategory PC                                                  
    inner join SrCategory C                                                  
        on PC.SrCategory_Code = C.SrCategory_Code                                            
  where PC.MtPartyCategory_Id=MtContractRegistration_BuyerCategoryId )),                                             
 @Seller_name_Category=((select MtPartyRegisteration_Name                                              
       from MtPartyRegisteration  where MtPartyRegisteration_Id=MtContractRegistration_SellerId)+'-'+                              
       (select SrCategory_Name from MtPartyCategory PC                                                  
    inner join SrCategory C                                                  
        on PC.SrCategory_Code = C.SrCategory_Code                                            
  where PC.MtPartyCategory_Id=MtContractRegistration_SellerCategoryId )),                              
   @Contract_Registration_Date= MtContractRegistration_ContractDate,                                            
   @Application_Date=MtContractRegistration_ApplicationDate,                                            
   @ApplicationId=MtContractRegistration_ApplicationNubmer,                                            
   @ContractDuration=Format(ISNULL(MtContractRegistration_EffectiveFrom,''),'dd-MMM-yyyy')+'-'+Format(ISNULL(MtContractRegistration_EffectiveTo,''),'dd-MMM-yyyy')        ,                                    
   @SrContractType_Id=mpr.SrContractType_Id                                    
                                               
FROM MtContractRegistration mpr inner join SrContractType CT                                                    
            on mpr.SrContractType_Id = ct.SrContractType_Id                                                                      
      and mpr.MtContractRegistration_Id = @MtWFHistory_Process_id                                                     
                                                       
 IF @module_id=22                                                    
 BEGIN                                                    
 SELECT TOP 1 @Modify_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                                            
 @Modify_Application_no=MtContractRegistrationActivities_ApplicationNo                                            
FROM MtContractRegistrationActivities                                                             
WHERE                                                            
MtContractRegistrationActivities_Action in ('CAMD' ,'CAMI')                                                         
AND MtContractRegistration_Id=@MtWFHistory_Process_id                                            
and isnull(MtContractRegistrationActivities_Deleted,0)=0                                        
order by MtContractRegistrationActivity_Id desc                                                     
 END                                         
                                         
  IF @module_id=23                                                   
 BEGIN                                                    
 SELECT TOP 1 @Deregister_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                    
 @Deregister_Application_no=MtContractRegistrationActivities_ApplicationNo                               
FROM MtContractRegistrationActivities                                                             
WHERE                                                            
MtContractRegistrationActivities_Action in ('CADD' ,'CADI')                                                         
AND MtContractRegistration_Id=@MtWFHistory_Process_id                                            
and isnull(MtContractRegistrationActivities_Deleted,0)=0                                        
order by MtContractRegistrationActivity_Id desc                                   
 END                                              
  IF @module_id=24                                                   
 BEGIN                                                    
 SELECT TOP 1 @Suspension_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                                            
 @Suspension_Application_no=MtContractRegistrationActivities_ApplicationNo                                            
FROM MtContractRegistrationActivities                                                             
WHERE                                                            
MtContractRegistrationActivities_Action in ('CASD' ,'CASI')                                                         
AND MtContractRegistration_Id=@MtWFHistory_Process_id                                            
and isnull(MtContractRegistrationActivities_Deleted,0)=0                                
order by MtContractRegistrationActivity_Id desc                                                     
 END                                        
                            
   IF @module_id=25                                                   
 BEGIN                                                    
 SELECT TOP 1 @withdraw_Suspension_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                                            
 @withdraw_Suspension_Application_no=MtContractRegistrationActivities_ApplicationNo                                            
FROM MtContractRegistrationActivities                                                             
WHERE                                                  
MtContractRegistrationActivities_Action in ('CAWD' ,'CAWI')                                                         
AND MtContractRegistration_Id=@MtWFHistory_Process_id                                            
and isnull(MtContractRegistrationActivities_Deleted,0)=0                                        
order by MtContractRegistrationActivity_Id desc                                                     
 END                                         
                                         
    IF @module_id=26                                                   
 BEGIN                                                    
 SELECT TOP 1 @termination_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                                            
 @termination_Application_no=MtContractRegistrationActivities_ApplicationNo                                            
FROM MtContractRegistrationActivities                                                             
WHERE                                                    
MtContractRegistrationActivities_Action in ('CATD' ,'CATI')                                                         
AND MtContractRegistration_Id=@MtWFHistory_Process_id                                            
and isnull(MtContractRegistrationActivities_Deleted,0)=0                                        
order by MtContractRegistrationActivity_Id desc                                                     
 END                                         
                                       
 END                                        
                                        
                                        
                            
                                        
     */                                      
                                                          
insert into #WF_history                                                                                        
(RuWorkFlowHeader_id ,From_resource,To_resource, MtWFHistory_Process_id,MtWFHistory_Process_name ,MtWFHistory_NotificationSubject ,                                 
 MtWFHistory_ActionDate ,MtWFHistory_LevelID ,MtWFHistory_SequenceID,[Status],SettlementPeriod ,MtStatementProcess_ExecutionFinishDate,MtWFHistory_Action                                                                               
 ,MtWFHistory_comments,notify_flag ,is_read                                                                             
 )                                                                         
select h.RuWorkFlowHeader_id,MtWFHistory_FromResource,MtWFHistory_ToResource,h.MtWFHistory_Process_id,h.MtWFHistory_Process_name,                                     
 h.MtWFHistory_NotificationSubject,h.MtWFHistory_ActionDate,h.MtWFHistory_LevelID,h.MtWFHistory_SequenceID,                                                                                          
 @status [STATUS],@SettlementPeriod,@MtStatementProcess_ExecutionFinishDate,MtWFHistory_Action ,MtWFHistory_comments  ,notify_flag ,is_read                                                                                      
 from MtWFHistory h                                              
 where  h.RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                              
 and h.MtWFHistory_Process_id=@MtWFHistory_Process_id                                                                                
 and h.MtWFHistory_id=@MtWFHistory_id                                                                                
                                                                                     
 update w                                                                                        
 set  To_resource=u.FirstName+' '+u.LastName+' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'                                                                                         
 from #WF_history w inner join AspNetUsers u on w.To_resource=u.UserId                                                                                   
    left join Lu_Department d                                                                      
on u.Lu_Department_Id=d.Lu_Department_Id                                                                      
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                                                                                     
                                                                                    
--Update From resource from previous action step                                                                                        
                                                                          
 update w                                                                                        
 set  From_resource=u.FirstName+' '+u.LastName+' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'                                                                                           
from #WF_history w inner join AspNetUsers u on w.From_resource=u.UserId                                                       
  left join Lu_Department d                                                                      
on u.Lu_Department_Id=d.Lu_Department_Id                                                                      
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                                                  
                                                                                        
 declare @approver_name varchar(128)                                                         
 select @approver_name=TO_resource,@status=[Status] from #WF_history                                                                                     
                                           
                      
DECLARE @from_sql AS VARCHAR(MAX)                          
       ,@where_query AS VARCHAR(MAX);                          
DECLARE @query AS NVARCHAR(MAX)                          
DECLARE @sql_query AS NVARCHAR(MAX)                          
DECLARE @where AS VARCHAR(MAX)                          
Declare @subject as nvarchar(max)                          
declare @subject_query as nvarchar(max)                     
declare @RuNotificationSetup_EmailBody varchar(max)   ,                    
@ProcessName nvarchar(256)                    
                                                
                        
SELECT                          
 @where = RuModulesProcessDetails_ColumnName                          
FROM RuModulesProcessDetails                          
WHERE RuModulesProcess_Id = @RuModulesProcess_Id                          
AND ISNULL(RuModulesProcessDetails_IsWhere, 0) = 1                    
and isnull(RuModulesProcessDetails_IsDeleted,0)=0              
                     
                       
SELECT                          
 @ProcessName = RuModulesProcess_Name                          
FROM RuModulesProcess                      
WHERE RuModulesProcess_Id = @RuModulesProcess_Id                     
                      
SELECT                          
 @RuNotificationSetup_EmailBody =  Concat('<tr><td colspan=2>',@ProcessName, ' ', RuNotificationSetup_EmailBody,'<br><br></td></tr>')     --CONCAT(@ProcessName, ' ', RuNotificationSetup_EmailBody)                          
FROM RuNotificationSetup                          
WHERE RuNotificationSetup_CategoryKey = 'InApproval'                        
    
SELECT                    
 @from_sql = STRING_AGG(CONCAT('<tr><td><b>', RuModulesProcessDetails_Label, ':</b></td><td>'' + isnull(cast(', ISNULL(RuModulesProcessDetails_ColumnName, ''), ' as NVARCHAR(MAX)),'''')+''</td></tr>'), '')                    
FROM RuModulesProcessDetails                    
WHERE RuModulesProcess_Id = @RuModulesProcess_Id   and isnull(RuModulesProcessDetails_IsDeleted,0)=0              
and isnull(RuModulesProcess_ShowOnScreen,0)=1      
    
    
    
SET @from_sql = '''' + @from_sql + ''''                          
--PRINT '@from_sql'                          
                          
DECLARE @HTMLTable VARCHAR(MAX)                          
                          
DECLARE @tableValues as nvarchar(max)                          
                          
select @query=Concat('select @Result=', @from_sql,' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@MtWFHistory_Process_id)                          
from RuModulesProcess where RuModulesProcess_Id=@RuModulesProcess_Id                           
                        
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
                    
                    
update #WF_history                                                       
 set NotificationBody =@EmailBody                    
                          
                          
   /*                       
                                          
 update #WF_history                                                       
 set NotificationBody = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(REPLACE (REPLACE(REPLACE                                                           (replace(replace(replace(replace(REPLACE(REPLACE(REPLACE(re
  
    
place(replace(replace(REPLACE(REPLACE (REPLACE(REPLACE(REPLACE                                                           
   (@NotificationBody,'@approver_name',ISNULL(@approver_name,''))                                                                    
  ,'@ProcessName',ISNULL(MtWFHistory_Process_name,''))                                                                        
  ,'@MtWFHistory_Process_id',MtWFHistory_Process_id)                                                                      
  ,'@SettlementPeriod',ISNULL(SettlementPeriod,''))                                                                      
  ,'@MtStatementProcess_ExecutionFinishDate',CASE WHEN @module_id BETWEEN 13 AND 18 or @module_id=20                         
           THEN ISNULL(Format(MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy'),'')                                         
           ELSE ISNULL(Format(MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy hh:mm tt'),'')end)                                                          
   ,'@Period',ISNULL(SettlementPeriod,''))                                                          
   ,'@upload_date',ISNULL(Format(MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy hh:mm tt'),''))                                                
   ,'@description',ISNULL(@description,''))                                                          
   ,'@Type',ISNULL(@party_type,''))                                                          
   ,'@Application_Date',CASE WHEN @module_id BETWEEN 13 AND 18 or @module_id=20                                                 
        THEN ISNULL(Format(@MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy'),'')                                              
       ELSE ISNULL(Format(@MtStatementProcess_ExecutionFinishDate,'dd-MMM-yyyy hh:mm tt'),'')                                                 
       end)                                                             
   ,'@Application_no',ISNULL(@ApplicationId,''))                                                           
    ,'@Category',ISNULL(@Category,''))                                                
 ,'@Modify_Application_Date',ISNULL(Format(@Modify_Application_Date,'dd-MMM-yyyy'),''))                                                    
 ,'@Deregister_Application_Date',ISNULL(Format(@Deregister_Application_Date,'dd-MMM-yyyy'),''))                                                    
 ,'@Suspension_Application_Date',ISNULL(Format(@Suspension_Application_Date,'dd-MMM-yyyy'),''))                              ,'@withdraw_Suspension_Application_Date',ISNULL(Format(@withdraw_Suspension_Application_Date,'dd-MMM-yyyy'),''))                  
  
    
     
        
          
            
              
                
                  
                    
                      
                                 
 ,'@termination_Application_Date',ISNULL(Format(@termination_Application_Date,'dd-MMM-yyyy'),'') )                                                
   ,'@Suspension_Modification_Application_Date',ISNULL(Format(@modify_Suspension_Application_Date,'dd-MMM-yyyy'),'') )                                                
    ,'@Suspension_Modification_Application_No',ISNULL(@Suspension_Modification_Application_No,'') )                                             
    ,'@Modify_Application_no',ISNULL(@Modify_Application_no,'') )                                        
 ,'@Deregister_Application_no',ISNULL(@Deregister_Application_no,'') )                                        
 ,'@Suspension_Application_no',ISNULL(@Suspension_Application_no,'') )                                        
 ,'@withdraw_Suspension_Application_no',ISNULL(@withdraw_Suspension_Application_no,'') )                                        
 ,'@termination_Application_no',ISNULL(@termination_Application_no,'') )                                      
  ,'@Contract_Type',ISNULL(@Contract_Type,'') )                                        
   ,'@Buyer_name_Category',ISNULL(@Buyer_name_Category,'') )                                        
    ,'@Seller_name_Category',ISNULL(@Seller_name_Category,'') )                                    
  ,'@Contract_Registration_Date',ISNULL(@Contract_Registration_Date,'') )                                      
   ,'@ContractDuration',ISNULL(@ContractDuration,'') )                                        
                                         
     */                                    
                                         
                                                 
                                                                                  
   update #WF_history                                                   
 set  To_resource=replace(To_resource,'( - )','') ,From_resource=replace(From_resource,'( - )','')                                                           
                                                          
                                                          
                                                          
                                                        
                                                                
                                                                                      
select @module_id module_id,@RuModulesProcess_ProcessTemplateId RuModulesProcess_ProcessTemplateId,@MtWFHistory_id MtWFHistory_id,@SrContractType_Id  ContractType_Id,*,@LuSOFileTemplate_Url_type LuSOFileTemplate_Url_type,                                  
  
    
     
                 
               
               
@LuSOFileTemplate_Url_file LuSOFileTemplate_Url_file,@RuModulesProcess_Name RuModulesProcess_Name from #WF_history                                                                                        
                                                                                        
select                                                                                   
 RuWorkFlowHeader_id                                                        
,MtWFHistory_Process_id                                                                                        
,MtWFHistory_Process_name                                                                                        
,MtWFHistory_LevelID                                                                                        
,MtWFHistory_ActionDate--CONVERT(varchar(15),  CAST(MtWFHistory_ActionDate AS TIME), 100) as MtWFHistory_ActionDate                                                  
,LuStatus_Name--MtWFHistory_Action                                                                             
,MtWFHistory_FromResource                                                                                        
,u.FirstName+' '+u.LastName+' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'     FromResource_name                                 
,MtWFHistory_ToResource                                                                                
,u.FirstName+' '+u.LastName ToResource_name                                                                                      
,MtWFHistory_comments                                                                                       
,MtWFHistory_SequenceID  MtWFHistory_SequenceID_old                                                                              
,MtWFHistory_id                            
into #resources                                                                                      
from MtWFHistory w                                
inner join [LuStatus] s on w.MtWFHistory_Action=s.LuStatus_Code                                                                                      
inner join AspNetUsers u on w.MtWFHistory_FromResource=u.UserId                                  
 left join Lu_Department d                                                                      
on u.Lu_Department_Id=d.Lu_Department_Id                                        
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                                                                      
where RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                                                                         
  and MtWFHistory_Process_id=@MtWFHistory_Process_id             
                                                                            
 update w                        
 set  ToResource_name= u.FirstName+' '+u.LastName +' ('+isnull(Lu_Designation_Name,'')+' - '+isnull(Lu_Department_Name,'')+')'                                                                           
 from #resources w inner join AspNetUsers u on w.MtWFHistory_ToResource=u.UserId                                                                 
 left join Lu_Department d                                                                      
on u.Lu_Department_Id=d.Lu_Department_Id                                                                      
left join Lu_Designation de on de.Lu_Designation_Id=u.Lu_Designation_Id                                                                   
                                                                
 update w                                                                                        
 set  ToResource_name=replace(ToResource_name,'( - )','')                                                                          
 from #resources w                                                                 
                                                              
 update w                                                                                        
 set  FromResource_name=replace(FromResource_name,'( - )','')                                                                          
 from #resources w                                                                                     
                                                               
 update w                                                                                        
 set  ToResource_name= ''                                                                  
 from #resources w where w.MtWFHistory_ToResource is null                                                                                  
  
  
  
  
 select ROW_NUMBER()OVER (PARTITION BY 1 ORDER BY MtWFHistory_id desc )MtWFHistory_SequenceID, *             
 INTO #result from #resources order by MtWFHistory_id      
                                                        
 select * from #result order by MtWFHistory_SequenceID 

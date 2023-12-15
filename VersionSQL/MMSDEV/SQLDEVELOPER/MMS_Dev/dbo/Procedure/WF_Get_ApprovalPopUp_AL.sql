/****** Object:  Procedure [dbo].[WF_Get_ApprovalPopUp_AL]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    
      
        
          
            
              
                
                  
                  
         --WF_Get_ApprovalPopUp_AL 308,14,1,4                               
                                            
                                            
                                              
--======================================================================                                                                
--Author  :  Alina Javed                                                    
--Reviewer : <>                                                                
--CreatedDate : 22 July 2022                                                                
--Comments :                                                                 
--======================================================================                                                           
CREATE procedure dbo.WF_Get_ApprovalPopUp_AL                                              
    @ProcessId as decimal(18, 0),                                              
    @RuModules_Id INT=null,   
    @level_id int = null,  
    @settlementid int
as                                              
       --Generic variables                
declare @MtStatementProcess_ExecutionFinishDate datetime,                                              
        @SettlementPeriod varchar(20),                                              
        @ProcessName nvarchar(256),                                              
        @RuWorkFlowHeader_id int,                                              
        @RuNotificationSetup_ID int,                                              
        @RuNotificationSetup_EmailSubject varchar(max),                                              
        @RuNotificationSetup_EmailBody varchar(max)    ,                    
        @modprocessid varchar(20),         
                
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
                   
 
   select @modprocessid=RuModulesProcess_Id from RuModulesProcess where RuModulesProcess_ProcessTemplateId=@RuModules_Id and RuModules_Id=@settlementid   
                                
select @RuWorkFlowHeader_id = RuWorkFlowHeader_id                                              
from RuWorkFlow_header                                     
where RuModulesProcess_Id = @modprocessid                                               
select @RuNotificationSetup_ID = RuNotificationSetup_ID                                              
from RuNotificationSetup                  
where RuModules_id = @RuModules_id    --RuWorkFlowHeader_id = @RuWorkFlowHeader_id                                              
      and RuNotificationSetup_CategoryKey = case                                              
                                                when isnull(@level_id, 0) = 1 then                                              
                                                    'Process_Submitted'                            
                                                else                                              
                                                    'process_approval'                                              
                                            end                                              
                                   
                       
                                

                                              
/*Get process defination for notification popup to show up on submission of process*/                                     
/*BME*/         

IF @settlementid =4
BEGIN

Declare @from_sql as varchar(max),@where_query as varchar(max);  
Declare @query as nvarchar(max)  
declare @sql_query as nvarchar(max) 
Declare @where as varchar(max)
--DECLARE @sql_reult as varchar(max)


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


select @RuNotificationSetup_EmailSubject=concat(RuNotificationSetup_EmailSubject,' ',@ProcessName) from RuNotificationSetup where RuNotificationSetup_CategoryKey='Submitted'


select @RuNotificationSetup_EmailBody=concat(@ProcessName,' ',RuNotificationSetup_EmailBody) from RuNotificationSetup where RuNotificationSetup_CategoryKey='Submitted'
--select  @sql_reult=STRING_AGG( CONCAT(RuModulesProcessDetails_ColumnName ,' as [', RuModulesProcessDetails_Label,']'),', ')  
--from RuModulesProcessDetails where RuModulesProcess_Id=@modprocessid  

--select @query=Concat('select ', @sql_reult,' from ', RuModulesProcess_LinkedObject ,' where ',RuModulesProcess_WhereClause, '=',@ProcessId)
--from RuModulesProcess where RuModulesProcess_Id=@modprocessid 
--EXEC (@query)

select  @from_sql=STRING_AGG( CONCAT('<tr><td><b>',RuModulesProcessDetails_Label,':</b></td><td>'' + cast(',RuModulesProcessDetails_ColumnName ,' as NVARCHAR(MAX))+''</td></tr>'),'')  from RuModulesProcessDetails where RuModulesProcess_Id=@modprocessid 

SELECT @where = RuModulesProcessDetails_ColumnName   
from RuModulesProcessDetails where RuModulesProcess_Id=@modprocessid and ISNULL(RuModulesProcessDetails_IsWhere,0)=1

declare @HTMLTable varchar(max)  set @from_sql=''''+@from_sql+''''
DECLARE @tableValues as nvarchar(max)
select @query=Concat('select @Result=', @from_sql,' from ', RuModulesProcess_LinkedObject ,' where ',@where, '=',@ProcessId)
from RuModulesProcess where RuModulesProcess_Id=@modprocessid  
--select @query=Concat('select @Result=', @from_sql,' from ', RuModulesProcess_LinkedObject ,' where ',RuModulesProcess_WhereClause, '=',@ProcessId)
--from RuModulesProcess where RuModulesProcess_Id=@modprocessid  
/**/
DECLARE @outCount nvarchar(max)
DECLARE @params NVARCHAR(255) = '@Result nvarchar(max) OUTPUT' EXEC sp_executeSQL @query, @params, @Result = @outCount OUTPUT;
Declare @EmailBody as varchar(max)
Set @EmailBody='<html></head>                         <style>            #notificationBody p{       margin-bottom: 0;        margin-top: 0;        padding:0;      }                         </style>                         </head>                         <body>                        <p>Dear @approver_name,<br><br></p>      <p>Settlement Process requires your approval, details are:<br></p><table>'
+
@RuNotificationSetup_EmailBody
+
@outCount
+
'</table></body></html>'
 



SELECT @RuWorkFlowHeader_id RuWorkFlowHeader_id, @ProcessId ProcessId,@RuNotificationSetup_EmailSubject EmailSubject, (@EmailBody) as [Email Body] 

--select @RuWorkFlowHeader_id RuWorkFlowHeader_id,                                    
--       @ProcessId ProcessId,                                    
--       @ProcessName ProcessName,                                    
--       @SettlementPeriod SettlementPeriod,                                    
--       @MtStatementProcess_ExecutionFinishDate ExecutionDate,                                    
--       @RuNotificationSetup_EmailSubject EmailSubject,                                    
--       @RuNotificationSetup_EmailBody EmailBody  

END
  
--IF  @RuModules_Id BETWEEN 1 AND 12  OR  @RuModules_Id = 27  or @RuModules_Id = 28 or @RuModules_Id = 29 or @RuModules_Id = 30    
--begin                                  
--select @ProcessName = CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name),                                              
-- @SettlementPeriod = LuAccountingMonth_MonthName,                                              
--       @MtStatementProcess_ExecutionFinishDate = MtStatementProcess_ExecutionFinishDate                            
--from MtStatementProcess mt_p                                              
--    inner join LuAccountingMonth lu_acm                                              
--        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id_Current                                              
--    inner join SrProcessDef SPD                                              
--        on SPD.SrProcessDef_ID = mt_p.SrProcessDef_ID                                              
--    inner join SrStatementDef SSD                                              
--        on SPD.SrStatementDef_ID = SSD.SrStatementDef_ID                                              
--where IsNull(MtStatementProcess_IsDeleted, 0) = 0                                 
--      and mt_p.MtStatementProcess_ID = @ProcessId         
                                                                  
                                  
--select @RuNotificationSetup_EmailSubject = replace(replace(replace(ISNULL(RuNotificationSetup_EmailSubject,''), '@ProcessName', @ProcessName),                                    
--                 '@Period',@SettlementPeriod),                                    
--                 '@Process_ID', @ProcessId ),                                    
--      @RuNotificationSetup_EmailBody  = replace(replace(replace(replace(ISNULL(RuNotificationSetup_EmailBody,''), '@ProcessName', @ProcessName),                                    
--                    '@ProcessId', @ProcessId ),                                    
--                    '@SettlementPeriod', @SettlementPeriod ),                                    
--                    '@MtStatementProcess_ExecutionFinishDate', Format(ISNULL(@MtStatementProcess_ExecutionFinishDate,''), 'dd-MMM-yyyy hh:mm tt'))                                    
                                    
--from RuNotificationSetup                                    
--where RuNotificationSetup_ID = @RuNotificationSetup_ID                                    
                                  
--select @RuWorkFlowHeader_id RuWorkFlowHeader_id,                                    
--       @ProcessId ProcessId,                                    
--       @ProcessName ProcessName,                                    
--       @SettlementPeriod SettlementPeriod,                                    
--       @MtStatementProcess_ExecutionFinishDate ExecutionDate,                                    
--       @RuNotificationSetup_EmailSubject EmailSubject,                                    
--       @RuNotificationSetup_EmailBody EmailBody                                    
                        
--end        
                                
/*SO DATA MANAGEMENT*/                                  
IF @RuModules_Id =19                                  
begin                                  
                                
                                
select @ProcessName = LuSOFileTemplate_Name,                                  
       @Period = LuAccountingMonth_MonthName,                                              
       @upload_date = MtSOFileMaster_CreatedOn,                                
    @description=MtSOFileMaster_Description           
from MtSOFileMaster mt_p                                              
    inner join LuAccountingMonth lu_acm                                              
        on lu_acm.LuAccountingMonth_Id = mt_p.LuAccountingMonth_Id                                              
  inner join LuSOFileTemplate SPD                                              
        on SPD.LuSOFileTemplate_Id = mt_p.LuSOFileTemplate_Id                                                     
where IsNull(MtSOFileMaster_IsDeleted, 0) = 0                                              
      and mt_p.MtSOFileMaster_Id = @ProcessId                                     
                                  
select @RuNotificationSetup_EmailSubject = REPLACE(replace(replace(replace(ISNULL(RuNotificationSetup_EmailSubject,''), '@ProcessName', @ProcessName),                                    
                 '@Period',@Period),                                    
                 '@Process_ID', @ProcessId ),                                  
                 '@upload_date', @upload_date ),                         
       @RuNotificationSetup_EmailBody  = REPLACE(replace(replace(replace(replace(ISNULL(RuNotificationSetup_EmailBody,''), '@ProcessName', @ProcessName),                                    
                    '@ProcessId', @ProcessId ),                                    
                    '@Period', @Period ),                                    
                    '@upload_date', Format(ISNULL(@upload_date,''), 'dd-MMM-yyyy hh:mm tt')),                                
     '@description',ISNULL(@description,''))                   
                                                      
                                    
from RuNotificationSetup                                    
where RuNotificationSetup_ID = @RuNotificationSetup_ID                                       
                                
select @RuWorkFlowHeader_id RuWorkFlowHeader_id,                                    
       @ProcessId ProcessId, --file ID                                   
       @ProcessName ProcessName,  --Template name                                  
       @Period file_Period,  --month                                  
       @upload_date ExecutionDate,   --upload date                                   
       @RuNotificationSetup_EmailSubject EmailSubject,                                    
       @RuNotificationSetup_EmailBody EmailBody                                    
                                  
                                  
end                                   
                                  
/*Registration*/                                  
IF @modprocessid BETWEEN 13 AND 18 or   @modprocessid=20                               
BEGIN                                  
                                   
select @ProcessName = MtPartyRegisteration_Name,                                                         
       @MtPartyCategory_ApplicationDate = MtPartyCategory_ApplicationDate,                                  
    @party_type=SrPartyType_Name,                                  
    @ApplicationId=MtPartyCategory_ApplicationId,                                  
    @Category=SrCategory_Name                                  
FROM MtPartyRegisteration mpr INNER JOIN                 
SrPartyType spt ON mpr.SrPartyType_Code = spt.SrPartyType_Code                                  
INNER JOIN MtPartyCategory mpc ON mpr.MtPartyRegisteration_Id = mpc.MtPartyRegisteration_Id                                  
INNER JOIN SrCategory sc ON mpc.SrCategory_Code = sc.SrCategory_Code                                           
      and mpr.MtPartyRegisteration_Id = @ProcessId                         
                           
                        
   SELECT  TOP 1                            
   @MtRegisterationActivity_Id = MtRegisterationActivity_Id,                        
   @Suspension_Application_Date=MtRegisterationActivities_ApplicationDate                        
FROM                               
 MtRegisterationActivities                             
WHERE                             
     MtPartyRegisteration_Id=@ProcessId                             
    and MtRegisterationActivities_ACtion = 'SDRF'                         
                        
 IF @modprocessid in (16,20)                        
 BEGIN                        
 SELECT TOP 1 @Suspension_Application_Date= MtRegisterationActivities_ApplicationDate                        
FROM MtRegisterationActivities                                 
WHERE                                
MtRegisterationActivities_ACtion = 'SDRF'                              
AND MtPartyRegisteration_Id=@ProcessId                              
order by MtRegisterationActivity_Id desc                         
 END                        
 IF @modprocessid=14                        
 BEGIN                        
 SELECT TOP 1 @Modify_Application_Date= MtRegisterationActivities_ApplicationDate                        
FROM MtRegisterationActivities                                 
WHERE                                
MtRegisterationActivities_ACtion in ('MDRA' ,'MPA')                             
AND MtPartyRegisteration_Id=@ProcessId                              
order by MtRegisterationActivity_Id desc                         
 END                        
                        
  IF @modprocessid=15                        
 BEGIN                        
 SELECT TOP 1 @Deregister_Application_Date= MtRegisterationActivities_ApplicationDate                        
FROM MtRegisterationActivities                                 
WHERE                
MtRegisterationActivities_ACtion in ('IDER' ,'ADER')                             
AND MtPartyRegisteration_Id=@ProcessId                              
order by MtRegisterationActivity_Id desc                         
 END                        
                        
   IF @modprocessid=17                        
 BEGIN                        
 SELECT TOP 1 @withdraw_Suspension_Application_Date= MtRegisterationActivities_ApplicationDate                        
FROM MtRegisterationActivities                                 
WHERE                              
MtRegisterationActivities_ACtion in ('WSPF')                             
AND ref_Id=@MtRegisterationActivity_Id                              
order by MtRegisterationActivity_Id desc                         
                        
 END                        
                        
   IF @modprocessid=18                        
 BEGIN                        
 SELECT TOP 1 @termination_Application_Date= MtRegisterationActivities_ApplicationDate                        
FROM MtRegisterationActivities                                 
WHERE                                
MtRegisterationActivities_ACtion in ('TERM' ,'TPA','TEDR')                             
AND ref_Id=@MtRegisterationActivity_Id                              
order by MtRegisterationActivity_Id desc                         
                        
 END                       
                     
    IF @modprocessid=20       BEGIN                        
 SELECT TOP 1 @modify_Suspension_Application_Date= MtRegisterationActivities_ApplicationDate                   
 ,@Suspension_Modification_Application_No =MtRegisterationActivities_ApplicationNo                  
FROM MtRegisterationActivities                                 
WHERE                                
MtRegisterationActivities_ACtion in ('SMDR','SMPA')                             
AND ref_Id=@MtRegisterationActivity_Id                              
order by MtRegisterationActivity_Id desc                         
                        
 END                      
                        
                        
                        
                        
                        
                                     
select @RuNotificationSetup_EmailSubject =replace(replace(ISNULL(RuNotificationSetup_EmailSubject,''), '@ProcessName', @ProcessName),                                             
                   '@Process_ID', @ProcessId ),                                  
                                  
          @RuNotificationSetup_EmailBody =replace(replace(replace(replace(replace(replace(replace(REPLACE(REPLACE(replace(replace(replace(replace(ISNULL(RuNotificationSetup_EmailBody,''),'@ProcessName',@ProcessName)                                       
  
    
      
       
            ,'@ProcessId',@ProcessId)                                            
 ,'@Type',@party_type)                                  
   ,'@Application_Date',Format(ISNULL(@MtPartyCategory_ApplicationDate,''),'dd-MMM-yyyy'))                                   
   ,'@Application_no',@ApplicationId)                                  
   ,'@Category',ISNULL(@Category,''))                        
    ,'@Modify_Application_Date',ISNULL(Format(@Modify_Application_Date,'dd-MMM-yyyy'),''))                            
 ,'@Deregister_Application_Date',ISNULL(Format(@Deregister_Application_Date,'dd-MMM-yyyy'),''))                            
 ,'@Suspension_Application_Date',ISNULL(Format(@Suspension_Application_Date,'dd-MMM-yyyy'),''))                            
 ,'@withdraw_Suspension_Application_Date',ISNULL(Format(@withdraw_Suspension_Application_Date,'dd-MMM-yyyy'),''))                          
 ,'@termination_Application_Date',ISNULL(Format(@termination_Application_Date,'dd-MMM-yyyy'),''))                       
  ,'@Suspension_Modification_Application_Date',ISNULL(Format(@modify_Suspension_Application_Date,'dd-MMM-yyyy'),'') )                    
    ,'@Suspension_Modification_Application_No',ISNULL(@Suspension_Modification_Application_No,'') )                   
from RuNotificationSetup                                    
where RuNotificationSetup_ID = @RuNotificationSetup_ID                                                              
                                  
 select                                   
    @RuWorkFlowHeader_id RuWorkFlowHeader_id,                                              
       @ProcessId ProcessId,                                              
       @ProcessName ProcessName,                                                         
       @RuNotificationSetup_EmailSubject EmailSubject,                                              
       @RuNotificationSetup_EmailBody EmailBody,                                  
    @party_type party_type,                                  
    @MtPartyCategory_ApplicationDate MtPartyCategory_ApplicationDate,                                  
    @ApplicationId ApplicationId,                                  
    @Category Category                                       
                                  
                                  
END                 
/*Contract Registration*/                  
 IF @modprocessid BETWEEN 21 AND 26                
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
   @ContractDuration=Format(ISNULL(MtContractRegistration_EffectiveFrom,''),'dd-MMM-yyyy')+'-'+Format(ISNULL(MtContractRegistration_EffectiveTo,''),'dd-MMM-yyyy')                
                   
FROM MtContractRegistration mpr inner join SrContractType CT                        
            on mpr.SrContractType_Id = ct.SrContractType_Id                                          
      and mpr.MtContractRegistration_Id = @ProcessId                         
                           
 IF @modprocessid=22                        
 BEGIN                        
 SELECT TOP 1 @Modify_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                
 @Modify_Application_no=MtContractRegistrationActivities_ApplicationNo                
FROM MtContractRegistrationActivities                                 
WHERE                                
MtContractRegistrationActivities_Action in ('CAMD' ,'CAMI')                             
AND MtContractRegistration_Id=@ProcessId                
and isnull(MtContractRegistrationActivities_Deleted,0)=0            
order by MtContractRegistrationActivity_Id desc                         
 END             
             
  IF @modprocessid=23                       
 BEGIN                        
 SELECT TOP 1 @Deregister_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                
 @Deregister_Application_no=MtContractRegistrationActivities_ApplicationNo                
FROM MtContractRegistrationActivities                                 
WHERE                                
MtContractRegistrationActivities_Action in ('CADD' ,'CADI')                             
AND MtContractRegistration_Id=@ProcessId                
and isnull(MtContractRegistrationActivities_Deleted,0)=0            
order by MtContractRegistrationActivity_Id desc                         
 END                  
  IF @modprocessid=24                       
 BEGIN                        
 SELECT TOP 1 @Suspension_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                
 @Suspension_Application_no=MtContractRegistrationActivities_ApplicationNo                
FROM MtContractRegistrationActivities                                 
WHERE                                
MtContractRegistrationActivities_Action in ('CASD' ,'CASI')                             
AND MtContractRegistration_Id=@ProcessId                
and isnull(MtContractRegistrationActivities_Deleted,0)=0            
order by MtContractRegistrationActivity_Id desc                         
 END            
             
   IF @modprocessid=25                       
 BEGIN                        
 SELECT TOP 1 @withdraw_Suspension_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                
 @withdraw_Suspension_Application_no=MtContractRegistrationActivities_ApplicationNo                
FROM MtContractRegistrationActivities                                 
WHERE                                
MtContractRegistrationActivities_Action in ('CAWD' ,'CAWI')                             
AND MtContractRegistration_Id=@ProcessId                
and isnull(MtContractRegistrationActivities_Deleted,0)=0            
order by MtContractRegistrationActivity_Id desc                         
 END             
             
    IF @modprocessid=26                       
 BEGIN                        
 SELECT TOP 1 @termination_Application_Date= MtContractRegistrationActivities_ApplicationDate ,                
 @termination_Application_no=MtContractRegistrationActivities_ApplicationNo                
FROM MtContractRegistrationActivities                                 
WHERE                                
MtContractRegistrationActivities_Action in ('CATD' ,'CATI')                             
AND MtContractRegistration_Id=@ProcessId                
and isnull(MtContractRegistrationActivities_Deleted,0)=0            
order by MtContractRegistrationActivity_Id desc                         
 END              
                
                 
                                     
select @RuNotificationSetup_EmailSubject =replace(ISNULL(RuNotificationSetup_EmailSubject,''),'@Process_ID', @ProcessId ),                 
       @RuNotificationSetup_EmailBody =replace(replace( replace(replace(replace(replace( replace(replace( replace(replace(             
    replace(replace(replace(replace(replace(replace(replace(ISNULL(RuNotificationSetup_EmailBody,''),'@Contract_Type',@Contract_Type)                                              
            ,'@Buyer_name_Category',@Buyer_name_Category)                                            
 ,'@Seller_name_Category',@Seller_name_Category)                                  
   ,'@Contract_Registration_Date',Format(ISNULL(@Contract_Registration_Date,''),'dd-MMM-yyyy'))                   
    ,'@Application_Date',Format(ISNULL(@Application_Date,''),'dd-MMM-yyyy'))                
 ,'@Application_no',isnull(@ApplicationId,''))                
 ,'@ContractDuration',@ContractDuration)                
 ,'@Modify_Application_Date',Format(ISNULL(@Modify_Application_Date,''),'dd-MMM-yyyy'))                
 ,'@Modify_Application_no',isnull(@Modify_Application_no,''))             
 ,'@Deregister_Application_Date',Format(ISNULL(@Deregister_Application_Date,''),'dd-MMM-yyyy'))                
 ,'@Deregister_Application_no',isnull(@Deregister_Application_no,''))             
  ,'@Suspension_Application_Date',Format(ISNULL(@Suspension_Application_Date,''),'dd-MMM-yyyy'))                
 ,'@Suspension_Application_no',isnull(@Suspension_Application_no,''))              
   ,'@withdraw_Suspension_Application_Date',Format(ISNULL(@withdraw_Suspension_Application_Date,''),'dd-MMM-yyyy'))                
 ,'@withdraw_Suspension_Application_no',isnull(@withdraw_Suspension_Application_no,''))             
    ,'@termination_Application_Date',Format(ISNULL(@termination_Application_Date,''),'dd-MMM-yyyy'))                
 ,'@termination_Application_no',isnull(@termination_Application_no,''))              
                
                  
from RuNotificationSetup                                    
where RuNotificationSetup_ID = @RuNotificationSetup_ID                 
                
              
                                  
 select                                   
    @RuWorkFlowHeader_id RuWorkFlowHeader_id,                                              
       @ProcessId ProcessId,                                                                                    
       @RuNotificationSetup_EmailSubject EmailSubject,                                              
       @RuNotificationSetup_EmailBody EmailBody                    
                
 END                
                                                                        
--Approval Required for @ProcessName Settlement ID # @Process_ID Month @Period 

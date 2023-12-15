/****** Object:  Procedure [dbo].[WF_Getnotification_body_RS]    Committed by VersionSQL https://www.versionsql.com ******/

          
CREATE procedure dbo.WF_Getnotification_body_RS                                       
@RuWorkFlowHeader_id int,          
@ProcessId INT,                
@user_id INT,          
@action varchar(4)          
as          
          
          
 declare @module_id int ,          
 @initiator varchar(256),          
 @approver varchar(256),          
 @RuNotificationSetup_ID int,          
 @NotificationBody varchar(max),          
 @ProcessName varchar(256),  
 


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
           
                                           
declare @MtStatementProcess_ExecutionFinishDate datetime,                            
        @SettlementPeriod varchar(20),                                                 
        @RuNotificationSetup_EmailSubject varchar(max),                            
        @RuNotificationSetup_EmailBody varchar(max)    ,                
  @MtPartyCategory_ApplicationDate DATETIME,                
  @party_type VARCHAR(64),                
  @ApplicationId VARCHAR(250),                
  @Category VARCHAR(64),                
  @Period VARCHAR(20),                
  @upload_date  datetime ,              
  @description varchar(max),    
    @MtRegisterationActivity_Id decimal(18,0),    
  @Modify_Application_Date DATE,    
  @Deregister_Application_Date DATE,    
  @Suspension_Application_Date DATE,    
  @withdraw_Suspension_Application_Date DATE,    
  @termination_Application_Date date,  
  @modify_Suspension_Application_Date date ,    
  @Suspension_Modification_Application_No varchar(30)    
       
      
  select @module_id=RuModulesProcess_Id from RuWorkFlow_header where RuWorkFlowHeader_id=@RuWorkFlowHeader_id            
   
SELECT @approver=              
       [dbo].[FN_WF_SENDER_NAME](@ProcessId,@user_id,@RuWorkFlowHeader_id)           
SELECT @initiator=              
       [DBO].[FN_WF_Init_NAME_EMAIL](@ProcessId,@RuWorkFlowHeader_id)           
            
select @initiator=substring(@initiator,1,charindex('¼',@initiator)-1)          
if @action in ('WFSM','WFAP')          
begin           
select @RuNotificationSetup_ID=RuNotificationSetup_ID           
from RuNotificationSetup where RuModules_id=@module_id   --RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                     
 and RuNotificationSetup_CategoryKey=  'process_approval_notification'             
end          
if @action  IN ('WFRJ','WFAJ')          
begin           
select @RuNotificationSetup_ID=RuNotificationSetup_ID           
from RuNotificationSetup where RuModules_id=@module_id   --RuWorkFlowHeader_id=@RuWorkFlowHeader_id                                     
 and RuNotificationSetup_CategoryKey=  'process_rejection_notification'             
end           
          
 select @NotificationBody=RuNotificationSetup_EmailBody--replac           e(RuNotificationSetup_EmailBody,'@approver_name',@approver_name)                                                 
from  RuNotificationSetup                                                 
where RuNotificationSetup_ID=@RuNotificationSetup_ID                       
      
      
 
----------*********************      
         
   --,'@sender_name',@approver)          
IF @module_id BETWEEN 1 AND 12                
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
                   
       
select  @NotificationBody = replace(replace(replace(replace(replace(ISNULL(@NotificationBody,''),'@approver_name',@initiator)                    
         ,'@ProcessName',@ProcessName)                        
            ,'@ProcessId',@ProcessId)                      
            ,'@SettlementPeriod',@SettlementPeriod)                      
            ,'@MtStatementProcess_ExecutionFinishDate',Format(ISNULL(@MtStatementProcess_ExecutionFinishDate,''),'dd-MMM-yyyy hh:mm tt'))                 
                            
end        
                
/*SO DATA MANAGEMENT*/                
IF @module_id =19                
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
         
select  @NotificationBody = REPLACE(replace(replace(replace(replace(replace(ISNULL(@NotificationBody,''),'@approver_name',@initiator)                    
         ,'@ProcessName',@ProcessName)                        
            ,'@ProcessId',@ProcessId)                      
            ,'@Period', @Period ),                
            '@upload_date', Format(ISNULL(@upload_date,''), 'dd-MMM-yyyy hh:mm tt')),              
            '@description',ISNULL(@description,''))            
         
                
end                 
                
/*Registration*/                
IF @module_id BETWEEN 13 AND 18   or @module_id=20             
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
    
 IF @module_id=16    
 BEGIN    
 SELECT TOP 1 @Suspension_Application_Date= MtRegisterationActivities_ApplicationDate    
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion = 'SDRF'          
AND MtPartyRegisteration_Id=@ProcessId          
order by MtRegisterationActivity_Id desc     
 END    
 IF @module_id=14    
 BEGIN    
 SELECT TOP 1 @Modify_Application_Date= MtRegisterationActivities_ApplicationDate    
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion in ('MDRA' ,'MPA')         
AND MtPartyRegisteration_Id=@ProcessId          
order by MtRegisterationActivity_Id desc     
 END    
    
  IF @module_id=15    
 BEGIN    
 SELECT TOP 1 @Deregister_Application_Date= MtRegisterationActivities_ApplicationDate    
FROM MtRegisterationActivities             
WHERE            
MtRegisterationActivities_ACtion in ('IDER' ,'ADER')         
AND MtPartyRegisteration_Id=@ProcessId          
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
    
    
    
    
    SELECT  @NotificationBody =REPLACE(REPLACE(REPLACE(REPLACE(replace(replace(replace(REPLACE(REPLACE(replace(replace(replace(replace(replace(ISNULL(@NotificationBody,''),'@approver_name',@initiator)       
 ,'@ProcessName',@ProcessName)                            
            ,'@ProcessId',@ProcessId)                          
   ,'@Type',@party_type)                
   ,'@Application_Date',Format(ISNULL(@MtPartyCategory_ApplicationDate,''),'dd-MMM-yyyy'))                 
   ,'@Application_no',@ApplicationId)                
   ,'@Category',@Category)     
       ,'@Modify_Application_Date',ISNULL(Format(@Modify_Application_Date,'dd-MMM-yyyy'),''))        
 ,'@Deregister_Application_Date',ISNULL(Format(@Deregister_Application_Date,'dd-MMM-yyyy'),''))        
 ,'@Suspension_Application_Date',ISNULL(Format(@Suspension_Application_Date,'dd-MMM-yyyy'),''))        
 ,'@withdraw_Suspension_Application_Date',ISNULL(Format(@withdraw_Suspension_Application_Date,'dd-MMM-yyyy'),''))      
 ,'@termination_Application_Date',ISNULL(Format(@termination_Application_Date,'dd-MMM-yyyy'),'') )   
   ,'@Suspension_Modification_Application_Date',ISNULL(Format(@modify_Suspension_Application_Date,'dd-MMM-yyyy'),'') )      
    ,'@Suspension_Modification_Application_No',ISNULL(@Suspension_Modification_Application_No,'') )     
                                        
         
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
   @ContractDuration=Format(ISNULL(MtContractRegistration_EffectiveFrom,''),'dd-MMM-yyyy')+'-'+Format(ISNULL(MtContractRegistration_EffectiveTo,''),'dd-MMM-yyyy')        
           
FROM MtContractRegistration mpr inner join SrContractType CT                
            on mpr.SrContractType_Id = ct.SrContractType_Id                                  
      and mpr.MtContractRegistration_Id = @ProcessId                 
                   
 IF @module_id=22                
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
     
  IF @module_id=23               
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
  IF @module_id=24               
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
     
   IF @module_id=25               
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
     
    IF @module_id=26               
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
        
         
                                

select @NotificationBody =replace(replace( replace(replace(replace(replace( replace(replace( replace(replace(     
    replace(replace(replace(replace(replace(replace(replace(replace
	(ISNULL(@NotificationBody,''),'@Contract_Type',@Contract_Type)                                
	,'@approver_name',@initiator)       
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
        



                                        
                  
 END       
      
      
      
      
-------------***********************8      
      
      
      
      
      
      
          
select @NotificationBody NotificationBody

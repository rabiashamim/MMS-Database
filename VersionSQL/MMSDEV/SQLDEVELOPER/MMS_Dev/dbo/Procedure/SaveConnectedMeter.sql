/****** Object:  Procedure [dbo].[SaveConnectedMeter]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.SaveConnectedMeter              
@vConnectedMeterId int,              
@vCdpId int=null,              
@vCategoryId int=null,              
@vUserId int=null,   
@vGenerationUnitId int = null ,              
@vConnectedFromId int =null,              
@vConnectedToId int=null   ,          
@vEffectiveTo  DATETIME =null,          
@vEffectiveFrom DATETIME =null ,        
@vCongestedZoneId int = null,        
@vTaxZoneId int =null        
          
AS              
BEGIN              
    DECLARE @MtConnectedMeterLogs_Id decimal(18,0)      
IF @vConnectedMeterId =0              
BEGIN              
              
  DECLARE @pMtConnectedMeter_Id decimal(18,0)              
  SELECT @pMtConnectedMeter_Id = ISNULL(max(MtConnectedMeter_Id),0)+1 FROM [dbo].[MtConnectedMeter]              
                
  INSERT INTO  [dbo].[MtConnectedMeter]              
 (MtConnectedMeter_Id              
 ,MtPartyCategory_Id              
 ,MtCDPDetail_Id              
 ,IsAssigned              
 ,MtConnectedMeter_CreatedBy              
 ,MtConnectedMeter_CreatedOn)              
  VALUES              
 (@pMtConnectedMeter_Id              
 ,@vCategoryId              
 ,@vCdpId              
 ,1              
 ,@vUserId              
 ,GETUTCDATE())              
        
  exec CDPandConnectedMeterSettings @vCdpId,@vCategoryId,1      
        
  Update  [dbo].[RuCDPDetail] set IsAssigned=1 where RuCDPDetail_Id= @vCdpId         
          
                
 SELECT @MtConnectedMeterLogs_Id = ISNULL(max(MtConnectedMeterlog_Id),0)+1 FROM [dbo].[MtConnectedMeterlogs]          
        
 INSERT INTO [dbo].[MtConnectedMeterlogs]         
  (MtConnectedMeterlog_Id        
  ,MtConnectedMeter_Id              
  ,MtPartyCategory_Id              
  ,MtCDPDetail_Id                
  ,MtConnectedMeter_CreatedBy        
  ,IsAssigned        
  ,MtConnectedMeter_CreatedOn)        
 VALUES        
  (@MtConnectedMeterLogs_Id        
  ,@pMtConnectedMeter_Id              
  ,@vCategoryId              
  ,@vCdpId          
  ,@vUserId        
  ,1        
  ,GETUTCDATE())        
        
return;              
END              
IF (@vConnectedMeterId>0)              
BEGIN              
    /**********  Contract Module Validation ************/ 
	DECLARE @pPartyId as DECIMAL(18,0);

	select @pPartyId=MtPartyRegisteration_Id from MtPartyCategory where MtPartyCategory_Id=(select MtPartyCategory_Id from MtConnectedMeter where MtConnectedMeter_Id= @pMtConnectedMeter_Id)
	   
  Declare @ContractTradingCdpCount as int=0;      
        
  select @ContractTradingCdpCount=count(1) from MtContractTradingCDPs  MCT      
  inner join MtContractRegistration MCR on MCR.MtContractRegistration_Id=MCT.MtContractRegistration_Id      
  where RuCDPDetail_Id =(Select MtCDPDetail_Id from   [dbo].[MtConnectedMeter] WHERE MtConnectedMeter_Id =@vConnectedMeterId)   and IsNULL(MtContractTradingCDPs_IsDeleted,0)=0      
  and MCR.MtContractRegistration_Status in ('CATV','CDRT') 
  and @pPartyId=case when  MtContractRegistration_MeterOwner='Seller' then MtContractRegistration_SellerId else MtContractRegistration_BuyerId end 
  
  --Check only for contracts When Status is active or drafted       
      
  if(@ContractTradingCdpCount>0)      
  BEGIN      
  Declare @ContractIdWithCdp as varchar(500)=null;      
  select distinct @ContractIdWithCdp= STRING_AGG('Contract # '+CAST(MCT.MtContractRegistration_Id as varchar(18)) + ' Buyer: '+ MPRB.MtPartyRegisteration_Name+', Seller: '+MPRS.MtPartyRegisteration_Name, '<br>')      
  from MtContractTradingCDPs MCT      
inner join MtContractRegistration MCR on MCR.MtContractRegistration_Id=MCT.MtContractRegistration_Id      
inner join MtPartyRegisteration MPRB on MPRB.MtPartyRegisteration_Id=MCR.MtContractRegistration_BuyerId      
inner join MtPartyRegisteration MPRS on MPRS.MtPartyRegisteration_Id=MCR.MtContractRegistration_SellerId      
  where RuCDPDetail_Id=(Select MtCDPDetail_Id from   [dbo].[MtConnectedMeter] WHERE MtConnectedMeter_Id =@vConnectedMeterId)        
  and      
isnull(MtContractTradingCDPs_IsDeleted,0)=0      
  and MCR.MtContractRegistration_Status in ('CATV','CDRT')      
      
     RAISERROR(N'Please remove this CDP from the following Contracts before modification: <br>%s'   , 16, -1,@ContractIdWithCdp)        
  RETURN;        
      
  END      
      
 SELECT @MtConnectedMeterLogs_Id = ISNULL(max(MtConnectedMeterlog_Id),0)+1 FROM [dbo].[MtConnectedMeterlogs]            
       
 INSERT INTO [dbo].[MtConnectedMeterlogs]        
  (MtConnectedMeterlog_Id        
  ,MtConnectedMeter_Id              
  ,MtPartyCategory_Id              
  ,MtCDPDetail_Id                
  ,MtConnectedMeter_CreatedBy        
  ,IsAssigned        
  ,MtConnectedMeter_CreatedOn      
  ,MtConnectedMeter_UnitId      
  ,MtConnectedMeter_ConnectedFrom      
  ,MtConnectedMeter_ConnectedTo      
  ,MtConnectedMeter_EffectiveFrom      
  ,MtConnectedMeter_EffectiveTo      
  ,CongestedZone_Id      
  ,TaxZone_Id      
  ,MtConnectedMeter_isDeleted)        
 (SELECT       
  @MtConnectedMeterLogs_Id      
  ,MtConnectedMeter_Id      
  ,MtPartyCategory_Id      
  ,MtCDPDetail_Id      
  ,MtConnectedMeter_CreatedBy      
  ,IsAssigned      
  ,MtConnectedMeter_CreatedOn      
  ,MtConnectedMeter_UnitId      
  ,MtConnectedMeter_ConnectedFrom      
  ,MtConnectedMeter_ConnectedTo      
  ,MtConnectedMeter_EffectiveFrom      
  ,MtConnectedMeter_EffectiveTo      
  ,CongestedZone_Id      
  ,TaxZone_Id      
  ,MtConnectedMeter_isDeleted      
 FROM [dbo].[MtConnectedMeter] WHERE  MtConnectedMeter_Id=@vConnectedMeterId)      
      
      
 UPDATE  [dbo].[MtConnectedMeter]              
 SET       
  MtConnectedMeter_UnitId =  @vGenerationUnitId,              
  MtConnectedMeter_ConnectedFrom = @vConnectedFromId,              
  MtConnectedMeter_ConnectedTo = @vConnectedToId ,          
  MtConnectedMeter_EffectiveFrom=@vEffectiveFrom,          
  MtConnectedMeter_EffectiveTo =@vEffectiveTo ,        
  CongestedZone_Id = @vCongestedZoneId,        
  TaxZone_Id =@vTaxZoneId       
 WHERE              
  MtConnectedMeter_Id=@vConnectedMeterId           
         
   SELECT       
   @vCdpId=MtCDPDetail_Id      
  ,@vCategoryId =MtPartyCategory_Id      
   FROM       
  MtConnectedMeter       
   WHERE       
  MtConnectedMeter_Id=@vConnectedMeterId      
      
   exec CDPandConnectedMeterSettings @vCdpId,@vCategoryId,0      
              
END              
              
              
END              
        
              
--Alter table  [dbo].[MtConnectedMeter] add  MtConnectedMeter_ConnectedFrom Decimal(18,0)              
--Alter table  [dbo].[MtConnectedMeter] add  MtConnectedMeter_ConnectedTo Decimal(18,0)              
--ALTER table  [dbo].[MtConnectedMeter] add  MtConnectedMeter_UnitId Decimal(18,0)              
--ALTER TABLE [dbo].[MtCDPDetail] add  IsAssigned BIT              
--ALTER table  [dbo].[MtConnectedMeter] add  IsAssigned BIT        
--Alter table [dbo].[MtConnectedMeterlogs] add IsAssigned BIT 

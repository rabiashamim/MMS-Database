/****** Object:  Procedure [dbo].[RemoveConnectedMeter]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.RemoveConnectedMeter    
@vConnectedMeterId decimal(18,0)    
AS    
    
BEGIN    
	DECLARE @pPartyId as DECIMAL(18,0);

	select @pPartyId=MtPartyRegisteration_Id from MtPartyCategory where MtPartyCategory_Id=(select MtPartyCategory_Id from MtConnectedMeter where MtConnectedMeter_Id= @vConnectedMeterId)


  Declare @ContractTradingCdpCount as int=0;  
  select @ContractTradingCdpCount=count(1) from MtContractTradingCDPs  MCT  
  inner join MtContractRegistration MCR on MCR.MtContractRegistration_Id=MCT.MtContractRegistration_Id  
  where RuCDPDetail_Id =(Select MtCDPDetail_Id from   [dbo].[MtConnectedMeter] WHERE MtConnectedMeter_Id =@vConnectedMeterId)   and IsNULL(MtContractTradingCDPs_IsDeleted,0)=0  
  and MCR.MtContractRegistration_Status in ('CATV','CDRT')  
    and @pPartyId=case when  MtContractRegistration_MeterOwner='Seller' then MtContractRegistration_SellerId else MtContractRegistration_BuyerId end 

  --Check only for contracts When Status is active   
  
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
  
     RAISERROR(N'Please remove this CDP from the following Contracts before deletion: <br>%s'   , 16, -1,@ContractIdWithCdp)    
  RETURN;    
  
  END  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
 Update     
  RuCDPDetail    
 Set     
  IsAssigned =0     
 Where     
  RuCDPDetail_Id = (Select MtCDPDetail_Id from   [dbo].[MtConnectedMeter] WHERE MtConnectedMeter_Id =@vConnectedMeterId)    
    
   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    
   UPDATE   
   [dbo].[MtConnectedMeter]   
   set   
   MtConnectedMeter_isDeleted=1   
   WHERE    
     MtConnectedMeter_Id=@vConnectedMeterId    
  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
END    
    
    

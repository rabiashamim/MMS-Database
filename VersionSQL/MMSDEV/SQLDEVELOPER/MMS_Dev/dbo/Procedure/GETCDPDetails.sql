/****** Object:  Procedure [dbo].[GETCDPDetails]    Committed by VersionSQL https://www.versionsql.com ******/

--  GETCDPDetails 723    
CREATE PROCEDURE dbo.GETCDPDetails      
AS    
BEGIN    
  
  
select distinct    
     RuCDPDetail_Id AS ID    
  ,RuCDPDetail_CdpId AS CdpId    
  ,RuCDPDetail_CdpName AS cdpName    
  ,RuCDPDetail_ToCustomer AS ToCustomer    
  ,RuCDPDetail_FromCustomer AS FromCustomer    
  ,RuCDPDetail_LineVoltage AS LineVoltage    
  ,'' AS Primary_MTMeterDetail    
  ,'' AS BackUp_MTMeterDetail    
   --,'' as Connected_ToParty    
   --,'' as Connected_FromParty    

   ,RuCDPDetail_ConnectedFromID as Connected_ToPartyId 
   ,Connected_ToParty=(select mpr.MtPartyRegisteration_Name from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=RuCDPDetail_ConnectedFromID)  
   ,RuCDPDetail_ConnectedToID as Connected_FromPartyId  
   ,Connected_FromParty=(select mpr.MtPartyRegisteration_Name from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=RuCDPDetail_ConnectedToID)  
     
 from      
  [dbo].[RuCDPDetail] RCDP    

 --WHERE   
 -- IsAssigned=0  
  
    
    
END 

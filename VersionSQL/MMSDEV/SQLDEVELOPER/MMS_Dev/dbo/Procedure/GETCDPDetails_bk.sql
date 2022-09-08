/****** Object:  Procedure [dbo].[GETCDPDetails_bk]    Committed by VersionSQL https://www.versionsql.com ******/

--  GETCDPDetails 10  
CREATE PROCEDURE [dbo].[GETCDPDetails_bk]  
@pPartyId decimal(18,0)  
AS  
BEGIN  
  
 select   
     RuCDPDetail_Id AS ID  
  ,RuCDPDetail_CdpId AS CdpId  
  ,RuCDPDetail_CdpName AS cdpName  
  ,RuCDPDetail_ToCustomer AS ToCustomer  
  ,RuCDPDetail_FromCustomer AS FromCustomer  
  ,RuCDPDetail_LineVoltage AS LineVoltage  
  ,'' AS Primary_MTMeterDetail  
  ,'' AS BackUp_MTMeterDetail  
   ,'Connected1' as Connected_ToParty  
   ,'Connected2' as Connected_FromParty  
 from    
  [dbo].[RuCDPDetail] RCDP  
 --LEFT JOIN   
 WHERE   
  ISNULL(IsAssigned,0)=0  
  
END  

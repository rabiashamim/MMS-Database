/****** Object:  Procedure [dbo].[GETCDPsList]    Committed by VersionSQL https://www.versionsql.com ******/

 --======================================================================      
--Author  : Sadaf Malik      
--Reviewer : <>      
--CreatedDate : 16 Feb 2022      
--Comments :       
--======================================================================      
--use mms      
-- [dbo].[GETCDPsList]  1060    
 CREATE PROCEDURE [dbo].[GETCDPsList]            
  @pIsConnectedOnly bit=null          
 AS            
 BEGIN            
  select   distinct    
        rcd.RuCDPDetail_Id      
        ,rcd.RuCDPDetail_CdpId      
        ,rcd.RuCDPDetail_CdpName      
        ,rcd.RuCDPDetail_CdpStatus      
        ,rcd.RuCDPDetail_ToCustomer      
        ,rcd.RuCDPDetail_FromCustomer      
        ,rcd.RuCDPDetail_EffectiveFrom as MtConnectedMeter_EffectiveFrom      
        ,rcd.RuCDPDetail_EffectiveTo  as MtConnectedMeter_EffectiveTo    
        ,rcd.RuCDPDetail_LineVoltage     
  ,rcd.RuCDPDetail_ConnectedFromID    
  ,rcd.RuCDPDetail_ConnectedFromCategoryID  
  ,rcd.RuCDPDetail_ConnectedToCategoryID  
  ,rcd.RuCDPDetail_ConnectedToID --rcd.RuCDPDetail_ConnectedToID    
  ,rcd.RuCDPDetail_EffectiveFromIPP    
  ,rcd.RuCDPDetail_EffectiveToIPP    
  ,rcd.RuCDPDetail_TaxZoneID    
  ,rcd.RuCDPDetail_CongestedZoneID    
        
  ,PrimaryMeterId = CASE WHEN CM.RuCdpMeters_MeterType='Primary' then RuCdpMeters_MeterId else null end      
  ,BackupMeterId = CASE WHEN CM.RuCdpMeters_MeterType='Backup' then RuCdpMeters_MeterId else null end      
  ,VerificationMeterId = CASE WHEN CM.RuCdpMeters_MeterType='Verification' then RuCdpMeters_MeterId else null end      
      
  ,RuCDPDetail_ConnectedFromID as MMSConnectedFromId     
        ,MMSConnectedFromName=(select mpr.MtPartyRegisteration_Name from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=RuCDPDetail_ConnectedFromID)      
        ,RuCDPDetail_ConnectedToID as MMSConnectedToId      
        ,MMSConnectedToName=(select mpr.MtPartyRegisteration_Name from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=RuCDPDetail_ConnectedToID)      
      
  ,CASE     
  WHEN ( ISNULL(RuCDPDetail_ConnectedFromID,0) > 0 AND ISNULL(RuCDPDetail_ConnectedToID,0) > 0 AND RuCDPDetail_ConnectedFromID <> RuCDPDetail_ConnectedToID)  then 'Connected' else 'Not Connected'    
  END AS CdpStatus    
        ,rcd.RuCDPDetail_Station   
		,rcd.IsBackfeedInclude
       -- ,mcm.MtConnectedMeter_Id        
    into #temp    
from       
 RuCDPDetail rcd        
left JOIN  MtConnectedMeter mcm on mcm.MtCDPDetail_Id=rcd.RuCDPDetail_Id  AND mcm.IsAssigned=1 AND ISNULL(mcm.MtConnectedMeter_isDeleted,0)=0        
left JOIN RuCdpMeters CM  ON CM.RuCDPDetail_CdpId=rcd.RuCDPDetail_CdpId   and ISNULL(CM.RuCdpMeters_IsDeleted,0)=0       
order by rcd.RuCDPDetail_Id asc        
    
    
if(@pIsConnectedOnly=1)    
BEGIN    
select * from #temp where CdpStatus='Connected'    
END    
ELSE    
BEGIN    
select * from #temp    
End     
    
END    
          

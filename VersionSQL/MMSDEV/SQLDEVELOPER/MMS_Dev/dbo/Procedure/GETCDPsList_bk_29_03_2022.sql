/****** Object:  Procedure [dbo].[GETCDPsList_bk_29_03_2022]    Committed by VersionSQL https://www.versionsql.com ******/

 --======================================================================  
--Author  : Sadaf Malik  
--Reviewer : <>  
--CreatedDate : 16 Feb 2022  
--Comments :   
--======================================================================  
--use mms  
-- [dbo].[GETCDPsList]  1
 CREATE PROCEDURE [dbo].[GETCDPsList_bk_29_03_2022]        
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
        --,mcm.MtConnectedMeter_EffectiveFrom  
        --,mcm.MtConnectedMeter_EffectiveTo  
        ,rcd.RuCDPDetail_LineVoltage  
    
  ,PrimaryMeterId = CASE WHEN CM.RuCdpMeters_MeterType='Primary' then RuCdpMeters_MeterId else null end  
  ,BackupMeterId = CASE WHEN CM.RuCdpMeters_MeterType='Backup' then RuCdpMeters_MeterId else null end  
  ,VerificationMeterId = CASE WHEN CM.RuCdpMeters_MeterType='Verification' then RuCdpMeters_MeterId else null end  
  
  
        ,MMSConnectedFromId=(select mpr.MtPartyRegisteration_Id from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=mcm.MtConnectedMeter_ConnectedFrom)  
        ,MMSConnectedFromName=(select mpr.MtPartyRegisteration_Name from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=mcm.MtConnectedMeter_ConnectedFrom)  
        ,MMSConnectedToId=(select mpr.MtPartyRegisteration_Id from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=mcm.MtConnectedMeter_ConnectedTo)  
        ,MMSConnectedToName=(select mpr.MtPartyRegisteration_Name from MtPartyRegisteration mpr where mpr.MtPartyRegisteration_Id=mcm.MtConnectedMeter_ConnectedTo)  
  
        ,CdpStatus=(  
           select   
            case when( count(1)=2) THEN 'Connected' ELSE 'Not Connected'   
            END   
           from   
            MtConnectedMeter mcm1   
           where   
            mcm1.MtCDPDetail_Id=rcd.RuCDPDetail_Id   
            and ISNULL(MtConnectedMeter_isDeleted,0)=0    
            and ISNULL(IsAssigned,0)=1
			)    
        ,rcd.RuCDPDetail_Station    
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
   

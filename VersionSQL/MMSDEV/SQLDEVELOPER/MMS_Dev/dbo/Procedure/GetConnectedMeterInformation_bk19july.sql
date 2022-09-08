/****** Object:  Procedure [dbo].[GetConnectedMeterInformation_bk19july]    Committed by VersionSQL https://www.versionsql.com ******/

  -- GetConnectedMeterInformation 1107              
CREATE PROCEDURE [dbo].[GetConnectedMeterInformation_bk19july]            
@pPartyCategoryId DECIMAL(18,0)=null                
AS                
BEGIN                
                
Select                 
CM.MtConnectedMeter_Id,                
CM.MtConnectedMeter_UnitId as GenerationUnitId,        
  
  
CDP.RuCDPDetail_EffectiveFromIPP as EffectiveFrom,            
CDP.RuCDPDetail_EffectiveToIPP as EffectiveTo,            
            
--G.MtGenerator_Name as GenerationUnit,                
GU.MtGenerationUnit_UnitName as GenerationUnit1,    
(select
case when MPC.SrCategory_Code='BPC' or MPC.SrCategory_Code='EBPC' Then G.MtGenerator_Name
ELSE GU.MtGenerationUnit_UnitName END
from MtPartyCategory MPC where MPC.MtPartyCategory_Id=CM.MtPartyCategory_Id) as GenerationUnit,


CDP.RuCDPDetail_CdpId as CDPID,                
CDP.RuCDPDetail_CdpName as CDPName,                
CDP.RuCDPDetail_FromCustomer as FromCustomer,                
CDP.RuCDPDetail_ToCustomer as ToCustomer,                
(select top 1 MtPartyRegisteration_Name from MtPartyRegisteration WHERE  MtPartyRegisteration_id =CDP.RuCDPDetail_ConnectedToID) as ConnectedToName,                
(select top 1 MtPartyRegisteration_Name from MtPartyRegisteration WHERE  MtPartyRegisteration_id =CDP.RuCDPDetail_ConnectedFromID) as ConnectedFromName ,              
  
--Case When CDP.MtCDPDetail_Primary_MtMeterDetail_Id is null  then 'not found!' else  Convert(varchar(20), CDP.MtCDPDetail_Primary_MtMeterDetail_Id) end as PrimaryMeter,            
--Case When CDP.MtCDPDetail_BackUp_MtMeterDetail_Id is null then 'not found!' else CONVERT(varchar(20), CDP.MtCDPDetail_BackUp_MtMeterDetail_Id) end as BackupMeter,            
--Case When CDP.MtCDPDetail_Other_MtMeterDetail_Id is null then 'not found!' else  CONVERT(VARCHAR(20),CDP.MtCDPDetail_Other_MtMeterDetail_Id) end as OtherMeter,            
          
            
          
CDP.RuCDPDetail_ConnectedToID as ConnectedTo,                
CDP.RuCDPDetail_ConnectedFromID as ConnectedFrom,                
ISNULL(CM.IsAssigned,1) AS IsAssigned                
--(Case WHEN CM.MtConnectedMeter_ConnectedFrom =0 then 'Self'                
--     ELSE PRFrom.MtPartyRegisteration_Name END) as ConnectedFromName,                
--(Case WHEN CM.MtConnectedMeter_ConnectedTo =0 then 'Self'                
--     ELSE PRTo.MtPartyRegisteration_Name END) as ConnectedToName                
           
 ,TZ.MtTaxZone_Id           
 ,TZ.MtTaxZone_Name          
 ,CZ.MtCongestedZone_Id          
 ,CZ.MtCongestedZone_Name          
          
           
from [dbo].[MtConnectedMeter] CM                
JOIN [dbo].[RuCDPDetail]  CDP ON CDP.RuCDPDetail_Id = CM.MtCDPDetail_Id                
LEFT JOIN [dbo].[MtGenerationUnit] GU ON GU.MtGenerationUnit_Id = CM.MtConnectedMeter_UnitId  
LEFT JOIN [dbo].[MtGenerator] G ON G.MtGenerator_Id = CM.MtConnectedMeter_UnitId  
        
                
LEFT JOIN [dbo].[MtCongestedZone] CZ ON CZ.MtCongestedZone_Id =  CDP.RuCDPDetail_CongestedZoneID         
LEFT JOIN [dbo].[MtTaxZone] TZ ON TZ.MtTaxZone_Id = CDP.RuCDPDetail_TaxZoneID          
WHERE      
CM.MtPartyCategory_Id=@pPartyCategoryId         
and ISNULL(CM.MtConnectedMeter_isDeleted,0)=0      
      
order by 1 desc                
                
                
END 

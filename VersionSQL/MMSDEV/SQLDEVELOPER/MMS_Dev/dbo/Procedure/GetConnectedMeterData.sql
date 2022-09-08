/****** Object:  Procedure [dbo].[GetConnectedMeterData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetConnectedMeterData]        
@PartyId decimal (18,0)
AS
BEGIN        
       SELECT   
 MtConnectedMeter_Id  
 ,PC.SrCategory_Code  
 ,SC.SrCategory_Name  
 ,MtConnectedMeter_UnitId  
 ,MtConnectedMeter_ConnectedFrom  
 ,MtConnectedMeter_ConnectedTo  
 ,TaxZone_Id  
 ,CongestedZone_Id  
 ,MtConnectedMeter_EffectiveFrom   
 ,MtConnectedMeter_EffectiveTo  
FROM   
     MtPartyRegisteration PR  
  JOIN MtPartyCategory PC ON PR.MtPartyRegisteration_Id=PC.MtPartyRegisteration_Id AND PC.isDeleted= 0  
  JOIN SrCategory SC ON SC.SrCategory_Code=PC.SrCategory_Code and SC.SrCategory_Code NOT IN ('PAKT', 'INTT')  
  LEFT JOIN MtConnectedMeter CM ON PC.MtPartyCategory_Id = CM.MtPartyCategory_Id and ISNULL(CM.MtConnectedMeter_isDeleted,0)=0   
    
  
WHERE   
  PR.MtPartyRegisteration_Id=@PartyId  
     
END         

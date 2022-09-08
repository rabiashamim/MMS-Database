/****** Object:  View [dbo].[Bme_PartyCdps]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 


CREATE VIEW [dbo].[Bme_PartyCdps]
AS
SELECT distinct  p.MtPartyRegisteration_Id as PartyRegisteration_Id, p.MtPartyRegisteration_Name as PartyRegisteration_Name, p.SrPartyType_Code as PartyType_Code,
                P.MtPartyRegisteration_IsPowerPool AS PartyIsPowerPool, c.MtPartyCategory_Id as PartyCategory_Id, c.SrCategory_Code AS PartyCategory_Code,
               cdp.RuCDPDetail_ConnectedFromID AS FromPartyRegisteration_Id,
			    cdp.RuCDPDetail_FromCustomerCategory AS FromPartyCategory_Code,
			   cdp.RuCDPDetail_ConnectedToID AS ToPartyRegisteration_Id,    
			   cdp.RuCDPDetail_ToCustomerCategory AS ToPartyCategory_Code,
               cdp.RuCDPDetail_Id,cdp.RuCDPDetail_CdpId,cdp.RuCDPDetail_CongestedZoneID, cz.MtCongestedZone_Name,cdp.RuCDPDetail_TaxZoneID,	
    cdp.RuCDPDetail_IsEnergyImported 
                  

FROM            dbo.MtPartyRegisteration AS p
INNER JOIN dbo.MtPartyCategory as c ON p.MtPartyRegisteration_Id = c.MtPartyRegisteration_Id
inner join dbo.MtConnectedMeter as MC
  on c.MtPartyCategory_Id=MC.MtPartyCategory_Id
  inner join dbo.RuCDPDetail as cdp
  on  cdp.RuCDPDetail_Id=MC.MtCDPDetail_Id
  inner join dbo.MtCongestedZone as cz
  on  cdp.RuCDPDetail_CongestedZoneID=cz.MtCongestedZone_Id
  where cdp.RuCDPDetail_CongestedZoneID is not null and p.isDeleted=0 and c.isDeleted=0 and MC.MtConnectedMeter_isDeleted=0 and p.LuStatus_Code_Applicant='AACT'

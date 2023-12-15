/****** Object:  View [dbo].[vw_PartyRegisteration]    Committed by VersionSQL https://www.versionsql.com ******/

--select * from vw_PartyRegisteration
CREATE view vw_PartyRegisteration
as 
SELECT        
  MtPartyRegisteration_Name        
   , MtPartyCategory_ApplicationDate        
   , SrPartyType_Name        
   , MtPartyCategory_ApplicationId        
   , SrCategory_Name    
   ,mpr.MtPartyRegisteration_Id
FROM MtPartyRegisteration mpr        
INNER JOIN SrPartyType spt        
 ON mpr.SrPartyType_Code = spt.SrPartyType_Code        
INNER JOIN MtPartyCategory mpc        
 ON mpr.MtPartyRegisteration_Id = mpc.MtPartyRegisteration_Id        
INNER JOIN SrCategory sc        
 ON mpc.SrCategory_Code = sc.SrCategory_Code        
  AND isnull(mpr.isDeleted,0) =0
        

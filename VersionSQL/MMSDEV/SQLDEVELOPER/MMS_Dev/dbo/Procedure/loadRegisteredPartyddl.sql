/****** Object:  Procedure [dbo].[loadRegisteredPartyddl]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[loadRegisteredPartyddl]    
AS    
BEGIN    
    
 --SELECT     
 -- MtPartyRegisteration_Id    
 -- ,MtPartyRegisteration_Name     
 --FROM     
 -- MtPartyRegisteration    
 -- INNER JOIN LuStatus ls ON MtPartyRegisteration.LuStatus_Code_Applicant = ls.LuStatus_Code    
 --   WHERE    
 -- ls.LuStatus_Category = 'APPLICATION'  
 --   -- commented by ALI Imran 01-March-2022  
 --   -- this check is removed by QA team AS per dicussion with BA team.  
 --    --and SrPartyType_Code <> 'EP'    
 --  AND     
 --  LuStatus_Code_Applicant IN ('AACT', 'ASUS','APP')    



 SELECT     
  mr.MtPartyRegisteration_Id,    
  mc.MtPartyCategory_Id
  MtPartyCategory_Id,
  CONCAT(MtPartyRegisteration_Name, ' - ', SrCategory_Code) AS MtPartyRegisteration_Name
 FROM     
  MtPartyRegisteration mr   
  INNER JOIN LuStatus ls ON mr.LuStatus_Code_Applicant = ls.LuStatus_Code 
  inner join MtPartyCategory mc on mr.MtPartyRegisteration_Id = mc.MtPartyRegisteration_Id
    WHERE    
  ls.LuStatus_Category = 'APPLICATION'  
    -- commented by ALI Imran 01-March-2022  
    -- this check is removed by QA team AS per dicussion with BA team.  
     --and SrPartyType_Code <> 'EP'    
   AND     
   LuStatus_Code_Applicant IN ('AACT', 'ASUS','APP')  
   AND
   mc.isDeleted=0
   and
   mr.isDeleted=0
   order by 1
       
END    
  
select * from LuStatus order by 3  

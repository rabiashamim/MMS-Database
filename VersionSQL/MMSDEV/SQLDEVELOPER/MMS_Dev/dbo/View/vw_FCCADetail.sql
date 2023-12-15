/****** Object:  View [dbo].[vw_FCCADetail]    Committed by VersionSQL https://www.versionsql.com ******/

create view vw_FCCADetail
as 
 SELECT DISTINCT  
  FCCA.MtFCCAMaster_Id AS FCCAMasterId  
    ,GP.MtPartyRegisteration_Name AS PartyName  
    ,FCCA.MtFCCAMaster_ModifiedOn as ExecutionDate  
 FROM MtFCCAMaster FCCA  
 INNER JOIN vw_GeneratorParties GP  
  ON FCCA.MtPartyRegisteration_Id = GP.MtPartyRegisteration_Id  
 WHERE ISNULL(FCCA.MtFCCAMaster_IsDeleted, 0) = 0   

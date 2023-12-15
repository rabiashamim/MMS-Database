/****** Object:  View [dbo].[vw_FirmCapacityCertificate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE View  vw_FirmCapacityCertificate               
 as  
  SELECT DISTINCT  
  ISNULL(FCC.MtFCCMaster_Id, 0) AS [FCCMasterID]  
    ,FCDG.MtFCDMaster_Id AS MtFCDMaster_Id  
    ,FCDG.MtGenerator_Id AS [GeneratorID]  
    ,G.MtGenerator_Name AS [GeneratorName]  
    ,G.MtPartyRegisteration_Name AS [PartyName]  
    ,FCC.LuFirmCapacityType_Id AS [FCCTypeID]  
    ,FCT.LuFirmCapacityType_Name AS [FCCTypeName]  
    ,FCDG.MtFCDGenerators_InitialFirmCapacity AS [InitialFirmCapacity]  
    ,FCC.MtFCCMaster_TotalCertificates AS [TotalCertificates]  
    ,Format(ISNULL(FCC.MtFCCMaster_IssuanceDate,''), 'dd-MMM-yyyy hh:mm tt')  AS [IssuanceDate]  
    ,Format(ISNULL(FCC.MtFCCMaster_ExpiryDate,''), 'dd-MMM-yyyy hh:mm tt') AS [ExpiryDate]  
    ,ISNULL(FCC.LuStatus_Code, 'New') AS [Status]  
    ,ISNULL(FCC.MtFCCMaster_ApprovalCode, 'Draft') AS [ApprovalStatus]  
 FROM MtFCDGenerators FCDG  
 INNER JOIN vw_GeneratorParties G  
  ON FCDG.MtGenerator_Id = G.MtGenerator_Id  
 LEFT JOIN MtFCCMaster FCC  
  ON FCDG.MtFCDMaster_Id = FCC.MtFCDMaster_Id  
   AND FCDG.MtGenerator_Id = FCC.MtGenerator_Id--RS20230427  
   AND ISNULL(MtFCCMaster_IsDeleted, 0) = 0  
 LEFT JOIN LuFirmCapacityType FCT  
  ON FCC.LuFirmCapacityType_Id = FCT.LuFirmCapacityType_Id  
 INNER JOIN MtFCDMaster mf  
  ON FCDG.MtFCDMaster_Id = mf.MtFCDMaster_Id 
  where isnull(fcc.MtFCCMaster_IsDeleted, 0) = 0   

  

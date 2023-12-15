/****** Object:  Procedure [dbo].[FCC_GetProcessList]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Ammama Gill      
-- CREATE date: 07 Apr 2023      
-- ALTER date:       
-- Description:       
-- =================================================================================       
-- dbo.FCC_GetProcessList @pGeneratorID=32, @pMtFCDMaster_Id=24    
CREATE PROCEDURE dbo.FCC_GetProcessList @pGeneratorID DECIMAL(18, 0) = 0,  
@pMtFCDMaster_Id DECIMAL(18, 0) = 0  
AS  
BEGIN  
  
 SELECT DISTINCT  
  ISNULL(FCC.MtFCCMaster_Id, 0) AS [FCCMasterID]  
    ,FCDG.MtFCDMaster_Id AS MtFCDMaster_Id  
    ,FCDG.MtGenerator_Id AS [GeneratorID]  
    ,G.MtGenerator_Name AS [GeneratorName]  
    ,G.MtPartyRegisteration_Name AS [PartyName]  
    ,FCC.LuFirmCapacityType_Id AS [FCCTypeID]  
    ,FCT.LuFirmCapacityType_Name AS [FCCTypeName]  
    ,ROUND(FCDG.MtFCDGenerators_InitialFirmCapacity,1) AS [InitialFirmCapacity]  
    ,FCC.MtFCCMaster_TotalCertificates AS [TotalCertificates]
	,L.LuAccountingMonth_MonthName as [FCSettlementPeriod] 
    ,FCC.MtFCCMaster_IssuanceDate AS [IssuanceDate]  
    ,FCC.MtFCCMaster_ExpiryDate AS [ExpiryDate]  
    ,ISNULL(FCC.LuStatus_Code, 'New') AS [Status]  
    ,ISNULL(FCC.MtFCCMaster_ApprovalCode, 'Draft') AS [ApprovalStatus]  
    ,FCC.MtFCCMaster_ExecutionTime AS MtFccMaster_ExecutionStartDate  
    ,FCC.MtFCCMaster_ModifiedOn as [ModifiedDate] 
	,mf.LuAccountingMonth_Id
	
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
  inner join LuAccountingMonth L on L.LuAccountingMonth_Id=mf.LuAccountingMonth_Id 
  
 WHERE (@pMtFCDMaster_Id = 0  
 OR FCDG.MtFCDMaster_Id = @pMtFCDMaster_Id)  
 AND (@pGeneratorID = 0  
 OR FCDG.MtGenerator_Id = @pGeneratorID)  
 AND ISNULL(MtFCDGenerators_IsDeleted, 0) = 0  
 AND mf.MtFCDMaster_ProcessStatus NOT IN ('Interrupted') --Ammama: Needs to be updated once status codes are incorporated   
 AND mf.MtFCDMaster_ApprovalStatus = 'Approved'  
 ORDER BY FCDG.MtFCDMaster_Id DESC, GeneratorId ASC  
END

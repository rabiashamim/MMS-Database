/****** Object:  Procedure [dbo].[BMCFinal_SameAsPreliminary]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================          
-- Author:  Ammama Gill                            
-- CREATE date: Jan 03, 2023                             
-- ALTER date:                             
-- Reviewer:                            
-- Description: BMC final Same as Preliminary Statement                          
-- =============================================                             
-- =============================================                             
-- v  
  
CREATE PROCEDURE dbo.BMCFinal_SameAsPreliminary (@pStatementProcessId DECIMAL(18, 0),  
@pUserId INT)  
  
AS  
BEGIN  
  
 BEGIN TRY  
  
  --- 1. get the Preliminary Statement ID from this ID.   
  DECLARE @vPreliminaryStatementID DECIMAL(18, 0);  
  SELECT  
   @vPreliminaryStatementID = [dbo].[GetBMCStatementProcessID] (@pStatementProcessId);  
  -- msp.MtStatementProcess_ID  
  --FROM MtStatementProcess msp  
  --WHERE msp.SrProcessDef_ID = 14  
  --AND msp.MtStatementProcess_IsDeleted = 0  
  --AND msp.MtStatementProcess_ApprovalStatus = 'Approved'  
  --AND LuAccountingMonth_Id_Current = (SELECT  
  --  msp.LuAccountingMonth_Id_Current  
  -- FROM MtStatementProcess msp  
  -- WHERE msp.MtStatementProcess_ID = @pStatementProcessId  
  -- AND msp.MtStatementProcess_IsDeleted = 0)  
  
  
  
  --- 2. Update input versions  
  
  UPDATE versionFSS  
  SET versionFSS.Version = versionPSS.Version  
  FROM BMEInputsSOFilesVersions versionFSS  
  JOIN [BMEInputsSOFilesVersions] versionPSS  
   ON versionFSS.SOFileTemplateId  
   = versionPSS.SOFileTemplateId  
  WHERE versionFSS.SettlementProcessId = @pStatementProcessId  
  AND versionPSS.SettlementProcessId = @vPreliminaryStatementID;  
  
  --- 3. Insert data  
  
  INSERT INTO BMCVariablesData (BMCVariablesData_ReserveMargin, BMCVariablesData_EfficientlevelReserve, BMCVariablesData_UnitaryCostCapacity, BMCVariablesData_KEShare_MW, BMCVariablesData_CapacityBalanceNegativeSum, BMCVariablesData_CapacityBalancePositiveSum, BMCVariablesData_EfficientDemandLevel_EDL, BMCVariablesData_Slope, BMCVariablesData_C_Constant, BMCVariablesData_Point_D_Qty, BMCVariablesData_CapacityPrice, MtStatementProcess_ID)  
   SELECT  
    bd.BMCVariablesData_ReserveMargin  
      ,bd.BMCVariablesData_EfficientlevelReserve  
      ,bd.BMCVariablesData_UnitaryCostCapacity  
      ,bd.BMCVariablesData_KEShare_MW  
      ,bd.BMCVariablesData_CapacityBalanceNegativeSum  
      ,bd.BMCVariablesData_CapacityBalancePositiveSum  
      ,bd.BMCVariablesData_EfficientDemandLevel_EDL  
      ,bd.BMCVariablesData_Slope  
      ,bd.BMCVariablesData_C_Constant  
      ,bd.BMCVariablesData_Point_D_Qty  
      ,bd.BMCVariablesData_CapacityPrice  
      ,@pStatementProcessId  
   FROM BMCVariablesData bd  
   WHERE bd.MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  
  
  INSERT INTO BMCAllocationFactors (BMCAllocationFactors_AllocationFactor, MtPartyRegisteration_Id, MtStatementProcess_ID)  
   SELECT  
    bf.BMCAllocationFactors_AllocationFactor  
      ,bf.MtPartyRegisteration_Id  
      ,@pStatementProcessId  
   FROM BMCAllocationFactors bf  
   WHERE bf.MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  
  INSERT INTO BMCActualEnergyCriticalHourly (BMCActualEnergyCriticalHourly_Year, BMCActualEnergyCriticalHourly_Month, BMCActualEnergyCriticalHourly_Day, BMCActualEnergyCriticalHourly_Hour, BMCActualEnergyCriticalHourly_ActualEnergy, MtPartyRegisteration_Id, MtStatementProcess_ID)  
  
   SELECT  
    BMCActualEnergyCriticalHourly_Year  
      ,BMCActualEnergyCriticalHourly_Month  
      ,BMCActualEnergyCriticalHourly_Day  
      ,BMCActualEnergyCriticalHourly_Hour  
      ,BMCActualEnergyCriticalHourly_ActualEnergy  
      ,MtPartyRegisteration_Id  
      ,@pStatementProcessId  
   FROM BMCActualEnergyCriticalHourly bech  
   WHERE bech.MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  
  INSERT INTO BMCAvailableCapacityGU (BMCAvailableCapacityGU_AvgCapacitySO, BMCAvailableCapacityGU_AvgCapacityCal, BMCAvailableCapacityGU_SoUnitId, MtGenerator_Id, MtGenerationUnit_Id, MtStatementProcess_ID)  
   SELECT  
    BMCAvailableCapacityGU_AvgCapacitySO  
      ,BMCAvailableCapacityGU_AvgCapacityCal  
      ,BMCAvailableCapacityGU_SoUnitId  
      ,MtGenerator_Id  
      ,MtGenerationUnit_Id  
      ,@pStatementProcessId  
   FROM BMCAvailableCapacityGU bcg  
   WHERE bcg.MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  
  INSERT INTO BMCAvailableCapacityGen (BMCAvailableCapacityGen_AvailableCapacityAvg, BMCAvailableCapacityGen_AvailableCapacityKE, BMCAvailableCapacityGen_AvailableCapacityAfterKE, MtGenerator_Id, MtStatementProcess_ID)  
   SELECT  
    BMCAvailableCapacityGen_AvailableCapacityAvg  
      ,BMCAvailableCapacityGen_AvailableCapacityKE  
      ,BMCAvailableCapacityGen_AvailableCapacityAfterKE  
      ,MtGenerator_Id  
      ,@pStatementProcessId  
   FROM BMCAvailableCapacityGen bcg  
   WHERE bcg.MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  
  INSERT INTO BMCAvailableCapacityGUHourly (BMCAvailableCapacityGUHourly_Date, BMCAvailableCapacityGUHourly_Hour, BMCAvailableCapacityGUHourly_CriticalHourCapacity, BMCAvailableCapacityGUHourly_SoUnitId, MtGenerationUnit_Id, MtGenerator_Id, MtStatementProcess_ID)  
   SELECT  
    BMCAvailableCapacityGUHourly_Date  
      ,BMCAvailableCapacityGUHourly_Hour  
      ,BMCAvailableCapacityGUHourly_CriticalHourCapacity  
      ,BMCAvailableCapacityGUHourly_SoUnitId  
      ,MtGenerationUnit_Id  
      ,MtGenerator_Id  
      ,@pStatementProcessId  
   FROM BMCAvailableCapacityGUHourly  
   WHERE MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  INSERT INTO BMCMPData (BMCMPData_AllocatedCapacity, BMCMPData_CapacityRequirement, BMCMPData_CapacityBalance, BMCMPData_CapacityPurchased, BMCMPData_CapacitySold, BMCMPData_AmountReceivable, BMCMPData_AmountPayable, MtPartyRegisteration_Id, MtStatementProcess_ID, BMCMPData_Actual_E)  
   SELECT  
    BMCMPData_AllocatedCapacity  
      ,BMCMPData_CapacityRequirement  
      ,BMCMPData_CapacityBalance  
      ,BMCMPData_CapacityPurchased  
      ,BMCMPData_CapacitySold  
      ,BMCMPData_AmountReceivable  
      ,BMCMPData_AmountPayable  
      ,MtPartyRegisteration_Id  
      ,@pStatementProcessId  
      ,BMCMPData_Actual_E  
   FROM BMCMPData b  
   WHERE b.MtStatementProcess_ID = @vPreliminaryStatementID;  
  
  
  --------- Update logs -----------------  
  INSERT INTO MtStatementProcessSteps (MtStatementProcessSteps_Status, MtStatementProcessSteps_Description, MtStatementProcess_ID, RuStepDef_ID, MtStatementProcessSteps_CreatedBy, MtStatementProcessSteps_CreatedOn)  
   SELECT  
    MtStatementProcessSteps_Status  
      ,MtStatementProcessSteps_Description  
      ,@pStatementProcessId  
      ,(SELECT  
      rsd.RuStepDef_ID  
     FROM RuStepDef rsd  
     WHERE rsd.RuStepDef_BMEStepNo = (SELECT  
       rsd.RuStepDef_BMEStepNo  
      FROM RuStepDef rsd  
      WHERE rsd.RuStepDef_ID = msps.RuStepDef_ID)  
     AND rsd.SrProcessDef_ID = 15)  
      ,@pUserId  
      ,GETUTCDATE()  
   FROM MtStatementProcessSteps msps  
   WHERE MtStatementProcess_ID = @vPreliminaryStatementID  
  
  INSERT INTO [dbo].[MtSattlementProcessLogs] ([MtStatementProcess_ID]  
  , [MtSattlementProcessLog_Message]  
  , [MtSattlementProcessLog_CreatedBy]  
  , [MtSattlementProcessLog_CreatedOn])  
   VALUES (@pStatementProcessId, 'Generate BMC - Final same as BMC - Preliminary completed', 100, GETUTCDATE())  
  
  UPDATE MtStatementProcess  
  SET MtStatementProcess_Status = 'Executed'  
     ,MtStatementProcess_ApprovalStatus = 'Draft'  
     ,MtStatementProcess_ExecutionStartDate = DATEADD(HOUR, 5, GETUTCDATE())  
     ,MtStatementProcess_ExecutionFinishDate = DATEADD(HOUR, 5, GETUTCDATE())  
  WHERE MtStatementProcess_ID = @pStatementProcessId;  
  
 END TRY  
 BEGIN CATCH  
  
  DECLARE @vErrorMessage VARCHAR(MAX) = '';  
  SELECT  
   @vErrorMessage = ERROR_MESSAGE();  
  RAISERROR (@vErrorMessage, 16, -1);  
 END CATCH  
  
END

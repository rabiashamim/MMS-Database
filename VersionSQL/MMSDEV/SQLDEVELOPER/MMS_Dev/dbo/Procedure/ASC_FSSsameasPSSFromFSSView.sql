/****** Object:  Procedure [dbo].[ASC_FSSsameasPSSFromFSSView]    Committed by VersionSQL https://www.versionsql.com ******/

--   select * from [dbo].[MtStatementProcess]  
--  [dbo].[BME_FSSsameasPSS] 3  
-- Delete from MtStatementProcess  where SrProcessDef_ID=4  
  
CREATE PROCEDURE [dbo].[ASC_FSSsameasPSSFromFSSView]  
@pPSSsettlementProcessId decimal  
,@pFSSsettlementProcessId decimal  
AS  
BEGIN  
  update MtStatementProcess set MtStatementProcess_Status='Executed', MtStatementProcess_ApprovalStatus='Executed', MtStatementProcess_ExecutionStartDate=DATEADD(hour,5,GETUTCDATE()), MtStatementProcess_ExecutionFinishDate=Dateadd(hour,5,GETUTCDATE()) where MtStatementProcess_ID=@pFSSsettlementProcessId;
  
--INSERT INTO [dbo].[BMEInputsSOFilesVersions]  
--           ([SettlementProcessId]  
--           ,[SOFileTemplateId]  
--           ,[Version]  
--           ,[BMEInputsSOFilesVersions_CreatedBy]  
--           ,[BMEInputsSOFilesVersions_CreatedOn])  
  
--   select @pFSSsettlementProcessId, SOFileTemplateId,Version,BMEInputsSOFilesVersions_CreatedBy,BMEInputsSOFilesVersions_CreatedOn  from [BMEInputsSOFilesVersions] where SettlementProcessId=@pPSSsettlementProcessId  ;  
  update versionFSS  set versionFSS.Version=versionPSS.Version 
  from BMEInputsSOFilesVersions versionFSS
  join [BMEInputsSOFilesVersions] versionPSS on versionFSS.SOFileTemplateId
=versionPSS.SOFileTemplateId
  where versionFSS.SettlementProcessId=@pFSSsettlementProcessId and versionPSS.SettlementProcessId=@pPSSsettlementProcessId
  
--------------------------------------------------------------------\  
	INSERT INTO [dbo].[BmeStatementDataMpCategoryHourly_SettlementProcess]
	(
		[BmeStatementData_NtdcDateTime],
		[BmeStatementData_Year],
		[BmeStatementData_Month],
		[BmeStatementData_Day],
		[BmeStatementData_Hour],
		[BmeStatementData_AdjustedEnergy],
		[BmeStatementData_TransmissionLosses],
		[BmeStatementData_DemandedEnergy],
		[BmeStatementData_UpliftTransmissionLosses],
		[BmeStatementData_ActualEnergy],
		[BmeStatementData_EnergySuppliedActual],
		[BmeStatementData_EnergySuppliedGenerated],
		[BmeStatementData_EnergySuppliedImport],
		[BmeStatementData_PartyRegisteration_Id],
		[BmeStatementData_PartyName],
		[BmeStatementData_PartyType_Code],
		[BmeStatementData_PartyCategory_Code],
		[BmeStatementData_AdjustedEnergyImport],
		[BmeStatementData_AdjustedEnergyExport],
		[BmeStatementData_EnergySuppliedGeneratedLegacy],
		[BmeStatementData_EnergySuppliedImportedLegacy],
		[BmeStatementData_CAPLegacy],
		[BmeStatementData_EnergySuppliedImported],
		[BmeStatementData_ActualCapacity],
		[BmeStatementData_EnergyTradedBought],
		[BmeStatementData_EnergyTradedSold],
		[BmeStatementData_EnergyTraded],
		[BmeStatementData_Imbalance],
		[BmeStatementData_ImbalanceCharges],
		[BmeStatementData_MarginalPrice],
		[BmeStatementData_BSUPRatioPP],
		[BmeStatementData_IsPowerPool],
		[BmeStatementData_CongestedZoneID],
		[BmeStatementData_ES],
		[BmeStatementData_MAC],
		[BmeStatementData_IG_AC],
		[BmeStatementData_RG_AC],
		[BmeStatementData_GS_SC],
		[BmeStatementData_GBS_BSC],
		[BmeStatementData_TAC],
		[BmeStatementData_MRC],
		[BmeStatementData_TC],
		[BmeStatementData_StatementProcessId],
		[BmeStatementData_SettlementProcessId]
	)
		
		Select
		[BmeStatementData_NtdcDateTime],
		[BmeStatementData_Year],
		[BmeStatementData_Month],
		[BmeStatementData_Day],
		[BmeStatementData_Hour],
		[BmeStatementData_AdjustedEnergy],
		[BmeStatementData_TransmissionLosses],
		[BmeStatementData_DemandedEnergy],
		[BmeStatementData_UpliftTransmissionLosses],
		[BmeStatementData_ActualEnergy],
		[BmeStatementData_EnergySuppliedActual],
		[BmeStatementData_EnergySuppliedGenerated],
		[BmeStatementData_EnergySuppliedImport],
		[BmeStatementData_PartyRegisteration_Id],
		[BmeStatementData_PartyName],
		[BmeStatementData_PartyType_Code],
		[BmeStatementData_PartyCategory_Code],
		[BmeStatementData_AdjustedEnergyImport],
		[BmeStatementData_AdjustedEnergyExport],
		[BmeStatementData_EnergySuppliedGeneratedLegacy],
		[BmeStatementData_EnergySuppliedImportedLegacy],
		[BmeStatementData_CAPLegacy],
		[BmeStatementData_EnergySuppliedImported],
		[BmeStatementData_ActualCapacity],
		[BmeStatementData_EnergyTradedBought],
		[BmeStatementData_EnergyTradedSold],
		[BmeStatementData_EnergyTraded],
		[BmeStatementData_Imbalance],
		[BmeStatementData_ImbalanceCharges],
		[BmeStatementData_MarginalPrice],
		[BmeStatementData_BSUPRatioPP],
		[BmeStatementData_IsPowerPool],
		[BmeStatementData_CongestedZoneID],
		[BmeStatementData_ES],
		[BmeStatementData_MAC],
		[BmeStatementData_IG_AC],
		[BmeStatementData_RG_AC],
		[BmeStatementData_GS_SC],
		[BmeStatementData_GBS_BSC],
		[BmeStatementData_TAC],
		[BmeStatementData_MRC],
		[BmeStatementData_TC],
		@pFSSsettlementProcessId,
		@pFSSsettlementProcessId
		From [dbo].[BmeStatementDataMpCategoryHourly_SettlementProcess] where BmeStatementData_StatementProcessId=@pPSSsettlementProcessId  

		---------------------------------------------
			INSERT INTO [dbo].[BmeStatementDataMpCategoryMonthly_SettlementProcess]
	(
		[BmeStatementData_Year],
		[BmeStatementData_Month],
		[BmeStatementData_EnergySuppliedActual],
		[BmeStatementData_PartyRegisteration_Id],
		[BmeStatementData_PartyName],
		[BmeStatementData_PartyType_Code],
		[BmeStatementData_PartyCategory_Code],
		[BmeStatementData_IsPowerPool],
		[BmeStatementData_CongestedZoneID],
		[BmeStatementData_ES],
		[BmeStatementData_MAC],
		[BmeStatementData_IG_AC],
		[BmeStatementData_RG_AC],
		[BmeStatementData_GS_SC],
		[BmeStatementData_GBS_BSC],
		[BmeStatementData_TAC],
		[BmeStatementData_MRC],
		[BmeStatementData_TC],
		[BmeStatementData_StatementProcessId],
		[BmeStatementData_SettlementProcessId]
	)
		select 
		[BmeStatementData_Year],
		[BmeStatementData_Month],
		[BmeStatementData_EnergySuppliedActual],
		[BmeStatementData_PartyRegisteration_Id],
		[BmeStatementData_PartyName],
		[BmeStatementData_PartyType_Code],
		[BmeStatementData_PartyCategory_Code],
		[BmeStatementData_IsPowerPool],
		[BmeStatementData_CongestedZoneID],
		[BmeStatementData_ES],
		[BmeStatementData_MAC],
		[BmeStatementData_IG_AC],
		[BmeStatementData_RG_AC],
		[BmeStatementData_GS_SC],
		[BmeStatementData_GBS_BSC],
		[BmeStatementData_TAC],
		[BmeStatementData_MRC],
		[BmeStatementData_TC],
		@pFSSsettlementProcessId,
		@pFSSsettlementProcessId
	from [dbo].[BmeStatementDataMpCategoryMonthly_SettlementProcess] where BmeStatementData_StatementProcessId=@pPSSsettlementProcessId

	-------------------------------------------------------------
INSERT INTO [dbo].[AscStatementDataCdpGuParty_SettlementProcess]
(
	[AscStatementData_GuPartyRegisteration_Id]
	,[AscStatementData_GuPartyRegisteration_Name]
	,[AscStatementData_GuPartyCategory_Code]
	,[AscStatementData_GuPartyType_Code]
	,[AscStatementData_CdpId]
	,[AscStatementData_FromPartyRegisteration_Id]
	,[AscStatementData_FromPartyRegisteration_Name]
	,[AscStatementData_FromPartyCategory_Code]
	,[AscStatementData_FromPartyType_Code]
	,[AscStatementData_ToPartyRegisteration_Id]
	,[AscStatementData_ToPartyRegisteration_Name]
	,[AscStatementData_ToPartyCategory_Code]
	,[AscStatementData_ToPartyType_Code]
	,[AscStatementData_ISARE]
	,[AscStatementData_ISThermal]
	,[AscStatementData_RuCDPDetail_Id]
	,[AscStatementData_IsLegacy]
	,[AscStatementData_IsEnergyImported]
	,[AscStatementData_IsPowerPool]
	,[AscStatementData_GenerationUnit_Id]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_SOUnitId]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
Select
	[AscStatementData_GuPartyRegisteration_Id]
	,[AscStatementData_GuPartyRegisteration_Name]
	,[AscStatementData_GuPartyCategory_Code]
	,[AscStatementData_GuPartyType_Code]
	,[AscStatementData_CdpId]
	,[AscStatementData_FromPartyRegisteration_Id]
	,[AscStatementData_FromPartyRegisteration_Name]
	,[AscStatementData_FromPartyCategory_Code]
	,[AscStatementData_FromPartyType_Code]
	,[AscStatementData_ToPartyRegisteration_Id]
	,[AscStatementData_ToPartyRegisteration_Name]
	,[AscStatementData_ToPartyCategory_Code]
	,[AscStatementData_ToPartyType_Code]
	,[AscStatementData_ISARE]
	,[AscStatementData_ISThermal]
	,[AscStatementData_RuCDPDetail_Id]
	,[AscStatementData_IsLegacy]
	,[AscStatementData_IsEnergyImported]
	,[AscStatementData_IsPowerPool]
	,[AscStatementData_GenerationUnit_Id]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_SOUnitId]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
from  [dbo].[AscStatementDataCdpGuParty_SettlementProcess] where AscStatementData_StatementProcessId=@pPSSsettlementProcessId
------------------------------------------------------------------------------------

INSERT INTO [dbo].[AscStatementDataGenMonthly_SettlementProcess]
(
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyRegisteration_Name]
	,[AscStatementData_PartyCategory_Code]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_MtPartyCategory_Id]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SO_RG_UT]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_TAC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_MR_UPC]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
Select
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyRegisteration_Name]
	,[AscStatementData_PartyCategory_Code]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_MtPartyCategory_Id]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SO_RG_UT]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_TAC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_MR_UPC]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
From [dbo].[AscStatementDataGenMonthly_SettlementProcess] where AscStatementData_StatementProcessId=@pPSSsettlementProcessId


-------------------------------------------------------------------------------------

INSERT INTO [dbo].[AscStatementDataGuHourly_SettlementProcess]
(

	[AscStatementData_NtdcDateTime]
	,[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_Day]
	,[AscStatementData_Hour]
	,[AscStatementData_GenerationUnit_Id]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_TechnologyType_Code]
	,[AscStatementData_FuelType_Code]
	,[AscStatementData_UnitNumber]
	,[AscStatementData_InstalledCapacity_KW]
	,[AscStatementData_location]
	,[AscStatementData_IsDisabled]
	,[AscStatementData_EffectiveFrom]
	,[AscStatementData_EffectiveTo]
	,[AscStatementData_ModifiedBy]
	,[AscStatementData_ModifiedOn]
	,[AscStatementData_UnitName]
	,[AscStatementData_SOUnitId]
	,[AscStatementData_IsEnergyImported]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyRegisteration_Name]
	,[AscStatementData_PartyCategory_Code]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_MtPartyCategory_Id]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SO_RG_UT]
	,[AscStatementData_IsIG]
	,[AscStatementData_IsRG]
	,[AscStatementData_IsGenMR]
	,[AscStatementData_IsGenBS]
	,[AscStatementData_IsGenS]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_MR_UPC]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
Select
	[AscStatementData_NtdcDateTime]
	,[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_Day]
	,[AscStatementData_Hour]
	,[AscStatementData_GenerationUnit_Id]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_TechnologyType_Code]
	,[AscStatementData_FuelType_Code]
	,[AscStatementData_UnitNumber]
	,[AscStatementData_InstalledCapacity_KW]
	,[AscStatementData_location]
	,[AscStatementData_IsDisabled]
	,[AscStatementData_EffectiveFrom]
	,[AscStatementData_EffectiveTo]
	,[AscStatementData_ModifiedBy]
	,[AscStatementData_ModifiedOn]
	,[AscStatementData_UnitName]
	,[AscStatementData_SOUnitId]
	,[AscStatementData_IsEnergyImported]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyRegisteration_Name]
	,[AscStatementData_PartyCategory_Code]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_MtPartyCategory_Id]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SO_RG_UT]
	,[AscStatementData_IsIG]
	,[AscStatementData_IsRG]
	,[AscStatementData_IsGenMR]
	,[AscStatementData_IsGenBS]
	,[AscStatementData_IsGenS]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_MR_UPC]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
From [dbo].[AscStatementDataGuHourly_SettlementProcess] where AscStatementData_StatementProcessId=@pPSSsettlementProcessId

INSERT INTO [dbo].[AscStatementDataGuMonthly_SettlementProcess]
(
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_GenerationUnit_Id]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_TechnologyType_Code]
	,[AscStatementData_FuelType_Code]
	,[AscStatementData_UnitNumber]
	,[AscStatementData_InstalledCapacity_KW]
	,[AscStatementData_location]
	,[AscStatementData_IsDisabled]
	,[AscStatementData_EffectiveFrom]
	,[AscStatementData_EffectiveTo]
	,[AscStatementData_ModifiedBy]
	,[AscStatementData_ModifiedOn]
	,[AscStatementData_UnitName]
	,[AscStatementData_SOUnitId]
	,[AscStatementData_IsEnergyImported]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyRegisteration_Name]
	,[AscStatementData_PartyCategory_Code]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_MtPartyCategory_Id]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SO_RG_UT]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_GS_NS]
	,[AscStatementData_GS_SC]
	,[AscStatementData_IsIG]
	,[AscStatementData_IsRG]
	,[AscStatementData_IsGenMR]
	,[AscStatementData_IsGenBS]
	,[AscStatementData_IsGenS]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_MR_UPC]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
Select
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_GenerationUnit_Id]
	,[AscStatementData_Generator_Id]
	,[AscStatementData_TechnologyType_Code]
	,[AscStatementData_FuelType_Code]
	,[AscStatementData_UnitNumber]
	,[AscStatementData_InstalledCapacity_KW]
	,[AscStatementData_location]
	,[AscStatementData_IsDisabled]
	,[AscStatementData_EffectiveFrom]
	,[AscStatementData_EffectiveTo]
	,[AscStatementData_ModifiedBy]
	,[AscStatementData_ModifiedOn]
	,[AscStatementData_UnitName]
	,[AscStatementData_SOUnitId]
	,[AscStatementData_IsEnergyImported]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyRegisteration_Name]
	,[AscStatementData_PartyCategory_Code]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_MtPartyCategory_Id]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SO_RG_UT]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_GS_NS]
	,[AscStatementData_GS_SC]
	,[AscStatementData_IsIG]
	,[AscStatementData_IsRG]
	,[AscStatementData_IsGenMR]
	,[AscStatementData_IsGenBS]
	,[AscStatementData_IsGenS]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_MR_UPC]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
FROM [dbo].[AscStatementDataGuMonthly_SettlementProcess] where AscStatementData_StatementProcessId=@pPSSsettlementProcessId

INSERT INTO [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess]
(
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyName]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_PAYABLE]
	,[AscStatementData_RECEIVABLE]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
Select
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyName]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_PAYABLE]
	,[AscStatementData_RECEIVABLE]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
from  [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess] where AscStatementData_StatementProcessId=@pPSSsettlementProcessId

INSERT INTO [dbo].[AscStatementDataZoneMonthly_SettlementProcess]
(
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_TAC]
	,[AscStatementData_TD]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
SELECT
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_Congestion_Zone]
	,[AscStatementData_SO_MP]
	,[AscStatementData_SO_AC]
	,[AscStatementData_SO_AC_ASC]
	,[AscStatementData_SO_MR_EP]
	,[AscStatementData_SO_MR_VC]
	,[AscStatementData_SO_RG_VC]
	,[AscStatementData_SO_RG_EG_ARE]
	,[AscStatementData_SO_IG_VC]
	,[AscStatementData_SO_IG_EPG]
	,[AscStatementData_MR_EAG]
	,[AscStatementData_MR_EPG]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_EAG]
	,[AscStatementData_AC_MOD]
	,[AscStatementData_RG_LOCC]
	,[AscStatementData_IG_EAG]
	,[AscStatementData_IG_EPG]
	,[AscStatementData_IG_UPC]
	,[AscStatementData_AC_Total]
	,[AscStatementData_TaxZoneID]
	,[AscStatementData_CongestedZoneID]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_TAC]
	,[AscStatementData_TD]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
	from [dbo].[AscStatementDataZoneMonthly_SettlementProcess] where AscStatementData_StatementProcessId=@pPSSsettlementProcessId



	INSERT INTO [AscStatementDataMpMonthly_SettlementProcess]
(
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyName]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_PAYABLE]
	,[AscStatementData_RECEIVABLE]
	,[AscStatementData_StatementProcessId]
	,[AscStatementData_SettlementProcessId]
)
Select 
	[AscStatementData_Year]
	,[AscStatementData_Month]
	,[AscStatementData_PartyRegisteration_Id]
	,[AscStatementData_PartyName]
	,[AscStatementData_PartyType_Code]
	,[AscStatementData_MRC]
	,[AscStatementData_RG_AC]
	,[AscStatementData_IG_AC]
	,[AscStatementData_SC_BSC]
	,[AscStatementData_MAC]
	,[AscStatementData_GS_SC]
	,[AscStatementData_GBS_BSC]
	,[AscStatementData_PAYABLE]
	,[AscStatementData_RECEIVABLE]
	,@pFSSsettlementProcessId
	,@pFSSsettlementProcessId
	FROM [AscStatementDataMpMonthly_SettlementProcess] where [AscStatementData_StatementProcessId]=@pPSSsettlementProcessId;

	----------------------------------
  
INSERT INTO [dbo].[MtStatementProcessSteps]  
           ([MtStatementProcessSteps_Status]  
           ,[MtStatementProcessSteps_Description]  
           ,[MtStatementProcess_ID]  
           ,[RuStepDef_ID]  
           ,[MtStatementProcessSteps_CreatedBy]  
           ,[MtStatementProcessSteps_CreatedOn])  
   select  
           MPS.MtStatementProcessSteps_Status  
     ,MPS.MtStatementProcessSteps_Description  
           ,@pFSSsettlementProcessId
           --,[RuStepDef_ID]  
     , (select RSD2.RuStepDef_ID from RuStepDef RSD2 where RSD2.SrProcessDef_ID=5 and RSD2.RuStepDef_BMEStepNo=(select RSD1.RuStepDef_BMEStepNo from RuStepDef RSD1 where RSD1.RuStepDef_ID=MPS.RuStepDef_ID))  
           ,MPS.MtStatementProcessSteps_CreatedBy  
           ,MPS.MtStatementProcessSteps_CreatedOn  
     from   
    [dbo].[MtStatementProcessSteps] MPS where MPS.MtStatementProcess_ID=@pPSSsettlementProcessId  
------------------------  
--Insert into LOGS table  
  
--------Insert into logs table  
  
INSERT INTO [dbo].[MtSattlementProcessLogs]  
           ([MtStatementProcess_ID]  
           ,[MtSattlementProcessLog_Message]  
           ,[MtSattlementProcessLog_CreatedBy]  
           ,[MtSattlementProcessLog_CreatedOn])  
		   Values(
		   @pFSSsettlementProcessId,
		   'Generate ASC - FSS same as PSS completed'
		   ,100,
		   GETUTCDATE()
		   )

--select @pFSSsettlementProcessId
--           ,[MtSattlementProcessLog_Message]  
--           ,[MtSattlementProcessLog_CreatedBy]  
--           ,[MtSattlementProcessLog_CreatedOn]  
--     FROM [dbo].[MtSattlementProcessLogs] where MtStatementProcess_ID=@pPSSsettlementProcessId  

--	 delete from [dbo].[MtSattlementProcessLogs] where MtStatementProcess_ID=@pPSSsettlementProcessId and MtSattlementProcessLog_ID=(
--	 select max(MtSattlementProcessLog_ID) from [dbo].[MtSattlementProcessLogs] where MtStatementProcess_ID=@pPSSsettlementProcessId
--	 )
	Select 1;
END  

/****** Object:  Procedure [dbo].[BME_FSSsameasPSSFromPSSView]    Committed by VersionSQL https://www.versionsql.com ******/

--   select * from [dbo].[MtStatementProcess]  
--  [dbo].[BME_FSSsameasPSS] 3  
-- Delete from MtStatementProcess  where SrProcessDef_ID=4  
  
CREATE PROCEDURE [dbo].[BME_FSSsameasPSSFromPSSView]  
@pSettlementProcessId decimal  
AS  
BEGIN  
  
Declare @vSettlementExists int=null;  
Declare @vNewSettlementPeriod table (ID int);  
  
select @vSettlementExists=count(1) from [MtStatementProcess] where LuAccountingMonth_Id_Current=(select LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pSettlementProcessId) and SrProcessDef_ID=4  
if(@vSettlementExists>0)  
BEGIN  
select 'Settlement already exists';  
RETURN;  
END  
  
INSERT INTO [dbo].[MtStatementProcess]  
           ([MtStatementProcess_ID]  
           ,[SrProcessDef_ID]  
           ,[LuAccountingMonth_Id_Current]  
           ,[MtStatementProcess_ExecutionStartDate]  
           ,[MtStatementProcess_ExecutionFinishDate]  
           ,[MtStatementProcess_Status]  
           ,[MtStatementProcess_ApprovalStatus]  
           ,[MtStatementProcess_CreatedBy]  
           ,[MtStatementProcess_CreatedOn]  
           ,[MtStatementProcess_IsDeleted])  
   OUTPUT Inserted.MtStatementProcess_ID into @vNewSettlementPeriod  
select (select max (MtStatementProcess_ID)+1 from MtStatementProcess),4,LuAccountingMonth_Id_Current,MtStatementProcess_ExecutionStartDate, MtStatementProcess_ExecutionFinishDate ,'Executed', 'Executed',MtStatementProcess_CreatedBy,
DATEADD(HOUR,5, GETUTCDATE()),0 from MtStatementProcess where MtStatementProcess_ID=@pSettlementProcessId  
  
INSERT INTO [dbo].[BMEInputsSOFilesVersions]  
           ([SettlementProcessId]  
           ,[SOFileTemplateId]  
           ,[Version]  
           ,[BMEInputsSOFilesVersions_CreatedBy]  
           ,[BMEInputsSOFilesVersions_CreatedOn])  
  
   select (select top 1 ID from @vNewSettlementPeriod), SOFileTemplateId,Version,BMEInputsSOFilesVersions_CreatedBy,BMEInputsSOFilesVersions_CreatedOn  from [BMEInputsSOFilesVersions] where SettlementProcessId=@pSettlementProcessId  ;  
  
  
--------------------------------------------------------------------\  
insert into BmeStatementDataCdpHourly_SettlementProcess  
(  
 BmeStatementData_NtdcDateTime  
 ,BmeStatementData_Year  
 ,BmeStatementData_Month  
 ,BmeStatementData_Day  
 ,BmeStatementData_Hour  
 ,BmeStatementData_CdpId  
 ,BmeStatementData_MeterIdImport  
 ,BmeStatementData_IncEnergyImport  
 ,BmeStatementData_DataSourceImport  
 ,BmeStatementData_MeterIdExport  
 ,BmeStatementData_IncEnergyExport  
 ,BmeStatementData_DataSourceExport  
 ,BmeStatementData_CreatedBy  
 ,BmeStatementData_CreatedOn  
 ,BmeStatementData_ModifiedBy  
 ,BmeStatementData_ModifiedOn  
 ,BmeStatementData_LineVoltage  
 ,BmeStatementData_FromPartyRegisteration_Id  
 ,BmeStatementData_FromPartyRegisteration_Name  
 ,BmeStatementData_FromPartyCategory_Code  
 ,BmeStatementData_FromPartyType_Code  
 ,BmeStatementData_DistLosses_Factor  
 ,BmeStatementData_DistLosses_EffectiveFrom  
 ,BmeStatementData_DistLosses_EffectiveTo  
 ,BmeStatementData_ToPartyRegisteration_Id  
 ,BmeStatementData_ToPartyRegisteration_Name  
 ,BmeStatementData_ToPartyCategory_Code  
 ,BmeStatementData_ToPartyType_Code  
 ,BmeStatementData_AdjustedEnergy  
 ,BmeStatementData_TransmissionLosses  
 ,BmeStatementData_DemandedEnergy  
 ,BmeStatementData_AdjustedEnergyExport  
 ,BmeStatementData_AdjustedEnergyImport  
 ,BmeStatementData_ActualEnergy  
 ,BmeStatementData_EnergySuppliedGenerated  
 ,BmeStatementData_EnergySuppliedActual  
 ,BmeStatementData_IsEnergyImported  
 ,BmeStatementData_OwnerId  
 ,[BmeStatementData_ISARE]  
 ,[BmeStatementData_ISThermal]  
 ,[BmeStatementData_RuCDPDetail_Id]  
 ,[BmeStatementData_IsLegacy]  
 ,[BmeStatementData_EnergySuppliedImported]  
 ,[BmeStatementData_StatementProcessId]  
)  
 select   
 BmeStatementData_NtdcDateTime  
 ,BmeStatementData_Year  
 ,BmeStatementData_Month  
 ,BmeStatementData_Day  
 ,BmeStatementData_Hour  
 ,BmeStatementData_CdpId  
 ,BmeStatementData_MeterIdImport  
 ,BmeStatementData_IncEnergyImport  
 ,BmeStatementData_DataSourceImport  
 ,BmeStatementData_MeterIdExport  
 ,BmeStatementData_IncEnergyExport  
 ,BmeStatementData_DataSourceExport  
 ,BmeStatementData_CreatedBy  
 ,BmeStatementData_CreatedOn  
 ,BmeStatementData_ModifiedBy  
 ,BmeStatementData_ModifiedOn  
 ,BmeStatementData_LineVoltage  
 ,BmeStatementData_FromPartyRegisteration_Id  
 ,BmeStatementData_FromPartyRegisteration_Name  
 ,BmeStatementData_FromPartyCategory_Code  
 ,BmeStatementData_FromPartyType_Code  
 ,BmeStatementData_DistLosses_Factor  
 ,BmeStatementData_DistLosses_EffectiveFrom  
 ,BmeStatementData_DistLosses_EffectiveTo  
 ,BmeStatementData_ToPartyRegisteration_Id  
 ,BmeStatementData_ToPartyRegisteration_Name  
 ,BmeStatementData_ToPartyCategory_Code  
 ,BmeStatementData_ToPartyType_Code  
 ,BmeStatementData_AdjustedEnergy  
 ,BmeStatementData_TransmissionLosses  
 ,BmeStatementData_DemandedEnergy  
 ,BmeStatementData_AdjustedEnergyExport  
 ,BmeStatementData_AdjustedEnergyImport  
 ,BmeStatementData_ActualEnergy  
 ,BmeStatementData_EnergySuppliedGenerated  
 ,BmeStatementData_EnergySuppliedActual  
 ,BmeStatementData_IsEnergyImported  
 ,BmeStatementData_OwnerId  
 ,[BmeStatementData_ISARE]  
 ,[BmeStatementData_ISThermal]  
 ,[BmeStatementData_RuCDPDetail_Id]  
 ,[BmeStatementData_IsLegacy]  
 ,[BmeStatementData_EnergySuppliedImported]  
 ,(select ID from @vNewSettlementPeriod)  
from BmeStatementDataCdpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
------1 end------  
  
  
------------2 [dbo].[BmeStatementDataHourly_SettlementProcess]------  
  
  
insert into [dbo].[BmeStatementDataHourly_SettlementProcess]  
(  
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_TransmissionLosses]  
 ,[BmeStatementData_DemandedEnergy]  
 ,[BmeStatementData_UpliftTransmissionLosses]  
 ,[BmeStatementData_ActualCapacity]  
 ,[BmeStatementData_EnergySuppliedGenerated]  
 ,[BmeStatementData_EnergySuppliedImported]  
 ,[BmeStatementData_EnergySuppliedGeneratedLegacy]  
 ,[BmeStatementData_EnergySuppliedImportedLegacy]  
 ,[BmeStatementData_CAPLegacy]  
 ,[BmeStatementData_StatementProcessId]  
)  
  
SELECT  
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_TransmissionLosses]  
 ,[BmeStatementData_DemandedEnergy]  
 ,[BmeStatementData_UpliftTransmissionLosses]  
 ,[BmeStatementData_ActualCapacity]  
 ,[BmeStatementData_EnergySuppliedGenerated]  
 ,[BmeStatementData_EnergySuppliedImported]  
 ,[BmeStatementData_EnergySuppliedGeneratedLegacy]  
 ,[BmeStatementData_EnergySuppliedImportedLegacy]  
 ,[BmeStatementData_CAPLegacy]  
 ,(select ID from @vNewSettlementPeriod)  
 from [dbo].[BmeStatementDataHourly_SettlementProcess]   
 where [BmeStatementData_StatementProcessId]=@pSettlementProcessId  
  
---------2 end-------------  
  
------------3 [dbo].[BmeStatementDataTspHourly_SettlementProcess] -----  
  
insert into BmeStatementDataTspHourly_SettlementProcess  
(  
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_PartyRegisteration_Id]  
 ,[BmeStatementData_PartyName]  
 ,[BmeStatementData_PartyCategory_Code]  
 ,[BmeStatementData_PartyType_Code]  
 ,[BmeStatementData_AdjustedEnergyImport]  
 ,[BmeStatementData_AdjustedEnergyExport]  
 ,[BmeStatementData_TransmissionLosses]  
 ,[BmeStatementData_StatementProcessId]  
)  
  
SELECT   
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_PartyRegisteration_Id]  
 ,[BmeStatementData_PartyName]  
 ,[BmeStatementData_PartyCategory_Code]  
 ,[BmeStatementData_PartyType_Code]  
 ,[BmeStatementData_AdjustedEnergyImport]  
 ,[BmeStatementData_AdjustedEnergyExport]  
 ,[BmeStatementData_TransmissionLosses]  
 ,(select ID from @vNewSettlementPeriod)  
 from BmeStatementDataTspHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId;  
  
 ---------3 end----------  
  
------4 [dbo].[BmeStatementDataMpHourly_SettlementProcess]---------  
  
  
insert into [dbo].[BmeStatementDataMpHourly_SettlementProcess]  
(  
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_AdjustedEnergy]  
 ,[BmeStatementData_TransmissionLosses]  
 ,[BmeStatementData_DemandedEnergy]  
 ,[BmeStatementData_UpliftTransmissionLosses]  
 ,[BmeStatementData_ActualEnergy]  
 ,[BmeStatementData_EnergySuppliedActual]  
 ,[BmeStatementData_EnergySuppliedGenerated]  
 ,[BmeStatementData_EnergySuppliedImport]  
 ,[BmeStatementData_PartyRegisteration_Id]  
 ,[BmeStatementData_PartyName]  
 ,[BmeStatementData_PartyType_Code]  
 ,[BmeStatementData_AdjustedEnergyImport]  
 ,[BmeStatementData_AdjustedEnergyExport]  
 ,[BmeStatementData_EnergySuppliedGeneratedLegacy]  
 ,[BmeStatementData_EnergySuppliedImportedLegacy]  
 ,[BmeStatementData_CAPLegacy]  
 ,[BmeStatementData_EnergySuppliedImported]  
 ,[BmeStatementData_ActualCapacity]  
 ,[BmeStatementData_EnergyTradedBought]  
 ,[BmeStatementData_EnergyTradedSold]  
 ,[BmeStatementData_EnergyTraded]  
 ,[BmeStatementData_Imbalance]  
 ,[BmeStatementData_ImbalanceCharges]  
 ,[BmeStatementData_MarginalPrice]  
 ,[BmeStatementData_BSUPRatioPP]  
 ,[BmeStatementData_StatementProcessId]  
)  
  
select   
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_AdjustedEnergy]  
 ,[BmeStatementData_TransmissionLosses]  
 ,[BmeStatementData_DemandedEnergy]  
 ,[BmeStatementData_UpliftTransmissionLosses]  
 ,[BmeStatementData_ActualEnergy]  
 ,[BmeStatementData_EnergySuppliedActual]  
 ,[BmeStatementData_EnergySuppliedGenerated]  
 ,[BmeStatementData_EnergySuppliedImport]  
 ,[BmeStatementData_PartyRegisteration_Id]  
 ,[BmeStatementData_PartyName]  
 ,[BmeStatementData_PartyType_Code]  
 ,[BmeStatementData_AdjustedEnergyImport]  
 ,[BmeStatementData_AdjustedEnergyExport]  
 ,[BmeStatementData_EnergySuppliedGeneratedLegacy]  
 ,[BmeStatementData_EnergySuppliedImportedLegacy]  
 ,[BmeStatementData_CAPLegacy]  
 ,[BmeStatementData_EnergySuppliedImported]  
 ,[BmeStatementData_ActualCapacity]  
 ,[BmeStatementData_EnergyTradedBought]  
 ,[BmeStatementData_EnergyTradedSold]  
 ,[BmeStatementData_EnergyTraded]  
 ,[BmeStatementData_Imbalance]  
 ,[BmeStatementData_ImbalanceCharges]  
 ,[BmeStatementData_MarginalPrice]  
 ,[BmeStatementData_BSUPRatioPP]  
 ,(select ID from @vNewSettlementPeriod)  
from [dbo].[BmeStatementDataMpHourly_SettlementProcess] where BmeStatementData_StatementProcessId=@pSettlementProcessId  
  
 ------4 end----  
  
  
-------5 [dbo].[BmeStatementDataCdpContractHourly]  
  
  
insert into [dbo].[BmeStatementDataCdpContractHourly_SettlementProcess]  
(  
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_SellerPartyRegisteration_Id]  
 ,[BmeStatementData_SellerPartyRegisteration_Name]  
 ,[BmeStatementData_SellerPartyCategory_Code]  
 ,[BmeStatementData_SellerPartyType_Code]  
 ,[BmeStatementData_BuyerPartyRegisteration_Id]  
 ,[BmeStatementData_BuyerPartyRegisteration_Name]  
 ,[BmeStatementData_BuyerPartyCategory_Code]  
 ,[BmeStatementData_BuyerPartyType_Code]  
 ,[BmeStatementData_EnergyTradedBought]  
 ,[BmeStatementData_EnergyTradedSold]  
 ,[BmeStatementData_ContractId]  
 ,BmeStatementData_Contract_Id  
 ,[BmeStatementData_ContractType]  
 ,[BmeStatementData_CdpId]  
 ,[BmeStatementData_Percentage]  
 ,[BmeStatementData_ContractedQuantity]  
 ,[BmeStatementData_CapQuantity]  
 ,[BmeStatementData_AncillaryServices]  
 ,[BmeStatementData_ContractType_Id]  
 ,[BmeStatementData_ContractSubType_Id]  
 ,[BmeStatementData_StatementProcessId]  
)  
SELECT   
 [BmeStatementData_NtdcDateTime]  
 ,[BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_Day]  
 ,[BmeStatementData_Hour]  
 ,[BmeStatementData_SellerPartyRegisteration_Id]  
 ,[BmeStatementData_SellerPartyRegisteration_Name]  
 ,[BmeStatementData_SellerPartyCategory_Code]  
 ,[BmeStatementData_SellerPartyType_Code]  
 ,[BmeStatementData_BuyerPartyRegisteration_Id]  
 ,[BmeStatementData_BuyerPartyRegisteration_Name]  
 ,[BmeStatementData_BuyerPartyCategory_Code]  
 ,[BmeStatementData_BuyerPartyType_Code]  
 ,[BmeStatementData_EnergyTradedBought]  
 ,[BmeStatementData_EnergyTradedSold]  
 ,[BmeStatementData_ContractId]  
 ,BmeStatementData_Contract_Id  
 ,[BmeStatementData_ContractType]  
 ,[BmeStatementData_CdpId]  
 ,[BmeStatementData_Percentage]  
 ,[BmeStatementData_ContractedQuantity]  
 ,[BmeStatementData_CapQuantity]  
 ,[BmeStatementData_AncillaryServices]  
 ,[BmeStatementData_ContractType_Id]  
 ,[BmeStatementData_ContractSubType_Id]  
 ,(select ID from @vNewSettlementPeriod)  
from [dbo].[BmeStatementDataCdpContractHourly_SettlementProcess] where BmeStatementData_StatementProcessId=@pSettlementProcessId;  
  
-------5 end---------  
  
  
-----------6 [dbo].[BmeStatementDataMpMonthly_SettlementProcess]  
  
insert into [dbo].[BmeStatementDataMpMonthly_SettlementProcess]  
(  
 [BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_PartyRegisteration_Id]  
 ,[BmeStatementData_PartyName]  
 ---,[BmeStatementData_PartyCategory_Code]  
 ,[BmeStatementData_PartyType_Code]  
 ,[BmeStatementData_ImbalanceCharges]  
 ,[BmeStatementData_SettlementOfLegacy]  
 ,[BmeStatementData_AmountPayableReceivable]  
 ,[BmeStatementData_StatementProcessId]  
)  
select  
 [BmeStatementData_Year]  
 ,[BmeStatementData_Month]  
 ,[BmeStatementData_PartyRegisteration_Id]  
 ,[BmeStatementData_PartyName]  
-- ,[BmeStatementData_PartyCategory_Code]  
 ,[BmeStatementData_PartyType_Code]  
 ,[BmeStatementData_ImbalanceCharges]  
 ,[BmeStatementData_SettlementOfLegacy]  
 ,[BmeStatementData_AmountPayableReceivable]  
 ,(select ID from @vNewSettlementPeriod)  
 from [dbo].[BmeStatementDataMpMonthly_SettlementProcess] where BmeStatementData_StatementProcessId=@pSettlementProcessId;  
  
-----------6 end-----------  
  
  
--------- 7 [dbo].[BMEContractedAmounts_SettlementProcess] ----  
insert into [dbo].[BMEContractedAmounts_SettlementProcess]  
(  
 [BMEContract_SellerPartyId]  
 ,[BMEContract_SellerPartyName]  
 ,[BMEContract_SellerPartyType_Code]  
 ,[BMEContract_BuyerPartyId]  
 ,[BMEContract_BuyerPartyName]  
 ,[BMEContract_BuyerPartyType_Code]  
 ,[BMEContract_ContractType]  
 ,[BMEContract_SrContractType_Id]  
 ,[BMEContract_ContractDay]  
 ,[BMEContract_ContractHour]  
 ,[BMEContract_EnergyTradedBought]  
 ,[BMEContract_EnergyTradedSold]  
 ,[BMEContract_EnergyTraded]  
 ,[BmeContract_SettlementProcessId]  
)  
select  
 [BMEContract_SellerPartyId]  
 ,[BMEContract_SellerPartyName]  
 ,[BMEContract_SellerPartyType_Code]  
 ,[BMEContract_BuyerPartyId]  
 ,[BMEContract_BuyerPartyName]  
 ,[BMEContract_BuyerPartyType_Code]  
 ,[BMEContract_ContractType]  
 ,[BMEContract_SrContractType_Id]  
 ,[BMEContract_ContractDay]  
 ,[BMEContract_ContractHour]  
 ,[BMEContract_EnergyTradedBought]  
 ,[BMEContract_EnergyTradedSold]  
 ,[BMEContract_EnergyTraded]  
 ,(select ID from @vNewSettlementPeriod)  
 from [dbo].[BMEContractedAmounts_SettlementProcess]  
 where BmeContract_SettlementProcessId=@pSettlementProcessId;  
--------- 7 end----------------  
  
---- 8 [dbo].[BmeStatementDataCdpOwnerParty_SettlementProcess]----  
  
insert into [dbo].[BmeStatementDataCdpOwnerParty_SettlementProcess]  
(  
 [BmeStatementData_OwnerPartyRegisteration_Id]  
 ,[BmeStatementData_OwnerPartyRegisteration_Name]  
 ,[BmeStatementData_OwnerPartyCategory_Code]  
 ,[BmeStatementData_OwnerPartyType_Code]  
 ,[BmeStatementData_CdpId]  
 ,[BmeStatementData_FromPartyRegisteration_Id]  
 ,[BmeStatementData_FromPartyRegisteration_Name]  
 ,[BmeStatementData_FromPartyCategory_Code]  
 ,[BmeStatementData_FromPartyType_Code]  
 ,[BmeStatementData_ToPartyRegisteration_Id]  
 ,[BmeStatementData_ToPartyRegisteration_Name]  
 ,[BmeStatementData_ToPartyCategory_Code]  
 ,[BmeStatementData_ToPartyType_Code]  
 ,[BmeStatementData_ISARE]  
 ,[BmeStatementData_ISThermal]  
 ,[BmeStatementData_RuCDPDetail_Id]  
 ,[BmeStatementData_IsLegacy]  
 ,[BmeStatementData_IsEnergyImported]  
 ,[BmeStatementData_IsPowerPool]  
 ,[BmeStatementData_StatementProcessId]  
)  
select   
 [BmeStatementData_OwnerPartyRegisteration_Id]  
 ,[BmeStatementData_OwnerPartyRegisteration_Name]  
 ,[BmeStatementData_OwnerPartyCategory_Code]  
 ,[BmeStatementData_OwnerPartyType_Code]  
 ,[BmeStatementData_CdpId]  
 ,[BmeStatementData_FromPartyRegisteration_Id]  
 ,[BmeStatementData_FromPartyRegisteration_Name]  
 ,[BmeStatementData_FromPartyCategory_Code]  
 ,[BmeStatementData_FromPartyType_Code]  
 ,[BmeStatementData_ToPartyRegisteration_Id]  
 ,[BmeStatementData_ToPartyRegisteration_Name]  
 ,[BmeStatementData_ToPartyCategory_Code]  
 ,[BmeStatementData_ToPartyType_Code]  
 ,[BmeStatementData_ISARE]  
 ,[BmeStatementData_ISThermal]  
 ,[BmeStatementData_RuCDPDetail_Id]  
 ,[BmeStatementData_IsLegacy]  
 ,[BmeStatementData_IsEnergyImported]  
 ,[BmeStatementData_IsPowerPool]  
 ,(select ID from @vNewSettlementPeriod)  
 from [dbo].[BmeStatementDataCdpOwnerParty_SettlementProcess] where BmeStatementData_StatementProcessId=@pSettlementProcessId  
  
-------------------------------  
  
  
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
           ,(select ID from @vNewSettlementPeriod)  
           --,[RuStepDef_ID]  
     , (select RSD2.RuStepDef_ID from RuStepDef RSD2 where RSD2.SrProcessDef_ID=4 and RSD2.RuStepDef_BMEStepNo=(select RSD1.RuStepDef_BMEStepNo from RuStepDef RSD1 where RSD1.RuStepDef_ID=MPS.RuStepDef_ID))  
           ,MPS.MtStatementProcessSteps_CreatedBy  
           ,MPS.MtStatementProcessSteps_CreatedOn  
     from   
    [dbo].[MtStatementProcessSteps] MPS where MPS.MtStatementProcess_ID=@pSettlementProcessId  
------------------------  
--Insert into LOGS table  
  
--------Insert into logs table  
  
INSERT INTO [dbo].[MtSattlementProcessLogs]  
           ([MtStatementProcess_ID]  
           ,[MtSattlementProcessLog_Message]  
           ,[MtSattlementProcessLog_CreatedBy]  
           ,[MtSattlementProcessLog_CreatedOn])  
select (select ID from @vNewSettlementPeriod)  
           ,[MtSattlementProcessLog_Message]  
           ,[MtSattlementProcessLog_CreatedBy]  
           ,[MtSattlementProcessLog_CreatedOn]  
     FROM [dbo].[MtSattlementProcessLogs] where MtStatementProcess_ID=@pSettlementProcessId  
END  

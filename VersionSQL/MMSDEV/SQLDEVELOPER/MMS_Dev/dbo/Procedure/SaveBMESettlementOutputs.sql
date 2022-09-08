/****** Object:  Procedure [dbo].[SaveBMESettlementOutputs]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE   Procedure [dbo].[SaveBMESettlementOutputs]  
  
 @p_settlementProcessId decimal(18,0),  
 @p_settlementProcessMonth int,  
 @p_settlementProcessYear int    
AS  
BEGIN  
 ------[dbo].[BMEContractedAmounts_SettlementProcess]  
  
 --INSERT INTO [dbo].[BMEContractedAmounts_SettlementProcess]  
 --(  
 -- [BMEContract_SellerPartyId],  
 -- [BMEContract_SellerPartyName],  
 -- [BMEContract_SellerPartyType_Code],  
 -- [BMEContract_BuyerPartyId],  
 -- [BMEContract_BuyerPartyName],  
 -- [BMEContract_BuyerPartyType_Code],  
 -- [BMEContract_ContractType],  
 -- [BMEContract_SrContractType_Id],  
 -- [BMEContract_ContractDay],  
 -- [BMEContract_ContractHour],  
 -- [BMEContract_EnergyTradedBought],  
 -- [BMEContract_EnergyTradedSold],  
 -- [BMEContract_EnergyTraded],  
 -- [BMEContract_SettlementProcessId]  
 --)  
  
 --SELECT   
 -- [BMEContract_SellerPartyId],  
 -- [BMEContract_SellerPartyName],  
 -- [BMEContract_SellerPartyType_Code],  
 -- [BMEContract_BuyerPartyId],  
 -- [BMEContract_BuyerPartyName],  
 -- [BMEContract_BuyerPartyType_Code],  
 -- [BMEContract_ContractType],  
 -- [BMEContract_SrContractType_Id],  
 -- [BMEContract_ContractDay],  
 -- [BMEContract_ContractHour],  
 -- [BMEContract_EnergyTradedBought],  
 -- [BMEContract_EnergyTradedSold],  
 -- [BMEContract_EnergyTraded],  
 -- @p_settlementProcessId  
 --FROM   
 -- [dbo].[BMEContractedAmounts]  
    
--------[dbo].[BmeStatementDataCdpContractHourly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataCdpContractHourly_SettlementProcess]  
 (  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_SellerPartyRegisteration_Id],  
  [BmeStatementData_SellerPartyRegisteration_Name],  
  [BmeStatementData_SellerPartyCategory_Code],  
  [BmeStatementData_SellerPartyType_Code],  
  [BmeStatementData_BuyerPartyRegisteration_Id],  
  [BmeStatementData_BuyerPartyRegisteration_Name],  
  [BmeStatementData_BuyerPartyCategory_Code],  
  [BmeStatementData_BuyerPartyType_Code],  
  [BmeStatementData_EnergyTradedBought],  
  [BmeStatementData_EnergyTradedSold],  
  [BmeStatementData_ContractId],  
  [BmeStatementData_Contract_Id],  
  [BmeStatementData_ContractType],  
  [BmeStatementData_CdpId],  
  [BmeStatementData_Percentage],  
  [BmeStatementData_ContractedQuantity],  
  [BmeStatementData_CapQuantity],  
  [BmeStatementData_AncillaryServices],  
  [BmeStatementData_ContractType_Id],  
  [BmeStatementData_ContractSubType_Id],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT   
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_SellerPartyRegisteration_Id],  
  [BmeStatementData_SellerPartyRegisteration_Name],  
  [BmeStatementData_SellerPartyCategory_Code],  
  [BmeStatementData_SellerPartyType_Code],  
  [BmeStatementData_BuyerPartyRegisteration_Id],  
  [BmeStatementData_BuyerPartyRegisteration_Name],  
  [BmeStatementData_BuyerPartyCategory_Code],  
  [BmeStatementData_BuyerPartyType_Code],  
  [BmeStatementData_EnergyTradedBought],  
  [BmeStatementData_EnergyTradedSold],  
  [BmeStatementData_ContractId],  
  [BmeStatementData_Contract_Id],  
  [BmeStatementData_ContractType],  
  [BmeStatementData_CdpId],  
  [BmeStatementData_Percentage],  
  [BmeStatementData_ContractedQuantity],  
  [BmeStatementData_CapQuantity],  
  [BmeStatementData_AncillaryServices],  
  [BmeStatementData_ContractType_Id],  
  [BmeStatementData_ContractSubType_Id],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM  
  BmeStatementDataCdpContractHourly  
 WHERE  
  BmeStatementData_Month = @p_settlementProcessMonth  
  AND BmeStatementData_Year = @p_settlementProcessYear  
  AND [BmeStatementData_StatementProcessId]=@p_settlementProcessId  
--------[dbo].[BmeStatementDataCdpHourly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataCdpHourly_SettlementProcess]  
 (  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_CdpId],  
  [BmeStatementData_MeterIdImport],  
  [BmeStatementData_IncEnergyImport],  
  [BmeStatementData_DataSourceImport],  
  [BmeStatementData_MeterIdExport],  
  [BmeStatementData_IncEnergyExport],  
  [BmeStatementData_DataSourceExport],  
  [BmeStatementData_CreatedBy],  
  [BmeStatementData_CreatedOn],  
  [BmeStatementData_ModifiedBy],  
  [BmeStatementData_ModifiedOn],  
  [BmeStatementData_LineVoltage],  
  [BmeStatementData_FromPartyRegisteration_Id],  
  [BmeStatementData_FromPartyRegisteration_Name],  
  [BmeStatementData_FromPartyCategory_Code],  
  [BmeStatementData_FromPartyType_Code],  
  [BmeStatementData_DistLosses_Factor],  
  [BmeStatementData_DistLosses_EffectiveFrom],  
  [BmeStatementData_DistLosses_EffectiveTo],  
  [BmeStatementData_ToPartyRegisteration_Id],  
  [BmeStatementData_ToPartyRegisteration_Name],  
  [BmeStatementData_ToPartyCategory_Code],  
  [BmeStatementData_ToPartyType_Code],  
  [BmeStatementData_AdjustedEnergy],  
  [BmeStatementData_TransmissionLosses],  
  [BmeStatementData_DemandedEnergy],  
  [BmeStatementData_AdjustedEnergyExport],  
  [BmeStatementData_AdjustedEnergyImport],  
  [BmeStatementData_ActualEnergy],  
  [BmeStatementData_EnergySuppliedGenerated],  
  [BmeStatementData_EnergySuppliedActual],  
  [BmeStatementData_IsEnergyImported],  
  [BmeStatementData_OwnerId],  
  [BmeStatementData_ISARE],  
  [BmeStatementData_ISThermal],  
  [BmeStatementData_RuCDPDetail_Id],  
  [BmeStatementData_IsLegacy],  
  [BmeStatementData_EnergySuppliedImported],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT   
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_CdpId],  
  [BmeStatementData_MeterIdImport],  
  [BmeStatementData_IncEnergyImport],  
  [BmeStatementData_DataSourceImport],  
  [BmeStatementData_MeterIdExport],  
  [BmeStatementData_IncEnergyExport],  
  [BmeStatementData_DataSourceExport],  
  [BmeStatementData_CreatedBy],  
  [BmeStatementData_CreatedOn],  
  [BmeStatementData_ModifiedBy],  
  [BmeStatementData_ModifiedOn],  
  [BmeStatementData_LineVoltage],  
  [BmeStatementData_FromPartyRegisteration_Id],  
  [BmeStatementData_FromPartyRegisteration_Name],  
  [BmeStatementData_FromPartyCategory_Code],  
  [BmeStatementData_FromPartyType_Code],  
  [BmeStatementData_DistLosses_Factor],  
  [BmeStatementData_DistLosses_EffectiveFrom],  
  [BmeStatementData_DistLosses_EffectiveTo],  
  [BmeStatementData_ToPartyRegisteration_Id],  
  [BmeStatementData_ToPartyRegisteration_Name],  
  [BmeStatementData_ToPartyCategory_Code],  
  [BmeStatementData_ToPartyType_Code],  
  [BmeStatementData_AdjustedEnergy],  
  [BmeStatementData_TransmissionLosses],  
  [BmeStatementData_DemandedEnergy],  
  [BmeStatementData_AdjustedEnergyExport],  
  [BmeStatementData_AdjustedEnergyImport],  
  [BmeStatementData_ActualEnergy],  
  [BmeStatementData_EnergySuppliedGenerated],  
  [BmeStatementData_EnergySuppliedActual],  
  [BmeStatementData_IsEnergyImported],  
  [BmeStatementData_OwnerId],  
  [BmeStatementData_ISARE],  
  [BmeStatementData_ISThermal],  
  [BmeStatementData_RuCDPDetail_Id],  
  [BmeStatementData_IsLegacy],  
  [BmeStatementData_EnergySuppliedImported],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM   
  [dbo].[BmeStatementDataCdpHourly]  
 WHERE  
  BmeStatementData_Month = @p_settlementProcessMonth  
  AND BmeStatementData_Year = @p_settlementProcessYear  
  AND [BmeStatementData_StatementProcessId]=@p_settlementProcessId  
------- [dbo].[BmeStatementDataCdpOwnerParty_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataCdpOwnerParty_SettlementProcess]  
 (   
  [BmeStatementData_OwnerPartyRegisteration_Id],  
  [BmeStatementData_OwnerPartyRegisteration_Name],  
  [BmeStatementData_OwnerPartyCategory_Code],  
  [BmeStatementData_OwnerPartyType_Code],  
  [BmeStatementData_CdpId],  
  [BmeStatementData_FromPartyRegisteration_Id],  
  [BmeStatementData_FromPartyRegisteration_Name],  
  [BmeStatementData_FromPartyCategory_Code],  
  [BmeStatementData_FromPartyType_Code],  
  [BmeStatementData_ToPartyRegisteration_Id],  
  [BmeStatementData_ToPartyRegisteration_Name],  
  [BmeStatementData_ToPartyCategory_Code],  
  [BmeStatementData_ToPartyType_Code],  
  [BmeStatementData_ISARE],  
  [BmeStatementData_ISThermal],  
  [BmeStatementData_RuCDPDetail_Id],  
  [BmeStatementData_IsLegacy],  
  [BmeStatementData_IsEnergyImported],  
  [BmeStatementData_IsPowerPool],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT   
  [BmeStatementData_OwnerPartyRegisteration_Id],  
  [BmeStatementData_OwnerPartyRegisteration_Name],  
  [BmeStatementData_OwnerPartyCategory_Code],  
  [BmeStatementData_OwnerPartyType_Code],  
  [BmeStatementData_CdpId],  
  [BmeStatementData_FromPartyRegisteration_Id],  
  [BmeStatementData_FromPartyRegisteration_Name],  
  [BmeStatementData_FromPartyCategory_Code],  
  [BmeStatementData_FromPartyType_Code],  
  [BmeStatementData_ToPartyRegisteration_Id],  
  [BmeStatementData_ToPartyRegisteration_Name],  
  [BmeStatementData_ToPartyCategory_Code],  
  [BmeStatementData_ToPartyType_Code],  
  [BmeStatementData_ISARE],  
  [BmeStatementData_ISThermal],  
  [BmeStatementData_RuCDPDetail_Id],  
  [BmeStatementData_IsLegacy],  
  [BmeStatementData_IsEnergyImported],  
  [BmeStatementData_IsPowerPool],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM  
  BmeStatementDataCdpOwnerParty  
  WHERE [BmeStatementData_StatementProcessId]=@p_settlementProcessId  
------ [dbo].[BmeStatementDataErrorMessage_SettlementProcess]  
 --INSERT INTO [dbo].[BmeStatementDataErrorMessage_SettlementProcess]  
 --(  
 -- [BmeStatementData_Year],  
 -- [BmeStatementData_Month],  
 -- [BmeStatementData_ERROR_NUMBER],  
 -- [BmeStatementData_ERROR_STATE],  
 -- [BmeStatementData_ERROR_SEVERITY],  
 -- [BmeStatementData_ERROR_LINE],  
 -- [BmeStatementData_ERROR_PROCEDURE],  
 -- [BmeStatementData_ERROR_MESSAGE],  
 -- [BmeStatementData_ERROR_TIME],  
 -- [BmeStatementData_SettlementProcessId]  
 --)  
 --SELECT  
 -- [BmeStatementData_Year],  
 -- [BmeStatementData_Month],  
 -- [BmeStatementData_ERROR_NUMBER],  
 -- [BmeStatementData_ERROR_STATE],  
 -- [BmeStatementData_ERROR_SEVERITY],  
 -- [BmeStatementData_ERROR_LINE],  
 -- [BmeStatementData_ERROR_PROCEDURE],  
 -- [BmeStatementData_ERROR_MESSAGE],  
 -- [BmeStatementData_ERROR_TIME],  
 -- @p_settlementProcessId  
 --FROM   
 -- BmeStatementDataErrorMessage  
 --WHERE  
 -- BmeStatementData_Year = @p_settlementProcessYear  
 -- AND BmeStatementData_Month = @p_settlementProcessMonth  
    
------ [dbo].[BmeStatementDataFinalOutputs_SettlementProcess]  
 --INSERT INTO [dbo].[BmeStatementDataFinalOutputs_SettlementProcess]  
 --(  
 -- [MtStatementProcess_ID],  
 -- [BmeStatementData_Year],  
 -- [BmeStatementData_Month],  
 -- [BmeStatementData_PartyRegisteration_Id],  
 -- [BmeStatementData_PartyName],  
 -- [BmeStatementData_PartyCategory_Code],  
 -- [BmeStatementData_PartyType_Code],  
 -- [BmeStatementData_ImbalanceCharges],  
 -- [BmeStatementData_SettlementOfLegacy],  
 -- [BmeStatementData_AmountPayableReceivable],  
 -- [AncillaryServicePayableCharges],  
 -- [AncillaryServiceReceivableCharges],  
 -- [MOFee],  
 -- [OtherChargesPaybale],  
 -- [AdjustmentfromESS],  
 -- [NetAmountPayableReceivable],  
 -- [BmeStatementData_SettlementProcessId]  
 --)   --SELECT  
 -- [MtStatementProcess_ID],  
 -- [BmeStatementData_Year],  
 -- [BmeStatementData_Month],  
 -- [BmeStatementData_PartyRegisteration_Id],  
 -- [BmeStatementData_PartyName],  
 -- [BmeStatementData_PartyCategory_Code],  
 -- [BmeStatementData_PartyType_Code],  
 -- [BmeStatementData_ImbalanceCharges],  
 -- [BmeStatementData_SettlementOfLegacy],  
 -- [BmeStatementData_AmountPayableReceivable],  
 -- [AncillaryServicePayableCharges],  
 -- [AncillaryServiceReceivableCharges],  
 -- [MOFee],  
 -- [OtherChargesPaybale],  
 -- [AdjustmentfromESS],  
 -- [NetAmountPayableReceivable],  
 -- @p_settlementProcessId  
 --FROM   
 -- BmeStatementDataFinalOutputs  
 --WHERE  
 -- BmeStatementData_Year=@p_settlementProcessYear  
 -- AND BmeStatementData_Month = @p_settlementProcessMonth  
  --AND BmeStatementData_StatementProcessId=@p_settlementProcessId  
------ [dbo].[BmeStatementDataHourly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataHourly_SettlementProcess]  
 (  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_TransmissionLosses],  
  [BmeStatementData_DemandedEnergy],  
  [BmeStatementData_UpliftTransmissionLosses],  
  [BmeStatementData_ActualCapacity],  
  [BmeStatementData_EnergySuppliedGenerated],  
  [BmeStatementData_EnergySuppliedImported],  
  [BmeStatementData_EnergySuppliedGeneratedLegacy],  
  [BmeStatementData_EnergySuppliedImportedLegacy],  
  [BmeStatementData_CAPLegacy],  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]   
 )  
 SELECT  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_TransmissionLosses],  
  [BmeStatementData_DemandedEnergy],  
  [BmeStatementData_UpliftTransmissionLosses],  
  [BmeStatementData_ActualCapacity],  
  [BmeStatementData_EnergySuppliedGenerated],  
  [BmeStatementData_EnergySuppliedImported],  
  [BmeStatementData_EnergySuppliedGeneratedLegacy],  
  [BmeStatementData_EnergySuppliedImportedLegacy],  
  [BmeStatementData_CAPLegacy],  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM   
  BmeStatementDataHourly  
 WHERE  
  BmeStatementData_Year = @p_settlementProcessYear  
  AND BmeStatementData_Month = @p_settlementProcessMonth  
  AND BmeStatementData_StatementProcessId=@p_settlementProcessId  
------ [dbo].[BmeStatementDataMpCategoryHourly_SettlementProcess]  
   
  
------ [dbo].[BmeStatementDataMpContractHourly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataMpContractHourly_SettlementProcess]  
 (  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_SellerPartyRegisteration_Id],  
  [BmeStatementData_SellerPartyRegisteration_Name],  
  [BmeStatementData_SellerPartyType_Code],  
  [BmeStatementData_BuyerPartyRegisteration_Id],  
  [BmeStatementData_BuyerPartyRegisteration_Name],  
  [BmeStatementData_BuyerPartyType_Code],  
  [BmeStatementData_EnergyTradedBought],  
  [BmeStatementData_EnergyTradedSold],  
  [BmeStatementData_ContractId],  
  [BmeStatementData_ContractType],  
  [BmeStatementData_Percentage],  
  [BmeStatementData_ContractedQuantity],  
  [BmeStatementData_CapQuantity],  
  [BmeStatementData_AncillaryServices],  
  [BmeStatementData_ContractType_Id],  
  [BmeStatementData_ContractSubType_Id],  
  [BmeStatementData_SellerPartyCategory_Code],  
  [BmeStatementData_BuyerPartyCategory_Code],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT   
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_SellerPartyRegisteration_Id],  
  [BmeStatementData_SellerPartyRegisteration_Name],  
  [BmeStatementData_SellerPartyType_Code],  
  [BmeStatementData_BuyerPartyRegisteration_Id],  
  [BmeStatementData_BuyerPartyRegisteration_Name],  
  [BmeStatementData_BuyerPartyType_Code],  
  [BmeStatementData_EnergyTradedBought],  
  [BmeStatementData_EnergyTradedSold],  
  [BmeStatementData_ContractId],  
  [BmeStatementData_ContractType],  
  [BmeStatementData_Percentage],  
  [BmeStatementData_ContractedQuantity],  
  [BmeStatementData_CapQuantity],  
  [BmeStatementData_AncillaryServices],  
  [BmeStatementData_ContractType_Id],  
  [BmeStatementData_ContractSubType_Id],  
  [BmeStatementData_SellerPartyCategory_Code],  
  [BmeStatementData_BuyerPartyCategory_Code],  
  [BmeStatementData_CongestedZoneID],  
  BmeStatementData_CongestedZone,  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM   
  BmeStatementDataMpContractHourly  
 WHERE   
  BmeStatementData_Year = @p_settlementProcessYear  
  AND BmeStatementData_Month = @p_settlementProcessMonth  
  AND BmeStatementData_StatementProcessId=@p_settlementProcessId  
------ [dbo].[BmeStatementDataMpHourly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataMpHourly_SettlementProcess]  
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
  [BmeStatementData_ActualEnergy_Metered],
  [BmeStatementData_EnergySuppliedActual],  
  [BmeStatementData_EnergySuppliedGenerated],  
  [BmeStatementData_EnergySuppliedImport],  
  [BmeStatementData_PartyRegisteration_Id],  
  [BmeStatementData_PartyName],  
  [BmeStatementData_PartyType_Code],  
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
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT   
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
  [BmeStatementData_ActualEnergy_Metered], 
  [BmeStatementData_EnergySuppliedActual],  
  [BmeStatementData_EnergySuppliedGenerated],  
  [BmeStatementData_EnergySuppliedImport],  
  [BmeStatementData_PartyRegisteration_Id],  
  [BmeStatementData_PartyName],  
  [BmeStatementData_PartyType_Code],  
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
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM   
  [dbo].[BmeStatementDataMpHourly]  
 WHERE  
  BmeStatementData_Year = @p_settlementProcessYear  
  AND BmeStatementData_Month = @p_settlementProcessMonth  
  AND BmeStatementData_StatementProcessId=@p_settlementProcessId  
--------[dbo].[BmeStatementDataMpMonthly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataMpMonthly_SettlementProcess]  
 (  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_PartyRegisteration_Id],  
  [BmeStatementData_PartyName],  
  [BmeStatementData_PartyType_Code],  
  [BmeStatementData_ImbalanceCharges],  
  [BmeStatementData_SettlementOfLegacy],  
  [BmeStatementData_AmountPayableReceivable],  
  [BmeStatementData_EnergySuppliedActual],  
  [BmeStatementData_IsPowerPool],  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_PartyRegisteration_Id],  
  [BmeStatementData_PartyName],  
  [BmeStatementData_PartyType_Code],  
  [BmeStatementData_ImbalanceCharges],  
  [BmeStatementData_SettlementOfLegacy],  
  [BmeStatementData_AmountPayableReceivable],  
  [BmeStatementData_EnergySuppliedActual],  
  [BmeStatementData_IsPowerPool],  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM   
  BmeStatementDataMpMonthly  
 WHERE  
  BmeStatementData_Month = @p_settlementProcessMonth  
  AND  
  BmeStatementData_Year = @p_settlementProcessYear  
  AND BmeStatementData_StatementProcessId=@p_settlementProcessId  
------ [dbo].[BmeStatementDataTspHourly_SettlementProcess]  
 INSERT INTO [dbo].[BmeStatementDataTspHourly_SettlementProcess]  
 (  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_PartyRegisteration_Id],  
  [BmeStatementData_PartyName],  
  [BmeStatementData_PartyCategory_Code],  
  [BmeStatementData_PartyType_Code],  
  [BmeStatementData_AdjustedEnergyImport],  
  [BmeStatementData_AdjustedEnergyExport],  
  [BmeStatementData_TransmissionLosses],  
  [BmeStatementData_StatementProcessId],  
  [BmeStatementData_SettlementProcessId]  
 )  
 SELECT  
  [BmeStatementData_NtdcDateTime],  
  [BmeStatementData_Year],  
  [BmeStatementData_Month],  
  [BmeStatementData_Day],  
  [BmeStatementData_Hour],  
  [BmeStatementData_PartyRegisteration_Id],  
  [BmeStatementData_PartyName],  
  [BmeStatementData_PartyCategory_Code],  
  [BmeStatementData_PartyType_Code],  
  [BmeStatementData_AdjustedEnergyImport],  
  [BmeStatementData_AdjustedEnergyExport],  
  [BmeStatementData_TransmissionLosses],  
  [BmeStatementData_StatementProcessId],  
  @p_settlementProcessId  
 FROM   
  BmeStatementDataTspHourly  
 WHERE  
  BmeStatementData_Year = @p_settlementProcessYear  
  AND BmeStatementData_Month = @p_settlementProcessMonth  
  AND BmeStatementData_StatementProcessId=@p_settlementProcessId  

/**/
INSERT INTO [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess]
           ([BmeStatementData_NtdcDateTime]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_Day]
           ,[BmeStatementData_Hour]
           ,[BmeStatementData_MtGenerator_Id]
           ,[BmeStatementData_MtGeneratorUnit_Id]
           ,[BmeStatementData_SOUnitId]
           ,[SrTechnologyType_Code]
           ,[BmeStatementData_InstalledCapacity_KW]
           ,[BmeStatementData_IncEnergyExport]
           ,[BmeStatementData_IncEnergyImport]
           ,[BmeStatementData_AdjustedEnergyExport]
           ,[BmeStatementData_AdjustedEnergyImport]
           ,[BmeStatementData_GenerationUnitEnergy]
           ,[BmeStatementData_GenerationUnitWiseBackfeed]
           ,[BmeStatementData_GenerationUnitEnergy_Metered]
           ,[BmeStatementData_GenerationUnitWiseBackfeed_Metered]
           ,[BmeStatementData_AvailableCapacityASC]
           ,[BmeStatementData_CalculatedAvailableCapacityASC]
           ,[BmeStatementData_ActualCapacity]
           ,[BmeStatementData_GenCapacity]
           ,[BmeStatementData_UnitWiseGeneration]
           ,[BmeStatementData_UnitWiseGenerationBackFeed]
           ,[BmeStatementData_UnitWiseGeneration_Metered]
           ,[BmeStatementData_UnitWiseGenerationBackFeed_Metered]
           ,[BmeStatementData_IsBackfeedInclude]
           ,[BmeStatementData_StatementProcessId])
     
	  SELECT 
	        [BmeStatementData_NtdcDateTime]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_Day]
           ,[BmeStatementData_Hour]
           ,[BmeStatementData_MtGenerator_Id]
           ,[BmeStatementData_MtGeneratorUnit_Id]
           ,[BmeStatementData_SOUnitId]
           ,[SrTechnologyType_Code]
           ,[BmeStatementData_InstalledCapacity_KW]
           ,[BmeStatementData_IncEnergyExport]
           ,[BmeStatementData_IncEnergyImport]
           ,[BmeStatementData_AdjustedEnergyExport]
           ,[BmeStatementData_AdjustedEnergyImport]
           ,[BmeStatementData_GenerationUnitEnergy]
           ,[BmeStatementData_GenerationUnitWiseBackfeed]
           ,[BmeStatementData_GenerationUnitEnergy_Metered]
           ,[BmeStatementData_GenerationUnitWiseBackfeed_Metered]
           ,[BmeStatementData_AvailableCapacityASC]
           ,[BmeStatementData_CalculatedAvailableCapacityASC]
           ,[BmeStatementData_ActualCapacity]
           ,[BmeStatementData_GenCapacity]
           ,[BmeStatementData_UnitWiseGeneration]
           ,[BmeStatementData_UnitWiseGenerationBackFeed]
           ,[BmeStatementData_UnitWiseGeneration_Metered]
           ,[BmeStatementData_UnitWiseGenerationBackFeed_Metered]
           ,[BmeStatementData_IsBackfeedInclude]
           ,[BmeStatementData_StatementProcessId]
		FROM  [dbo].[BmeStatementDataGenUnitHourly]
		WHERE   BmeStatementData_Year = @p_settlementProcessYear  
     AND BmeStatementData_Month = @p_settlementProcessMonth  
    AND BmeStatementData_StatementProcessId=@p_settlementProcessId 


/**/  
UPDATE MtBvmReading  
SET IsAlreadyUsedInBME =1  
FROM MtBvmReading  
WHERE DATEPART(YEAR, MtBvmReading_ReadingDate) = @p_settlementProcessYear  
AND DATEPART(MONTH, MtBvmReading_ReadingDate) = @p_settlementProcessMonth  
   
  
return @@rowcount;  
END  

/****** Object:  Procedure [dbo].[SaveBMESettlementOutputs2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SaveBMESettlementOutputs2]

	@p_settlementProcessId decimal(18,0),
	@p_settlementProcessMonth int,
	@p_settlementProcessYear int		
as
begin

	--------1  BmeStatementDataCdpHourly_SettlementProcess  ----



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
	,[BmeStatementData_SettlementProcessId]
)
select 
	BSD.BmeStatementData_NtdcDateTime
	,BSD.BmeStatementData_Year
	,BSD.BmeStatementData_Month
	,BSD.BmeStatementData_Day
	,BSD.BmeStatementData_Hour
	,BSD.BmeStatementData_CdpId
	,BSD.BmeStatementData_MeterIdImport
	,BSD.BmeStatementData_IncEnergyImport
	,BSD.BmeStatementData_DataSourceImport
	,BSD.BmeStatementData_MeterIdExport
	,BSD.BmeStatementData_IncEnergyExport
	,BSD.BmeStatementData_DataSourceExport
	,BSD.BmeStatementData_CreatedBy
	,BSD.BmeStatementData_CreatedOn
	,BSD.BmeStatementData_ModifiedBy
	,BSD.BmeStatementData_ModifiedOn
	,BSD.BmeStatementData_LineVoltage
	,BSD.BmeStatementData_FromPartyRegisteration_Id
	,BSD.BmeStatementData_FromPartyRegisteration_Name
	,BSD.BmeStatementData_FromPartyCategory_Code
	,BSD.BmeStatementData_FromPartyType_Code
	,BSD.BmeStatementData_DistLosses_Factor
	,BSD.BmeStatementData_DistLosses_EffectiveFrom
	,BSD.BmeStatementData_DistLosses_EffectiveTo
	,BSD.BmeStatementData_ToPartyRegisteration_Id
	,BSD.BmeStatementData_ToPartyRegisteration_Name
	,BSD.BmeStatementData_ToPartyCategory_Code
	,BSD.BmeStatementData_ToPartyType_Code
	,BSD.BmeStatementData_AdjustedEnergy
	,BSD.BmeStatementData_TransmissionLosses
	,BSD.BmeStatementData_DemandedEnergy
	,BSD.BmeStatementData_AdjustedEnergyExport
	,BSD.BmeStatementData_AdjustedEnergyImport
	,BSD.BmeStatementData_ActualEnergy
	,BSD.BmeStatementData_EnergySuppliedGenerated
	,BSD.BmeStatementData_EnergySuppliedActual
	,BSD.BmeStatementData_IsEnergyImported
	,BSD.BmeStatementData_OwnerId
	,BSD.[BmeStatementData_ISARE]
	,BSD.[BmeStatementData_ISThermal]
	,BSD.[BmeStatementData_RuCDPDetail_Id]
	,BSD.[BmeStatementData_IsLegacy]
	,BSD.[BmeStatementData_EnergySuppliedImported]
	,@p_settlementProcessId
from 
	[dbo].[BmeStatementDataCdpHourly] BSD
where
	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear;


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
	,[BmeStatementData_SettlementProcessId]
)

select
	BSD.[BmeStatementData_NtdcDateTime]
	,BSD.[BmeStatementData_Year]
	,BSD.[BmeStatementData_Month]
	,BSD.[BmeStatementData_Day]
	,BSD.[BmeStatementData_Hour]
	,BSD.[BmeStatementData_TransmissionLosses]
	,BSD.[BmeStatementData_DemandedEnergy]
	,BSD.[BmeStatementData_UpliftTransmissionLosses]
	,BSD.[BmeStatementData_ActualCapacity]
	,BSD.[BmeStatementData_EnergySuppliedGenerated]
	,BSD.[BmeStatementData_EnergySuppliedImported]
	,BSD.[BmeStatementData_EnergySuppliedGeneratedLegacy]
	,BSD.[BmeStatementData_EnergySuppliedImportedLegacy]
	,BSD.[BmeStatementData_CAPLegacy]
	,@p_settlementProcessId
from 
	[dbo].[BmeStatementDataHourly] BSD
where
	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear


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
	,[BmeStatementData_SettlementProcessId]
)

select
	BSD.[BmeStatementData_NtdcDateTime]
	,BSD.[BmeStatementData_Year]
	,BSD.[BmeStatementData_Month]
	,BSD.[BmeStatementData_Day]
	,BSD.[BmeStatementData_Hour]
	,BSD.[BmeStatementData_PartyRegisteration_Id]
	,BSD.[BmeStatementData_PartyName]
	,BSD.[BmeStatementData_PartyCategory_Code]
	,BSD.[BmeStatementData_PartyType_Code]
	,BSD.[BmeStatementData_AdjustedEnergyImport]
	,BSD.[BmeStatementData_AdjustedEnergyExport]
	,BSD.[BmeStatementData_TransmissionLosses]
	,@p_settlementProcessId
from
	[dbo].[BmeStatementDataTspHourly] BSD
where
	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear


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
	,[BmeStatementData_SettlementProcessId]
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
	,@p_settlementProcessId
from
	[dbo].[BmeStatementDataMpHourly]
where 
	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear

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
	,[BmeStatementData_SettlementProcessId]
)

select
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
	,@p_settlementProcessId
from
	[dbo].[BmeStatementDataCdpContractHourly]
where 
	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear;

-------5 end---------


-----------6 [dbo].[BmeStatementDataMpMonthly_SettlementProcess]

insert into [dbo].[BmeStatementDataMpMonthly_SettlementProcess]
(
	[BmeStatementData_Year]
	,[BmeStatementData_Month]
	,[BmeStatementData_PartyRegisteration_Id]
	,[BmeStatementData_PartyName]
	--,[BmeStatementData_PartyCategory_Code]
	,[BmeStatementData_PartyType_Code]
	,[BmeStatementData_ImbalanceCharges]
	,[BmeStatementData_SettlementOfLegacy]
	,[BmeStatementData_AmountPayableReceivable]
	,[BmeStatementData_SettlementProcessId]
)
select
	[BmeStatementData_Year]
	,[BmeStatementData_Month]
	,[BmeStatementData_PartyRegisteration_Id]
	,[BmeStatementData_PartyName]
--	,[BmeStatementData_PartyCategory_Code]
	,[BmeStatementData_PartyType_Code]
	,[BmeStatementData_ImbalanceCharges]
	,[BmeStatementData_SettlementOfLegacy]
	,[BmeStatementData_AmountPayableReceivable]
	,@p_settlementProcessId
from 
	[dbo].[BmeStatementDataMpMonthly]
where 
	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear

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
	,@p_settlementProcessId
from [dbo].[BMEContractedAmounts]
	
--------- 7 end----------------

--------- 7 [dbo].[BMEContractedAmounts_SettlementProcess] ----

INSERT INTO [dbo].[BmeStatementDataMpContractHourly_SettlementProcess]
           ([BmeStatementData_NtdcDateTime]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_Day]
           ,[BmeStatementData_Hour]
           ,[BmeStatementData_SellerPartyRegisteration_Id]
           ,[BmeStatementData_SellerPartyRegisteration_Name]
           ,[BmeStatementData_SellerPartyType_Code]
           ,[BmeStatementData_BuyerPartyRegisteration_Id]
           ,[BmeStatementData_BuyerPartyRegisteration_Name]
           ,[BmeStatementData_BuyerPartyType_Code]
           ,[BmeStatementData_EnergyTradedBought]
           ,[BmeStatementData_EnergyTradedSold]
           ,[BmeStatementData_ContractId]
           ,[BmeStatementData_ContractType]
           ,[BmeStatementData_Percentage]
           ,[BmeStatementData_ContractedQuantity]
           ,[BmeStatementData_CapQuantity]
           ,[BmeStatementData_AncillaryServices]
           ,[BmeStatementData_ContractType_Id]
           ,[BmeStatementData_ContractSubType_Id]
           ,[BmeStatementData_SettlementProcessId])
select [BmeStatementData_NtdcDateTime]
           ,[BmeStatementData_Year]
           ,[BmeStatementData_Month]
           ,[BmeStatementData_Day]
           ,[BmeStatementData_Hour]
           ,[BmeStatementData_SellerPartyRegisteration_Id]
           ,[BmeStatementData_SellerPartyRegisteration_Name]
           ,[BmeStatementData_SellerPartyType_Code]
           ,[BmeStatementData_BuyerPartyRegisteration_Id]
           ,[BmeStatementData_BuyerPartyRegisteration_Name]
           ,[BmeStatementData_BuyerPartyType_Code]
           ,[BmeStatementData_EnergyTradedBought]
           ,[BmeStatementData_EnergyTradedSold]
           ,[BmeStatementData_ContractId]
           ,[BmeStatementData_ContractType]
           ,[BmeStatementData_Percentage]
           ,[BmeStatementData_ContractedQuantity]
           ,[BmeStatementData_CapQuantity]
           ,[BmeStatementData_AncillaryServices]
           ,[BmeStatementData_ContractType_Id]
           ,[BmeStatementData_ContractSubType_Id]
		,@p_settlementProcessId
from [dbo].[BmeStatementDataMpContractHourly]
where 	[BmeStatementData_Month] = @p_settlementProcessMonth
	and [BmeStatementData_Year] = @p_settlementProcessYear;
	
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
	,[BmeStatementData_SettlementProcessId]
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
	,@p_settlementProcessId
from 
	[dbo].[BmeStatementDataCdpOwnerParty]

----- 8 end-----------



UPDATE MtBvmReading
SET IsAlreadyUsedInBME =1
FROM MtBvmReading
WHERE DATEPART(YEAR, MtBvmReading_ReadingDate) = @p_settlementProcessYear
AND DATEPART(MONTH, MtBvmReading_ReadingDate) = @p_settlementProcessMonth
	

return @@rowcount;
	end

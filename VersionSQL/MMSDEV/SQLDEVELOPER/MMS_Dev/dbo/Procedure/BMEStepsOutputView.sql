/****** Object:  Procedure [dbo].[BMEStepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

-- dbo.BMEStepsOutputView 25,8  
-- dbo.BMEStepsOutputView 3,2.  
-- dbo.BMEStepsOutputView 66,4  
CREATE   PROCEDURE dbo.BMEStepsOutputView
    @pSettlementProcessId int,
    @pStepId decimal(4, 1)
AS
BEGIN

    DECLARE @vSrProcessDef_ID DECIMAL(18, 0);
SELECT
	@vSrProcessDef_ID = SrProcessDef_ID
FROM MtStatementProcess
WHERE MtStatementProcess_ID = @pSettlementProcessId
AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

--**************  
IF (@pStepId = 1)
BEGIN
SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_Id) AS [Sr]
   ,BmeStatementData_Month AS [Month]
   ,BmeStatementData_Day AS [Day]
   ,BmeStatementData_Hour - 1 AS [Hour]
   ,BmeStatementData_CdpId AS [CDP-ID]
   ,BmeStatementData_FromPartyRegisteration_Name AS [Connected From]
   ,BmeStatementData_ToPartyRegisteration_Name AS [Connected To]
   ,BmeStatementData_FromPartyRegisteration_Id AS [Connected From Id]
   ,BmeStatementData_ToPartyRegisteration_Id AS [Connected To Id]
   ,BmeStatementData_LineVoltage AS [Line Voltage (kV)]
   ,BmeStatementData_IncEnergyImport AS [Energy Import (kWh)]
   ,BmeStatementData_IncEnergyExport AS [Energy Export (kWh)]
FROM BmeStatementDataCdpHourly_SettlementProcess
WHERE --BmeStatementData_Year=2021 and BmeStatementData_Month=11 and   
BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY BmeStatementData_Month,
BmeStatementData_Day,
BmeStatementData_Hour,
BmeStatementData_CdpId;
END


--------------------------------------------------------------  
ELSE
IF (@pStepId = 2)
BEGIN
-----------  2.1  
DECLARE @month AS INT
	   ,@year AS INT;

SELECT
	@month = LuAccountingMonth_Month
   ,@year = LuAccountingMonth_Year
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = (SELECT
		LuAccountingMonth_Id_Current
	FROM MtStatementProcess
	WHERE MtStatementProcess_ID = @pSettlementProcessId)

DECLARE @MONTH_EFFECTIVE_FROM AS DATETIME = DATEFROMPARTS(@year, @month, 1)
DECLARE @MONTH_EFFECTIVE_TO AS DATETIME = EOMONTH(@MONTH_EFFECTIVE_FROM)

/***********************
Previous Code*****************************/
SELECT
	ROW_NUMBER() OVER (ORDER BY Lu_DistLosses_Id) AS [Sr]
   ,Lu_DistLosses_MP_Name AS [Entity Name]
   ,MtPartyRegisteration_Id AS [Entity Id]
   ,Lu_DistLosses_LineVoltage AS [Line Voltage (kV)]
   ,Lu_DistLosses_Factor AS [Factor (%)]
FROM Lu_DistLosses
WHERE (@MONTH_EFFECTIVE_FROM >= Lu_DistLosses_EffectiveFrom
OR Lu_DistLosses_EffectiveFrom BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO)

AND ISNULL(Lu_DistLosses_EffectiveTo, @MONTH_EFFECTIVE_TO) >= @MONTH_EFFECTIVE_TO
ORDER BY MtPartyRegisteration_Id


/***********************
NEw Code******************************/

/*DROP TABLE IF EXISTS #tempDistLosses
DROP TABLE IF EXISTS #tempDistLossSum

select Lu_LineVoltage_Name
,DL.Lu_DistLosses_LineVoltage
,Lu_LineVoltage_Level
,Lu_DistLosses_Factor
,MtPartyRegisteration_Id
,Lu_DistLosses_EffectiveFrom
,Lu_DistLosses_EffectiveTo
into #tempDistLosses
from Lu_DistLosses DL join Lu_LineVoltage LV
on cast(LV.Lu_LineVoltage_Name as VARCHAR(20))=cast(DL.Lu_DistLosses_LineVoltage as VARCHAR(20))
WHERE   (	@MONTH_EFFECTIVE_FROM >= DL.Lu_DistLosses_EffectiveFrom
  OR  DL.Lu_DistLosses_EffectiveFrom  BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO  )

	  and ISNULL(DL.Lu_DistLosses_EffectiveTo,@MONTH_EFFECTIVE_TO)>=@MONTH_EFFECTIVE_TO;
	   
 select 
	ROW_NUMBER() OVER (ORDER BY MtPartyRegisteration_Id,t1.Lu_LineVoltage_Level) AS [Sr]
,t1.MtPartyRegisteration_Id
,t1.Lu_DistLosses_LineVoltage
,Lu_DistLosses_EffectiveFrom
,Lu_DistLosses_EffectiveTo
,(select sum(t2.Lu_DistLosses_Factor) from #tempDistLosses t2 where t2.MtPartyRegisteration_Id=t1.MtPartyRegisteration_Id and t2.Lu_LineVoltage_Level>=t1.Lu_LineVoltage_Level) as Lu_DistLosses_Factor
--into #tempDistLossSum
from #tempDistLosses t1
ORDER BY MtPartyRegisteration_Id
*/
/***********************/

---------- 2.2  
SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_Id) AS [Sr]
   ,BmeStatementData_Month AS [Month]
   ,BmeStatementData_Day AS [Day]
   ,BmeStatementData_Hour - 1 AS [Hour]
   ,BmeStatementData_CdpId AS [CDP-ID]
   ,BmeStatementData_FromPartyRegisteration_Name AS [Connected From]
   ,BmeStatementData_ToPartyRegisteration_Name AS [Connected To]
   ,BmeStatementData_FromPartyRegisteration_Id AS [Connected From Id]
   ,BmeStatementData_ToPartyRegisteration_Id AS [Connected To Id]
   ,BmeStatementData_LineVoltage AS [Line Voltage (kV)]
   ,BmeStatementData_DistLosses_Factor as [Distribution Loss Factor]
   ,BmeStatementData_IncEnergyImport AS [Energy Import (kWh)]
   ,BmeStatementData_IncEnergyExport AS [Energy Export (kWh)]
   ,BmeStatementData_AdjustedEnergyImport AS [Adjusted Energy Import (kWh)]
   ,BmeStatementData_AdjustedEnergyExport AS [Adjusted Energy Export (kWh)]
FROM BmeStatementDataCdpHourly_SettlementProcess
WHERE BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY BmeStatementData_Month,
BmeStatementData_Day,
BmeStatementData_Hour,
BmeStatementData_CdpId;
END
--------------------------------------------------------------  
ELSE
IF (@pStepId = 3)
BEGIN

--------------- 3.1  
--select ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  BmeStatementData_Month as [Month],   
--BmeStatementData_Day as [Day],   
--BmeStatementData_Hour-1 as [Hour] ,  
--BmeStatementData_PartyRegisteration_Id as [TSP-ID],  
--BmeStatementData_PartyName  as [TSP-Name],  
--BmeStatementData_AdjustedEnergyImport as [Adjusted Energy Import (kWh)],  
--BmeStatementData_AdjustedEnergyExport as [Adjusted Energy Export (kWh)],  
--BmeStatementData_TransmissionLosses as [Transmission Loss (MWh)]  

--from BmeStatementDataTspHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  

SELECT
	ROW_NUMBER() OVER (ORDER BY tspHourly.BmeStatementData_Id) AS [Sr]
   ,tspHourly.BmeStatementData_Month AS [Month]
   ,tspHourly.BmeStatementData_Day AS [Day]
   ,tspHourly.BmeStatementData_Hour - 1 AS [Hour]
   ,tspHourly.BmeStatementData_PartyRegisteration_Id AS [TSP-ID]
   ,tspHourly.BmeStatementData_PartyName AS [TSP-Name]
   ,tspHourly.BmeStatementData_AdjustedEnergyImport AS [Adjusted Energy Import (kWh)]
   ,tspHourly.BmeStatementData_AdjustedEnergyExport AS [Adjusted Energy Export (kWh)]
   ,tspHourly.BmeStatementData_TransmissionLosses AS [Transmission Loss (kWh)]
--dataHourly.BmeStatementData_DemandedEnergy AS [Total Demand (kWh)],
--dataHourly.BmeStatementData_UpliftTransmissionLosses AS [Uplift Transmission Loss]
FROM BmeStatementDataTspHourly_SettlementProcess tspHourly
--LEFT JOIN BmeStatementDataHourly_SettlementProcess dataHourly
--    ON (
--           dataHourly.BmeStatementData_StatementProcessId = dataHourly.BmeStatementData_StatementProcessId
--           AND dataHourly.BmeStatementData_Year = tspHourly.BmeStatementData_Year
--           AND dataHourly.BmeStatementData_Month = tspHourly.BmeStatementData_Month
--           AND dataHourly.BmeStatementData_Day = tspHourly.BmeStatementData_Day
--       )
WHERE tspHourly.BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY tspHourly.BmeStatementData_Month,
tspHourly.BmeStatementData_Day,
tspHourly.BmeStatementData_Hour,
tspHourly.BmeStatementData_PartyRegisteration_Id;

--------------- 3.2   

SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_Id) AS [Sr]
   ,BmeStatementData_Month AS [Month]
   ,BmeStatementData_Day AS [Day]
   ,BmeStatementData_Hour - 1 AS [Hour]
   ,BmeStatementData_TransmissionLosses AS [Transmission Loss (kWh)]
   ,BmeStatementData_DemandedEnergy AS [Total Demand (kWh)]
   ,BmeStatementData_UpliftTransmissionLosses AS [Uplift Transmission Loss]
FROM BmeStatementDataHourly_SettlementProcess
WHERE BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY BmeStatementData_Month,
BmeStatementData_Day,
BmeStatementData_Hour;

--select ROW_NUMBER() OVER(Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour) as [Sr],    
--BmeStatementData_Month as [Month],   
--BmeStatementData_Day as [Day],   
--BmeStatementData_Hour as [Hour] ,  
--Sum(BmeStatementData_AdjustedEnergyImport) as [Adjusted Energy Import (kWh)],  
--Sum(BmeStatementData_AdjustedEnergyExport) as [Adjusted Energy Export (kWh)],  
--Sum(BmeStatementData_TransmissionLosses) as [Transmission Loss (MWh)]  

--from BmeStatementDataTspHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Group by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour;  


--select ROW_NUMBER() OVER(Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour) as [Sr],    
--BmeStatementData_Month as [Month],   
--BmeStatementData_Day as [Day],   
--BmeStatementData_Hour -1 as [Hour] ,  
--Sum(BmeStatementData_TransmissionLosses) as [Transmission Loss (MWh)]  

--from BmeStatementDataHourly where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Group by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour;  


--------------- 3.3   
--select  ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],   
--BmeStatementData_Day as [Day],   
--BmeStatementData_Hour -1 as [Hour],   
--BmeStatementData_DemandedEnergy as [Total Demand (MWh)]   
--from BmeStatementDataHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour;  

END
--------------------------------------------------------------  
ELSE
IF (@pStepId = 4)
BEGIN
--select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
--       BmeStatementData_Month as [Month],
--       BmeStatementData_Day as [Day],
--       BmeStatementData_Hour - 1 as [Hour]
--       --BmeStatementData_TransmissionLosses as [Transmission Loss (kWh)],
--       --BmeStatementData_DemandedEnergy as [Total Demand (kWh)],
--       --BmeStatementData_UpliftTransmissionLosses as [Uplift Transmission Loss]
--from BmeStatementDataHourly_SettlementProcess
--where BmeStatementData_StatementProcessId = @pSettlementProcessId
--Order by BmeStatementData_Month,
--         BmeStatementData_Day,
--         BmeStatementData_Hour;

EXEC [dbo].[BME_GenerationEnergyInfo] @pSettlementProcessId;
---4.3 for Generator and Generation Unit wise energy with availabilities  

--  EXEC BME_GenerationEnergyAndAvailabilityOutputs @pSettlementProcessId
END
--------------------------------------------------------------  
--ELSE if(@pStepId=5)  
--BEGIN  
--select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)]  
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  

--END  
--------------------------------------------------------------  
--ELSE if(@pStepId=6)  
--BEGIN  
--------------- 6.1  
--select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],  
--BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)]  
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  

--------------- 6.2  
--select  ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],  
--BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A (kWh)],  
--BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)]  
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  

--------------- 6.3  
--select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],  
--BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)],  
--BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)],  
--BmeStatementData_EnergySuppliedImported as [Hourly Imported (ES_I) (kWh)]   
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  

--END  
----------------------------------------------------------------  
--ELSE if(@pStepId=7)  
--BEGIN  
------------ 7.1  
--select  ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_ContractId as [Contract ID],   
--Convert(date, BmeStatementData_NtdcDateTime) as [Date],   
--BmeStatementData_Hour -1 as [Hour], BmeStatementData_SellerPartyRegisteration_Name as [Seller Name], BmeStatementData_BuyerPartyRegisteration_Name as [Buyer Name], BmeStatementData_SellerPartyRegisteration_Id as [Seller Id], BmeStatementData_BuyerPartyRegisteration_Id as [Buyer Id],  
--BmeStatementData_ContractType as [Contract Type],   
--BmeStatementData_CdpId as [Relevant CDPs],   
--BmeStatementData_Percentage as [Percentage], BmeStatementData_ContractedQuantity as [Contracted Quantity (kWh)], BmeStatementData_CapQuantity as [Contract Cap], BmeStatementData_AncillaryServices as [Ancillary Services]  
--  from BmeStatementDataCdpContractHourly_SettlementProcess  
--  where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_ContractId, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_CdpId;  

--  -------------  7.2  
--  Drop table if EXISTS #temp7_2;  
--select Distinct   
-- BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_CAPLegacy as [CAP]  
--into #temp7_2  
--from BmeStatementDataHourly_SettlementProcess   
--where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, [HOUR]; -- updated Ammama  


--select ROW_NUMBER() OVER(Order by Month, Day, Hour) as [Sr],* from #temp7_2  

----------------- 7.3  
--select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],  
--BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)],  
--BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)],  
--BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I) (kWh)] ,  
--BmeStatementData_EnergyTradedBought as [ET_Bought (kWh)],  
--BmeStatementData_EnergyTradedSold as [ET_Sold (kWh)],  
--BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)]  
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  



----------------- 7.4  
--SELECT  
--BmeStatementData_NtdcDateTime AS [DATE TIME]  
--,BmeStatementData_PartyRegisteration_Id [Party Id]  
--,BmeStatementData_PartyName [Party Name]  
--,BmeStatementData_CAPLegacy [CAP]  

--FROM   
--BmeStatementDataMpHourly_SettlementProcess   
--WHERE BmeStatementData_StatementProcessId=@pSettlementProcessId  
--AND BmeStatementData_PartyRegisteration_Id <>1  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  
--END  
--------------------------------------------------------------  
ELSE
IF (@pStepId = 8)
BEGIN
--------------- 8.1  
--select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],  
--BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)],  
--BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)],  
--BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I) (kWh)] ,  
--BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)],   
--BmeStatementData_Imbalance as [Energy Imbalance (kWh)]  
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  


--------------- 8.2  
--select   ROW_NUMBER() OVER(Order by BmeStatementData_Id) as [Sr],  
--BmeStatementData_Month as [Month],  
--BmeStatementData_Day as [Day],  
--BmeStatementData_Hour -1 as [Hour],  
--BmeStatementData_PartyName as [MP Name],  
--BmeStatementData_PartyRegisteration_Id as [MP ID],  
--BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],  
--BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],  
--BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A (kWh)],  
--BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G)],  
--BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I (kWh))] ,  
--BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)],   
--BmeStatementData_Imbalance as [Energy Imbalance (kWh)],  
--BmeStatementData_MarginalPrice as [Marginal Price (PKR)]  
--from BmeStatementDataMpHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId  
--Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour, BmeStatementData_PartyRegisteration_Id;  

--------------- 8.3  


SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_Month,
	BmeStatementData_PartyRegisteration_Id,
	BmeStatementData_Day,
	BmeStatementData_Hour
	) AS [Sr]
   ,BmeStatementData_Month AS [Month]
   ,BmeStatementData_Day AS [Day]
   ,BmeStatementData_Hour - 1 AS [Hour]
   ,BmeStatementData_PartyName AS [MP Name]
   ,BmeStatementData_PartyRegisteration_Id AS [MP ID]
   ,BmeStatementData_ActualEnergy_Metered AS [Energy Withdrawal- Metered (EMP) (kWh)]
   ,BmeStatementData_ActualEnergy AS [Energy Withdrawal- Adjusted for Distribution Losses (Act_E) (kWh)]
   ,BmeStatementData_EnergySuppliedActual AS [Hourly  Energy Supplied (ES_A (kWh)]
   ,BmeStatementData_EnergySuppliedGenerated AS [Hourly  Generation (ES_G)]
   ,BmeStatementData_EnergySuppliedImported AS [Hourly Imported Energy (ES_I (kWh))]
   ,BmeStatementData_CAPLegacy AS [CAP]
   ,BmeStatementData_EnergyTradedBought AS [ET_Bought (kWh)]
   ,BmeStatementData_EnergyTradedSold AS [ET_Sold (kWh)]
   ,BmeStatementData_EnergyTraded AS [Hourly Contracted Energy (ET) (kWh)]
   ,BmeStatementData_Imbalance AS [Energy Imbalance (kWh)]
   ,BmeStatementData_MarginalPrice AS [Marginal Price]
   ,BmeStatementData_ImbalanceCharges AS [Imbalance Charges (PKR)]
FROM BmeStatementDataMpHourly_SettlementProcess
WHERE BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY BmeStatementData_Month,
BmeStatementData_PartyRegisteration_Id,
BmeStatementData_Day,
BmeStatementData_Hour;

END
--------------------------------------------------------------  
ELSE
IF (@pStepId = 9)
BEGIN
----------- 9.1  
SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_Year, 
BmeStatementData_Month, 
BmeStatementData_Day, 
BmeStatementData_Hour,
BmeStatementData_PartyRegisteration_Id) AS [Sr]
   ,BmeStatementData_PartyName AS [MP Name]
   ,BmeStatementData_PartyRegisteration_Id AS [MP ID]
   ,BmeStatementData_Year AS [Year]
   ,BmeStatementData_Month AS [Month]
   ,BmeStatementData_Day AS [Day]
   ,BmeStatementData_Hour-1 AS [Hour]
   ,BmeStatementData_BSUPRatioPP AS [Settlement of Legacy (PKR)]
FROM BmeStatementDataMpHourly_SettlementProcess
WHERE BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY SR, 
BmeStatementData_Year, 
BmeStatementData_Month, 
BmeStatementData_Day, 
BmeStatementData_Hour,
BmeStatementData_PartyRegisteration_Id;

----------- 9.2  
SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_PartyRegisteration_Id) AS [Sr]
   ,BmeStatementData_Month AS [Month]
   ,BmeStatementData_PartyName AS [MP Name]
   ,BmeStatementData_PartyRegisteration_Id AS [MP ID]
   ,BmeStatementData_SettlementOfLegacy AS [Settlement of Legacy (PKR)]
FROM BmeStatementDataMpMonthly_SettlementProcess
WHERE BmeStatementData_StatementProcessId = @pSettlementProcessId
ORDER BY BmeStatementData_PartyRegisteration_Id;


END
--------------------------------------------------------------  
ELSE
IF (@pStepId = 10)
BEGIN
-----------------10.1  


DROP TABLE IF EXISTS #tempStep10
SELECT
	ROW_NUMBER() OVER (ORDER BY BmeStatementData_Id) AS [Sr]
   ,MPM.BmeStatementData_Month AS [Month]
   ,MPM.BmeStatementData_PartyName AS [MP Name]
   ,MPM.BmeStatementData_PartyRegisteration_Id AS [MP ID]
   ,(SELECT
			SUM(MPH.BmeStatementData_ActualEnergy_Metered)
		FROM BmeStatementDataMpHourly_SettlementProcess MPH
		WHERE MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
		AND MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
		AND MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
		GROUP BY MPH.BmeStatementData_PartyRegisteration_Id
				,MPH.BmeStatementData_Month)
	AS [Actual Energy (kW)]
   ,(SELECT
			SUM(MPH.BmeStatementData_ActualEnergy)
		FROM BmeStatementDataMpHourly_SettlementProcess MPH
		WHERE MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
		AND MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
		AND MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
		GROUP BY MPH.BmeStatementData_PartyRegisteration_Id
				,MPH.BmeStatementData_Month)
	AS [Adjusted Energy (kW)]
   ,(SELECT
			SUM(MPH.BmeStatementData_EnergySuppliedActual)
		FROM BmeStatementDataMpHourly_SettlementProcess MPH
		WHERE MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
		AND MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
		AND MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
		GROUP BY MPH.BmeStatementData_PartyRegisteration_Id
				,MPH.BmeStatementData_Month)
	AS [Energy Supplied (kW)]
   ,MPM.BmeStatementData_SettlementOfLegacy AS [Settlement of Legacy (PKR)]
   ,MPM.BmeStatementData_ImbalanceCharges AS [Imbalance Charges (PKR)]
   ,MPM.BmeStatementData_AmountPayableReceivable AS [Amount Payable / Amount Receivable (PKR)] INTO #tempStep10
FROM BmeStatementDataMpMonthly_SettlementProcess MPM
WHERE MPM.BmeStatementData_StatementProcessId = @pSettlementProcessId
--and MPM.BmeStatementData_PartyRegisteration_Id<>1115  
ORDER BY BmeStatementData_PartyRegisteration_Id;


INSERT INTO #tempStep10 ([month],
[MP Name],
[Amount Payable / Amount Receivable (PKR)],
[Imbalance Charges (PKR)])
	VALUES ('', 'Total', (SELECT SUM([Amount Payable / Amount Receivable (PKR)]) FROM #tempStep10), (SELECT SUM([Imbalance Charges (PKR)]) FROM #tempStep10))

SELECT
	[SR]
   ,CASE
		WHEN [Month] = 0 THEN NULL
		ELSE [Month]
	END AS [Month]
   ,[MP Name] AS [Party Name]
   ,[MP ID] AS [Party ID]
   ,[Actual Energy (kW)] AS [Energy Withdrawal - Metered (EMP) (kWh)]
   ,[Adjusted Energy (kW)] AS [Energy withdrawal - Adjusted for Distribution Losses (Act_E) (kWh)]
   ,[Energy Supplied (kW)] AS [Energy withdrawal - Adjusted for Transmission Losses (ES) (kWh)]
   ,[Imbalance Charges (PKR)]
   ,[Settlement of Legacy (PKR)]
   ,[Amount Payable / Amount Receivable (PKR)]
FROM #tempStep10
ORDER BY CASE
	WHEN [SR] IS NULL THEN 1
	ELSE 0
END,
[SR]

END
ELSE
IF (@pStepId = 11
	AND @vSrProcessDef_ID = 7)
BEGIN

DECLARE @vPredecessorId AS DECIMAL(18, 0)

SELECT
	@vPredecessorId = [dbo].[GetESSAdjustmentPredecessorStatementId](@pSettlementProcessId);

SELECT
	ROW_NUMBER() OVER (ORDER BY MPM.BmeStatementData_Id) AS [Sr]
   ,MPM.BmeStatementData_Month AS [Month]
   ,MPM.BmeStatementData_PartyName AS [MP Name]
   ,MPM.BmeStatementData_PartyRegisteration_Id AS [MP ID]
   ,(SELECT
			SUM(MPH.BmeStatementData_ActualEnergy)
		FROM BmeStatementDataMpHourly_SettlementProcess MPH
		WHERE MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
		AND MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
		AND MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
		GROUP BY MPH.BmeStatementData_PartyRegisteration_Id
				,MPH.BmeStatementData_Month)
	AS [Actual Energy]
   ,(SELECT
			SUM(MPH.BmeStatementData_ActualEnergy_Metered)
		FROM BmeStatementDataMpHourly_SettlementProcess MPH
		WHERE MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
		AND MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
		AND MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
		GROUP BY MPH.BmeStatementData_PartyRegisteration_Id
				,MPH.BmeStatementData_Month)
	AS [Inc Actual Energy]
   ,MPM.BmeStatementData_SettlementOfLegacy AS [Settlement of Legacy (PKR)]
   ,MPM.BmeStatementData_ImbalanceCharges AS [Imbalance Charges (PKR)]
   ,MPM_Previous.BmeStatementData_AmountPayableReceivable AS [Previous Month Amount Payable / Amount Receivable (PKR)]
   ,MPM.BmeStatementData_AmountPayableReceivable AS [Amount Payable / Amount Receivable (PKR)]
   ,MPM.BmeStatementData_ESSAdjustment AS [ESS Adjustment (PKR)] INTO #tempStep11
FROM BmeStatementDataMpMonthly_SettlementProcess MPM
JOIN BmeStatementDataMpMonthly_SettlementProcess MPM_Previous
	ON MPM.BmeStatementData_PartyRegisteration_Id = MPM_Previous.BmeStatementData_PartyRegisteration_Id
WHERE MPM.BmeStatementData_StatementProcessId = @pSettlementProcessId
AND MPM_Previous.BmeStatementData_StatementProcessId = @vPredecessorId
--and MPM.BmeStatementData_PartyRegisteration_Id<>1115  
ORDER BY MPM.BmeStatementData_PartyRegisteration_Id;

INSERT INTO #tempStep11 ([MP Name],
[Month],
[Previous Month Amount Payable / Amount Receivable (PKR)],
[Amount Payable / Amount Receivable (PKR)],
[ESS Adjustment (PKR)],
[Imbalance Charges (PKR)])
	VALUES ('Total', '', (SELECT SUM([Previous Month Amount Payable / Amount Receivable (PKR)]) FROM #tempStep11), (SELECT SUM([Amount Payable / Amount Receivable (PKR)]) FROM #tempStep11), (SELECT SUM([ESS Adjustment (PKR)]) FROM #tempStep11), (SELECT SUM([Imbalance Charges (PKR)]) FROM #tempStep11))

DECLARE @vPredecessorMonthName AS NVARCHAR(MAX);
SELECT
	@vPredecessorMonthName = [dbo].[GetMonthNameFromMtStatementProcessId](@vPredecessorId)

DECLARE @query NVARCHAR(MAX);

SET @query
= 'select  
 [Sr] ,case WHEN [Month]=0 THEN NULL else [Month] end as [Month] ,[MP Name] ,[MP ID], [Actual Energy] as [Actual Energy (kW)],[Settlement of Legacy (PKR)],[Imbalance Charges (PKR)],[Amount Payable / Amount Receivable (PKR)] ,[Previous Month Amount Payable / Amount Receivable (PKR)] as [' + @vPredecessorMonthName
+ '], [ESS Adjustment (PKR)] from #tempStep11 order by case when [Sr] is null then 1 else 0 end, [Sr]  
'
       ;
EXEC (@query);
END
ELSE
IF (
	(
	@pStepId = 11
	AND @vSrProcessDef_ID IN (1, 4)
	)
	OR (
	@pStepId = 12
	AND @vSrProcessDef_ID = 7
	)
	)
BEGIN
EXECUTE BME_PostValidationReport @pSettlementProcessId

END
END

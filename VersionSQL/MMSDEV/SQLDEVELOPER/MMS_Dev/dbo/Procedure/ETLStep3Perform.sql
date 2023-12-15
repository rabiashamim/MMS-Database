/****** Object:  Procedure [dbo].[ETLStep3Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Sadaf Malik
-- CREATE date: 13 Jan 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
 --[dbo].[ETLStep1Perform] 34
/*****   25-NTDC	26-Pak Mitiari
Select * FROM [dbo].[EtlTspHourly] 
Select * FROM [dbo].[EtlHourly]
Select * from [dbo].[EtlTspData]
Select * from [dbo].[EtlMpData]
******/
CREATE   PROCEDURE dbo.ETLStep3Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

DECLARE @luaccountingMonth AS INT ;

select
	@luaccountingMonth = LuAccountingMonth_Id_Current 
from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId

DECLARE @FromDate AS DATETIME;
DECLARE @ToDate AS DATETIME;

DROP TABLE IF EXISTS #StatementIDs

/*==========================================================================================
		Get From date and To Date of Financial Year
		==========================================================================================*/
SELECT
	@FromDate = LuAccountingMonth_FromDate
   ,@ToDate = LuAccountingMonth_ToDate
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @luaccountingMonth
/*==========================================================================================
		Fetch All statement process Id of the BME year.  ESS/FSS only
		==========================================================================================*/

SELECT
	MAX(MtStatementProcess_ID) AS StatementIDs INTO #StatementIDs
FROM MtStatementProcess SP
INNER JOIN LuAccountingMonth AM
	ON SP.LuAccountingMonth_Id_Current = AM.LuAccountingMonth_Id
WHERE DATEFROMPARTS(AM.LuAccountingMonth_Year, AM.LuAccountingMonth_Month, 1) BETWEEN @FromDate AND @ToDate
AND ISNULL(SP.MtStatementProcess_IsDeleted, 0) = 0
AND ISNULL(AM.LuAccountingMonth_IsDeleted, 0) = 0
AND SP.SrProcessDef_ID IN (4, 7)
GROUP BY LuAccountingMonth_Id_Current



/*==========================================================================================
		Step 4: Get Actual Energy
		==========================================================================================*/

IF NOT EXISTS (SELECT TOP 1
			1
		FROM [dbo].[EtlMpData]
		WHERE MtStatementProcess_ID = @pStatementProcessId)
BEGIN


INSERT INTO [dbo].[EtlMpData] ([MtStatementProcess_ID]
, [MTPartyRegisteration_Id]
, [EtlMpData_ActualEnergy]
, EtlMpData_ContractedEnergy)

	SELECT
		@pStatementProcessId
	   ,MPH.BmeStatementData_PartyRegisteration_Id
	   ,SUM(MPH.BmeStatementData_ActualEnergy) / 1000
	   ,CASE
			WHEN BmeStatementData_PartyRegisteration_Id = 1 THEN 0
			ELSE SUM(MPH.BmeStatementData_EnergyTraded) / 1000
		END	--Get contracted Energy of all MPs except legacy generator

	FROM BmeStatementDataMpHourly_SettlementProcess MPH
	WHERE BmeStatementData_StatementProcessId IN (SELECT
			StatementIDs
		FROM #StatementIDs)
	GROUP BY MPH.BmeStatementData_PartyRegisteration_Id

/******************
MP Monthly Actual Energy
*****************/

	INSERT INTO [dbo].[EtlMpMonthlyData] ([MtStatementProcess_ID]
, [MTPartyRegisteration_Id]
,[EtlMpMonthlyData_Month]
, [EtlMpMonthlyData_ActualEnergy]
 )

	SELECT
		@pStatementProcessId
	   ,MPH.BmeStatementData_PartyRegisteration_Id
	   ,MPH.BmeStatementData_Month
	   ,SUM(MPH.BmeStatementData_ActualEnergy) / 1000
	
	FROM BmeStatementDataMpHourly_SettlementProcess MPH
	WHERE BmeStatementData_StatementProcessId IN (SELECT
			StatementIDs
		FROM #StatementIDs)
	GROUP BY MPH.BmeStatementData_PartyRegisteration_Id,MPH.BmeStatementData_Month
	order by MPH.BmeStatementData_Month, MPH.BmeStatementData_PartyRegisteration_Id

/******************
Excess loss Compensation
*****************/
DECLARE @vTotalActucalEnergyOfAllMps DECIMAL(38, 13);
DECLARE @vTotalPayableExcessLosses DECIMAL(38, 13);

SELECT
	@vTotalActucalEnergyOfAllMps = SUM(EtlMpData_ActualEnergy)
FROM EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId;

SELECT
	@vTotalPayableExcessLosses = SUM(EtlTspData_TotalPayableExcessLosses )--SUM(EtlTspData_TransmissionLoss)
FROM EtlTspData
WHERE MtStatementProcess_ID = @pStatementProcessId


/***********
Prorated SUM
*************/
Declare @vTotalProratedSum  DECIMAL(38,13)
Declare @vAdjustedDifference  DECIMAL(38,13)
Declare @vTotalDiscos  Int
Select @vTotalProratedSum=SUM((EtlMpData_ActualEnergy / @vTotalActucalEnergyOfAllMps) * @vTotalPayableExcessLosses) from EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId

select @vTotalDiscos=count(distinct MTPartyRegisteration_Id) from EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId

set @vAdjustedDifference=(@vTotalPayableExcessLosses-@vTotalProratedSum)/@vTotalDiscos

if @vAdjustedDifference>1
BEGIN
set @vAdjustedDifference=0
END
/***********
Excess Losses  Compensation
*************/

UPDATE [dbo].[EtlMpData]
SET EtlMpData_ExcessLossesCompensation = ((EtlMpData_ActualEnergy / @vTotalActucalEnergyOfAllMps) * @vTotalPayableExcessLosses)+@vAdjustedDifference
WHERE MtStatementProcess_ID = @pStatementProcessId
;


/***********
Prorated Minor Adjustment
*************/
Declare @vTotalProratedSumMinor  DECIMAL(38,13)
Declare @vAdjustedDifferenceMinor  DECIMAL(38,13)

Select @vTotalProratedSumMinor=SUM(EtlMpData_ExcessLossesCompensation) from EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId


set @vAdjustedDifferenceMinor=@vTotalPayableExcessLosses-@vTotalProratedSumMinor

if @vAdjustedDifference>0.01
BEGIN
set @vAdjustedDifference=0
END


Declare @vMpRegistrationId as decimal(18,0)

select @vMpRegistrationId=max(MTPartyRegisteration_Id) from EtlMpData 
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id <> 1



UPDATE [dbo].[EtlMpData]
SET EtlMpData_ExcessLossesCompensation =EtlMpData_ExcessLossesCompensation+@vAdjustedDifferenceMinor
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id=@vMpRegistrationId


END
END

/****** Object:  Procedure [dbo].[ETLStep4Perform]    Committed by VersionSQL https://www.versionsql.com ******/

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
CREATE   PROCEDURE dbo.ETLStep4Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

DECLARE @luaccountingMonth AS INT ;

select 	@luaccountingMonth = LuAccountingMonth_Id_Current
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

/******************
Excess loss Compensation
*****************/
DECLARE @vTotalContractedEnergyOfAllMps DECIMAL(38, 13);
DECLARE @vLegacyExcessLossesCompensation DECIMAL(38, 13);

SELECT
@vTotalContractedEnergyOfAllMps = SUM(EtlMpData_ContractedEnergy )
FROM EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId;

SELECT
	@vLegacyExcessLossesCompensation = EtlMpData_ExcessLossesCompensation  
FROM EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id = 1
;

/***********
Prorated SUM
*************/
Declare @vTotalProratedSum  DECIMAL(38,13)
Declare @vAdjustedDifference  DECIMAL(38,13)
Declare @vTotalDiscos  Int
Select @vTotalProratedSum=SUM((EtlMpData_ContractedEnergy / @vTotalContractedEnergyOfAllMps) * @vLegacyExcessLossesCompensation) from EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId

select @vTotalDiscos=count(distinct MTPartyRegisteration_Id) from EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId

set @vAdjustedDifference=(@vLegacyExcessLossesCompensation-@vTotalProratedSum)/@vTotalDiscos

if @vAdjustedDifference>1
BEGIN
set @vAdjustedDifference=0
END

/***********
Additional  Compensation
*************/

UPDATE [dbo].[EtlMpData]
SET EtlMpData_AdditionalCompensation =(( EtlMpData_ContractedEnergy / @vTotalContractedEnergyOfAllMps) * @vLegacyExcessLossesCompensation)+@vAdjustedDifference
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id <> 1
;


/***********
Prorated Minor Adjustment
*************/
Declare @vTotalProratedSumMinor  DECIMAL(38,13)
Declare @vAdjustedDifferenceMinor  DECIMAL(38,13)

Select @vTotalProratedSumMinor=SUM(EtlMpData_AdditionalCompensation) from EtlMpData
WHERE MtStatementProcess_ID = @pStatementProcessId


set @vAdjustedDifferenceMinor=@vLegacyExcessLossesCompensation-@vTotalProratedSumMinor

if @vAdjustedDifference>0.01
BEGIN
set @vAdjustedDifference=0
END


Declare @vMpRegistrationId as decimal(18,0)

select @vMpRegistrationId=max(MTPartyRegisteration_Id) from EtlMpData 
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id <> 1



UPDATE [dbo].[EtlMpData]
SET EtlMpData_AdditionalCompensation =EtlMpData_AdditionalCompensation+@vAdjustedDifferenceMinor
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id=@vMpRegistrationId

/******************
Total Loss Compensation
*****************/

UPDATE [dbo].[EtlMpData]
SET EtlMpData_TotalExcessLossesCompensation = EtlMpData_ExcessLossesCompensation + EtlMpData_AdditionalCompensation
WHERE MtStatementProcess_ID = @pStatementProcessId
AND MTPartyRegisteration_Id <> 1
;

--SELECT
--EtlMpData_ExcessLossesCompensation,EtlMpData_AdditionalCompensation
--from EtlMpData
--WHERE MtStatementProcess_ID = @pStatementProcessId
----;

--SELECT
--	MP.MTPartyRegisteration_Id
--   ,0 AS TotalPayable
--   ,MP.EtlMpData_TotalExcessLossesCompensation AS TotalCompensation
--FROM EtlMpData MP
--WHERE MP.MtStatementProcess_ID = @pStatementProcessId

--UNION

--SELECT
--	TSP.MTPartyRegisteration_Id
--   ,TSP.EtlTspData_TotalPayableExcessLosses AS TotalPayable
--   ,0 AS TotalCompensation
--FROM EtlTspData TSP
--WHERE TSP.MtStatementProcess_ID = @pStatementProcessId

END

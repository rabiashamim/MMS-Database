/****** Object:  Procedure [dbo].[ETLStepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================      
-- Author: Sadaf Malik    
-- CREATE date: 16 January 2022      
-- ALTER date:          
-- Description:                     
--==========================================================================================      
    -- dbo.ETLStepsOutputView 284,1
CREATE    PROCEDURE dbo.ETLStepsOutputView (      
@pSettlementProcessId DECIMAL(18, 0),      
@pStepId DECIMAL(4, 1))      
AS      
BEGIN
      
    BEGIN TRY      
IF EXISTS (SELECT
	TOP 1
		1
	FROM MtStatementProcess msp
	WHERE msp.MtStatementProcess_ID = @pSettlementProcessId
	AND msp.MtStatementProcess_IsDeleted = 0
	AND SrProcessDef_ID IN (17, 18, 19))

BEGIN

IF (@pStepId = 1)
BEGIN
/*******************
		Step 1.1
***********************/
SELECT
	ROW_NUMBER() OVER (ORDER BY EtlTspHourly_Year, EtlTspHourly_Month, EtlTspHourly_Day, EtlTspHourly_Hour, E.MtPartyRegisteration_Id) AS [Sr]
   ,EtlTspHourly_Year AS [Year]
   ,EtlTspHourly_Month AS [Month]
   ,EtlTspHourly_Day AS [Day]
   ,EtlTspHourly_Hour - 1 AS [Hour]
   ,E.MTPartyRegisteration_Id AS [TSP-ID]
   ,P.MtPartyRegisteration_Name AS [TSP-Name]
   ,EtlTspHourly_AdjustedEnergyImport AS [Adjusted Energy Import (kWh)]
   ,EtlTspHourly_AdjustedEnergyExport AS [Adjusted Energy Export (kWh)]
   ,EtlTspHourly_TransmissionLoss AS [Transmission Loss (kWh)]
FROM EtlTspHourly E
INNER JOIN MtPartyRegisteration P
	ON P.MtPartyRegisteration_Id = E.MtPartyRegisteration_Id
WHERE MtStatementProcess_ID = @pSettlementProcessId
ORDER BY EtlTspHourly_Year ASC, EtlTspHourly_Month ASC, EtlTspHourly_Day ASC, EtlTspHourly_Hour ASC, E.MtPartyRegisteration_Id ASC;
/*******************
		Step 1.2
***********************/

SELECT
	ROW_NUMBER() OVER (ORDER BY E.EtlHourly_Year, E.EtlHourly_Month, E.EtlHourly_Day, E.EtlHourly_Hour) AS [Sr]
   ,E.EtlHourly_Year AS [Year]
   ,E.EtlHourly_Month AS [Month]
   ,E.EtlHourly_Day AS [Day]
   ,E.EtlHourly_Hour - 1 AS [Hour]
   ,E.EtlHourly_TranmissionLoss AS [Transmission Loss (kWh)]
   ,E.EtlHourly_Demand AS [Total Demand (kWh)]
   ,E.EtlHourly_MarginalPrice AS [Marginal Price (PKR)]
FROM EtlHourly E
WHERE MtStatementProcess_ID = @pSettlementProcessId
ORDER BY E.EtlHourly_Year ASC, E.EtlHourly_Month ASC, E.EtlHourly_Day ASC, E.EtlHourly_Hour ASC;
/*******************
		Step 1.3
***********************/
WITH cte_etltsp
AS
(SELECT
		EtlTspHourly_Year
	   ,EtlTspHourly_Month
	   ,MTPartyRegisteration_Id
	   ,SUM(EtlTspHourly_AdjustedEnergyImport) AS AEI
	   ,SUM(EtlTspHourly_AdjustedEnergyExport) AS AEE
	   ,SUM(EtlTspHourly_TransmissionLoss) AS TL
	FROM EtlTspHourly
	WHERE MtStatementProcess_ID = @pSettlementProcessId
	GROUP BY EtlTspHourly_Year
			,EtlTspHourly_Month
			,MTPartyRegisteration_Id)
SELECT
	ROW_NUMBER() OVER (ORDER BY E.MTPartyRegisteration_Id) AS [SR]
   ,E.EtlTspHourly_Year AS [year]
   ,E.EtlTspHourly_Month AS [Month]
   ,E.MTPartyRegisteration_Id AS [TSP-ID]
   ,P.MtPartyRegisteration_Name AS [TSP-Name]
   ,E.AEI AS [Total Energy Injected into TSP (MWh)]
   ,E.AEE AS [Total Energy Withdrawl from TSP (MWh)]
   ,E.TL AS [Transmission Loss (MWh)]
FROM cte_etltsp E
INNER JOIN MtPartyRegisteration P
	ON P.MtPartyRegisteration_Id = E.MtPartyRegisteration_Id
ORDER BY EtlTspHourly_Year ASC, EtlTspHourly_Month ASC, E.MtPartyRegisteration_Id ASC;

END
ELSE
IF (@pStepId = 2)
BEGIN
/*******************
		Step 2.1
***********************/
SELECT
	ROW_NUMBER() OVER (ORDER BY E.MTPartyRegisteration_Id) AS [Sr]
   ,E.MTPartyRegisteration_Id AS [TSP-ID]
   ,P.MtPartyRegisteration_Name AS [TSP-Name]
   ,EtlTspData_TransmissionLoss AS [Transmission Loss (MWh)]
   ,EtlTspData_TotalEnergyInjected AS [Total Energy Injected into TSP (MWh)]
   ,E.EtlTspData_AnnualLosses AS [Annual Losses (%)]
   ,E.EtlTspData_AllowedCap AS [Allow Cap %]
   ,E.EtlTspData_AllowableLosses AS [Allowable Losses (MWh)]
   ,E.EtlTspData_ExcessLosses AS [Excess Losses (MWh)]
   ,E.EtlTspData_WeightedAverageMarginalPrice AS [Weighted Average Marginal Price (PKR/MWh)]
   ,E.EtlTspData_TotalPayableExcessLosses AS [Total Payable for Excess Losses Charge (PKR)]
FROM EtlTspData E
INNER JOIN MtPartyRegisteration P
	ON P.MtPartyRegisteration_Id = E.MtPartyRegisteration_Id
WHERE MtStatementProcess_ID = @pSettlementProcessId
ORDER BY E.MtPartyRegisteration_Id;


END
ELSE
IF (@pStepId = 3)
BEGIN
/*******************
		Step 3.1
***********************/
SELECT
	ROW_NUMBER() OVER (ORDER BY E.EtlMpMonthlyData_Month, E.MTPartyRegisteration_Id) AS [Sr]
   ,E.EtlMpMonthlyData_Month AS [Month]
   ,E.MTPartyRegisteration_Id AS [MP ID]
   ,P.MtPartyRegisteration_Name AS [MP Name]
   ,E.EtlMpMonthlyData_ActualEnergy AS [Energy Withdrawal- Adjusted for Distribution Losses (Act_E) (MWh)]
FROM EtlMpMonthlyData E
INNER JOIN MtPartyRegisteration P
	ON P.MtPartyRegisteration_Id = E.MtPartyRegisteration_Id
WHERE MtStatementProcess_ID = @pSettlementProcessId
ORDER BY E.EtlMpMonthlyData_Month, E.MtPartyRegisteration_Id;

/*******************
		Step 3.2
***********************/
DECLARE @sumofActualEnergyOfAllMps DECIMAL(38, 13);
SELECT
	@sumofActualEnergyOfAllMps = SUM(EtlMpData_ActualEnergy)
FROM EtlMpData
WHERE MtStatementProcess_ID = @pSettlementProcessId

SELECT
	ROW_NUMBER() OVER (ORDER BY E.MTPartyRegisteration_Id) AS [Sr]
   ,E.MTPartyRegisteration_Id AS [MP ID]
   ,P.MtPartyRegisteration_Name AS [MP Name]
   ,E.EtlMpData_ActualEnergy AS [Energy Withdrawal- Adjusted for Distribution Losses (Act_E) (MWh)]
   ,@sumofActualEnergyOfAllMps AS [Total Energy Withdrawal by All MPs (MWh)]
   ,E.EtlMpData_ExcessLossesCompensation AS [Excess Losses Compensation (PKR)]
FROM EtlMpData E
INNER JOIN MtPartyRegisteration P
	ON P.MtPartyRegisteration_Id = E.MtPartyRegisteration_Id
WHERE MtStatementProcess_ID = @pSettlementProcessId
ORDER BY E.MtPartyRegisteration_Id;


END
ELSE
IF (@pStepId = 4)
BEGIN
/*******************
		Step 4.1
***********************/
DECLARE @sumofContractedEnergyOfAllMps DECIMAL(38, 13);
SELECT
	@sumofContractedEnergyOfAllMps = SUM(EtlMpData_ContractedEnergy)
FROM EtlMpData
WHERE MtStatementProcess_ID = @pSettlementProcessId

SELECT
	ROW_NUMBER() OVER (ORDER BY E.MTPartyRegisteration_Id) AS [Sr]
   ,E.MTPartyRegisteration_Id AS [MP ID]
   ,P.MtPartyRegisteration_Name AS [MP Name]
   ,E.EtlMpData_ContractedEnergy AS [Contracted Energy by Legacy MP (ET) (MWh)]
   ,@sumofContractedEnergyOfAllMps AS [Total Energy Contracted by All Legacy MPs (MWh)]
   ,E.EtlMpData_AdditionalCompensation AS [Excess Losses Additional Compensation (PKR)]
   ,E.EtlMpData_TotalExcessLossesCompensation AS [Total Excess Losses Compensation (PKR)]
FROM EtlMpData E
INNER JOIN MtPartyRegisteration P
	ON P.MtPartyRegisteration_Id = E.MtPartyRegisteration_Id
WHERE MtStatementProcess_ID = @pSettlementProcessId
AND E.MTPartyRegisteration_Id <> 1
ORDER BY E.MtPartyRegisteration_Id;

/*******************
		Step 4.2
***********************/
SELECT
	ROW_NUMBER() OVER (ORDER BY [MP ID]) AS [Sr]
   ,*
FROM (SELECT
		--	ROW_NUMBER() OVER (ORDER BY MTPartyRegisteration_Id) AS [Sr],
		MP.MTPartyRegisteration_Id AS [MP ID]
	   ,P.MtPartyRegisteration_Name AS [MP Name]
	   ,0 AS [Total Payable for Excess Losses Charge (PKR)]
	   ,MP.EtlMpData_TotalExcessLossesCompensation AS [Total Excess Losses Compensation (PKR)]
	FROM EtlMpData MP
	INNER JOIN MtPartyRegisteration P
		ON P.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
	WHERE MP.MtStatementProcess_ID = @pSettlementProcessId
	AND MP.MTPartyRegisteration_Id <> 1
	UNION

	SELECT
		TSP.MTPartyRegisteration_Id AS [MP ID]
	   ,P.MtPartyRegisteration_Name AS [MP Name]
	   ,TSP.EtlTspData_TotalPayableExcessLosses AS [Total Payable for Excess Losses Charge (PKR)]
	   ,0 AS [Total Excess Losses Compensation (PKR)]

	FROM EtlTspData TSP
	INNER JOIN MtPartyRegisteration P
		ON P.MtPartyRegisteration_Id = TSP.MtPartyRegisteration_Id
	WHERE TSP.MtStatementProcess_ID = @pSettlementProcessId
--order BY MP.MTPartyRegisteration_Id
) a
ORDER BY [MP ID]

END

IF (@pStepId = 5)
BEGIN
/*******************
		Step 5.1		For ESS only
***********************/
DECLARE @vLuAccountingMonth_Id_Reference as int,
@vSrProcessDefId_Reference int;


SELECT
			@vSrProcessDefId_Reference=SrProcessDef_ID,
			@vLuAccountingMonth_Id_Reference= CASE
			WHEN SrProcessDef_ID = 18 THEN LuAccountingMonth_Id_Current
			ELSE LuAccountingMonth_Id
		END
	FROM MtStatementProcess
	WHERE MtStatementProcess_ID = (SELECT TOP 1
			MtStatementProcess_ID_Reference
		FROM EtlEyssAdjustmentData
		WHERE MtStatementProcess_ID = @pSettlementProcessId)

DECLARE @vRefPeriod AS VARCHAR(20);

SELECT
	@vRefPeriod=LuAccountingMonth_MonthName
FROM LuAccountingMonth
WHERE LuAccountingMonth_Id = @vLuAccountingMonth_Id_Reference


DECLARE @vquery NVARCHAR(MAX);
DECLARE @vSettlementPeriodName NVARCHAR(20);

set @vSettlementPeriodName=
CONCAT(case when @vSrProcessDefId_Reference=18 then 'FYSS' else 'EYSS' END,' ',@vRefPeriod);

SET @vquery
= '
SELECT
	ROW_NUMBER() OVER (ORDER BY [MP ID]) AS [Sr]
   ,a.[MP ID]
   ,a.[MP Name]
   ,a.[Total Payable for Excess Losses Charge (PKR)]
   ,a.[Total Excess Losses Compensation (PKR)]
   ,EYSS.EtlEyssAdjustmentData_TotalPayableExcessLosses AS [Total Payable for Excess Losses Charge-'+@vSettlementPeriodName+' (PKR)]
   ,EYSS.EtlEyssAdjustmentData_TotalExcessLossesCompensation AS [Total Excess Losses Compensation-'+@vSettlementPeriodName+' (PKR)]
   ,EYSS.EtlEyssAdjustmentData_NetAdjustments AS [ESS Adjustment (PKR)]
FROM (SELECT
		MP.MTPartyRegisteration_Id AS [MP ID]
	   ,P.MtPartyRegisteration_Name AS [MP Name]
	   ,0 AS [Total Payable for Excess Losses Charge (PKR)]
	   ,MP.EtlMpData_TotalExcessLossesCompensation AS [Total Excess Losses Compensation (PKR)]
	FROM EtlMpData MP
	INNER JOIN MtPartyRegisteration P
		ON P.MtPartyRegisteration_Id = MP.MtPartyRegisteration_Id
	WHERE MP.MtStatementProcess_ID = '+cast (@pSettlementProcessId as varchar(18))+'
	AND MP.MTPartyRegisteration_Id <> 1
	UNION

	SELECT
		TSP.MTPartyRegisteration_Id AS [MP ID]
	   ,P.MtPartyRegisteration_Name AS [MP Name]
	   ,TSP.EtlTspData_TotalPayableExcessLosses AS [Total Payable for Excess Losses Charge (PKR)]
	   ,0 AS [Total Excess Losses Compensation (PKR)]

	FROM EtlTspData TSP
	INNER JOIN MtPartyRegisteration P
		ON P.MtPartyRegisteration_Id = TSP.MtPartyRegisteration_Id
	WHERE TSP.MtStatementProcess_ID = '+cast(@pSettlementProcessId as varchar(18))+'
) a
INNER JOIN EtlEyssAdjustmentData EYSS
	ON EYSS.MTPartyRegisteration_Id = a.[MP ID]
	WHERE EYSS.MtStatementProcess_ID='+cast(@pSettlementProcessId as varchar(18))+'
ORDER BY [MP ID]

'
EXEC (@vquery);


END

END
END TRY
BEGIN CATCH

DECLARE @vErrorMessage VARCHAR(MAX) = '';
SELECT
	@vErrorMessage = 'ETL Process Output View Error: ' + ERROR_MESSAGE();
RAISERROR (@vErrorMessage, 16, -1);
END CATCH
END

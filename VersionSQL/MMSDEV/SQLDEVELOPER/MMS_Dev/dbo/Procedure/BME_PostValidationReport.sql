/****** Object:  Procedure [dbo].[BME_PostValidationReport]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================  
-- Author: Ali Imran (.Net/SQL Developer)  
-- CREATE date: Sep 15, 2022 
-- ALTER date: 
-- Description: 
-- =============================================  
-- BME_PostValidationReport 47
CREATE   PROCEDURE dbo.BME_PostValidationReport (
  @StatementProcessId DECIMAL(18, 0))
AS
BEGIN
	/********************************************************************************************
	* BME Process Validation 1.
	********************************************************************************************/


	

	--SELECT
	--	BmeStatementData_Year AS [Year]
	--   ,BmeStatementData_Month AS [Month]
	--   ,BmeStatementData_Day AS [Day]
	--   ,BmeStatementData_Hour -1 AS [Hour]
	--   ,(SELECT TOP 1
	--			MtGenerator_Name
	--		FROM vw_CdpGenerators
	--		WHERE MtGenerator_Id = BmeStatementData_MtGenerator_Id)
	--	AS [Generator Name]
	--   ,(SELECT TOP 1
	--			MtGenerationUnit_UnitName
	--		FROM vw_CdpGenerators
	--		WHERE MtGenerationUnit_Id = BmeStatementData_MtGeneratorUnit_Id)
	--	AS [Generator Unit Name]
	--   ,[SrTechnologyType_Code] AS [Technology Type]
	--   ,[BmeStatementData_CalculatedAvailableCapacityASC] AS [Available Capacity]
	--   ,[BmeStatementData_GenerationUnitEnergy] AS [Metered Value] INTO #Validation1
	--FROM [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess] 
	--WHERE BmeStatementData_StatementProcessId = @StatementProcessId
	--AND SrTechnologyType_Code <> 'ARE'
	--AND ISNULL(BmeStatementData_GenerationUnitEnergy, 0) <> 0
	--AND ISNULL([BmeStatementData_CalculatedAvailableCapacityASC], 0) = 0

	SELECT
		BmeStatementData_Year AS [Year]
	   ,BmeStatementData_Month AS [Month]
	   ,BmeStatementData_Day AS [Day]
	   ,BmeStatementData_Hour AS [Hour]
	   ,(SELECT TOP 1
				MtGenerator_Name
			FROM vw_CdpGenerators
			WHERE MtGenerator_Id = BmeStatementData_MtGenerator_Id)
		AS [Generator Name]
	   ,(SELECT TOP 1
				MtGenerationUnit_UnitName
			FROM vw_CdpGenerators
			WHERE MtGenerationUnit_Id = BmeStatementData_MtGeneratorUnit_Id)
		AS [Generator Unit Name]
		,(SELECT TOP 1 MtGenerationUnit_SOUnitId FROM vw_CdpGenerators
		WHERE MtGenerationUnit_Id = BmeStatementData_MtGeneratorUnit_Id) AS [SO Unit Id]
	   ,[SrTechnologyType_Code] AS [Technology Type]
	   ,[BmeStatementData_CalculatedAvailableCapacityASC] AS [Available Capacity]
	   	   ,[BmeStatementData_CalculatedAvailableCapacityASCSum] AS [Available Capacity Sum ]
	   ,[BmeStatementData_GenerationUnitEnergy] AS [Metered Value] INTO #Validation1
	FROM [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess] 
	WHERE BmeStatementData_StatementProcessId = @StatementProcessId
	AND SrTechnologyType_Code <> 'ARE'
	AND ISNULL(BmeStatementData_GenerationUnitEnergy, 0) <> 0
	--AND ISNULL([BmeStatementData_CalculatedAvailableCapacityASC], 0) = 0
			AND ISNULL([BmeStatementData_CalculatedAvailableCapacityASCSum], 0) = 0

	/********************************************************************************************
	* BME Process Validation 2.
	********************************************************************************************/

	SELECT
		ROW_NUMBER() OVER (ORDER BY DH.BmeStatementData_Id) AS [Sr]
	   ,DH.BmeStatementData_Month AS [Month]
	   ,DH.BmeStatementData_Day AS [Day]
	   ,DH.BmeStatementData_Hour-1 AS [Hour]
	   ,CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) AS [Total Demand (kWh)]
	   ,CAST(MP.BmeStatementData_ActualEnergy AS INT) [Hourly Metered Energy (Act_E) (kWh)]
	   ,CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT) AS diff INTO #Validation2
	FROM BmeStatementDataHourly_SettlementProcess DH
	JOIN (SELECT
			BmeStatementData_Month
		   ,BmeStatementData_Day
		   ,BmeStatementData_Hour
		   ,SUM(BmeStatementData_ActualEnergy) AS BmeStatementData_ActualEnergy
		FROM BmeStatementDataMpHourly_SettlementProcess
		WHERE BmeStatementData_StatementProcessId = @StatementProcessId
		GROUP BY BmeStatementData_Month
				,BmeStatementData_Day
				,BmeStatementData_Hour) MP
		ON MP.BmeStatementData_Month = DH.BmeStatementData_Month
			AND MP.BmeStatementData_Day = DH.BmeStatementData_Day
			AND MP.BmeStatementData_Hour = DH.BmeStatementData_Hour

	WHERE DH.BmeStatementData_StatementProcessId = @StatementProcessId
	--AND (CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT)) <> 0
	AND( (CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT)) >2
	OR (CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT)) <-2)


	/********************************************************************************************
	* BME Process Validation 3.
	********************************************************************************************/

	SELECT
		SUM(ISNULL(BmeStatementData_AmountPayableReceivable, 0)) AS SumAmountPayableReceivable INTO #Validation3
	FROM BmeStatementDataMpMonthly_SettlementProcess
	WHERE BmeStatementData_StatementProcessId = @StatementProcessId


	/********************************************************************************************
	* BME Process Validation 4.
	********************************************************************************************/



	SELECT
		DH.BmeStatementData_Month AS [Month]
	   ,DH.BmeStatementData_Day AS [Day]
	   ,DH.BmeStatementData_Hour-1 AS [Hour]
	   ,DH.BmeStatementData_TransmissionLosses AS [Transmission Loss]
	   ,MP.BmeStatementData_ActualEnergy AS [Actual Energy] 
	   --,MP.BmeStatementData_EnergySuppliedActual
	   --,DH.BmeStatementData_TransmissionLosses + MP.BmeStatementData_ActualEnergy AS [Sum of TL AND ESG]
	   ,MP.BmeStatementData_EnergySuppliedGenerated AS [ESG]
	   ,MP.BmeStatementData_EnergySuppliedImported AS [ESI]
	   ,CAST(DH.BmeStatementData_TransmissionLosses AS INT) + CAST(MP.BmeStatementData_ActualEnergy AS INT) 
	   - CAST(MP.BmeStatementData_EnergySuppliedGenerated AS INT) - CAST(MP.BmeStatementData_EnergySuppliedImported AS INT)
	   AS [Energy Difference]

INTO #Validation4A
	FROM BmeStatementDataHourly_SettlementProcess DH
	JOIN (SELECT
			BmeStatementData_Month
		   ,BmeStatementData_Day
		   ,BmeStatementData_Hour
		   ,SUM(ISNULL(BmeStatementData_ActualEnergy,0)) AS BmeStatementData_ActualEnergy --AS [Hourly Metered Energy (Act_E) (kWh)]
		   ,SUM(ISNULL(BmeStatementData_EnergySuppliedActual,0)) AS BmeStatementData_EnergySuppliedActual
		   ,SUM(ISNULL(BmeStatementData_EnergySuppliedImported,0)) AS BmeStatementData_EnergySuppliedImported
		   ,SUM(ISNULL(BmeStatementData_EnergySuppliedGenerated,0)) AS BmeStatementData_EnergySuppliedGenerated --AS [Hourly  Generation (ES_G) (kWh)]
		FROM BmeStatementDataMpHourly_SettlementProcess

		WHERE BmeStatementData_StatementProcessId = @StatementProcessId
		GROUP BY BmeStatementData_Month
				,BmeStatementData_Day
				,BmeStatementData_Hour) MP
		ON MP.BmeStatementData_Month = DH.BmeStatementData_Month
			AND MP.BmeStatementData_Day = DH.BmeStatementData_Day
			AND MP.BmeStatementData_Hour = DH.BmeStatementData_Hour

	WHERE BmeStatementData_StatementProcessId = @StatementProcessId
	--thrash hold value 1,0,-1
	SELECT * into #Validation4 FROM #Validation4A WHERE  [Energy Difference] NOT IN (1,0,-1) 
		/********************************************************************************************
	* BME Process Validation 5. Total Adjusted Energy Import should be greater than Total Adjusted Energy Export
	********************************************************************************************/
SELECT
	ROW_NUMBER() OVER (ORDER BY tspHourly.BmeStatementData_Id) AS [Sr]
   ,tspHourly.BmeStatementData_Month AS [Month]
   ,tspHourly.BmeStatementData_Day AS [Day]
   ,tspHourly.BmeStatementData_Hour - 1 AS [Hour]
   ,tspHourly.BmeStatementData_PartyRegisteration_Id AS [TSP-ID]
   ,tspHourly.BmeStatementData_PartyName AS [TSP-Name]
   ,tspHourly.BmeStatementData_AdjustedEnergyImport AS [Adjusted Energy Import (kWh)]
   ,tspHourly.BmeStatementData_AdjustedEnergyExport AS [Adjusted Energy Export (kWh)]
   , tspHourly.BmeStatementData_TransmissionLosses as [Losses]
   into #Validation5
FROM BmeStatementDataTspHourly_SettlementProcess tspHourly
WHERE tspHourly.BmeStatementData_StatementProcessId=@StatementProcessId
AND tspHourly.BmeStatementData_AdjustedEnergyImport<=tspHourly.BmeStatementData_AdjustedEnergyExport
	/********************************************************************************************
	* BME Validation final Results.
	********************************************************************************************/



	SELECT 1 AS [Sr],
		'Availability issue while calculating unit wise generation' AS [Validation]
	   ,CASE
			WHEN COUNT(v1.[day]) > 0 THEN 'Failed'
			ELSE 'Passed'
		END AS [status]
	FROM #Validation1 v1
	UNION
	SELECT 2 AS [Sr],
		'Check for Total Demand and Sum of Actual E are equal' AS [Validation]
	   ,CASE
			WHEN COUNT(v2.[day]) > 0 THEN 'Failed'
			ELSE 'Passed'
		END AS [status]
	FROM #Validation2 v2
	UNION
	SELECT 3 AS [Sr],
		'Sum of Amount Payable / Receivable is Zero' AS [Validation]
	   ,CASE
			WHEN v3.SumAmountPayableReceivable <> 0 THEN 'Failed'
			ELSE 'Passed'
		END AS [status]
	FROM #Validation3 v3
	UNION
	SELECT 4 AS [Sr],
		'Sum of Actual E + Transmission Losses shall be equal to total generation' AS [Validation]
	   ,CASE
			WHEN COUNT(v4.[hour]) > 0 THEN 'Failed'
			ELSE 'Passed'
		END AS [status]
	FROM #Validation4 v4

	UNION
	SELECT 5 AS [Sr],
		'Total Adjusted Energy Import (kWh) of TSP should be greater than total Adjusted Energy Export (kWh) of TSP' AS [Validation]
	   ,CASE
			WHEN COUNT(v5.[Hour]) > 0 THEN 'Failed'
			ELSE 'Passed'
		END AS [status]
	FROM #Validation5 v5

    /********************************************************************************************
	* BME Validation Reports.
	********************************************************************************************/


	SELECT
		'' AS [1] ,*
	FROM #Validation1
	ORDER BY [day],[hour],[Generator Name],[Generator Unit Name]

	SELECT
	'' AS [2] 

	,
		*
	FROM #Validation2
	ORDER BY [day],[hour]

	SELECT
	'' AS [3] ,
		*
	FROM #Validation3
	

	SELECT
	'' AS [4] ,
		*
	FROM #Validation4
	ORDER BY [day],[hour]


	SELECT
	'' AS [5] ,
		*
	FROM #Validation5
	ORDER BY [Day],[Hour]
END

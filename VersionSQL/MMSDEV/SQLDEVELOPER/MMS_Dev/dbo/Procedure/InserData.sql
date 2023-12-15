/****** Object:  Procedure [dbo].[InserData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE InserData
	@Id DECIMAL(18,0)
	AS 
	BEGIN
		INSERT INTO [dbo].[BMEPostValidationStep1]
           ([BMEPostValidationStep1_Year]
           ,[BMEPostValidationStep1_Month]
           ,[BMEPostValidationStep1_Day]
           ,[BMEPostValidationStep1_Hour]
           ,[BMEPostValidationStep1_GeneratorName]
           ,[BMEPostValidationStep1_GeneratorUnitName]
           ,[BMEPostValidationStep1_SOUnitId]
           ,[BMEPostValidationStep1_TechnologyType]
           ,[BMEPostValidationStep1_AvailableCapacity]
           ,[BMEPostValidationStep1_AvailableCapacitySum]
           ,[BMEPostValidationStep1_MeteredValue]
           ,[BMEPostValidationStep1_CreatedAt]
		   ,[MtStatementProcess_ID])
	
	SELECT Top 10
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
	   ,[BmeStatementData_GenerationUnitEnergy] AS [Metered Value] 
	   ,GETDATE()
	   ,@Id
	FROM [dbo].[BmeStatementDataGenUnitHourly_SettlementProcess] 
	WHERE BmeStatementData_StatementProcessId = @Id
	AND SrTechnologyType_Code <> 'ARE'
	AND ISNULL(BmeStatementData_GenerationUnitEnergy, 0) <> 0
	AND ISNULL([BmeStatementData_CalculatedAvailableCapacityASCSum], 0) = 0

	INSERT INTO [dbo].[BMEPostValidationStep2]
	([BMEPostValidationStep2_Month],
	[BMEPostValidationStep2_Day],
	[BMEPostValidationStep2_Hour],
	[BMEPostValidationStep2_TotalDemand],
	[BMEPostValidationStep2_HourlyMeteredEnergy],
	[BMEPostValidationStep2_diff],
	[BMEPostValidationStep2_CreatedAt],
	[MtStatementProcess_ID])

	SELECT
		--ROW_NUMBER() OVER (ORDER BY DH.BmeStatementData_Id) AS [Sr]
	   DH.BmeStatementData_Month AS [Month]
	   ,DH.BmeStatementData_Day AS [Day]
	   ,DH.BmeStatementData_Hour-1 AS [Hour]
	   ,CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) AS [Total Demand (kWh)]
	   ,CAST(MP.BmeStatementData_ActualEnergy AS INT) [Hourly Metered Energy (Act_E) (kWh)]
	   ,CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT) AS diff 
	   ,GETDATE()
	   ,@Id
	FROM BmeStatementDataHourly_SettlementProcess DH
	JOIN (SELECT
			BmeStatementData_Month
		   ,BmeStatementData_Day
		   ,BmeStatementData_Hour
		   ,SUM(BmeStatementData_ActualEnergy) AS BmeStatementData_ActualEnergy
		FROM BmeStatementDataMpHourly_SettlementProcess
		WHERE BmeStatementData_StatementProcessId = @Id
		GROUP BY BmeStatementData_Month
				,BmeStatementData_Day
				,BmeStatementData_Hour) MP
		ON MP.BmeStatementData_Month = DH.BmeStatementData_Month
			AND MP.BmeStatementData_Day = DH.BmeStatementData_Day
			AND MP.BmeStatementData_Hour = DH.BmeStatementData_Hour

	WHERE DH.BmeStatementData_StatementProcessId = @Id
	--AND (CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT)) <> 0
	AND( (CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT)) >2
	OR (CAST(ISNULL(DH.BmeStatementData_DemandedEnergy, 0) AS INT) - CAST(ISNULL(MP.BmeStatementData_ActualEnergy, 0) AS INT)) <-2)
	END;

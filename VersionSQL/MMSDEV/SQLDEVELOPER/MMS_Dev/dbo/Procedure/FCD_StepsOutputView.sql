/****** Object:  Procedure [dbo].[FCD_StepsOutputView]    Committed by VersionSQL https://www.versionsql.com ******/

--  dbo.FCD_StepsOutputView 143,1

CREATE PROCEDURE dbo.FCD_StepsOutputView @pMtFCDMaster_Id DECIMAL(18, 0),
@pStepId INT
AS
BEGIN

	IF EXISTS (SELECT TOP 1
				1
			FROM MtGenerator
			WHERE MtGenerator_Id IN (SELECT
					MtGenerator_Id
				FROM MtFCDGenerators
				WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
				AND ISNULL(MtFCDGenerators_IsDeleted, 0) = 0)
			AND ISNULL(isDeleted, 0) = 0
			AND ISNULL(MtGenerator_IsDeleted, 0) = 0
			AND LuEnergyResourceType_Code = 'NDP' 
			)
		AND @pStepId IN (1)


	BEGIN
		SELECT
			DATEFROMPARTS(MtFCDHourlyData_Year, MtFCDHourlyData_Month, MtFCDHourlyData_Day) AS [Date]
		   ,MtFCDHourlyData_Hour AS [Hour]
		   ,G.MtGenerator_Name AS [MMS Generator Name]
		   ,T.SrTechnologyType_Name AS [Technology]
		   ,FCD.MtGenerator_Id AS [MMS Gen ID]
		   ,FCD.MtFCDHourlyData_SOForecast AS [Forecast(MW)]
		   ,FCD.MtFCDHourlyData_Curtailment AS [Curtailemnt(MW)]
		   ,FCD.MtFCDHourlyData_Generation AS [Generation(MW)]
		   ,G.MtGenerator_TotalInstalledCapacity AS [Installed Capacity]
		   ,MtFCDHourlyData_Calculation AS calculation
		FROM [dbo].[MtFCDHourlyData] FCD
		JOIN MtGenerator G
			ON G.MtGenerator_Id = FCD.MtGenerator_Id
		INNER JOIN MtGenerationUnit GU
			ON GU.MtGenerator_Id = G.MtGenerator_Id
		INNER JOIN SrTechnologyType T
			ON T.SrTechnologyType_Code = GU.SrTechnologyType_Code
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		AND ISNULL(G.isDeleted, 0) = 0
		AND ISNULL(MtGenerator_IsDeleted, 0) = 0
		AND ISNULL(GU.isDeleted, 0) = 0
		AND ISNULL(GU.MtGenerationUnit_IsDeleted, 0) = 0
		ORDER BY FCD.MtGenerator_Id, MtFCDHourlyData_Year, MtFCDHourlyData_Month, MtFCDHourlyData_Day
	END

		IF EXISTS (SELECT TOP 1
				1
			FROM MtGenerator
			WHERE MtGenerator_Id IN (SELECT
					MtGenerator_Id
				FROM MtFCDGenerators
				WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
				AND ISNULL(MtFCDGenerators_IsDeleted, 0) = 0)
			AND ISNULL(isDeleted, 0) = 0
			AND ISNULL(MtGenerator_IsDeleted, 0) = 0
			AND LuEnergyResourceType_Code = 'DP' 
			)
		AND @pStepId IN (2)
	BEGIN

	SELECT
			lAM.LuAccountingMonth_MonthName AS [Period]
		   ,G.MtGenerator_Id AS [Generator ID]
		   ,G.MtGenerator_Name AS [Generator Name]
			--,FG.MtFCDGenerators_TotalGeneration AS [Total Generation]    
			--,FG.MtFCDGenerators_EnergyGeneratedDuringCurtailment AS [Energy Generation During Curtailment]    
		   ,FG.MtFCDGenerators_InitialFirmCapacity AS [Initial Firm Capacity (MW)]
		FROM MtFCDGenerators FG
		JOIN MtFCDMaster M
			ON FG.MtFCDMaster_Id = M.MtFCDMaster_Id
		JOIN LuAccountingMonth lAM
			ON M.LuAccountingMonth_Id = lAM.LuAccountingMonth_Id
		JOIN MtGenerator G
			ON G.MtGenerator_Id = FG.MtGenerator_Id
		WHERE m.MtFCDMaster_Id = @pMtFCDMaster_Id
		AND ISNULL(isDeleted, 0) = 0
		AND ISNULL(MtGenerator_IsDeleted, 0) = 0
		AND M.MtFCDMaster_IsDeleted=0
	END



	IF @pStepId IN (3)
		BEGIN
		SELECT
			lAM.LuAccountingMonth_MonthName AS [Period]
		   ,G.MtGenerator_Id AS [Generator ID]
		   ,G.MtGenerator_Name AS [Generator Name]
			--,FG.MtFCDGenerators_TotalGeneration AS [Total Generation]    
			--,FG.MtFCDGenerators_EnergyGeneratedDuringCurtailment AS [Energy Generation During Curtailment]    
		   ,FG.MtFCDGenerators_InitialFirmCapacity AS [Initial Firm Capacity (MW)]
		FROM MtFCDGenerators FG
		JOIN MtFCDMaster M
			ON FG.MtFCDMaster_Id = M.MtFCDMaster_Id
		JOIN LuAccountingMonth lAM
			ON M.LuAccountingMonth_Id = lAM.LuAccountingMonth_Id
		JOIN MtGenerator G
			ON G.MtGenerator_Id = FG.MtGenerator_Id
		WHERE m.MtFCDMaster_Id = @pMtFCDMaster_Id
		AND ISNULL(isDeleted, 0) = 0
		AND ISNULL(MtGenerator_IsDeleted, 0) = 0
		AND M.MtFCDMaster_IsDeleted=0
	END
--and g.LuEnergyResourceType_Code='DP' 
END

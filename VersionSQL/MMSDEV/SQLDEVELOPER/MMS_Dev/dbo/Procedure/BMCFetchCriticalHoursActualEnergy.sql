/****** Object:  Procedure [dbo].[BMCFetchCriticalHoursActualEnergy]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Ali Imran| AMMAMA Gill
-- CREATE date: 28 Dec 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
CREATE   PROCEDURE dbo.BMCFetchCriticalHoursActualEnergy @pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [dbo].[BMCActualEnergyCriticalHourly]
			WHERE MtStatementProcess_ID = @pStatementProcessId)
	BEGIN

		/*==========================================================================================
		Fetch distinct critical hours frm Critical Hours Capacity.
		==========================================================================================*/
		--DROP TABLE IF EXISTS #CHC
		SELECT
		DISTINCT
			DATEPART(YEAR, MtCriticalHoursCapacity_Date) AS [year]
		   ,DATEPART(MONTH, MtCriticalHoursCapacity_Date) AS [Month]
		   ,DATEPART(DAY, MtCriticalHoursCapacity_Date) AS [Day]
		   ,MtCriticalHoursCapacity_Hour AS [hour] INTO #CHC
		FROM [dbo].[MtCriticalHoursCapacity]
		WHERE MtSOFileMaster_Id = dbo.GetMtSoFileMasterId(@pStatementProcessId, 10)

		/*==========================================================================================
		Fetch Year for BMC
		==========================================================================================*/
		DECLARE @vEffectiveFrom DATE
			   ,@vEffectiveTo DATE;
		--@vBMCYear INT;
		SELECT
			@vEffectiveFrom = AM.LuAccountingMonth_FromDate
		   ,@vEffectiveTo = AM.LuAccountingMonth_ToDate
		--@vBMCYear = AM.LuAccountingMonth_Year
		FROM MtStatementProcess msp
		INNER JOIN LuAccountingMonth AM
			ON msp.LuAccountingMonth_Id_Current = AM.LuAccountingMonth_Id
		WHERE msp.MtStatementProcess_ID = @pStatementProcessId

		/*==========================================================================================
		Fetch All statement process Id of the BMC year.  ESS/FSS only
		==========================================================================================*/

		SELECT
			MAX(MtStatementProcess_ID) AS StatementIDs INTO #StatementIDs
		FROM MtStatementProcess SP
		INNER JOIN LuAccountingMonth AM
			ON SP.LuAccountingMonth_Id_Current = AM.LuAccountingMonth_Id
		WHERE (DATEFROMPARTS(AM.LuAccountingMonth_Year, AM.LuAccountingMonth_Month, 1) BETWEEN @vEffectiveFrom AND @vEffectiveTo)
		--AM.LuAccountingMonth_Year = @vBMCYear
		AND ISNULL(SP.MtStatementProcess_IsDeleted, 0) = 0
		AND ISNULL(AM.LuAccountingMonth_IsDeleted, 0) = 0
		AND SP.SrProcessDef_ID IN (4, 7)
		GROUP BY LuAccountingMonth_Id_Current


		/*==========================================================================================
		Filter parties which have categories BPC and BSUP 
		==========================================================================================*/

		SELECT
			mpr.MtPartyRegisteration_Id INTO #RequiredParties
		FROM MtPartyRegisteration mpr
		INNER JOIN MtPartyCategory mpc
			ON mpr.MtPartyRegisteration_Id = mpc.MtPartyRegisteration_Id
		WHERE mpc.SrCategory_Code IN ('BPC', 'BSUP')
		AND ISNULL(mpc.isDeleted, 0) = 0
		AND ISNULL(mpr.isDeleted, 0) = 0

		/*==========================================================================================
		Fetch Actual Energy from BME only for Critical Hours.
		==========================================================================================*/

		INSERT INTO [dbo].[BMCActualEnergyCriticalHourly] ([BMCActualEnergyCriticalHourly_Year]
		, [BMCActualEnergyCriticalHourly_Month]
		, [BMCActualEnergyCriticalHourly_Day]
		, [BMCActualEnergyCriticalHourly_Hour]
		, [BMCActualEnergyCriticalHourly_ActualEnergy]
		, [MtPartyRegisteration_Id]
		, [MtStatementProcess_ID])

			SELECT
				CHC.[year]
			   ,CHC.[month]
			   ,CHC.[day]
			   ,CHC.[hour]
			   ,BmeStatementData_ActualEnergy AS Actual_E
			   ,BmeStatementData_PartyRegisteration_Id AS [PartyId]
			   ,@pStatementProcessId
			FROM #CHC CHC
			LEFT JOIN BmeStatementDataMpHourly_SettlementProcess MPH
				ON MPH.BmeStatementData_Year = CHC.[year]
					AND MPH.BmeStatementData_Month = CHC.[month]
					AND MPH.BmeStatementData_Day = CHC.[day]
					AND MPH.BmeStatementData_Hour = CHC.[hour]
			INNER JOIN #RequiredParties rp
				ON MPH.BmeStatementData_PartyRegisteration_Id = rp.MtPartyRegisteration_Id
			WHERE BmeStatementData_StatementProcessId IN (SELECT
					StatementIDs
				FROM #StatementIDs)

	END

END

/****** Object:  Procedure [dbo].[FCD_Execution_BK_22May2023]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================  
-- Author:  Ali Imran
-- CREATE date: 15 March 2023
-- ALTER date: 
-- Description: 
-- ================================================================================= 
-- [FCD_Execution] @pMtFCDMaster_Id=40,@pUserId=1
CREATE     PROCEDURE dbo.FCD_Execution_BK_22May2023 @pMtFCDMaster_Id DECIMAL(18, 0)
, @pUserId INT
AS
BEGIN
	UPDATE MtFCDMaster
	SET MtFCDMaster_ProcessStatus = 'InProcess',
	MtFCDMaster_ExecutionStartDate=GETDATE()
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id

	BEGIN TRY
		/**************************************************************************************************************
		*************************************      Validations    **************************************************
		**************************************************************************************************************/

		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 0
										  ,@pStatus = 1
										  ,@pMessage = 'Firm Capacity Determination Step 0: Validations started'
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1
		/**************************************************************************************************************/
		EXECUTE [FCD_PreValidation] @pMtFCDMaster_Id = @pMtFCDMaster_Id
								   ,@pUserId = @pUserId

		IF EXISTS (SELECT
					1
				WHERE @@rowcount > 0)
		BEGIN

			EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
											  ,@pStepNo = 0
											  ,@pStatus = 3
											  ,@pMessage = 'Firm Capacity Determination Step 0: Validations failed'
											  ,@pUserId = @pUserId
											  ,@pSrFCDProcessDef_Id = 1


			UPDATE MtFCDMaster
			SET MtFCDMaster_ProcessStatus = 'Interrupted'
			   ,MtFCDMaster_ApprovalStatus = 'Draft'
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id

			RETURN;
		END
		/**************************************************************************************************************/
		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 0
										  ,@pStatus = 2
										  ,@pMessage = 'Firm Capacity Determination Step 0: Validations completed'
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1
		/**************************************************************************************************************/

		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 1
										  ,@pStatus = 1
										  ,@pMessage = 'Firm Capacity Determination Step 1: Non-Dispatchable Plants started'
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1

		/**************************************************************************************************************/

		IF NOT EXISTS (SELECT TOP 1
					1
				FROM [MtFCDHourlyData]
				WHERE [MtFCDMaster_Id] = @pMtFCDMaster_Id)
		BEGIN
			INSERT INTO [dbo].[MtFCDHourlyData] ([MtFCDMaster_Id]
			, [MtGenerator_Id]
			, [MtFCDHourlyData_Year]
			, [MtFCDHourlyData_Month]
			, [MtFCDHourlyData_Day]
			, [MtFCDHourlyData_Hour]
			, [MtFCDHourlyData_Generation]
			, [MtFCDHourlyData_Curtailment]
			, [MtFCDHourlyData_SOForecast]
			--, [MtFCDHourlyData_EnergyNonExistent]
			)
				SELECT
					@pMtFCDMaster_Id
				   ,MtGenerator_Id
				   ,MtFCDGenerationCurtailmentForecastHourlyData_year
				   ,MtFCDGenerationCurtailmentForecastHourlyData_Month
				   ,MtFCDGenerationCurtailmentForecastHourlyData_Day
				   ,MtFCDGenerationCurtailmentForecastHourlyData_Hour
				   ,MtFCDGenerationCurtailmentForecastHourlyData_Generation
				   ,MtFCDGenerationCurtailmentForecastHourlyData_Curtailment
				   ,MtFCDGenerationCurtailmentForecastHourlyData_SoForecast
				--,MtFCDGenerationCurtailmentForecastHourlyData_EnergyNonExistent
				FROM MtFCDGenerationCurtailmentForecastHourlyData mfcfhd
				WHERE mfcfhd.MtFCDMaster_Id = @pMtFCDMaster_Id
		END
		/******************************************************************
		Calculate Calculation step column on Hourly basis
		******************************************************************/
		update Hourly set  
		Hourly.[MtFCDHourlyData_Calculation]=

		case
		when DATEFROMPARTS( Hourly.MtFCDHourlyData_Year, Hourly.MtFCDHourlyData_Month, Hourly.MtFCDHourlyData_Day)<G.COD_Date
		Then Gen.MtGenerator_TotalInstalledCapacity* Gen.MtFCDGenerators_EAFactor

		 when Hourly.[MtFCDHourlyData_Generation]>=0 
		and ISNULL(Hourly.[MtFCDHourlyData_Curtailment],0)=0 
		Then Hourly.[MtFCDHourlyData_Generation]

		when  Hourly.[MtFCDHourlyData_Generation]>=0 
		and Hourly.[MtFCDHourlyData_Curtailment]>0 
		and Hourly.[MtFCDHourlyData_SOForecast] is null then 
		Gen.MtGenerator_TotalInstalledCapacity* Gen.MtFCDGenerators_EAFactor

		when  Hourly.[MtFCDHourlyData_Curtailment]>0 
		and isnull(Hourly.[MtFCDHourlyData_SOForecast],0)>=0
		then Hourly.[MtFCDHourlyData_SOForecast]

		when Hourly.[MtFCDHourlyData_Generation] is null 
		and ISNULL(Hourly.[MtFCDHourlyData_Curtailment],0)=0 
		then Gen.MtGenerator_TotalInstalledCapacity* Gen.MtFCDGenerators_EAFactor
		

		end	
		From MtFCDHourlyData Hourly
		inner join MtFCDGenerators Gen on Gen.MtGenerator_Id=Hourly.MtGenerator_Id
		inner join Mtgenerator G on G.MtGenerator_Id=Gen.MtGenerator_Id
		and Gen.MtFCDMaster_Id=@pMtFCDMaster_Id
		where  Hourly.MtFCDMaster_Id = @pMtFCDMaster_Id
		and ISNULL( G.isDeleted,0)=0
		and ISNULL(G.MtGenerator_IsDeleted,0)=0;

		/******************************************************************
		Calculate IFC based on Calculation column
		******************************************************************/
		update FCD
		set FCD.MtFCDGenerators_InitialFirmCapacity=SumFCD.TotalCalculations/SumFCD.TotalHours
		from MtFCDGenerators FCD join
		(
		select MtGenerator_Id, count(1) as TotalHours, sum(MtFCDHourlyData_Calculation) as TotalCalculations from MtFCDHourlyData
		where MtFCDMaster_Id=@pMtFCDMaster_Id
		group by MtGenerator_Id
		) as SumFCD
		on SumFCD.MtGenerator_Id=FCD.MtGenerator_Id
		where MtFCDMaster_Id=@pMtFCDMaster_Id
		;

		--return;
		--return;
		--/**************************************************************************************************************
		--*************************************      MtFCDGenerators   **************************************************
		--**************************************************************************************************************/
		
		--WITH _GenTotalGenerater
		--AS
		--(SELECT
		--		MtGenerator_Id
		--	   ,SUM(ISNULL(MtFCDHourlyData_Generation, 0)) AS GenerationSum
		--	FROM [MtFCDHourlyData] mf
		--	WHERE mf.MtFCDMaster_Id = @pMtFCDMaster_Id
		--	GROUP BY MtGenerator_Id)

		--UPDATE G
		--SET G.MtFCDGenerators_TotalGeneration =
		--HG.GenerationSum
		--FROM MtFCDGenerators G
		--JOIN _GenTotalGenerater HG
		--	ON G.MtGenerator_Id = HG.MtGenerator_Id
		--WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
		--AND G.LuEnergyResourceType_Code = 'NDP'


		--/**************************************************************************************************************
		--*************************************      Count zero Generations hours  **************************************
		--**************************************************************************************************************/
		--;
		--WITH withZeroGeneration
		--AS
		--(SELECT
		--		G.MtGenerator_Id
		--	   ,COUNT(HD.MtFCDHourlyData_Generation) AS ZeroGenerationCount
		--	FROM MtFCDGenerators G
		--	LEFT JOIN MtFCDHourlyData HD
		--		ON HD.MtGenerator_Id = G.MtGenerator_Id
		--		AND HD.MtFCDHourlyData_Generation < 1
		--		AND HD.MtFCDHourlyData_Curtailment<1
		--		AND HD.MtFCDHourlyData_SOForecast<1
		--	WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
		--	AND G.LuEnergyResourceType_Code = 'NDP'
		--	GROUP BY G.MtGenerator_Id)

		--UPDATE G
		--SET MtFCDGenerators_CountNonExistenceHours = ZG.ZeroGenerationCount
		--FROM MtFCDGenerators G
		--JOIN withZeroGeneration ZG
		--	ON G.MtGenerator_Id = ZG.MtGenerator_Id
		--WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
		--AND G.LuEnergyResourceType_Code = 'NDP'
		--;
		--/**************************************************************************************************************
		--*************************************   Energy  Generated during Curtailment  *********************************
		--**************************************************************************************************************/

		--WITH CurtailmentGeneration
		--AS
		--(SELECT
		--		G.MtGenerator_Id
		--	   ,SUM(HD.MtFCDHourlyData_Generation) AS EnergyGeneratedDuringCurtailment
		--	   ,SUM(HD.MtFCDHourlyData_SOForecast) AS SOForecastDuringCurtailment
		--	FROM MtFCDGenerators G
		--	LEFT JOIN MtFCDHourlyData HD
		--		ON HD.MtGenerator_Id = G.MtGenerator_Id
		--		AND HD.MtFCDHourlyData_Curtailment > 0
		--	WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
		--	GROUP BY G.MtGenerator_Id)


		--UPDATE G
		--SET G.MtFCDGenerators_EnergyGeneratedDuringCurtailment = CG.EnergyGeneratedDuringCurtailment
		--   ,G.MtFCDGenerators_SoForecastDuringCurtailment = CG.SOForecastDuringCurtailment
		--FROM MtFCDGenerators G
		--JOIN CurtailmentGeneration CG
		--	ON G.MtGenerator_Id = CG.MtGenerator_Id
		--WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
		--AND G.LuEnergyResourceType_Code = 'NDP'


		--/**************************************************************************************************************
		--************************************* Calculate Energy Estimated              *********************************
		--**************************************************************************************************************/

		--UPDATE MtFCDGenerators
		--SET MtFCDGenerators_EnergyEstimated
		--= MtGenerator_TotalInstalledCapacity * MtFCDGenerators_EAFactor * MtFCDGenerators_CountNonExistenceHours
		--WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		--AND LuEnergyResourceType_Code = 'NDP';

		--/**************************************************************************************************************
		--************************************* Calculate Initial Firm Capacity         *********************************
		--**************************************************************************************************************/

		--WITH CountFCDGenerationRows
		--AS
		--(SELECT
		--		MtGenerator_Id
		--	   ,COUNT(1) AS totalrows
		--	FROM MtFCDHourlyData
		--	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		--	GROUP BY MtGenerator_Id)

		--UPDATE FG
		--SET MtFCDGenerators_InitialFirmCapacity = (
		--FG.MtFCDGenerators_TotalGeneration
		--- ISNULL(FG.MtFCDGenerators_EnergyGeneratedDuringCurtailment,0)
		--+ ISNULL(FG.MtFCDGenerators_SoForecastDuringCurtailment,0)
		--+ ISNULL(FG.MtFCDGenerators_EnergyEstimated, 0))
		--/ FGR.totalrows
		--FROM MtFCDGenerators FG
		--JOIN CountFCDGenerationRows FGR
		--	ON FG.MtGenerator_Id = FGR.MtGenerator_Id
		--WHERE FG.MtFCDMaster_Id = @pMtFCDMaster_Id
		--AND FG.LuEnergyResourceType_Code = 'NDP';

		/**************************************************************************************************************/
		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 1
										  ,@pStatus = 2
										  ,@pMessage = 'Firm Capacity Determination Step 1: Non-Dispatchable Plants completed'
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1
		/**************************************************************************************************************
		*************************************    For NON Dispachable                  *********************************
		**************************************************************************************************************/
		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 2
										  ,@pStatus = 1
										  ,@pMessage = 'Firm Capacity Determination Step 2: Dispatchable Plants started'
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1
		/**************************************************************************************************************/
		UPDATE MtFCDGenerators
		SET MtFCDGenerators_InitialFirmCapacity = ADCValue * (1 - GeneratorFOR/100)
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		AND LuEnergyResourceType_Code = 'DP'

		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 2
										  ,@pStatus = 2
										  ,@pMessage = 'Firm Capacity Determination Step 2: Dispatchable Plants completed'
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1
		/**************************************************************************************************************/
		--EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
		--								  ,@pStepNo = 3
		--								  ,@pStatus = 1
		--								  ,@pMessage = 'Firm Capacity Determination Step 3: Prepare Output started'
		--								  ,@pUserId = @pUserId
		--								  ,@pSrFCDProcessDef_Id=1
		/**************************************************************************************************************/
		--EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
		--								  ,@pStepNo = 3
		--								  ,@pStatus = 2
		--								  ,@pMessage = 'Firm Capacity Determination Step 3: Prepare Output completed'
		--								  ,@pUserId = @pUserId
		--								  ,@pSrFCDProcessDef_Id=1
		/**************************************************************************************************************/

		-- Set Execution status to 'Executed'      
		UPDATE MtFCDMaster
		SET MtFCDMaster_ProcessStatus = 'Executed'
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id

	END TRY
	BEGIN CATCH
		--interrupted state    
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();

		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 0
										  ,@pStatus = 3
										  ,@pMessage = @vErrorMessage
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1

		UPDATE MtFCDMaster
		SET MtFCDMaster_ProcessStatus = 'Interrupted'
		   ,MtFCDMaster_ApprovalStatus = 'Draft'
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id



		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH


END

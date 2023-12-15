/****** Object:  Procedure [dbo].[FCD_Execution]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================        
-- Author:  Ali Imran      
-- CREATE date: 15 March 2023      
-- ALTER date:       
-- Description:       
-- =================================================================================       
-- [FCD_Execution] @pMtFCDMaster_Id=40,@pUserId=1      
CREATE   Procedure dbo.FCD_Execution @pMtFCDMaster_Id DECIMAL(18, 0)
, @pUserId INT
AS
BEGIN
	UPDATE MtFCDMaster
	SET MtFCDMaster_ProcessStatus = 'InProcess'
	   ,MtFCDMaster_ExecutionStartDate = GETDATE()
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id

	BEGIN TRY
		/***************************************************************************  
	      Logs section  
	    ****************************************************************************/
		DECLARE @output VARCHAR(MAX);
		SET @output = 'Process Execution Started: ' + CAST(@pMtFCDMaster_Id AS VARCHAR(10)) + ' Process ID. Period: ' + (SELECT
				LuAccountingMonth_MonthName
			FROM MtFCDMaster fcd
			INNER JOIN LuAccountingMonth AM
				ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)

		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Determination'
							   ,@CrudOperationName = 'Update'
							   ,@logMessage = @output


		/***************************************************************************  
	      Logs section  
	    ****************************************************************************/



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

		BEGIN TRY
			EXECUTE [FCD_PreValidation] @pMtFCDMaster_Id = @pMtFCDMaster_Id
									   ,@pUserId = @pUserId

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

			/***************************************************************************  
		   Logs section  
		 ****************************************************************************/

			SET @output = 'Process Execution Interrupted: ' + CAST(@pMtFCDMaster_Id AS VARCHAR(10)) + ' Process ID. Period: ' + (SELECT
					LuAccountingMonth_MonthName
				FROM MtFCDMaster fcd
				INNER JOIN LuAccountingMonth AM
					ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
				WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)

			EXEC [dbo].[SystemLogs] @user = @pUserId
								   ,@moduleName = 'Firm Capacity Determination'
								   ,@CrudOperationName = 'Update'
								   ,@logMessage = @output


			/***************************************************************************  
		      Logs section  
		    ****************************************************************************/



			RAISERROR (@vErrorMessage, 16, -1);
			RETURN;
		END CATCH

		/*  IF EXISTS (SELECT      
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
	      */
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
		UPDATE Hourly
		SET Hourly.[MtFCDHourlyData_Calculation] =

		CASE
			WHEN DATEFROMPARTS(Hourly.MtFCDHourlyData_Year, Hourly.MtFCDHourlyData_Month, Hourly.MtFCDHourlyData_Day) < G.COD_Date THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor

			-- when Hourly.[MtFCDHourlyData_Generation]>=0       
			--and ISNULL(Hourly.[MtFCDHourlyData_Curtailment],0)=0       
			--Then Hourly.[MtFCDHourlyData_Generation]     


			WHEN Hourly.[MtFCDHourlyData_Generation] >= 0 AND
				Hourly.[MtFCDHourlyData_Curtailment] > 0 AND
				Hourly.[MtFCDHourlyData_SOForecast] IS NULL THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor


			WHEN
				(
				--Hourly.[MtFCDHourlyData_Curtailment]>0   OR    
				Hourly.[MtFCDHourlyData_Curtailment] < Gen.MtGenerator_TotalInstalledCapacity OR
				Hourly.[MtFCDHourlyData_Curtailment] <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))
				) AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) >= 0 AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) < Gen.MtGenerator_TotalInstalledCapacity--(Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))    

			THEN Hourly.[MtFCDHourlyData_SOForecast]

			WHEN
				(
				-- Hourly.[MtFCDHourlyData_Curtailment]>0   OR    
				Hourly.[MtFCDHourlyData_Curtailment] < Gen.MtGenerator_TotalInstalledCapacity OR
				Hourly.[MtFCDHourlyData_Curtailment] <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))
				) AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) > (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor

			WHEN
				(
				--Hourly.[MtFCDHourlyData_Curtailment]>0   OR    
				Hourly.[MtFCDHourlyData_Curtailment] < Gen.MtGenerator_TotalInstalledCapacity OR
				Hourly.[MtFCDHourlyData_Curtailment] <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))
				) AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) < (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) THEN Gen.MtGenerator_TotalInstalledCapacity

			WHEN Hourly.[MtFCDHourlyData_Generation] IS NULL AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor

			-----1. (generation)If Generation is less than or equal to Installed Net Capacity Then use Generation---    
			WHEN Hourly.[MtFCDHourlyData_Generation] <= Gen.MtGenerator_TotalInstalledCapacity AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Hourly.[MtFCDHourlyData_Generation]

			----2. If Generation is greater than installed Net Capacity upto 5%  Then use Installed Net Capacity    
			WHEN Hourly.[MtFCDHourlyData_Generation] > Gen.MtGenerator_TotalInstalledCapacity AND
				Hourly.[MtFCDHourlyData_Generation] <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Gen.MtGenerator_TotalInstalledCapacity

			-----3. If Generation is greater than installed Net Capacity above 5% Then use Installed Net Capacity * Factor    
			WHEN Hourly.[MtFCDHourlyData_Generation] > (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor

			----1. (Curtailment)If Curtailment is less than or equal to Installed Net Capacity Then use Curtailment    
			WHEN Hourly.[MtFCDHourlyData_Curtailment] <= Gen.MtGenerator_TotalInstalledCapacity AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) >= 0 AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) >= Gen.MtGenerator_TotalInstalledCapacity AND
				ISNULL(Hourly.[MtFCDHourlyData_SOForecast], 0) <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) THEN Gen.MtGenerator_TotalInstalledCapacity

			--   when  Hourly.[MtFCDHourlyData_Curtailment] <= Gen.MtGenerator_TotalInstalledCapacity      
			-- and isnull(Hourly.[MtFCDHourlyData_SOForecast],0)>=0      
			---- AND   isnull(Hourly.[MtFCDHourlyData_SOForecast],0) >= Gen.MtGenerator_TotalInstalledCapacity     
			-- AND  isnull(Hourly.[MtFCDHourlyData_SOForecast],0) >= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))    
			-- then     


			----2. If Curtailment is greater than installed Net Capacity upto 5%  Then use Installed Net Capacity    
			-- when  Hourly.[MtFCDHourlyData_Curtailment] > Gen.MtGenerator_TotalInstalledCapacity    
			--  AND Hourly.[MtFCDHourlyData_Curtailment] <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))    

			--then Gen.MtGenerator_TotalInstalledCapacity    

			----3.If Curtailment is greater than installed Net Capacity above 5% Then use Installed Net Capacity * Factor    
			WHEN Hourly.[MtFCDHourlyData_Curtailment] > (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05))
			--AND ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0    
			THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor

			-------Forecast------    
			---1. If Forecast is less than or equal to Installed Net Capacity Then use Forecast    
			WHEN Hourly.MtFCDHourlyData_SOForecast <= Gen.MtGenerator_TotalInstalledCapacity AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Hourly.[MtFCDHourlyData_Generation]
			----2.If Forecast is greater than installed Net Capacity upto 5%  Then use Installed Net Capacity    
			WHEN Hourly.MtFCDHourlyData_SOForecast > Gen.MtGenerator_TotalInstalledCapacity AND
				Hourly.MtFCDHourlyData_SOForecast <= (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Gen.MtGenerator_TotalInstalledCapacity

			----3.If Forecast is greater than installed Net Capacity above 5% Then use Installed Net Capacity * Factor    
			WHEN Hourly.MtFCDHourlyData_SOForecast > (Gen.MtGenerator_TotalInstalledCapacity + (Gen.MtGenerator_TotalInstalledCapacity * 0.05)) AND
				ISNULL(Hourly.[MtFCDHourlyData_Curtailment], 0) = 0 THEN Gen.MtGenerator_TotalInstalledCapacity * Gen.MtFCDGenerators_EAFactor
		END
		FROM MtFCDHourlyData Hourly
		INNER JOIN MtFCDGenerators Gen
			ON Gen.MtGenerator_Id = Hourly.MtGenerator_Id
		INNER JOIN Mtgenerator G
			ON G.MtGenerator_Id = Gen.MtGenerator_Id
			AND Gen.MtFCDMaster_Id = @pMtFCDMaster_Id
		WHERE Hourly.MtFCDMaster_Id = @pMtFCDMaster_Id
		AND ISNULL(G.isDeleted, 0) = 0
		AND ISNULL(G.MtGenerator_IsDeleted, 0) = 0;

		/******************************************************************      
	       Calculate IFC based on Calculation column      
	       ******************************************************************/
		UPDATE FCD
		SET FCD.MtFCDGenerators_InitialFirmCapacity = SumFCD.TotalCalculations / SumFCD.TotalHours
		FROM MtFCDGenerators FCD
		JOIN (SELECT
				MtGenerator_Id
			   ,COUNT(1) AS TotalHours
			   ,SUM(MtFCDHourlyData_Calculation) AS TotalCalculations
			FROM MtFCDHourlyData
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
			GROUP BY MtGenerator_Id) AS SumFCD
			ON SumFCD.MtGenerator_Id = FCD.MtGenerator_Id
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		;

		--return;      
		--return;      
		--/**************************************************************************************************************      
		--*************************************      MtFCDGenerators   **************************************************      
		--**************************************************************************************************************/      

		--WITH _GenTotalGenerater      
		--AS      
		--(SELECT      
		--  MtGenerator_Id      
		--    ,SUM(ISNULL(MtFCDHourlyData_Generation, 0)) AS GenerationSum      
		-- FROM [MtFCDHourlyData] mf      
		-- WHERE mf.MtFCDMaster_Id = @pMtFCDMaster_Id      
		-- GROUP BY MtGenerator_Id)      

		--UPDATE G      
		--SET G.MtFCDGenerators_TotalGeneration =      
		--HG.GenerationSum      
		--FROM MtFCDGenerators G      
		--JOIN _GenTotalGenerater HG      
		-- ON G.MtGenerator_Id = HG.MtGenerator_Id      
		--WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id      
		--AND G.LuEnergyResourceType_Code = 'NDP'      


		--/**************************************************************************************************************      
		--*************************************      Count zero Generations hours  **************************************      
		--**************************************************************************************************************/      
		--;      
		--WITH withZeroGeneration      
		--AS      
		--(SELECT      
		--  G.MtGenerator_Id      
		--    ,COUNT(HD.MtFCDHourlyData_Generation) AS ZeroGenerationCount      
		-- FROM MtFCDGenerators G      
		-- LEFT JOIN MtFCDHourlyData HD      
		--  ON HD.MtGenerator_Id = G.MtGenerator_Id      
		--  AND HD.MtFCDHourlyData_Generation < 1      
		--  AND HD.MtFCDHourlyData_Curtailment<1      
		--  AND HD.MtFCDHourlyData_SOForecast<1      
		-- WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id      
		-- AND G.LuEnergyResourceType_Code = 'NDP'      
		-- GROUP BY G.MtGenerator_Id)      

		--UPDATE G      
		--SET MtFCDGenerators_CountNonExistenceHours = ZG.ZeroGenerationCount      
		--FROM MtFCDGenerators G      
		--JOIN withZeroGeneration ZG      
		-- ON G.MtGenerator_Id = ZG.MtGenerator_Id      
		--WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id      
		--AND G.LuEnergyResourceType_Code = 'NDP'      
		--;      
		--/**************************************************************************************************************      
		--*************************************   Energy  Generated during Curtailment  *********************************      
		--**************************************************************************************************************/      

		--WITH CurtailmentGeneration      
		--AS      
		--(SELECT      
		--  G.MtGenerator_Id      
		--    ,SUM(HD.MtFCDHourlyData_Generation) AS EnergyGeneratedDuringCurtailment      
		--    ,SUM(HD.MtFCDHourlyData_SOForecast) AS SOForecastDuringCurtailment      
		-- FROM MtFCDGenerators G      
		-- LEFT JOIN MtFCDHourlyData HD      
		--  ON HD.MtGenerator_Id = G.MtGenerator_Id      
		--  AND HD.MtFCDHourlyData_Curtailment > 0      
		-- WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id      
		-- GROUP BY G.MtGenerator_Id)      


		--UPDATE G      
		--SET G.MtFCDGenerators_EnergyGeneratedDuringCurtailment = CG.EnergyGeneratedDuringCurtailment      
		--   ,G.MtFCDGenerators_SoForecastDuringCurtailment = CG.SOForecastDuringCurtailment      
		--FROM MtFCDGenerators G      
		--JOIN CurtailmentGeneration CG      
		-- ON G.MtGenerator_Id = CG.MtGenerator_Id      
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
		--  MtGenerator_Id      
		--    ,COUNT(1) AS totalrows      
		-- FROM MtFCDHourlyData      
		-- WHERE MtFCDMaster_Id = @pMtFCDMaster_Id      
		-- GROUP BY MtGenerator_Id)      

		--UPDATE FG      
		--SET MtFCDGenerators_InitialFirmCapacity = (      
		--FG.MtFCDGenerators_TotalGeneration      
		--- ISNULL(FG.MtFCDGenerators_EnergyGeneratedDuringCurtailment,0)      
		--+ ISNULL(FG.MtFCDGenerators_SoForecastDuringCurtailment,0)      
		--+ ISNULL(FG.MtFCDGenerators_EnergyEstimated, 0))      
		--/ FGR.totalrows      
		--FROM MtFCDGenerators FG      
		--JOIN CountFCDGenerationRows FGR      
		-- ON FG.MtGenerator_Id = FGR.MtGenerator_Id      
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
		SET MtFCDGenerators_InitialFirmCapacity = ADCValue * (1 - GeneratorFOR / 100)
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
		--          ,@pStepNo = 3      
		--          ,@pStatus = 1      
		--          ,@pMessage = 'Firm Capacity Determination Step 3: Prepare Output started'      
		--          ,@pUserId = @pUserId      
		--          ,@pSrFCDProcessDef_Id=1      
		/**************************************************************************************************************/
		--EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id      
		--          ,@pStepNo = 3      
		--          ,@pStatus = 2      
		--          ,@pMessage = 'Firm Capacity Determination Step 3: Prepare Output completed'      
		--          ,@pUserId = @pUserId      
		--          ,@pSrFCDProcessDef_Id=1      
		/**************************************************************************************************************/

		-- Set Execution status to 'Executed'            
		UPDATE MtFCDMaster
		SET MtFCDMaster_ProcessStatus = 'Executed'
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id


		/***************************************************************************  
	   Logs section  
	  ****************************************************************************/

		SET @output = 'Process Execution Completed: ' + CAST(@pMtFCDMaster_Id AS VARCHAR(10)) + ' Process ID. Period: ' + (SELECT
				LuAccountingMonth_MonthName
			FROM MtFCDMaster fcd
			INNER JOIN LuAccountingMonth AM
				ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)

		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Determination'
							   ,@CrudOperationName = 'Update'
							   ,@logMessage = @output


	/***************************************************************************  
      Logs section  
    ****************************************************************************/

	END TRY
	BEGIN CATCH
		--interrupted state          
		--  DECLARE @vErrorMessage VARCHAR(MAX) = '';      
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


		/***************************************************************************  
	   Logs section  
	  ****************************************************************************/

		SET @output = 'Process Execution Interrupted: ' + CAST(@pMtFCDMaster_Id AS VARCHAR(10)) + ' Process ID. Period: ' + (SELECT
				LuAccountingMonth_MonthName
			FROM MtFCDMaster fcd
			INNER JOIN LuAccountingMonth AM
				ON fcd.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)

		EXEC [dbo].[SystemLogs] @user = @pUserId
							   ,@moduleName = 'Firm Capacity Determination'
							   ,@CrudOperationName = 'Update'
							   ,@logMessage = @output


		/***************************************************************************  
	      Logs section  
	    ****************************************************************************/

		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH


END

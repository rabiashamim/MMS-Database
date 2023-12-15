/****** Object:  Procedure [dbo].[FCD_PreValidation]    Committed by VersionSQL https://www.versionsql.com ******/

-- ================================================================================      
-- Author:  Ali Imran    
-- CREATE date: 15 March 2023    
-- ALTER date:     
-- Description:     
-- =================================================================================     
-- [FCD_PreValidation] @pMtFCDMaster_Id=393,@pUserId=1    
CREATE   PROCEDUREdbo.FCD_PreValidation @pMtFCDMaster_Id DECIMAL(18, 0)    
, @pUserId INT    
AS    
BEGIN    
    
    
 /**************************************************************************************************************    
 *************************************   Equivalent Availability Factors   ********************************    
 **************************************************************************************************************/    
 ;    
 WITH GetEAF    
 AS    
 (SELECT DISTINCT    
   FG.MtGenerator_Id    
     ,GU.SrFuelType_Code    
     ,EAF.LuEquivalentAvailabilityFactors_Value AS Factor    
  FROM MtFCDGenerators FG    
  JOIN MtGenerationUnit GU    
   ON FG.MtGenerator_Id = GU.MtGenerator_Id    
  JOIN LuEquivalentAvailabilityFactors EAF    
   ON EAF.SrFuelType_Code = GU.SrFuelType_Code    
  WHERE MtFCDMaster_Id = @pMtFCDMaster_Id    
  AND FG.LuEnergyResourceType_Code = 'NDP'    
    and ISNULL(GU.isDeleted,0)=0    
    and ISNULL(GU.MtGenerationUnit_IsDeleted,0)=0    
    )    
    
 UPDATE FG    
 SET FG.MtFCDGenerators_EAFactor = EAF.Factor    
 FROM MtFCDGenerators FG    
 JOIN GetEAF EAF    
  ON EAF.MtGenerator_Id = FG.MtGenerator_Id    
 WHERE MtFCDMaster_Id = @pMtFCDMaster_Id    
 AND FG.LuEnergyResourceType_Code = 'NDP';    
    
 /**************************************************************************************************************    
 *************************************  validation for EAF   ***************************************************    
 **************************************************************************************************************/    
 IF EXISTS(SELECT     
  MtGenerator_Id,MtFCDGenerators_EAFactor     
 FROM     
  MtFCDGenerators     
 WHERE     
  MtFCDMaster_Id=@pMtFCDMaster_Id    
  AND  LuEnergyResourceType_Code='NDP'    
  AND ISNULL(MtFCDGenerators_EAFactor,0)=0)    
  BEGIN    
   RAISERROR ('Equivalent Availability Factors (EAF) not find. ', 16, -1);    
   RETURN;    
  END    
     
    
  /**************************************************************************************************************/    
  DECLARE @vFromDate DATETime    
     ,@vToDate DATETime;    
 SELECT    
  @vFromDate = LuAccountingMonth_FromDate    
    ,@vToDate = LuAccountingMonth_ToDate    
 FROM LuAccountingMonth    
 WHERE LuAccountingMonth_Id = (SELECT    
   LuAccountingMonth_Id    
  FROM MtFCDMaster    
  WHERE MtFCDMaster_Id = @pMtFCDMaster_Id);    
  
  
   /**************************************************************************************************************    
   Future Generator Scenario   for non dispachable case                
   **************************************************************************************************************/   

SELECT
	FCD.MtFCDMaster_Id
   ,G.MtGenerator_Id
   ,G.LuEnergyResourceType_Code
   ,G.MtGenerator_TotalInstalledCapacity
   ,MG.COD_Date
   ,LAU.LuAccountingMonth_ToDate INTO #FutureGenerator
FROM MtFCDMaster FCD
JOIN MtFCDGenerators G
	ON FCD.MtFCDMaster_Id = G.MtFCDMaster_Id
JOIN MtGenerator MG
	ON MG.MtGenerator_Id = G.MtGenerator_Id
JOIN LuAccountingMonth LAU
	ON LAU.LuAccountingMonth_Id = FCD.LuAccountingMonth_Id
WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
AND G.LuEnergyResourceType_Code = 'NDP'
AND MG.COD_Date > LAU.LuAccountingMonth_ToDate

IF EXISTS (SELECT TOP 1
			1
		FROM #FutureGenerator)
BEGIN

	UPDATE G
	SET G.MtFCDGenerators_InitialFirmCapacity = FG.MtGenerator_TotalInstalledCapacity*G.MtFCDGenerators_EAFactor
	FROM #FutureGenerator FG
	JOIN MtFCDGenerators G
		ON G.MtFCDMaster_Id = FG.MtFCDMaster_Id
	WHERE G.MtFCDMaster_Id = @pMtFCDMaster_Id
	RETURN;
END

 /**************************************************************************************************************    
 Fetch ADC Value,    
 if more then one ADC value of Generator than pick the latest one                     
 **************************************************************************************************************/    
     
 ;    
 WITH _MaxDateADCValue    
 AS    
 (SELECT    
   A.MtGenerator_Id    
     ,A.MtAnnualDependableCapacityADC_Value    
  FROM MtAnnualDependableCapacityADC A    
  JOIN (SELECT    
    FCD.MtGenerator_Id    
      ,MAX(ADC.MtAnnualDependableCapacityADC_Date) AS ADC_Date    
   FROM MtAnnualDependableCapacityADC ADC    
   JOIN MtFCDGenerators FCD    
    ON ADC.MtGenerator_Id = FCD.MtGenerator_Id    
   WHERE MtFCDMaster_Id = @pMtFCDMaster_Id    
   AND FCD.MtFCDGenerators_IsDeleted = 0    
   AND ADC.MtAnnualDependableCapacityADC_IsDeleted = 0    
   --AND ADC.MtAnnualDependableCapacityADC_Date BETWEEN @vFromDate AND @vToDate    
   GROUP BY FCD.MtGenerator_Id) AS AD    
   ON A.MtGenerator_Id = AD.MtGenerator_Id    
   AND A.MtAnnualDependableCapacityADC_Date = AD.ADC_Date    
  WHERE A.MtAnnualDependableCapacityADC_IsDeleted = 0)    
    
 UPDATE FG    
 SET FG.ADCValue = ISNULL(ADC.MtAnnualDependableCapacityADC_Value,FG.MtGenerator_TotalInstalledCapacity)    
    
 FROM MtFCDGenerators FG    
 LEFT JOIN _MaxDateADCValue ADC    
  ON ADC.MtGenerator_Id = FG.MtGenerator_Id    
 WHERE FG.MtFCDMaster_Id = @pMtFCDMaster_Id    
    
 SELECT    
  FG.MtGenerator_Id INTO #withoutFCD    
 FROM MtFCDGenerators FG    
 WHERE FG.MtFCDMaster_Id = @pMtFCDMaster_Id    
 AND FG.LuEnergyResourceType_Code = 'DP'    
 AND ISNULL(FG.ADCValue, 0) = 0    
  
 declare @withoutFCD varchar(2000),@perror_Message varchar(2000)  
        SET @withoutFCD = STUFF((SELECT distinct ',' + convert(varchar(2000),MtGenerator_Id  )  
            FROM #withoutFCD     
            FOR XML PATH(''), TYPE    
            ).value('.', 'NVARCHAR(MAX)')     
        ,1,1,'')


IF EXISTS (SELECT TOP 1
			1
		FROM #withoutFCD)
BEGIN
	SET @perror_Message = 'ADC value not found for generators ' + @withoutFCD
	EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
									  ,@pStepNo = 0
									  ,@pStatus = 3
									  ,@pMessage = @perror_Message
									  ,@pUserId = @pUserId
									  ,@pSrFCDProcessDef_Id = 1
	RAISERROR (@perror_Message, 16, -1);
	RETURN;
END
/***************************************************************************************    
*************** 1. Get Curtailment and Forecast last 3 years data *****************    
****************************************************************************************/

--DECLARE @vERT VARCHAR(4)    
--SELECT @vERT=LuEnergyResourceType_Code FROM MtFCDGenerators WHERE MtFCDMaster_Id=@pMtFCDMaster_Id    

--IF(@vERT='NDP')    
DECLARE @vERT AS INT = 0;
SELECT
	@vERT = COUNT(1)
FROM MtFCDGenerators
WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
AND LuEnergyResourceType_Code = 'NDP'

IF (@vERT > 0)
BEGIN

	/***************************************************************************************    
    now pick files from Data managment having template id=13 and last 3     
    fiscal years and if multiple files on same year than pick the latest one     
    ****************************************************************************************/

	;
	WITH cte_Last3Years
	AS
	(SELECT
			LuAccountingMonth_Id
		FROM LuAccountingMonth
		WHERE PeriodTypeID = 3
		AND LuAccountingMonth_IsDeleted = 0
		AND DATEPART(YEAR, LuAccountingMonth_FromDate) <= DATEPART(YEAR, @vFromDate)
		AND DATEPART(YEAR, LuAccountingMonth_FromDate) >= DATEPART(YEAR, @vFromDate) - 2)


	/***************************************************************************************    
    ***************  last 3 years curtailmemtn and forecast data  *****************    
    ****************************************************************************************/

	SELECT
		MAX(MtSOFileMaster_Id) AS MtSOFileMaster_Id INTO #Last3yearsForcastAndCurtailmentIds
	FROM MtSOFileMaster
	WHERE LuSOFileTemplate_Id = 13
	AND MtSOFileMaster_IsUseForSettlement = 1
	AND ISNULL(MtSOFileMaster_IsDeleted, 0) = 0
	AND LuAccountingMonth_Id IN (SELECT
			LuAccountingMonth_Id
		FROM cte_Last3Years)
	GROUP BY LuAccountingMonth_Id;

	/**********************************************  
    Specify hours for which data is missing  
    ***************************************************/

	--  select count (1) from ;  
	/***************************************************************************************    
    ****************************************************************************************/

	IF NOT EXISTS (SELECT
				1
			FROM #Last3yearsForcastAndCurtailmentIds
			HAVING COUNT(1) = 3)
	BEGIN
		RAISERROR ('3 years data not found for : Forecast and Curtailment Data non-dispatchable ', 16, -1);
		RETURN;
	END

	/***************************************************************************************    
    ***************  GetCurtailment and forecast data  *****************    
    ****************************************************************************************/
	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [MtFCDGenerationCurtailmentForecastHourlyData]
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)
	BEGIN


		SELECT
			@pMtFCDMaster_Id AS FCDMasterId
		   ,MtGenerator_Id
		   ,DATEPART(YEAR, MTGenForcastAndCurtailment_Date) AS [year]
		   ,DATEPART(MONTH, MTGenForcastAndCurtailment_Date) AS [Month]
		   ,DATEPART(DAY, MTGenForcastAndCurtailment_Date) AS [Day]
		   ,MTGenForcastAndCurtailment_Hour AS [Hour]
		   ,MTGenForcastAndCurtailment_Curtailemnt_MW AS Curtailment
		   ,MTGenForcastAndCurtailment_Forecast_MW AS SoForecast INTO #tempMTGenForcastAndCurtailment
		FROM MtGenForcastAndCurtailment
		WHERE MtGenerator_Id IN (SELECT DISTINCT
				MtGenerator_Id
			FROM MtFCDGenerators
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
			AND ISNULL(MtFCDGenerators_IsDeleted, 0) = 0
		-- AND (SELECT
		--	COD_Date
		--FROM MtGenerator
		--WHERE MtGenerator_Id = MtGenerator_Id
		--AND ISNULL(MtGenerator_IsDeleted, 0) = 0)<=GETUTCDATE()
		)
		AND MtSOFileMaster_Id IN (SELECT
				MtSOFileMaster_Id
			FROM #Last3yearsForcastAndCurtailmentIds)
		AND DATEPART(MONTH, MTGenForcastAndCurtailment_Date)
		IN (SELECT
				value
			FROM STRING_SPLIT((SELECT
					RuGlobalSetting_value
				FROM RuGlobalSetting
				WHERE RuGlobalSetting_Key = 'FCD_Months')
			, ','))

		AND MTGenForcastAndCurtailment_Hour
		IN (SELECT
				value
			FROM STRING_SPLIT((SELECT
					RuGlobalSetting_value
				FROM RuGlobalSetting
				WHERE RuGlobalSetting_Key = 'FCD_Hours')
			, ','))
		AND ISNULL(MTGenForcastAndCurtailment_IsDeleted, 0) = 0
/**************************************************************************************************
--todo: ignore when COD is future date.
***************************************************************************************************/
		

			IF NOT EXISTS (SELECT TOP 1
						1
					FROM #tempMTGenForcastAndCurtailment)
			BEGIN
				RAISERROR ('No data exists for Generation Forecast and Curtailment ', 16, -1);
				RETURN;

			END
		

/**************************************************************************************************

***************************************************************************************************/
		INSERT INTO [dbo].[MtFCDGenerationCurtailmentForecastHourlyData] (MtFCDMaster_Id
		, [MtGenerator_Id]
		, [MtFCDGenerationCurtailmentForecastHourlyData_year]
		, [MtFCDGenerationCurtailmentForecastHourlyData_Month]
		, [MtFCDGenerationCurtailmentForecastHourlyData_Day]
		, [MtFCDGenerationCurtailmentForecastHourlyData_Hour]
		, [MtFCDGenerationCurtailmentForecastHourlyData_Curtailment]
		, [MtFCDGenerationCurtailmentForecastHourlyData_SoForecast])


			SELECT
				FCDMasterId
			   ,MtGenerator_Id
			   ,[Year]
			   ,[month]
			   ,[day]
			   ,[hour]
			   ,Curtailment
			   ,SoForecast
			FROM #tempMTGenForcastAndCurtailment

	END

	/*******************************************************  
   Compose temp table containing all hours of 3 years  
   ************************************************************/
	DROP TABLE IF EXISTS #TempHours;
	DROP TABLE IF EXISTS #TempHoursGenerators;

	CREATE TABLE #TempHoursGenerators (
		dateTimeHour DATETIME NULL
	   ,GeneratorId DECIMAL(18, 0)
	);


	DECLARE @INC_Hour AS INT = 1;

	WITH ROWCTE
	AS
	(SELECT
			@vFromDate AS dateTimeHour
		UNION ALL
		SELECT
			DATEADD(HOUR, @INC_Hour, dateTimeHour)
		FROM ROWCTE
		WHERE dateTimeHour < @vToDate)

	SELECT
		* INTO #TempHours
	FROM ROWCTE
	WHERE DATEPART(HOUR, dateTimeHour) IN (SELECT
			value
		FROM STRING_SPLIT((SELECT
				RuGlobalSetting_value
			FROM RuGlobalSetting
			WHERE RuGlobalSetting_Key = 'FCD_Hours')
		, ','))
	AND DATEPART(MONTH, dateTimeHour) IN (SELECT
			value
		FROM STRING_SPLIT((SELECT
				RuGlobalSetting_value
			FROM RuGlobalSetting
			WHERE RuGlobalSetting_Key = 'FCD_Months')
		, ','))
	OPTION (MAXRECURSION 0) --There is no way to perform a recursion more than 32767   
	;

	INSERT INTO #TempHoursGenerators
		SELECT DISTINCT
			dateTimeHour
		   ,M.MtGenerator_Id
		FROM #TempHours
			,[MtFCDGenerationCurtailmentForecastHourlyData] M
		WHERE M.MtFCDMaster_Id = @pMtFCDMaster_Id


	/***************************************************************************************    
    ***************  Get Generation data directly from table *****************    
    ****************************************************************************************/
	UPDATE HD
	SET HD.MtFCDGenerationCurtailmentForecastHourlyData_Generation = GD.MTGenerationFirmCapacityHourlyData_Generation
	FROM [MtFCDGenerationCurtailmentForecastHourlyData] HD
	JOIN MTGenerationFirmCapacityHourlyData GD
		ON HD.MtGenerator_Id = GD.MtGenerator_Id
		AND HD.MtFCDGenerationCurtailmentForecastHourlyData_year = GD.MTGenerationFirmCapacityHourlyData_year
		AND HD.MtFCDGenerationCurtailmentForecastHourlyData_Month = GD.MTGenerationFirmCapacityHourlyData_Month
		AND HD.MtFCDGenerationCurtailmentForecastHourlyData_Day = GD.MTGenerationFirmCapacityHourlyData_Day
		AND HD.MtFCDGenerationCurtailmentForecastHourlyData_Hour = GD.MTGenerationFirmCapacityHourlyData_Hour
	WHERE MtFCDMaster_Id = @pMtFCDMaster_Id;

	/* -- temp check added for dry run must remove.    
	 UPDATE [MtFCDGenerationCurtailmentForecastHourlyData]    
	 SET MtFCDGenerationCurtailmentForecastHourlyData_Generation=0    
	 WHERE MtFCDGenerationCurtailmentForecastHourlyData_Generation IS NULL    
	 AND MtFCDMaster_Id = @pMtFCDMaster_Id;    
	  */

	/***************************************************************************************    
    ****************************************************************************************/

	DROP TABLE IF EXISTS #validations
	CREATE TABLE #validations (
		GeneratorId DECIMAL(18, 0)
	   ,msg VARCHAR(MAX)
	   ,[status] BIT
	)
	/***************************************************************************************    
    *********** 1. Generation data for 3 years. for fiscal year must have 4 year ***********    
    ****************************************************************************************/
	INSERT INTO #validations
		SELECT

			MtGenerator_Id AS GeneratorId
		   ,'Generation(' + CAST(MtGenerator_Id AS VARCHAR(5)) + ')  data for 3 years' AS msg
		   ,CASE
				WHEN COUNT(DISTINCT MtFCDGenerationCurtailmentForecastHourlyData_year) = 4 THEN 1
				ELSE 0
			END AS [status]

		FROM [MtFCDGenerationCurtailmentForecastHourlyData]
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		GROUP BY MtGenerator_Id


	/*************************************************************  
  Print detail of day, month, hour missing in data  
  ***************************************************************/
	--  if exists(select 1 from #TempHours  
	--left  join [MtFCDGenerationCurtailmentForecastHourlyData]  
	--  on MtFCDGenerationCurtailmentForecastHourlyData_year=DATEPART(year,dateTimeHour)  
	--  and  MtFCDGenerationCurtailmentForecastHourlyData_month=DATEPART(month,dateTimeHour)  
	--  and   
	--   MtFCDGenerationCurtailmentForecastHourlyData_day=DATEPART(day,dateTimeHour)  
	--  and   
	--   MtFCDGenerationCurtailmentForecastHourlyData_hour=DATEPART(hour,dateTimeHour)  
	--  and  ( MtFCDMaster_Id = @pMtFCDMaster_Id or MtFCDMaster_Id is null)  

	--  where   
	--   MtFCDGenerationCurtailmentForecastHourlyData_year is NULL  
	--   )  

	--   BEGIN  
	INSERT INTO #validations

		SELECT
			GeneratorId
		   ,CONCAT('Data Missing for Generator (', GeneratorId, ') Day ',
			CONVERT(CHAR(20), dateTimeHour, 106), ' Hour ', DATEPART(HOUR, dateTimeHour), '.') -- COALESCE(cast(dateTimeHour as varchar(15)),' ;'))   
		   ,0 AS Status
		FROM #TempHoursGenerators
		LEFT JOIN [MtFCDGenerationCurtailmentForecastHourlyData]
			ON MtFCDGenerationCurtailmentForecastHourlyData_year = DATEPART(YEAR, dateTimeHour)
				AND MtFCDGenerationCurtailmentForecastHourlyData_Month = DATEPART(MONTH, dateTimeHour)
				AND MtFCDGenerationCurtailmentForecastHourlyData_Day = DATEPART(DAY, dateTimeHour)
				AND MtFCDGenerationCurtailmentForecastHourlyData_Hour = DATEPART(HOUR, dateTimeHour)
				AND MtFCDMaster_Id = @pMtFCDMaster_Id
				AND GeneratorId = MtGenerator_Id

		WHERE MtFCDGenerationCurtailmentForecastHourlyData_year IS NULL

	--select * from #validations  
	--  END  


	/***************************************************************************************    
    **********************2. Generater  must have 1342 entries per year.************************    
    ****************************************************************************************/
	INSERT INTO #validations
		SELECT
			MtGenerator_Id AS GeneratorId
		   ,'Generator(' + CAST(MtGenerator_Id AS VARCHAR(5)) + ') must have 4026 entries for 3 years' AS msg
		   ,CASE
				WHEN COUNT(1) = 4026 THEN 1
				ELSE 0
			END AS [status]

		FROM [MtFCDGenerationCurtailmentForecastHourlyData]
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
		GROUP BY MtGenerator_Id
	;


	/***************************************************************************************    
    ****************************************************************************************    
    ****************************************************************************************/
	DROP TABLE IF EXISTS #Curtailment_Generation_SoForcast;

	WITH GeneratorInstalledCapacity
	AS
	(SELECT DISTINCT
			GFCH.MtGenerator_Id
		   ,G.MtGenerator_NewInstalledCapacity /*G.MtGenerator_TotalInstalledCapacity*/ AS InstalledCapacity
		   ,G.MtGenerator_TotalInstalledCapacity AS InstalledNetCapacity
		FROM MtFCDGenerationCurtailmentForecastHourlyData GFCH
		JOIN MtGenerator G
			ON G.MtGenerator_Id = GFCH.MtGenerator_Id
		WHERE MtFCDMaster_Id = @pMtFCDMaster_Id)


	SELECT
		H.MtGenerator_Id AS GeneratorId
	   ,H.MtFCDGenerationCurtailmentForecastHourlyData_year AS [year]
	   ,H.MtFCDGenerationCurtailmentForecastHourlyData_Month AS [Month]
	   ,H.MtFCDGenerationCurtailmentForecastHourlyData_Day AS [Day]
	   ,H.MtFCDGenerationCurtailmentForecastHourlyData_Hour AS [Hour]
	   ,H.MtFCDGenerationCurtailmentForecastHourlyData_Generation
	   ,IC.InstalledCapacity
	   ,IC.InstalledNetCapacity
		--  ,CASE    
		-- WHEN --H.MtFCDGenerationCurtailmentForecastHourlyData_Generation IS NULL OR    
		-- isnull( H.MtFCDGenerationCurtailmentForecastHourlyData_Generation ,0)> Isnull(IC.InstalledCapacity,0) THEN 0    
		-- ELSE 1    
		--END AS [Generation_status]    
		--  ,CASE    
		-- WHEN-- H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment IS NULL OR    
		-- isnull( H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment,0) > isnull( IC.InstalledCapacity ,0) THEN 0    
		-- ELSE 1    
		--END AS [Curtailment_status]    
		--  ,CASE    
		-- WHEN --MtFCDGenerationCurtailmentForecastHourlyData_SoForecast IS NULL OR    
		-- isnull( H.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast,0) > isnull(IC.InstalledCapacity,0) THEN 0    
		-- ELSE 1    
		--END AS [SoForecast_status]
	   ,CASE
			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Generation, 0) <= ISNULL(IC.InstalledNetCapacity, 0)
			-- and ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment,0)=0   
			THEN H.MtFCDGenerationCurtailmentForecastHourlyData_Generation

			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Generation, 0) > ISNULL(IC.InstalledNetCapacity, 0) AND
				ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Generation, 0) <= (ISNULL(IC.InstalledNetCapacity, 0) + (ISNULL(IC.InstalledNetCapacity, 0) * 0.05))
			-- AND ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment,0)=0   
			THEN ISNULL(IC.InstalledNetCapacity, 0)

			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Generation, 0) > (ISNULL(IC.InstalledCapacity, 0) + (ISNULL(IC.InstalledCapacity, 0) * 0.05))
			--  AND ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment,0)=0  
			THEN ISNULL(IC.InstalledNetCapacity, 0) * ISNULL(FG.MtFCDGenerators_EAFactor, 0)
			ELSE 1
		END AS [Generation_status]
		------Curtailment-----
	   ,CASE
			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment, 0) <= ISNULL(IC.InstalledNetCapacity, 0)
			-- and ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast,0)=0   
			THEN H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment

			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment, 0) > ISNULL(IC.InstalledNetCapacity, 0) AND
				ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment, 0) <= (ISNULL(IC.InstalledNetCapacity, 0) + (ISNULL(IC.InstalledNetCapacity, 0) * 0.05))
			--  AND ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast,0)=0   
			THEN ISNULL(IC.InstalledNetCapacity, 0)

			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_Curtailment, 0) > (ISNULL(IC.InstalledNetCapacity, 0) + (ISNULL(IC.InstalledNetCapacity, 0) * 0.05))
			-- AND ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast,0)=0  
			THEN ISNULL(IC.InstalledNetCapacity, 0) * ISNULL(FG.MtFCDGenerators_EAFactor, 0)
			ELSE 1
		END AS [Curtailment_status]

		------Forecast-----
	   ,CASE
			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast, 0) <= ISNULL(IC.InstalledNetCapacity, 0)
			-- and ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_Generation,0)=0   
			THEN H.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast

			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast, 0) > ISNULL(IC.InstalledNetCapacity, 0) AND
				ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast, 0) <= (ISNULL(IC.InstalledNetCapacity, 0) + (ISNULL(IC.InstalledNetCapacity, 0) * 0.05))
			--  AND ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_Generation,0)=0   
			THEN ISNULL(IC.InstalledNetCapacity, 0)

			WHEN ISNULL(H.MtFCDGenerationCurtailmentForecastHourlyData_SoForecast, 0) > (ISNULL(IC.InstalledNetCapacity, 0) + (ISNULL(IC.InstalledNetCapacity, 0) * 0.05))
			--  AND ISNULL(h.MtFCDGenerationCurtailmentForecastHourlyData_Generation,0)=0  
			THEN ISNULL(IC.InstalledNetCapacity, 0) * ISNULL(FG.MtFCDGenerators_EAFactor, 0)

		END AS [SoForecast_status] INTO #Curtailment_Generation_SoForcast
	FROM [MtFCDGenerationCurtailmentForecastHourlyData] H
	JOIN GeneratorInstalledCapacity IC
		ON H.MtGenerator_Id = IC.MtGenerator_Id
	INNER JOIN MtFCDGenerators FG
		ON FG.MtFCDMaster_Id = H.MtFCDMaster_Id

	WHERE H.MtFCDMaster_Id = @pMtFCDMaster_Id

	/***************************************************************************************    
    **************3. Hourly generation is greater than installed capacity*******************    
    ****************************************************************************************/

	-- INSERT INTO #validations    
	--  SELECT    
	--   GeneratorId    
	--     ,'Generator Id: ' + CAST(GeneratorId AS VARCHAR(5)) + ', year ' + CAST(year AS VARCHAR(5)) + ', month ' + CAST(Month AS VARCHAR(5)) + ', day '    
	--   --+ CAST(Day AS VARCHAR(5)) + ', hour ' + CAST(Hour AS VARCHAR(5)) + ' ,NULL Value |Hourly generation is greater than installed capacity.' AS msg    
	--    + CAST(Day AS VARCHAR(5)) + ', hour ' + CAST(Hour AS VARCHAR(5)) 
	--	+', Generation '+Cast(CAST(MtFCDGenerationCurtailmentForecastHourlyData_Generation AS DECIMAL(15, 2)) as varchar(20))
	----	+', Installed Capacity '+Cast(CAST(InstalledCapacity AS DECIMAL(18, 2)) as varchar(20))
	--	+ ' , Hourly generation is greater than installed capacity.' AS msg    
	--	,0 AS [Status]    
	--  FROM #Curtailment_Generation_SoForcast    
	--  WHERE [Generation_status] = 0    


	/*   
     Commented after discussion with Sir Namet    
     Check comments on Bug 3081    
     Due to variation in Auxilary consumption, generation can be greater than installed capacity    
   */
	/***************************************************************************************    
    ****************4. Hourly curtailment is greater than installed capacity.***************    
    ****************************************************************************************/
	--INSERT INTO #validations    
	-- SELECT    
	--  GeneratorId    
	--    ,'Generator Id: ' + CAST(GeneratorId AS VARCHAR(5)) + ', year ' + CAST(year AS VARCHAR(5)) + ', month ' + CAST(Month AS VARCHAR(5)) + ', day '    
	--  + CAST(Day AS VARCHAR(5)) + ', hour ' + CAST(Hour AS VARCHAR(5)) + ' , Hourly curtailment is greater than installed capacity.' AS msg    
	--    ,0 AS [Status]    
	-- FROM #Curtailment_Generation_SoForcast    
	-- WHERE [Curtailment_status] = 0    
	/*
    Commented after discussion with Sir Namet    
    Check comments on Bug 3081    
    Due to variation in Auxilary consumption, generation can be greater than installed capacity    
    */
	/***************************************************************************************    
    ***************5. Hourly Forecast is greater than installed capacity.***********    
    --****************************************************************************************/
	--INSERT INTO #validations    
	-- SELECT    
	--  GeneratorId    
	--    ,'Generator Id: ' + CAST(GeneratorId AS VARCHAR(5)) + ', year ' + CAST(year AS VARCHAR(5)) + ', month ' + CAST(Month AS VARCHAR(5)) + ', day '    
	--  + CAST(Day AS VARCHAR(5)) + ', hour ' + CAST(Hour AS VARCHAR(5)) + ' , Hourly Forecast is greater than installed capacity.' AS msg    
	--    ,0 AS [Status]    
	-- FROM #Curtailment_Generation_SoForcast    
	-- WHERE [SoForecast_status] = 0    

	/* 
    Commented after discussion with Sir Namet    
    Check comments on Bug 3081    
    Due to variation in Auxilary consumption, generation can be greater than installed capacity    
    */


	/***************************************************************************************    
    ****************************************************************************************    
    ****************************************************************************************/

	--SELECT G.MtFCDGenerators_Id AS GeneratorId     
	--,GEN.COD_Date    
	--FROM     
	-- MtFCDGenerators G    
	--JOIN MtGenerator GEN ON GEN.MtGenerator_Id=G.MtFCDGenerators_Id    
	--WHERE     
	-- G.MtFCDMaster_Id=7    


	/***************************************************************************************    
    ****************************************************************************************    
    ****************************************************************************************/

	IF EXISTS (SELECT TOP 1
				1
			FROM #validations
			WHERE [status] = 0)
	BEGIN
		DECLARE @categories VARCHAR(200)
		SET @categories = 'Firm Capacity Determination Step 0: Validations Errors:'

		SELECT
			@categories = @categories + msg + ', '
		FROM #validations
		WHERE [status] = 0


		EXEC [dbo].[FCD_InsertProcessLogs] @pMtFCDMaster_Id = @pMtFCDMaster_Id
										  ,@pStepNo = 0
										  ,@pStatus = 3
										  ,@pMessage = @categories
										  ,@pUserId = @pUserId
										  ,@pSrFCDProcessDef_Id = 1
		--SELECT    
		-- @categories    

		RAISERROR (@categories, 16, -1);
		RETURN;
	END
END 
END

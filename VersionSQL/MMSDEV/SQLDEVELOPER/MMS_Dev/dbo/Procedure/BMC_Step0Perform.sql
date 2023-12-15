/****** Object:  Procedure [dbo].[BMC_Step0Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================        
-- Author:  Ammama Gill                          
-- CREATE date: Dec 20, 2022                           
-- ALTER date:                           
-- Reviewer:                          
-- Description: BMC Pre-execution Validations.                          
-- =============================================                           
-- =============================================                           
--  dbo.BMC_Step0Perform 102,2022,1

CREATE   PROCEDURE dbo.BMC_Step0Perform (@pStatementProcessId DECIMAL(18, 0),
@pUserId INT)

AS
BEGIN
	/*==========================================================================================    
       get the date range from Statement process IDs.    
       ==========================================================================================*/
	DECLARE @vEffectiveFrom DATE
		   ,@vEffectiveTo DATE;

	SELECT
		@vEffectiveFrom = lam.LuAccountingMonth_FromDate
	   ,@vEffectiveTo = lam.LuAccountingMonth_ToDate
	FROM MtStatementProcess msp
	INNER JOIN LuAccountingMonth lam
		ON msp.LuAccountingMonth_Id_Current = lam.LuAccountingMonth_Id
	WHERE msp.MtStatementProcess_ID = @pStatementProcessId

	CREATE TABLE #InvalidData (
		LOG_MESSAGE VARCHAR(MAX)
	   ,ERROR_LEVEL VARCHAR(MAX)
	);

	DECLARE @vsoFileMasterIdHourlyCap DECIMAL(18, 0) = 0
		   ,@vsofileMasterIdAvgCap DECIMAL(18, 0) = 0
		   ,@v50CriticalHours VARCHAR(MAX) = '';
	SELECT
		@vsoFileMasterIdHourlyCap = [dbo].[GetMtSoFileMasterId](@pStatementProcessId, 10);

	SELECT
		@vsofileMasterIdAvgCap = [dbo].[GetMtSoFileMasterId](@pStatementProcessId, 11);


	--1. Validate Critical Hours.  
	--a. Number of Critical Hours for the settlement period should be == 50.  

	SELECT
		@v50CriticalHours = @v50CriticalHours + ',' +
		mchc.MtCriticalHoursCapacity_SOUnitId
	FROM MtCriticalHoursCapacity mchc
	WHERE mchc.MtSOFileMaster_Id = @vsoFileMasterIdHourlyCap
	AND mchc.MtCriticalHoursCapacity_IsDeleted = 0
	GROUP BY mchc.MtCriticalHoursCapacity_SOUnitId
	HAVING COUNT(1) <> 50

	IF @v50CriticalHours <> ''
	BEGIN

		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			SELECT
				'Critical Hours for the settlement period should be 50: ' + @v50CriticalHours AS LOG_MESSAGE
			   ,'Warning' AS ERROR_LEVEL
	END

	--b. Critical Hours should be distinct.  
	DECLARE @vDistinctHours INT = 0;
	SELECT
		@vDistinctHours =
		COUNT(DISTINCT CONCAT(mchc.MtCriticalHoursCapacity_Date, MtCriticalHoursCapacity_Hour))
	FROM MtCriticalHoursCapacity mchc
	WHERE mchc.MtCriticalHoursCapacity_IsDeleted = 0
	AND mchc.MtSOFileMaster_Id = @vsoFileMasterIdHourlyCap
	--GROUP BY mchc.MtCriticalHoursCapacity_Date
	--		,mchc.MtCriticalHoursCapacity_Hour;

	IF @vDistinctHours <> 50
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Only 50 critical hours per settlement year are allowed. ', 'Warning');
	END

	DECLARE @vInvalidYear VARCHAR(MAX) = '';
	SELECT
		@vInvalidYear = @vInvalidYear + ',' + CAST(mchc.MtCriticalHoursCapacity_Date AS VARCHAR(MAX))
	FROM MtCriticalHoursCapacity mchc
	WHERE mchc.MtSOFileMaster_Id = @vsoFileMasterIdHourlyCap
	AND mchc.MtCriticalHoursCapacity_IsDeleted = 0
	AND mchc.MtCriticalHoursCapacity_Date NOT BETWEEN @vEffectiveFrom AND @vEffectiveTo;
	--AND DATEPART(YEAR, mchc.MtCriticalHoursCapacity_Date) <> @pYear;
	IF @vInvalidYear <> ''
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Critical date|hour combinations should be of relevant settlement year only: ' + @vInvalidYear, 'Warning');
	END

	-- c. There should be no more than 5 critical hours in a day.  
	DECLARE @v5CriticalHoursADay VARCHAR(MAX) = '';

	SELECT
		@v5CriticalHoursADay = @v5CriticalHoursADay + ','
		+ CAST(mchc.MtCriticalHoursCapacity_SOUnitId AS VARCHAR(MAX)) + '|' +
		CAST(mchc.MtCriticalHoursCapacity_Date AS VARCHAR(MAX))
	FROM MtCriticalHoursCapacity mchc
	WHERE mchc.MtSOFileMaster_Id = @vsoFileMasterIdHourlyCap
	AND mchc.MtCriticalHoursCapacity_IsDeleted = 0
	GROUP BY mchc.MtCriticalHoursCapacity_SOUnitId
			,mchc.MtCriticalHoursCapacity_Date
	HAVING COUNT(1) > 5

	IF @v5CriticalHoursADay <> ''
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('There cannot be more than 5 critical hours in a day: ' + @v5CriticalHoursADay, 'Warning');
	END



	--d. Check if both the files have equal no of sounit ids.
	DECLARE @vInvalidSOUnitIDs VARCHAR(MAX) = '';

	;
	WITH cte_SOUnitIDs
	AS
	(SELECT
		DISTINCT
			machc.MtAvgCriticalHoursCapacity_SOUnitId AS SOunitID
		FROM MtAvgCriticalHoursCapacity machc
		WHERE machc.MtSOFileMaster_Id = @vsofileMasterIdAvgCap
		UNION ALL
		SELECT
		DISTINCT
			mchc.MtCriticalHoursCapacity_SOUnitId AS SOunitID
		FROM MtCriticalHoursCapacity mchc
		WHERE mchc.MtSOFileMaster_Id = @vsoFileMasterIdHourlyCap)

	SELECT
		@vInvalidSOUnitIDs = @vInvalidSOUnitIDs + ',' + CAST(SOunitID AS VARCHAR(MAX))
	FROM cte_SOUnitIDs
	GROUP BY SOunitID
	HAVING COUNT(1) <> 2;

	IF @vInvalidSOUnitIDs <> ''
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Same generator units should be present in both critical hour capacity file and avg capacity file: ' + @vInvalidSOUnitIDs, 'Warning');
	END



	--3. Validations for Reference Values
	IF NOT EXISTS (SELECT
				*
			FROM RuReferenceValue rrv
			JOIN SrReferenceType srt1
				ON rrv.SrReferenceType_Id = srt1.SrReferenceType_Id
				AND rrv.RuReferenceValue_IsDeleted = 0
				AND srt1.SrReferenceType_IsDeleted = 0)
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Missing Reference Values.', 'Warning');

	END

	DECLARE @vRefValMessage VARCHAR(MAX) = '';

	SELECT
		@vRefValMessage =
		CASE
			WHEN (MAX(CASE
					WHEN (@vEffectiveFrom >=CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE) AND  @vEffectiveTo BETWEEN CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE) AND cast(ISNULL(rrv.RuReferenceValue_EffectiveTo, GETDATE()) AS DATE) AND
						ISNULL(srt.SrReferenceType_Name, '') = 'Reserve Margin') THEN 1
					ELSE 0
				END)) = 0 THEN 'Missing Reserve Margin value. '
			ELSE ''
		END
		+
		CASE
			WHEN (MAX(CASE
					WHEN (@vEffectiveFrom>=CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE) AND @vEffectiveTo BETWEEN CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE)AND cast(ISNULL(rrv.RuReferenceValue_EffectiveTo, GETDATE()) AS DATE) AND
						ISNULL(srt.SrReferenceType_Name, '') = 'RE') THEN 1
					ELSE 0
				END)) = 0 THEN 'Missing RE value. '
			ELSE ''
		END
		+
		CASE
			WHEN (MAX(CASE
					WHEN (@vEffectiveFrom>=CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE) AND @vEffectiveTo BETWEEN CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE)AND cast(ISNULL(rrv.RuReferenceValue_EffectiveTo, GETDATE()) AS DATE) AND
						ISNULL(srt.SrReferenceType_Name, '') = 'LIC') THEN 1
					ELSE 0
				END)) = 0 THEN 'Missing LIC value. '
			ELSE ''
		END

		+
		CASE
			WHEN (MAX(CASE
					WHEN (@vEffectiveFrom>=CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE) AND @vEffectiveTo BETWEEN CAST(ISNULL(rrv.RuReferenceValue_EffectiveFrom, GETDATE()) AS DATE)AND cast(ISNULL(rrv.RuReferenceValue_EffectiveTo, GETDATE()) AS DATE) AND
						ISNULL(srt.SrReferenceType_Name, '') = 'KE Share') THEN 1
					ELSE 0
				END)) = 0 THEN 'Missing KE Share value. '
			ELSE ''
		END


	FROM RuReferenceValue rrv
	JOIN SrReferenceType srt
		ON rrv.SrReferenceType_Id = srt.SrReferenceType_Id
	WHERE ISNULL(rrv.RuReferenceValue_IsDeleted, 0) = 0
	AND ISNULL(srt.SrReferenceType_IsDeleted, 0) = 0

	IF @vRefValMessage <> ''
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES (@vRefValMessage, 'Warning');
	END


	--4. Check if PSS/FSS exists for the settlement year.

	EXEC BMCFetchCriticalHoursActualEnergy @pStatementProcessId;

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [BMCActualEnergyCriticalHourly]
			WHERE MtStatementProcess_ID = @pStatementProcessId)
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('No FSS/ESS exists for the settlement Year.', 'Warning');
	END
	DECLARE @vPssFssCheck VARCHAR(MAX) = '';
	SELECT
		@vPssFssCheck = @vPssFssCheck + ',' +
		CAST(DATETIMEFROMPARTS(BMCActualEnergyCriticalHourly_Year, BMCActualEnergyCriticalHourly_Month, BMCActualEnergyCriticalHourly_Day, BMCActualEnergyCriticalHourly_Hour, 0, 0, 0) AS VARCHAR(MAX))
	FROM [BMCActualEnergyCriticalHourly]
	WHERE MtStatementProcess_ID = @pStatementProcessId
	AND BMCActualEnergyCriticalHourly_ActualEnergy IS NULL


	IF @vPssFssCheck <> ''
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('PSS/FSS missing for some of the dates of the settlement year: ' + @vPssFssCheck, 'Warning');
	END

	--5. Check if Avg and critical hours files are empty.
	IF NOT EXISTS (SELECT TOP 1
				1
			FROM MtCriticalHoursCapacity mchc
			WHERE mchc.MtSOFileMaster_Id = @vsoFileMasterIdHourlyCap)
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Critical Hours Capacity file against the settlement year is empty. ', 'Warning');
	END

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM MtAvgCriticalHoursCapacity machc
			WHERE machc.MtSOFileMaster_Id = @vsofileMasterIdAvgCap)
	BEGIN
		INSERT INTO #InvalidData (LOG_MESSAGE, ERROR_LEVEL)
			VALUES ('Avg. Critical Hours Capacity file against the settlement year is empty. ', 'Warning');
	END

	-- Insert errors into MtSattlementProcessLogs

	--SELECT
	--	*
	--FROM #InvalidData id;

	IF EXISTS (SELECT
			TOP 1
				1
			FROM #InvalidData id)
	BEGIN
		INSERT INTO MtSattlementProcessLogs (MtStatementProcess_ID
		, MtSattlementProcessLog_Message
		, MtSattlementProcessLog_ErrorLevel
		, MtSattlementProcessLog_CreatedBy
		, MtSattlementProcessLog_CreatedOn)
			SELECT
				@pStatementProcessId
			   ,id.LOG_MESSAGE
			   ,id.ERROR_LEVEL
			   ,@pUserId
			   ,GETDATE()
			FROM #InvalidData id

		RAISERROR ('BMC basic validations failure. Please refer to the previous logs for further details.', 16, -1);
		--THROW(SELECT 50000,'BMC basic validations error. Please refer to the logs grid for further details.',-1);
		RETURN;
	END


--END TRY
--BEGIN CATCH
--	--SELECT
--	--	ERROR_NUMBER() AS ErrorNumber
--	--   ,ERROR_STATE() AS ErrorState
--	--   ,ERROR_SEVERITY() AS ErrorSeverity
--	--   ,ERROR_PROCEDURE() AS ErrorProcedure
--	--   ,ERROR_LINE() AS ErrorLine
--	--   ,ERROR_MESSAGE() AS ErrorMessage;

--	   THROW;
--END CATCH
END

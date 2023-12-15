/****** Object:  Procedure [dbo].[CriticalHoursCapacity_Validations]    Committed by VersionSQL https://www.versionsql.com ******/

/************************************************************/
-- =============================================                            
-- Author: Ammama Gill                                       
-- CREATE date:  14/12/2022                                             
-- ALTER date:                                               
-- Reviewer:                                              
-- Description: Validate Critical hours Capacity data.                                          
-- =============================================                                               
-- =============================================                       


CREATE PROCEDURE dbo.CriticalHoursCapacity_Validations @pSoFileMaster_Id DECIMAL(18, 0),
@pUser_Id INT

AS
BEGIN
	BEGIN TRY

		DECLARE @vFromDate Date;
		DECLARE @vToDate Date;

		SELECT
			@vFromDate = lam.LuAccountingMonth_FromDate,
			@vToDate=lam.LuAccountingMonth_ToDate
		FROM MtSOFileMaster msm
		INNER JOIN LuAccountingMonth lam
			ON msm.LuAccountingMonth_Id = lam.LuAccountingMonth_Id
		WHERE msm.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(lam.LuAccountingMonth_IsDeleted, 0) = 0
		AND ISNULL(msm.MtSOFileMaster_IsDeleted, 0) = 0;

		UPDATE mch
		SET MtCriticalHoursCapacity_Message =
		CASE
			WHEN ISNULL(mch.MtCriticalHoursCapacity_Date, '') = '' THEN 'Date cannot be empty.'
			ELSE CASE
					WHEN ISDATE(mch.MtCriticalHoursCapacity_Date) = 0 THEN 'Invalid Date'
					ELSE CASE
							WHEN 
							MtCriticalHoursCapacity_Date>=@vFromDate and mch.MtCriticalHoursCapacity_Date<=@vToDate
--							DATEPART(YEAR, mch.MtCriticalHoursCapacity_Date) = @vYear 
							THEN ''
							ELSE 'Date should be of selected settlement year only.'
						END
				END

		END +
		CASE
			WHEN ISNULL(MtCriticalHoursCapacity_CriticalHour, '') = '' THEN 'Critical hour value cannot be empty.'
			ELSE CASE
					WHEN ISNUMERIC(MtCriticalHoursCapacity_CriticalHour) = 0 THEN 'Invalid Critical Hour.'
					ELSE CASE
							WHEN MtCriticalHoursCapacity_CriticalHour BETWEEN 1 AND 50 THEN ''
							ELSE 'Critical Hour should be between 1 and 50.'
						END
				END
		END +
		CASE
			WHEN ISNULL(mch.MtCriticalHoursCapacity_Hour, '') = '' THEN 'Hour cannot be empty.'
			ELSE CASE
					WHEN ISNUMERIC(mch.MtCriticalHoursCapacity_Hour) = 0 THEN 'Invalid hour.'
					ELSE CASE
							WHEN mch.MtCriticalHoursCapacity_Hour BETWEEN 0 AND 23 THEN ''
							ELSE 'Hour should be between 0 and 23.'
						END
				END
		END +
		CASE
			WHEN ISNULL(mch.MtCriticalHoursCapacity_SOUnitId, '') = '' THEN 'Generation Unit ID cannot be empty.'
			ELSE CASE
					WHEN ISNUMERIC(mch.MtCriticalHoursCapacity_SOUnitId) = 0 THEN 'Invalid Generation Unit ID.'
					ELSE CASE
							WHEN EXISTS (SELECT
										mgu.MtGenerationUnit_Id
									FROM MtGenerationUnit mgu
									WHERE mch.MtCriticalHoursCapacity_SOUnitId = mgu.MtGenerationUnit_SOUnitId
									AND ISNULL(mgu.MtGenerationUnit_IsDeleted, 0) = 0
									AND ISNULL(mgu.isDeleted, 0) = 0) THEN ''
							ELSE 'Generation Unit does not exist.'
						END
				END
		END
		+
		CASE
			WHEN ISNULL(mch.MtCriticalHoursCapacity_Capacity, '') = '' THEN 'Capacity cannot be empty.'
			ELSE CASE
					WHEN ISNUMERIC(mch.MtCriticalHoursCapacity_Capacity) = 0 THEN 'Invalid Capacity.'
					ELSE ''
				END
		END
		FROM MtCriticalHoursCapacity_Interface mch
		WHERE mch.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mch.MtCriticalHoursCapacity_IsDeleted = 0;

		DROP TABLE IF EXISTS #tempDuplicates;
		DROP TABLE IF EXISTS #tempEntriesExceeding5;
		-- same date|hour combination                  

		SELECT
			mchci.MtCriticalHoursCapacity_SOUnitId
		   ,mchci.MtCriticalHoursCapacity_Date
		   ,mchci.MtCriticalHoursCapacity_Hour INTO #tempDuplicates
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtCriticalHoursCapacity_IsDeleted = 0
		GROUP BY mchci.MtCriticalHoursCapacity_SOUnitId
				,mchci.MtCriticalHoursCapacity_Date
				,mchci.MtCriticalHoursCapacity_Hour
		HAVING COUNT(1) > 1;

		UPDATE MCI
		SET MCI.MtCriticalHoursCapacity_Message = MtCriticalHoursCapacity_Message + ' Multiple Day|Hour combinations. '
		FROM MtCriticalHoursCapacity_Interface MCI
		INNER JOIN #tempDuplicates d
			ON MCI.MtCriticalHoursCapacity_SOUnitId = d.MtCriticalHoursCapacity_SOUnitId
			AND MCI.MtCriticalHoursCapacity_Date = d.MtCriticalHoursCapacity_Date
			AND d.MtCriticalHoursCapacity_Hour = MCI.MtCriticalHoursCapacity_Hour
		WHERE MCI.MtCriticalHoursCapacity_IsDeleted = 0
		AND MCI.MtSOFileMaster_Id = @pSoFileMaster_Id;



		-- 5 entries of the same day                  

		SELECT

			mchci.MtCriticalHoursCapacity_SOUnitId
		   ,mchci.MtCriticalHoursCapacity_Date INTO #tempEntriesExceeding5
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtCriticalHoursCapacity_IsDeleted = 0
		GROUP BY mchci.MtCriticalHoursCapacity_SOUnitId
				,mchci.MtCriticalHoursCapacity_Date
		HAVING COUNT(1) > 5

		UPDATE MCI
		SET MCI.MtCriticalHoursCapacity_Message = MtCriticalHoursCapacity_Message + ' Critical Hours of the same day cannot exceed 5. '
		FROM MtCriticalHoursCapacity_Interface MCI
		INNER JOIN #tempEntriesExceeding5 d
			ON MCI.MtCriticalHoursCapacity_SOUnitId = d.MtCriticalHoursCapacity_SOUnitId
			AND MCI.MtCriticalHoursCapacity_Date = d.MtCriticalHoursCapacity_Date
		WHERE MCI.MtCriticalHoursCapacity_IsDeleted = 0
		AND MCI.MtSOFileMaster_Id = @pSoFileMaster_Id;


		DECLARE @vSOUnitsAvail INT = 0;
		SELECT
			@vSOUnitsAvail =
			COUNT(DISTINCT MtCriticalHoursCapacity_SOUnitId)
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtCriticalHoursCapacity_IsDeleted = 0;
		--AND mchci.MtCriticalHoursCapacity_SOUnitId IN (SELECT
		--		CAST(mgu.MtGenerationUnit_SOUnitId AS NVARCHAR(MAX))
		--	FROM MtGenerationUnit mgu
		--	WHERE ISNULL(mgu.isDeleted, 0) = 0
		--	AND ISNULL(mgu.MtGenerationUnit_IsDeleted, 0) = 0);

		SELECT
			mchci.MtCriticalHoursCapacity_Date
		   ,mchci.MtCriticalHoursCapacity_Hour INTO #DateHourComb
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtCriticalHoursCapacity_IsDeleted = 0
		AND mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		GROUP BY mchci.MtCriticalHoursCapacity_Date
				,mchci.MtCriticalHoursCapacity_Hour
		HAVING COUNT(1) <> @vSOUnitsAvail;



		UPDATE MCI
		SET MCI.MtCriticalHoursCapacity_Message = MtCriticalHoursCapacity_Message + ' Critical Hours should be same for all the Generation Units. '
		FROM MtCriticalHoursCapacity_Interface MCI
		INNER JOIN #DateHourComb d
			ON MCI.MtCriticalHoursCapacity_Date = d.MtCriticalHoursCapacity_Date
			AND MCI.MtCriticalHoursCapacity_Hour = d.MtCriticalHoursCapacity_Hour
		WHERE MCI.MtCriticalHoursCapacity_IsDeleted = 0
		AND MCI.MtSOFileMaster_Id = @pSoFileMaster_Id;



		--- Duplicate critical hours-----    
		SELECT
			mchci.MtCriticalHoursCapacity_CriticalHour
		   ,mchci.MtCriticalHoursCapacity_SOUnitId INTO #DuplicateCriticalHours
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtCriticalHoursCapacity_IsDeleted = 0
		GROUP BY mchci.MtCriticalHoursCapacity_SOUnitId
				,mchci.MtCriticalHoursCapacity_CriticalHour
		HAVING COUNT(1) > 1;

		UPDATE MCI
		SET MCI.MtCriticalHoursCapacity_Message = MtCriticalHoursCapacity_Message + ' Critical Hour no cannot be duplicate. '
		FROM MtCriticalHoursCapacity_Interface MCI
		INNER JOIN #DuplicateCriticalHours d
			ON d.MtCriticalHoursCapacity_CriticalHour = MCI.MtCriticalHoursCapacity_CriticalHour
			AND d.MtCriticalHoursCapacity_SOUnitId = MCI.MtCriticalHoursCapacity_SOUnitId
		WHERE MCI.MtCriticalHoursCapacity_IsDeleted = 0
		AND MCI.MtSOFileMaster_Id = @pSoFileMaster_Id;

		------------------------- update interface table. Set isvalid 0.    

		UPDATE MtCriticalHoursCapacity_Interface
		SET MtCriticalHoursCapacity_IsValid = 0
		WHERE MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(MtCriticalHoursCapacity_Message, '') <> ''
		AND MtCriticalHoursCapacity_IsDeleted = 0;


		------------------ Set valid/invalid count------------    
		DECLARE @vInvalidCount INT
			   ,@vTotalCount INT;
		SELECT
			@vInvalidCount = COUNT(*)
		FROM MtCriticalHoursCapacity_Interface mchci
		WHERE mchci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND mchci.MtCriticalHoursCapacity_IsDeleted = 0
		AND mchci.MtCriticalHoursCapacity_Message <> '';

		SELECT
			@vTotalCount = COUNT(*)
		FROM MtCriticalHoursCapacity_Interface machci
		WHERE machci.MtSOFileMaster_Id = @pSoFileMaster_Id
		AND machci.MtCriticalHoursCapacity_IsDeleted = 0

		UPDATE MtSOFileMaster
		SET InvalidRecords = @vInvalidCount
		   ,TotalRecords = @vTotalCount
		WHERE MtSOFileMaster_Id = @pSoFileMaster_Id
		AND ISNULL(MtSOFileMaster_IsDeleted, 0) = 0


		--IF EXISTS (SELECT            
		--   1            
		--  FROM MtCriticalHoursCapacity_Interface mchci            
		--  WHERE mchci.MtCriticalHoursCapacity_IsValid = 0            
		--  AND MtSOFileMaster_Id = @pSoFileMaster_Id            
		--  AND mchci.MtCriticalHoursCapacity_IsDeleted = 0)            
		--BEGIN            
		-- ;            
		-- WITH CTE            
		-- AS            
		-- (SELECT            
		--   mchci.MtCriticalHoursCapacity_RowNumber            
		--     ,mchci.MtCriticalHoursCapacity_IsValid            
		--     ,mchci.MtCriticalHoursCapacity_Id            
		--     ,ROW_NUMBER() OVER (ORDER BY MtCriticalHoursCapacity_IsValid, MtCriticalHoursCapacity_RowNumber) AS MtCriticalHoursCapacity_RowNumber_new            
		--  FROM MtCriticalHoursCapacity_Interface mchci           
		--  WHERE MtSOFileMaster_Id = @pSoFileMaster_Id            
		--  AND mchci.MtCriticalHoursCapacity_IsDeleted = 0)            

		-- UPDATE M            
		-- SET MtCriticalHoursCapacity_RowNumber = c.MtCriticalHoursCapacity_RowNumber_new            
		-- FROM MtCriticalHoursCapacity_Interface M            
		-- INNER JOIN CTE c            
		--  ON c.MtCriticalHoursCapacity_Id = M.MtCriticalHoursCapacity_Id            
		-- WHERE M.MtSOFileMaster_Id = @pSoFileMaster_Id            
		-- AND M.MtCriticalHoursCapacity_IsDeleted = 0;            







		--END            

		SELECT
			@vInvalidCount AS InvalidCount
		   ,@vTotalCount AS ValidCount;


	END TRY
	BEGIN CATCH

		SELECT
			ERROR_NUMBER() AS ErrorNumber
		   ,ERROR_STATE() AS ErrorState
		   ,ERROR_SEVERITY() AS ErrorSeverity
		   ,ERROR_PROCEDURE() AS ErrorProcedure
		   ,ERROR_LINE() AS ErrorLine
		   ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH

END

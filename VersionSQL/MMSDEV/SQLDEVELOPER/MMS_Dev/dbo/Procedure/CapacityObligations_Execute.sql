/****** Object:  Procedure [dbo].[CapacityObligations_Execute]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ================================================================================    
-- Author:  Ammama Gill 
-- CREATE date: 18 May 2023  
-- ALTER date:   
-- Description:   
-- =================================================================================   

-- dbo.CapacityObligations_Execute  1053,1
CREATE PROCEDURE dbo.CapacityObligations_Execute (@pSoFileMasterId DECIMAL(18, 0), @pUserId INT)
AS
BEGIN
	BEGIN TRY

		/*****************************************************************************************  
	    Fetch Transmission Loss and Reserve Margin values based on effective from and effective to
	    *****************************************************************************************/


		DECLARE @vTransmissionLoss DECIMAL(24, 8)
			   ,@vReserveMargin DECIMAL(24, 8)
			   ,@vValidationMessage VARCHAR(MAX) = ''
			   ,@vToDate DATE
			   ,@vFromDate DATE;


		SELECT
			@vFromDate = LAM.LuAccountingMonth_FromDate
		   ,@vToDate = LAM.LuAccountingMonth_ToDate
		FROM MtSOFileMaster msm
		INNER JOIN LuAccountingMonth LAM
			ON msm.LuAccountingMonth_Id = LAM.LuAccountingMonth_Id
		WHERE msm.MtSOFileMaster_Id = @pSoFileMasterId;


		SELECT
			@vTransmissionLoss = MAX(CASE
				WHEN @vFromDate >= RV.RuReferenceValue_EffectiveFrom AND
					@vToDate BETWEEN ISNULL(RV.RuReferenceValue_EffectiveFrom, GETDATE()) AND ISNULL(RV.RuReferenceValue_EffectiveTo, GETDATE()) AND
					ISNULL(RT.SrReferenceType_Name, '') = 'Cap on Transmission Losses NTDC' THEN RV.RuReferenceValue_Value
				ELSE 0
			END)
		   ,@vReserveMargin = MAX(CASE
				WHEN @vFromDate >= RV.RuReferenceValue_EffectiveFrom AND
					@vToDate BETWEEN ISNULL(RV.RuReferenceValue_EffectiveFrom, GETDATE()) AND ISNULL(RV.RuReferenceValue_EffectiveTo, GETDATE()) AND
					ISNULL(RT.SrReferenceType_Name, '') = 'Reserve Margin' THEN RV.RuReferenceValue_Value
				ELSE 0
			END)
		FROM RuReferenceValue RV
		INNER JOIN SrReferenceType RT
			ON RV.SrReferenceType_Id = RT.SrReferenceType_Id
		WHERE ISNULL(RT.SrReferenceType_IsDeleted, 0) = 0
		AND ISNULL(RV.RuReferenceValue_IsDeleted, 0) = 0;


		IF @vTransmissionLoss = 0
		BEGIN
			SET @vValidationMessage = 'Missing Transmission Loss value. ';
		END

		IF @vReserveMargin = 0
		BEGIN
			SET @vValidationMessage = @vValidationMessage + 'Missing Reserve Margin value. ';
		END

		/***************************************************************************************** 
		Validate if party categories represent demand side.
	    *****************************************************************************************/

		DECLARE @vPartyCategoriesValidations VARCHAR(300) = ''

		SELECT
		DISTINCT
			@vPartyCategoriesValidations = @vPartyCategoriesValidations +

			CONCAT(APC.SrCategory_Code, ':', CAST(mf.MtParty_Id AS VARCHAR(10))) + ','
		FROM MTDemandForecast mf
		INNER JOIN vw_ActivePartyCategories APC
			ON APC.MtPartyRegisteration_Id = mf.MtParty_Id
		WHERE mf.MtSOFileMaster_Id = @pSoFileMasterId
		AND APC.SrCategory_Code NOT IN ('BSUP', 'BPC', 'CSUP', 'PAKT', 'INTT')

		IF @vPartyCategoriesValidations <> ''
		BEGIN
			SET @vValidationMessage = @vValidationMessage + 'Invalid categories in the uploaded demand forecast file: ' + @vPartyCategoriesValidations;
		END

		DECLARE @vPartyCount INT = 0
			   ,@vPartyDataValidation VARCHAR(300) = '';
		SELECT
			@vPartyCount = COUNT(DISTINCT (MF.MtParty_Id))--COUNT(DISTINCT (concat(MF.MtParty_Id, SrCategory_Code)))
		FROM MTDemandForecast MF
		INNER JOIN vw_ActivePartyCategories APC
			ON APC.MtPartyRegisteration_Id = MF.MtParty_Id
		WHERE MF.MtSOFileMaster_Id = @pSoFileMasterId
		AND ISNULL(MTDemandForecast_IsDeleted, 0) = 0;

		SELECT
			@vPartyDataValidation = @vPartyDataValidation + CAST(MTDemandForecast_Year AS VARCHAR(10)) + ' , '
		FROM MTDemandForecast MF
		WHERE MtSOFileMaster_Id = @pSoFileMasterId
		AND ISNULL(MTDemandForecast_IsDeleted, 0) = 0
		GROUP BY MTDemandForecast_Year
		HAVING COUNT(1) < @vPartyCount

		if @vPartyDataValidation <> ''
		begin
		set @vValidationMessage = @vValidationMessage + 'Missing years in the uploaded file: ' + @vPartyDataValidation;
		end
		


		IF NOT EXISTS (SELECT
				TOP 1
					1
				FROM MtCapacityObligationsDetails COD
				WHERE COD.MtSOFileMaster_Id = @pSoFileMasterId)
		BEGIN

			/*****************************************************************************************  
		    insert all the demand side categories included within the Demand Forecast file. 
		    *****************************************************************************************/
			;
			WITH cte_Categories
			AS
			(SELECT
				DISTINCT
					APC.SrCategory_Code
				FROM MTDemandForecast DF
				INNER JOIN vw_ActivePartyCategories APC
					ON APC.MtPartyRegisteration_Id = DF.MtParty_Id

				WHERE APC.SrCategory_Code IN ('BSUP', 'BPC', 'CSUP', 'PAKT', 'INTT')
				AND DF.MtSOFileMaster_Id = @pSoFileMasterId)



			INSERT INTO MtCapacityObligationsDetails (MtSOFileMaster_Id, SrCategory_Code, MtCapacityObligationsDetails_YearReference, MtCapacityObligationsDetails_ReserveMargin, MtCapacityObligationsDetails_TransmissionLoss, MtCapacityObligationsDetails_CreatedBy, MtCapacityObligationsDetails_CreatedOn)
				SELECT
					@pSoFileMasterId
				   ,C.SrCategory_Code
				   ,MCOS.MtCapacityObligationsSettings_year
				   ,@vReserveMargin
				   ,@vTransmissionLoss
				   ,@pUserId
				   ,GETDATE()
				FROM MtCapacityObligationsSettings MCOS
				INNER JOIN cte_Categories C
					ON MCOS.SrCategory_Code = C.SrCategory_Code
				WHERE MCOS.MtCapacityObligationsSettings_IsDisabled = 0
				AND MCOS.MtCapacityObligationsSettings_IsDeleted = 0


			/*****************************************************************************************  
			Select all the number of years for each category set.
			*****************************************************************************************/
			DROP TABLE IF EXISTS #Years;

			CREATE TABLE #Years (
				SrCategoryCode VARCHAR(4)
			   ,PercentageObligations DECIMAL(18, 4)
			   ,YearPlace INT
			   ,PreviousYear INT
			   ,NextYear INT
			   ,FinancialYear VARCHAR(50)
			);

			INSERT INTO #Years (SrCategoryCode, YearPlace, PercentageObligations)
				SELECT
				DISTINCT
					MCOS.SrCategory_Code
				   ,MCOS.MtCapacityObligationsSettings_year
				   ,MCOS.MtCapacityObligationsSettings_Percentage
				FROM MtCapacityObligationsSettings MCOS
				INNER JOIN LuCapacityObligationsYears COY
					ON COY.LuCapacityObligationsYears_Name = MCOS.MtCapacityObligationsSettings_year
				INNER JOIN MtCapacityObligationsDetails COD
					ON MCOS.SrCategory_Code = COD.SrCategory_Code
				WHERE ISNULL(COD.MtCapacityObligationsDetails_IsDeleted, 0) = 0
				AND ISNULL(MCOS.MtCapacityObligationsSettings_IsDeleted, 0) = 0
				AND COD.MtSOFileMaster_Id = @pSoFileMasterId
				AND MCOS.MtCapacityObligationsSettings_IsDisabled = 0
				ORDER BY MCOS.MtCapacityObligationsSettings_year


			;
			WITH cte_CurrentYear
			AS
			(SELECT
					0 AS YearPlace
				   ,CAST(value AS INT) AS SplitYear
				FROM MtSOFileMaster SOF
				INNER JOIN LuAccountingMonth AM
					ON SOF.LuAccountingMonth_Id = AM.LuAccountingMonth_Id
				CROSS APPLY STRING_SPLIT(LuAccountingMonth_MonthName, '-')
				WHERE SOF.MtSOFileMaster_Id = @pSoFileMasterId)

			UPDATE Y
			SET Y.PreviousYear = (SELECT
						MIN(CY.SplitYear)
					FROM cte_CurrentYear CY)
				+ Y.YearPlace

			   ,Y.NextYear = (SELECT
						MAX(CY.SplitYear)
					FROM cte_CurrentYear CY)
				+ Y.YearPlace

			FROM #Years Y


			UPDATE Y
			SET FinancialYear =
			CONCAT_WS('-', Y.PreviousYear, Y.NextYear)
			FROM #Years Y

			/*****************************************************************************************  
			Add validations to check data completeness in Uploaded Demand forecast files.
			*****************************************************************************************/
			DECLARE @vYearCountValidation VARCHAR(100) = '';
			;
			WITH cte_YearValidations
			AS
			(SELECT DISTINCT
					MF.MTDemandForecast_Year
				   ,APC.SrCategory_Code
				FROM MTDemandForecast MF
				INNER JOIN vw_ActivePartyCategories APC
					ON APC.MtPartyRegisteration_Id = MF.MtParty_Id
				WHERE MF.MtSOFileMaster_Id = @pSoFileMasterId
				UNION ALL
				SELECT
					y.FinancialYear
				   ,y.SrCategoryCode
				FROM #Years y)


			SELECT
				@vYearCountValidation = @vYearCountValidation + STRING_AGG(CONCAT(SrCategory_Code, ' : ', MTDemandForecast_Year), ',') + '. '
			FROM cte_YearValidations
			GROUP BY SrCategory_Code
					,MTDemandForecast_Year
			HAVING COUNT(MTDemandForecast_Year) < 2

			--select @vYearCountValidation;

			IF @vYearCountValidation <> ''
			BEGIN
				SET @vValidationMessage = @vValidationMessage + 'Yearly data inconsistency: ' + @vYearCountValidation + ' for capacity obligation settings.';
			END

			DECLARE @vDataValidation VARCHAR(100) = '';
			;
			WITH cte_MaxDemandValidations
			AS
			(SELECT
				DISTINCT
					ROW_NUMBER() OVER (PARTITION BY MF.MtParty_Id ORDER BY COD.MtCapacityObligationsDetails_YearReference ASC) AS yearRefRow
				   ,ROW_NUMBER() OVER (PARTITION BY MF.MtParty_Id ORDER BY MF.MTDemandForecast_Max_Demand_during_Peakhours_MW ASC) AS DemandRefRow
				   ,MF.MtParty_Id
				   ,COD.MtCapacityObligationsDetails_Year
				FROM MTDemandForecast MF
				INNER JOIN MtCapacityObligationsDetails COD
					ON MF.MtSOFileMaster_Id = COD.MtSOFileMaster_Id
					AND MF.MTDemandForecast_Year = COD.MtCapacityObligationsDetails_Year
				INNER JOIN vw_ActivePartyCategories APC
					ON COD.SrCategory_Code = APC.SrCategory_Code
					AND MF.MtParty_Id = APC.MtPartyRegisteration_Id
				WHERE MF.MtSOFileMaster_Id = @pSoFileMasterId)

			SELECT
			TOP 1
				@vDataValidation = @vDataValidation + CONCAT(CAST(MtParty_Id AS VARCHAR(10)), ':', MtCapacityObligationsDetails_Year) + ','
			FROM cte_MaxDemandValidations
			WHERE yearRefRow <> DemandRefRow;

			IF @vDataValidation <> ''
			BEGIN
				SET @vValidationMessage = @vValidationMessage + 'Maximum demand capacity value is not consistent: ' + @vDataValidation;

			END

			IF @vValidationMessage <> ''
			BEGIN

				UPDATE MtSOFileMaster
				SET MtSOFileMaster_Validations = @vValidationMessage
				WHERE MtSOFileMaster_Id = @pSoFileMasterId;

				EXEC CapacityObligations_Rollback @pSoFileMasterId
												 ,@pUserId;
				RAISERROR ('Data in uploaded file is incorrect. Please remove this file  and upload revised dataset before continuning to save data.', 16, -1);
				RETURN;
			END
			ELSE
			BEGIN
				UPDATE MtSOFileMaster
				SET MtSOFileMaster_Validations = NULL
				WHERE MtSOFileMaster_Id = @pSoFileMasterId;
			END


			UPDATE COD
			SET COD.MtCapacityObligationsDetails_Year = Y.FinancialYear
			   ,COD.MtCapacityObligationsSettings_Percentage = Y.PercentageObligations
			FROM MtCapacityObligationsDetails COD
			INNER JOIN #Years Y
				ON COD.SrCategory_Code = Y.SrCategoryCode
				AND COD.MtCapacityObligationsDetails_YearReference = Y.YearPlace
			WHERE COD.MtSOFileMaster_Id = @pSoFileMasterId




			/*****************************************************************************************  
			Calculate MP & Year wise Capacity Obligations. (MD/1-(T_loss/100) * (1*RM)/100 * OB%/100
			*****************************************************************************************/
			;
			WITH cte_Calculations
			AS
			(SELECT
					MF.MtParty_Id
				   ,MF.MTDemandForecast_Year
				   ,(1 - (COD.MtCapacityObligationsDetails_TransmissionLoss / 100)) AS Factor1
				   ,(1 + (COD.MtCapacityObligationsDetails_ReserveMargin / 100)) AS Factor2
				   ,(COD.MtCapacityObligationsSettings_Percentage / 100) AS Factor3
				FROM MTDemandForecast MF
				INNER JOIN MtCapacityObligationsDetails COD
					ON MF.MtSOFileMaster_Id = COD.MtSOFileMaster_Id
					AND MF.MTDemandForecast_Year = COD.MtCapacityObligationsDetails_Year
				INNER JOIN vw_ActivePartyCategories APC
					ON COD.SrCategory_Code = APC.SrCategory_Code
					AND MF.MtParty_Id = APC.MtPartyRegisteration_Id
				WHERE MF.MtSOFileMaster_Id = @pSoFileMasterId)

			UPDATE MF
			SET MF.MTDemandForecast_CapacityObligation =
			(MF.MTDemandForecast_Max_Demand_during_Peakhours_MW / C.Factor1) * C.Factor2 * C.Factor3
			FROM MTDemandForecast MF
			INNER JOIN cte_Calculations C
				ON MF.MtParty_Id = C.MtParty_Id
				AND MF.MTDemandForecast_Year = C.MTDemandForecast_Year
			WHERE MF.MtSOFileMaster_Id = @pSoFileMasterId


		END
	END TRY
	BEGIN CATCH
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();

		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH
END

/****** Object:  Procedure [dbo].[BME_ValidateDistributionLossFactor]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author: Ali Imran
-- CREATE date: 05/April/2023
-- ALTER date:   
-- Description: 
-- Parameters: @Year, @Month, @StatementProcessId  
-- =============================================  
-- dbo.BME_ValidateDistributionLossFactor 2023,1,2132
CREATE     PROCEDURE dbo.BME_ValidateDistributionLossFactor @Year INT 
, @Month INT 
, @StatementProcessId DECIMAL(18, 0) 

AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		
		DECLARE @MONTH_EFFECTIVE_FROM AS DATETIME = DATETIMEFROMPARTS(@Year, @Month, 1, 0, 0, 0, 0);
		DECLARE @MONTH_EFFECTIVE_TO AS DATETIME = EOMONTH(@MONTH_EFFECTIVE_FROM);


		WITH _PartyIds
		AS
		(SELECT DISTINCT
				BmeStatementData_ToPartyRegisteration_Id AS PartyId
			   ,BmeStatementData_LineVoltage
			FROM BmeStatementDataCdpHourly bsdchsp
			WHERE BmeStatementData_StatementProcessId = @StatementProcessId
			AND BmeStatementData_LineVoltage IN (11, 132)
			AND BmeStatementData_ToPartyCategory_Code = 'DSP'
			AND ISNULL(IsBackfeedInclude, 0) = 1
			AND BmeStatementData_FromPartyCategory_Code <> 'TSP'
			UNION
			SELECT DISTINCT
				BmeStatementData_FromPartyRegisteration_Id AS PartyId
			   ,BmeStatementData_LineVoltage AS PartyId
			FROM BmeStatementDataCdpHourly bsdchsp
			WHERE BmeStatementData_StatementProcessId = @StatementProcessId
			AND BmeStatementData_LineVoltage IN (11, 132)
			AND ISNULL(IsBackfeedInclude, 0) = 1
			AND BmeStatementData_FromPartyCategory_Code = 'DSP'
			AND BmeStatementData_ToPartyCategory_Code <> 'TSP')



		SELECT
			P.PartyId
		   ,P.BmeStatementData_LineVoltage
		   ,D.Lu_DistLosses_Factor
		   ,D.Lu_DistLosses_EffectiveFrom
		   ,D.Lu_DistLosses_EffectiveTo INTO #DistLossFactor
		FROM _PartyIds P
		LEFT JOIN Lu_DistLosses D
			ON D.Lu_DistLosses_MP_Id = P.PartyId
				AND D.Lu_DistLosses_LineVoltage = P.BmeStatementData_LineVoltage

				AND (@MONTH_EFFECTIVE_FROM >= D.Lu_DistLosses_EffectiveFrom
					OR D.Lu_DistLosses_EffectiveFrom BETWEEN @MONTH_EFFECTIVE_FROM AND @MONTH_EFFECTIVE_TO)

				AND ISNULL(D.Lu_DistLosses_EffectiveTo, @MONTH_EFFECTIVE_TO) >= @MONTH_EFFECTIVE_TO
		ORDER BY 1;




		SELECT
			PartyId
		   ,BmeStatementData_LineVoltage AS LineVoltage
		   ,Lu_DistLosses_Factor AS LossFactor
		   ,Lu_DistLosses_EffectiveFrom AS EffectiveFrom
		   ,Lu_DistLosses_EffectiveTo AS EffectiveTo
		   ,'loss factor is null or zero not allowed                    ' AS [Message] INTO #DissLossFactorIssue
		FROM #DistLossFactor
		WHERE ISNULL(Lu_DistLosses_Factor, 0) = 0


		DECLARE @vStartDate DATE = DATEFROMPARTS(@Year, @Month, 1)
			   ,@vEndDate DATE = EOMONTH(DATEFROMPARTS(@Year, @Month, 1))

		INSERT INTO #DissLossFactorIssue
			SELECT
				PartyId
			   ,BmeStatementData_LineVoltage AS LineVoltage
			   ,Lu_DistLosses_Factor AS LossFactor
			   ,Lu_DistLosses_EffectiveFrom AS EffectiveFrom
			   ,Lu_DistLosses_EffectiveTo AS EffectiveTo
			   ,'Month date is not between effective From and To date' AS [Message]
			FROM #DistLossFactor df
			WHERE @vStartDate NOT BETWEEN df.Lu_DistLosses_EffectiveFrom AND df.Lu_DistLosses_EffectiveTo
			OR @vEndDate NOT BETWEEN df.Lu_DistLosses_EffectiveFrom AND df.Lu_DistLosses_EffectiveTo


		IF NOT EXISTS (SELECT TOP 1
					1
				FROM #DissLossFactorIssue)
		BEGIN
			SELECT
				1 AS [IS_VALID]
			   ,@@rowcount AS [ROW_COUNT]
			   ,OBJECT_NAME(@@procid) AS [SP_NAME];

		END
		ELSE
		BEGIN
			--SELECT
			--	0 AS [IS_VALID]
			--   ,OBJECT_NAME(@@procid) AS [SP_NAME];


			SELECT
				'Party Id: ' + CAST(PartyId AS VARCHAR(10)) + ' - Line Voltage: ' + CAST(LineVoltage AS VARCHAR(10)) AS [messages] INTO #errormessage
			FROM #DissLossFactorIssue

			DECLARE @vErrorMessage NVARCHAR(MAX) =
			'distribution loss factor is null or zero not allowed. Month date is not between disstribution loss effective From and To date: '
			SELECT
				@vErrorMessage += STUFF((SELECT DISTINCT
						',' + [messages]
					FROM #errormessage
					FOR XML PATH (''))
				, 1, 1, ''
				)


			RAISERROR (@vErrorMessage, 16, 1);
			
		END
	END TRY
	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS ErrorNumber
		   ,ERROR_STATE() AS ErrorState
		   ,ERROR_SEVERITY() AS ErrorSeverity
		   ,ERROR_PROCEDURE() AS ErrorProcedure
		   ,ERROR_LINE() AS ErrorLine
		   ,ERROR_MESSAGE() AS ErrorMessage;
		   THROW;
	END CATCH;

END

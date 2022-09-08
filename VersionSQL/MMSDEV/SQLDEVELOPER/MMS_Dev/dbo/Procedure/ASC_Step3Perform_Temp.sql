/****** Object:  Procedure [dbo].[ASC_Step3Perform_Temp]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[ASC_Step3Perform_Temp] (@Year INT,
@Month INT
, @StatementProcessId DECIMAL(18, 0))
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF EXISTS (SELECT TOP 1
					AscStatementData_Id
				FROM AscStatementDataGuHourly
				WHERE AscStatementData_Year = @Year
				AND AscStatementData_Month = @Month
				AND AscStatementData_StatementProcessId = @StatementProcessId)
		BEGIN
			DECLARE @BmeStatementProcessId DECIMAL(18, 0) = NULL;
			SELECT TOP 1
				@BmeStatementProcessId = MtStatementProcess_ID
			FROM MtStatementProcess SP
			WHERE SP.LuAccountingMonth_Id_Current IN (SELECT TOP 1
					SP.LuAccountingMonth_Id_Current
				FROM MtStatementProcess SP
				WHERE SP.MtStatementProcess_ID = @StatementProcessId)
			AND SP.SrProcessDef_ID = 1
			AND SP.MtStatementProcess_IsDeleted = 0;

			DROP TABLE IF EXISTS #TempEAG

			/*
			step 3.1 Calculate Must Run EAG
			*/


			SELECT
				CDPH.BmeStatementData_CdpId
			   ,CDPH.BmeStatementData_NtdcDateTime
			   ,AscStatementData_SOUnitId
			   ,CDPH.BmeStatementData_IncEnergyExport
			   ,CDPH.BmeStatementData_IncEnergyImport
			   ,ISNULL(CASE
					WHEN GUP.AscStatementData_FromPartyCategory_Code IN ('GEN', 'CGEN', 'EGEN') THEN CDPH.BmeStatementData_IncEnergyExport
					WHEN GUP.AscStatementData_ToPartyCategory_Code IN ('GEN', 'CGEN', 'EGEN') THEN CDPH.BmeStatementData_IncEnergyImport
				END, 0) AS EAG INTO #TempEAG
			FROM [dbo].[AscStatementDataCdpGuParty] GUP
			INNER JOIN BmeStatementDataCdpHourly CDPH
				ON GUP.AscStatementData_CdpId = CDPH.BmeStatementData_CdpId
			WHERE GUP.AscStatementData_StatementProcessId = @StatementProcessId
			AND CDPH.BmeStatementData_Year = @Year
			AND CDPH.BmeStatementData_Month = @Month
			AND CDPH.BmeStatementData_StatementProcessId = @BmeStatementProcessId;

			UPDATE AscStatementDataGuHourly
			SET AscStatementData_MR_EAG = TE.EAG
			FROM AscStatementDataGuHourly GUH
			INNER JOIN #TempEAG TE
				ON GUH.AscStatementData_SOUnitId = TE.AscStatementData_SOUnitId
				AND GUH.AscStatementData_NtdcDateTime = TE.BmeStatementData_NtdcDateTime
			WHERE GUH.AscStatementData_Year = @Year
			AND GUH.AscStatementData_Month = @Month
			AND GUH.AscStatementData_StatementProcessId = @StatementProcessId
			AND GUH.AscStatementData_Generator_Id
			IN (SELECT
					GUP.AscStatementData_Generator_Id
				FROM [dbo].[AscStatementDataCdpGuParty] GUP
				WHERE AscStatementData_StatementProcessId = @StatementProcessId
				GROUP BY GUP.AscStatementData_Generator_Id
				HAVING COUNT(GUP.AscStatementData_SOUnitId) = 1)


			UPDATE AscStatementDataGuHourly
			SET AscStatementData_MR_EAG = TE.EAG -
			--select GUH.AscStatementData_SOUnitId ,TE.EAG,
			ISNULL((SELECT
					SUM(ISNULL(AscStatementData_SO_AC_ASC, 0))
				FROM AscStatementDataGuHourly GH
				WHERE GH.AscStatementData_NtdcDateTime = GUH.AscStatementData_NtdcDateTime
				AND GH.AscStatementData_Year = @Year
				AND GH.AscStatementData_Month = @Month
				AND GH.AscStatementData_StatementProcessId = @StatementProcessId
				AND GH.AscStatementData_SOUnitId IN (SELECT DISTINCT
						AscStatementData_SOUnitId
					FROM AscStatementDataCdpGuParty
					WHERE AscStatementData_StatementProcessId = @StatementProcessId
					AND AscStatementData_RuCDPDetail_Id
					IN (SELECT
							AscStatementData_RuCDPDetail_Id
						FROM AscStatementDataCdpGuParty
						WHERE AscStatementData_StatementProcessId = @StatementProcessId
						AND AscStatementData_SOUnitId = GUH.AscStatementData_SOUnitId))
				AND AscStatementData_SOUnitId <> GUH.AscStatementData_SOUnitId)
			, 0)
			FROM AscStatementDataGuHourly GUH
			INNER JOIN (SELECT
					T.AscStatementData_SOUnitId
				   ,T.BmeStatementData_NtdcDateTime
				   ,SUM(T.EAG) AS EAG
				FROM #TempEAG T
				GROUP BY T.AscStatementData_SOUnitId
						,T.BmeStatementData_NtdcDateTime) TE
				ON GUH.AscStatementData_SOUnitId = TE.AscStatementData_SOUnitId
				AND GUH.AscStatementData_NtdcDateTime = TE.BmeStatementData_NtdcDateTime
			WHERE GUH.AscStatementData_Year = @Year
			AND GUH.AscStatementData_Month = @Month
			AND GUH.AscStatementData_StatementProcessId = @StatementProcessId
			AND AscStatementData_IsGenMR = 1

			AND GUH.AscStatementData_Generator_Id IN (SELECT
					GUP.AscStatementData_Generator_Id
				FROM [dbo].[AscStatementDataCdpGuParty] GUP
				WHERE AscStatementData_StatementProcessId = @StatementProcessId
				GROUP BY GUP.AscStatementData_Generator_Id
				HAVING COUNT(GUP.AscStatementData_SOUnitId) > 1);

			/*
			step 3.2 Calculate Must Run EPG
			"MR_EPG = SO_MR_EP
			"
			*/

			UPDATE AscStatementDataGuHourly
			SET AscStatementData_MR_EPG = AscStatementData_SO_MR_EP
			FROM AscStatementDataGuHourly GUH

			WHERE GUH.AscStatementData_Year = @Year
			AND GUH.AscStatementData_Month = @Month
			AND GUH.AscStatementData_StatementProcessId = @StatementProcessId
			AND GUH.AscStatementData_IsGenMR = 1;


			/*
			Step 3.3 Calculate Must Run MRC
			"Variable Price of generator unit to be compensated -  Marginal Price of that hour
			MRC =  (MR_EAG - MR_EPG) * (SO_MR_VC - SO_MP)
			"
			
			*/



			UPDATE AscStatementDataGuHourly
			SET AscStatementData_MRC = ISNULL(AscStatementData_MR_EAG - AscStatementData_MR_EPG, 0) * ISNULL((AscStatementData_SO_MR_VC - AscStatementData_SO_MP), 0)
			   ,AscStatementData_MR_UPC = ISNULL(AscStatementData_MR_EAG - AscStatementData_MR_EPG, 0)
			WHERE AscStatementData_Year = @Year
			AND AscStatementData_Month = @Month
			AND AscStatementData_StatementProcessId = @StatementProcessId
			AND AscStatementData_IsGenMR = 1;



			SELECT
				1 AS [IS_VALID]
			   ,@@rowcount AS [ROW_COUNT]
			   ,OBJECT_NAME(@@procid) AS [SP_NAME];
		END
		ELSE
		BEGIN
			SELECT
				0 AS [IS_VALID]
			   ,OBJECT_NAME(@@procid) AS [SP_NAME];
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
	END CATCH;

END

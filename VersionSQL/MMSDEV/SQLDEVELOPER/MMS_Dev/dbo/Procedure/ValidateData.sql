/****** Object:  Procedure [dbo].[ValidateData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [dbo].[ValidateData] 217,2021,9
CREATE PROCEDURE [dbo].[ValidateData]
@StatementProcessId INT,
@Year INT = NULL,
@Month INT = NULL


AS
BEGIN 

BEGIN TRY
	

		DROP TABLE IF EXISTS #ValidatePartyRegistrationData;
		DROP TABLE  IF EXISTS #ValidateCDPData;
		DROP TABLE IF EXISTS #ValidateAllocationFactorData;
		DROP TABLE IF EXISTS #ValidateDistLossData;
		DROP TABLE IF EXISTS #ValidateMarginalPriceData;
		DROP TABLE IF EXISTS #ValidateBilateralContractData;
		DROP TABLE IF EXISTS #ValidateAvailibilityData;
		DROP TABLE IF EXISTS #ValidateGeneratorData
		DROP TABLE IF EXISTS #Final_ValidatedData;

		DECLARE @soFileId_marginalPrice INT;
		DECLARE @soFileId_bilateralContract INT;
		DECLARE @soFileId_AvailData INT;

		SET @soFileId_bilateralContract = dbo.GetMtSoFileMasterId(@StatementProcessId,8);
		SET @soFileId_marginalPrice = dbo.GetMtSoFileMasterId(@StatementProcessId,1);
		SET @soFileId_AvailData = dbo.GetMtSoFileMasterId(@StatementProcessId,2);


		CREATE TABLE #Final_ValidatedData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
	
		);

		CREATE TABLE #ValidatePartyRegistrationData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);

		CREATE TABLE #ValidateCDPData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
	
		);

		CREATE TABLE #ValidateAllocationFactorData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);

		CREATE TABLE #ValidateDistLossData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);

		CREATE TABLE #ValidateBilateralContractData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);

		CREATE TABLE #ValidateMarginalPriceData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);

		CREATE TABLE #ValidateAvailibilityData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);
		
		CREATE TABLE #ValidateGeneratorData(
		IS_VALID BIT,
		SP_NAME VARCHAR(MAX),
		LOG_MESSAGE VARCHAR(MAX),
		ERROR_LEVEL VARCHAR(MAX)
		);
		
		-- 1. [ValidatePartyRegistrationData]

		INSERT INTO #ValidatePartyRegistrationData
		EXEC ValidatePartyRegistrationData;

		-- 2. Validating CDP Data

		INSERT INTO #ValidateCDPData
		exec dbo.ValidateCDPData;

		-- 3. ValidateAllocationFactorData
	
		INSERT INTO #ValidateAllocationFactorData
		EXEC ValidateAllocationFactorData;

		-- 4. ValidateDistLossData 

		INSERT INTO #ValidateDistLossData
		EXEC ValidateDistLossData;

		-- 5. [dbo].[ValidateBilateralContractData]

		INSERT INTO #ValidateBilateralContractData
		EXEC ValidateBilateralContractData @SoFileMasterId = @soFileId_bilateralContract;


		-- 6. [dbo].[ValidateMarginalPriceData]

		INSERT INTO #ValidateMarginalPriceData
		EXEC ValidateMarginalPriceData @Year = @Year
									  ,@Month = @Month
									  ,@SoFileMasterId = @soFileId_marginalPrice;

		-- 7. [dbo].[ValidateAvailibilityData]

		INSERT INTO #ValidateAvailibilityData
		EXEC ValidateAvailibilityData @Year = @Year
									 ,@Month = @Month
									 ,@SoFileMasterId = @soFileId_AvailData;

		-- 8. [dbo].[ValidateGeneratorData]
		INSERT #ValidateGeneratorData
		EXEC [dbo].[ValidateGeneratorData];


		-- Insert into Final Temp Table.

		INSERT INTO #Final_ValidatedData
		SELECT * FROM #ValidatePartyRegistrationData vprd
		UNION
		SELECT * FROM #ValidateCDPData vc
		UNION
		SELECT * FROM #ValidateGeneratorData vgd
		UNION
		SELECT * FROM #ValidateAllocationFactorData vafd
		UNION
		SELECT * FROM #ValidateDistLossData vdld	
		UNION
		SELECT * FROM #ValidateMarginalPriceData
		UNION
		SELECT * FROM #ValidateBilateralContractData vbcd
		UNION
		SELECT * FROM #ValidateAvailibilityData vad;

		SELECT * FROM #Final_ValidatedData fvd

		-- insert into logs table from final temp table
		INSERT INTO MtSattlementProcessLogs (
			MtStatementProcess_ID
			,MtSattlementProcessLog_Message
			,MtSattlementProcessLog_ErrorLevel 
			,MtSattlementProcessLog_CreatedBy
			,MtSattlementProcessLog_CreatedOn
			)
		SELECT
			@StatementProcessId
			,vdd.LOG_MESSAGE
			,vdd.ERROR_LEVEL
			,1
			,GETDATE()
		FROM 
			#Final_ValidatedData vdd
		WHERE vdd.IS_VALID = 0;




END TRY

BEGIN CATCH
	 SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH

END

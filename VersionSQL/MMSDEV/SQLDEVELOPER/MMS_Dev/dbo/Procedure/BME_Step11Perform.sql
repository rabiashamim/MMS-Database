/****** Object:  Procedure [dbo].[BME_Step11Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure [dbo].[BME_Step11Perform] (@Year INT,
@Month INT
, @StatementProcessId DECIMAL(18, 0) --ESS Statement Process Id for current month
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		--------------------------------------------------------	
		------		MP Hourly Calculations
		--------------------------------------------------------

		IF EXISTS (SELECT TOP 1
					BmeStatementData_Id
				FROM BmeStatementDataMpMonthly_SettlementProcess
				WHERE BmeStatementData_Year = @Year
				AND BmeStatementData_Month = @Month
				AND BmeStatementData_StatementProcessId = @StatementProcessId)
		BEGIN

			DECLARE @vPredecessorId AS DECIMAL(18, 0)

			SELECT
				@vPredecessorId = [dbo].[GetESSAdjustmentPredecessorStatementId](@StatementProcessId);

			SELECT
				* INTO #tempPredecessorData
			FROM BmeStatementDataMpMonthly_SettlementProcess
			WHERE BmeStatementData_Year = @Year
			AND BmeStatementData_Month = @Month
			AND BmeStatementData_StatementProcessId = @vPredecessorId;

			UPDATE currentESS
			SET currentESS.BmeStatementData_ESSAdjustment = ISNULL(currentESS.BmeStatementData_AmountPayableReceivable, 0) - ISNULL(predecessor.BmeStatementData_AmountPayableReceivable, 0)
			FROM BmeStatementDataMpMonthly_SettlementProcess currentESS
			JOIN #tempPredecessorData predecessor
				ON predecessor.BmeStatementData_PartyRegisteration_Id = currentESS.BmeStatementData_PartyRegisteration_Id

			--where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId 




			/*********************************************************************************************************************************
			  Adjustment save
			*********************************************************************************************************************************/



			DECLARE @refMonth INT
				   ,@refYear INT
				   ,@StatementDef VARCHAR(50)


			SELECT
				@refYear = LU.LuAccountingMonth_Year
			   ,@refMonth = LU.LuAccountingMonth_Month
			   ,@StatementDef = ssd.SrStatementDef_Name
			FROM MtStatementProcess SP
			JOIN LuAccountingMonth LU
				ON LU.LuAccountingMonth_Id = SP.LuAccountingMonth_Id
			JOIN SrProcessDef spd
				ON spd.SrProcessDef_ID = SP.SrProcessDef_ID
			JOIN SrStatementDef ssd
				ON ssd.SrStatementDef_ID = spd.SrStatementDef_ID
			WHERE MtStatementProcess_ID = @StatementProcessId


			DELETE FROM [dbo].[MtStatementDataAdjustment]
			WHERE [StatementDataAdjustment_StatementRefernce_Id] = @StatementProcessId

			INSERT INTO [dbo].[MtStatementDataAdjustment] ([StatementDataAdjustment_StatementRefernce_Id]
			, [StatementDataAdjustment_StatementDefName]
			, [StatementDataAdjustment_Month]
			, [StatementDataAdjustment_Year]
			, [StatementDataAdjustment_Ref_Month]
			, [StatementDataAdjustment_Ref_Year]
			, [StatementDataAdjustment_MPID]
			, [StatementDataAdjustment_AdjustmentType]
			, [StatementDataAdjustment_Adjustment]
			, [StatementDataAdjustment_CreatedBy]
			, [StatementDataAdjustment_CreatedOn]
			, [StatementDataAdjustment_IsDeleted])
				SELECT
					BmeStatementData_StatementProcessId
				   ,@StatementDef
				   ,BmeStatementData_Month
				   ,BmeStatementData_Year
				   ,@refMonth
				   ,@refYear
				   ,BmeStatementData_PartyRegisteration_Id
				   ,'BME'
				   ,BmeStatementData_ESSAdjustment
				   ,100
				   ,GETUTCDATE()
				   ,0
				FROM BmeStatementDataMpMonthly_SettlementProcess
				WHERE BmeStatementData_StatementProcessId = @StatementProcessId


			/*********************************************************************************************************************************/
			/*********************************************************************************************************************************/


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

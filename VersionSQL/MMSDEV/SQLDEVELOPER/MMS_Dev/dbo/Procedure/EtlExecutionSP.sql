/****** Object:  Procedure [dbo].[EtlExecutionSP]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================  
-- Author: AMMAMA Gill 
-- CREATE date: 16 Jan 2023  
-- ALTER date:      
-- Description:                 
--==========================================================================================   
-- dbo.EtlExecutionSP 275,'2022-2023',1        
CREATE PROCEDURE dbo.EtlExecutionSP @pStatementProcessId DECIMAL(18, 0),
@pYear nvarchar(20),
@pUserId INT
AS
BEGIN
	BEGIN TRY

		DECLARE @vProcessDefId INT =0;

		select @vProcessDefId=SrProcessDef_ID from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId
		/*==========================================================================================  
		    Update status  
		    ==========================================================================================*/



		UPDATE MtStatementProcess
		SET MtStatementProcess_Status = 'InProcess'
		   ,MtStatementProcess_ExecutionStartDate = GETDATE()
		WHERE MtStatementProcess_ID = @pStatementProcessId;

		DECLARE @vDescription VARCHAR(1000);
		DECLARE @vRuStepDefId INT;

		EXEC [EtlClearData] @pStatementProcessId

		SET @vDescription = CONCAT('ETL Process execution for year ', @pYear, ' begins at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = 0
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1
		/*==========================================================================================  
	    Step 0   
	    ==========================================================================================*/


		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 0

EXEC [dbo].[ETLStep0And1Perform] @pStatementProcessId, @pUserId

		--EXEC [dbo].[BMC_Step0Perform] @pStatementProcessId
		--							 ,@pYear
		--							 ,@pUserId;



		SET @vDescription = CONCAT('Step # 0 - ETL completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));


		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1



		/*==========================================================================================  
		Step 1   
	    ==========================================================================================*/
		SET @vDescription = CONCAT('Step # 1 - ETL Step 1 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 1

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1

--		EXEC ETLStep1Perform @pStatementProcessId

		SET @vDescription = CONCAT('Step # 1 - ETL Step 1 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		--SELECT
		--	@vRuStepDefId = RuStepDef_ID
		--FROM RuStepDef
		--WHERE SrProcessDef_ID = @vProcessDefId
		--AND RuStepDef_BMEStepNo = 1


		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1


		/*==========================================================================================  
	      Step 2    
	      ==========================================================================================*/

		SET @vDescription = CONCAT('Step # 2 - ETL Step 2 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 2

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = NULL


		EXEC ETLStep2Perform @pStatementProcessId

		SET @vDescription = CONCAT('Step # 2 - ETL Step 2 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		--SELECT
		--	@vRuStepDefId = RuStepDef_ID
		--FROM RuStepDef
		--WHERE SrProcessDef_ID = @vProcessDefId
		--AND RuStepDef_BMEStepNo = 2


		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1


		/*==========================================================================================  
	      Step 3    
	      ==========================================================================================*/


		SET @vDescription = CONCAT('Step # 3 - ETL Step 3 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 3

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1




		EXEC ETLStep3Perform @pStatementProcessId

		SET @vDescription = CONCAT('Step # 3 - ETL Step 3 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		--SELECT
		--	@vRuStepDefId = RuStepDef_ID
		--FROM RuStepDef
		--WHERE SrProcessDef_ID = @vProcessDefId
		--AND RuStepDef_BMEStepNo = 3


		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1


		/*==========================================================================================  
	      Step 4    
	      ==========================================================================================*/
		SET @vDescription = CONCAT('Step # 4 - ETL Step 4 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 4

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1


		EXEC ETLStep4Perform @pStatementProcessId

		SET @vDescription = CONCAT('Step # 4 - ETL Step 4 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));
		--SELECT
		--	@vRuStepDefId = RuStepDef_ID
		--FROM RuStepDef
		--WHERE SrProcessDef_ID = @vProcessDefId
		--AND RuStepDef_BMEStepNo = 4


		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1

		/*==========================================================================================  
	      Step 4    
	      ==========================================================================================*/
		  if(@vProcessDefId=19)
		  BEGIN
		SET @vDescription = CONCAT('Step # 5 - ETL Step 5 started at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));

		SELECT
			@vRuStepDefId = RuStepDef_ID
		FROM RuStepDef
		WHERE SrProcessDef_ID = @vProcessDefId
		AND RuStepDef_BMEStepNo = 5

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1


		EXEC ETLStep5Perform @pStatementProcessId

		SET @vDescription = CONCAT('Step # 5 - ETL Step 5 completed at ', FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm tt', 'en-US'));


		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vDescription
												,@OutputMessage = 'Success'
												,@OutputStatus = 1

	END
		/*==========================================================================================  
			Status updation   
	      ==========================================================================================*/



		-- Set Execution status to 'Executed'      
		UPDATE MtStatementProcess
		SET MtStatementProcess_Status = 'Executed'
		   ,MtStatementProcess_ExecutionFinishDate = GETDATE()
		WHERE MtStatementProcess_ID = @pStatementProcessId;


		SELECT
			1 AS response



	END TRY
	BEGIN CATCH
		--interrupted state    
		DECLARE @vErrorMessage VARCHAR(MAX) = '';
		SELECT
			@vErrorMessage = ERROR_MESSAGE();

		EXEC [dbo].[SaveMtSattlementProcessLogs] @StatementProcessId = @pStatementProcessId
												,@pRuStepDef_ID = @vRuStepDefId
												,@LogsMessage = @vErrorMessage
												,@OutputMessage = 'Error'
												,@OutputStatus = 0

		UPDATE MtStatementProcess
		SET MtStatementProcess_Status = 'Interrupted'
		   ,MtStatementProcess_ApprovalStatus = 'Draft'
		WHERE MtStatementProcess_ID = @pStatementProcessId
		RAISERROR (@vErrorMessage, 16, -1);
		RETURN;
	END CATCH

END

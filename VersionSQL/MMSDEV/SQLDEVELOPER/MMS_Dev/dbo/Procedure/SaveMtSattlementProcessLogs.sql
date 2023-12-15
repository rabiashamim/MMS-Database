/****** Object:  Procedure [dbo].[SaveMtSattlementProcessLogs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Babar Hussain>
-- Create date: <08-04-2022, 10:30 AM>
-- Description:	<BME Logs and Output Grid>
-- =============================================

CREATE PROCEDURE dbo.SaveMtSattlementProcessLogs
-- Add the parameters for the stored procedure here
@StatementProcessId INT,
@pRuStepDef_ID INT,
@LogsMessage NVARCHAR(MAX),
@OutputMessage NVARCHAR(MAX),
@OutputStatus INT = NULL
AS
BEGIN
	------------------------ BME Logs Started -----------------------
	INSERT INTO [dbo].[MtSattlementProcessLogs] ([MtStatementProcess_ID]
	, [MtSattlementProcessLog_Message]
	, [MtSattlementProcessLog_CreatedBy]
	, [MtSattlementProcessLog_CreatedOn]
	, [MtSattlementProcessLog_ModifiedBy]
	, [MtSattlementProcessLog__ModifiedOn]
	, [MtSattlementProcessLog_ErrorLevel])
		VALUES (@StatementProcessId, @LogsMessage, 1, GETDATE(), 1, GETDATE(), NULL)

	------------------------ BME Logs Ended -------------------------

	------------------------ OUTPUT Grid Started --------------------
	DECLARE @MTSPStepId AS INT
	SELECT
		@MTSPStepId = MtStatementProcessSteps_ID
	FROM MtStatementProcessSteps
	WHERE MtStatementProcess_ID = @StatementProcessId
	AND RuStepDef_ID = @pRuStepDef_ID
	IF (@MTSPStepId > 0)
	BEGIN
		UPDATE MtStatementProcessSteps
		SET MtStatementProcessSteps_Status = @OutputStatus
		   ,MtStatementProcessSteps_Description = @OutputMessage
		   ,MtStatementProcessSteps_ModifiedBy = 1
		   ,MtStatementProcessSteps_ModifiedOn = GETDATE()
		WHERE MtStatementProcessSteps_ID = @MTSPStepId
	END
	ELSE
	BEGIN
		INSERT INTO MtStatementProcessSteps
			VALUES (@OutputStatus, @OutputMessage, @StatementProcessId, @pRuStepDef_ID, 1, GETDATE(), 1, GETDATE())
	END

	/*********************************************************************************************************
	* BME step Post Validations logic PSS | FSS
	*********************************************************************************************************/
	DECLARE @vRuProcessDef_ID DECIMAL(18, 0)
	DECLARE @vRuStepDef_ID DECIMAL(18, 0)

	SELECT @vRuProcessDef_ID=SrProcessDef_ID FROM MtStatementProcess WHERE MtStatementProcess_ID=@StatementProcessId

	IF (@vRuProcessDef_ID IN (1, 4)
		AND @pRuStepDef_ID = (SELECT
				rsd.RuStepDef_ID
			FROM RuStepDef rsd
			WHERE rsd.SrProcessDef_ID = @vRuProcessDef_ID
			AND rsd.RuStepDef_BMEStepNo = 10
			AND ISNULL(rsd.RuStepDef_IsDeleted, 0) = 0)
		)
	BEGIN
		
		SELECT
			@vRuStepDef_ID = rsd.RuStepDef_ID
		FROM RuStepDef rsd
		WHERE rsd.SrProcessDef_ID = @vRuProcessDef_ID
		AND rsd.RuStepDef_BMEStepNo = 11;

		EXEC dbo.SaveMtSattlementProcessLogs @StatementProcessId = @StatementProcessId
												,@pRuStepDef_ID = @vRuStepDef_ID
												,@LogsMessage = 'Post validations'
												,@OutputMessage = 'BME Step Post validations'
												,@OutputStatus = 1;

	END

	/*********************************************************************************************************
	* BME step Post Validations logic ESS
	*********************************************************************************************************/


	ELSE if (@vRuProcessDef_ID =7
		AND @pRuStepDef_ID = (SELECT
				rsd.RuStepDef_ID
			FROM RuStepDef rsd
			WHERE rsd.SrProcessDef_ID = @vRuProcessDef_ID
			AND rsd.RuStepDef_BMEStepNo = 11
			AND ISNULL(rsd.RuStepDef_IsDeleted, 0) = 0)
		)
	BEGIN
		
		SELECT
			@vRuStepDef_ID = rsd.RuStepDef_ID
		FROM RuStepDef rsd
		WHERE rsd.SrProcessDef_ID = @vRuProcessDef_ID
		AND rsd.RuStepDef_BMEStepNo = 12;

		EXEC dbo.SaveMtSattlementProcessLogs @StatementProcessId = @StatementProcessId
												,@pRuStepDef_ID = @vRuStepDef_ID
												,@LogsMessage = 'Post validations'
												,@OutputMessage = 'BME Step Post validations'
												,@OutputStatus = 1;

	END


	------------------------ OUTPUT Grid Ended --------------------
	RETURN @@rowcount;
END

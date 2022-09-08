/****** Object:  Procedure [dbo].[SaveMtSattlementProcessLogs]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Babar Hussain>
-- Create date: <08-04-2022, 10:30 AM>
-- Description:	<BME Logs and Output Grid>
-- =============================================

CREATE PROCEDURE [dbo].[SaveMtSattlementProcessLogs] 
	-- Add the parameters for the stored procedure here
@StatementProcessId INT,
@pRuStepDef_ID INT,
@LogsMessage NVARCHAR (max),
@OutputMessage NVARCHAR (max),
@OutputStatus INT = NULL
AS
BEGIN
------------------------ BME Logs Started -----------------------
INSERT INTO [dbo].[MtSattlementProcessLogs]
           ([MtStatementProcess_ID]
           ,[MtSattlementProcessLog_Message]
           ,[MtSattlementProcessLog_CreatedBy]
           ,[MtSattlementProcessLog_CreatedOn]
           ,[MtSattlementProcessLog_ModifiedBy]
           ,[MtSattlementProcessLog__ModifiedOn]
           ,[MtSattlementProcessLog_ErrorLevel])
	VALUES (@StatementProcessId, @LogsMessage, 1, GETDATE(), 1, GETDATE(),null)

------------------------ BME Logs Ended -------------------------

------------------------ OUTPUT Grid Started --------------------
	Declare @MTSPStepId as int
		SELECT @MTSPStepId = MtStatementProcessSteps_ID FROM MtStatementProcessSteps
		where MtStatementProcess_ID = @StatementProcessId and RuStepDef_ID = @pRuStepDef_ID
	IF (@MTSPStepId > 0)
	BEGIN
		UPDATE MtStatementProcessSteps SET
			MtStatementProcessSteps_Status = @OutputStatus, 
			MtStatementProcessSteps_Description = @OutputMessage,
			MtStatementProcessSteps_ModifiedBy = 1, 
			MtStatementProcessSteps_ModifiedOn = GETDATE()
		WHERE MtStatementProcessSteps_ID = @MTSPStepId
	END
	ELSE
	BEGIN
		INSERT INTO MtStatementProcessSteps VALUES 
		(@OutputStatus, @OutputMessage, @StatementProcessId, @pRuStepDef_ID, 1, GETDATE(), 1, GETDATE())
	END
------------------------ OUTPUT Grid Ended --------------------
	RETURN @@ROWCOUNT;	
END

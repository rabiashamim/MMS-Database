/****** Object:  Procedure [dbo].[FCD_InsertProcessLogs]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.FCD_InsertProcessLogs @pMtFCDMaster_Id DECIMAL(18, 0)
, @pStepNo INT
, @pStatus INT   -- 1 (Step Started)		2(Step Completed)
, @pMessage VARCHAR(200) = NULL
, @pUserId INT
,@pSrFCDProcessDef_Id int
AS
BEGIN

	DECLARE @vRuFCDStepDef_ID DECIMAL(18, 0)

	SELECT
		@vRuFCDStepDef_ID = RuFCDStepDef_ID
	FROM [dbo].[RuFCDStepDef]
	WHERE RuFCDStepDef_FCDStepNo = @pStepNo
	and SrFCDProcessDef_Id=@pSrFCDProcessDef_Id
	-----------------	Insert into Process Logs

	INSERT INTO [dbo].[MtFCDProcessLog] ([MtFCDMaster_Id]
	, [MtFCDProcessLog_Message]
	, [MtFCDProcessLog_CreatedBy]
	, [MtFCDProcessLog_CreatedOn]
	,SrFCDProcessDef_Id)
		VALUES (@pMtFCDMaster_Id, @pMessage, @pUserId, GETDATE(),@pSrFCDProcessDef_Id)


	-----------------	Insert into Process Steps

	IF NOT EXISTS (SELECT TOP 1
				1
			FROM [dbo].[MtFCDProcessSteps]
			WHERE MtFCDMaster_Id = @pMtFCDMaster_Id
			AND RuFCDStepDef_ID = @vRuFCDStepDef_ID
			and SrFCDProcessDef_Id=@pSrFCDProcessDef_Id)
	BEGIN
		IF (@pStatus = 2)
		BEGIN
			INSERT INTO [dbo].[MtFCDProcessSteps] ([MtFCDProcessSteps_Status]
			, [MtFCDProcessSteps_Description]
			, [MtFCDMaster_Id]
			, [RuFCDStepDef_ID]
			, [MtFCDProcessSteps_CreatedBy]
			, [MtFCDProcessSteps_CreatedOn]
			,SrFCDProcessDef_Id)
				VALUES (1, 'SUCCCESS', @pMtFCDMaster_Id, @vRuFCDStepDef_ID, @pUserId, GETDATE(),@pSrFCDProcessDef_Id)
		END

		IF (@pStatus = 3)
		BEGIN
			INSERT INTO [dbo].[MtFCDProcessSteps] ([MtFCDProcessSteps_Status]
			, [MtFCDProcessSteps_Description]
			, [MtFCDMaster_Id]
			, [RuFCDStepDef_ID]
			, [MtFCDProcessSteps_CreatedBy]
			, [MtFCDProcessSteps_CreatedOn]
			,SrFCDProcessDef_Id)
				VALUES (0, 'Failed', @pMtFCDMaster_Id, @vRuFCDStepDef_ID, @pUserId, GETDATE(),@pSrFCDProcessDef_Id)
		END
	END
END

/****** Object:  Procedure [dbo].[SaveBMEInputsSOFilesVersions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<BABAR HUSSAIN>
-- Create date: <11-04-2022 03:30 PM>
-- Description:	<BME INPUT GRID SO FILES VERSIONS>
-- =============================================
CREATE PROCEDURE [dbo].[SaveBMEInputsSOFilesVersions]
@pStatementProcessId AS INT,
@pSOFileTemplateId AS INT,
@pSOFileVersion AS INT
AS
BEGIN
	DECLARE @pBMEInputsSOFilesVersions_Id AS INT
	SELECT @pBMEInputsSOFilesVersions_Id = BMEInputsSOFilesVersions_Id FROM BMEInputsSOFilesVersions WHERE SettlementProcessId = @pStatementProcessId AND SOFileTemplateId = @pSOFileTemplateId;
	
	IF (@pBMEInputsSOFilesVersions_Id > 0)
	BEGIN
		UPDATE BMEInputsSOFilesVersions SET
			SettlementProcessId = @pStatementProcessId,
			SOFileTemplateId = @pSOFileTemplateId,
			Version = @pSOFileVersion,
			BMEInputsSOFilesVersions_ModifiedOn = GETDATE()
		WHERE BMEInputsSOFilesVersions_Id = @pBMEInputsSOFilesVersions_Id;
	END

	ELSE
	BEGIN
		INSERT INTO BMEInputsSOFilesVersions 
		VALUES (@pStatementProcessId, @pSOFileTemplateId, @pSOFileVersion, 1, GETDATE(), 1, GETDATE(),null)
	END
END

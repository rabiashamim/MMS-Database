/****** Object:  ScalarFunction [dbo].[GetBMCStatementProcessID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ammama Gill  
-- Create date: 11-01-2023  
-- Description: Returns the relevant Statement ID of the predecessor (if exists)  
-- =============================================  


CREATE FUNCTION GetBMCStatementProcessID (@pStatementProcessId DECIMAL(18, 0))
RETURNS DECIMAL(18, 0)
AS
BEGIN
	DECLARE @vLuAccountingYear INT
		   ,@vSrProcessDef_ID INT
		   ,@vBMCStatementId DECIMAL(18, 0);

	SELECT
		@vLuAccountingYear =
		msp.LuAccountingMonth_Id_Current
	   ,@vSrProcessDef_ID =
		msp.SrProcessDef_ID
	FROM MtStatementProcess msp
	WHERE msp.MtStatementProcess_ID = @pStatementProcessId
	AND ISNULL(msp.MtStatementProcess_IsDeleted, 0) = 0

	SELECT
		@vBMCStatementId =
		msp.MtStatementProcess_ID
	FROM MtStatementProcess msp
	WHERE msp.LuAccountingMonth_Id_Current = @vLuAccountingYear
	AND msp.SrProcessDef_ID = (SELECT
			spd.SrProcessDef_PredecessorID
		FROM SrProcessDef spd
		WHERE spd.SrProcessDef_ID = @vSrProcessDef_ID)
	--AND msp.MtStatementProcess_ApprovalStatus = 'Approved'  
	AND ISNULL(msp.MtStatementProcess_IsDeleted, 0) = 0

	RETURN @vBMCStatementId;

END  
  

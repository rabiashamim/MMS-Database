/****** Object:  Procedure [dbo].[SettlementStatusChange]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author: Ali Imran
-- Create date: 06-Sep-2023  
-- Description: 
-- =============================================  
--SettlementStatusChange 114,'Executed','Draft',100
CREATE   Proceduredbo.SettlementStatusChange @pStatementProcess_ID INT,
@pProcessStatus VARCHAR(10),
@pApprovalProcessStatus VARCHAR(10),
@pUserId INT,
@pIsFinished BIT=0
AS
BEGIN


	UPDATE MtStatementProcess
	SET MtStatementProcess_Status = @pProcessStatus
	   ,MtStatementProcess_ApprovalStatus = @pApprovalProcessStatus
	   ,MtStatementProcess_ModifiedBy = @pUserId
	   ,MtStatementProcess_ModifiedOn = GETDATE()
	   ,MtStatementProcess_UpdatedDate = GETDATE()
	   ,MtStatementProcess_ExecutionFinishDate=CASE WHEN @pIsFinished=0 THEN '' ELSE GETDATE() end
	WHERE MtStatementProcess_ID = @pStatementProcess_ID

	SELECT
		@@rowcount
END

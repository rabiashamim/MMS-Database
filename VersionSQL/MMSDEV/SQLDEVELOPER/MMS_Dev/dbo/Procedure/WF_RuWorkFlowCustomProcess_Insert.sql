/****** Object:  Procedure [dbo].[WF_RuWorkFlowCustomProcess_Insert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================                
-- Author:  ALI IMRAN               
-- Create date: 07 july 2023
-- Description: 
-- ============================================= 
CREATE PROCEDURE WF_RuWorkFlowCustomProcess_Insert @pRuModules_Id INT
, @pSubProcessId INT
, @pProcessName NVARCHAR(50)
, @pUserId INT
AS
BEGIN
	INSERT INTO [dbo].[RuWorkFlowCustomProcess] ([RuModules_Id]
	, [RuWorkFlowCustomProcess_ProcessId]
	, [RuWorkFlowCustomProcess_ProcessName]
	, [RuWorkFlowCustomProcess_CreatedOn]
	, [RuWorkFlowCustomProcess_CreatedBy]
	, [RuWorkFlowCustomProcess_IsDeleted])
		VALUES (@pRuModules_Id, @pSubProcessId, @pProcessName, GETDATE(), @pUserId, 0)


END

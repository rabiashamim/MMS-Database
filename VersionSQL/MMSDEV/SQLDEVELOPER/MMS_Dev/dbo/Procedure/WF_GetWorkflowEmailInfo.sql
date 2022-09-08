/****** Object:  Procedure [dbo].[WF_GetWorkflowEmailInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.WF_GetWorkflowEmailInfo
	-- Add the parameters for the stored procedure here
	(@ProcessId INT,    
	 @user_id INT   
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT   
	  		  [dbo].[FN_WF_SENDER_NAME](@ProcessId,@user_id) LastSender, DBO.FN_WF_Init_NAME_EMAIL(@ProcessId) Initiator


END

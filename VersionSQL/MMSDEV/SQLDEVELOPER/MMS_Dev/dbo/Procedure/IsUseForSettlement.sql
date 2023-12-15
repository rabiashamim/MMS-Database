/****** Object:  Procedure [dbo].[IsUseForSettlement]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Alina Javed>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE dbo.IsUseForSettlement
	-- Add the parameters for the stored procedure here
@pFileMasterId DECIMAL(18,0),                
@pUserId DECIMAL(18,0),
@pIsUseForSettlement bit=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update MtSOFileMaster set MtSOFileMaster_IsUseForSettlement=@pIsUseForSettlement
	where MtSOFileMaster_Id= @pFileMasterId

	------------------------ logs--------------    
 DECLARE @pSOFileTemplate INT = 0;    
 DECLARE @tempname NVARCHAR(MAX) = NULL;       
 Declare @version int=0;
SELECT
	@version = MtSOFileMaster_Version
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId

SELECT
	@pSOFileTemplate = LuSOFileTemplate_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId 

SELECT
	@tempname = LuSOFileTemplate_Name
FROM LuSOFileTemplate
WHERE LuSOFileTemplate_Id = @pSOFileTemplate

DECLARE @vMonthId_Current VARCHAR(MAX);
SELECT
	@vMonthId_Current = LuAccountingMonth_Id
FROM MtSOFileMaster
WHERE MtSOFileMaster_Id = @pFileMasterId
DECLARE @period VARCHAR(20);
SET @period = [dbo].[GetSettlementMonthYear](@vMonthId_Current)
Declare @output VARCHAR(max);
if(@pIsUseForSettlement=1)
begin
SET @output = 'Use for Settlement Enabled for Dataset: ' +@tempname+' .Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ', Version:' + CONVERT(VARCHAR(MAX), @version)+ ', File Master Id: ' +CONVERT(VARCHAR(MAX), @pFileMasterId) 

EXEC [dbo].[SystemLogs] @user = @pUserId
					   ,@moduleName = 'Data Management'
					   ,@CrudOperationName = 'Update'
					   ,@logMessage = @output
end

ELSE
BEGIN
SET @output = 'Use for Settlement Disabled for Dataset: ' +@tempname+' .Settlement Period:' + CONVERT(VARCHAR(MAX), @period) + ', Version:' + CONVERT(VARCHAR(MAX), @version)+ ', File Master Id: ' +CONVERT(VARCHAR(MAX), @pFileMasterId) 

EXEC [dbo].[SystemLogs] @user = @pUserId
					   ,@moduleName = 'Data Management'
					   ,@CrudOperationName = 'Update'
					   ,@logMessage = @output
END

END

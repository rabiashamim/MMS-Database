/****** Object:  Function [dbo].[GetMonthNameFromMtStatementProcessId]    Committed by VersionSQL https://www.versionsql.com ******/

-- select [dbo].[GetMonthNameFromMtStatementProcessId](180)
CREATE function [dbo].[GetMonthNameFromMtStatementProcessId] 
(
@pStatementProcessId decimal(18,0)
)
RETURNS nvarchar(max)
AS
BEGIN
	Declare @vMonthName  nvarchar(max)
	
	
	DECLARE @vPredecessorStatementProcessId int
	DECLARE @vLuAccountMonth_Id_Current int
	DECLARE @vSrProcessDefId int
	Declare @vProcessName nvarchar(max)
	Declare @vLuAccountingMonthName nvarchar(max)
	
	select @vLuAccountMonth_Id_Current=LuAccountingMonth_Id_Current, @vSrProcessDefId=SrProcessDef_ID from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId;

	select @vProcessName=CONCAT(SrProcessDef.SrProcessDef_Name ,' - ',SrStatementDef.SrStatementDef_Name) from SrProcessDef join SrStatementDef on SrProcessDef.SrStatementDef_ID=SrStatementDef.SrStatementDef_ID where SrProcessDef_ID=@vSrProcessDefId;

	select @vLuAccountingMonthName=LuAccountingMonth_MonthName from LuAccountingMonth where LuAccountingMonth_Id=@vLuAccountMonth_Id_Current;

	set @vMonthName=CONCAT(@vProcessName , ' for ',@vLuAccountingMonthName)
	-- Return the result of the function
	RETURN @vMonthName

END

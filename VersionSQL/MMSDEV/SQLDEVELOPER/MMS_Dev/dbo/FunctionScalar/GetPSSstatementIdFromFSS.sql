/****** Object:  Function [dbo].[GetPSSstatementIdFromFSS]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
--select [dbo].[GetMtSoFileMasterId] (3,1) --38
-- =============================================
CREATE function [dbo].[GetPSSstatementIdFromFSS]
(
	@pSettlementProcessId decimal(18,0)
)
RETURNS int
AS
BEGIN
	DECLARE @PssID decimal(18,0)


select @PssID= MtStatementProcess_ID from MtStatementProcess where LuAccountingMonth_Id_Current=(select LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pSettlementProcessId) and SrProcessDef_ID=(
select NewSrProcessDef_ID= 
	case WHEN SrProcessDef_ID=4 Then 1
	When SrProcessDef_ID=5 then 2
	WHEN SrProcessDef_ID=6 then 3 END
 from MtStatementProcess WHERE MtStatementProcess_ID=@pSettlementProcessId--SrProcessDef_ID=4
) and ISNULL(MtStatementProcess_IsDeleted,0)=0

 RETURN @PssID

END

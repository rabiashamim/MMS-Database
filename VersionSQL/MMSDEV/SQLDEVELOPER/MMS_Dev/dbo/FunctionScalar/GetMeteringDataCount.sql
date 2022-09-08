/****** Object:  Function [dbo].[GetMeteringDataCount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE function [dbo].[GetMeteringDataCount]
(
@MtStatementProcessId as int
)
RETURNS int
AS
BEGIN

Declare @vMonth as int, @vYear as int, @vResult as int

select @vMonth= LuAccountingMonth_Month, @vYear=LuAccountingMonth_Year from LuAccountingMonth where LuAccountingMonth_Id in (
select LuAccountingMonth_Id_Current from mtstatementProcess where MtStatementProcess_ID=@MtStatementProcessId
)

select @VResult=count(1) from MtBvmReading where DATEPART(month, MtBvmReading_ReadingDate)=@vMonth and DATEPART(year, MtBvmReading_ReadingDate)=@vYear;

	RETURN @vResult

END

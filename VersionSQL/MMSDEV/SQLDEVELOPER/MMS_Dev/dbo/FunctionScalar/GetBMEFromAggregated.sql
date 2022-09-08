/****** Object:  Function [dbo].[GetBMEFromAggregated]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE function [dbo].[GetBMEFromAggregated] 
(
@pAggregatedId decimal(18,0)
)
RETURNS decimal(18,0)
AS
BEGIN

	DECLARE @vBmeId decimal(18,0)

select @vBmeId=predecessor.MtStatementProcess_ID from 
MtStatementProcess predecessor
JOIN MtStatementProcess currentS on currentS.LuAccountingMonth_Id_Current = predecessor.LuAccountingMonth_Id_Current
and IsNull(predecessor.MtStatementProcess_IsDeleted,0)=0
 where currentS.MtStatementProcess_ID=229
 and predecessor.SrProcessDef_ID =(
	 select spd.SrProcessDef_ID from SrProcessDef spd where spd.SrStatementDef_ID in (
			select DISTINCT SrStatementDef_ID from SrProcessDef spd1 where currentS.SrProcessDef_ID=spd1.SrProcessDef_ID 
	 ) 
	 and spd.SrProcessDef_ID in (1,4)
 )

	RETURN @vBmeId

END

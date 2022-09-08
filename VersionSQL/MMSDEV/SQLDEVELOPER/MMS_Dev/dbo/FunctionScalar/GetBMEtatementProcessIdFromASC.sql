/****** Object:  Function [dbo].[GetBMEtatementProcessIdFromASC]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
--DROP FUNCTION [dbo].[GetBMESettlementProcessId]
CREATE function [dbo].[GetBMEtatementProcessIdFromASC] 
(
@AscSettlementProcessId decimal(18,0)
)
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @BMESettlementProcessId decimal(18,0)

SELECT @BMESettlementProcessId=msp1.MtStatementProcess_ID FROM MtStatementProcess msp1 WHERE 
 msp1.LuAccountingMonth_Id_Current= (SELECT LuAccountingMonth_Id_Current FROM MtStatementProcess WHERE MtStatementProcess_ID=@AscSettlementProcessId)
AND IsNull(msp1.MtStatementProcess_IsDeleted,0)=0
AND msp1.SrProcessDef_ID =
---------------------------------------------------------
(
SELECT
spd.SrProcessDef_ID
FROM SrProcessDef spd
WHERE spd.SrProcessDef_ID IN (1, 4, 7)
AND spd.SrStatementDef_ID = (
---------------------------------------------------------
SELECT
SrStatementDef_ID
FROM SrProcessDef spd
WHERE spd.SrProcessDef_ID = (
---------------------------------------------------------
SELECT
SrProcessDef_ID
FROM MtStatementProcess msp
WHERE msp.MtStatementProcess_ID IN (@AscSettlementProcessId)

)
---------------------------------------------------------
)
)
---------------------------------------------------------
---------------------------------------------------------
	-- Return the result of the function
	RETURN @BMESettlementProcessId

END

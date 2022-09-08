/****** Object:  Procedure [dbo].[GetBmeSettlementSteps]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[GetBmeSettlementSteps]  9
CREATE PROCEDURE [dbo].[GetBmeSettlementSteps]    
@pStatementProcessId decimal(18,0)   =null 

AS    
BEGIN    
---------------------------Get Process Id

Declare @SrProcessDef_Id as int
Declare @LuAccountingMonth_Id as int

select @SrProcessDef_Id= SrProcessDef_ID, @LuAccountingMonth_Id=LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId

------------------------------------- Get Data from RuStepDef
--select *,'OK' as RuStepDefStatus  from RuStepDef where SrProcessDef_ID=@SrProcessDef_Id

SELECT RSD.RuStepDef_ID, RSD.RuStepDef_Name, SPS.MtStatementProcessSteps_Status, ISNULL(RSD.RuStepDef_BMEStepNo,0) as RuStepDef_BMEStepNo, SPS.MtStatementProcessSteps_Description
FROM RuStepDef RSD
LEFT JOIN MtStatementProcessSteps SPS ON RSD.RuStepDef_ID = SPS.RuStepDef_ID AND SPS.MtStatementProcess_ID = @pStatementProcessId
WHERE
RSD.SrProcessDef_ID = @SrProcessDef_Id
AND ISNULL(RSD.RuStepDef_IsDeleted,0) = 0
ORDER BY RuStepDef_BMEStepNo ASC

END 

-------------------------------------

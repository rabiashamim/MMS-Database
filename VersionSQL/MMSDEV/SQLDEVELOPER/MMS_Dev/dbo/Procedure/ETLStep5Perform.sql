/****** Object:  Procedure [dbo].[ETLStep5Perform]    Committed by VersionSQL https://www.versionsql.com ******/

--==========================================================================================
-- Author: Sadaf Malik
-- CREATE date: 13 Jan 2022
-- ALTER date:    
-- Description:               
--==========================================================================================
 --[dbo].[ETLStep1Perform] 34
/*****   25-NTDC	26-Pak Mitiari
Select * FROM [dbo].[EtlTspHourly] [dbo].[EtlClearData]
Select * FROM [dbo].[EtlHourly]
Select * from [dbo].[EtlTspData]
Select * from [dbo].[EtlMpData]
******/
CREATE         PROCEDURE dbo.ETLStep5Perform 
@pStatementProcessId DECIMAL(18, 0)
AS
BEGIN

DECLARE @vluaccountingMonth AS INT, @vRefStatementProcessId as decimal(18,0);


select 	@vluaccountingMonth =LuAccountingMonth_Id_Current
from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId
and ISNULL(MtStatementProcess_IsDeleted,0)=0


select @vRefStatementProcessId=max(MtStatementProcess_ID) from MtStatementProcess where @vluaccountingMonth=LuAccountingMonth_Id_Current
--case when  SrProcessDef_ID in (17,18) then LuAccountingMonth_Id_Current else LuAccountingMonth_Id end
and ISNULL(MtStatementProcess_IsDeleted,0)=0 and MtStatementProcess_ID <> @pStatementProcessId


/******************************************************************
		INSERT ESS Adjustments data
*************************************************************************/
INSERT INTO [dbo].[EtlEyssAdjustmentData]
(
	[MtStatementProcess_ID],
	[MtStatementProcess_ID_Reference],
	[MTPartyRegisteration_Id] ,
	[EtlEyssAdjustmentData_TotalPayableExcessLosses],
	[EtlEyssAdjustmentData_TotalExcessLossesCompensation],
	[EtlEyssAdjustmentData_NetAdjustments] 
)
select 
@pStatementProcessId
,@vRefStatementProcessId
,EtlNew.MTPartyRegisteration_Id
,0 as TotalPayableForExcessLosses
,EtlPrevious.EtlMpData_TotalExcessLossesCompensation
,(EtlPrevious.EtlMpData_TotalExcessLossesCompensation-0) - (EtlNew.EtlMpData_TotalExcessLossesCompensation-0) as NetAdjustment 
from 
EtlMpData EtlPrevious
inner join EtlMpData EtlNew on EtlNew.MTPartyRegisteration_Id=EtlPrevious.MTPartyRegisteration_Id

where EtlPrevious.MtStatementProcess_ID=@vRefStatementProcessId
and EtlNew.MtStatementProcess_ID=@pStatementProcessId

union

select 
@pStatementProcessId
,@vRefStatementProcessId
,EtlPrevious.MTPartyRegisteration_Id
,EtlPrevious.EtlTspData_TotalPayableExcessLosses
,0 as TotalExcessLossCompensation
,(0-EtlPrevious.EtlTspData_TotalPayableExcessLosses) - (0-EtlNew.EtlTspData_TotalPayableExcessLosses-0) as NetAdjustment 
from EtlTspData EtlPrevious 
inner join EtlTspData EtlNew on EtlNew.MTPartyRegisteration_Id=EtlPrevious.MTPartyRegisteration_Id

where EtlPrevious.MtStatementProcess_ID=@vRefStatementProcessId
and EtlNew.MtStatementProcess_ID=@pStatementProcessId


END

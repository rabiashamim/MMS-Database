/****** Object:  Procedure [dbo].[ReportAllocationFactors]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Sadaf Malik
--CreatedDate : 17 Aug 2022
--Comments : Aggregated Reports Summary
--======================================================================

--dbo.ReportAllocationFactors 27
CREATE PROCEDURE dbo.ReportAllocationFactors
@pAggregatedStatementId INT=null

AS
BEGIN

Declare @EffectiveFromDate as Date=null
Declare @EffectiveToDate as Date=null




select @EffectiveFromDate=DATEFROMPARTS(LuAccountingMonth_Year,LuAccountingMonth_Month,1) from LuAccountingMonth where LuAccountingMonth_Id in (
select LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pAggregatedStatementId
);

set @EffectiveToDate=DATEADD(month,1,@EffectiveFromDate);


select 
ROW_NUMBER() OVER(Order by laf.MtPartyRegisteration_Id) as [Sr]
,mpr.MtPartyRegisteration_Name as [Supplier of Last Resort Name]
, case when laf.MtPartyRegisteration_Id=12 THEN 'As per its PPAA with CPPA-SPA (up to 2050 MW)' ELSE
 CAST(LuAllocationFactors_Factor as varchar(10))+'%' END as [Allocation Factor/Quantum]
from LuAllocationFactors laf
inner join MtPartyRegisteration mpr on mpr.MtPartyRegisteration_Id=laf.MtPartyRegisteration_Id
where LuAllocationFactors_EffectiveFrom<=@EffectiveFromDate
and LuAllocationFactors_EffectiveTo>=@EffectiveToDate
and mpr.LuStatus_Code_Applicant not in 
(
'ASUS'
,'ATER'
,'DER'
,'REJ'
)

END

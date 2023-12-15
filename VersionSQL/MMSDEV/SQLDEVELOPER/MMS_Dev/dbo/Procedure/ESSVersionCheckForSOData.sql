/****** Object:  Procedure [dbo].[ESSVersionCheckForSOData]    Committed by VersionSQL https://www.versionsql.com ******/

-- dbo.ESSVersionCheckForSOData 168

CREATE PROCEDURE dbo.ESSVersionCheckForSOData
@pESSProcessId int
AS
BEGIN

DROP TABLE IF EXISTS #tempFSSVersions ,#tempESSVersions


Declare @vFSSProcessId as Decimal(8,0)=null;
Declare @vFSSProcessDefId as Decimal(8,0)=null;
Declare @vMisMatchSORecords as int=null;
Declare @vNewMeteringRecords as int=null;
Declare @vLuAccountingMonthId as int=null
,@vSrProcessDef_ID INT=NULL;

select @vFSSProcessDefId=case when SrProcessDef_ID=7 then 4  when SrProcessDef_ID=8 then 5 END,
@vLuAccountingMonthId=LuAccountingMonth_Id_Current,  
@vSrProcessDef_ID=SrProcessDef_ID
from MtStatementProcess where MtStatementProcess_ID=@pESSProcessId and isnull(MtStatementProcess_IsDeleted,0)=0
-- LuAccountingMonth_Id_Current=16 and

select @vFSSProcessId=MtStatementProcess_ID from MtStatementProcess where  LuAccountingMonth_Id_Current=@vLuAccountingMonthId  and SrProcessDef_ID=@vFSSProcessDefId

select SOFileTemplateId	,Version into #tempFSSVersions from BMEInputsSOFilesVersions where SettlementProcessId=@vFSSProcessId
select  SOFileTemplateId,Version into #tempESSVersions from BMEInputsSOFilesVersions where SettlementProcessId=@pESSProcessId


select  @vMisMatchSORecords=count(1)  from #tempESSVersions ess Join #tempFSSVersions fss on ess.SOFileTemplateId=fss.SOFileTemplateId
where ess.Version>fss.Version 

--select * into #tempMisMatch from #tempFSSVersions 
--EXCEPT
--select * from #tempESSVersions



--select @vMisMatchSORecords=count(1) from #tempMisMatch


----------------------------------	Metering Data Check starts

IF(@vSrProcessDef_ID=8)
BEGIN
SET @vNewMeteringRecords=2;
END
ELSE
BEGIN

SELECT @vNewMeteringRecords=count(1) FROM MtBvmReading
WHERE DATEPART(YEAR, MtBvmReading_ReadingDate) = (select LuAccountingMonth_Year from LuAccountingMonth where LuAccountingMonth_Id=@vLuAccountingMonthId)
AND DATEPART(MONTH, MtBvmReading_ReadingDate) = (select LuAccountingMonth_Month from LuAccountingMonth where LuAccountingMonth_Id=@vLuAccountingMonthId)
AND ISNULL(IsAlreadyUsedInBME,0)=0

END


select @vMisMatchSORecords as MisMatchSORecords, @vNewMeteringRecords as NewMeteringRecords;


END

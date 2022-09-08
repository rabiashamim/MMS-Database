/****** Object:  Procedure [dbo].[GetBmeSettlementInputs]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[GetBmeSettlementInputs] 30
CREATE PROCEDURE [dbo].[GetBmeSettlementInputs]    
@pStatementProcessId decimal(18,0)   =null 

AS    
BEGIN    
---------------------------Get Process Id

Declare @SrProcessDef_Id as int
Declare @LuAccountingMonth_Id as int



select @SrProcessDef_Id= SrProcessDef_ID, @LuAccountingMonth_Id=LuAccountingMonth_Id_Current from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId

----For ESS, Get month ID of previous months
--if(@SrProcessDef_Id=7 or @SrProcessDef_Id=8 or @SrProcessDef_Id=9)
--BEGIN
--	select  @LuAccountingMonth_Id=LuAccountingMonth_Id from MtStatementProcess where MtStatementProcess_ID=@pStatementProcessId
--END

print @LuAccountingMonth_Id
------------------------------------- Get Data from RuProcessInputDef
select *  into #temp from RuProcessInputDef where SrProcessDef_ID=@SrProcessDef_Id


select LuSOFileTemplate_Id , versionsList = 
    STUFF((SELECT DISTINCT ', ' + CONVERT(VARCHAR(MAX), b.MtSOFileMaster_Version)
           FROM MtSOFileMaster b
           WHERE b.LuSOFileTemplate_Id = a.LuSOFileTemplate_Id
		   and IsNULL(b.MtSOFileMaster_IsDeleted,0)=0
		   and b.LuAccountingMonth_Id =@LuAccountingMonth_Id
		   and IsNULL( b.MtSOFileMaster_IsUseForSettlement,0)=1
		   and b.LuStatus_Code='APPR'
--		   order by b.MtSOFileMaster_Version desc
          FOR XML PATH('')), 1, 2, '')
		  into #temp1
from #temp a
GROUP by LuSOFileTemplate_Id


select RuProcessInputDef_ID,	RuProcessInputDef_Name, ISNULL(a.LuSOFileTemplate_Id,0) as LuSOFileTemplate_Id, RuProcessInputDef_Description, v.Version ,
--versionsList
case when @SrProcessDef_Id in (2,5,8) and a.LuSOFileTemplate_Id in (1,2) then cast(v.Version as NVARCHAR(MAX)) else
versionsList END as versionsList
, c.LuSOFileTemplate_Url
from #temp a 
left join #temp1 b on a.LuSOFileTemplate_Id=b.LuSOFileTemplate_Id
left join LuSOFileTemplate c on a.LuSOFileTemplate_Id = c.LuSOFileTemplate_Id
left join BMEInputsSOFilesVersions v on a.LuSOFileTemplate_Id = v.SOFileTemplateId AND v.SettlementProcessId = @pStatementProcessId
END 

-------------------------------------

--select top 1 MtSOFileMaster_Id from MtMarginalPrice
-- select * from RuProcessInputDef

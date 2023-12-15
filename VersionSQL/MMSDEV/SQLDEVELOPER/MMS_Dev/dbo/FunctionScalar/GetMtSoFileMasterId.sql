/****** Object:  ScalarFunction [dbo].[GetMtSoFileMasterId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
--select dbo.GetMtSoFileMasterId (3,1) --38
-- =============================================
CREATE FUNCTION dbo.GetMtSoFileMasterId
(
	@pSettlementProcessId decimal(18,0)
	,@pLuSOFileTemplateId int
)
RETURNS int
AS
BEGIN
	DECLARE @MtSOFileMasterID decimal(18,0)
select @MtSOFileMasterID=MSM.MtSOFileMaster_Id from MtSOFileMaster MSM  
LEFt join 
(
select MSP.LuAccountingMonth_Id_Current, IFV.Version, IFV.SOFileTemplateId from MtStatementProcess MSP
LEFT JOIN BMEInputsSOFilesVersions IFV on IFV.SettlementProcessId=MSP.MtStatementProcess_ID
where MSP.MtStatementProcess_ID=@pSettlementProcessId and IFV.SOFileTemplateId=@pLuSOFileTemplateId
) as DataId
 on DataId.LuAccountingMonth_Id_Current=MSM.LuAccountingMonth_Id and DataId.Version=MSM.MtSOFileMaster_Version and DataId.SOFileTemplateId= MSM.LuSOFileTemplate_Id
 where ISNULL( MSM.MtSOFileMaster_IsDeleted,0)=0
and MSM.LuSOFileTemplate_Id=@pLuSOFileTemplateId
and MSM.LuAccountingMonth_Id=DataId.LuAccountingMonth_Id_Current



--select @MtSOFileMasterID=MSM.MtSOFileMaster_Id from MtSOFileMaster MSM  
--LEFt join 
--(
--select MSP.LuAccountingMonth_Id_Current, IFV.Version, IFV.SOFileTemplateId from MtStatementProcess MSP
----JOIN SrProcessDef SPD on SPD.SrProcessDef_ID=MSP.SrProcessDef_ID
----JOIN RuProcessInputDef PID on PID.SrProcessDef_ID=MSP.SrProcessDef_ID
--LEFT JOIN BMEInputsSOFilesVersions IFV on IFV.SettlementProcessId=MSP.MtStatementProcess_ID
--where MSP.MtStatementProcess_ID=@pSettlementProcessId and IFV.SOFileTemplateId=@pLuSOFileTemplateId
--) as DataId
-- on DataId.LuAccountingMonth_Id_Current=MSM.LuAccountingMonth_Id and DataId.Version=MSM.MtSOFileMaster_Version and DataId.SOFileTemplateId= MSM.LuSOFileTemplate_Id


 RETURN @MtSOFileMasterID

END

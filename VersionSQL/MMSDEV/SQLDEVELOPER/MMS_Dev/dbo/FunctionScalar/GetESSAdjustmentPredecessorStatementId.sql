/****** Object:  Function [dbo].[GetESSAdjustmentPredecessorStatementId]    Committed by VersionSQL https://www.versionsql.com ******/

-- select [dbo].[GetESSAdjustmentPredecessorStatementId](180)
CREATE function [dbo].[GetESSAdjustmentPredecessorStatementId] 
(
@pESSStatementProcessId decimal(18,0)
)
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @vPredecessorStatementProcessId int
	DECLARE @vLuAccountMonth_Id_Current int
	DECLARE @vSrProcessDefId int

	select @vLuAccountMonth_Id_Current=LuAccountingMonth_Id_Current, @vSrProcessDefId=SrProcessDef_ID from MtStatementProcess where MtStatementProcess_ID=@pESSStatementProcessId

	----------------------------------------------------------------
	--		BME - ESS Section
	----------------------------------------------------------------

	if(@vSrProcessDefId=7) --FOR BME-ESS only
	Begin
	Declare @vMaxBmeESSId as int;
		-- Get Id of most recent latest Bme-ESS
		select @vMaxBmeESSId=max (MtStatementProcess_ID ) from MtStatementProcess where LuAccountingMonth_Id_Current=@vLuAccountMonth_Id_Current and SrProcessDef_ID=7 and MtStatementProcess_ID<>@pESSStatementProcessId and ISNULL(MtStatementProcess_IsDeleted,0)=0;	--BME-ESS
		-- If no ESS exists for provided month, then get Id of BME-FSS
		if (@vMaxBmeESSId is null or @vMaxBmeESSId = '')
		BEGIN 
			select @vPredecessorStatementProcessId=max (MtStatementProcess_ID ) from MtStatementProcess where LuAccountingMonth_Id_Current=@vLuAccountMonth_Id_Current and SrProcessDef_ID=4 and ISNULL(MtStatementProcess_IsDeleted,0)=0;	  --BME-FSS
		END
		ELSE
			BEGIN
			set @vPredecessorStatementProcessId=@vMaxBmeESSId
			END

	END

	----------------------------------------------------------------
	--		ASC - ESS Section
	----------------------------------------------------------------

	if(@vSrProcessDefId=8) --FOR ASC-ESS only
	Begin
	Declare @vMaxAscESSId as int;
		-- Get Id of most recent latest ASC-ESS
		select @vMaxAscESSId=max (MtStatementProcess_ID ) from MtStatementProcess where LuAccountingMonth_Id_Current=@vLuAccountMonth_Id_Current and SrProcessDef_ID=8 and MtStatementProcess_ID<>@pESSStatementProcessId and ISNULL(MtStatementProcess_IsDeleted,0)=0;	--BME-ESS
		-- If no ESS exists for provided month, then get Id of BME-FSS
		if (@vMaxAscESSId is null or @vMaxAscESSId = '')
		BEGIN 
			select @vPredecessorStatementProcessId=max (MtStatementProcess_ID ) from MtStatementProcess where LuAccountingMonth_Id_Current=@vLuAccountMonth_Id_Current and SrProcessDef_ID=5 and ISNULL(MtStatementProcess_IsDeleted,0)=0;	  --ASC-FSS
		END
		ELSE
			BEGIN
			set @vPredecessorStatementProcessId=@vMaxAscESSId
			END

	END

	---------------------------------------------------------
	-- Return the result of the function
	RETURN @vPredecessorStatementProcessId

END

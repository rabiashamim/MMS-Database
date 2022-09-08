/****** Object:  Procedure [dbo].[ASC_StepDPerform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure [dbo].[ASC_StepDPerform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
			)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY    
   IF EXISTS(SELECT TOP 1 AscStatementData_Id FROM AscStatementDataGuHourly WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId)
   BEGIN
 
  DECLARE @BmeStatementProcessId decimal(18,0) = null;
SELECT top 1 @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@StatementProcessId);


WITH MpZoneMonthly_CTE
as
(
	select MH.BmeStatementData_StatementProcessId, MH.BmeStatementData_PartyRegisteration_Id
	,MH.BmeStatementData_PartyName
	,MH.BmeStatementData_PartyType_Code
	,MH.BmeStatementData_CongestedZoneID
    ,MH.BmeStatementData_CongestedZone
	,MH.BmeStatementData_Year,MH.BmeStatementData_Month,
	SUM(MH.BmeStatementData_MAC) AS AscStatementData_MAC,
	SUM(MH.BmeStatementData_MRC) AS AscStatementData_MRC,
	SUM(MH.BmeStatementData_IG_AC) AS AscStatementData_IG_AC,
	SUM(MH.BmeStatementData_RG_AC) AS AscStatementData_RG_AC,
	SUM(MH.BmeStatementData_GS_SC) AS AscStatementData_GS_SC,
	SUM(MH.BmeStatementData_GBS_BSC) AS AscStatementData_GBS_BSC,
	SUM(MH.BmeStatementData_TAC) AS AscStatementData_PAYABLE,
	SUM(MH.BmeStatementData_TC) AS AscStatementData_RECEIVABLE,
    SUM(MH.BmeStatementData_ES) AS AscStatementData_ES ,
	SUM(MH.BmeStatementData_ET) AS AscStatementData_ET
	from BmeStatementDataMpCategoryMonthly MH
	where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month 
    and MH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
	group by MH.BmeStatementData_PartyRegisteration_Id,MH.BmeStatementData_PartyName,MH.BmeStatementData_PartyType_Code,
    MH.BmeStatementData_CongestedZoneID,MH.BmeStatementData_CongestedZone,MH.BmeStatementData_Year,MH.BmeStatementData_Month,MH.BmeStatementData_StatementProcessId
)
insert into AscStatementDataMpZoneMonthly
(
    [AscStatementData_StatementProcessId]
	,[AscStatementData_Year]
      ,[AscStatementData_Month]
      ,[AscStatementData_CongestedZoneID]
      ,[AscStatementData_CongestedZone]
      ,[AscStatementData_PartyRegisteration_Id]
      ,[AscStatementData_PartyName]
      ,[AscStatementData_PartyType_Code]
      ,[AscStatementData_MRC]
      ,[AscStatementData_RG_AC]
      ,[AscStatementData_IG_AC]
      ,[AscStatementData_MAC]      
      ,[AscStatementData_GS_SC]
      ,[AscStatementData_GBS_BSC]
      ,[AscStatementData_SC_BSC]
	  ,[AscStatementData_PAYABLE]
	  ,[AscStatementData_RECEIVABLE]
      ,[AscStatementData_ES]
	  ,[AscStatementData_ET]
	  )
select 
    @StatementProcessId
    ,[BmeStatementData_Year]
      ,[BmeStatementData_Month]
      ,[BmeStatementData_CongestedZoneID]
      ,[BmeStatementData_CongestedZone]
      ,[BmeStatementData_PartyRegisteration_Id]
      ,[BmeStatementData_PartyName]
      ,[BmeStatementData_PartyType_Code]
      ,[AscStatementData_MRC]
      ,[AscStatementData_RG_AC]
      ,[AscStatementData_IG_AC]
      ,[AscStatementData_MAC]      
      ,[AscStatementData_GS_SC]
      ,[AscStatementData_GBS_BSC]
      ,ISNULL([AscStatementData_GS_SC],0) + ISNULL([AscStatementData_GBS_BSC],0) as SC_BSC
	  ,[AscStatementData_PAYABLE]
	  ,[AscStatementData_RECEIVABLE]
      ,[AscStatementData_ES]
	  ,[AscStatementData_ET]
	  from MpZoneMonthly_CTE C;



SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END
 ELSE
 BEGIN
 SELECT 0 AS [IS_VALID], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 END 
END TRY
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END

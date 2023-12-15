/****** Object:  Procedure [dbo].[ASC_StepCPerform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Proceduredbo.ASC_StepCPerform(			 
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

UPDATE BmeStatementDataMpCategoryHourly_SettlementProcess
-- BmeStatementData_MAC=MH.BmeStatementData_ES/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_MAC
--, BmeStatementData_MRC=MH.BmeStatementData_ES/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_MRC
--,BmeStatementData_IG_AC=MH.BmeStatementData_ES/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_IG_AC
--,BmeStatementData_RG_AC=MH.BmeStatementData_ES/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_RG_AC
--,BmeStatementData_GS_SC=MH.BmeStatementData_ES/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_GS_SC
--,BmeStatementData_GBS_BSC=MH.BmeStatementData_ES/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_GBS_BSC
-- TaskId: 4062
--,BmeStatementData_TC=MH.BmeStatementData_ES/CAST(NULLIF(ZM.AscStatementData_TD,0) AS DECIMAL(18,4))*ZM.AscStatementData_TAC
SET
 BmeStatementData_MAC=MH.BmeStatementData_EnergySuppliedActual/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_MAC
,BmeStatementData_MRC=MH.BmeStatementData_EnergySuppliedActual/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_MRC
,BmeStatementData_IG_AC=MH.BmeStatementData_EnergySuppliedActual/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_IG_AC
,BmeStatementData_RG_AC=MH.BmeStatementData_EnergySuppliedActual/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_RG_AC
,BmeStatementData_GS_SC=MH.BmeStatementData_EnergySuppliedActual/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_GS_SC
,BmeStatementData_GBS_BSC=MH.BmeStatementData_EnergySuppliedActual/NULLIF(ZM.AscStatementData_TD,0)*ZM.AscStatementData_GBS_BSC
,BmeStatementData_TC=MH.BmeStatementData_EnergySuppliedActual/CAST(NULLIF(ZM.AscStatementData_TD,0) AS DECIMAL(18,4))*ZM.AscStatementData_TAC
FROM BmeStatementDataMpCategoryHourly_SettlementProcess MH 
INNER JOIN AscStatementDataZoneMonthly ZM
ON MH.BmeStatementData_Year=ZM.AscStatementData_Year and MH.BmeStatementData_Month=ZM.AscStatementData_Month 
and MH.BmeStatementData_CongestedZoneID=ZM.AscStatementData_CongestedZoneID
where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month 
and ZM.AscStatementData_StatementProcessId=@StatementProcessId and MH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
and MH.BmeStatementData_PartyCategory_Code in ('CGEN','GEN','BPC','EGEN','EBPC','CSUP','BSUP','PAKT','INTT')
;

WITH MpCategoryMonthly_CTE
as
(
	select MH.BmeStatementData_StatementProcessId,
     MH.BmeStatementData_PartyRegisteration_Id,MH.BmeStatementData_PartyCategory_Code,MH.BmeStatementData_CongestedZoneID,MH.BmeStatementData_Year,MH.BmeStatementData_Month,
	SUM(BmeStatementData_ES) AS BmeStatementData_ES,
	SUM(BmeStatementData_EnergyTraded) AS BmeStatementData_EnergyTraded,
	SUM(BmeStatementData_MAC) AS BmeStatementData_MAC,
	SUM(BmeStatementData_MRC) AS BmeStatementData_MRC,
	SUM(BmeStatementData_IG_AC) AS BmeStatementData_IG_AC,
	SUM(BmeStatementData_RG_AC) AS BmeStatementData_RG_AC,
	SUM(BmeStatementData_GS_SC) AS BmeStatementData_GS_SC,
	SUM(BmeStatementData_GBS_BSC) AS BmeStatementData_GBS_BSC,	
	SUM(BmeStatementData_TC) AS BmeStatementData_TC
	 
	from BmeStatementDataMpCategoryHourly_SettlementProcess MH
	where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month 
    and MH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
	group by MH.BmeStatementData_StatementProcessId,
     MH.BmeStatementData_PartyRegisteration_Id,
     MH.BmeStatementData_PartyCategory_Code,
    MH.BmeStatementData_CongestedZoneID,
    MH.BmeStatementData_Year,
    MH.BmeStatementData_Month
)
UPDATE BmeStatementDataMpCategoryMonthly_SettlementProcess
SET  BmeStatementData_MAC=C.BmeStatementData_MAC,
	BmeStatementData_IG_AC =C.BmeStatementData_IG_AC,
	BmeStatementData_MRC =C.BmeStatementData_MRC,
	BmeStatementData_RG_AC=C.BmeStatementData_RG_AC,
	BmeStatementData_GS_SC=C.BmeStatementData_GS_SC,
	BmeStatementData_GBS_BSC=C.BmeStatementData_GBS_BSC,	
	BmeStatementData_TC=C.BmeStatementData_TC		,
	BmeStatementData_ES = C.BmeStatementData_ES,
	BmeStatementData_ET=C.BmeStatementData_EnergyTraded
FROM BmeStatementDataMpCategoryMonthly_SettlementProcess CH INNER JOIN
MpCategoryMonthly_CTE C
ON CH.BmeStatementData_PartyRegisteration_Id= C.BmeStatementData_PartyRegisteration_Id 
and CH.BmeStatementData_PartyCategory_Code = C.BmeStatementData_PartyCategory_Code
and CH.BmeStatementData_CongestedZoneID = C.BmeStatementData_CongestedZoneID
AND CH.BmeStatementData_StatementProcessId= C.BmeStatementData_StatementProcessId
and CH.BmeStatementData_Year= C.BmeStatementData_Year
AND CH.BmeStatementData_Month = C.BmeStatementData_Month
where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month 
and CH.BmeStatementData_StatementProcessId=@BmeStatementProcessId;

----------------------------------------

WITH MpGenMonthly_CTE
as
(
	select MH.ASCStatementData_StatementProcessId, MH.AscStatementData_PartyRegisteration_Id,MH.AscStatementData_PartyCategory_Code
    ,MH.AscStatementData_CongestedZoneID,MH.AscStatementData_Year,MH.AscStatementData_Month
	,SUM(AscStatementData_TAC) AS AscStatementData_TAC
	 
	from AscStatementDataGenMonthly MH
	where MH.AscStatementData_Year=@Year and MH.AscStatementData_Month=@Month and MH.AscStatementData_StatementProcessId=@StatementProcessId
	group by MH.AscStatementData_PartyRegisteration_Id,MH.AscStatementData_PartyCategory_Code,
    MH.AscStatementData_CongestedZoneID,MH.AscStatementData_Year,MH.AscStatementData_Month,MH.AscStatementData_StatementProcessId
)
UPDATE BmeStatementDataMpCategoryMonthly_SettlementProcess
SET  BmeStatementData_TAC=C.AscStatementData_TAC
FROM BmeStatementDataMpCategoryMonthly_SettlementProcess CH INNER JOIN
MpGenMonthly_CTE C
ON CH.BmeStatementData_PartyRegisteration_Id= C.AscStatementData_PartyRegisteration_Id 
and CH.BmeStatementData_PartyCategory_Code = C.AscStatementData_PartyCategory_Code
and CH.BmeStatementData_CongestedZoneID = C.AscStatementData_CongestedZoneID
and CH.BmeStatementData_Year= C.AscStatementData_Year
AND CH.BmeStatementData_Month = C.AscStatementData_Month
where CH.BmeStatementData_Year=@Year and CH.BmeStatementData_Month=@Month
 and CH.BmeStatementData_StatementProcessId=@BmeStatementProcessId


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

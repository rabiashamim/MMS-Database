/****** Object:  Procedure [dbo].[ASC_StepBPerform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure [dbo].[ASC_StepBPerform](			 
			@Year int,
			@Month int
			,@StatementProcessId decimal(18,0)
			)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY

DECLARE @BmeStatementProcessId decimal(18,0) = null;
SELECT top 1 @BmeStatementProcessId = dbo.[GetBMEtatementProcessIdFromASC] (@StatementProcessId);

   IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpCategoryHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month 
   and BmeStatementData_StatementProcessId=@BmeStatementProcessId
   )
   BEGIN
 

UPDATE BmeStatementDataMpCategoryHourly
SET 
BmeStatementData_ES=NULLIF(MH.BmeStatementData_EnergySuppliedActual,0) - ISNULL(MH.BmeStatementData_EnergyTradedBought,0)
FROM BmeStatementDataMpCategoryHourly MH 
where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month 
and MH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
and MH.BmeStatementData_PartyCategory_Code in ('CGEN','GEN','BPC','EGEN','EBPC');

 UPDATE BmeStatementDataMpCategoryHourly
SET 
BmeStatementData_ES=MH.BmeStatementData_EnergySuppliedActual 
FROM BmeStatementDataMpCategoryHourly MH 
where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month 
and MH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
and MH.BmeStatementData_PartyCategory_Code in ('BSUP','PAKT','INTT');

-----------------------------------------------
  
 UPDATE BmeStatementDataMpCategoryHourly
SET 
BmeStatementData_ES=ISNULL(MH.BmeStatementData_EnergySuppliedActual,0) + ISNULL(MH.BmeStatementData_EnergyTradedSold,0)
FROM BmeStatementDataMpCategoryHourly MH 
where MH.BmeStatementData_Year=@Year and MH.BmeStatementData_Month=@Month 
and MH.BmeStatementData_StatementProcessId=@BmeStatementProcessId
and MH.BmeStatementData_PartyCategory_Code in ('CSUP');

-------------------------------------------------


UPDATE AscStatementDataZoneMonthly
SET 
AscStatementData_TD=MCM.BmeStatementData_TD
FROM AscStatementDataZoneMonthly GH 
JOIN (
   SELECT MCM.BmeStatementData_StatementProcessId, MCM.BmeStatementData_CongestedZoneID,MCM.BmeStatementData_Year, MCM.BmeStatementData_Month
   ,sum(MCM.BmeStatementData_ES)as BmeStatementData_TD
   FROM BmeStatementDataMpCategoryHourly MCM
   where MCM.BmeStatementData_Year=@Year and MCM.BmeStatementData_Month=@Month   
  and MCM.BmeStatementData_StatementProcessId=@BmeStatementProcessId
   and MCM.BmeStatementData_PartyCategory_Code in ('CGEN','GEN','BPC','EGEN','EBPC','CSUP','BSUP','PAKT','INTT')   
   GROUP BY MCM.BmeStatementData_CongestedZoneID,MCM.BmeStatementData_Year, MCM.BmeStatementData_Month,MCM.BmeStatementData_StatementProcessId
	)  MCM  
on 
MCM.BmeStatementData_CongestedZoneID=GH.AscStatementData_CongestedZoneID 
and MCM.BmeStatementData_Year=GH.AscStatementData_Year and MCM.BmeStatementData_Month=GH.AscStatementData_Month
where GH.AscStatementData_Year=@Year and GH.AscStatementData_Month=@Month
 AND MCM.BmeStatementData_StatementProcessId=@BmeStatementProcessId AND GH.AscStatementData_StatementProcessId=@StatementProcessId;

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

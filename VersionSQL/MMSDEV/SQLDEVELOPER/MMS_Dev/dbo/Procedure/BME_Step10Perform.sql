/****** Object:  Procedure [dbo].[BME_Step10Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 18, 2022 
-- ALTER date: June 01, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
CREATE   Procedure [dbo].[BME_Step10Perform](			 
			@Year int,
			@Month int
		,@StatementProcessId decimal(18,0)
)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
	--------------------------------------------------------	
	------		MP Hourly Calculations
	--------------------------------------------------------

     IF EXISTS(SELECT TOP 1 BmeStatementData_Id FROM BmeStatementDataMpMonthly 
     WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId)
    BEGIN
-------------------------------------
---		Step 10	Calculate Amount Payable Receivable
-------------------------------------


update BmeStatementDataMpMonthly set BmeStatementData_AmountPayableReceivable=isnull(BmeStatementData_ImbalanceCharges,0)+ isnull(BmeStatementData_SettlementOfLegacy,0)
where BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId 
 and ISNULL(BmeStatementData_IsPowerPool ,0)=0;
  
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

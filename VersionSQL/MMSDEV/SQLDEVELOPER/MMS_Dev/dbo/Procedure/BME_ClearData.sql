/****** Object:  Procedure [dbo].[BME_ClearData]    Committed by VersionSQL https://www.versionsql.com ******/

  
-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant), Ali Imran (.Net/SQL Developer)  
-- CREATE date: March 28, 2022 
-- ALTER date: June 09, 2022   
-- Description: This procedure delete BME data from all related tables based on 
--             the year, month and statement process id values those are passed in 
--             the @Year, @Month and @StatementProcessId parameters.  
-- =============================================  
CREATE   Procedure [dbo].[BME_ClearData](      
    @Year int,
	@Month int,
    @StatementProcessId decimal(18,0)=null)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  BEGIN TRY 
	DELETE FROM BmeStatementDataMpCategoryMonthly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;  
	DELETE FROM BmeStatementDataMpCategoryHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM [BmeStatementDataMpMonthly] WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataMpContractHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataCdpContractHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month  and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataMpHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataTspHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataGenUnitHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataCdpHourly WHERE  BmeStatementData_Year=@Year and BmeStatementData_Month=@Month and BmeStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM BmeStatementDataCdpOwnerParty WHERE BmeStatementData_StatementProcessId=@StatementProcessId;
  
SELECT 1 AS [IS_VALID], @@ROWCOUNT AS [ROW_COUNT], OBJECT_NAME(@@PROCID) AS [SP_NAME];
 
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

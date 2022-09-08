/****** Object:  Procedure [dbo].[ASC_ClearData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE   Procedure [dbo].[ASC_ClearData](      
    @Year int,
	@Month int,
    @StatementProcessId decimal(18,0)=null)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
BEGIN TRY

    DELETE FROM [dbo].[AscStatementDataMpMonthly]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM [dbo].[AscStatementDataMpZoneMonthly]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId;
	DELETE FROM [dbo].[AscStatementDataZoneMonthly]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId;
	DELETE FROM [dbo].[AscStatementDataGenMonthly]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId;
	DELETE FROM [dbo].[AscStatementDataGuMonthly]	WHERE AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM [dbo].[AscStatementDataGuHourly] WHERE  AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId;
    DELETE FROM [dbo].[AscStatementDataCdpGuParty] WHERE AscStatementData_StatementProcessId=@StatementProcessId;

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

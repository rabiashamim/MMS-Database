/****** Object:  Procedure [dbo].[ASC_Step9Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--    [dbo].[ASC_Step1Perform] 2021,11
CREATE   Procedure [dbo].[ASC_Step9Perform](			 
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
/*
Step A- 9.1	Aggregate Genetation Unit AC and BSC				
1."//Sum of AC_Total
AC_Total"	
2."//Sum of SC_BSC
SC_BSC"
*/
/*
Step A- 9.2	Total monthly compensation to a Generator for the provision of ASC
MAC = AC_Total + SC_BSC
*/
/*
Step A- 9.3	Aggregate Must Run Generator Monthly			
"//Sum of MRC
MMRC"
*/
/*
Step A- 10	The total amount of compensation for allowing the provision of Ancillary Services and Must Run Generation			
TAC = MAC + MMRC
*/
 --DECLARE @Year int=2021, @Month int=11;
 --DROP TABLE IF EXISTS #TempBSC

 select GUM.AscStatementData_Generator_Id,GUM.AscStatementData_Year, GUM.AscStatementData_Month, 
 SUM(AscStatementData_AC_Total) as AC_Total,
 SUM(AscStatementData_SC_BSC) as SC_BSC,
 SUM(AscStatementData_MRC) as MRC
 INTO #TempBSC
from AscStatementDataGuMonthly GUM
where GUM.AscStatementData_Year=@Year and GUM.AscStatementData_Month=@Month and GUM.AscStatementData_StatementProcessId=@StatementProcessId 
GROUP BY GUM.AscStatementData_Generator_Id,GUM.AscStatementData_Year, GUM.AscStatementData_Month;

--select * from #TempBSC
UPDATE AscStatementDataGenMonthly SET
AscStatementData_AC_Total =ISNULL(TB.AC_Total,0),
AscStatementData_SC_BSC =ISNULL(TB.SC_BSC,0),
AscStatementData_MAC = ISNULL(TB.AC_Total,0) + ISNULL(TB.SC_BSC,0),
AscStatementData_MRC =ISNULL(TB.MRC,0),
AscStatementData_TAC =ISNULL(TB.AC_Total,0) + ISNULL(TB.SC_BSC,0) + ISNULL(TB.MRC,0)
FROM  AscStatementDataGenMonthly GUM
INNER JOIN #TempBSC TB on  GUM.AscStatementData_Year=TB.AscStatementData_Year and GUM.AscStatementData_Month=TB.AscStatementData_Month 
and TB.AscStatementData_Generator_Id=GUM.AscStatementData_Generator_Id
where GUM.AscStatementData_Year=@Year and GUM.AscStatementData_Month=@Month and GUM.AscStatementData_StatementProcessId=@StatementProcessId


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

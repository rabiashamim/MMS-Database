/****** Object:  Procedure [dbo].[ASC_Step6Perform]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: April 18, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- Parameters: @Year, @Month, @StatementProcessId
-- ============================================= 
--   
CREATE   PROCEDURE dbo.ASC_Step6Perform(			 
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
"AC_total =  
∑(RG_LOCC * (SO_MP – SO_RG_VC))  + 
∑(IG_UPC *    (SO_IG_VC – SO_MP))"

*/
UPDATE AscStatementDataGuHourly SET
--AscStatementData_RG_AC=CASE WHEN ISNULL(AscStatementData_RG_LOCC,0) <0 then 0 else   ISNULL(AscStatementData_RG_LOCC,0)*(ISNULL(AscStatementData_SO_MP,0) - ISNULL(AscStatementData_SO_RG_VC,0)) end,
--AscStatementData_RG_AC_WithNegativeValues=  ISNULL(AscStatementData_RG_LOCC,0) *(ISNULL(AscStatementData_SO_MP,0) - ISNULL(AscStatementData_SO_RG_VC,0)),
AscStatementData_RG_AC=  ISNULL(AscStatementData_RG_LOCC,0) *(ISNULL(AscStatementData_SO_MP,0) - ISNULL(AscStatementData_SO_RG_VC,0)),
AscStatementData_IG_AC=  ISNULL(AscStatementData_IG_UPC,0) * (ISNULL(AscStatementData_SO_IG_VC,0)-ISNULL(AscStatementData_SO_MP,0)),
AscStatementData_AC_total =CASE WHEN ISNULL(AscStatementData_RG_LOCC,0) <0 then 0 ELSE ISNULL(AscStatementData_RG_LOCC,0) *(ISNULL(AscStatementData_SO_MP,0) - ISNULL(AscStatementData_SO_RG_VC,0)) end,
AscStatementData_AC_total_WithNegativeValues =  ISNULL(AscStatementData_RG_LOCC,0) *(ISNULL(AscStatementData_SO_MP,0) - ISNULL(AscStatementData_SO_RG_VC,0)) 
+ ISNULL(AscStatementData_IG_UPC,0) * (ISNULL(AscStatementData_SO_IG_VC,0)-ISNULL(AscStatementData_SO_MP,0))
where AscStatementData_Year=@Year and AscStatementData_Month=@Month and AscStatementData_StatementProcessId=@StatementProcessId


SELECT
	1 AS [IS_VALID]
   ,@@rowcount AS [ROW_COUNT]
   ,OBJECT_NAME(@@procid) AS [SP_NAME];
 END
 ELSE
BEGIN
	SELECT
		0 AS [IS_VALID]
	   ,OBJECT_NAME(@@procid) AS [SP_NAME];
END 
END TRY
BEGIN CATCH
SELECT
	ERROR_NUMBER() AS ErrorNumber
   ,ERROR_STATE() AS ErrorState
   ,ERROR_SEVERITY() AS ErrorSeverity
   ,ERROR_PROCEDURE() AS ErrorProcedure
   ,ERROR_LINE() AS ErrorLine
   ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END

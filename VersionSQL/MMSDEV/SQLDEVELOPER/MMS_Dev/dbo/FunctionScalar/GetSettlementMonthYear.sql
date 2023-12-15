/****** Object:  ScalarFunction [dbo].[GetSettlementMonthYear]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  Ammama Gill  
-- Create date: 18-01-2023  
-- Description: Returns the relevant month/ year or combinations on the basis of the period ID (if exists)  
-- =============================================  

--  [GetSettlementMonthYear] 35
CREATE FUNCTION dbo.GetSettlementMonthYear (@pSettlementId DECIMAL(18, 0))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @vSettlementMonthYear VARCHAR(20) = '';


	SELECT
		@vSettlementMonthYear =
		CASE
			WHEN lam.PeriodTypeID IN (1, 3) THEN lam.LuAccountingMonth_MonthName
			WHEN lam.PeriodTypeID = 2 THEN CAST(lam.LuAccountingMonth_Year AS VARCHAR(20))
		END

	FROM LuAccountingMonth lam
	WHERE lam.LuAccountingMonth_Id = @pSettlementId
	AND ISNULL(lam.LuAccountingMonth_IsDeleted, 0) = 0

	RETURN @vSettlementMonthYear;

END  
  

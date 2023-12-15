/****** Object:  Procedure [dbo].[GetLuAccountingPeriodList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE dbo.GetLuAccountingPeriodList (@pSrProcessDef_Id DECIMAL(18, 0) = NULL
, @pPeriodType INT = NULL, @pLuStatus_Code VARCHAR(5) = NULL
)
AS
BEGIN


	SELECT
		LuAccountingMonth_Id
	   ,LuAccountingMonth_MonthName
	   ,LuStatus_Code
	FROM LuAccountingMonth
	WHERE LuStatus_Code =@pLuStatus_Code
	--CASE
	--	WHEN @pSrProcessDef_Id IN (19, 23) THEN 'CLSD'
	--	ELSE 'OPEN'
	--END
	 
	
	AND LuAccountingMonth_IsDeleted = 0
	AND PeriodTypeID = @pPeriodType
	ORDER BY 1
END

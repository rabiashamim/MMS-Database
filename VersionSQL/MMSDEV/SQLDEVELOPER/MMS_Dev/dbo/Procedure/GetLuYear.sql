/****** Object:  Procedure [dbo].[GetLuYear]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================              
-- Author:  Kapil Kumar          
-- CREATE date: Jan 13, 2023             
-- ALTER date:             
-- Reviewer:        
-- Description:             
-- =============================================            
-- GetLuYear 2   
CREATE PROCEDURE dbo.GetLuYear @pLuPeriodType INT = NULL

AS
BEGIN
	IF @pLuPeriodType = 2
	BEGIN
		SELECT
			ly.Lu_Year
		   ,ly.Lu_Year

		FROM LuYear ly
		ORDER BY 1
	END
	ELSE IF @pLuPeriodType=3
	BEGIN
	SELECT
			lfy.Lu_FinancialYear AS Lu_Year
		   ,lfy.Lu_FinancialYear  AS Lu_Year

		FROM LuFinancialYear lfy 
		ORDER BY 1
	END

END

/****** Object:  Procedure [dbo].[GetSettlementProcessList]    Committed by VersionSQL https://www.versionsql.com ******/

/************************************************************/  
-- =============================================                              
-- Author: Ammama Gill  
-- CREATE date:  01/02/2023                                              
-- ALTER date:                                                 
-- Reviewer:                                                
-- Description: Self explanatory.                                         
-- =============================================                                                 
-- =============================================  
CREATE PROCEDURE GetSettlementProcessList (@pSettlementPeriodType INT)
AS
BEGIN
	SELECT
		SPD.SrProcessDef_ID
	   ,CONCAT(SPD.SrProcessDef_Name, ' - ', SSD.SrStatementDef_Name) AS StatementProcessName
	   ,SPD.SrProcessDef_Name
	   ,SSD.SrStatementDef_Name
	   ,SPD.SrProcessDef_PeriodType
	FROM SrStatementDef SSD
	INNER JOIN SrProcessDef SPD
		ON SPD.SrStatementDef_ID = SSD.SrStatementDef_ID
	WHERE SPD.SrProcessDef_PeriodType =
	CASE
		WHEN @pSettlementPeriodType = 1 THEN 1 -- for monthly
		WHEN @pSettlementPeriodType = 2 THEN 3 -- for Yearly 
	END
END

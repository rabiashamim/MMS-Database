/****** Object:  Procedure [dbo].[GetLuCapacityObligationsYearslist]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author: Ali Imran
-- CREATE date: May 16, 2023 
-- ALTER date:   
-- Description: GET ALL
-- =============================================   

CREATE   PROCEDURE dbo.GetLuCapacityObligationsYearslist

AS
BEGIN
	SELECT
	LuCapacityObligationsYears_Name	
	,LuCapacityObligationsYears_Discription
	FROM LuCapacityObligationsYears sc

END

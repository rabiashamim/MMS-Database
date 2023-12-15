/****** Object:  Procedure [dbo].[GetCategorylist]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author: Ali Imran
-- CREATE date: May 16, 2023 
-- ALTER date:   
-- Description: GET ALL
-- [MtCapacityObligationsSettings_GetAll]
--  [GetCategorylist]
-- =============================================   

CREATE   PROCEDURE dbo.GetCategorylist

AS
BEGIN
	SELECT
		SrCategory_Code
	   ,SrCategory_Name
	FROM SrCategory sc
	WHERE SC.SrCategory_Code IN ('BPC','CSUP','BSUP','INTT','PAKT');

END

/****** Object:  Function [dbo].[GetGeneratorName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GetGeneratorName] (@GenId INT)
RETURNS VARCHAR(50)
AS 
BEGIN

DECLARE @GenName VARCHAR(50);
	SELECT DISTINCT @GenName = 
		mgu.MtGenerator_Name
	FROM MtGenerator mgu 
	WHERE mgu.MtGenerator_Id = @GenId;

RETURN @GenName;

END

/****** Object:  Function [dbo].[GetGenerationUnitName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION dbo.GetGenerationUnitName (@GUId INT)
RETURNS VARCHAR(50)
AS 
BEGIN

DECLARE @GUName VARCHAR(50);
	SELECT DISTINCT @GUName = 
		mgu.MtGenerationUnit_UnitName 
	FROM MtGenerationUnit mgu 
	WHERE mgu.MtGenerationUnit_SOUnitId = @GUId;

RETURN @GUName;

END

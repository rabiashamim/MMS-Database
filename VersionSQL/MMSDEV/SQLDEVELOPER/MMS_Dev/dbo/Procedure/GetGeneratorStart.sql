/****** Object:  Procedure [dbo].[GetGeneratorStart]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetGeneratorStart]
@pFileMasterId decimal(18,0)
AS
BEGIN

SELECT *,
GenerationUnitName = dbo.GetGenerationUnitName(MtGenerationUnit_Id) 
FROM MtGeneratorStart
WHERE 
	MtSOFileMaster_Id=@pFileMasterId


END
